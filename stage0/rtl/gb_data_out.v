// The Game Boy data bus output, EZ Flash's own: what the console reads
// back on D0-D7 and when the FPGA drives them. Combinational only.
//
// What the equations show:
//
//   - the bus is driven whenever /WR is high, except at $C000-$DFFF (d_t)
//   - the sector buffer (X3Y5, buf_q) reads through its window (buf_en),
//     gated by the $7FB4 flag (cmd_b4_flag) and $7F30 bit 1 (win_en1);
//     d0 reads 1 while the loader runs (load_busy_2x), the status the
//     kernel polls
//   - in kernel mode with $7F32 bit 3 set, $0000-$7FFF reads the stage1
//     program from block RAM bit planes (boot_q_*, one bit each) or, one
//     page up (brom_sel), bytes from block RAM X19Y17 (brom_q)
//   - the $7Fxx registers read back (reg_dec, reg_rd): the header
//     checksum ($7FC3, hdr_chk) in place of the pSRAM's byte at $014D in
//     game mode (chk_rd), the pSRAM's data pins (mem_d*) otherwise
//   - the seven RTC values the PicoBlaze sends (rtc_v0..6, 2x-domain
//     copies of its port EE writes) read back selected by the low
//     address bits in kernel mode and, in game mode, by the MBC3 RTC
//     register select (rtc_sel, the value written to $4000) through a
//     small adder chain (the carry cells at X24Y20-21)
//
// This is a transcription of the carved logic with the ports and the
// main decode terms named; the body's t_* wires are the LUTs as placed.
// It proves equivalent, and is readable at its boundary rather than
// in its body: the next pass should fold the RTC read path into a case.
//
// Block: stage0/blocks/gb_data_out.blk.

