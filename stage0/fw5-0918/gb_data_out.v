// FW5-0918's Game Boy data bus output: the FW4 module (stage0/rtl/
// gb_data_out.v, which says what each read returns) with these differences,
// read from the design and proved:
//
//   - the game's MBC3 clock reads come from latched copies: with rtc_sel
//     $08-$0C a read returns the latched S, M, H, DL or DH (lat_*, five
//     registers on /WR loaded together by the latch, $01 written to
//     $6000-$7FFF while the $6000 register holds $00); FW4 converts the
//     live PCF8563 BCD and serves DH as a constant 1
//   - $7FC0 = 4 reads $05 (FW4 $04)
//   - the kernel window ($A008-$A00E) reads the RTC bridge's registers,
//     which keep only the bits the BCD values use (seconds and minutes 7,
//     hours and day 6, weekday 3, month 5, year 8)
//   - a register-window read that is not one of those returns 0 (FW4: $FF)
//   - the header checksum's bit 7 is a register written with $7FC3 (FW4:
//     the D7 pad's input register)
//
// psram_ctrl also selects U4 page $08 on the game's clock accesses, so a
// write lands there for the PicoBlaze; the read is the FPGA's.
//
// Block: built by stage0/tools/simblk.py from stage0/blocks/gb_data_out.blk
// (stage0/fw5-0918/gb_data_out.sim has its arguments), with the names in
// gb_data_out.names.

