// The two data FIFOs' other side and the master that empties and fills
// them: Marek Czerski's sd_fifo_filler from the OpenCores WISHBONE SD Card
// Controller (http://opencores.org/project,sd_card_controller), as EZ Flash
// built it, on the mode clock. Its Wishbone master reads the rx FIFO word
// by word into memory while a block is received, and fills the tx FIFO
// from memory while one is sent, stepping an address it loads from the
// register file's DMA address between transfers. The FIFO halves are
// Rudolf Usselmann's generic_fifo_dc_gray read and write sides, whose
// SD-clock halves are in stage0/rtl/sd_fifos.v.
//
// Derived from those sources: the filler is Copyright (C) 2013 Marek
// Czerski, under the GNU Lesser General Public License version 2.1 or
// later; the FIFO is Copyright (C) 2000-2002 Rudolf Usselmann
// (www.asics.ws), under its BSD-style notice. This file keeps both notices
// and is under the LGPL.
//
// Written from the OpenCores sources, with what the synthesis left of
// them and what EZ Flash added:
//
//   - the Wishbone slave is EZ Flash's: a 2 KB block RAM (X3Y5, 512 words)
//     written from the rx FIFO's read port and read into the tx FIFO's
//     write port, which the Game Boy bus reads and writes on its other
//     port, and the pSRAM path in the memory clock domain, which takes the
//     same address; the acknowledge is EZ Flash's too, a two-bit counter
//     that answers every strobe on its third cycle (ack_cnt here)
//   - the address is 21 bits, wbm_adr_o[22:2]: bits 1:0 are the constant
//     zeros the top level appends, and nothing reads the bits above 22
//   - rst is the software reset (wb_rst_i is tied off), the SD-clock copy
//     as in the top level; the FIFO halves take the FIFO reset the SD-side
//     block derives from it and their clr from a constant-0 LUT in the data
//     host block, so the clear synchronizer's asynchronous set became a
//     data input; another constant-0 LUT there is the address
//     incrementer's carry-in, and both are inputs here
//   - en_rx_i and en_tx_i are the data master's start_rx_fifo_o and
//     start_tx_fifo_o, read from the SD clock domain without a
//     synchronizer, as in the source
//   - as on the SD side, each gray pointer's top bit is its binary
//     pointer's: tx_wp_bin and rx_rp_bin are four bits here, under
//     tx_wp_gray_m[4] / rx_rp_gray_m[4] (the crossings block's names for
//     the gray pointers, which it carries to the SD side)
//   - the rx FIFO's empty flag (wb_empty_o) starts at 1; the tx FIFO's
//     full flag is the data master's tx_fifo_full_i
//
// Block: stage0/blocks/sd_fifo_filler.blk.

