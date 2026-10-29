// The PicoBlaze's ports, EZ Flash's own: what its OUTPUT instructions write
// and its INPUT instructions read, and the bridge between it and the SD
// controller's Wishbone register file. The firmware's port map is in
// re/stage0/docs/picoblaze.md; the port numbers below are its.
//
// Writes (wr_q is write_strobe one cycle later, when port_id and out_port
// still hold):
//
//   70-73  the SD data word, a byte each (SDC_D0-3)
//   BF     the ROM loader's table index, 7 bits: block RAM X3Y21's read
//          address, whose other port the Game Boy writes
//   C8     the program bank bit
//   D3     the Device DNA port's control bits
//   D4/D5  the SPI flash's control bit (starts at 1) and MOSI
//   E0/E1  the loader's destination address, staged; E3 commits the 14
//          bits as one (E2 is unused)
//   ED/EE  RTC register index and value, out to the register file side
//   EF/F1  the loader's and the flash writer's busy flags
//   F0     the RTC set index
//
// Reads (in_port is clocked on the falling edge, as the core's input
// registers are):
//
//   70-73  the SD read data, captured from the register file
//   B0-B3  the sector address the kernel wrote (registers in the Game Boy
//          write domain), B4 the data bus input registers (the count),
//          B5 the command bits 7:3, B6 the RTC set data
//   B9     reads 1: the RTC refresh runs always
//   C0-C3  the table word at the index (C0 the top byte)
//   D1     the ICAP output, bit-reversed; D3 the DNA bit; D4 MISO in bit
//          7; EB the I2C lines (SCL bit 0, SDA bit 1)
//   A0, B7 read 0; every other port holds the last value
//
// The bridge: INPUT from a port below A0 selects that controller register
// and starts a Wishbone read of it; OUTPUT to 70 starts a write, and the
// OUTPUT that follows it, OUTPUT sD, (sE) in the firmware, names the
// register. Reading the selected register's port again returns the done
// flag in bits 1:0 (the ack the firmware polls for), and reading 70 after
// a read releases the captured data for the next one. The strobe is set
// whenever the address is loaded and held until the controller
// acknowledges.
//
// Block: stage0/blocks/picoblaze_ports.blk.

