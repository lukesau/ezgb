`timescale 1ns/1ps
// Full boot: oscillator on P43, config flash on its configuration pins, SD
// card on the bank-1 SD pins (see re/stage0/docs/design.md), Game Boy bus idle,
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
    // SD card: CLK P23, CMD P28, DAT0 P34, DAT1 P25, DAT2 P30, DAT3 P29
`ifndef SD_DAT
`define SD_DAT {P29, P30, P25, P34}       // DAT3..DAT0, confirmed by block reads through the GB window
`endif
    sd_card #(.IMAGE("card.img")) sd(.CLK(P23), .CMD(P28), .DAT(`SD_DAT));
    // Game Boy bus: A0-A15, D0-D7, /WR on P84. There is no /RD or /CS: the
    // FPGA drives D0-D7 from A13-A15 and /WR alone (re/stage0/docs/design.md).
    reg [15:0] gb_a = 16'h0000;
    reg [7:0] gb_d = 8'h00;
    reg gb_doe = 0, gb_wr_n = 1;
    assign {P7, P6, P5, P4, P21, P39, P68, P82, P99, P98, P97, P94, P93, P90, P89, P88} = gb_a;
    assign {P19, P16, P15, P13, P12, P10, P9, P3} = gb_doe ? gb_d : 8'hzz;
    assign P84 = gb_wr_n;
    wire [7:0] gb_q = {P19, P16, P15, P13, P12, P10, P9, P3};
    // P61: an input next to /RESET, not placed yet (the cart edge's CLK, /RD
    // or /CS). Pulled up unless one of these says otherwise.
`ifdef P61_PHI
    reg phi = 0;
    always #477 phi = !phi;              // ~1.05 MHz, the Game Boy's bus clock
`ifdef P61_INV
    assign P61 = !phi;                   // same clock, opposite phase to the bus cycles
`elsif P61_RD
    reg rd_n = 0;                        // DMG /RD: low except during a write cycle
    assign P61 = rd_n;
`elsif P61_HIGH
    assign P61 = 1'b1;                   // held high, bus cycles still timed by phi
`elsif P61_POR
    // P61 reads the console's /RESET at the cart edge (P62 is the FPGA's
    // drive of it): low while the console powers up, high from 1 ms
    reg por_n = 0;
    initial #1000000 por_n = 1;
    assign P61 = por_n;
`elsif P61_CS
    reg cs_n = 1;                        // DMG /CS: low for $A000-$FFFF accesses
    assign P61 = cs_n;
`else
    assign P61 = phi;
`endif
`elsif P61_LOW
    assign P61 = 1'b0;
`else
    pullup (P61);
`endif
    // one machine cycle each, about 1 us as on a DMG
`ifdef P61_FREE
    reg fphi = 0;
    always #477 fphi = !fphi;
    assign P61 = fphi;
`endif
`ifdef P61_PHI
    // Bus cycles locked to the clock on P61, timed as a real DMG's cartridge
    // bus (measured by the Retrode author, forum.retrode.com msg 3139): the
    // cycle starts at the rising edge, the address changes ~150 ns later,
    // write data goes out from ~450 ns with /WR low ~480-840 ns while the
    // clock is low, and reads are sampled in the middle of the low half.
    task gb_write(input [15:0] a, input [7:0] d);
        begin
            @(posedge phi);
`ifdef P61_RD
            #140; rd_n = 1; #10;
`else
            #150;
`endif
            gb_a = a;
`ifdef P61_CS
            #100; cs_n = !(a >= 16'hA000); #200;
`else
            #300;
`endif
            gb_d = d; gb_doe = 1; #30; gb_wr_n = 0;
            #360; gb_wr_n = 1; #100; gb_doe = 0;
`ifdef P61_RD
            rd_n = 0;
`endif
`ifdef P61_CS
            cs_n = 1;
`endif
        end
    endtask
    task gb_read(input [15:0] a, output [7:0] d);
        begin
            @(posedge phi); #150; gb_a = a;
`ifdef P61_CS
            #100; cs_n = !(a >= 16'hA000);
`endif
            @(negedge phi); #230; d = gb_q;
`ifdef P61_CS
            #200; cs_n = 1;
`endif
        end
    endtask
