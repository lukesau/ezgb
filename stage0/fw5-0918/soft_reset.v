// FW5-0918's soft reset: the FW4 module (stage0/rtl/soft_reset.v) on the
// DCM's CLK0 instead of CLK2X. The synchronizer takes the rising edge and
// the counter the falling edge, as FW4's do on CLK2X, so the drive stays
// low for 65536 falling edges of CLK0, twice as long as on FW4.
// The counter's carry-in is the constant-0 LUT the rest of the design
// shares (FW4 builds one for the counter alone), so it leaves as gnd.
//
// Block: carried from stage0/blocks/soft_reset.blk by fw5-prove.sh, with
// the clock named in soft_reset.names.
module soft_reset (
    input clk_0,
    input reset_req,                // $7FE0 bit 7 (gb_regs)
    output reg reset_drive,         // low while the console is held in reset
    output gnd                      // a constant-0 LUT other blocks read
);
    assign gnd = 1'b0;
    reg req_s1, req_s2;
    reg [15:0] cnt;
    initial begin req_s1 = 1'b0; req_s2 = 1'b0; cnt = 16'd0; reset_drive = 1'b1; end
    always @(posedge clk_0) {req_s2, req_s1} <= {req_s1, reset_req};
    wire start = req_s1 & !req_s2;
    always @(negedge clk_0 or posedge start)
        if (start) begin
            cnt <= 16'd0;
            reset_drive <= 1'b0;
        end else begin
            if (cnt != 16'hffff) cnt <= cnt + 16'd1;
            else reset_drive <= 1'b1;
        end
endmodule
