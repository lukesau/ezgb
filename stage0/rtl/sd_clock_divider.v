// The SD clock divider: Marek Czerski's sd_clock_divider from the OpenCores
// WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// as EZ Flash built it, with the two sync stages that bring the divider
// register into its clock domain. It runs on the mode clock and toggles
// sd_clk every divider_reg + 1 cycles; sd_clk goes to the SD clock buffer
// and out on the SD CLK pad.
//
// Derived from that source, which is Copyright (C) 2013 Marek Czerski,
// based on original work Copyright (C) 2009 Adam Edvardsson, and licensed
// under the GNU Lesser General Public License version 2.1 or later; this
// file keeps that notice and is under the same license.
//
// What the synthesis left of it: the source's asynchronous RST is tied off
// (nothing here resets), and the counter's clear became the flip-flops'
// synchronous reset, driven by the comparator. The divider register's
// crossing is the source's two-stage one. The counter's carry-in is a
// constant-0 LUT that sd_cmd_serial's block owns, so it comes in as gnd_i.
//
// Block: stage0/blocks/sd_clock_divider.blk.

module sd_clock_divider (
    input clk_mode,
    input [7:0] divider_reg,        // the register file's divider, in another clock domain
    input gnd_i,                    // the counter's carry-in: a constant-0 LUT sd_cmd_serial owns
    output sd_clk
);
    reg [7:0] divider_s1, divider_s2, clock_div;
    reg sd_clk_r;
    assign sd_clk = sd_clk_r;
    always @(posedge clk_mode) begin
        divider_s1 <= divider_reg;
        divider_s2 <= divider_s1;
    end
    always @(posedge clk_mode)
        if (clock_div == divider_s2) begin
            clock_div <= 8'd0;
            sd_clk_r <= ~sd_clk_r;
        end else
            clock_div <= clock_div + 8'd1;

`ifdef FORMAL
    always @* begin
        env_gnd: assume (gnd_i == 1'b0);
    end
`endif
endmodule