module gb_data_out (
    input a0,
    input a1,
    input a2,
    input a6,
    input a13,
    input a14,
    input a15,
    input d7_q,
    input wr_n,
    input mem_d0,
    input mem_d1,
    input mem_d2,
    input mem_d3,
    input mem_d4,
    input mem_d5,
    input mem_d6,
    input mem_d7,
    input kernel_mode,
    input a13_gb_q,
    input adr_014d,
    input adr_014d_lo,
    input bank_hi_ones,
    input bank_lo_ones,
    input bank_q_a,
    input bank_q_b,
    input boot_q_x19y13,
    input boot_q_x19y21,
    input boot_q_x19y25,
    input boot_q_x19y29,
    input boot_q_x19y5,
    input boot_q_x19y9,
    input boot_q_x3y13,
    input boot_q_x3y17,
    input [7:0] brom_q,
    input buf_en,
    input [7:0] buf_q,
    input cmd_b4_flag,
    input flash_busy,
    input [7:0] rtc_sel,
    input [6:0] hdr_chk,
    input kernel_b3_lo,
    input load_busy_2x,
    input [8:8] mbc_bank,
    input pg15_gb_q,
    input [7:0] rtc_v0,
    input [7:0] rtc_v1,
    input [7:0] rtc_v2,
    input [7:0] rtc_v3,
    input [7:0] rtc_v4,
    input [7:0] rtc_v5,
    input [7:0] rtc_v6,
    input win_en,
    input win_en1,
    input win_kernel,
    input [3:0] win_mode,
    input win_sel,
    output d0_o,
    output d1_o,
    output d2_o,
    output d3_o,
    output d4_o,
    output d5_o,
    output d6_o,
    output d7_o,
    output d_t,
    output reg_dec,
    output gnd2,
    output dec_x23y21_s1,
    output a1a0_zero
);
    wire t_x2y13_s0_g;
    wire t_x7y9_s0_g;
    wire t_x7y10_s3_g;
    wire t_x7y24_s3_g;
    wire t_x8y11_s0_f;
    wire buf_rd;
    wire t_x8y12_s2_f;
    wire t_x8y15_s3_g;
    wire t_x9y15_s1_g;
    wire t_x9y19_s0_g;
    wire a000;
    wire t_x11y14_s3_g;
    wire t_x11y17_s1_g;
    wire t_x11y17_s2_g;
    wire boot_rd;
    wire t_x12y12_s3_g;
    wire win5;
    wire win4;
    wire reg_rd;
    wire t_x13y16_s0_g;
    wire t_x14y19_s2_f;
    wire t_x14y19_s2_g;
    wire reg_dec_k;
    wire reg_dec_g;
    wire t_x15y18_s2_f;
    wire brom_sel;
    wire t_x17y4_s2_f;
    wire t_x17y4_s2_g;
    wire t_x17y18_s0_f;
    wire t_x17y18_s0_g;
    wire t_x18y1_s0_f;
    wire t_x18y1_s0_g;
    wire t_x18y1_s2_f;
    wire t_x18y1_s2_g;
    wire t_x18y13_s0_f;
    wire t_x18y13_s0_g;
    wire t_x18y13_s3_f;
    wire t_x18y13_s3_g;
    wire t_x18y15_s0_f;
    wire t_x18y15_s0_g;
    wire t_x18y16_s2_g;
    wire t_x18y18_s0_f;
    wire t_x18y18_s0_g;
    wire t_x18y28_s0_f;
    wire t_x18y28_s0_g;
    wire t_x18y28_s3_f;
    wire t_x18y28_s3_g;
    wire t_x18y31_s1_f;
    wire t_x18y31_s1_g;
    wire t_x23y21_s0_f;
    wire t_x23y21_s0_g;
    wire t_x23y21_s2_f;
    wire t_x23y21_s2_g;
    wire t_x23y21_s3_f;
    wire t_x23y21_s3_g;
    wire t_x23y22_s1_f;
    wire t_x23y22_s1_g;
    wire t_x23y23_s2_g;
    wire t_x23y24_s1_g;
    wire t_x23y24_s2_f;
    wire t_x23y24_s2_g;
    wire t_x23y24_s3_f;
    wire t_x23y24_s3_g;
    wire t_x23y25_s0_f;
    wire t_x23y25_s0_g;
    wire t_x23y25_s1_f;
    wire t_x23y25_s1_g;
    wire t_x23y25_s2_g;
    wire t_x23y26_s1_f;
    wire t_x23y26_s1_g;
    wire t_x23y26_s3_f;
    wire chk_rd;
    wire t_x23y27_s0_f;
    wire t_x23y27_s0_g;
    wire t_x23y27_s2_g;
    wire t_x23y32_s1_f;
    wire t_x23y32_s1_g;
    wire t_x24y3_s0_f;
    wire t_x24y3_s0_g;
    wire t_x24y18_s0_f;
    wire t_x24y18_s0_g;
    wire t_x24y18_s2_f;
    wire t_x24y18_s2_g;
    wire t_x24y18_s3_f;
    wire t_x24y19_s0_f;
    wire t_x24y19_s0_g;
    wire t_x24y20_s0_f;
    wire t_x24y20_s0_g;
    wire t_x24y20_s1_f;
    wire t_x24y20_s1_g;
    wire t_x24y20_s2_f;
    wire t_x24y20_s2_g;
    wire t_x24y20_s3_f;
    wire t_x24y20_s3_g;
    wire t_x24y21_s0_f;
    wire t_x24y21_s0_g;
    wire t_x24y21_s1_f;
    wire t_x24y21_s1_g;
    wire t_x24y21_s2_f;
    wire t_x24y21_s2_g;
    wire t_x24y21_s3_f;
    wire t_x24y21_s3_g;
    wire t_x24y22_s0_f;
    wire t_x24y22_s0_g;
    wire t_x24y22_s1_f;
    wire t_x24y22_s1_g;
    wire t_x24y22_s2_f;
    wire t_x24y22_s2_g;
    wire t_x24y23_s0_f;
    wire t_x24y23_s0_g;
    wire t_x24y23_s1_f;
    wire t_x24y23_s1_g;
    wire t_x24y23_s2_f;
    wire t_x24y23_s2_g;
    wire t_x24y23_s3_g;
    wire t_x24y24_s0_f;
    wire t_x24y24_s1_f;
    wire t_x24y24_s1_g;
    wire t_x24y24_s2_f;
    wire t_x24y24_s2_g;
    wire t_x24y24_s3_f;
    wire t_x24y24_s3_g;
    wire t_x24y25_s0_f;
    wire t_x24y25_s0_g;
    wire t_x24y25_s1_f;
    wire t_x24y25_s1_g;
    wire t_x24y25_s2_f;
    wire t_x24y25_s2_g;
    wire t_x24y25_s3_g;
    wire t_x24y26_s0_f;
    wire t_x24y26_s0_g;
    wire t_x24y26_s1_f;
    wire t_x24y26_s1_g;
    wire t_x24y26_s2_f;
    wire t_x24y26_s2_g;
    wire t_x24y26_s3_f;
    wire t_x24y26_s3_g;
    wire t_x24y27_s0_f;
    wire t_x24y27_s0_g;
    wire t_x24y27_s1_f;
    wire t_x24y27_s1_g;
    wire t_x24y27_s2_f;
    wire t_x24y27_s2_g;
    wire t_x24y27_s3_f;
    wire t_x24y27_s3_g;
    wire t_x24y28_s3_f;
    wire t_x24y31_s0_f;
    wire t_x24y31_s0_g;
    wire game_rtc;
    wire t_x17y4_s2_f5;
    wire t_x17y18_s0_f5;
    wire t_x18y1_s0_f5;
    wire t_x18y1_s2_f5;
    wire t_x18y18_s0_f5;
    wire t_x23y21_s0_f5;
    wire t_x23y21_s2_f5;
    wire t_x23y22_s1_f5;
    wire t_x23y24_s2_f5;
    wire t_x23y24_s3_f5;
    wire t_x23y25_s0_f5;
    wire t_x23y25_s1_f5;
    wire t_x23y27_s0_f5;
    wire t_x23y32_s1_f5;
    wire t_x24y3_s0_f5;
    wire t_x24y18_s0_f5;
    wire t_x24y18_s2_f5;
    wire t_x24y19_s0_f5;
    wire t_x24y20_s0_f5;
    wire t_x24y22_s0_f5;
    wire t_x24y23_s1_f5;
    wire t_x24y24_s1_f5;
    wire t_x24y25_s2_f5;
    wire t_x24y26_s3_f5;
    wire t_x24y27_s1_f5;
    wire t_x24y27_s3_f5;
    wire t_x24y31_s0_f5;
    wire t_x24y20_s1_cyf;
    wire t_x24y20_s1_cyg;
    wire t_x24y20_s3_cyf;
    wire t_x24y20_s3_cyg;
    wire t_x24y21_s1_cyf;
    wire t_x24y21_s1_cyg;
    wire t_x24y20_s1_xorf;
    wire t_x24y20_s1_xorg;
    wire t_x24y20_s3_xorf;
    wire t_x24y20_s3_xorg;
    wire t_x24y21_s1_xorf;
    wire t_x24y21_s1_xorg;
    wire t_x24y21_s3_xorf;

    assign d2_o = t_x2y13_s0_g | t_x17y18_s0_f5 & !buf_en & !load_busy_2x;
    assign t_x2y13_s0_g = buf_q[2] & buf_rd & cmd_b4_flag;
    assign d7_o = t_x18y15_s0_f | t_x24y18_s2_f5 | !load_busy_2x & t_x7y9_s0_g;
    assign t_x7y9_s0_g = !cmd_b4_flag & buf_en | !win_en1 & buf_en & buf_q[7];
    assign d6_o = t_x18y13_s3_f | t_x17y4_s2_f5 | !load_busy_2x & t_x7y10_s3_g;
    assign t_x7y10_s3_g = !cmd_b4_flag & buf_en | buf_en & !win_en1 & buf_q[6];
    assign t_x7y24_s3_g = rtc_v4[7] & a1a0_zero & !a2 | a1a0_zero & a2 & rtc_v0[7];
    assign t_x8y11_s0_f = buf_rd & buf_q[4] & cmd_b4_flag;
    assign buf_rd = !win_en1 & buf_en & !load_busy_2x;
    assign t_x8y12_s2_f = buf_rd & buf_q[1] & cmd_b4_flag;
    assign t_x8y15_s3_g = win_en1 & buf_en | buf_en & !cmd_b4_flag | buf_en & buf_q[0];
    assign d5_o = t_x18y13_s0_f | t_x24y3_s0_f5 | !load_busy_2x & t_x9y15_s1_g;
    assign t_x9y15_s1_g = !cmd_b4_flag & buf_en | buf_q[5] & !win_en1 & buf_en;
    assign d0_o = t_x8y15_s3_g | load_busy_2x | t_x9y19_s0_g;
    assign t_x9y19_s0_g = !win_en & !t_x14y19_s2_f | !win_sel & !t_x14y19_s2_f | win_mode[1] & !t_x14y19_s2_f;
    assign d_t = !wr_n | a14 & !a13 & a15;
    assign a000 = !a14 & a13 & a15;
    assign d3_o = t_x12y12_s3_g | t_x18y1_s2_f5 | boot_rd & t_x11y14_s3_g;
    assign t_x11y14_s3_g = !pg15_gb_q & boot_q_x3y13 | brom_sel & brom_q[3];
    assign d1_o = t_x23y32_s1_f5 | t_x8y12_s2_f | t_x11y17_s1_g & boot_rd;
    assign t_x11y17_s1_g = boot_q_x19y21 & !pg15_gb_q | brom_sel & brom_q[1];
    assign d4_o = t_x8y11_s0_f | t_x18y1_s0_f5 | boot_rd & t_x11y17_s2_g;
    assign t_x11y17_s2_g = boot_q_x3y17 & !pg15_gb_q | brom_q[4] & brom_sel;
    assign boot_rd = kernel_b3_lo & !load_busy_2x & !buf_en;
    assign t_x12y12_s3_g = buf_q[3] & buf_rd & cmd_b4_flag;
    assign win5 = win_mode[2] & win_kernel & win_mode[0] & !win_mode[1];
    assign win4 = win_mode[2] & win_kernel & !win_mode[0] & !win_mode[1];
    assign reg_rd = win_mode[1] & !load_busy_2x & !kernel_b3_lo | !load_busy_2x & !kernel_b3_lo & !t_x13y16_s0_g;
    assign t_x13y16_s0_g = win_mode[2] & win_kernel | win_en & win_kernel & !win_mode[0];
    assign t_x14y19_s2_f = !t_x14y19_s2_g & !t_x15y18_s2_f | win4 & !kernel_b3_lo | !t_x15y18_s2_f & kernel_b3_lo | !t_x14y19_s2_g & !kernel_b3_lo;
    assign t_x14y19_s2_g = t_x18y28_s3_f & flash_busy | t_x23y26_s3_f & !win5 | flash_busy & win5 | t_x18y28_s3_f & !win5;
    assign reg_dec_k = a000 & win_mode[3] | a000 & win_mode[1] & win_mode[2];
    assign reg_dec_g = mbc_bank[8] & bank_lo_ones & a000 & bank_hi_ones;
    assign t_x15y18_s2_f = brom_sel & brom_q[0] | !pg15_gb_q & boot_q_x19y5;
    assign brom_sel = !bank_q_a & !a13_gb_q & pg15_gb_q & !bank_q_b;
    assign t_x17y4_s2_f = reg_rd & t_x23y21_s0_f5;
    assign t_x17y4_s2_g = mem_d0 & hdr_chk[6] & reg_rd | mem_d0 & reg_rd & !chk_rd | hdr_chk[6] & reg_rd & chk_rd;
    assign t_x17y18_s0_f = win4 | kernel_b3_lo | !win5 & t_x24y31_s0_f5;
    assign t_x17y18_s0_g = win4 & !kernel_b3_lo | !win5 & t_x24y31_s0_f5 & !kernel_b3_lo;
    assign t_x18y1_s0_f = reg_rd & t_x24y18_s0_f5;
    assign t_x18y1_s0_g = hdr_chk[4] & mem_d2 & reg_rd | hdr_chk[4] & reg_rd & chk_rd | mem_d2 & reg_rd & !chk_rd;
    assign t_x18y1_s2_f = reg_rd & t_x24y19_s0_f5;
    assign t_x18y1_s2_g = hdr_chk[3] & reg_rd & mem_d1 | hdr_chk[3] & reg_rd & chk_rd | reg_rd & mem_d1 & !chk_rd;
    assign t_x18y13_s0_f = kernel_b3_lo & t_x18y13_s0_g & !buf_en & !load_busy_2x;
    assign t_x18y13_s0_g = boot_q_x19y13 & !pg15_gb_q | brom_q[5] & brom_sel;
    assign t_x18y13_s3_f = !load_busy_2x & !buf_en & kernel_b3_lo & t_x18y13_s3_g;
    assign t_x18y13_s3_g = brom_sel & brom_q[6] | !pg15_gb_q & boot_q_x19y9;
    assign t_x18y15_s0_f = !load_busy_2x & kernel_b3_lo & !buf_en & t_x18y15_s0_g;
    assign t_x18y15_s0_g = brom_q[7] & brom_sel | !pg15_gb_q & boot_q_x19y29;
    assign t_x18y16_s2_g = brom_q[2] & brom_sel | !pg15_gb_q & boot_q_x19y25;
    assign t_x18y18_s0_f = 1'b0;
    assign t_x18y18_s0_g = !rtc_sel[4] & rtc_sel[3] & !rtc_sel[6] & !rtc_sel[5];
    assign t_x18y28_s0_f = t_x24y28_s3_f | t_x23y27_s2_g & a0 | a0 & t_x18y28_s0_g;
    assign t_x18y28_s0_g = a1 & a2 | a1 & rtc_v1[0];
    assign t_x18y28_s3_f = reg_dec & !kernel_mode & t_x24y27_s0_f | reg_dec & kernel_mode & t_x18y28_s3_g;
    assign t_x18y28_s3_g = t_x18y31_s1_f | t_x18y28_s0_f;
    assign t_x18y31_s1_f = !adr_014d_lo | a6 | a1 & t_x18y31_s1_g;
    assign t_x18y31_s1_g = a2 & rtc_v5[0] | !a2 & rtc_v3[0] & !a0;
    assign gnd2 = 1'b0;
    assign t_x23y21_s0_f = !reg_dec | t_x23y21_s3_g | t_x23y27_s0_f5 | t_x23y24_s3_f5;
    assign t_x23y21_s0_g = !reg_dec | t_x24y21_s0_f | !rtc_sel[2] & t_x24y21_s1_xorg;
    assign dec_x23y21_s1 = !a1 | !a2;
    assign t_x23y21_s2_f = !reg_dec | t_x23y21_s3_g | t_x24y23_s1_f5 | t_x24y25_s2_f5;
    assign t_x23y21_s2_g = !reg_dec | t_x24y21_s0_f | !rtc_sel[2] & t_x24y21_s1_xorf;
    assign t_x23y21_s3_f = !reg_dec | t_x24y21_s0_f & !kernel_mode | kernel_mode & t_x23y21_s3_g;
    assign t_x23y21_s3_g = !adr_014d_lo | a6 | a0 & !dec_x23y21_s1;
    assign t_x23y22_s1_f = rtc_v2[2] & a0 | a1 & rtc_v1[2] & a0;
    assign t_x23y22_s1_g = !a1 & rtc_v6[2] & a0 | a1 & rtc_v1[2] & a0;
    assign t_x23y23_s2_g = a2 & rtc_v5[2] | !a2 & rtc_v3[2] & !a0;
    assign t_x23y24_s1_g = a2 & rtc_v5[7] | !a0 & rtc_v3[7] & !a2;
    assign t_x23y24_s2_f = t_x24y25_s0_f | t_x23y21_s3_f | t_x23y24_s1_g & a1;
    assign t_x23y24_s2_g = t_x23y21_s3_f | !rtc_sel[2] & t_x24y21_s3_xorf;
    assign t_x23y24_s3_f = a0 & rtc_v2[6] | a1 & a0 & rtc_v1[6];
    assign t_x23y24_s3_g = !a1 & a0 & rtc_v6[6] | a1 & a0 & rtc_v1[6];
    assign t_x23y25_s0_f = rtc_v3[1] & !rtc_sel[0] | !rtc_sel[1] & rtc_v6[1] | !rtc_sel[1] & !rtc_sel[0];
    assign t_x23y25_s0_g = rtc_v3[1] & rtc_sel[1] & !rtc_sel[0] | !rtc_sel[1] & rtc_sel[0] & rtc_v6[1];
    assign t_x23y25_s1_f = rtc_v3[7] & !rtc_sel[0] | !rtc_sel[1] & rtc_v6[7] | !rtc_sel[0] & !rtc_sel[1];
    assign t_x23y25_s1_g = rtc_v3[7] & !rtc_sel[0] & rtc_sel[1] | rtc_sel[0] & !rtc_sel[1] & rtc_v6[7];
    assign t_x23y25_s2_g = rtc_v5[1] & a2 | rtc_v3[1] & !a0 & !a2;
    assign t_x23y26_s1_f = rtc_v0[1] & a2 & a1a0_zero | !a2 & rtc_v4[1] & a1a0_zero;
    assign t_x23y26_s1_g = rtc_v1[3] & a1 | a2 & rtc_v2[3];
    assign t_x23y26_s3_f = !reg_dec & !chk_rd & mem_d7 | !reg_dec & chk_rd & hdr_chk[0];
    assign chk_rd = !kernel_mode & adr_014d & !a15;
    assign t_x23y27_s0_f = a2 & rtc_v5[6] | rtc_v3[6] & !a2 & !a0;
    assign t_x23y27_s0_g = rtc_v4[6] & !a2 & !a0 | a2 & !a0 & rtc_v0[6];
    assign t_x23y27_s2_g = a2 & rtc_v2[0] | !a2 & rtc_v6[0] & !a1;
    assign t_x23y32_s1_f = reg_rd & t_x24y27_s3_f5;
    assign t_x23y32_s1_g = !chk_rd & mem_d6 & reg_rd | chk_rd & reg_rd & hdr_chk[1];
    assign t_x24y3_s0_f = t_x23y21_s2_f5 & reg_rd;
    assign t_x24y3_s0_g = hdr_chk[5] & mem_d3 & reg_rd | hdr_chk[5] & chk_rd & reg_rd | mem_d3 & !chk_rd & reg_rd;
    assign t_x24y18_s0_f = t_x23y21_s3_f | t_x24y21_s2_f | a1 & t_x24y18_s3_f;
    assign t_x24y18_s0_g = t_x23y21_s3_f | t_x24y20_s3_xorg & !rtc_sel[2];
    assign t_x24y18_s2_f = reg_rd & t_x23y24_s2_f5;
    assign t_x24y18_s2_g = mem_d4 & d7_q & reg_rd | mem_d4 & reg_rd & !chk_rd | d7_q & reg_rd & chk_rd;
    assign t_x24y18_s3_f = rtc_v5[4] & a2 | rtc_v3[4] & !a0 & !a2;
    assign t_x24y19_s0_f = t_x23y21_s3_f | t_x24y26_s0_f | a1 & t_x24y27_s2_g;
    assign t_x24y19_s0_g = t_x23y21_s3_f | t_x24y20_s3_xorf & !rtc_sel[2];
    assign t_x24y20_s0_f = !rtc_sel[1] & !rtc_sel[0] | !rtc_sel[1] & rtc_v6[4] | !rtc_sel[0] & rtc_v3[4];
    assign t_x24y20_s0_g = !rtc_sel[1] & rtc_sel[0] & rtc_v6[4] | rtc_sel[1] & !rtc_sel[0] & rtc_v3[4];
    assign t_x24y20_s1_f = !1'b1 | !1'b1 | !t_x24y24_s3_f & t_x24y20_s2_f | t_x24y24_s3_f & !t_x24y20_s2_f;
    assign t_x24y20_s1_g = !1'b1 | !t_x24y22_s1_f & t_x24y21_s3_g | t_x24y22_s1_f & !t_x24y21_s3_g;
    assign t_x24y20_s2_f = t_x24y20_s2_g | t_x18y18_s0_f5 & t_x24y20_s0_f5 & !rtc_sel[2];
    assign t_x24y20_s2_g = !t_x24y22_s2_g & rtc_v1[4] | rtc_sel[0] & rtc_v1[4] & rtc_sel[1];
    assign t_x24y20_s3_f = !1'b1 | !t_x24y23_s2_f & !t_x24y24_s2_f & t_x24y20_s2_f | !t_x24y23_s2_f & t_x24y24_s2_f & !t_x24y20_s2_f | t_x24y23_s2_f & !t_x24y24_s2_f & !t_x24y20_s2_f | t_x24y23_s2_f & t_x24y24_s2_f & t_x24y20_s2_f;
    assign t_x24y20_s3_g = !t_x24y25_s1_f & !t_x24y24_s2_f & t_x24y21_s3_g | t_x24y25_s1_f & !t_x24y24_s2_f & !t_x24y21_s3_g | !t_x24y25_s1_f & t_x24y24_s2_f & t_x24y20_s2_f & !t_x24y21_s3_g | !t_x24y25_s1_f & !t_x24y20_s2_f & t_x24y21_s3_g | t_x24y25_s1_f & t_x24y24_s2_f & t_x24y20_s2_f & t_x24y21_s3_g | t_x24y25_s1_f & !t_x24y20_s2_f & !t_x24y21_s3_g;
    assign t_x24y21_s0_f = !t_x18y18_s0_f5 | rtc_sel[2] & rtc_sel[0] | rtc_sel[2] & rtc_sel[1];
    assign t_x24y21_s0_g = rtc_v2[4] & a2 | rtc_v1[4] & a1;
    assign t_x24y21_s1_f = !t_x24y25_s1_f & t_x24y24_s2_f & !t_x24y20_s2_f | t_x24y25_s1_f & !t_x24y24_s2_f & t_x24y21_s3_g | !t_x24y25_s1_f & t_x24y24_s2_f & !t_x24y21_s3_g | t_x24y24_s2_f & !t_x24y20_s2_f & !t_x24y21_s3_g;
    assign t_x24y21_s1_g = t_x24y25_s1_f & !t_x24y24_s2_f | !t_x24y25_s1_f & t_x24y24_s2_f & t_x24y20_s2_f & t_x24y21_s3_g | t_x24y25_s1_f & !t_x24y20_s2_f & !t_x24y21_s3_g;
    assign t_x24y21_s2_f = t_x24y24_s0_f | t_x24y21_s2_g & a0 | a0 & t_x24y21_s0_g;
    assign t_x24y21_s2_g = rtc_v6[4] & !a2 & !a1;
    assign t_x24y21_s3_f = t_x24y25_s1_f & t_x24y24_s2_f & t_x24y20_s2_f | t_x24y25_s1_f & t_x24y24_s2_f & t_x24y21_s3_g;
    assign t_x24y21_s3_g = t_x24y22_s2_f | t_x24y24_s1_f5 & !rtc_sel[2] & t_x18y18_s0_f5;
    assign t_x24y22_s0_f = rtc_v3[2] & !rtc_sel[0] | rtc_v6[2] & !rtc_sel[1] | !rtc_sel[0] & !rtc_sel[1];
    assign t_x24y22_s0_g = rtc_v3[2] & !rtc_sel[0] & rtc_sel[1] | rtc_v6[2] & rtc_sel[0] & !rtc_sel[1];
    assign t_x24y22_s1_f = t_x24y22_s1_g | t_x18y18_s0_f5 & !rtc_sel[2] & t_x24y22_s0_f5;
    assign t_x24y22_s1_g = rtc_v1[2] & !t_x24y22_s2_g | rtc_sel[1] & rtc_sel[0] & rtc_v1[2];
    assign t_x24y22_s2_f = !t_x24y22_s2_g & rtc_v1[5] | rtc_v1[5] & rtc_sel[0] & rtc_sel[1];
    assign t_x24y22_s2_g = t_x18y18_s0_f5 & !rtc_sel[2];
    assign t_x24y23_s0_f = kernel_mode & t_x23y22_s1_f5 | kernel_mode & t_x24y23_s0_g;
    assign t_x24y23_s0_g = t_x24y23_s3_g | t_x23y23_s2_g & a1;
    assign t_x24y23_s1_f = a0 & rtc_v2[5] | a0 & a1 & rtc_v1[5];
    assign t_x24y23_s1_g = !a1 & a0 & rtc_v6[5] | a1 & rtc_v1[5] & a0;
    assign t_x24y23_s2_f = t_x24y23_s2_g | t_x18y18_s0_f5 & !rtc_sel[2] & t_x24y26_s3_f5;
    assign t_x24y23_s2_g = rtc_v1[3] & !t_x24y22_s2_g | rtc_v1[3] & rtc_sel[1] & rtc_sel[0];
    assign t_x24y23_s3_g = rtc_v0[2] & rtc_v4[2] & a1a0_zero | rtc_v0[2] & a1a0_zero & a2 | rtc_v4[2] & a1a0_zero & !a2;
    assign t_x24y24_s0_f = rtc_v4[4] & a1a0_zero & rtc_v0[4] | rtc_v4[4] & a1a0_zero & !a2 | a1a0_zero & rtc_v0[4] & a2;
    assign t_x24y24_s1_f = rtc_v6[5] & !rtc_sel[1] | !rtc_sel[0] & rtc_v3[5] | !rtc_sel[0] & !rtc_sel[1];
    assign t_x24y24_s1_g = rtc_v6[5] & rtc_sel[0] & !rtc_sel[1] | !rtc_sel[0] & rtc_sel[1] & rtc_v3[5];
    assign t_x24y24_s2_f = t_x24y24_s2_g | t_x24y27_s1_f5 & !rtc_sel[2] & t_x18y18_s0_f5;
    assign t_x24y24_s2_g = rtc_v1[6] & !t_x24y22_s2_g | rtc_v1[6] & rtc_sel[0] & rtc_sel[1];
    assign t_x24y24_s3_f = t_x24y24_s3_g | t_x18y18_s0_f5 & t_x23y25_s0_f5 & !rtc_sel[2];
    assign t_x24y24_s3_g = !t_x24y22_s2_g & rtc_v1[1] | rtc_v1[1] & rtc_sel[1] & rtc_sel[0];
    assign t_x24y25_s0_f = t_x7y24_s3_g | t_x24y25_s3_g & a0 | a0 & t_x24y25_s0_g;
    assign t_x24y25_s0_g = !a1 & !a2 & rtc_v6[7];
    assign t_x24y25_s1_f = t_x24y25_s1_g | t_x18y18_s0_f5 & t_x23y25_s1_f5 & !rtc_sel[2];
    assign t_x24y25_s1_g = !t_x24y22_s2_g & rtc_v1[7] | rtc_v1[7] & rtc_sel[1] & rtc_sel[0];
    assign t_x24y25_s2_f = rtc_v5[5] & a2 | rtc_v3[5] & !a2 & !a0;
    assign t_x24y25_s2_g = rtc_v4[5] & !a0 & rtc_v0[5] | rtc_v4[5] & !a0 & !a2 | !a0 & rtc_v0[5] & a2;
    assign t_x24y25_s3_g = a2 & rtc_v2[7] | rtc_v1[7] & a1;
    assign t_x24y26_s0_f = t_x24y26_s2_g | t_x23y26_s1_g & a0 | a0 & t_x24y26_s0_g;
    assign t_x24y26_s0_g = rtc_v6[3] & !a1 & !a2;
    assign t_x24y26_s1_f = t_x23y26_s1_f | a0 & t_x24y26_s2_f | a0 & t_x24y26_s1_g;
    assign t_x24y26_s1_g = !a1 & !a2 & rtc_v6[1];
    assign t_x24y26_s2_f = rtc_v2[1] & a2 | a1 & rtc_v1[1];
    assign t_x24y26_s2_g = a1a0_zero & !a2 & rtc_v4[3] | a1a0_zero & a2 & rtc_v0[3];
    assign t_x24y26_s3_f = !rtc_sel[1] & rtc_v6[3] | rtc_v3[3] & !rtc_sel[0] | !rtc_sel[1] & !rtc_sel[0];
    assign t_x24y26_s3_g = !rtc_sel[1] & rtc_v6[3] & rtc_sel[0] | rtc_sel[1] & rtc_v3[3] & !rtc_sel[0];
    assign t_x24y27_s0_f = rtc_sel[2] | t_x24y27_s0_g | t_x24y27_s2_f | !t_x18y18_s0_f5;
    assign t_x24y27_s0_g = rtc_sel[0] & rtc_v6[0] & !rtc_sel[1] | rtc_sel[0] & rtc_sel[1] & rtc_v1[0];
    assign t_x24y27_s1_f = !rtc_sel[0] & !rtc_sel[1] | !rtc_sel[0] & rtc_v3[6] | !rtc_sel[1] & rtc_v6[6];
    assign t_x24y27_s1_g = !rtc_sel[0] & rtc_sel[1] & rtc_v3[6] | rtc_sel[0] & !rtc_sel[1] & rtc_v6[6];
    assign t_x24y27_s2_f = !rtc_sel[0] & rtc_v4[0] & !rtc_sel[1] | !rtc_sel[0] & rtc_sel[1] & rtc_v3[0];
    assign t_x24y27_s2_g = rtc_v5[3] & a2 | !a0 & rtc_v3[3] & !a2;
    assign t_x24y27_s3_f = t_x23y21_s3_f | t_x24y26_s1_f | a1 & t_x23y25_s2_g;
    assign t_x24y27_s3_g = t_x23y21_s3_f | t_x24y20_s1_xorf & !rtc_sel[2];
    assign t_x24y28_s3_f = a1a0_zero & rtc_v0[0] & a2 | a1a0_zero & !a2 & rtc_v4[0];
    assign a1a0_zero = !a0 & !a1;
    assign t_x24y31_s0_f = t_x24y23_s0_f | t_x23y21_s3_f | game_rtc & t_x24y20_s1_xorg;
    assign t_x24y31_s0_g = hdr_chk[2] & mem_d5 | hdr_chk[2] & chk_rd | mem_d5 & !chk_rd;
    assign game_rtc = !kernel_mode & !rtc_sel[2];
    assign reg_dec = (kernel_mode ? reg_dec_k : reg_dec_g);
    assign t_x17y4_s2_f5 = (reg_dec ? t_x17y4_s2_f : t_x17y4_s2_g);
    assign t_x17y18_s0_f5 = (t_x18y16_s2_g ? t_x17y18_s0_f : t_x17y18_s0_g);
    assign t_x18y1_s0_f5 = (reg_dec ? t_x18y1_s0_f : t_x18y1_s0_g);
    assign t_x18y1_s2_f5 = (reg_dec ? t_x18y1_s2_f : t_x18y1_s2_g);
    assign t_x18y18_s0_f5 = (rtc_sel[7] ? t_x18y18_s0_f : t_x18y18_s0_g);
    assign t_x23y21_s0_f5 = (kernel_mode ? t_x23y21_s0_f : t_x23y21_s0_g);
    assign t_x23y21_s2_f5 = (kernel_mode ? t_x23y21_s2_f : t_x23y21_s2_g);
    assign t_x23y22_s1_f5 = (a2 ? t_x23y22_s1_f : t_x23y22_s1_g);
    assign t_x23y24_s2_f5 = (kernel_mode ? t_x23y24_s2_f : t_x23y24_s2_g);
    assign t_x23y24_s3_f5 = (a2 ? t_x23y24_s3_f : t_x23y24_s3_g);
    assign t_x23y25_s0_f5 = (rtc_v4[1] ? t_x23y25_s0_f : t_x23y25_s0_g);
    assign t_x23y25_s1_f5 = (rtc_v4[7] ? t_x23y25_s1_f : t_x23y25_s1_g);
    assign t_x23y27_s0_f5 = (a1 ? t_x23y27_s0_f : t_x23y27_s0_g);
    assign t_x23y32_s1_f5 = (reg_dec ? t_x23y32_s1_f : t_x23y32_s1_g);
    assign t_x24y3_s0_f5 = (reg_dec ? t_x24y3_s0_f : t_x24y3_s0_g);
    assign t_x24y18_s0_f5 = (kernel_mode ? t_x24y18_s0_f : t_x24y18_s0_g);
    assign t_x24y18_s2_f5 = (reg_dec ? t_x24y18_s2_f : t_x24y18_s2_g);
    assign t_x24y19_s0_f5 = (kernel_mode ? t_x24y19_s0_f : t_x24y19_s0_g);
    assign t_x24y20_s0_f5 = (rtc_v4[4] ? t_x24y20_s0_f : t_x24y20_s0_g);
    assign t_x24y22_s0_f5 = (rtc_v4[2] ? t_x24y22_s0_f : t_x24y22_s0_g);
    assign t_x24y23_s1_f5 = (a2 ? t_x24y23_s1_f : t_x24y23_s1_g);
    assign t_x24y24_s1_f5 = (rtc_v4[5] ? t_x24y24_s1_f : t_x24y24_s1_g);
    assign t_x24y25_s2_f5 = (a1 ? t_x24y25_s2_f : t_x24y25_s2_g);
    assign t_x24y26_s3_f5 = (rtc_v4[3] ? t_x24y26_s3_f : t_x24y26_s3_g);
    assign t_x24y27_s1_f5 = (rtc_v4[6] ? t_x24y27_s1_f : t_x24y27_s1_g);
    assign t_x24y27_s3_f5 = (kernel_mode ? t_x24y27_s3_f : t_x24y27_s3_g);
    assign t_x24y31_s0_f5 = (reg_dec ? t_x24y31_s0_f : t_x24y31_s0_g);
    assign t_x24y20_s1_cyf = (t_x24y20_s1_f ? gnd2 : t_x24y24_s3_f);
    assign t_x24y20_s1_cyg = (t_x24y20_s1_g ? t_x24y20_s1_cyf : t_x24y22_s1_f);
    assign t_x24y20_s3_cyf = (t_x24y20_s3_f ? t_x24y20_s1_cyg : t_x24y23_s2_f);
    assign t_x24y20_s3_cyg = (t_x24y20_s3_g ? t_x24y20_s3_cyf : 1'b0);
    assign t_x24y21_s1_cyf = (t_x24y21_s1_f ? t_x24y20_s3_cyg : 1'b0);
    assign t_x24y21_s1_cyg = (t_x24y21_s1_g ? t_x24y21_s1_cyf : 1'b0);
    assign t_x24y20_s1_xorf = (t_x24y20_s1_f ^ gnd2);
    assign t_x24y20_s1_xorg = (t_x24y20_s1_g ^ t_x24y20_s1_cyf);
    assign t_x24y20_s3_xorf = (t_x24y20_s3_f ^ t_x24y20_s1_cyg);
    assign t_x24y20_s3_xorg = (t_x24y20_s3_g ^ t_x24y20_s3_cyf);
    assign t_x24y21_s1_xorf = (t_x24y21_s1_f ^ t_x24y20_s3_cyg);
    assign t_x24y21_s1_xorg = (t_x24y21_s1_g ^ t_x24y21_s1_cyf);
    assign t_x24y21_s3_xorf = (t_x24y21_s3_f ^ t_x24y21_s1_cyg);

endmodule