module picoblaze_ports (
    input clk_pb,
    input dcm_locked,
    // the core
    input [7:0] port_id,
    input [7:0] out_port,
    input read_strobe,
    input write_strobe,
    // the SD register file (sd_controller_wb)
    input [31:0] wb_dat_o,
    input wb_ack_o,
    // the other read sources
    input [7:0] cmd_lba0_i,         // the kernel's $7FB0..B3, in the Game Boy write domain
    input [7:0] cmd_lba1_i,
    input [7:0] cmd_lba2_i,
    input [7:0] cmd_lba3_i,
    input d0_q, d1_q, d2_q, d3_q, d4_q, d5_q, d6_q,   // the data bus pads' input registers
    input [7:3] cmd_op_i,           // the command bits, 2x domain
    input [7:0] rtc_set_data_i,
    input [31:0] tbl_q,             // block RAM X3Y21, port B
    input [7:0] icap_o,
    input dna_dout,
    input flash_miso,
    input i2c_scl_in,
    input i2c_sda_in,
    // to the core
    output reg reset,
    output reg [7:0] in_port,
    output reg bank,
    // to the SD register file
    output reg [31:0] wb_dat_i,
    output reg [7:0] wb_adr_i,
    output reg wb_stb_i,            // wb_stb_i & wb_cyc_i in one
    output reg wb_we_i,
    // the loader and the peripherals
    output reg [13:0] load_addr,
    output reg [6:0] tbl_index,
    output reg [3:0] dna_ctrl,
    output reg spi_ctrl,
    output reg spi_mosi,
    output reg [3:0] rtc_reg_index,
    output reg [7:0] rtc_reg_value,
    output reg load_busy,
    output reg [3:0] rtc_set_index,
    output reg flash_busy,
    output wr_d4,                   // the write to D4, for the SPI flash's clock outside the block
    output wr_ec_ef,                // a write to EC-EF, for the I2C output enable in pb_periph
    output pid_cd_lo,               // port_id in C0-C3 or D0-D3, pid_cd_2_3 with bit 1 set, pid_lo_01 bits 1:0 == 01:
    output pid_cd_2_3,              //   the decodes pb_periph's ICAP writes (D1, D2) share
    output pid_lo_01,
    output reg wr_q,                // write_strobe one cycle later, the peripherals' write timing
    output gnd                      // a constant-0 LUT the block RAM X3Y1 and two pads share
);
    assign gnd = 1'b0;

    // ---- the reset: released two cycles after the DCM locks
    reg reset_s1;
    initial begin reset_s1 = 1'b1; reset = 1'b1; end
    always @(posedge clk_pb) begin
        reset_s1 <= !dcm_locked ? 1'b1 : gnd;
        reset <= !dcm_locked ? 1'b1 : reset_s1;
    end

    // ---- the strobes, one cycle later
    reg rd_q;
    always @(posedge clk_pb) begin
        rd_q <= read_strobe;
        wr_q <= write_strobe;
    end

    assign wr_d4 = wr_q & (port_id == 8'hd4);
    assign wr_ec_ef = wr_q & (port_id[7:2] == 6'b111011);
    assign pid_cd_lo = port_id[7] & port_id[6] & !port_id[5] & !port_id[3] & !port_id[2];
    assign pid_cd_2_3 = pid_cd_lo & port_id[1];
    assign pid_lo_01 = port_id[0] & !port_id[1];

    // ---- the port registers
    reg [7:0] load_addr_lo;
    reg [5:0] load_addr_hi;
    initial spi_ctrl = 1'b1;
    always @(posedge clk_pb)
        if (wr_q)
            case (port_id)
                8'h70: wb_dat_i[7:0] <= out_port;
                8'h71: wb_dat_i[15:8] <= out_port;
                8'h72: wb_dat_i[23:16] <= out_port;
                8'h73: wb_dat_i[31:24] <= out_port;
                8'hbf: tbl_index <= out_port[6:0];
                8'hc8: bank <= out_port[0];
                8'hd3: dna_ctrl <= out_port[3:0];
                8'hd4: spi_ctrl <= out_port[0];
                8'hd5: spi_mosi <= out_port[7];
                8'he0: load_addr_lo <= out_port;
                8'he1: load_addr_hi <= out_port[5:0];
                8'he3: load_addr <= {load_addr_hi, load_addr_lo};
                8'hed: rtc_reg_index <= out_port[3:0];
                8'hee: rtc_reg_value <= out_port;
                8'hef: load_busy <= out_port[0];
                8'hf0: rtc_set_index <= out_port[3:0];
                8'hf1: flash_busy <= out_port[0];
                default: ;
            endcase

    // ---- the bridge to the register file
    reg sd_rd_flag;                 // a register read is selected (INPUT from a port below A0)
    reg sd_cycle;                   // a Wishbone cycle runs
    reg sd_done;                    // the read was acknowledged: what the poll reads
    reg sd_q_hold;                  // the captured data is being read out, until port 70 is read
    reg [31:0] sd_q;                // the captured read data
    wire sd_port = !port_id[7] | (!port_id[6] & !port_id[5]);     // 00-9F
    wire p7x = port_id[7:2] == 6'b011100;                          // 70-73
    wire p70 = p7x & (port_id[1:0] == 2'b00);
    wire rd_sd = rd_q & sd_port;
    wire wr70 = wr_q & p70;
    wire rd_flag_hold = sd_cycle ? (sd_rd_flag | wr_q)
                                 : (sd_rd_flag & (!rd_q | (!sd_q_hold & !wb_we_i)));
    wire adr_load = !sd_rd_flag & ((rd_sd & !sd_cycle & !wr70) | (sd_cycle & wr_q));
    wire sd_busy = sd_cycle | sd_rd_flag | rd_sd | wr70;
    always @(posedge clk_pb) begin
        sd_rd_flag <= rd_flag_hold | (sd_q_hold & !(rd_q & p70))
                    | (!sd_rd_flag & rd_sd & !sd_cycle & !wr70);
        sd_cycle <= (!sd_rd_flag & (rd_sd | wr70)) | (sd_cycle & (!wb_ack_o | !sd_rd_flag));
        sd_done <= (sd_done & sd_busy) | (wb_ack_o & sd_cycle & sd_rd_flag);
        sd_q_hold <= sd_q_hold ? !(rd_q & p70) : (rd_q & sd_rd_flag & !sd_cycle & !wb_we_i);
        wb_we_i <= (wb_we_i & sd_busy) | (sd_cycle & !sd_rd_flag & wr_q);
        if (adr_load) wb_adr_i <= port_id;
        wb_stb_i <= adr_load | (sd_cycle ? (wb_stb_i & (!wb_ack_o | !sd_rd_flag))
                                         : (wb_stb_i & (sd_rd_flag | wr70)));
        if (sd_cycle & sd_rd_flag & wb_ack_o & !sd_q_hold) sd_q <= wb_dat_o;
    end

    // ---- the in_port mux, on the falling edge
    always @(negedge clk_pb)
        if (port_id == wb_adr_i) in_port <= {6'd0, sd_done, sd_done};
        else case (port_id)
            8'h70: in_port <= sd_q[7:0];
            8'h71: in_port <= sd_q[15:8];
            8'h72: in_port <= sd_q[23:16];
            8'h73: in_port <= sd_q[31:24];
            8'ha0, 8'hb7: in_port <= 8'd0;
            8'hb0: in_port <= cmd_lba0_i;
            8'hb1: in_port <= cmd_lba1_i;
            8'hb2: in_port <= cmd_lba2_i;
            8'hb3: in_port <= cmd_lba3_i;
            8'hb4: in_port <= {1'b0, d6_q, d5_q, d4_q, d3_q, d2_q, d1_q, d0_q};
            8'hb5: in_port <= {cmd_op_i[7:3], 3'd0};
            8'hb6: in_port <= rtc_set_data_i;
            8'hb9: in_port <= 8'h01;
            8'hc0: in_port <= tbl_q[31:24];
            8'hc1: in_port <= tbl_q[23:16];
            8'hc2: in_port <= tbl_q[15:8];
            8'hc3: in_port <= tbl_q[7:0];
            8'hd1: in_port <= {icap_o[0], icap_o[1], icap_o[2], icap_o[3], icap_o[4], icap_o[5], icap_o[6], icap_o[7]};
            8'hd3: in_port <= {7'd0, dna_dout};
            8'hd4: in_port <= {flash_miso, 7'd0};
            8'heb: in_port <= {6'd0, i2c_sda_in, i2c_scl_in};
            default: ;
        endcase
endmodule
