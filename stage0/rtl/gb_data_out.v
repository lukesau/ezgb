// The Game Boy data bus output, written by EZ Flash: what the console reads
// back on D0-D7 and when the FPGA drives them. Combinational only.
//
// What a read returns, in order of precedence:
//
//   - $01 while the loader runs (port EF): the status the kernel polls
//   - in the sector buffer window ($7FC0 = 0 at $A000-$BFFF): $E1 from
//     the $7FB4 write until the transfer's data interrupt (the flag in
//     gb_regs), $01 while $7F30 bit 1 is set, else the buffer's byte
//     (block RAM X3Y5)
//   - in kernel mode with $7F32 bit 3 set, below $8000: the stage1
//     program from block RAM bit planes, one bit per RAM, or bytes from
//     block RAM X19Y17 one page up (the page bits that choose are the
//     controller's, in their 2x-domain copies)
//   - $7FC0 = 4 reads $04, $7FC0 = 5 reads the flash writer's busy flag
//   - the register window ($7FC0 = 6, 7 or 8 and up in kernel mode; in
//     game mode the bank register at all ones with RAM enabled): the
//     seven RTC values the PicoBlaze sends (the RTC bridge's 2x-domain
//     copies of its port EE writes) at offsets $08-$0E in kernel mode,
//     $FF elsewhere in it; in game mode the MBC3 way, by the value
//     written to $4000: $08-$0B give seconds, minutes, hours and days
//     converted from the PCF8563's BCD to binary, $0C the day counter's
//     high byte as a constant 1, anything else $FF
//   - the header checksum register ($7FC3, bit 7 straight from the data
//     pad's input register) at $014D in game mode
//   - the pSRAM's data pins otherwise, in the pad order mem_d7..mem_d0
//     for D0..D7 (the pad names are the board's, see sd_mem_path)
//
// The bus is driven whenever /WR is high, except at $C000-$DFFF.
//
// The proof takes the window decode's three stages (win_kernel, win_sel,
// buf_en) as consistent with the address and mode bits, which is how
// sd_mem_path makes them; the LUTs' behavior for contradictory stages is
// not reproduced.
//
// Block: stage0/blocks/gb_data_out.blk.

