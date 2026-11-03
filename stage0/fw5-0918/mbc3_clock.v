// FW5-0918's MBC3 clock registers, which FW4 doesn't have. All are Game
// Boy registers on /WR; the PicoBlaze is the clock between them:
//
//   - mbc3_wr_*: what an MBC3 game writes to clock registers $08-$0C
//     (seconds, minutes, hours, DL, DH) through $A000-$BFFF, with RAM
//     enabled, the bank register all ones and rtc_sel $08-$0C. Bits the
//     MBC3 doesn't have read back as 0 (seconds and minutes keep 6 bits,
//     hours 5, DH bits 0, 6 and 7). The kernel writes all eight bits at
//     $A010-$A014 in its register window. The PicoBlaze reads them at
//     INPUT A5-A9
//   - wrote_*: set by the game's write to that clock register, cleared
//     by any write to $6000-$7FFF; a seconds write also clears wrote_dh.
//     They cross to the PicoBlaze clock as command bits (pb_periph)
//   - lat_*: the latched clock the game reads (gb_data_out), copied from
//     the PicoBlaze's OUTPUT A5-A9 values when the game writes $01 to
//     $6000-$7FFF while that register holds $00
//   - r6000: the game's last $6000-$7FFF write, for the latch
//   - ram_en: the game's RAM enable ($0A to $0000-$1FFF), which gates
//     only the clock registers here
//
// Every register loads only for an MBC3 game (mbc_type 3, not kernel
// mode); the kernel's writes come through its register window. The block
// never reads mbc_type bit 2: gb_regs's type0_n2 and type1_n2 carry it
// (each is a type bit with !bit 2), and the hardware builds the MBC3 test
// from them two ways, as below.
//
// Block: stage0/fw5-0918/mbc3_clock.blk (FW5 only).

