// The SD controller's register file: Marek Czerski's sd_controller_wb from
// the OpenCores WISHBONE SD Card Controller (http://opencores.org/project,sd_card_controller),
// as EZ Flash built it. The Wishbone slave that holds the command, its
// argument, the timeouts, block size and count, the interrupt enables, the
// clock divider and the DMA address, and reads them, the responses and the
// interrupt status registers back; writes to the argument and the two
// interrupt status registers raise the pulses that start a command and
// clear the status. Here the Wishbone master is the PicoBlaze: its SD
// ports hold the address, the four data bytes, the strobe and the write
// flag, and this module reads those registers across the clock boundary.
//
// Derived from that source, which is Copyright (C) 2013 Marek Czerski,
// based on original work Copyright (C) 2009 Adam Edvardsson, and licensed
// under the GNU Lesser General Public License version 2.1 or later; this
// file keeps that notice and is under the same license.
//
// Written from the OpenCores source at its 2013 revision (commit 2232a619,
// "data xfer timeout", the one the data host matched), with what the
// synthesis left of it:
//
//   - the registers are written without byte enables and the read mux
//     zero-extends each register and holds on an undecoded address, as
//     that revision does (the 2019 revision clears the output first)
//   - no reset: wb_rst_i is tied off, so block_size_reg's reset value of
//     511 and the others' zeros are gone with it; every register starts
//     at 0
//   - the widths are EZ Flash's: the command timeout is 16 bits, the data
//     timeout 8, the block size 10, the block count 8 (the source's 24,
//     24, 12 and 16)
//   - wb_stb_i here is the source's wb_stb_i & wb_cyc_i, one register on
//     the PicoBlaze side; wb_sel_i is all ones
//   - the voltage register still reads 3300 and the capabilities 0
//   - the source's int_cmd is unused and gone; its int_data (the OR of the
//     data interrupt status and enable) is kept in a register EZ
//     Flash added
//   - the three write pulses go through the top level's sd_edge_detect
//     instances, two registers each: the crossings block names them
//     <pulse>_m[1] (the source's sig_reg[0]) and <pulse>_m[0] (sig_reg[1])
//     and takes the rising edge as [1] & ![0]
//   - wb_adr_i[1:0] and [7] must be zero for any register to decode;
//     which of the two low bits is which cannot be told from the decode
//
// Block: stage0/blocks/sd_controller_wb.blk.

