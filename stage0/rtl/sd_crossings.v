// The SD controller's clock-domain crossings: Marek Czerski's
// bistable_domain_cross and monostable_domain_cross instances from the
// OpenCores WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// as EZ Flash built them. Registers written on the Game Boy side (the mode
// clock domain) are carried into the SD clock domain, and the command
// responses and interrupt status back; three write pulses cross as toggles.
//
// Derived from that source, which is Copyright (C) 2013 Marek Czerski,
// based on original work Copyright (C) 2009 Adam Edvardsson, and licensed
// under the GNU Lesser General Public License version 2.1 or later; this
// file keeps that notice and is under the same license.
//
// What the synthesis left of it:
//
//   - no resets: the source's rst is tied off, so every stage is a plain
//     flip-flop
//   - into the SD domain, some registers cross in two stages as in the
//     source (argument, block count, data timeout) and the rest in one
//     (command, command timeout, block size, bus width, byte alignment,
//     software reset); back into the mode domain the responses and the
//     command interrupt status cross in two
//   - the command register's bits 7:5 do not cross: 7 is unused and 6:5
//     (CMD_WITH_DATA) go to the data master's trigger separately, so the
//     command crosses as its index (13:8) and its checks (4:0)
//   - the three pulse crossings are the source's: a toggle in the mode
//     domain, three stages in the SD domain, the consumer XORs the last
//     two; the pulse that flips each toggle is one mode-domain flag ANDed
//     with the inverse of another (a rising-edge detect in the register
//     file), which arrive here as <pulse>_m[1] and <pulse>_m[0]
//   - the data interrupt status is gone from the design, but its reset
//     pulse's crossing is still here (data_int_rst, named by elimination)
//
// Block: stage0/blocks/sd_crossings.blk.

module sd_crossings (
    input clk_mode,
    input clk_sd,
    // mode domain in
    input [31:0] argument_m,
    input [5:0] cmd_index_m,
    input [4:0] cmd_check_m,
    input [1:0] cmd_with_data_m,
    input [15:0] cmd_timeout_m,
    input [7:0] data_timeout_m,
    input [9:0] blksize_m,
    input [7:0] blkcnt_m,
    input bus_4bit_m,
    input [1:0] byte_alignment_m,
    input soft_rst_m,
    input [1:0] cmd_start_m,
    input [1:0] cmd_int_rst_m,
    input [1:0] data_int_rst_m,
    // SD domain in
    input [31:0] response_0_i,
    input [31:0] response_1_i,
    input [31:0] response_2_i,
    input [31:8] response_3_i,
    input [4:0] cmd_int_status_i,
    // SD domain out
    output reg [31:0] argument_i,
    output reg [5:0] cmd_index_i,
    output reg [4:0] cmd_check_i,
    output reg [1:0] cmd_with_data_i,
    output reg [15:0] cmd_timeout_i,
    output reg [7:0] data_timeout_i,
    output reg [9:0] blksize_i,
    output reg [7:0] blkcnt_i,
    output reg bus_4bit_i,
    output reg [1:0] byte_alignment_i,
    output reg soft_rst,
    output reg [2:0] cmd_start_sync,
    output reg [2:0] cmd_int_rst_sync,
    output reg [2:0] data_int_rst_sync,
    // mode domain out
    output reg [31:0] response_0_m,
    output reg [31:0] response_1_m,
    output reg [31:0] response_2_m,
    output reg [31:8] response_3_m,
    output reg [4:0] cmd_int_status_m
);
    // ---- into the SD domain
    reg [31:0] argument_s1;
    reg [7:0] data_timeout_s1, blkcnt_s1;
    always @(posedge clk_sd) begin
        argument_s1 <= argument_m;           argument_i <= argument_s1;
        data_timeout_s1 <= data_timeout_m;   data_timeout_i <= data_timeout_s1;
        blkcnt_s1 <= blkcnt_m;               blkcnt_i <= blkcnt_s1;
        cmd_index_i <= cmd_index_m;
        cmd_check_i <= cmd_check_m;
        cmd_with_data_i <= cmd_with_data_m;
        cmd_timeout_i <= cmd_timeout_m;
        blksize_i <= blksize_m;
        bus_4bit_i <= bus_4bit_m;
        byte_alignment_i <= byte_alignment_m;
        soft_rst <= soft_rst_m;
    end

    // ---- the pulses: toggle on the mode side, three stages on the SD side
    reg cmd_start_toggle, cmd_int_rst_toggle, data_int_rst_toggle;
    always @(posedge clk_mode) begin
        cmd_start_toggle <= cmd_start_toggle ^ (cmd_start_m[1] & !cmd_start_m[0]);
        cmd_int_rst_toggle <= cmd_int_rst_toggle ^ (cmd_int_rst_m[1] & !cmd_int_rst_m[0]);
        data_int_rst_toggle <= data_int_rst_toggle ^ (data_int_rst_m[1] & !data_int_rst_m[0]);
    end
    always @(posedge clk_sd) begin
        cmd_start_sync <= {cmd_start_sync[1:0], cmd_start_toggle};
        cmd_int_rst_sync <= {cmd_int_rst_sync[1:0], cmd_int_rst_toggle};
        data_int_rst_sync <= {data_int_rst_sync[1:0], data_int_rst_toggle};
    end

    // ---- back into the mode domain
    reg [31:0] response_0_s1, response_1_s1, response_2_s1;
    reg [31:8] response_3_s1;
    reg [4:0] cmd_int_status_s1;
    always @(posedge clk_mode) begin
        response_0_s1 <= response_0_i;           response_0_m <= response_0_s1;
        response_1_s1 <= response_1_i;           response_1_m <= response_1_s1;
        response_2_s1 <= response_2_i;           response_2_m <= response_2_s1;
        response_3_s1 <= response_3_i;           response_3_m <= response_3_s1;
        cmd_int_status_s1 <= cmd_int_status_i;   cmd_int_status_m <= cmd_int_status_s1;
    end
endmodule