module gb_data_out (
    input a0, a1, a2, a4, a13, a14, a15,
    input wr_n,
    input mem_d0, mem_d1, mem_d2, mem_d3, mem_d4, mem_d5, mem_d6, mem_d7,
    input kernel_mode,
    input a13_gb_q,                 // the controller's page bits, 2x-domain copies
    input adr_014d,                 // the address is $x14D (psram_ctrl)
    input bank_hi_ones, bank_lo_ones,   // the game-mode bank register is all ones
    input a12_pass_q, a11_pass_q,   // a12 and a11 after the window remap, registered (gb_bus)
    input boot_q_x19y13, boot_q_x19y21, boot_q_x19y25, boot_q_x19y29, boot_q_x19y5, boot_q_x19y9, boot_q_x3y13, boot_q_x3y17,
    input [7:0] brom_q,             // block RAM X19Y17
    input buf_en,                   // the sector buffer window (sd_mem_path)
    input [7:0] buf_q,              // the sector buffer
    input cmd_b4_flag,              // cleared by the $7FB4 write, set by the data interrupt
    input flash_busy,               // port F1
    input [6:0] hdr_chk,            // $7FC3 bits 6:0
    input hdr_chk7,                 // $7FC3 bit 7
    input kernel_b3_lo,             // kernel mode, $7F32 bit 3, below $8000
    input load_busy_2x,             // port EF
    input [8:8] mbc_bank,           // the RAM enable
    input pg15_gb_q,
    input [6:0] rtc_sec, rtc_min,   // the RTC bridge's registers
    input [5:0] rtc_hour, rtc_day,
    input [2:0] rtc_wday,
    input [4:0] rtc_month,
    input [7:0] rtc_year,
    input [7:0] lat_sec, lat_min, lat_hour, lat_dl, lat_dh,     // the MBC3 latched clock
    input [7:0] rtc_sel,            // the MBC3 clock register select
    input win_en, win_en1,          // $7F30 bits 0 and 1
    input win_kernel,               // the window decode (sd_mem_path)
    input [3:0] win_mode,           // $7FC0 bits 3:0
    input win_a000,                 // a13 & !a14 (sd_mem_path)
    // shared decodes (gb_regs, unlock)
    input rtc_win,                  // the register window's offsets $x8-$xF, kernel mode
    input a210_any, a2_n1, a210_4, a210_6, a0_n1,
    output d0_o, d1_o, d2_o, d3_o, d4_o, d5_o, d6_o, d7_o,
    output d_t,                     // the bus's tristate
    output reg_dec                  // the register window
);
    assign d_t = !wr_n | a14 & !a13 & a15;

    // ---- where the read is
    wire a000 = a15 & win_a000;
    wire reg_dec_k = a000 & win_mode[3] | a000 & win_mode[1] & win_mode[2];
    wire reg_dec_g = mbc_bank[8] & bank_lo_ones & a000 & bank_hi_ones;
    assign reg_dec = kernel_mode ? reg_dec_k : reg_dec_g;
    wire win4 = win_kernel & (win_mode == 4'b0100);
    wire win5 = win_kernel & (win_mode == 4'b0101);
    wire chk_rd = !kernel_mode & adr_014d & !a15;
    wire brom_sel = pg15_gb_q & !a12_pass_q & !a11_pass_q & !a13_gb_q;

    // ---- the bytes
    wire [7:0] boot_planes = {boot_q_x19y29, boot_q_x19y9, boot_q_x19y13, boot_q_x3y17, boot_q_x3y13, boot_q_x19y25, boot_q_x19y21, boot_q_x19y5};
    wire [7:0] boot_byte = ({8{brom_sel}} & brom_q) | ({8{!pg15_gb_q}} & boot_planes);
    wire [7:0] mem_byte = {mem_d4, mem_d0, mem_d3, mem_d2, mem_d1, mem_d5, mem_d6, mem_d7};
    wire [7:0] chk_byte = {hdr_chk7, hdr_chk};
    wire [7:0] mem_or_chk = chk_rd ? chk_byte : mem_byte;
    wire [7:0] status = !cmd_b4_flag ? 8'he1 : win_en1 ? 8'h01 : buf_q;

    // the kernel window: the seven readings at offsets $x8-$xE
    reg [7:0] rtc_k;
    always @* case ({a2, a1, a0})
        3'd0: rtc_k = {1'b0, rtc_sec};
        3'd1: rtc_k = {1'b0, rtc_min};
        3'd2: rtc_k = {2'b0, rtc_hour};
        3'd3: rtc_k = {2'b0, rtc_day};
        3'd4: rtc_k = {5'b0, rtc_wday};
        3'd5: rtc_k = {3'b0, rtc_month};
        3'd6: rtc_k = rtc_year;
        default: rtc_k = 8'h00;
    endcase
    // the game's MBC3 clock registers, latched
    reg [7:0] rtc_g;
    always @* case (rtc_sel)
        8'h08: rtc_g = lat_sec;
        8'h09: rtc_g = lat_min;
        8'h0a: rtc_g = lat_hour;
        8'h0b: rtc_g = lat_dl;
        8'h0c: rtc_g = lat_dh;
        default: rtc_g = 8'h00;
    endcase
    wire [7:0] reg_byte = kernel_mode ? (rtc_win & !a4 ? rtc_k : 8'h00) : rtc_g;

    // ---- the mux
    wire [7:0] d_o = load_busy_2x ? 8'h01
                   : buf_en       ? status
                   : kernel_b3_lo ? boot_byte
                   : win4         ? 8'h05
                   : win5         ? {7'd0, flash_busy}
                   : reg_dec      ? reg_byte
                   :                mem_or_chk;
    assign {d7_o, d6_o, d5_o, d4_o, d3_o, d2_o, d1_o, d0_o} = d_o;

`ifdef FORMAL
    // The window decode and the shared address decodes arrive from the
    // blocks that make them, from the same address and mode bits; stated
    // as input assumptions.
    always @* begin
        env_win_a000:   assume (win_a000 == (a13 & !a14));
        env_win_kernel: assume (win_kernel == (kernel_mode & a13 & !a14 & a15 & !win_mode[3]));
        env_buf_en:     assume (buf_en == (win_kernel & !win_mode[0] & !win_mode[2] & !win_mode[1] & win_en));
        env_a210_any:   assume (a210_any == (a2 | a1 | a0));
        env_a2_n1:      assume (a2_n1 == (a2 | !a1));
        env_a210_4:     assume (a210_4 == ({a2, a1, a0} == 3'd4));
        env_a210_6:     assume (a210_6 == ({a2, a1, a0} == 3'd6));
        env_a0_n1:      assume (a0_n1 == (a0 & !a1));
        // psram_ctrl's kernel_b3_lo is kernel_mode & !a15 & mode32_b3
        env_kernel_b3:  assume (!kernel_b3_lo | kernel_mode & !a15);
        // gb_regs' rtc_win is the register window's $x8-$xF in kernel mode
        env_rtc_win:    assume (!rtc_win | kernel_mode & reg_dec);
    end
`endif
endmodule
