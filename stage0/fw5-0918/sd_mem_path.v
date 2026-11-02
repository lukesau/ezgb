// FW5-0918's memory side of an SD transfer: the FW4 module
// (stage0/rtl/sd_mem_path.v, which says what each part does) with the Game
// Boy side of the address pins built here, in the pin LUTs, where FW4
// takes it ready-made from gb_bus, pb_periph and psram_ctrl (mem_a_gb).
// The differences, read from the design and proved:
//
//   - the MBC3 clock: on the access psram_ctrl sends to U4 page $08 for a
//     clock register, the address pins carry the register number
//     (rtc_sel, from gb_regs) plus $18 on A7-A0, so each register has
//     its own location; A8 and A10 clear, A9 and A13 set. Any other access
//     to neither chip with n_save drives the same on A0-A10 (no chip is
//     selected then)
//   - the SPI flash's lines leave A11/A12 on that clock access
//   - the data pins' force-high (mem_d_ones) is psram_ctrl's address
//     tristate, which in FW5 also covers the clock access
//   - no CLK2X copy of port EF: load_busy_2x is the PicoBlaze-clock
//     register itself
//   - the sector buffer is block RAM X19Y17 (X3Y5 in FW4); its enables
//     are the same
//
// Block: built by scripts/fpga/simblk.py from stage0/blocks/sd_mem_path.blk
// (stage0/fw5-0918/sd_mem_path.sim has its arguments), with the names in
// sd_mem_path.names.

module sd_mem_path (
    input clk_dcm1,
    input clk_sys4,
    // the filler
    input [14:2] wbm_adr_o,
    input wbm_we_o,
    input [31:0] wbm_dat_o,         // the rx FIFO's read port (X3Y1 DOB)
    // the loader
    input [5:0] load_addr,
    input load_busy_2x,             // port EF (the PicoBlaze-clock register; FW5 has no 2x copy)
    // the Game Boy bus and the window registers
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,
    input wr_n,
    input kernel_mode,
    input [3:0] win_mode,           // $7FC0 bits 3:0
    input win_en,                   // $7F30 bit 0
    // the access, from psram_ctrl
    input n_rom, n_save,
    input n_rom_gb,                 // n_rom outside a load
    input u4_win,
    input pg15_gb_b, a13_gb_b, bank0_sel, a13_pass,
    input mem_a13_t,                // n_save & n_rom outside a load
    input mem_d_ones,               // forces the data pins high (psram_ctrl's mem_a_t)
    // the rest of the Game Boy side
    input flash_op,                 // $7FD2 bit 0
    input [7:7] mbc_bank,
    input [7:1] rtc_sel,            // the MBC3 clock register number (gb_regs)
    input adr_pass, a11_pass, a12_pass,     // gb_bus's remap
    input spi_ctrl, spi_mosi,       // pb_periph's SPI flash lines
    input a13_latch,                // the P51 register
    // the buffer's port
    output buf_en,
    output buf_we,
    output win_a000,                // the decode's stages, shared outside
    output win_kernel,
    output win_sel,
    // the pSRAM pins
    output [13:1] mem_a,
    output mem_a13_b,               // mem_a[13] again, on the LUT's net: the P51 register takes it
    output mem_a13_sd,              // the loader's A13 and its inverse, for the page logic
    output mem_a13_sd_n,
    output mem_d0_o, mem_d1_o, mem_d2_o, mem_d3_o, mem_d4_o, mem_d5_o, mem_d6_o, mem_d7_o,
    // the sequencer, for the strobes outside
    output wr_start,
    output reg [3:0] cnt,
    output reg done,
    output reg byte_we_n
);
    // ---- the buffer's window
    assign win_a000 = a13 & !a14;
    assign win_kernel = win_a000 & kernel_mode & a15 & !win_mode[3];
    assign win_sel = win_kernel & !win_mode[0] & !win_mode[2];
    assign buf_en = win_sel & !win_mode[1] & win_en;
    assign buf_we = buf_en & !wr_n;

    // ---- the word and its address, into the memory clock
    reg [14:2] adr_q;
    reg [31:0] dat_q;
    always @(posedge clk_dcm1) begin
        adr_q <= wbm_adr_o;
        dat_q <= wbm_dat_o;
    end

    // ---- the byte sequencer: 16 system-clock cycles from the write's edge
    reg we_q, we_qq;
    reg [7:0] sd_byte;
    always @(posedge clk_sys4) begin
        we_q <= wbm_we_o;
        we_qq <= we_q;
    end
    assign wr_start = we_q & !we_qq;
    always @(posedge clk_sys4 or posedge wr_start)
        if (wr_start) begin
            cnt <= 4'd0;
            done <= 1'b0;
        end else if (!done) begin
            cnt <= cnt + 4'd1;
            done <= cnt == 4'hf;
        end
    initial byte_we_n = 1'b1;
    always @(posedge clk_sys4)
        byte_we_n <= cnt[1] | done;                 // low in the first two cycles of each byte
    always @(posedge clk_sys4)
        if (done) sd_byte <= 8'd0;
        else case (cnt[3:2])                        // top byte first
            2'b00: sd_byte <= dat_q[31:24];
            2'b01: sd_byte <= dat_q[23:16];
            2'b10: sd_byte <= dat_q[15:8];
            2'b11: sd_byte <= dat_q[7:0];
        endcase

    // ---- the Game Boy side of the address pins
    //
    // U9 takes the address one bit up (A0 is its byte select), U4 as it
    // is. On the clock access (n_save outside U9) A1-A7 carry rtc_sel[7:1]
    // + $0C, so with A0 = rtc_sel[0] (psram_ctrl) the pins A7-A0 hold
    // rtc_sel + $18; A9 is set, A8 and A10 clear, and A13 set, in the page
    // psram_ctrl selects ($08)
    wire ld = load_busy_2x;
    wire u4_extra = u4_win & mbc_bank[7];
    wire [7:1] rtc_a = rtc_sel[7:1] + 7'h0c;
    wire [7:1] a_u4 = {a7, a6, a5, a4, a3, a2, a1};
    wire [7:1] a_u9 = {a8, a7, a6, a5, a4, a3, a2};
    wire [13:1] gb_a;
    assign gb_a[7:1] = n_rom ? (n_save ? rtc_a : a_u4) : a_u9;
    assign gb_a[8] = n_rom ? !n_save & a8 : a9;
    assign gb_a[9] = n_rom ? n_save | a9 : a10;
    assign gb_a[10] = n_rom ? !n_save & a10 : adr_pass & a11;
    // A11 and A12 carry the SPI flash's lines in a flash operation, and in
    // any access to neither chip except the clock's
    wire spi_on = flash_op | n_save & !u4_extra;
    assign gb_a[11] = n_rom ? (spi_on ? spi_ctrl : !n_save & a11_pass)
                            : (flash_op ? spi_ctrl : adr_pass & a12);
    assign gb_a[12] = n_rom ? (spi_on ? spi_mosi : !n_save & a12_pass)
                            : (flash_op ? spi_mosi : bank0_sel | a13_pass & a13);
    // A13: on U9 the page's bit 0, on U4 the save page's, else the P51
    // register (the SPI clock in a flash operation), or set for the clock
    assign gb_a[13] = n_rom ? (n_save ? u4_extra | a13_latch : a13_gb_b) : pg15_gb_b;

