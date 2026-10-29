// The SD command master: Marek Czerski's sd_cmd_master from the OpenCores
// WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// as EZ Flash built it. It latches the command and argument the PicoBlaze
// wrote, starts the serial host, watches for a timeout, and collects the
// response and the interrupt status for the register file.
//
// Derived from that source, which is Copyright (C) 2013 Marek Czerski,
// based on original work Copyright (C) 2009 Adam Edvardsson, and licensed
// under the GNU Lesser General Public License version 2.1 or later; this
// file keeps that notice and is under the same license.
//
// Written from the OpenCores source, with what the synthesis left of it:
//
//   - the timeout register and the watchdog are 16 bits, not 24: the
//     register file never sets the upper byte
//   - cmd_o[39] is a constant 0 and is gone; response_3_o[7:0] are the
//     constant zeros the source appends and are gone too
//   - the registers come from the Wishbone side through single flip-flops
//     (argument_i, command_i, timeout_i here are those), and the start and
//     interrupt-reset pulses arrive as the two taps of the source's
//     monostable crossing, XORed here
//   - busy_i is the DAT0 pad's input register, inverted (the data host
//     derives sd_data_busy from DAT0 the same way)
//   - int_status_o is gated by the IDLE state as in the source; cmd_int_n
//     is a LUT EZ Flash added, low while a command is complete or in
//     error, that shares the block
//
// Block: stage0/blocks/sd_cmd_master.blk.

module sd_cmd_master (
    input clk_sd,
    input soft_rst,
    input [2:1] start_sync,         // monostable crossing taps: start_i = ^start_sync
    input [2:1] int_rst_sync,       // likewise int_status_rst_i
    input [119:0] response_i,
    input finish_i,
    input crc_ok_i,
    input index_ok_i,
    input sd_dat0_q,                // DAT0 pad, registered: low while the card is busy
    input [31:0] argument_i,
    input [13:0] command_i,
    input [15:0] timeout_i,
    output expect_response,         // setting_o[0]
    output long_response,           // setting_o[1]
    output reg start_xfr_o,
    output reg go_idle_o,
    output [38:0] cmd_o,
    output [31:0] response_0_o,
    output [31:0] response_1_o,
    output [31:0] response_2_o,
    output [31:8] response_3_o,
    output [4:0] int_status_o,
    output int_status_cc,           // int_status_o[0] again, for logic outside
    output cmd_int_n,
    output gnd
);
    assign gnd = 1'b0;
    wire start_i = start_sync[2] ^ start_sync[1];
    wire int_status_rst_i = int_rst_sync[2] ^ int_rst_sync[1];
    wire busy_i = !sd_dat0_q;       // the card holds DAT0 low while busy

    localparam IDLE = 2'b00, EXECUTE = 2'b01, BUSY_CHECK = 2'b10;
    localparam CC = 0, EI = 1, CTE = 2, CCRCE = 3, CIE = 4;        // int_status bits

    reg [1:0] state;
    reg [15:0] timeout_reg, watchdog;
    reg crc_check, index_check, busy_check;
    reg expect_response_r, long_response_r;
    reg [4:0] int_status_reg;
    reg [38:0] cmd_o_r;
    reg [31:0] response_0_r, response_1_r, response_2_r;
    reg [31:8] response_3_r;
    assign expect_response = expect_response_r, long_response = long_response_r;
    assign cmd_o = cmd_o_r;
    assign response_0_o = response_0_r, response_1_o = response_1_r, response_2_o = response_2_r, response_3_o = response_3_r;
    assign int_status_o = (state == IDLE) ? int_status_reg : 5'h0;
    assign int_status_cc = int_status_o[CC];
    assign cmd_int_n = !(int_status_o[CC] | int_status_o[EI]);

    wire timed_out = (|timeout_reg) && (watchdog >= timeout_reg);

    // ---- state
    always @(posedge clk_sd or posedge soft_rst)
        if (soft_rst) state <= IDLE;
        else case (state)
            IDLE:       state <= start_i ? EXECUTE : IDLE;
            EXECUTE:    state <= ((finish_i && !busy_check) || go_idle_o) ? IDLE
                               : (finish_i && busy_check) ? BUSY_CHECK : EXECUTE;
            BUSY_CHECK: state <= busy_i ? BUSY_CHECK : IDLE;
            default:    state <= IDLE;
        endcase

    // ---- the rest
    always @(posedge clk_sd or posedge soft_rst)
        if (soft_rst) begin
            crc_check <= 1'b0; index_check <= 1'b0; busy_check <= 1'b0;
            expect_response_r <= 1'b0; long_response_r <= 1'b0;
            int_status_reg <= 5'h0; cmd_o_r <= 39'd0; start_xfr_o <= 1'b0; go_idle_o <= 1'b0;
            watchdog <= 16'd0; timeout_reg <= 16'd0;
            response_0_r <= 32'd0; response_1_r <= 32'd0; response_2_r <= 32'd0; response_3_r <= 24'd0;
        end else begin
            case (state)
                IDLE: begin
                    go_idle_o <= 1'b0;
                    index_check <= command_i[4];
                    crc_check <= command_i[3];
                    busy_check <= command_i[2];
                    expect_response_r <= command_i[1] | command_i[0];     // CMD_RESPONSE_CHECK != 0
                    long_response_r <= command_i[1];                     // 2'b10 or 2'b11
                    cmd_o_r <= {1'b1, command_i[13:8], argument_i};      // {01, index, argument} less the leading 0
                    timeout_reg <= timeout_i;
                    watchdog <= 16'd0;
                    if (start_i) begin
                        start_xfr_o <= 1'b1;
                        int_status_reg <= 5'h0;
                    end
                end
                EXECUTE: begin
                    start_xfr_o <= 1'b0;
                    watchdog <= watchdog + 16'd1;
                    if (timed_out) begin
                        int_status_reg[CTE] <= 1'b1;
                        int_status_reg[EI] <= 1'b1;
                        go_idle_o <= 1'b1;
                    end else if (finish_i) begin
                        if (crc_check & !crc_ok_i) begin
                            int_status_reg[CCRCE] <= 1'b1;
                            int_status_reg[EI] <= 1'b1;
                        end
                        if (index_check & !index_ok_i) begin
                            int_status_reg[CIE] <= 1'b1;
                            int_status_reg[EI] <= 1'b1;
                        end
                        int_status_reg[CC] <= 1'b1;
                        if (expect_response_r) begin
                            response_0_r <= response_i[119:88];
                            response_1_r <= response_i[87:56];
                            response_2_r <= response_i[55:24];
                            response_3_r <= response_i[23:0];
                        end
                    end
                end
                BUSY_CHECK: begin
                    start_xfr_o <= 1'b0;
                    go_idle_o <= 1'b0;
                end
                default: ;
            endcase
            if (int_status_rst_i)
                int_status_reg <= 5'h0;
        end

`ifdef FORMAL
    // The state is IDLE, EXECUTE or BUSY_CHECK; the fourth code never
    // occurs, and the synthesis took it as a don't-care.
    always @* assume (state != 2'b11);
`endif
endmodule
