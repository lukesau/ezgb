// FW5-0918's console /RESET edge, which FW4 doesn't have. gb_reset_n_q is
// the /RESET pad's input register, which reset_debounce samples once every
// 2^20 CLK0 cycles; rst_prev is that register one CLK0 cycle later, set
// while the DCM is unlocked. rst_edge, the cycle /RESET is seen low after
// being high, resets the SD controller (its Wishbone reset), joins the SD
// soft reset, and resets and holds off the /WR registers that FW5 clears
// on a console reset. Other blocks also read gb_reset_n_q and rst_prev
// themselves, in LUTs that fold the edge into their own terms.
//
// Block: stage0/fw5-0918/reset_edge.blk (FW5 only).

module reset_edge (
    input clk_0,
    input dcm_locked,
    input gb_reset_n_q,             // the debounced /RESET register
    output reg rst_prev,
    output rst_edge
);
    initial rst_prev = 1'b1;
    always @(posedge clk_0 or negedge dcm_locked)
        if (!dcm_locked) rst_prev <= 1'b1;
        else rst_prev <= gb_reset_n_q;
    assign rst_edge = rst_prev & !gb_reset_n_q;
endmodule
