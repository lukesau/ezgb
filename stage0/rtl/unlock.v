// The $7Fxx register file's unlock, as the kernel and stage1 drive it:
//
//     ld [$7F00], $E1 ; ld [$7F10], $E2 ; ld [$7F20], $E3     unlock
//     ld [$7FF0], $E4                                         lock
//
// Only the low address byte is decoded (the write clock is /WR qualified by
// A15 low, so any $0000-$7FFF address with that low byte does). Two
// flip-flops, both clocked by the write and cleared by the console's reset:
//
//   key_e1    set by the $E1 write at $xx00; kept by the $E2 at $xx10
//   unlocked  set by that $E2 write, and kept only while every write after
//             it is to a register address ($xx30-$xx37 but $33, $xxB0-$xxB4,
//             $xxC0-$xxC4, $xxD0, $xxD2, $xxE0, $xxF0) or is the third key,
//             $E3 at $xx20. $E4 at $xxF0 locks; any other write, a ROM bank
//             switch at $2000 included, locks too.
//
// So the full sequence is E1, E2, E3: the E2 unlocks, and the E3 is what the
// third write has to be to stay unlocked.
//
// Bels: X18Y31_S3.FFX (key_e1), X18Y31_S0.FFX (unlocked), and the decode
// LUTs around them (stage0/blocks/unlock.blk). Two decode terms come in
// from shared LUTs (a1a0_zero, rst) and two go out to other logic
// (a542_zero, d_key_pattern).

module unlock (
    input a0, a1, a2, a3, a4, a5, a6, a7,
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input a1a0_zero,            // !a1 & !a0, decoded elsewhere
    input clk_wr_b,             // /WR, A15 low
    input rst,                  // console reset, registered
    output reg key_e1,
    output reg unlocked,
    output a542_zero,           // !a5 & !a4 & !a2
    output d_key_pattern        // d[7:3] == 11100
);
    wire [7:0] a = {a7, a6, a5, a4, a3, a2, a1, a0};
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};

    assign d_key_pattern = d[7:3] == 5'b11100;
    assign a542_zero = !a5 & !a4 & !a2;

    // the keys: $E1 at $xx00, $E2 at $xx10, $E3 at $xx20
    wire key_addr = !a7 & !a6 & !a3 & !a2 & a1a0_zero;     // $xx00 $xx10 $xx20 $xx30
    wire key_data = d_key_pattern & !d2;                    // $E0..$E3
    wire key1 = key_addr & key_data & !a5 & !a4 & !d1 &  d0;
    wire key2 = key_addr & key_data & !a5 &  a4 &  d1 & !d0;
    wire key3 = key_addr & key_data &  a5 & !a4 &  d1 &  d0;

    // writes that leave the registers unlocked
    wire reg_write =
           (a[7:3] == 5'b00110 && a[2:0] != 3'b011)   // $30-$32, $34-$37
        || (a[7:3] == 5'b10110 && a[2:0] <= 3'd4)      // $B0-$B4
        || (a[7:3] == 5'b11000 && a[2:0] <= 3'd4)      // $C0-$C4
        || a == 8'hD0 || a == 8'hD2 || a == 8'hE0
        || (a == 8'hF0 && d != 8'hE4);                 // $F0: $E4 locks

    always @(posedge clk_wr_b or posedge rst)
        if (rst) begin
            key_e1 <= 1'b0;
            unlocked <= 1'b0;
        end else begin
            key_e1 <= !unlocked & (key_e1 ? key2 : key1);
            unlocked <= key_e1 ? (unlocked ? key3 : key2)
                               : (unlocked & reg_write);
        end
endmodule
