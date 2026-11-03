// FW5-0918's /RESET debounce, which FW4 doesn't have. The console's
// /RESET is synchronized two stages deep on CLK0, and a 20-bit counter
// runs freely on CLK0, restarting the cycle after /RESET falls. When it
// is all ones, rst_sample enables the /RESET pad's input register
// (gb_reset_n_q, the reset everything else sees): the pad is sampled
// once every 2^20 CLK0 cycles, the first time 2^20 cycles after it fell,
// so a press shorter than that between samples goes unseen. Everything
// here is held (counter 0, /RESET high) while the DCM is unlocked.
//
// Block: stage0/fw5-0918/reset_debounce.blk (FW5 only).

module reset_debounce (
    input clk_0,
    input gb_reset_n,               // the /RESET pad
    input dcm_locked,
    output rst_sample
);
    reg rst_s1, rst_s2;
    reg [19:0] cnt;
    wire fell = rst_s2 & !rst_s1;

    initial begin rst_s1 = 1'b1; rst_s2 = 1'b1; cnt = 20'd0; end
    always @(posedge clk_0 or negedge dcm_locked)
        if (!dcm_locked) begin
            rst_s1 <= 1'b1; rst_s2 <= 1'b1; cnt <= 20'd0;
        end else begin
            {rst_s2, rst_s1} <= {rst_s1, gb_reset_n};
            cnt <= fell ? 20'd0 : cnt + 20'd1;
        end
    assign rst_sample = &cnt;
endmodule
