`timescale 1ns/1ps
// Full boot: oscillator on P43, config flash on its configuration pins, SD
// card on the bank-1 SD pins (see docs/fpga-design.md), Game Boy bus idle,
// every other pin pulled up. Works under iverilog and Verilator (glbl and
// the monitors are instantiated here, so tb is the only top).
//   iverilog -g2012 -s tb s3prims.v models.v pinmon.v tb_pcmap.v design.v tb_full.v
//   or Verilator: --binary --timing --top-module tb, same files
module tb;
    wire P3, P4, P5, P6, P7, P9, P10, P12, P13, P15, P16, P19, P20, P21, P23, P24, P25,
         P27, P28, P29, P30, P31, P32, P33, P34, P35, P36, P37, P39, P40, P41, P43, P44, P46,
         P48, P49, P50, P51, P52, P53, P56, P57, P59, P60, P61, P62, P64, P65, P68, P70, P71,
         P72, P73, P77, P78, P82, P83, P84, P85, P86, P88, P89, P90, P93, P94, P97, P98, P99;
    glbl glbl();
    tbpc tbpc();
    pinmon pinmon();
    fpga_top dut(.*);
    reg osc = 0;
    always #20 osc = !osc;               // 25 MHz (the real oscillator frequency is unknown)
    assign P43 = osc;
    // config flash: CS P27, CLK P53, MOSI P46, MISO P51
    wire miso;
    spi_flash #(.IMAGE("flash.hex")) flash(.CS_N(P27), .CLK(P53), .MOSI(P46), .MISO(miso));
    assign P51 = P27 ? 1'bz : miso;
    // SD card: CLK P23, CMD P28, DAT0-3 (order still being confirmed)
`ifndef SD_DAT
`define SD_DAT {P29, P25, P30, P34}
`endif
    sd_card #(.IMAGE("card.img")) sd(.CLK(P23), .CMD(P28), .DAT(`SD_DAT));
    // Game Boy idle: address 0, /WR high
    assign {P7, P6, P5, P4, P21, P39, P68, P82, P99, P98, P97, P94, P93, P90, P89, P88} = 16'h0000;
    assign P84 = 1'b1;
    pullup (P3); pullup (P9); pullup (P10); pullup (P12); pullup (P13); pullup (P15); pullup (P16);
    pullup (P19); pullup (P20); pullup (P23); pullup (P24); pullup (P25); pullup (P28);
    pullup (P29); pullup (P30); pullup (P31); pullup (P32); pullup (P33); pullup (P34); pullup (P35);
    pullup (P36); pullup (P37); pullup (P40); pullup (P41); pullup (P44); pullup (P48);
    pullup (P49); pullup (P50); pullup (P52); pullup (P56); pullup (P57);
    pullup (P59); pullup (P60); pullup (P61); pullup (P62); pullup (P64); pullup (P65); pullup (P70);
    pullup (P71); pullup (P72); pullup (P73); pullup (P77); pullup (P78); pullup (P83); pullup (P85);
    pullup (P86);
    initial begin
        #(`RUN_NS);
        pinmon.report;
        $finish;
    end
endmodule
