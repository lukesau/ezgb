// FW6's MBC3 clock registers on /WR. The clock itself is in the FPGA
// (mbc3_rtc); what is here is:
//
//   - mbc3_wr_*: the value to load into the clock. An MBC3 game writes it
//     to clock registers $08-$0C (seconds, minutes, hours, DL, DH)
//     through $A000-$BFFF, with RAM enabled, the bank register all ones
//     and rtc_sel $08-$0C; the kernel writes it at $A018-$A01C of its
//     register window. Only the bits the MBC3 has are kept
//   - tog_*: flipped by either write to that clock register. mbc3_rtc
//     sees every flip as one load, so the kernel's write sets the game's
//     clock. pb_periph still crosses the five bits to the PicoBlaze as
//     command bits, where FW5 crossed its write flags
//   - the latch: latch_reg is the last byte a game wrote to $6000-$7FFF.
//     $01 written over $00 copies the clock into cap_* and sets latched,
//     and from then on the game reads the copy (gb_data_out). /RESET
//     clears latched
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
    input [5:0] sec, min,           // the clock (mbc3_rtc)
    input [4:0] hour,
    input [8:0] day,
    input halt, day_carry,
    output [7:0] mbc3_wr_s, mbc3_wr_m, mbc3_wr_h, mbc3_wr_dl, mbc3_wr_dh,
    output reg tog_s, tog_m, tog_h, tog_dl, tog_dh,
    output reg latched,
    output reg [5:0] cap_sec, cap_min,
    output reg [4:0] cap_hour,
    output reg [8:0] cap_day,
    output reg cap_halt, cap_carry
);
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};
    wire [2:0] a = {a2, a1, a0};
    reg ram_en;
    reg [7:0] latch_reg;
    // the value to load: only the bits the MBC3 has are registers
    reg [5:0] wr_s, wr_m;
    reg [4:0] wr_h;
    reg [7:0] wr_dl;
    reg wr_d8, wr_halt, wr_carry;
    assign mbc3_wr_s = {2'b00, wr_s};
    assign mbc3_wr_m = {2'b00, wr_m};
    assign mbc3_wr_h = {3'b000, wr_h};
    assign mbc3_wr_dl = wr_dl;
    assign mbc3_wr_dh = {wr_carry, wr_halt, 5'b00000, wr_d8};

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
    // the kernel's, at $A018-$A01C of its register window
    wire reg_dec = a000 & (win_mode[3] | win_mode[1] & win_mode[2]);
    wire k_wr = kernel_mode & reg_dec & !rst_edge & !a7 & !a6 & !a5 & a4 & a3;
    wire [4:0] k_sel = {a == 3'd4, a == 3'd3, a == 3'd2, a == 3'd1, a == 3'd0};
    wire [4:0] ld = {5{clk_wr}} & sel | {5{k_wr}} & k_sel;
    // the latch
    wire wr_6000 = mbc3 & !a15 & a14 & a13;
    wire latch = wr_6000 & latch_reg == 8'h00 & d == 8'h01;

    initial begin
        {wr_s, wr_m, wr_h, wr_dl, wr_d8, wr_halt, wr_carry} = 28'd0;
        {tog_s, tog_m, tog_h, tog_dl, tog_dh} = 5'd0;
        ram_en = 1'b0; latch_reg = 8'h00; latched = 1'b0;
        {cap_sec, cap_min, cap_hour, cap_day, cap_halt, cap_carry} = 28'd0;
    end
    always @(posedge clk_wr_a) begin
        if (ld[0]) begin wr_s <= d[5:0]; tog_s <= !tog_s; end
        if (ld[1]) begin wr_m <= d[5:0]; tog_m <= !tog_m; end
        if (ld[2]) begin wr_h <= d[4:0]; tog_h <= !tog_h; end
        if (ld[3]) begin wr_dl <= d; tog_dl <= !tog_dl; end
        if (ld[4]) begin {wr_carry, wr_halt, wr_d8} <= {d[7:6], d[0]}; tog_dh <= !tog_dh; end
        if (wr_6000) latch_reg <= d;
        if (latch) {cap_sec, cap_min, cap_hour, cap_day, cap_halt, cap_carry} <= {sec, min, hour, day, halt, day_carry};
    end
    always @(posedge clk_wr_a or posedge rst_edge)
        if (rst_edge) ram_en <= 1'b0;
        else if (mbc3 & wr_0000) ram_en <= d[3:0] == 4'ha;
    always @(posedge clk_wr_a or posedge rst_edge)
        if (rst_edge) latched <= 1'b0;
        else if (latch) latched <= 1'b1;
endmodule
