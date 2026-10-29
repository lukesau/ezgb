// The SD card's data lines: Marek Czerski's sd_data_serial_host from the
// OpenCores WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// as EZ Flash built it. It shifts a block out over DAT0 (or DAT0-3), appends
// the four CRC16s and reads back the card's CRC status, or clocks a block in,
// checks its CRC16s and hands the words to the receive buffer.
//
// Derived from that source, which is Copyright (C) 2013 Marek Czerski,
// based on original work Copyright (C) 2009 Adam Edvardsson, and licensed
// under the GNU Lesser General Public License version 2.1 or later; this
// file keeps that notice and is under the same license.
//
// Written from the OpenCores source at revision bf94521b (2013: the abort on
// start == 2'b11 from every state, a three-bit crc_status), with what the
// synthesis left of it:
//
//   - the FSM is binary, not one-hot: IDLE 000, WRITE_DAT 001, WRITE_CRC 101,
//     WRITE_BUSY 010, READ_WAIT 100, READ_DAT 011; codes 110 and 111 never
//     occur and the synthesis took them as don't-cares
//   - BLKSIZE_W is 10 and BLKCNT_W 8 in EZ Flash's build: transf_cnt is 14
//     bits, data_cycles 13 (its bit 0 is a constant 0 and has no register),
//     blkcnt_reg 8; blksize_reg keeps only the two bits the byte alignment
//     update reads, and those two have no reset: their enable is
//     IDLE & !soft_rst instead
//   - DAT_dat_reg is the pads' own input registers (sd_dat*_q here), and
//     DAT_dat_o / DAT_oe_o are registered again in the pads' output cells
//     from the same next values this module keeps in its own copies
//     (dat_out_next, dat_t_next); the DAT2 pad is input only, so its copy
//     drives nothing
//   - data_in is the transmit buffer's read port (block RAM X3Y9), and
//     data_out feeds the receive buffer's write port (X3Y1) directly, with
//     we as its write enable; EZ Flash's address counters sit outside
//   - blksize, blkcnt, bus_4bit, byte_alignment and start arrive through
//     the register crossings as the *_i inputs
//   - the transfer counter's carry-in is sd_cmd_serial's constant-0 LUT
//     (gnd_i); the constant-0 LUTs here are shared the same way
//
// Block: stage0/blocks/sd_data_serial.blk.

