`timescale 1ns/1ps
// First boot test: oscillator on P43, Game Boy bus idle, every other pin
// pulled up. Logs the PicoBlaze program counter (address of the X3Y29
// instruction BRAM) each time it changes, for comparison with X3Y29.psm.
module tb;
    wire P3, P4, P5, P6, P7, P9, P10, P12, P13, P15, P16, P19, P20, P21, P23, P24, P25,
         P27, P28, P29, P30, P31, P32, P33, P34, P35, P36, P37, P39, P40, P41, P43, P44, P46,
         P48, P49, P50, P51, P52, P53, P56, P57, P59, P60, P61, P62, P64, P65, P68, P70, P71,
         P72, P73, P77, P78, P82, P83, P84, P85, P86, P88, P89, P90, P93, P94, P97, P98, P99;
    fpga_top dut(.*);
    reg osc = 0;
    always #20 osc = !osc;               // 25 MHz (the real oscillator frequency is unknown)
    assign P43 = osc;
    // Game Boy idle: address 0, /WR high
    assign {P7, P6, P5, P4, P21, P39, P68, P82, P99, P98, P97, P94, P93, P90, P89, P88} = 16'h0000;
    assign P84 = 1'b1;
    pullup (P3); pullup (P9); pullup (P10); pullup (P12); pullup (P13); pullup (P15); pullup (P16);
    pullup (P19); pullup (P20); pullup (P23); pullup (P24); pullup (P25); pullup (P27); pullup (P28);
    pullup (P29); pullup (P30); pullup (P31); pullup (P32); pullup (P33); pullup (P34); pullup (P35);
    pullup (P36); pullup (P37); pullup (P40); pullup (P41); pullup (P44); pullup (P46); pullup (P48);
    pullup (P49); pullup (P50); pullup (P51); pullup (P52); pullup (P53); pullup (P56); pullup (P57);
    pullup (P59); pullup (P60); pullup (P61); pullup (P62); pullup (P64); pullup (P65); pullup (P70);
    pullup (P71); pullup (P72); pullup (P73); pullup (P77); pullup (P78); pullup (P83); pullup (P85);
    pullup (P86);
    wire [9:0] pc = dut.i_D0X3Y29_bram.ADDRA[13:4];
    wire [17:0] instr = {dut.i_D0X3Y29_bram.DOPA[1:0], dut.i_D0X3Y29_bram.DOA[15:0]};
    reg [9:0] last = 10'h3ff;
    integer n = 0;
    always @(pc) if (pc !== last && n < 400) begin
        $display("%t pc=%h instr=%h", $time, pc, instr);
        last = pc; n = n + 1;
    end
    initial begin
        #2000000;
        $display("done, %0d pc changes", n);
        $finish;
    end
endmodule
