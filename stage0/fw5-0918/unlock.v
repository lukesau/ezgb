// FW5-0918's unlock of the $7Fxx registers, against FW4's (stage0/rtl/unlock.v)
// the same three keys and lock, a different state machine, read from the
// design and proved:
//
//     ld [$7F00], $E1 ; ld [$7F10], $E2 ; ld [$7F20], $E3     unlock
//     ld [$7FF0], $E4                                         lock
//
// Four one-hot registers on /WR, each enabled with A15 low (FW4: two, on a
// /WR | A15 clock): idle (set at power-up), key_e1, key_e2, unlocked. Only
// the low address byte is decoded.
//
//   idle      -> key_e1    the $E1 at $xx00
//   key_e1    -> key_e2    the $E2 at $xx10
//   key_e2    -> unlocked  the $E3 at $xx20
//   unlocked  stays while every write is to a register address ($xx30-$37
//             but $33, $xxB0-$B4, $xxC0-$C4, $xxD0, $xxD2-$D4, $xxE0,
//             $xxF0 but $E4 there)
//
// Any other write sends a key state, or unlocked, back to idle. So FW5
// unlocks on the $E3 (FW4 on the $E2, with the $E3 only keeping it), and
// its register list adds $7FD3 and $7FD4. There is no console reset here:
// FW5 resets these on the /RESET edge, which fw5-noedge.py takes out of the
// design this is proved against.
//
// Block: built by scripts/fpga/simblk.py from stage0/blocks/unlock.blk
// (stage0/fw5-0918/unlock.sim has its arguments), with the names in
// unlock.names.
module unlock (
    input a0, a1, a2, a3, a4, a5, a6, a7, a15,
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input a10_any, a210_any,    // a1 | a0, a2 | a1 | a0 (gb_regs)
    input d_e4,                 // d == $E4 (gb_regs)
    input clk_wr_a,             // /WR
    output reg unlocked,
    output d_key_pattern,       // d[7:3] == 11100
    output a0_n1                // a0 & !a1, shared outside
);
    wire [7:0] a = {a7, a6, a5, a4, a3, a2, a1, a0};
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};

    assign d_key_pattern = d[7:3] == 5'b11100;
    assign a0_n1 = a0 & !a1;

    // the keys: $E1 at $xx00, $E2 at $xx10, $E3 at $xx20
    wire key_addr = !a7 & !a6 & !a3 & !a2 & !a10_any;
    wire key_data = d_key_pattern & !d2;
    wire key1 = key_addr & key_data & !a5 & !a4 & !d1 &  d0;
    wire key2 = key_addr & key_data & !a5 &  a4 &  d1 & !d0;
    wire key3 = key_addr & key_data &  a5 & !a4 &  d1 &  d0;

    // writes that leave the registers unlocked
    wire reg_write = !a3 & (
           a[7:4] == 4'h3 && a[2:0] != 3'd3            // $30-$32, $34-$37
        || a[7:4] == 4'hb && a[2:0] <= 3'd4            // $B0-$B4
        || a[7:4] == 4'hc && a[2:0] <= 3'd4            // $C0-$C4
        || a[7:4] == 4'hd && (a[2:0] == 3'd0 || a[2:0] >= 3'd2 && a[2:0] <= 3'd4)   // $D0, $D2-$D4
        || a[7:4] == 4'he && !a210_any                 // $E0
        || a[7:4] == 4'hf && !a210_any && !d_e4);      // $F0: $E4 locks

    reg idle, key_e1, key_e2;
    initial begin idle = 1'b1; key_e1 = 1'b0; key_e2 = 1'b0; unlocked = 1'b0; end
    always @(posedge clk_wr_a)
        if (!a15) begin
            idle <= idle & !key1 | key_e1 & !key2 | key_e2 & !key3 | unlocked & !reg_write;
            key_e1 <= idle & key1;
            key_e2 <= key_e1 & key2;
            unlocked <= key_e2 & key3 | unlocked & reg_write;
        end

`ifdef FORMAL
    // The shared decodes arrive from gb_regs. Stated as input assumptions.
    always @* begin
        env_a10_any:    assume (a10_any == (a1 | a0));
        env_a210_any:   assume (a210_any == (a2 | a1 | a0));
        env_d_e4:       assume (d_e4 == (d_key_pattern & d2 & !d1 & !d0));
    end
`endif
endmodule
