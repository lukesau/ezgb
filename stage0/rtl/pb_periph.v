// The PicoBlaze's peripherals outside its ports block, written by EZ Flash.
// Four things, in two clock domains:
//
//   - the ICAP writes, on the processor clock: OUTPUT to D1 loads the
//     port's eight data bits, OUTPUT to D2 its clock (bit 0), CE (bit 1)
//     and WRITE (bit 2). Each is a register wired straight to the
//     Spartan-3A ICAP primitive, so bank 2 bit-bangs the configuration
//     port the way it bit-bangs the SPI flash: the MultiBoot hand-over
//     from slot A to slot B (re/stage0/docs/picoblaze.md). The data goes
//     in bit-reversed, out_port bit 7 on I[0], as the readback on D1
//     comes out (the port's bit order is the configuration stream's)
//   - the I2C output enable, on the processor clock: an OUTPUT to EC
//     (wr_ec) clocks out_port bits 0 and 1 into the SCL and SDA pads'
//     tristate flip-flops, which live in the IO tiles (P31, P32; the
//     pads drive 0 when enabled, so the lines are open drain). The tiles
//     are outside the proof; this block makes the enable
//   - the SPI flash's clock and MOSI, combinational: the flash shares
//     the pSRAM's address pins (SCK on A11, P53; MOSI on A12, P46), and
//     these two pins carry the port bits whenever the flash operation
//     bit is set ($7FD2, flash_op) and whenever neither pSRAM is
//     selected, the address otherwise. The address is the word address
//     for U9 (byte bit 12 on A11, A13 or the bank's bit 0 on A12) and the
//     byte address for U4 (bits 11 and 12, after the window remap), the
//     same split the lower pins make elsewhere
//   - the interrupt source, on the 2x clock: five request flags the
//     Game Boy writes (gb_regs: sector read and write at $7FB4, the ROM
//     load at $7F36, the RTC set at $7FD0, the flash operation at $7FD2)
//     are synchronized two stages deep, and a rising edge of any of them
//     sets the interrupt and loads the command bits the firmware reads at
//     port B5, one per flag (bit 7 read, 6 write, 5 load, 4 RTC set, 3
//     flash). The processor's acknowledge clears the interrupt, a
//     synchronous reset that wins over a request in the same cycle
//
// The Device DNA port has no logic of its own: the primitive's CLK,
// SHIFT, READ and DIN are the ports block's dna_ctrl bits 0-3 and its
// DOUT goes back to the in_port mux (port D3).
//
// Block: stage0/blocks/pb_periph.blk.

