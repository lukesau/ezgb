// The SD card's command line: Marek Czerski's sd_cmd_serial_host from the
// OpenCores WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// as EZ Flash built it. It sends a 48-bit command (start bit, 38 bits of
// index and argument, CRC7, stop bit) and clocks in the response, checking
// its CRC7 and index.
//
// Derived from that source, which is Copyright (C) 2013 Marek Czerski,
// based on original work Copyright (C) 2009 Adam Edvardsson, and licensed
// under the GNU Lesser General Public License version 2.1 or later; this
// file keeps that notice and is under the same license.
//
// Written from the OpenCores source, with what the synthesis left of it:
//
//   - the FSM is one-hot with a register for INIT too (the source numbers
//     INIT as zero); the integer counter is a full 32 bits, resp_idx 7
//   - resp_len is 39 or 127: its constant-one bits became one register
//     (resp_len_loaded, set by the first start) and its other bits are
//     long_response
//   - cmd_buff[39] is a constant 0 from the command master, so the buffer
//     is 39 bits; resp_buff[127:126], the response's start and
//     transmission bits, are never read and were dropped
//   - cmd_dat_reg is the pad's own input register (cmd_dat_q here), and
//     cmd_out_o / cmd_oe_o are registered again in the pad's output cells,
//     from the same next values this module keeps in its own copies
//     (cmd_out_next, cmd_oe_next)
//   - the CRC7 register sits in the slices rotated by three bits
//
// Block: stage0/blocks/sd_cmd_serial.blk.

