
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
