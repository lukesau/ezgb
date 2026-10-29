// The pSRAM controller, EZ Flash's own: what decides which chip a Game Boy
// access reaches, the page (the address above A13) that access gets from
// the bank registers and the MBC state, the pipeline that carries the page
// into the fast clock and the serializer that shifts it into the 74HC595
// behind the address pins, and the byte strobes, write enable, chip
// selects and address tristate. The SD load path's half of the pins is in
// stage0/rtl/sd_mem_path.v; the data bus is not here.
//
// What is known, from re/stage0/docs/design.md and the write decode:
//
//   - two pSRAMs: U9 (game ROM, /CE on P52) and U4 (saves, /CE on P60)
//   - in kernel mode $7F32 bit 7 is set: $2000 is a plain 8-bit ROM bank
//     latch (rom_bank, with $3000 bit 0 as rom_bank8), $4000 a second
//     register (bank_4000) that pages the save window, $7FC0 selects
//     what $A000-$BFFF shows (0 the SD sector buffer, 1 a window on U9,
//     2 the ROM load window with $7F36, 3 the save page), and $7F32 bit
//     3 (mode32_b3) and the load window (load_win) gate the rest
//   - in game mode the MBC type at $7F37 (mbc_type: 1 MBC1, 2 MBC2, 3
//     MBC3, 4 MBC5, 5 MBC1 multicart) decides how rom_bank loads, a
//     9-bit register (mbc_bank) loads on every write by that logic and
//     pages the save RAM, with bit 8 as the RAM enable, and the MBC1
//     multicart keeps four more registers (mbc1m_*); a bank register of
//     all ones (bank_ff_game) is special
//   - the address $x14D in game mode (adr_014d) is the header checksum,
//     served from a register, not from U9
//   - the page is byte-address bits 22:15 (page_d, then page_q); when it
//     changes it is sampled on the falling edge (page_n), compared against
//     the last value shifted out (page_s, starting all ones) and shifted
//     out MSB first over eight clocks, then latched (sr_ser, sr_rclk; the
//     shift clock is the memory clock, elsewhere)
//   - the names of the game-mode registers and of several decode terms
//     say how they are written or used, not what the kernel calls them;
//     the proof does not depend on them
//
// The P51 output latch that carries A13 during a load is a latch, not a
// flip-flop, and stays outside the block (a13_latch is its output).
//
// Block: stage0/blocks/psram_ctrl.blk.

module psram_ctrl (
    input a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,
    input wr_n,
    input gb_reset_n,
    input clk_fx,
    input kernel_mode,              // $7F32 bit 7
    input a13_latch,                // the P51 output latch, outside
    input [7:0] bank_4000,          // the $4000 register (kernel mode)
    input byte_we_n,                // the SD byte sequencer (sd_mem_path)
    input [3:2] cnt,
    input flash_op,                 // $7FD2 bit 0
    input mbc1_mode,                // the MBC1 mode bit, $6000-$7FFF (gb_regs)
    input gnd1,                     // a constant-0 LUT in the data host block
    input [13:6] load_addr,         // the loader's destination, upper bits
    input load_busy_2x,             // port EF, 2x-domain copy
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
    output mem_a13_t,               // P51's tristate (A13 shares the flash MISO pin)
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
    output [13:13] mem_a_gb,        // A13 for sd_mem_path's pad mux
    output a13_gb_b, a13_gb,
    output kernel_b3_lo,
    output bank_hi_ones, bank_lo_ones,
    output chk_sel, adr_014d, adr_014d_lo,
    output hi_n_win1,
    output n_save,
    output bank0_sel,
    output type_grp, type_lo,
    output a13_sel,
    output n_rom,
    output game_mbc1m,
    output n_4000,
    output n_mbc1, is_mbc5
);
    // ---- what the access is
    assign adr_014d_lo = !a7 & a3 & !a5 & !a4;
    wire adr_014d_mid = a8 & !a12 & !a11 & !a9;
    wire adr_014d_lo2 = !a1 & a0 & !a13 & a2;
    wire adr_014d_hi = !a14 & a6 & !a10;
    assign adr_014d = adr_014d_mid & adr_014d_lo2 & adr_014d_hi & adr_014d_lo;   // $x14D
    assign chk_sel = !kernel_mode & adr_014d | kernel_mode & mode32_b3 & !a15;      // served from a register, not U9
    assign n_4000 = !a14 | a15;
    assign kernel_b3_lo = kernel_mode & !a15 & mode32_b3;
    wire win_not3 = !win_mode[0] | win_mode[3] | !win_mode[1] | win_mode[2];
    wire n_win1_k = win_mode[3] | !kernel_mode | !win_a000 | win_mode[2];
    assign hi_n_win1 = n_win1_k & a15 | win_mode[1] & a15 | a15 & !win_mode[0];    // a15, unless the $7FC0=1 window
    assign n_rom = hi_n_win1 | chk_sel;                                              // not a U9 access
    wire n_ram_win = !win_a000 | !a15 | !mbc_bank[8] & !kernel_mode;                // not $A000-$BFFF with RAM enabled
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
    assign a13_sel = game_n_save_or_b3 & a13 | kernel_n_loadwin & a13 & !n_rom;
    assign bank0_sel = bank_4000[0] & kernel_4000_sel | mbc_bank[0] & game_bank_sel;
    assign a13_gb_b = a13_sel | bank0_sel;
    assign a13_gb = a13_gb_b;
    wire a13_gb_sel = !n_save & a13_gb & n_rom | n_save & a13_latch & n_rom;
    assign mem_a_gb[13] = a13_gb_sel | !hi_n_win1 & pg15_gb & !chk_sel;

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
    wire [7:0] page_d_next = ld ? sd_page : gb_page;
    wire page_ce = kernel_b3_lo | !n_save | ld | !mem_ce9_n;

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
    assign mem_ce9_n = hi_n_win1 & !ld | chk_sel & !ld | !ld & flash_op;
    assign mem_ce4_n = n_save | ld | flash_op | !n_rom;
    wire we_gb = a15 & !wr_n & !flash_op & !n_save;
    assign mem_we_n = !n_rom & !ld | ld & byte_we_n | !ld & !we_gb;
    wire lb_n_gb = a0 & n_save | n_save & hi_n_win1 | a0 & !hi_n_win1 & !chk_sel | n_save & chk_sel;
    assign mem_lb_n = flash_op & cnt[2] | lb_n_gb & !ld | cnt[2] & ld | flash_op & !ld;
    wire ub_n_gb = flash_op | hi_n_win1 | chk_sel | !a0;
    assign mem_ub_n = ld ? !cnt[2] : ub_n_gb;
    assign mem_a0 = ld ? cnt[3] : (a0 & hi_n_win1 | a0 & chk_sel | !hi_n_win1 & !chk_sel & a1);
    assign mem_a_t = !ld & flash_op | !ld & n_rom & n_save;
    assign mem_a13_t = n_save & hi_n_win1 & !ld | n_save & !ld & chk_sel;
    assign p85 = a13 & wr_n | !a15 & wr_n | wr_n & !a14;
    assign gb_reset_drive = reset_drive & gb_reset_n;
endmodule
