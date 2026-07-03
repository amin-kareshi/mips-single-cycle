
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
