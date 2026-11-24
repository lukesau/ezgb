// FW6's Game Boy data bus output: FW5-0918's module (stage0/fw5-0918/
// gb_data_out.v, and stage0/fw4/rtl/gb_data_out.v for what each read
// returns) with these differences, read from the design and proven:
//
//   - the game's MBC3 clock reads come from the clock in the FPGA: with
//     rtc_sel $08-$0C a read returns mbc3_rtc's seconds, minutes, hours,
//     day low byte, or DH (day bit 8 in bit 0, halt in bit 6, the day
//     carry in bit 7). Until the game's first latch ($01 written to
//     $6000-$7FFF over $00) they are the clock as it is that moment;
//     from then on, the copy the last latch took (mbc3_clock)
//   - the kernel reads that clock too, as it is that moment, at
//     $A018-$A01C of its register window (FW5 read 0 there)
//   - a stage1 read returns gb_bus's registered byte
//   - $7FC0 = 4 reads $06 (FW5 $05)
//
// Proven in the whole-design proof (stage0/tools/fw6-prove.sh).

module gb_data_out (
    input a0, a1, a2, a3, a4, a5, a6, a7, a13, a14, a15,
    input wr_n,
    input mem_d0, mem_d1, mem_d2, mem_d3, mem_d4, mem_d5, mem_d6, mem_d7,
    input kernel_mode,
    input adr_014d,                 // the address is $x14D (psram_ctrl)
    input bank_hi_ones, bank_lo_ones,   // the game-mode bank register is all ones
    input [7:0] boot_q,             // the stage1 byte (gb_bus)
    input buf_en,                   // the sector buffer window (sd_mem_path)
    input [7:0] buf_q,              // the sector buffer
    input cmd_b4_flag,              // cleared by the $7FB4 write, set by the data interrupt
    input flash_busy,               // port F1
    input [6:0] hdr_chk,            // $7FC3 bits 6:0
    input hdr_chk7,                 // $7FC3 bit 7
    input kernel_b3_lo,             // kernel mode, $7F32 bit 3, below $8000
    input load_busy_2x,             // port EF
    input [8:8] mbc_bank,           // the RAM enable
    input [6:0] rtc_sec, rtc_min,   // the RTC bridge's registers
    input [5:0] rtc_hour, rtc_day,
    input [2:0] rtc_wday,
    input [4:0] rtc_month,
    input [7:0] rtc_year,
    input [5:0] sec, min,           // the MBC3 clock (mbc3_rtc)
    input [4:0] hour,
    input [8:0] day,
    input halt, day_carry,
    input latched,                  // a latch has been taken, and its copy (mbc3_clock)
    input [5:0] cap_sec, cap_min,
    input [4:0] cap_hour,
    input [8:0] cap_day,
    input cap_halt, cap_carry,
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

    // ---- the bytes
    wire [7:0] boot_byte = boot_q;
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
    // the game's MBC3 clock registers: live, or the latched copy
    wire [5:0] g_sec = latched ? cap_sec : sec;
    wire [5:0] g_min = latched ? cap_min : min;
    wire [4:0] g_hour = latched ? cap_hour : hour;
    wire [8:0] g_day = latched ? cap_day : day;
    wire g_halt = latched ? cap_halt : halt;
    wire g_carry = latched ? cap_carry : day_carry;
    reg [7:0] rtc_g;
    always @* case (rtc_sel)
        8'h08: rtc_g = {2'b00, g_sec};
        8'h09: rtc_g = {2'b00, g_min};
        8'h0a: rtc_g = {3'b000, g_hour};
        8'h0b: rtc_g = g_day[7:0];
        8'h0c: rtc_g = {g_carry, g_halt, 5'b00000, g_day[8]};
        default: rtc_g = 8'h00;
    endcase
    // the kernel reads the game's clock, always live, at $x18-$x1C of
    // its register window, where it writes the value to load
    reg [7:0] clk_k;
    always @* case ({a2, a1, a0})
        3'd0: clk_k = {2'b00, sec};
        3'd1: clk_k = {2'b00, min};
        3'd2: clk_k = {3'b000, hour};
        3'd3: clk_k = day[7:0];
        3'd4: clk_k = {day_carry, halt, 5'b00000, day[8]};
        default: clk_k = 8'h00;
    endcase
    wire clk_win = !a7 & !a6 & !a5 & a4 & a3;
    wire [7:0] reg_byte = !kernel_mode   ? rtc_g
                        : rtc_win & !a4  ? rtc_k
                        : clk_win        ? clk_k
                        :                  8'h00;

    // ---- the mux
    wire [7:0] d_o = load_busy_2x ? 8'h01
                   : buf_en       ? status
                   : kernel_b3_lo ? boot_byte
                   : win4         ? 8'h06
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
