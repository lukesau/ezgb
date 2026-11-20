// FW6's MBC3 clock registers on /WR. FW5's block of this name also held
// the write flags, the $6000 latch and the latched copies the game read;
// FW6 keeps the clock in the FPGA (mbc3_rtc), and what is left here is:
//
//   - mbc3_wr_*: what an MBC3 game writes to clock registers $08-$0C
//     (seconds, minutes, hours, DL, DH) through $A000-$BFFF, with RAM
//     enabled, the bank register all ones and rtc_sel $08-$0C, as in
//     FW5. Bits the MBC3 doesn't have read back as 0. The kernel writes
//     all eight bits at $A010-$A014 in its register window. The
//     PicoBlaze still reads them at INPUT A5-A9
//   - tog_*: flipped by the game's write to that clock register. FW5 set
//     a flag here and cleared it on a $6000-$7FFF write; a toggle needs
//     no clearing, and mbc3_rtc sees every write as one change. The
//     kernel's writes don't flip them, so they never reach the clock.
//     pb_periph still crosses the five bits to the PicoBlaze as command
//     bits, where FW5 crossed the flags
//   - ram_en: the game's RAM enable ($0A to $0000-$1FFF), which gates
//     only the clock registers here
//
// The decodes FW5's block took from gb_regs and unlock are worked out
// here from the pins and registers: FW6 packs them into other LUTs, and
// no net carries them between the blocks.
//
// Proven in the whole-design proof (stage0/tools/fw6-prove.sh).

module mbc3_clock (
    input clk_wr_a,
    input gb_reset_n_q,             // the debounced /RESET register (reset_edge)
    input rst_prev,                 // and its last value: the falling edge clears ram_en
    input a0, a1, a2, a3, a4, a5, a6, a7, a12, a13, a14, a15,
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input kernel_mode,
    input [3:0] mbc_type,
    input [7:0] rtc_sel,            // the MBC3 RAM bank / clock register select (gb_regs)
    input [8:0] mbc_bank,           // the game bank register (gb_regs)
    input [3:1] win_mode,
    output reg [7:0] mbc3_wr_s, mbc3_wr_m, mbc3_wr_h, mbc3_wr_dl, mbc3_wr_dh,
    output reg tog_s, tog_m, tog_h, tog_dl, tog_dh
);
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};
    wire [2:0] a = {a2, a1, a0};
    reg ram_en;

    wire rst_edge = rst_prev & !gb_reset_n_q;
    // an MBC3 game: not kernel mode, mbc_type 3
    wire mbc3 = !kernel_mode & !rst_edge & mbc_type == 4'd3;
    wire wr_0000 = !a15 & !a14 & !a13;
    wire a000 = a15 & a13 & !a14;
    // the game's clock register write, and which register
    wire clk_win = a000 & ram_en & mbc_bank[7:0] == 8'hff & rtc_sel[7:3] == 5'b00001;
    wire clk_wr = mbc3 & clk_win;
    wire [4:0] sel = {rtc_sel[2:0] == 3'd4, rtc_sel[2:0] == 3'd3, rtc_sel[2:0] == 3'd2,
                      rtc_sel[2:0] == 3'd1, rtc_sel[2:0] == 3'd0};
    // the kernel's, at $A010-$A014 of its register window
    wire reg_dec = a000 & (win_mode[3] | win_mode[1] & win_mode[2]);
    wire k_wr = kernel_mode & reg_dec & !rst_edge & !a7 & !a6 & !a5 & a4 & a3;
    wire [4:0] k_sel = {a == 3'd4, a == 3'd3, a == 3'd2, a == 3'd1, a == 3'd0};
    wire [7:0] kd = kernel_mode ? 8'hff : 8'h00;  // the bits only the kernel writes

    initial begin
        {mbc3_wr_s, mbc3_wr_m, mbc3_wr_h, mbc3_wr_dl, mbc3_wr_dh} = 40'd0;
        {tog_s, tog_m, tog_h, tog_dl, tog_dh} = 5'd0;
        ram_en = 1'b0;
    end
    always @(posedge clk_wr_a) begin
        if (clk_wr & sel[0] | k_wr & k_sel[0]) mbc3_wr_s <= d & {kd[7:6], 6'h3f};
        if (clk_wr & sel[1] | k_wr & k_sel[1]) mbc3_wr_m <= d & {kd[7:6], 6'h3f};
        if (clk_wr & sel[2] | k_wr & k_sel[2]) mbc3_wr_h <= d & {kd[7:5], 5'h1f};
        if (clk_wr & sel[3] | k_wr & k_sel[3]) mbc3_wr_dl <= d;
        if (clk_wr & sel[4] | k_wr & k_sel[4]) mbc3_wr_dh <= d & {2'b11, kd[5:1], 1'b1};
        if (clk_wr & sel[0]) tog_s <= !tog_s;
        if (clk_wr & sel[1]) tog_m <= !tog_m;
        if (clk_wr & sel[2]) tog_h <= !tog_h;
        if (clk_wr & sel[3]) tog_dl <= !tog_dl;
        if (clk_wr & sel[4]) tog_dh <= !tog_dh;
    end
    always @(posedge clk_wr_a or posedge rst_edge)
        if (rst_edge) ram_en <= 1'b0;
        else if (mbc3 & wr_0000) ram_en <= d[3:0] == 4'ha;
endmodule