module sd_cmd_serial (
    input clk_sd,
    input soft_rst,             // wb_rst | software reset
    input go_idle,              // the command master's timeout
    input start,
    input with_response_i,      // setting_i[0]
    input long_response_i,      // setting_i[1]
    input [38:0] cmd_i,         // {1, index[5:0], argument[31:0]}
    input cmd_dat_q,            // CMD pad, registered
    output [119:0] response,
    output reg finish_o,
    output reg crc_ok_o,
    output reg index_ok_o,
    output cmd_out_next,        // next cmd_out_o, to the pad's output register
    output cmd_t_next,          // the pad's tristate control: !cmd_oe_o next
    output rst,
    output gnd, gnd1, gnd2      // constant-0 LUTs the design shares
);
    assign rst = soft_rst | go_idle;
    assign gnd = 1'b0, gnd1 = 1'b0, gnd2 = 1'b0;

    localparam INIT_DELAY = 4, BITS_TO_SEND = 48, CMD_SIZE = 40, RESP_SIZE = 128;

    // ---- state (one-hot)
    reg st_init, st_idle, st_setup, st_write, st_read_wait, st_read, st_finish_wr, st_finish_wo;
    reg signed [31:0] counter;
    reg [6:0] resp_idx;
    reg with_response, long_response, resp_len_loaded;
    reg [38:0] cmd_buff;
    reg [125:0] resp_buff;
    reg [119:0] response_o;
    reg crc_rst, crc_enable, crc_bit, crc_ok;
    reg [6:0] crc_in, crc;
    reg cmd_oe_o, cmd_out_o;

    assign response = response_o;
    wire signed [31:0] resp_len = (resp_len_loaded ? 32'd39 : 32'd0) | (long_response ? 32'd88 : 32'd0);  // 0, 39 or 127
    wire [39:0] cmd_buff_full = {1'b0, cmd_buff};

    // ---- CRC7 (x^7 + x^3 + 1), cleared asynchronously by crc_rst
    wire inv = crc_bit ^ crc[6];
    always @(posedge clk_sd or posedge crc_rst)
        if (crc_rst) crc <= 7'd0;
        else if (crc_enable) crc <= {crc[5:3], crc[2] ^ inv, crc[1:0], inv};

    // ---- command decoder
    always @(posedge clk_sd or posedge rst)
        if (rst) begin
            with_response <= 1'b0; long_response <= 1'b0; resp_len_loaded <= 1'b0; cmd_buff <= 39'd0;
        end else if (start) begin
            with_response <= with_response_i;
            long_response <= long_response_i;
            resp_len_loaded <= 1'b1;
            cmd_buff <= cmd_i;
        end

    // ---- FSM
    always @(posedge clk_sd or posedge rst)
        if (rst) begin
            st_init <= 1'b1; st_idle <= 1'b0; st_setup <= 1'b0; st_write <= 1'b0;
            st_read_wait <= 1'b0; st_read <= 1'b0; st_finish_wr <= 1'b0; st_finish_wo <= 1'b0;
        end else begin
            st_init      <= st_init & !(counter >= INIT_DELAY);
            st_idle      <= (st_init & (counter >= INIT_DELAY)) | (st_idle & !start) | st_finish_wo | st_finish_wr;
            st_setup     <= st_idle & start;
            st_write     <= st_setup | (st_write & !(counter >= BITS_TO_SEND));
            st_read_wait <= (st_write & (counter >= BITS_TO_SEND) & with_response) | (st_read_wait & cmd_dat_q);
            st_finish_wo <= st_write & (counter >= BITS_TO_SEND) & !with_response;
            st_read      <= (st_read_wait & !cmd_dat_q) | (st_read & !(counter >= resp_len + 8));
            st_finish_wr <= st_read & (counter >= resp_len + 8);
        end

    // ---- FSM outputs
    //
    // The synthesis decoded the one-hot state with a test per bit, so a
    // register assigned in several states takes the OR of what each active
    // state assigns, and holds only while no assigning state is active.
    // With one bit set that is the source's case statement; the equations
    // below say it the hardware's way so that the proof covers every state.
    wire inc = st_init | st_write | st_read;
    wire write_cmd = st_write & (counter < BITS_TO_SEND - 8);                       // 40 command bits
    wire write_crc = st_write & (counter >= BITS_TO_SEND - 8) & (counter < BITS_TO_SEND - 1);  // 7 CRC bits
    wire read_data = st_read & (counter <= resp_len);
    wire read_crc  = st_read & (counter > resp_len) & (counter - resp_len <= 7);
    wire read_done = st_read & (counter > resp_len) & (counter - resp_len > 7);
    wire assign_counter = st_init | st_idle | st_write | st_read_wait | st_finish_wo | st_read | st_finish_wr;
    wire assign_oe = assign_counter;                                                 // all but SETUP
    wire assign_crc_rst = st_idle | st_setup | st_read_wait | st_finish_wo | st_read | st_finish_wr;
    wire assign_crc_enable = st_idle | st_setup | st_write | st_read_wait | st_finish_wo | st_read | st_finish_wr;

    wire [31:0] counter_next = ({32{inc}} & (counter + 1)) | ({32{st_read_wait}} & 32'd1) | ({32{!assign_counter}} & counter);
    wire cmd_oe_next = st_init | (st_write & (counter < BITS_TO_SEND)) | (!assign_oe & cmd_oe_o);   // driven through the stop bit
    assign cmd_t_next = !cmd_oe_next;
    assign cmd_out_next = st_init | (write_cmd & cmd_buff_full[CMD_SIZE - 1 - counter])
                        | (write_crc & crc[BITS_TO_SEND - 2 - counter]) | (st_write & (counter >= BITS_TO_SEND - 1))
                        | (!(st_init | st_write) & cmd_out_o);
    wire crc_rst_next = st_idle | st_read_wait | st_finish_wo | st_finish_wr | (!assign_crc_rst & crc_rst);
    wire crc_enable_next = st_setup
                         | (st_write & crc_enable & !((counter >= BITS_TO_SEND - 9) & (counter < BITS_TO_SEND - 1)))
                         | (read_data & ((resp_len != RESP_SIZE - 1) || (counter > 7)))
                         | (!assign_crc_enable & crc_enable);
    wire crc_bit_next = (st_setup & cmd_buff_full[CMD_SIZE - 1 - counter])
                      | (st_write & ((counter < BITS_TO_SEND - 9) ? cmd_buff_full[CMD_SIZE - 2 - counter] : crc_bit))
                      | (st_read & (read_data ? cmd_dat_q : crc_bit))
                      | (!(st_setup | st_write | st_read) & crc_bit);
    wire [6:0] resp_idx_next = ({7{st_read}} & ((read_data & (counter >= 8)) ? resp_idx + 7'd1 : resp_idx))
                             | ({7{!(st_idle | st_read)}} & resp_idx);
    wire finish_next = st_finish_wo | st_finish_wr | (!(st_idle | st_finish_wo | st_finish_wr) & finish_o);
    wire index_ok_next = (st_finish_wr & (cmd_buff[37:32] == resp_buff[125:120])) | (!(st_idle | st_finish_wr) & index_ok_o);
    wire crc_ok_o_next = (st_finish_wr & crc_ok) | (!(st_idle | st_finish_wr) & crc_ok_o);
    wire [119:0] response_next = ({120{st_finish_wr}} & resp_buff[119:0]) | ({120{!(st_idle | st_finish_wr)}} & response_o);

    integer k;
    always @(posedge clk_sd or posedge rst)
        if (rst) begin
            crc_enable <= 1'b0; resp_idx <= 7'd0; cmd_oe_o <= 1'b1; cmd_out_o <= 1'b1;
            resp_buff <= 126'd0; finish_o <= 1'b0; crc_rst <= 1'b1; crc_bit <= 1'b0; crc_in <= 7'd0;
            response_o <= 120'd0; index_ok_o <= 1'b0; crc_ok_o <= 1'b0; crc_ok <= 1'b0; counter <= 32'd0;
        end else begin
            counter <= counter_next;
            cmd_oe_o <= cmd_oe_next;
            cmd_out_o <= cmd_out_next;
            crc_rst <= crc_rst_next;
            crc_enable <= crc_enable_next;
            crc_bit <= crc_bit_next;
            resp_idx <= resp_idx_next;
            finish_o <= finish_next;
            index_ok_o <= index_ok_next;
            crc_ok_o <= crc_ok_o_next;
            response_o <= response_next;
            // the response, bit by bit: start, transmission and index bits by
            // the counter (the first two are not kept), the rest by resp_idx
            for (k = 0; k < 126; k = k + 1)
                if (read_data & ((counter < 8 & k == RESP_SIZE - 1 - counter) | (counter >= 8 & k == 7'd119 - resp_idx)))
                    resp_buff[k] <= cmd_dat_q;
            for (k = 0; k < 7; k = k + 1)
                if (read_crc & k == (resp_len + 7) - counter)
                    crc_in[k] <= cmd_dat_q;
            if (read_done) crc_ok <= crc_in == crc;
        end
`ifdef FORMAL
    // What the proof may assume about the hardware's reachable states. The
    // proof script also proves these hold, from reset and by induction, so
    // they are written inductively: what they allow at one step implies
    // them at the next.
    //
    //   - the state is one-hot: the FSM starts in INIT and moves one token
    //   - the counter per state: INIT counts to 4 and hands IDLE a 5, which
    //     IDLE clears; SETUP follows IDLE with 0; WRITE counts to 48 and
    //     hands over 49; READ_WAIT holds that 49 for a cycle and then 1;
    //     READ counts from 1 to at most resp_len + 8 (135) and hands over
    //     up to 136; FINISH_WO sees 49
    //   - resp_idx: cleared by IDLE, so 0 until READ, where it counts the
    //     response bits taken after the first eight (so at most counter - 8),
    //     up to 120
    always @* begin
        assume ((st_init + st_idle + st_setup + st_write + st_read_wait + st_read + st_finish_wr + st_finish_wo) == 4'd1);
        assume (counter >= 0);
        if (st_init)      assume (counter <= 4);
        if (st_idle)      assume (counter <= 5);
        if (st_setup)     assume (counter == 0);
        if (st_write)     assume (counter <= 48);
        if (st_read_wait) assume (counter == 49 || counter == 1);
        if (st_read)      assume (counter >= 1 && counter <= 135);
        if (st_finish_wr) assume (counter <= 136);
        if (st_finish_wo) assume (counter == 49);
        assume (resp_idx <= 7'd120);
        if (st_setup || st_write || st_read_wait) assume (resp_idx == 0);
        if (st_read) assume (counter >= 8 ? resp_idx <= counter - 8 : resp_idx == 0);
    end
`endif
endmodule
