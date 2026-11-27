// FW6: the module below with a divider of five bits (FW4 and FW5 eight).
// Bits 7:5 of what the PicoBlaze writes to the divider register are not
// kept, so its $3F for card identification divides as $1F. gnd_i is gone
// with the wider counter's carry-in. Proven in the whole-design proof
// (stage0/tools/fw6-prove.sh).
//
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
// FW5-0918: the same, plus the source's asynchronous reset, which FW5
// wires to the console /RESET edge (reset_edge.v): every register clears.
//
// Block: stage0/fw4/blocks/sd_clock_divider.blk, carried to FW5.

module sd_clock_divider (
    input clk_mode,
    input [4:0] divider_reg,        // the register file's divider, in another clock domain
    input rst_edge,                 // the console /RESET edge (reset_edge)
    output sd_clk
);
    reg [4:0] divider_s1, divider_s2, clock_div;
    reg sd_clk_r;
    assign sd_clk = sd_clk_r;
    initial begin divider_s1 = 5'd0; divider_s2 = 5'd0; clock_div = 5'd0; sd_clk_r = 1'b0; end
    always @(posedge clk_mode or posedge rst_edge)
        if (rst_edge) begin
            divider_s1 <= 5'd0;
            divider_s2 <= 5'd0;
        end else begin
            divider_s1 <= divider_reg;
            divider_s2 <= divider_s1;
        end
    always @(posedge clk_mode or posedge rst_edge)
        if (rst_edge) begin
            clock_div <= 5'd0;
            sd_clk_r <= 1'b0;
        end else if (clock_div == divider_s2) begin
            clock_div <= 5'd0;
            sd_clk_r <= ~sd_clk_r;
        end else
            clock_div <= clock_div + 5'd1;
endmodule