module pb_periph (
    input clk_pb,
    input clk_2x,
    // the processor and its ports block
    input [4:0] port_id,            // bits 0, 1 and 4; the rest arrive decoded
    input [7:0] out_port,
    input wr_q,                     // write_strobe, one cycle later
    input wr_ec_ef,                 // a write to EC-EF
    input pid_cd_lo,                // port_id in C0-C3 or D0-D3 (a decode in picoblaze_ports)
    input pid_cd_2_3,               // and bit 1 set: C2, C3, D2 or D3
    input pid_lo_01,                // port_id[1:0] == 01
    input int_ack,                  // the core's interrupt acknowledge
    input spi_ctrl,                 // port D4 bit 0: SCK
    input spi_mosi,                 // port D5 bit 7
    // the request flags (gb_regs)
    input flash_op, load_start, cmd_read, cmd_write, rtc_set_go,
    // the address pins' other sources
    input n_rom,                    // not a U9 access (psram_ctrl)
    input n_save,                   // not a U4 access
    input bank0_sel, a13_sel,       // U9's A12: the bank's bit 0 or A13
    input a12,
    input adr_pass,                 // no window remaps the address (the 2x bus state)
    input a12_pass, a11_pass,       // a12 and a11 through the remap
    // the ICAP
    output reg icap_clk, icap_ce, icap_write,
    output reg [7:0] icap_i,
    // the I2C pads' tristate enable
    output wr_ec,
    // to the processor
    output reg [7:3] cmd_op_i,
    output reg interrupt,
    // the address pins
    output [12:11] mem_a_gb
);
    // ---- the port writes
    wire wr_dx = wr_q & port_id[4] & pid_cd_lo;                 // D0-D3
    wire wr_d1 = wr_dx & pid_lo_01;
    wire wr_d2 = wr_dx & port_id[1] & !port_id[0];
    assign wr_ec = wr_ec_ef & !port_id[1] & !port_id[0];

    initial begin
        icap_clk = 1'b0; icap_ce = 1'b0; icap_write = 1'b0; icap_i = 8'd0;
    end
    always @(posedge clk_pb) begin
        if (wr_d1) icap_i <= {out_port[0], out_port[1], out_port[2], out_port[3],
                              out_port[4], out_port[5], out_port[6], out_port[7]};
        if (wr_d2) {icap_write, icap_ce, icap_clk} <= out_port[2:0];
    end

    // ---- the SPI flash on the address pins
    wire spi_on_u4 = flash_op | n_save;                         // in a non-ROM access: unless U4 is selected
    assign mem_a_gb[11] = n_rom ? (spi_on_u4 ? spi_ctrl : a11_pass)
                                : (flash_op ? spi_ctrl : a12_pass);
    assign mem_a_gb[12] = n_rom ? (spi_on_u4 ? spi_mosi : a12_pass)
                                : (flash_op ? spi_mosi : bank0_sel | a13_sel);

    // ---- the interrupt source
    reg load_start_s1, load_start_s2, flash_op_s1, flash_op_s2, cmd_write_s1, cmd_write_s2,
        cmd_read_s1, cmd_read_s2, rtc_set_s1, rtc_set_s2;
    initial begin
        {load_start_s1, load_start_s2, flash_op_s1, flash_op_s2, cmd_write_s1, cmd_write_s2,
         cmd_read_s1, cmd_read_s2, rtc_set_s1, rtc_set_s2} = 10'd0;
        cmd_op_i = 5'd0; interrupt = 1'b0;
    end
    always @(posedge clk_2x) begin
        {load_start_s2, load_start_s1} <= {load_start_s1, load_start};
        {flash_op_s2, flash_op_s1} <= {flash_op_s1, flash_op};
        {cmd_write_s2, cmd_write_s1} <= {cmd_write_s1, cmd_write};
        {cmd_read_s2, cmd_read_s1} <= {cmd_read_s1, cmd_read};
        {rtc_set_s2, rtc_set_s1} <= {rtc_set_s1, rtc_set_go};
    end
    wire load_rise = load_start_s1 & !load_start_s2;
    wire flash_rise = flash_op_s1 & !flash_op_s2;
    wire write_rise = cmd_write_s1 & !cmd_write_s2;
    wire read_rise = cmd_read_s1 & !cmd_read_s2;
    wire rtc_rise = rtc_set_s1 & !rtc_set_s2;
    wire req_any = read_rise | write_rise | load_rise | rtc_rise | flash_rise;
    always @(posedge clk_2x) begin
        if (req_any) cmd_op_i <= {read_rise, write_rise, load_rise, rtc_rise, flash_rise};
        if (int_ack) interrupt <= 1'b0;
        else if (req_any) interrupt <= 1'b1;
    end

`ifdef FORMAL
    // The decodes arrive from picoblaze_ports, where they are made from
    // the same port_id; the remapped a12 comes from the 2x bus state. Stated
    // as input assumptions.
    always @* begin
        env_pid_cd_2_3: assume (pid_cd_2_3 == (pid_cd_lo & port_id[1]));
        env_pid_lo_01:  assume (pid_lo_01 == (port_id[0] & !port_id[1]));
        env_a12_pass:   assume (a12_pass == (a12 & adr_pass));
    end
`endif
endmodule