module sd_data_serial (
    input clk_sd,
    input soft_rst,
    input [1:0] start_i,            // {d_read, d_write} from the data master
    input sd_dat0_q,                // DAT0..3 pads, registered (DAT_dat_reg)
    input sd_dat1_q,
    input sd_dat2_q,
    input sd_dat3_q,
    input [31:0] data_in,           // transmit buffer word
    input [9:0] blksize_i,
    input [7:0] blkcnt_i,
    input bus_4bit_i,
    input [1:0] byte_alignment_i,
    input gnd_i,                    // a constant 0 shared with sd_cmd_serial
    output reg [2:0] state,
    output reg crc_ok,
    output reg DAT_oe_o,
    output reg we,
    output reg rd,
    output reg [31:0] data_out,
    output busy,
    output [3:0] dat_out_next,      // next DAT_dat_o, to the pads' output registers
    output dat_t_next,              // the pads' tristate control: !DAT_oe_o next
    output gnd, gnd1, gnd2, gnd3, gnd4, gnd5, gnd6, gnd7
);
    assign gnd = 1'b0, gnd1 = 1'b0, gnd2 = 1'b0, gnd3 = 1'b0, gnd4 = 1'b0, gnd5 = 1'b0, gnd6 = 1'b0, gnd7 = 1'b0;

    localparam BLKSIZE_W = 10, BLKCNT_W = 8;
    localparam IDLE = 3'b000, WRITE_DAT = 3'b001, WRITE_CRC = 3'b101, WRITE_BUSY = 3'b010, READ_WAIT = 3'b100, READ_DAT = 3'b011;

    wire [3:0] DAT_dat_reg = {sd_dat3_q, sd_dat2_q, sd_dat1_q, sd_dat0_q};
    wire start_bit = !DAT_dat_reg[0];
    assign busy = (state != IDLE);

    // ---- registers (one for one with the hardware's)
    reg [BLKSIZE_W-1+3:1] data_cycles;             // bit 0 is always 0 and has no register
    wire [BLKSIZE_W-1+3:0] data_cycles_full = {data_cycles, 1'b0};
    reg bus_4bit_reg;
    reg [3:0] crc_in;
    reg crc_en, crc_rst;
    reg [BLKSIZE_W-1+4:0] transf_cnt;
    reg [2:0] crc_status;
    reg busy_int;
    reg [BLKCNT_W-1:0] blkcnt_reg;
    reg [1:0] byte_alignment_reg;
    reg [1:0] blksize_reg;
    reg next_block;
    reg [4:0] crc_c;
    reg [3:0] last_din;
    reg [2:0] crc_s;
    reg [4:0] data_index;
    reg [3:0] DAT_dat_o;

    // ---- the four CRC16s (x^16 + x^12 + x^5 + 1), cleared asynchronously by crc_rst
    reg [15:0] crc0, crc1, crc2, crc3;
    function [15:0] crc16_next(input [15:0] c, input b);
        reg inv;
        begin
            inv = b ^ c[15];
            crc16_next = {c[14:12], c[11] ^ inv, c[10:5], c[4] ^ inv, c[3:0], inv};
        end
    endfunction
    always @(posedge clk_sd or posedge crc_rst)
        if (crc_rst) begin
            crc0 <= 16'd0; crc1 <= 16'd0; crc2 <= 16'd0; crc3 <= 16'd0;
        end else if (crc_en) begin
            crc0 <= crc16_next(crc0, crc_in[0]);
            crc1 <= crc16_next(crc1, crc_in[1]);
            crc2 <= crc16_next(crc2, crc_in[2]);
            crc3 <= crc16_next(crc3, crc_in[3]);
        end

    // ---- next state
    reg [2:0] next_state;
    always @* begin
        case (state)
            IDLE:       next_state = (start_i == 2'b01) ? WRITE_DAT : (start_i == 2'b10) ? READ_WAIT : IDLE;
            WRITE_DAT:  next_state = (transf_cnt >= data_cycles_full + 21 && start_bit) ? WRITE_CRC : WRITE_DAT;
            WRITE_CRC:  next_state = (crc_status == 3) ? WRITE_BUSY : WRITE_CRC;
            WRITE_BUSY: next_state = (!busy_int && next_block && crc_ok) ? WRITE_DAT : !busy_int ? IDLE : WRITE_BUSY;
            READ_WAIT:  next_state = start_bit ? READ_DAT : READ_WAIT;
            READ_DAT:   next_state = (transf_cnt == data_cycles_full + 17 && next_block && crc_ok) ? READ_WAIT
                                   : (transf_cnt == data_cycles_full + 17) ? IDLE : READ_DAT;
            default:    next_state = IDLE;
        endcase
        if (start_i == 2'b11) next_state = IDLE;     // abort
    end

    // ---- next values: the source's case statement, computed combinationally
    // so that the pads can take DAT_dat_o and DAT_oe_o a cycle early
    reg DAT_oe_n, crc_en_n, crc_rst_n, rd_n, we_n, crc_ok_n, busy_int_n, next_block_n, bus_4bit_n;
    reg [BLKSIZE_W-1+4:0] transf_cnt_n;
    reg [4:0] crc_c_n, data_index_n;
    reg [3:0] last_din_n, crc_in_n, DAT_dat_n;
    reg [2:0] crc_status_n, crc_s_n;
    reg [31:0] data_out_n;
    reg [BLKCNT_W-1:0] blkcnt_n;
    reg [1:0] byte_alignment_n;
    reg [BLKSIZE_W-1+3:0] data_cycles_n;
    always @* begin
        DAT_oe_n = DAT_oe_o; crc_en_n = crc_en; crc_rst_n = crc_rst; rd_n = rd; we_n = we; crc_ok_n = crc_ok;
        busy_int_n = busy_int; next_block_n = next_block; bus_4bit_n = bus_4bit_reg; transf_cnt_n = transf_cnt;
        crc_c_n = crc_c; data_index_n = data_index; last_din_n = last_din; crc_in_n = crc_in; DAT_dat_n = DAT_dat_o;
        crc_status_n = crc_status; crc_s_n = crc_s; data_out_n = data_out; blkcnt_n = blkcnt_reg;
        byte_alignment_n = byte_alignment_reg; data_cycles_n = data_cycles_full;
        case (state)
            IDLE: begin
                DAT_oe_n = 0;
                DAT_dat_n = 4'b1111;
                crc_en_n = 0;
                crc_rst_n = 1;
                transf_cnt_n = 0;
                crc_c_n = 16;
                crc_status_n = 0;
                crc_s_n = 0;
                we_n = 0;
                rd_n = 0;
                data_index_n = 0;
                next_block_n = 0;
                blkcnt_n = blkcnt_i;
                byte_alignment_n = byte_alignment_i;
                // the 4-bit count takes blksize bit 2 as 1 (see the header)
                data_cycles_n = bus_4bit_i ? ((blksize_i | 10'd4) << 1) + 2 : (blksize_i << 3) + 8;
                bus_4bit_n = bus_4bit_i;
            end
            WRITE_DAT: begin
                crc_ok_n = 0;
                transf_cnt_n = transf_cnt + 1;
                next_block_n = 0;
                rd_n = 0;
                if (transf_cnt == 0 && byte_alignment_reg == 2'b11 && bus_4bit_reg) begin   // special case
                    rd_n = 1;
                end else if (transf_cnt == 1) begin
                    crc_rst_n = 0;
                    crc_en_n = 1;
                    if (bus_4bit_reg) begin
                        last_din_n = {data_in[31 - (byte_alignment_reg << 3)], data_in[30 - (byte_alignment_reg << 3)],
                                      data_in[29 - (byte_alignment_reg << 3)], data_in[28 - (byte_alignment_reg << 3)]};
                        crc_in_n = last_din_n;
                    end else begin
                        last_din_n = {3'h7, data_in[31 - (byte_alignment_reg << 3)]};
                        crc_in_n = last_din_n;
                    end
                    DAT_oe_n = 1;
                    DAT_dat_n = bus_4bit_reg ? 4'h0 : 4'he;
                    data_index_n = bus_4bit_reg ? {2'b00, byte_alignment_reg, 1'b1} : {byte_alignment_reg, 3'b001};
                end else if (transf_cnt >= 2 && transf_cnt <= data_cycles_full + 1) begin
                    DAT_oe_n = 1;
                    if (bus_4bit_reg) begin
                        last_din_n = {data_in[31 - (data_index[2:0] << 2)], data_in[30 - (data_index[2:0] << 2)],
                                      data_in[29 - (data_index[2:0] << 2)], data_in[28 - (data_index[2:0] << 2)]};
                        crc_in_n = last_din_n;
                        if (data_index[2:0] == 3'h5 && transf_cnt <= data_cycles_full - 1)   // not 7: read delay
                            rd_n = 1;
                    end else begin
                        last_din_n = {3'h7, data_in[31 - data_index]};
                        crc_in_n = last_din_n;
                        if (data_index == 29)                                           // not 31: read delay
                            rd_n = 1;
                    end
                    data_index_n = data_index + 1;
                    DAT_dat_n = last_din;
                    if (transf_cnt == data_cycles_full + 1)
                        crc_en_n = 0;
                end else if (transf_cnt > data_cycles_full + 1 && crc_c != 0) begin
                    crc_en_n = 0;
                    crc_c_n = crc_c - 1;
                    DAT_oe_n = 1;
                    DAT_dat_n[0] = crc0[crc_c - 1];
                    if (bus_4bit_reg)
                        DAT_dat_n[3:1] = {crc3[crc_c - 1], crc2[crc_c - 1], crc1[crc_c - 1]};
                    else
                        DAT_dat_n[3:1] = 3'h7;
                end else if (transf_cnt == data_cycles_full + 18) begin
                    DAT_oe_n = 1;
                    DAT_dat_n = 4'hf;
                end else if (transf_cnt >= data_cycles_full + 19) begin
                    DAT_oe_n = 0;
                end
            end
            WRITE_CRC: begin
                DAT_oe_n = 0;
                if (crc_status < 3)
                    crc_s_n[crc_status] = DAT_dat_reg[0];
                crc_status_n = crc_status + 1;
                busy_int_n = 1;
            end
            WRITE_BUSY: begin
                crc_ok_n = (crc_s == 3'b010);
                busy_int_n = !DAT_dat_reg[0];
                next_block_n = (blkcnt_reg != 0);
                if (next_state != WRITE_BUSY) begin
                    blkcnt_n = blkcnt_reg - 1;
                    byte_alignment_n = byte_alignment_reg + blksize_reg + 2'b1;
                    crc_rst_n = 1;
                    crc_c_n = 16;
                    crc_status_n = 0;
                end
                transf_cnt_n = 0;
            end
            READ_WAIT: begin
                DAT_oe_n = 0;
                crc_rst_n = 0;
                crc_en_n = 1;
                crc_in_n = 0;
                crc_c_n = 15;
                next_block_n = 0;
                transf_cnt_n = 0;
                data_index_n = bus_4bit_reg ? (byte_alignment_reg << 1) : (byte_alignment_reg << 3);
            end
            READ_DAT: begin
                if (transf_cnt < data_cycles_full) begin
                    if (bus_4bit_reg) begin
                        we_n = (data_index[2:0] == 7 || (transf_cnt == data_cycles_full - 1 && !(|blkcnt_reg)));
                        data_out_n[31 - (data_index[2:0] << 2)] = DAT_dat_reg[3];
                        data_out_n[30 - (data_index[2:0] << 2)] = DAT_dat_reg[2];
                        data_out_n[29 - (data_index[2:0] << 2)] = DAT_dat_reg[1];
                        data_out_n[28 - (data_index[2:0] << 2)] = DAT_dat_reg[0];
                    end else begin
                        we_n = (data_index == 31 || (transf_cnt == data_cycles_full - 1 && !(|blkcnt_reg)));
                        data_out_n[31 - data_index] = DAT_dat_reg[0];
                    end
                    data_index_n = data_index + 1;
                    crc_in_n = DAT_dat_reg;
                    crc_ok_n = 1;
                    transf_cnt_n = transf_cnt + 1;
                end else if (transf_cnt <= data_cycles_full + 16) begin
                    transf_cnt_n = transf_cnt + 1;
                    crc_en_n = 0;
                    last_din_n = DAT_dat_reg;
                    we_n = 0;
                    if (transf_cnt > data_cycles_full) begin
                        crc_c_n = crc_c - 1;
                        if (crc0[crc_c] != last_din[0]) crc_ok_n = 0;
                        if (crc1[crc_c] != last_din[1] && bus_4bit_reg) crc_ok_n = 0;
                        if (crc2[crc_c] != last_din[2] && bus_4bit_reg) crc_ok_n = 0;
                        if (crc3[crc_c] != last_din[3] && bus_4bit_reg) crc_ok_n = 0;
                        if (crc_c == 0) begin
                            next_block_n = (blkcnt_reg != 0);
                            blkcnt_n = blkcnt_reg - 1;
                            byte_alignment_n = byte_alignment_reg + blksize_reg + 2'b1;
                            crc_rst_n = 1;
                        end
                    end
                end
            end
            default: ;
        endcase
    end
    assign dat_out_next = DAT_dat_n;
    assign dat_t_next = !DAT_oe_n;

    always @(posedge clk_sd or posedge soft_rst)
        if (soft_rst) begin
            state <= IDLE; DAT_oe_o <= 0; crc_en <= 0; crc_rst <= 1; transf_cnt <= 0; crc_c <= 0; rd <= 0;
            last_din <= 0; crc_in <= 0; DAT_dat_o <= 0; crc_status <= 0; crc_s <= 0; we <= 0; data_out <= 0;
            crc_ok <= 0; busy_int <= 0; data_index <= 0; next_block <= 0; blkcnt_reg <= 0; byte_alignment_reg <= 0;
            data_cycles <= 0; bus_4bit_reg <= 0;
        end else begin
            state <= next_state; DAT_oe_o <= DAT_oe_n; crc_en <= crc_en_n; crc_rst <= crc_rst_n; transf_cnt <= transf_cnt_n;
            crc_c <= crc_c_n; rd <= rd_n; last_din <= last_din_n; crc_in <= crc_in_n; DAT_dat_o <= DAT_dat_n;
            crc_status <= crc_status_n; crc_s <= crc_s_n; we <= we_n; data_out <= data_out_n; crc_ok <= crc_ok_n;
            busy_int <= busy_int_n; data_index <= data_index_n; next_block <= next_block_n; blkcnt_reg <= blkcnt_n;
            byte_alignment_reg <= byte_alignment_n; data_cycles <= data_cycles_n[BLKSIZE_W-1+3:1]; bus_4bit_reg <= bus_4bit_n;
        end

    // blksize_reg[1:0]: loaded in IDLE like the rest, but without a reset
    always @(posedge clk_sd)
        if (state == IDLE && !soft_rst)
            blksize_reg <= blksize_i[1:0];

`ifdef FORMAL
    // What the proof may assume about the hardware's reachable states. The
    // proof script also proves these hold, from reset and by induction, so
    // they are written inductively: what they allow at one step implies
    // them at the next. (A wrong one would silently empty the proof of the
    // states it excludes.)
    //
    //   - the state is one of the six codes
    //   - crc_status counts 0..3 in WRITE_CRC and reaches 4 on the way out,
    //     into WRITE_BUSY (always 4 there, cleared on exit) or into IDLE
    //     by an abort (cleared a cycle later); at most 3 anywhere else
    //   - crc_c: IDLE sets 16 and WRITE_DAT counts it down to 0 (the write
    //     states see 0..16); READ_WAIT sets 15 and READ_DAT counts it down
    //     through the 16 CRC cycles after data_cycles, so there it tracks
    //     transf_cnt and ends at 31 (0 - 1) in the last cycle, which IDLE or
    //     READ_WAIT reloads
    //   - gnd_i is a constant 0 LUT: an environment assumption, which the
    //     script keeps as one (the env_ label)
    always @* begin
        assume (state == IDLE || state == WRITE_DAT || state == WRITE_CRC || state == WRITE_BUSY || state == READ_WAIT || state == READ_DAT);
        assume (state == WRITE_BUSY ? crc_status == 3'd4 : state == IDLE ? crc_status <= 3'd4 : crc_status <= 3'd3);
        if (state == READ_DAT) begin
            assume (transf_cnt <= data_cycles_full + 17);
            assume (transf_cnt <= data_cycles_full ? crc_c == 5'd15
                  : transf_cnt <= data_cycles_full + 16 ? crc_c == data_cycles_full + 16 - transf_cnt
                  : crc_c == 5'd31);
        end else if (state == IDLE || state == READ_WAIT)
            assume (crc_c <= 5'd16 || crc_c == 5'd31);
        else
            assume (crc_c <= 5'd16);
        env_gnd: assume (gnd_i == 1'b0);
    end
`endif
endmodule
