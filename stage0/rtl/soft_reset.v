// The soft reset, EZ Flash's own: how a $7FE0 write resets the console.
//
// The request flag the Game Boy sets ($7FE0 bit 7, gb_regs, cleared again
// by the lock write) goes through a two-stage synchronizer on the 2x
// clock, and its rising edge asynchronously clears a 16-bit counter and
// the reset drive. The counter runs on the inverted 2x clock and counts
// up until it saturates at $FFFF, where it stops; the cycle after it
// gets there the drive is set again. So the drive is low for 65536
// falling edges of the 2x clock after the request. The controller ANDs
// the drive with the console's own /RESET onto P62 (psram_ctrl's
// gb_reset_drive), which is how the kernel restarts the console into a
// game it has loaded. The drive starts high.
//
// Block: stage0/blocks/soft_reset.blk.

module soft_reset (
    input clk_2x,
    input reset_req,                // $7FE0 bit 7 (gb_regs)
    output reg reset_drive          // low while the console is held in reset
);
    reg req_s1, req_s2;
    reg [15:0] cnt;
    initial begin req_s1 = 1'b0; req_s2 = 1'b0; cnt = 16'd0; reset_drive = 1'b1; end

    always @(posedge clk_2x) {req_s2, req_s1} <= {req_s1, reset_req};
    wire start = req_s1 & !req_s2;

    always @(negedge clk_2x or posedge start)
        if (start) begin
            cnt <= 16'd0;
            reset_drive <= 1'b0;
        end else begin
            if (cnt != 16'hffff) cnt <= cnt + 16'd1;
            else reset_drive <= 1'b1;
        end
endmodule
