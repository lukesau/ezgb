// The SD data master: Marek Czerski's sd_data_master from the OpenCores
// WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// as EZ Flash built it, together with his sd_data_xfer_trig, the small FSM
// that turns a command-with-data into a transfer start once the command
// has completed. The master starts the data host (d_write_o / d_read_o),
// watches the buffer flags and a timeout, and stops it.
//
// Derived from that source, which is Copyright (C) 2013 Marek Czerski,
// based on original work Copyright (C) 2009 Adam Edvardsson, and licensed
// under the GNU Lesser General Public License version 2.1 or later; this
// file keeps that notice and is under the same license.
//
// Written from the OpenCores source, with what the synthesis left of it:
//
//   - the FSM keeps the source's codes (IDLE 000, START_TX_FIFO 001,
//     START_RX_FIFO 010, DATA_TRANSFER 100), so does the trigger's (IDLE
//     00, WAIT_FOR_CMD_INT 01, TRIGGER_XFER 10)
//   - DATA_TIMEOUT_W is 8 in EZ Flash's build: timeout_reg and the
//     watchdog are 8 bits
//   - int_status_o is gone: nothing reads the data interrupt status, so the
//     synthesis dropped the register and with it crc_ok_i and
//     int_status_rst_i
//   - the trigger's command start arrives as the two taps of the source's
//     monostable crossing, XORed here; cmd_int_status_i is the command
//     master's int_status_cc and cmd_int_n outputs (CC, and "CC or EI")
//   - the buffer flags are EZ Flash's own (the source's FIFO filler is
//     not in the design); tx_fifo_full_i is a register in the Game Boy
//     clock domain read without a synchronizer
//   - xfr_complete_i is the data host's busy output inverted; the synthesis
//     also decoded the host's state bits directly in places, so both come
//     in, and the proof assumes they agree (they are the same LUT function)
//
// Block: stage0/blocks/sd_data_master.blk.