module mbc3_clock (
    input clk_wr_a,
    input a0, a1, a2, a4, a12, a13, a14, a15,
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input kernel_mode,
    input [3:0] mbc_type,           // bits 0, 1 and 3; bit 2 only through the decodes
    input [7:0] rtc_sel,            // the MBC3 RAM bank / clock register select (gb_regs)
    input bank_lo_ones, bank_hi_ones,   // the game bank register is all ones (psram_ctrl)
    input win_a000,                 // the $A000 window decode (sd_mem_path)
    input rtc_set_wr,               // the kernel's register window write (gb_regs)
    // gb_regs's and unlock's shared decodes, stated in the assumptions below
    input n_r6000, r2000, game_n3,
    input type0_n2, type1_n2,       // mbc_type[0] & !mbc_type[2], mbc_type[1] & !mbc_type[2]
    input rtc_sel_d,                // d[7:4] == 0 and mbc_type[2:0] == 3
    input a10_any, a0_n1, a210_4, d_0a,
    // the PicoBlaze's OUTPUT A5-A9
    input [7:0] mbc3_rd_s, mbc3_rd_m, mbc3_rd_h, mbc3_rd_dl, mbc3_rd_dh,
    output reg [7:0] mbc3_wr_s, mbc3_wr_m, mbc3_wr_h, mbc3_wr_dl, mbc3_wr_dh,
    output reg wrote_s, wrote_m, wrote_h, wrote_dl, wrote_dh,
    output reg [7:0] lat_sec, lat_min, lat_hour, lat_dl, lat_dh
);
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};
    wire [2:0] a = {a2, a1, a0};
    reg [7:0] r6000;
    reg ram_en;

    // an MBC3 game (game_n3: not kernel mode, mbc_type[3] clear), as the
    // registers' enables test it and as the clock register decode does
    wire mbc3 = game_n3 & type0_n2 & mbc_type[1];
    wire mbc3_rd = game_n3 & type1_n2 & mbc_type[0];
    wire wr_0000 = !a15 & !a14 & !a13;
    wire wr_6000 = !a15 & a14 & a13;
    wire bank_ones = bank_lo_ones & bank_hi_ones;
    // the game's clock register write, and which register
    wire clk_win = a15 & win_a000 & ram_en & bank_ones & rtc_sel[7:3] == 5'b00001;
    wire clk_wr = mbc3_rd & clk_win;
    wire [4:0] sel = {rtc_sel[2:0] == 3'd4, rtc_sel[2:0] == 3'd3, rtc_sel[2:0] == 3'd2,
                      rtc_sel[2:0] == 3'd1, rtc_sel[2:0] == 3'd0};
    // the kernel's, at $A010-$A014
    wire k_wr = rtc_set_wr & a4;
    wire [4:0] k_sel = {a == 3'd4, a == 3'd3, a == 3'd2, a == 3'd1, a == 3'd0};
    wire [7:0] kd = kernel_mode ? 8'hff : 8'h00;  // the bits only the kernel writes
    // the latch: $01 written to $6000-$7FFF over $00
    wire latch = game_n3 & rtc_sel_d & wr_6000 & r6000 == 8'h00 & d[3:0] == 4'h1;
    // wrote_dh holds through everything but a $6000-$7FFF write and a
    // seconds or DH write ($08/$0C), which the OR below sets again for DH
    wire dh_clr = !a15 ? a14 & a13
                       : a13 & !a14 & ram_en & bank_ones & rtc_sel[7:3] == 5'b00001 & !rtc_sel[1] & !rtc_sel[0];

    initial begin
        {mbc3_wr_s, mbc3_wr_m, mbc3_wr_h, mbc3_wr_dl, mbc3_wr_dh} = 40'd0;
        {wrote_s, wrote_m, wrote_h, wrote_dl, wrote_dh} = 5'd0;
        {lat_sec, lat_min, lat_hour, lat_dl, lat_dh} = 40'd0;
        r6000 = 8'd0; ram_en = 1'b0;
    end
    always @(posedge clk_wr_a) begin
        if (clk_wr & sel[0] | k_wr & k_sel[0]) mbc3_wr_s <= d & {kd[7:6], 6'h3f};
        if (clk_wr & sel[1] | k_wr & k_sel[1]) mbc3_wr_m <= d & {kd[7:6], 6'h3f};
        if (clk_wr & sel[2] | k_wr & k_sel[2]) mbc3_wr_h <= d & {kd[7:5], 5'h1f};
        if (clk_wr & sel[3] | k_wr & k_sel[3]) mbc3_wr_dl <= d;
        if (clk_wr & sel[4] | k_wr & k_sel[4]) mbc3_wr_dh <= d & {2'b11, kd[5:1], 1'b1};
        if (mbc3) begin
            wrote_s <= clk_win & sel[0] | wrote_s & !wr_6000;
            wrote_m <= clk_win & sel[1] | wrote_m & !wr_6000;
            wrote_h <= clk_win & sel[2] | wrote_h & !wr_6000;
            wrote_dl <= clk_win & sel[3] | wrote_dl & !wr_6000;
            wrote_dh <= clk_win & sel[4] | wrote_dh & !dh_clr;
        end
        if (mbc3 & wr_6000) r6000 <= d;
        if (mbc3 & wr_0000) ram_en <= d_0a;
        if (latch) {lat_sec, lat_min, lat_hour, lat_dl, lat_dh} <= {mbc3_rd_s, mbc3_rd_m, mbc3_rd_h, mbc3_rd_dl, mbc3_rd_dh};
    end

`ifdef FORMAL
    // gb_regs's and unlock's decodes, which the block reads as nets
    always @* begin
        env_r6000: assume (n_r6000 == !wr_6000);
        env_r2000: assume (r2000 == (!a15 & !a14 & a13));
        env_game: assume (game_n3 == (!kernel_mode & !mbc_type[3]));
        env_a10: assume (a10_any == (a1 | a0));
        env_a0n1: assume (a0_n1 == (a0 & !a1));
        env_a4: assume (a210_4 == (a == 3'd4));
        env_d0a: assume (d_0a == (d[3:0] == 4'ha));
        env_kwr: assume (!rtc_set_wr | a15);
    end
`endif
endmodule
