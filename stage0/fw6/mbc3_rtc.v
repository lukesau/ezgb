// FW6's MBC3 clock, which FW4 and FW5 don't have: the FPGA keeps the
// time itself. FW5 leaves the clock to the PicoBlaze, which copies the
// game's writes to the RTC chip and the chip's time back. Here the clock
// registers are counters on the falling edge of the PicoBlaze clock
// (CLK2X, 49.0909 MHz):
//
//   - sub counts PicoBlaze clock cycles. When it reaches 49,090,908 the
//     second ticks and it clears, so a second is 49,090,909 cycles. A
//     write to the seconds register clears it too, and it stops while
//     halt is set
//   - sec and min are six bits each and wrap at 59 into the next
//     register. A value past 59, which only a write can leave, counts
//     on to 63 and wraps to 0 without a carry, as the MBC3 does
//   - hour is five bits and wraps at 23 (past it, at 31 without a carry)
//   - day is nine bits; passing 511 sets day_carry
//   - halt and day_carry are DH bits 6 and 7. A DH write sets them, and
//     the day counter sets day_carry
//
// A game's write to a clock register lands in mbc3_clock's mbc3_wr_*
// register and flips that register's toggle (tog_*), on /WR. Each toggle
// crosses to this clock through two flip-flops. A difference between the
// two is the write, and loads the register here from mbc3_wr_*. A write
// wins over the count in the same cycle. A DH write loads day[8], halt
// and day_carry and holds day[7:0], even when a DL write arrives in the
// same cycle. A DL write loads day[7:0] and day[8] too, from the DH
// value last written (the build of 2026-11-24 left day[8] alone on a DL
// write).
//
// The kernel's write to $A018-$A01C loads them the same way, and the
// $6000 latch copies them (mbc3_clock). The PicoBlaze and the RTC chip
// are not connected to this clock, so it starts at zero when the FPGA is
// configured.
//
// Block: stage0/fw6/mbc3_rtc.blk (FW6 only), proven with equiv.sh; the
// whole-design proof (stage0/tools/fw6-prove.sh) covers it too.

module mbc3_rtc (
    input clk_pb,
    input tog_s, tog_m, tog_h, tog_dl, tog_dh,     // mbc3_clock's write toggles
    input [5:0] mbc3_wr_s, mbc3_wr_m,
    input [4:0] mbc3_wr_h,
    input [7:0] mbc3_wr_dl, mbc3_wr_dh,
    output reg [5:0] sec, min,
    output reg [4:0] hour,
    output reg [8:0] day,
    output reg halt, day_carry,
    output gnd                                     // the constant 0 the build shares between blocks
);
    assign gnd = 1'b0;
    localparam [25:0] SECOND = 26'd49090908;

    reg tog_s_s1, tog_s_s2, tog_m_s1, tog_m_s2, tog_h_s1, tog_h_s2;
    reg tog_dl_s1, tog_dl_s2, tog_dh_s1, tog_dh_s2;
    reg [25:0] sub;

    wire wr_s = tog_s_s1 ^ tog_s_s2;
    wire wr_m = tog_m_s1 ^ tog_m_s2;
    wire wr_h = tog_h_s1 ^ tog_h_s2;
    wire wr_dl = tog_dl_s1 ^ tog_dl_s2;
    wire wr_dh = tog_dh_s1 ^ tog_dh_s2;

    wire sec_tick = !halt & sub >= SECOND;
    wire min_tick = sec_tick & sec == 6'd59;
    wire hour_tick = min_tick & min == 6'd59;
    wire day_tick = hour_tick & hour == 5'd23;

    initial begin
        {tog_s_s1, tog_s_s2, tog_m_s1, tog_m_s2, tog_h_s1, tog_h_s2} = 6'd0;
        {tog_dl_s1, tog_dl_s2, tog_dh_s1, tog_dh_s2} = 4'd0;
        sub = 26'd0; sec = 6'd0; min = 6'd0; hour = 5'd0; day = 9'd0;
        halt = 1'b0; day_carry = 1'b0;
    end
    always @(negedge clk_pb) begin
        {tog_s_s2, tog_s_s1} <= {tog_s_s1, tog_s};
        {tog_m_s2, tog_m_s1} <= {tog_m_s1, tog_m};
        {tog_h_s2, tog_h_s1} <= {tog_h_s1, tog_h};
        {tog_dl_s2, tog_dl_s1} <= {tog_dl_s1, tog_dl};
        {tog_dh_s2, tog_dh_s1} <= {tog_dh_s1, tog_dh};

        if (wr_s | sec_tick) sub <= 26'd0;
        else if (!halt) sub <= sub + 26'd1;

        if (wr_s) sec <= mbc3_wr_s;
        else if (sec_tick) sec <= min_tick ? 6'd0 : sec + 6'd1;

        if (wr_m) min <= mbc3_wr_m;
        else if (min_tick) min <= hour_tick ? 6'd0 : min + 6'd1;

        if (wr_h) hour <= mbc3_wr_h;
        else if (hour_tick) hour <= day_tick ? 5'd0 : hour + 5'd1;

        if (wr_dh) day[8] <= mbc3_wr_dh[0];
        else if (wr_dl) day <= {mbc3_wr_dh[0], mbc3_wr_dl};
        else if (day_tick) day <= day + 9'd1;

        if (wr_dh) halt <= mbc3_wr_dh[6];
        if (wr_dh) day_carry <= mbc3_wr_dh[7];
        else if (day_tick & day == 9'd511) day_carry <= 1'b1;
    end
endmodule
