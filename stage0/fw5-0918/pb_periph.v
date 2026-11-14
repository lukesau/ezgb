// FW5-0918's PicoBlaze peripherals: FW4's (stage0/fw4/rtl/pb_periph.v) with
// these changes:
//
//   - the interrupt source runs on the PicoBlaze clock (FW4 the 2x clock)
//     and watches ten request flags, FW4's five and the MBC3 clock's
//     wrote_* flags (the game wrote seconds, minutes, hours, DL or DH;
//     mbc3_clock). A rising edge of any sets the interrupt and loads all
//     ten edges: port B5 reads read, write, load, RTC set, flash, then
//     seconds, minutes, hours from bit 7 down (FW4 has the first five in
//     bits 7:3), port B8 DL (bit 0) and DH (bit 1)
//   - the SPI flash's pins are built in sd_mem_path with the rest of the
//     address pins, so mem_a_gb is gone
//   - the ICAP writes decode D1 and D2 from picoblaze_ports's D0-D3 term
//
// Block: simblk.py from stage0/fw4/blocks/pb_periph.blk with
// stage0/fw5-0918/pb_periph.sim and pb_periph.names.

module pb_periph (
    input clk_pb,
    // the processor and its ports block
    input [1:0] port_id,
    input [7:0] out_port,
    input wr_q,                     // write_strobe, one cycle later
    input wr_ec_ef,                 // a write to EC-EF
    input pid_d0_3,                 // port_id in D0-D3 (picoblaze_ports)
    input int_ack,                  // the core's interrupt acknowledge
    // the request flags: gb_regs's and mbc3_clock's
    input flash_op, load_start, cmd_read, cmd_write, rtc_set_go,
    input wrote_s, wrote_m, wrote_h, wrote_dl, wrote_dh,
    // the ICAP
    output reg icap_clk, icap_ce, icap_write,
    output reg [7:0] icap_i,
    // the I2C pads' tristate enable
    output wr_ec,
    // to the processor
    output reg [7:0] cmd_op,        // port B5
    output reg [1:0] stat_b8,       // port B8
    output reg interrupt,
    // the synchronizers, two stages per flag
    output reg cmd_read_s1, cmd_read_s2, cmd_write_s1, cmd_write_s2,
    output reg load_start_s1, load_start_s2, rtc_set_s1, rtc_set_s2,
    output reg flash_op_s1, flash_op_s2,
    output reg wrote_s_s1, wrote_s_s2, wrote_m_s1, wrote_m_s2, wrote_h_s1, wrote_h_s2,
    output reg wrote_dl_s1, wrote_dl_s2, wrote_dh_s1, wrote_dh_s2
);
    // ---- the port writes
    wire wr_d1 = wr_q & pid_d0_3 & port_id == 2'd1;
    wire wr_d2 = wr_q & pid_d0_3 & port_id == 2'd2;
    assign wr_ec = wr_ec_ef & port_id == 2'd0;

    initial begin
        icap_clk = 1'b0; icap_ce = 1'b0; icap_write = 1'b0; icap_i = 8'd0;
    end
    always @(posedge clk_pb) begin
        if (wr_d1) icap_i <= {out_port[0], out_port[1], out_port[2], out_port[3],
                              out_port[4], out_port[5], out_port[6], out_port[7]};
        if (wr_d2) {icap_write, icap_ce, icap_clk} <= out_port[2:0];
    end

    // ---- the interrupt source
    initial begin
        {cmd_read_s1, cmd_read_s2, cmd_write_s1, cmd_write_s2, load_start_s1, load_start_s2,
         rtc_set_s1, rtc_set_s2, flash_op_s1, flash_op_s2} = 10'd0;
        {wrote_s_s1, wrote_s_s2, wrote_m_s1, wrote_m_s2, wrote_h_s1, wrote_h_s2,
         wrote_dl_s1, wrote_dl_s2, wrote_dh_s1, wrote_dh_s2} = 10'd0;
        cmd_op = 8'd0; stat_b8 = 2'd0; interrupt = 1'b0;
    end
    always @(posedge clk_pb) begin
        {cmd_read_s2, cmd_read_s1} <= {cmd_read_s1, cmd_read};
        {cmd_write_s2, cmd_write_s1} <= {cmd_write_s1, cmd_write};
        {load_start_s2, load_start_s1} <= {load_start_s1, load_start};
        {rtc_set_s2, rtc_set_s1} <= {rtc_set_s1, rtc_set_go};
        {flash_op_s2, flash_op_s1} <= {flash_op_s1, flash_op};
        {wrote_s_s2, wrote_s_s1} <= {wrote_s_s1, wrote_s};
        {wrote_m_s2, wrote_m_s1} <= {wrote_m_s1, wrote_m};
        {wrote_h_s2, wrote_h_s1} <= {wrote_h_s1, wrote_h};
        {wrote_dl_s2, wrote_dl_s1} <= {wrote_dl_s1, wrote_dl};
        {wrote_dh_s2, wrote_dh_s1} <= {wrote_dh_s1, wrote_dh};
    end
    wire [9:0] rise = {cmd_read_s1 & !cmd_read_s2, cmd_write_s1 & !cmd_write_s2,
                       load_start_s1 & !load_start_s2, rtc_set_s1 & !rtc_set_s2,
                       flash_op_s1 & !flash_op_s2, wrote_s_s1 & !wrote_s_s2,
                       wrote_m_s1 & !wrote_m_s2, wrote_h_s1 & !wrote_h_s2,
                       wrote_dh_s1 & !wrote_dh_s2, wrote_dl_s1 & !wrote_dl_s2};
    wire req_any = |rise;
    always @(posedge clk_pb) begin
        if (req_any) {cmd_op, stat_b8} <= rise;
        if (int_ack) interrupt <= 1'b0;
        else if (req_any) interrupt <= 1'b1;
    end
endmodule
