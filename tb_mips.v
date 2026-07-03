`timescale 1ns/1ps
module tb_mips;
    reg clk = 0, reset = 1;
    integer cyc;

    MIPS cpu (.clk(clk), .reset(reset));
    always #5 clk = ~clk;   // 100 MHz

    // convenient hierarchical
    `define REG  cpu.rf.regs
    `define DMEM cpu.dmem.mem

    initial begin
        #2 reset = 1; #10 reset = 0;   // release after one edge

        // run 15 cycles
        for (cyc = 0; cyc < 15; cyc = cyc + 1) begin
            @(posedge clk);
            #1 $display("cyc=%0d  PC=%0d  instr=%h", cyc, cpu.pc_current, cpu.instruction);
        end

        $display("\n--- RESULTS ---");
        $display("$t0 ($8)  = %0d   (expected 10)",  `REG[8]);
        $display("$t1 ($9)  = %0d   (expected 20)",  `REG[9]);


        $display("$t2 ($10) = %0d   (expected 30  add)",   `REG[10]);
        $display("$t3 ($11) = %0d   (expected 10  sub)",   `REG[11]);


        $display("$t4 ($12) = %0d   (expected 0   and 10&20)", `REG[12]);

        $display("$t5 ($13) = %0d   (expected 30  or 10|20)",  `REG[13]);
        $display("$t6 ($14) = %0d   (expected 1   slt 10<20)", `REG[14]);

        $display("$t7 ($15) = %0d   (expected 30  lw)",        `REG[15]);
        
        $display("mem[0]    = %0d   (expected 30  sw)",        `DMEM[0]);
        $display("$s0 ($16) = %0d   (expected 0  - skipped by beq)", `REG[16]);
        $display("$s1 ($17) = %0d   (expected 0  - skipped by beq)", `REG[17]);
        $display("$s2 ($18) = %0d   (expected 0  - sub at branch target)", `REG[18]);

        // pass/fail check
        if (`REG[10]==30 && `REG[11]==10 && `REG[12]==0 && `REG[13]==30 &&
            `REG[14]==1  && `REG[15]==30 && `DMEM[0]==30 &&
            `REG[16]==0  && `REG[17]==0  && `REG[18]==0)
            $display("\n*** ALL CHECKS PASSED ***");
        else
            $display("\n*** SOME CHECKS FAILED ***");

        $finish;
    end
endmodule