module gb_data_out (
    input a0, a1, a2, a6, a13, a14, a15,
    input d7_q,                     // D7's pad input register: the checksum register's bit 7
    input wr_n,
    input mem_d0, mem_d1, mem_d2, mem_d3, mem_d4, mem_d5, mem_d6, mem_d7,
    input kernel_mode,
    input a13_gb_q,                 // the controller's page bits, 2x-domain copies
    input adr_014d,                 // the address is $x14D (psram_ctrl)
    input adr_014d_lo,              // its bits 7:3 match: the RTC window's offsets
    input bank_hi_ones, bank_lo_ones,   // the game-mode bank register is all ones
    input a12_pass_q, a11_pass_q,   // a12 and a11 after the window remap, registered (gb_bus)
    input boot_q_x19y13, boot_q_x19y21, boot_q_x19y25, boot_q_x19y29, boot_q_x19y5, boot_q_x19y9, boot_q_x3y13, boot_q_x3y17,
    input [7:0] brom_q,             // block RAM X19Y17
    input buf_en,                   // the sector buffer window (sd_mem_path)
    input [7:0] buf_q,              // block RAM X3Y5
    input cmd_b4_flag,              // cleared by the $7FB4 write, set by the data interrupt
    input flash_busy,               // port F1
    input [6:0] hdr_chk,            // $7FC3 bits 6:0
    input kernel_b3_lo,             // kernel mode, $7F32 bit 3, below $8000
    input load_busy_2x,             // port EF
    input [8:8] mbc_bank,           // the RAM enable
    input pg15_gb_q,
    input [7:0] rtc_sec, rtc_min, rtc_hour, rtc_day, rtc_wday, rtc_month, rtc_year,   // the RTC bridge's copies of the PicoBlaze's readings
    input [7:0] rtc_sel,            // the MBC3 RTC register select
    input win_en, win_en1,          // $7F30 bits 0 and 1
    input win_kernel, win_sel,      // the window decode's stages (sd_mem_path)
    input [3:0] win_mode,           // $7FC0 bits 3:0
    output d0_o, d1_o, d2_o, d3_o, d4_o, d5_o, d6_o, d7_o,
    output d_t,                     // the bus's tristate
    // decode terms shared outside
    output reg_dec,                 // the register window
    output gnd2,                    // a constant-0 LUT
    output dec_x23y21_s1,           // !a1 | !a2
    output a1a0_zero
);
    assign d_t = !wr_n | a14 & !a13 & a15;
    assign gnd2 = 1'b0;
    assign dec_x23y21_s1 = !a1 | !a2;
    assign a1a0_zero = !a0 & !a1;

    // ---- where the read is
    wire a000 = !a14 & a13 & a15;
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
    wire [7:0] chk_byte = {d7_q, hdr_chk};
    wire [7:0] mem_or_chk = chk_rd ? chk_byte : mem_byte;
    wire [7:0] status = !cmd_b4_flag ? 8'he1 : win_en1 ? 8'h01 : buf_q;

    // the RTC window in kernel mode: the seven readings at offsets $08-$0E
    function [7:0] bcd2bin(input [7:0] v);
        bcd2bin = {4'd0, v[7:4]} * 8'd10 + {4'd0, v[3:0]};
    endfunction
    wire rtc_win_k = adr_014d_lo & !a6;                   // offsets $08-$0F
    reg [7:0] rtc_k;
    always @* case ({a2, a1, a0})
        3'd0: rtc_k = rtc_sec;       // seconds
        3'd1: rtc_k = rtc_min;       // minutes
        3'd2: rtc_k = rtc_hour;       // hours
        3'd3: rtc_k = rtc_day;       // days
        3'd4: rtc_k = rtc_wday;       // weekday
        3'd5: rtc_k = rtc_month;       // month
        3'd6: rtc_k = rtc_year;       // year
        default: rtc_k = 8'hff;
    endcase
    reg [7:0] rtc_g;
    always @* case (rtc_sel)
        8'h08: rtc_g = bcd2bin(rtc_sec);
        8'h09: rtc_g = bcd2bin(rtc_min);
        8'h0a: rtc_g = bcd2bin(rtc_hour);
        8'h0b: rtc_g = bcd2bin(rtc_day);
        8'h0c: rtc_g = 8'h01;
        default: rtc_g = 8'hff;
    endcase
    wire [7:0] reg_byte = kernel_mode ? (rtc_win_k ? rtc_k : 8'hff) : rtc_g;

    // ---- the mux
    wire [7:0] d_o = load_busy_2x ? 8'h01
                   : buf_en       ? status
                   : kernel_b3_lo ? boot_byte
                   : win4         ? 8'h04
                   : win5         ? {7'd0, flash_busy}
                   : reg_dec      ? reg_byte
                   :                mem_or_chk;
    assign {d7_o, d6_o, d5_o, d4_o, d3_o, d2_o, d1_o, d0_o} = d_o;

`ifdef FORMAL
    // The window decode's stages arrive from sd_mem_path, where they are
    // made from the same address and mode bits; the mux above reads them
    // as the decode, and what the LUTs do for stages that contradict each
    // other is not reachable. Stated as input assumptions.
    always @* begin
        env_win_kernel: assume (win_kernel == (kernel_mode & a13 & !a14 & a15 & !win_mode[3]));
        env_win_sel:    assume (win_sel == (win_kernel & !win_mode[0] & !win_mode[2]));
        env_buf_en:     assume (buf_en == (win_sel & !win_mode[1] & win_en));
    end
`endif
endmodule
