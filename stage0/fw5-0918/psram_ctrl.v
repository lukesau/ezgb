// FW5-0918's pSRAM controller: the FW4 module (stage0/fw4/rtl/psram_ctrl.v,
// which says what each part does) with these differences, read from the
// design and proved:
//
//   - one more way to reach U4: a $A000-$BFFF access with bank register
//     bit 7 set, when the game-mode bank is all ones with the RAM enabled
//     (an access FW4 keeps off both chips) or the kernel window mode is 6,
//     7 or 8 up (u4_extra). The chip select, write enable, low byte strobe
//     and address tristate all take it; n_save, which other blocks read,
//     does not
//   - that access is at page $08: u4_win, with or without bit 7, loads
//     the page register with $08
//   - with no pSRAM access, or on that extra U4 access, A0 carries bit 0
//     of the MBC3 clock register number (rtc_sel, $08-$0C) instead of the
//     Game Boy's A0; sd_mem_path puts the rest of it on A1-A8, so each
//     clock register has its own bytes there
//   - no CLK2X copy of port EF: ld is the PicoBlaze-clock register itself
//     (FW5 keeps two copies of it, both named load_busy_2x in the block)
//   - the A13 pad mux (FW4's mem_a_gb[13], with the P51 latch) is not
//     here; chk_sel, hi_n_win1, a13_sel and adr_014d_lo stay inside, and
//     FW5 shares adr_014d_lo3, a13_pass, n_rom_gb and u4_win instead
//   - the $A000 test inside comes from A13 and A14; only u4_win reads the
//     shared win_a000
//
// Block: built by stage0/tools/simblk.py from stage0/fw4/blocks/psram_ctrl.blk
// (stage0/fw5-0918/psram_ctrl.sim has its arguments), with the names in
// psram_ctrl.names.
module psram_ctrl (
    input a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,
    input wr_n,
    input gb_reset_n,
    input clk_fx,
    input kernel_mode,              // $7F32 bit 7
    input gnd1,                     // the constant-0 LUT the design shares (soft_reset's gnd)
    input rtc_sel0,                 // bit 0 of the MBC3 clock register number (gb_regs' rtc_sel)
    input [7:0] bank_4000,          // the $4000 register (kernel mode)
    input byte_we_n,                // the SD byte sequencer (sd_mem_path)
    input [3:2] cnt,
    input flash_op,                 // $7FD2 bit 0
    input mbc1_mode,                // the MBC1 mode bit, $6000-$7FFF (gb_regs)
    input [13:6] load_addr,         // the loader's destination, upper bits
    input load_busy_2x,             // port EF (the PicoBlaze-clock register; FW5 has no 2x copy)
    input load_win,                 // $7F36 bit 0
    input [1:0] mbc1m_hi,           // the MBC1 multicart's registers
    input mbc1m_mode,
    input [3:0] mbc1m_ram,
    input mbc1m_sel,
    input [8:0] mbc_bank,           // the game-mode bank register; [8] the RAM enable
    input [3:0] mbc_type,           // $7F37 bits 3:0
    input mode32_b3,                // $7F32 bit 3
    input reset_drive,              // the console reset pulse ($7FE0)
    input [7:0] rom_bank,           // the $2000 register
    input rom_bank8,                // $3000 bit 0
    input [22:15] wbm_adr_o,        // the filler's address, upper bits
    input win_a000,                 // a13 & !a14 (sd_mem_path)
    input [3:0] win_mode,           // $7FC0 bits 3:0
    input win_sel,                  // sd_mem_path's window decode
    // the pins
    output gb_reset_drive,          // P62: the console's /RESET
    output mem_a0,                  // P56
    output mem_a13_t,               // P51's tristate in FW4; FW5 drives P51 always and reads this elsewhere
    output mem_a_t,                 // the other address pins' tristate
    output mem_ce4_n,               // P60: U4, saves
    output mem_ce9_n,               // P52: U9, game ROM
    output mem_lb_n,                // P37
    output mem_ub_n,                // P36
    output mem_we_n,                // P40
    output p85,                     // follows /WR outside $A000-$BFFF
    output reg sh_done,
    output reg sh_run,
    output sr_rclk,                 // P24: the 74HC595's latch clock
    output sr_ser,                  // P33: its data
    // decode terms other blocks share
    output pg15_gb_b, pg15_gb,      // the first banked address bit of the Game Boy's access (see below)
    output a13_gb_b, a13_gb,
    output a13_pass,                // a13_sel before the AND with A13
    output n_rom_gb,                // n_rom outside a load
    output u4_win,                  // u4_extra before bank bit 7
    output kernel_b3_lo,
    output bank_hi_ones, bank_lo_ones,
    output adr_014d,
    output adr_014d_lo3,            // !a7 & a3 & !a5, which FW5 shares in place of adr_014d_lo
    output n_save,
    output bank0_sel,
    output type_grp, type_lo,
    output n_rom,
    output game_mbc1m,
    output n_4000,
    output n_mbc1, is_mbc5
);
    // ---- what the access is
    assign adr_014d_lo3 = !a7 & a3 & !a5;
    wire adr_014d_lo = adr_014d_lo3 & !a4;
    wire adr_014d_mid = a8 & !a12 & !a11 & !a9;
    wire adr_014d_lo2 = !a1 & a0 & !a13 & a2;
    wire adr_014d_hi = !a14 & a6 & !a10;
    assign adr_014d = adr_014d_mid & adr_014d_lo2 & adr_014d_hi & adr_014d_lo;   // $x14D
    wire chk_sel = !kernel_mode & adr_014d | kernel_mode & mode32_b3 & !a15;      // served from a register, not U9
    assign n_4000 = !a14 | a15;
    assign kernel_b3_lo = kernel_mode & !a15 & mode32_b3;
    wire win_not3 = !win_mode[0] | win_mode[3] | !win_mode[1] | win_mode[2];
    wire a000 = a13 & !a14;                 // win_a000 from the pins: FW5 reads the shared net only in u4_win
    wire n_win1_k = win_mode[3] | !kernel_mode | !a000 | win_mode[2];
    wire hi_n_win1 = n_win1_k & a15 | win_mode[1] & a15 | a15 & !win_mode[0];    // a15, unless the $7FC0=1 window
    assign n_rom = hi_n_win1 | chk_sel;                                              // not a U9 access
    wire n_ram_win = !a000 | !a15 | !mbc_bank[8] & !kernel_mode;                // not $A000-$BFFF with RAM enabled
    assign bank_lo_ones = mbc_bank[2] & mbc_bank[3] & mbc_bank[0] & mbc_bank[1];
    assign bank_hi_ones = mbc_bank[5] & mbc_bank[7] & mbc_bank[4] & mbc_bank[6];
    wire bank_ff_game = bank_lo_ones & !kernel_mode & bank_hi_ones;
    assign n_save = n_ram_win | bank_ff_game | win_not3 & kernel_mode;              // not a U4 access
    wire kernel_n_loadwin = !load_win & kernel_mode | !win_mode[1] & kernel_mode | !win_sel & kernel_mode;
    wire rom_hi = a14 & !chk_sel & !a15;                                             // $4000-$7FFF

    // ---- the MBC type
    assign n_mbc1 = mbc_type[3] | !mbc_type[0] | mbc_type[1];                       // not 1 or 5
    assign is_mbc5 = !mbc_type[1] & !mbc_type[3] & !mbc_type[0] & mbc_type[2];
    assign type_lo = mbc_type[0] | mbc_type[1];
    assign type_grp = mbc_type[3] | mbc_type[1] & mbc_type[2] | !mbc_type[1] & !mbc_type[0] & !mbc_type[2];   // 0, 6, 7 or 8 up
    assign game_mbc1m = !kernel_mode & !n_mbc1 & mbc_type[2];                       // MBC1 multicart, in game mode
    wire n_ram_or_mbc1_mode0 = n_ram_win | !mbc1_mode & !n_mbc1 & !mbc_type[2];
    wire game_n_save = n_ram_win & !kernel_mode | !kernel_mode & bank_lo_ones & bank_hi_ones;
    wire game_n_save_or_b3 = game_n_save | mode32_b3 & !a15 & kernel_mode;
    wire mbc_banked = !mbc_type[2] & !mbc_type[3] & game_n_save & type_lo | mbc_type[2] & !mbc_type[3] & game_n_save & !type_lo;   // types 1-4
    wire rom_hi_sel = mbc_banked & rom_hi | !mode32_b3 & kernel_n_loadwin & rom_hi;  // rom_bank applies
    wire game_bank_sel = !n_ram_or_mbc1_mode0 & !bank_lo_ones & !kernel_mode | !n_ram_or_mbc1_mode0 & !kernel_mode & !bank_hi_ones;   // mbc_bank pages the save RAM
    wire n_kernel_4000 = n_save | !hi_n_win1 & !chk_sel;
    wire kernel_4000_sel = kernel_n_loadwin & !mode32_b3 & !n_kernel_4000 | kernel_n_loadwin & a15 & !n_kernel_4000;   // bank_4000 pages the save RAM
    wire mbc1m_lo = n_save & !chk_sel & !hi_n_win1 & game_mbc1m;

    // ---- the MBC1 multicart's and the bank-zero quirks
    wire mbc1m_a14 = a15 & mbc1m_mode | !a15 & a14 & mbc1m_hi[0] | mbc1m_mode & !a14;
    wire mbc1m_a14b = !a14 & mbc1m_sel | a14 & !a15 & mbc1m_hi[1] | a15 & mbc1m_sel;
    wire mbc1m_ram0 = mbc1m_hi[0] ? mbc1m_ram[0] : (mbc1m_ram[0] | !mbc1m_ram[1] & !mbc1m_ram[3] & !mbc1m_ram[2]);
    wire bank_bit0_eff = !mbc_type[2] & rom_bank[0] | mbc_type[2] & mbc1m_ram0 & mbc_type[0] | rom_bank[0] & !mbc_type[0];
    wire n_bank_lo_zero = !mbc_type[1] | !rom_bank[5] & !rom_bank[6] & !rom_bank[7];
    wire bank_nonzero = mbc_type[2] | rom_bank[4] | !n_bank_lo_zero;
    wire bank_zero_fix = !rom_bank[3] & !rom_bank[2] & !bank_nonzero & !rom_bank[1];
    wire a14_game = type_grp | !a15 & bank_bit0_eff | !a15 & bank_zero_fix;
    wire a14_misc = kernel_b3_lo | n_rom & game_n_save | game_n_save & a14_game;
    wire a14_kernel = !n_rom & kernel_n_loadwin & !a15 & rom_bank[0];

    // ---- the banked address bits of a Game Boy access
    //
    // pg15_gb is bit 14 of a ROM access (rom_bank[0]) and bit 15 of a save
    // access (the page's bit 1): the two paths share the net, and the save
    // page starts one bit higher because the window is 8 KB.
    wire pg15_bank = kernel_4000_sel & bank_4000[1] | game_bank_sel & mbc_bank[1];
    assign pg15_gb_b = pg15_bank | a14_kernel & a14 | a14 & a14_misc;
    assign pg15_gb = pg15_gb_b;
    assign a13_pass = game_n_save_or_b3 | kernel_n_loadwin & !n_rom;
    wire a13_sel = a13 & a13_pass;
    assign bank0_sel = bank_4000[0] & kernel_4000_sel | mbc_bank[0] & game_bank_sel;
    assign a13_gb_b = a13_sel | bank0_sel;
    assign a13_gb = a13_gb_b;

    // ---- the bank bits
    //
    // bank_bit[k] is what the access puts on byte-address bit 15+k when it
    // reaches U4 (the save window is paged by 16 KB and 8 KB wide, so the
    // page starts at bit 14 with bank0_sel on A13) and on bit 14+k when it
    // reaches U9 (ROM bank N at N x 16 KB, bit 14 being rom_bank[0] on A13
    // through pg15_gb): the same vector, read one bit apart. The save page
    // is bank_4000 in kernel mode and mbc_bank in game mode; the ROM bank
    // is rom_bank with $3000's bit on top; the MBC1 multicart folds its
    // RAM bits into bits 1:5 of a $4000-$7FFF access.
    wire mbc1m_hi_rom = mbc1m_lo & a14 & !a15;
    wire [8:0] bank_bit;
    assign bank_bit[0] = pg15_gb;
    assign bank_bit[1] = kernel_4000_sel & bank_4000[2] | game_bank_sel & mbc_bank[2] | rom_hi_sel & rom_bank[1]
                       | mbc1m_hi_rom & mbc1m_ram[1];       // the LUT also ORs in a game-mode term the page register never loads
    assign bank_bit[2] = kernel_4000_sel & bank_4000[3] | game_bank_sel & mbc_bank[3] | rom_hi_sel & rom_bank[2] | mbc1m_hi_rom & mbc1m_ram[2];
    assign bank_bit[3] = kernel_4000_sel & bank_4000[4] | game_bank_sel & mbc_bank[4] | rom_hi_sel & rom_bank[3] | mbc1m_hi_rom & mbc1m_ram[3];
    assign bank_bit[4] = kernel_4000_sel & bank_4000[5] | game_bank_sel & mbc_bank[5] | rom_hi_sel & rom_bank[4] | mbc1m_lo & mbc1m_a14;
    assign bank_bit[5] = kernel_4000_sel & bank_4000[6] | game_bank_sel & mbc_bank[6] | rom_hi_sel & rom_bank[5] | mbc1m_lo & mbc1m_a14b;
    assign bank_bit[6] = kernel_4000_sel & bank_4000[7] | game_bank_sel & mbc_bank[7] | rom_hi_sel & rom_bank[6];
    assign bank_bit[7] = rom_hi_sel & rom_bank[7];
    wire bank8_sel = !n_4000 & rom_bank8 & !hi_n_win1 & !chk_sel;          // $4000-$7FFF on U9 with $3000 bit 0 set
    assign bank_bit[8] = bank8_sel & (is_mbc5 & game_n_save | kernel_n_loadwin & !mode32_b3);

    // ---- the page, bits 22:15: the loader's address while it runs, else the access's
    wire ld = load_busy_2x;
    wire [7:0] gb_page = mem_ce9_n ? bank_bit[7:0] : bank_bit[8:1];
    wire [7:0] sd_page = wbm_adr_o[22:15] | load_addr[13:6];
    // neither chip's usual access: only u4_win loads the page that way, and
    // the page is $08
    wire gb_page8 = n_save & !kernel_b3_lo & mem_ce9_n;
    wire [7:0] page_d_next = ld ? sd_page : gb_page8 ? 8'h08 : gb_page;
    wire page_ce = kernel_b3_lo | !n_save | ld | !mem_ce9_n | u4_win;

    reg [7:0] page_d, page_q, page_n, page_s;
    initial page_s = 8'hff;
    always @(posedge clk_fx)
        if (page_ce) begin
            page_d <= page_d_next;
            page_q <= page_d;
        end
    wire page_same = (page_d == page_q);
    always @(negedge clk_fx)
        if (page_same) page_n <= page_q;
    always @(posedge clk_fx) page_s <= page_n;

    // ---- the serializer: eight bits MSB first into the 74HC595, then the latch pulse
    reg [2:0] sh_cnt;
    reg sh_start;
    wire page_stable = (page_n == page_s);
    wire sh_clr = sh_run & sh_done | sh_run & sh_start;
    always @(posedge clk_fx) sh_start <= !page_stable;
    always @(posedge clk_fx)
        if (sh_start) sh_run <= 1'b1;
        else if (sh_done) sh_run <= gnd1;
    always @(posedge clk_fx)
        if (sh_clr) begin sh_cnt <= 3'd0; sh_done <= 1'b0; end
        else if (sh_run) begin sh_cnt <= sh_cnt + 3'd1; sh_done <= sh_done ^ (sh_cnt == 3'd7); end
    wire sr_bit = page_s[~sh_cnt];
    assign sr_ser = sh_run & sr_bit & !sh_done;
    assign sr_rclk = sh_run & sh_done & (sh_cnt == 3'd0);

    // ---- the strobes and chip selects
    wire win_6_up = kernel_mode & (win_mode[3] | win_mode[2] & win_mode[1]);
    assign u4_win = a15 & win_a000 & (win_6_up | bank_ff_game & mbc_bank[8]);
    wire u4_extra = u4_win & mbc_bank[7];
    assign n_rom_gb = n_rom & !ld;
    wire n_save_u4 = n_save & !u4_extra;
    assign mem_ce9_n = hi_n_win1 & !ld | chk_sel & !ld | !ld & flash_op;
    assign mem_ce4_n = n_save_u4 | ld | flash_op | !n_rom;
    wire we_gb = a15 & !wr_n & !flash_op & !n_save_u4;
    assign mem_we_n = !n_rom & !ld | ld & byte_we_n | !ld & !we_gb;
    wire lb_n_gb = n_rom ? n_save_u4 : a0;
    assign mem_lb_n = flash_op & cnt[2] | lb_n_gb & !ld | cnt[2] & ld | flash_op & !ld;
    wire ub_n_gb = flash_op | hi_n_win1 | chk_sel | !a0;
    assign mem_ub_n = ld ? !cnt[2] : ub_n_gb;
    assign mem_a0 = ld ? cnt[3] : !n_rom ? a1 : n_save ? rtc_sel0 : a0;
    assign mem_a_t = !ld & flash_op | !ld & n_rom & n_save_u4;
    assign mem_a13_t = n_save & hi_n_win1 & !ld | n_save & !ld & chk_sel;
    assign p85 = a13 & wr_n | !a15 & wr_n | wr_n & !a14;
    assign gb_reset_drive = reset_drive & gb_reset_n;
endmodule
