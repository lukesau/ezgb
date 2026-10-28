// The two data FIFOs between the SD data host and the Game Boy side, on
// their SD-clock side: Rudolf Usselmann's generic_fifo_dc_gray (the
// dual-clock FIFO with gray-code pointers from the OpenCores generic_fifos),
// as Marek Czerski's sd_fifo_filler instantiates it twice in the OpenCores
// WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// and as EZ Flash built it. The rx FIFO is written by the data host (we)
// and read by the Game Boy side; the tx FIFO is written by the Game Boy
// side and read by the data host (rd). Each side keeps a binary pointer
// for its memory port and a gray copy for the other side, synchronizes
// the other side's gray pointer, and derives its own flag from the two.
//
// Derived from that source, which is Copyright (C) 2000-2002 Rudolf
// Usselmann (www.asics.ws) and licensed under its BSD-style notice; the
// filler is Copyright (C) 2013 Marek Czerski, under the GNU Lesser General
// Public License version 2.1 or later. This file keeps both notices and is
// under the LGPL.
//
// Written from the OpenCores source, with what the synthesis left of it:
//
//   - aw is 4 (sd_fifo_filler's FIFO_MEM_ADR_SIZE): 16 words of 32 bits
//     per FIFO, the memories being the block RAMs X3Y1 (rx) and X3Y9 (tx),
//     addressed by the low four pointer bits; they are not in this block
//   - the gray pointer's top bit equals the binary pointer's, and the
//     synthesis kept one register for both: rx_wp_gray and tx_rp_gray
//     are four bits here, with rx_wp_bin[4] / tx_rp_bin[4] on top
//   - rst is !(soft_rst | reset_fifo) with reset_fifo = neither FIFO
//     started, as in the filler; the two reset synchronizers per FIFO
//     (rd_rst/rd_rst_r, wr_rst/wr_rst_r) clock from the same input in
//     this domain and the synthesis merged them into one pair, rst/rst_r
//   - clr is tied to 0, and the clear synchronizer (rd_clr/rd_clr_r,
//     merged likewise) survives as a two-cycle clear after configuration:
//     the registers keep the 1 the asynchronous clear would give them
//     as their initial value, then clock in the constant 0, clr one cycle
//     after clr_r
//   - the level outputs (wr_level, rd_level) are unconnected in the filler
//     and gone, with the registers behind them
//   - full and empty have no reset in the source; empty starts at 1 in
//     the hardware (its initial value), full at 0
//
// Block: stage0/blocks/sd_fifos.blk.

module sd_fifos (
    input clk_sd,
    input soft_rst,
    input start_tx_fifo_i,          // the data master's start_tx_fifo_o: en_tx_i in the filler
    input start_rx_fifo_i,          // and start_rx_fifo_o: en_rx_i
    input we,                       // the data host writes a received word into the rx FIFO
    input rd,                       // the data host takes the next word to send from the tx FIFO
    input [4:0] rx_rp_gray_m,       // the rx FIFO's read pointer, gray, from the Game Boy clock domain
    input [4:0] tx_wp_gray_m,       // the tx FIFO's write pointer, likewise
    output reg [4:0] rx_wp_bin,     // [3:0] addresses the rx memory's write port
    output reg [3:0] rx_wp_gray,    // the gray write pointer for the other side, under rx_wp_bin[4]
    output reg rx_full,             // the data master's rx_fifo_full_i
    output reg [4:0] tx_rp_bin,     // [3:0] addresses the tx memory's read port
    output reg [3:0] tx_rp_gray,    // the gray read pointer for the other side, under tx_rp_bin[4]
    output reg tx_empty,            // the data master's tx_fifo_empty_i
    output fifo_rst,                // the FIFOs' reset (the source's rst, active low there): also the Game Boy side's
    output gnd                      // the constant clr, which the memories' parity inputs share
);
    assign gnd = 1'b0;
    wire clr_i = gnd;
    wire reset_fifo = !start_rx_fifo_i & !start_tx_fifo_i;
    assign fifo_rst = soft_rst | reset_fifo;

    // ---- reset and clear synchronizers (one pair each for the two FIFOs)
    reg rst, rst_r;
    reg clr = 1'b1, clr_r = 1'b1;
    always @(posedge clk_sd or posedge fifo_rst)
        if (fifo_rst) rst_r <= 1'b0;
        else rst_r <= 1'b1;
    always @(posedge clk_sd or posedge fifo_rst)
        if (fifo_rst) rst <= 1'b0;
        else if (rst_r) rst <= 1'b1;              // release reset
    always @(posedge clk_sd or posedge clr_i)
        if (clr_i) clr_r <= 1'b1;
        else clr_r <= 1'b0;
    always @(posedge clk_sd or posedge clr_i)
        if (clr_i) clr <= 1'b1;
        else if (!clr_r) clr <= 1'b0;             // release clear

    function [4:0] gray2bin(input [4:0] g);
        integer i;
        begin
            gray2bin[4] = g[4];
            for (i = 3; i >= 0; i = i - 1) gray2bin[i] = g[i] ^ gray2bin[i + 1];
        end
    endfunction

    // ---- rx FIFO, write side (generic_fifo_dc_gray0: wr_clk = sd_clk)
    reg [4:0] rx_rp_s;                                     // the other side's gray read pointer, synchronized
    wire [4:0] rx_wp_bin_next = rx_wp_bin + 5'd1;
    wire [4:0] rx_wp_gray_next = rx_wp_bin_next ^ {1'b0, rx_wp_bin_next[4:1]};
    wire [4:0] rx_rp_bin_x = gray2bin(rx_rp_s);
    always @(posedge clk_sd)
        if (!rst | clr) rx_wp_bin <= 5'd0;
        else if (we) rx_wp_bin <= rx_wp_bin_next;
    always @(posedge clk_sd)
        if (!rst | clr) rx_wp_gray <= 4'd0;
        else if (we) rx_wp_gray <= rx_wp_gray_next[3:0];
    always @(posedge clk_sd) rx_rp_s <= rx_rp_gray_m;
    always @(posedge clk_sd)
        rx_full <= ((rx_wp_bin[3:0] == rx_rp_bin_x[3:0]) & (rx_wp_bin[4] != rx_rp_bin_x[4]))
                 | (we & (rx_wp_bin_next[3:0] == rx_rp_bin_x[3:0]) & (rx_wp_bin_next[4] != rx_rp_bin_x[4]));

    // ---- tx FIFO, read side (generic_fifo_dc_gray1: rd_clk = sd_clk)
    reg [4:0] tx_wp_s;                                     // the other side's gray write pointer, synchronized
    wire [4:0] tx_rp_bin_next = tx_rp_bin + 5'd1;
    wire [4:0] tx_rp_gray_next = tx_rp_bin_next ^ {1'b0, tx_rp_bin_next[4:1]};
    wire [4:0] tx_rp_gray_full = {tx_rp_bin[4], tx_rp_gray};
    initial tx_empty = 1'b1;
    always @(posedge clk_sd)
        if (!rst | clr) tx_rp_bin <= 5'd0;
        else if (rd) tx_rp_bin <= tx_rp_bin_next;
    always @(posedge clk_sd)
        if (!rst | clr) tx_rp_gray <= 4'd0;
        else if (rd) tx_rp_gray <= tx_rp_gray_next[3:0];
    always @(posedge clk_sd) tx_wp_s <= tx_wp_gray_m;
    always @(posedge clk_sd)
        tx_empty <= (tx_wp_s == tx_rp_gray_full) | (rd & (tx_wp_s == tx_rp_gray_next));
endmodule