`ifdef FORMAL
    // Two of psram_ctrl's terms arrive ready-made, from its n_rom and
    // n_save and the load flag; some pin LUTs read them instead. Stated
    // as input assumptions.
    always @* begin
        env_n_rom_gb:   assume (n_rom_gb == (n_rom & !load_busy_2x));
        env_mem_a13_t:  assume (mem_a13_t == (n_save & n_rom & !load_busy_2x));
    end
`endif

    // ---- the pad muxes, SD side
    wire [14:2] sd_a = adr_q | {load_addr, 7'd0};
    assign mem_a = ld ? sd_a[14:2] : gb_a;
    assign mem_a13_b = mem_a[13];
    assign mem_a13_sd = load_busy_2x & sd_a[14];
    assign mem_a13_sd_n = load_busy_2x & !sd_a[14];
    assign mem_d7_o = mem_d_ones | (load_busy_2x ? sd_byte[0] : d0);
    assign mem_d6_o = mem_d_ones | (load_busy_2x ? sd_byte[1] : d1);
    assign mem_d5_o = mem_d_ones | (load_busy_2x ? sd_byte[2] : d2);
    assign mem_d1_o = mem_d_ones | (load_busy_2x ? sd_byte[3] : d3);
    assign mem_d2_o = mem_d_ones | (load_busy_2x ? sd_byte[4] : d4);
    assign mem_d3_o = mem_d_ones | (load_busy_2x ? sd_byte[5] : d5);
    assign mem_d0_o = mem_d_ones | (load_busy_2x ? sd_byte[6] : d6);
    assign mem_d4_o = mem_d_ones | (load_busy_2x ? sd_byte[7] : d7);
endmodule