module sd_data_master (
    input clk_sd,
    input soft_rst,
    input [7:0] timeout_i,
    input [2:1] cmd_start_sync,     // monostable crossing taps: cmd_start = ^cmd_start_sync
    input [1:0] cmd_with_data_i,    // command register, CMD_WITH_DATA: 01 read, 10/11 write
    input cmd_int_cc_i,             // the command master's int_status_o[CC] (its int_status_cc output)
    input cmd_int_n_i,              // the command master's cmd_int_n: low while a command is complete or in error
    input tx_fifo_full_i,
    input tx_fifo_empty_i,
    input rx_fifo_full_i,
    input xfr_busy_i,               // the data host's busy
    input [2:0] xfr_state_i,        // the data host's state: busy is (xfr_state_i != 0)
    output reg [2:0] state,
    output reg trans_done,
    output reg d_write_o,
    output reg d_read_o,
    output reg start_tx_fifo_o,
    output reg start_rx_fifo_o,
    output timeout_lo_zero,         // LUTs the design shares with logic outside
    output timeout_hi_zero,
    output timeout_zero,
    output fifo_flag,
    output watchdog_ge_timeout
);
    localparam IDLE = 3'b000, START_TX_FIFO = 3'b001, START_RX_FIFO = 3'b010, DATA_TRANSFER = 3'b100;
    localparam T_IDLE = 2'b00, WAIT_FOR_CMD_INT = 2'b01, TRIGGER_XFER = 2'b10;

    // ---- the transfer trigger (sd_data_xfer_trig)
    wire cmd_start = cmd_start_sync[2] ^ cmd_start_sync[1];
    wire cmd_with_data_start = cmd_start & (cmd_with_data_i != 2'b00);
    wire r_w = (cmd_with_data_i == 2'b01);
    wire cmd_int_cc = cmd_int_cc_i;
    reg [1:0] trig_state;
    reg r_w_reg, start_tx, start_rx;
    reg [1:0] trig_next;
    always @* begin
        case (trig_state)
            T_IDLE:           trig_next = (cmd_with_data_start & r_w) ? TRIGGER_XFER : cmd_with_data_start ? WAIT_FOR_CMD_INT : T_IDLE;
            WAIT_FOR_CMD_INT: trig_next = cmd_int_cc ? TRIGGER_XFER : cmd_int_n_i ? WAIT_FOR_CMD_INT : T_IDLE;   // falls to IDLE on CC or EI
            TRIGGER_XFER:     trig_next = T_IDLE;
            default:          trig_next = T_IDLE;
        endcase
    end
    always @(posedge clk_sd or posedge soft_rst)
        if (soft_rst) begin
            trig_state <= T_IDLE; start_tx <= 0; start_rx <= 0; r_w_reg <= 0;
        end else begin
            trig_state <= trig_next;
            case (trig_state)
                T_IDLE:           begin start_tx <= 0; start_rx <= 0; r_w_reg <= r_w; end
                WAIT_FOR_CMD_INT: begin start_tx <= 0; start_rx <= 0; end
                TRIGGER_XFER:     begin start_tx <= ~r_w_reg; start_rx <= r_w_reg; end
                default: ;
            endcase
        end

    // ---- the data master
    reg [7:0] timeout_reg, watchdog;
    reg tx_cycle;
    wire xfr_complete = !xfr_busy_i;
    assign fifo_flag = tx_cycle ? tx_fifo_empty_i : rx_fifo_full_i;
    assign timeout_lo_zero = (timeout_reg[3:0] == 4'd0);
    assign timeout_hi_zero = (timeout_reg[7:4] == 4'd0);
    assign timeout_zero = timeout_lo_zero & timeout_hi_zero;
    assign watchdog_ge_timeout = (watchdog >= timeout_reg);
    wire timed_out = !timeout_zero & watchdog_ge_timeout;

    reg [2:0] next_state;
    always @* begin
        case (state)
            IDLE:          next_state = start_tx ? START_TX_FIFO : start_rx ? START_RX_FIFO : IDLE;
            START_TX_FIFO: next_state = (tx_fifo_full_i && !xfr_complete) ? DATA_TRANSFER : START_TX_FIFO;
            START_RX_FIFO: next_state = !xfr_complete ? DATA_TRANSFER : START_RX_FIFO;
            DATA_TRANSFER: next_state = trans_done ? IDLE : DATA_TRANSFER;
            default:       next_state = IDLE;
        endcase
    end

    always @(posedge clk_sd or posedge soft_rst)
        if (soft_rst) begin
            state <= IDLE; start_tx_fifo_o <= 0; start_rx_fifo_o <= 0; d_write_o <= 0; d_read_o <= 0;
            trans_done <= 0; tx_cycle <= 0; timeout_reg <= 0; watchdog <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    start_tx_fifo_o <= 0;
                    start_rx_fifo_o <= 0;
                    d_write_o <= 0;
                    d_read_o <= 0;
                    trans_done <= 0;
                    tx_cycle <= 0;
                    timeout_reg <= timeout_i;
                    watchdog <= 0;
                end
                START_RX_FIFO: begin
                    start_rx_fifo_o <= 1;
                    start_tx_fifo_o <= 0;
                    tx_cycle <= 0;
                    d_read_o <= 1;
                end
                START_TX_FIFO: begin
                    start_rx_fifo_o <= 0;
                    start_tx_fifo_o <= 1;
                    tx_cycle <= 1;
                    if (tx_fifo_full_i)
                        d_write_o <= 1;
                end
                DATA_TRANSFER: begin
                    d_read_o <= 0;
                    d_write_o <= 0;
                    watchdog <= watchdog + 8'd1;
                    if (fifo_flag) begin                 // tx: buffer empty; rx: buffer full
                        trans_done <= 1;
                        d_write_o <= 1;
                        d_read_o <= 1;
                    end
                    if (timed_out) begin
                        trans_done <= 1;
                        d_write_o <= 1;
                        d_read_o <= 1;
                    end else if (xfr_complete) begin
                        d_write_o <= 0;
                        d_read_o <= 0;
                        trans_done <= 1;
                    end
                end
                default: ;
            endcase
        end

`ifdef FORMAL
    // The states are the four and three codes above (the synthesis took the
    // others as don't-cares). Two facts about the inputs, true by the LUTs
    // that drive them in the neighboring blocks: the data host's busy is the
    // OR of its state bits, and the command master's cmd_int_n is low
    // whenever its CC is set (the trigger would otherwise set both of its
    // state bits at once).
    always @* begin
        assume (state == IDLE || state == START_TX_FIFO || state == START_RX_FIFO || state == DATA_TRANSFER);
        assume (trig_state != 2'b11);
        env_busy: assume (xfr_busy_i == (xfr_state_i != 3'b000));
        env_cmd_int: assume (!(cmd_int_cc_i && cmd_int_n_i));
    end
`endif
endmodule