module sd_controller_wb (
    input clk_mode,
    input wb_stb_i,                     // wb_stb_i & wb_cyc_i
    input wb_we_i,
    input [7:0] wb_adr_i,
    input [31:0] wb_dat_i,
    input [31:0] response_0_m,          // from the crossings block
    input [31:0] response_1_m,
    input [31:0] response_2_m,
    input [31:8] response_3_m,          // the low byte is the constant zeros the command master appends
    input [4:0] cmd_int_status_m,
    input [4:0] data_int_status_m,
    output reg [31:0] wb_dat_o,
    output reg wb_ack_o,
    output reg [31:0] argument_m,       // the registers, for the crossings block
    output reg [13:0] command_m,
    output reg soft_rst_m,              // software_reset_reg
    output reg [15:0] cmd_timeout_m,
    output reg [7:0] data_timeout_m,
    output reg [9:0] blksize_m,
    output reg bus_4bit_m,              // controll_setting_reg
    output reg [4:0] cmd_int_enable_m,
    output reg [7:0] clock_divider_m,   // the clock divider's divider_reg
    output reg [4:0] data_int_enable_m,
    output reg [7:0] blkcnt_m,
    output reg [31:0] dma_addr_m,       // [1:0] cross as the byte alignment; the rest is the FIFO filler's
    output reg [1:0] cmd_start_m,       // the edge detects' registers
    output reg [1:0] cmd_int_rst_m,
    output reg [1:0] data_int_rst_m,
    output reg int_data
);
    localparam [7:0] ARGUMENT = 8'h00, COMMAND = 8'h04, RESP0 = 8'h08, RESP1 = 8'h0c, RESP2 = 8'h10, RESP3 = 8'h14,
                     DATA_TIMEOUT = 8'h18, CONTROLLER = 8'h1c, CMD_TIMEOUT = 8'h20, CLOCK_D = 8'h24, RESET = 8'h28,
                     VOLTAGE = 8'h2c, CAPA = 8'h30, CMD_ISR = 8'h34, CMD_ISER = 8'h38, DATA_ISR = 8'h3c, DATA_ISER = 8'h40,
                     BLKSIZE = 8'h44, BLKCNT = 8'h48, DST_SRC_ADDR = 8'h60;
    localparam [31:0] VOLTAGE_CONTROLL_REG = 32'd3300;      // SUPPLY_VOLTAGE_mV
    localparam [15:0] CAPABILIES_REG = 16'd0;

    reg cmd_start, data_int_rst, cmd_int_rst;

    // ---- the registers and the pulses
    always @(posedge clk_mode) begin
        cmd_start <= 1'b0;
        data_int_rst <= 1'b0;
        cmd_int_rst <= 1'b0;
        if (wb_stb_i | wb_ack_o) begin
            if (wb_we_i)
                case (wb_adr_i)
                    ARGUMENT: begin
                        argument_m <= wb_dat_i;
                        cmd_start <= 1'b1;
                    end
                    COMMAND:      command_m <= wb_dat_i[13:0];
                    RESET:        soft_rst_m <= wb_dat_i[0];
                    CMD_TIMEOUT:  cmd_timeout_m <= wb_dat_i[15:0];
                    DATA_TIMEOUT: data_timeout_m <= wb_dat_i[7:0];
                    BLKSIZE:      blksize_m <= wb_dat_i[9:0];
                    CONTROLLER:   bus_4bit_m <= wb_dat_i[0];
                    CMD_ISER:     cmd_int_enable_m <= wb_dat_i[4:0];
                    CMD_ISR:      cmd_int_rst <= 1'b1;
                    CLOCK_D:      clock_divider_m <= wb_dat_i[7:0];
                    DATA_ISR:     data_int_rst <= 1'b1;
                    DATA_ISER:    data_int_enable_m <= wb_dat_i[4:0];
                    DST_SRC_ADDR: dma_addr_m <= wb_dat_i;
                    BLKCNT:       blkcnt_m <= wb_dat_i[7:0];
                    default: ;
                endcase
            wb_ack_o <= wb_stb_i & ~wb_ack_o;
        end
    end

    // ---- the read mux: each register zero-extended, and no default
    always @(posedge clk_mode)
        if (wb_stb_i)
            case (wb_adr_i)
                ARGUMENT:     wb_dat_o <= argument_m;
                COMMAND:      wb_dat_o <= {18'd0, command_m};
                RESP0:        wb_dat_o <= response_0_m;
                RESP1:        wb_dat_o <= response_1_m;
                RESP2:        wb_dat_o <= response_2_m;
                RESP3:        wb_dat_o <= {response_3_m, 8'd0};
                CONTROLLER:   wb_dat_o <= {31'd0, bus_4bit_m};
                BLKSIZE:      wb_dat_o <= {22'd0, blksize_m};
                VOLTAGE:      wb_dat_o <= VOLTAGE_CONTROLL_REG;
                RESET:        wb_dat_o <= {31'd0, soft_rst_m};
                CMD_TIMEOUT:  wb_dat_o <= {16'd0, cmd_timeout_m};
                DATA_TIMEOUT: wb_dat_o <= {24'd0, data_timeout_m};
                CMD_ISR:      wb_dat_o <= {27'd0, cmd_int_status_m};
                CMD_ISER:     wb_dat_o <= {27'd0, cmd_int_enable_m};
                CLOCK_D:      wb_dat_o <= {24'd0, clock_divider_m};
                CAPA:         wb_dat_o <= {16'd0, CAPABILIES_REG};
                DATA_ISR:     wb_dat_o <= {27'd0, data_int_status_m};
                BLKCNT:       wb_dat_o <= {24'd0, blkcnt_m};
                DATA_ISER:    wb_dat_o <= {27'd0, data_int_enable_m};
                DST_SRC_ADDR: wb_dat_o <= dma_addr_m;
                default: ;
            endcase

    // ---- the top level's edge detects (sd_edge_detect: sig_reg <= {sig_reg[0], sig})
    always @(posedge clk_mode) begin
        cmd_start_m <= {cmd_start, cmd_start_m[1]};
        cmd_int_rst_m <= {cmd_int_rst, cmd_int_rst_m[1]};
        data_int_rst_m <= {data_int_rst, data_int_rst_m[1]};
    end

    // ---- the data interrupt, registered (the source's is combinational)
    always @(posedge clk_mode)
        int_data <= |(data_int_status_m & data_int_enable_m);
endmodule
