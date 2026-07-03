
// Instruction Memory

module InstMem (
    input  [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] mem [0:63];
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1) mem[i] = 32'h00000000;
        // test program
        mem[0]  = 32'h01095020; // add  
        
        mem[1]  = 32'h01285822; // sub  
        mem[2]  = 32'h01096024; // and  
        mem[3]  = 32'h01096825; // or   
        mem[4]  = 32'h0109702a; // slt  
        mem[5]  = 32'hac0a0000; // sw   
        mem[6]  = 32'h8c0f0000; // lw   

        mem[7]  = 32'h11080002; // beq  
        mem[8]  = 32'h01098020; // add  
        mem[9]  = 32'h01098820; // add  


        mem[10] = 32'h014f9022; // sub  
        mem[11] = 32'h0800000c; // jump
        mem[12] = 32'h00000020; // nop 
    end

    assign instruction = mem[addr[31:2]];
endmodule

// Register File

module RegFile (
    input         clk,
    input         reset,
    input         RegWrite,
    input  [4:0]  read_reg1,
    input  [4:0]  read_reg2,
    input  [4:0]  write_reg,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] regs [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) regs[i] = 32'b0;
        regs[8] = 32'd10;   // $t0 = 10
        regs[9] = 32'd20;   // $t1 = 20
    end

    always @(posedge clk) begin
        if (RegWrite && (write_reg != 5'b0))
            regs[write_reg] <= write_data;
    end

    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : regs[read_reg2];
endmodule


//  Program Counter

module PCounter (
    input         clk,
    input         reset,
    input  [31:0] pc_next,
    output reg [31:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'b0;
        else       pc <= pc_next;
    end
endmodule
// ALU 

module ALU (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_ctrl,
    output reg [31:0] result,
    output        zero
);
    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a & b;
            4'b0001: result = a | b;
            4'b0010: result = a + b;
            4'b0110: result = a - b;
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'b1100: result = ~(a | b);
            default: result = 32'b0;
        endcase
    end
    assign zero = (result == 32'b0);
endmodule


// ALU Control

module ALUCtrl (
    input  [1:0] ALUOp,
    input  [5:0] funct,
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        case (ALUOp)
            2'b00: alu_ctrl = 4'b0010;            
            2'b01: alu_ctrl = 4'b0110;            
            2'b10: begin                         
                case (funct)
                    6'b100000: alu_ctrl = 4'b0010; // add
                    6'b100010: alu_ctrl = 4'b0110; // sub
                    6'b100100: alu_ctrl = 4'b0000; // and
                    6'b100101: alu_ctrl = 4'b0001; // or
                    6'b101010: alu_ctrl = 4'b0111; // slt
                    default:   alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule

// Control Unit

module CtrlUnit (
    input  [5:0] opcode,
    output reg   RegDst,
    output reg   ALUSrc,
    output reg   MemtoReg,
    output reg   RegWrite,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   Branch,
    output reg   Jump,
    output reg [1:0] ALUOp
);
    always @(*) begin
        // defaults
        RegDst=0; ALUSrc=0; MemtoReg=0; RegWrite=0;
        MemRead=0; MemWrite=0; Branch=0; Jump=0; ALUOp=2'b00;
        case (opcode)
            6'b000000: begin
                RegDst=1; RegWrite=1; ALUOp=2'b10;
            end
            6'b100011: begin
                ALUSrc=1; MemtoReg=1; RegWrite=1; MemRead=1; ALUOp=2'b00;
            end
            6'b101011: begin 
                ALUSrc=1; MemWrite=1; ALUOp=2'b00;
            end
            6'b000100: begin 
                Branch=1; ALUOp=2'b01;
            end
            6'b000010: begin
                Jump=1;
            end
            default: ; 
        endcase
    end
endmodule

//  Data Memory

module DataMem (
    input         clk,
    input         MemRead,
    input         MemWrite,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:63];
    integer i;
    initial for (i = 0; i < 64; i = i + 1) mem[i] = 32'b0;

    always @(posedge clk)
        if (MemWrite) mem[addr[31:2]] <= write_data;

    assign read_data = MemRead ? mem[addr[31:2]] : 32'b0;
endmodule


module MIPS (
    input clk,
    input reset
);
    // Fetch
    wire [31:0] pc_current, pcounter_plus4, pc_next, pc_branch, pc_branchmux, pc_jump;
    wire [31:0] instruction;

    PCounter pc_reg (.clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc_current));
    assign pcounter_plus4 = pc_current + 32'd4;
    InstMem imem (.addr(pc_current), .instruction(instruction));

    // Instruction fields
    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rs     = instruction[25:21];
    wire [4:0] rt     = instruction[20:16];
    wire [4:0] rd     = instruction[15:11];
    wire [5:0] funct  = instruction[5:0];
    wire [15:0] imm16 = instruction[15:0];

    // Control
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jump;
    wire [1:0] ALUOp;
    CtrlUnit ctrl (
        .opcode(opcode), .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg),
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite),
        .Branch(Branch), .Jump(Jump), .ALUOp(ALUOp)
    );

    // Register file
    wire [4:0]  write_reg = RegDst ? rd : rt;
    wire [31:0] read_data1, read_data2, write_data;
    RegFile rf (
        .clk(clk), .reset(reset), .RegWrite(RegWrite),
        .read_reg1(rs), .read_reg2(rt), .write_reg(write_reg),
        .write_data(write_data), .read_data1(read_data1), .read_data2(read_data2)
    );

    // Sign extend
    wire [31:0] sign_ext = {{16{imm16[15]}}, imm16};

    // ALU
    wire [31:0] alu_b = ALUSrc ? sign_ext : read_data2;
    wire [3:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        zero;
    ALUCtrl aluctl (.ALUOp(ALUOp), .funct(funct), .alu_ctrl(alu_ctrl));
    ALU alu (.a(read_data1), .b(alu_b), .alu_ctrl(alu_ctrl),
             .result(alu_result), .zero(zero));

    // Data memory
    wire [31:0] mem_read_data;
    DataMem dmem (
        .clk(clk), .MemRead(MemRead), .MemWrite(MemWrite),
        .addr(alu_result), .write_data(read_data2), .read_data(mem_read_data)
    );

    assign write_data = MemtoReg ? mem_read_data : alu_result;

    assign pc_branch     = pcounter_plus4 + (sign_ext << 2);
    wire branch_taken    = Branch & zero;
    assign pc_branchmux  = branch_taken ? pc_branch : pcounter_plus4;
    assign pc_jump       = {pcounter_plus4[31:28], instruction[25:0], 2'b00};
    assign pc_next       = Jump ? pc_jump : pc_branchmux;

endmodule