`else
    task gb_write(input [15:0] a, input [7:0] d);
        begin
            gb_a = a; #200; gb_d = d; gb_doe = 1; #100; gb_wr_n = 0; #450; gb_wr_n = 1; #100; gb_doe = 0; #100;
        end
    endtask
    task gb_read(input [15:0] a, output [7:0] d);
        begin
            gb_a = a; #800; d = gb_q; #150;
        end
    endtask
`endif
    // Memory bus: U9 (game ROM pSRAM, /CE P52) and U4 (save pSRAM, /CE P60)
    // share the address, data, /WE and byte-lane pins; word address A14 and up
    // come from the 74HC595 (SRCLK P35, SER P33, RCLK P24). See
    // re/stage0/docs/design.md. /OE is not identified yet and is tied active.
    wire [7:0] bank;
    hc595 u2(.SRCLK(P35), .SER(P33), .RCLK(P24), .Q(bank));
    wire [22:0] mem_a = {1'b0, bank, P51, P46, P53, P20, P86, P83, P50, P44, P73, P70, P71, P65, P59, P56};
    wire [7:0] mem_d = {P64, P41, P57, P49, P48, P72, P77, P78};
    wire [7:0] u9_q, u4_q;
    wire u9_oe, u4_oe;
`ifndef RTC_TICK_NS
`define RTC_TICK_NS 3000000
`endif
`ifdef PRELOAD
    // gb_mbc.vh: start from tagged images instead of an SD load
    localparam U9_IMG = "u9.img", U4_IMG = "u4.img";
`else
    localparam U9_IMG = "", U4_IMG = "";
`endif
    psram #(.WORDS(4194304), .IMAGE(U9_IMG), .NAME("U9")) u9(.A(mem_a), .D(mem_d), .Q(u9_q), .OE(u9_oe),
        .CE_N(P52), .WE_N(P40), .OE_N(1'b0), .LB_N(P37), .UB_N(P36));
    psram #(.WORDS(262144), .IMAGE(U4_IMG), .NAME("U4")) u4(.A(mem_a), .D(mem_d), .Q(u4_q), .OE(u4_oe),
        .CE_N(P60), .WE_N(P40), .OE_N(1'b0), .LB_N(P37), .UB_N(P36));
    // the memories drive only while the FPGA's data pins are tri-stated
    wire [7:0] mem_q = u9_oe ? u9_q : u4_q;
    wire fpga_drives_mem = !dut.i_X23Y33_IOI0.t;   // P78's tristate (all eight share it)
    reg mem_drive = 0;
`ifdef NO_MEM_READ
    always #1 mem_drive = 0;
`else
    always #1 mem_drive = (u9_oe || u4_oe) && !fpga_drives_mem;
`endif
    assign {P64, P41, P57, P49, P48, P72, P77, P78} = mem_drive ? mem_q : 8'hzz;
`ifdef GB_TEST
`include `GB_TEST
`endif
    pullup (P3); pullup (P9); pullup (P10); pullup (P12); pullup (P13); pullup (P15); pullup (P16);
    pullup (P19); pullup (P20); pullup (P23); pullup (P24); pullup (P25); pullup (P28);
`ifdef RTC
    // PCF8563 on the I2C pins (+define+RTC_SCL=P31 +define+RTC_SDA=P32 or
    // the other way round); open drain, pulled high
    wire rtc_sda_low;
    pcf8563 #(.TICK_NS(`RTC_TICK_NS)) rtc(.SCL(`RTC_SCL), .SDA(`RTC_SDA), .SDA_LOW(rtc_sda_low));
    assign `RTC_SDA = rtc_sda_low ? 1'b0 : 1'bz;
    assign (weak0, weak1) P31 = 1'b1;
    assign (weak0, weak1) P32 = 1'b1;
    pullup (P29); pullup (P30); pullup (P33); pullup (P34); pullup (P35);
`else
    pullup (P29); pullup (P30); pullup (P31); pullup (P32); pullup (P33); pullup (P34); pullup (P35);
`endif
    pullup (P36); pullup (P37); pullup (P40); pullup (P41); pullup (P44); pullup (P48);
    pullup (P49); pullup (P50); pullup (P52); pullup (P56); pullup (P57);
    pullup (P59); pullup (P60); pullup (P62); pullup (P64); pullup (P65); pullup (P70);
    pullup (P71); pullup (P72); pullup (P73); pullup (P77); pullup (P78); pullup (P83); pullup (P85);
    pullup (P86);
    initial begin
        #(`RUN_NS);
`ifdef U9_DUMP
        u9.dump("u9.bin", `U9_DUMP);
`endif
        pinmon.report;
        $finish;
    end
endmodule
