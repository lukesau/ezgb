`timescale 1ns/1ps
// logs each PicoBlaze address the first time it executes, and the bank
// FW4 by default; other builds pass +define+PC_BRAM=<bank-1 BRAM instance>
// and +define+BANK2=<bank-select net> (1'b0 logs everything as B1)
`ifndef PC_BRAM
`define PC_BRAM i_D0X3Y29_bram
`endif
`ifndef BANK2
`define BANK2 tb.dut.n_X10Y27_S0_YQ
`endif
module tbpc;
    reg seen [0:2047];
    integer i;
    initial for (i = 0; i < 2048; i = i + 1) seen[i] = 0;
    wire [9:0] pc = tb.dut.`PC_BRAM.ADDRA[13:4];
    wire bank2 = `BANK2;
    always @(pc) if (pc !== 10'bx && !seen[{bank2, pc}]) begin
        seen[{bank2, pc}] = 1;
        $display("%t new %s %h", $time, bank2 ? "B2" : "B1", pc);
    end
endmodule