module sd_fifo_filler (
    input clk_mode,
    input soft_rst,                 // the software reset, SD-clock copy: the filler's rst
    input fifo_rst,                 // the FIFOs' reset from the SD side: soft_rst | neither FIFO started
    input clr_i,                    // the FIFOs' clr: a constant-0 LUT in the data host block
    input gnd1_i,                   // another constant-0 LUT there: the address incrementer's carry-in
    input start_rx_fifo_i,          // en_rx_i
    input start_tx_fifo_i,          // en_tx_i
    input [22:2] dma_addr_m,        // adr_i, from the register file
    input [4:0] tx_rp_gray_i,       // the tx FIFO's read pointer, gray, from the SD side ([4] is tx_rp_bin[4] there)
    input [4:0] rx_wp_gray_i,       // the rx FIFO's write pointer, likewise
    output reg [22:2] wbm_adr_o,    // the memory address: X3Y5's port A and the pSRAM path
    output wbm_we_o,                // the memory write enable, to a register in the system clock domain
    output wbm_we_x,                // the same LUT's output on the slice's X pin: X3Y5's port A write enable
    output reg [3:0] tx_wp_bin,     // addresses the tx memory's write port (X3Y9 port A)
    output reg [4:0] tx_wp_gray_m,  // the gray write pointer for the SD side
    output tx_we,                   // the tx memory's write enable
    output reg tx_fifo_full_i,      // the tx FIFO's full flag (wb_full_o)
    output reg [3:0] rx_rp_bin,     // addresses the rx memory's read port (X3Y1 port B)
    output reg [4:0] rx_rp_gray_m,  // the gray read pointer for the SD side
    output reg rx_empty             // the rx FIFO's empty flag (wb_empty_o)
);
    // ---- the master
    reg fifo_rd_reg, fifo_rd_ack;
    reg [1:0] ack_cnt;
    wire reset_fifo = !start_rx_fifo_i & !start_tx_fifo_i;
    wire wbm_cyc_o = start_rx_fifo_i ? !rx_empty : start_tx_fifo_i & !tx_fifo_full_i;
    assign wbm_we_o = start_rx_fifo_i & !rx_empty;
    assign wbm_we_x = wbm_we_o;
    wire wbm_stb_o = start_rx_fifo_i ? wbm_cyc_o & fifo_rd_ack : wbm_cyc_o;
    wire wbm_ack_i = wbm_stb_o & (ack_cnt == 2'd2);         // EZ Flash's slave: the third cycle of a strobe
    wire fifo_rd = wbm_cyc_o & wbm_ack_i;

    always @(posedge clk_mode)
        if (wbm_ack_i) ack_cnt <= 2'd0;
        else if (wbm_stb_o) ack_cnt <= ack_cnt + 2'd1;

    initial fifo_rd_ack = 1'b1;
    always @(posedge clk_mode or posedge soft_rst)
        if (soft_rst) begin
            wbm_adr_o <= 21'd0;
            fifo_rd_reg <= 1'b0;
            fifo_rd_ack <= 1'b1;
        end else begin
            fifo_rd_reg <= fifo_rd;
            fifo_rd_ack <= fifo_rd_reg | !fifo_rd;
            if (wbm_cyc_o & wbm_stb_o & wbm_ack_i)
                wbm_adr_o <= wbm_adr_o + 21'd1 + {20'd0, gnd1_i};   // + MEM_OFFSET, on the word address: the 1 is folded into the chain's first LUT, the constant 0 is its carry-in
            else if (reset_fifo)
                wbm_adr_o <= dma_addr_m;
        end

    // ---- the FIFOs' reset and clear synchronizers (one pair each for the two)
    reg rst, rst_r;
    reg clr = 1'b1, clr_r = 1'b1;
    always @(posedge clk_mode or posedge fifo_rst)
        if (fifo_rst) rst_r <= 1'b0;
        else rst_r <= 1'b1;
    always @(posedge clk_mode or posedge fifo_rst)
        if (fifo_rst) rst <= 1'b0;
        else if (rst_r) rst <= 1'b1;
    always @(posedge clk_mode) clr_r <= clr_i;
    always @(posedge clk_mode) if (!clr_r) clr <= clr_i;

    function [4:0] gray2bin(input [4:0] g);
        integer i;
        begin
            gray2bin[4] = g[4];
            for (i = 3; i >= 0; i = i - 1) gray2bin[i] = g[i] ^ gray2bin[i + 1];
        end
    endfunction

    // ---- rx FIFO, read side (generic_fifo_dc_gray0: rd_clk = wb_clk)
    reg [4:0] rx_wp_s;                                     // the SD side's gray write pointer, synchronized
    wire rx_re = start_rx_fifo_i & wbm_cyc_o & wbm_ack_i;
    wire [4:0] rx_rp_bin_next = {rx_rp_gray_m[4], rx_rp_bin} + 5'd1;
    wire [4:0] rx_rp_gray_next = rx_rp_bin_next ^ {1'b0, rx_rp_bin_next[4:1]};
    initial rx_empty = 1'b1;
    always @(posedge clk_mode)
        if (!rst | clr) begin rx_rp_bin <= 4'd0; rx_rp_gray_m <= 5'd0; end
        else if (rx_re) begin rx_rp_bin <= rx_rp_bin_next[3:0]; rx_rp_gray_m <= rx_rp_gray_next; end
    always @(posedge clk_mode) rx_wp_s <= rx_wp_gray_i;
    always @(posedge clk_mode)
        rx_empty <= (rx_wp_s == rx_rp_gray_m) | (rx_re & (rx_wp_s == rx_rp_gray_next));

    // ---- tx FIFO, write side (generic_fifo_dc_gray1: wr_clk = wb_clk)
    reg [4:0] tx_rp_s;                                     // the SD side's gray read pointer, synchronized
    assign tx_we = start_tx_fifo_i & wbm_cyc_o & wbm_stb_o & wbm_ack_i;
    wire [4:0] tx_wp_bin_full = {tx_wp_gray_m[4], tx_wp_bin};
    wire [4:0] tx_wp_bin_next = tx_wp_bin_full + 5'd1;
    wire [4:0] tx_wp_gray_next = tx_wp_bin_next ^ {1'b0, tx_wp_bin_next[4:1]};
    wire [4:0] tx_rp_bin_x = gray2bin(tx_rp_s);
    always @(posedge clk_mode)
        if (!rst | clr) begin tx_wp_bin <= 4'd0; tx_wp_gray_m <= 5'd0; end
        else if (tx_we) begin tx_wp_bin <= tx_wp_bin_next[3:0]; tx_wp_gray_m <= tx_wp_gray_next; end
    always @(posedge clk_mode) tx_rp_s <= tx_rp_gray_i;
    always @(posedge clk_mode)
        tx_fifo_full_i <= ((tx_wp_bin_full[3:0] == tx_rp_bin_x[3:0]) & (tx_wp_bin_full[4] != tx_rp_bin_x[4]))
                        | (tx_we & (tx_wp_bin_next[3:0] == tx_rp_bin_x[3:0]) & (tx_wp_bin_next[4] != tx_rp_bin_x[4]));
endmodule
