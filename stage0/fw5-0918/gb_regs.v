// FW5-0918's Game Boy registers: the FW4 module (stage0/rtl/gb_regs.v, which
// says what each register does) with these differences, read from the
// design and proved:
//
//   - one write strobe: FW5 clocks every register from /WR and puts A15
//     low in the $7Fxx enables, where FW4 has a second /WR | A15 clock
//   - no /RESET-level reset: FW4 resets the mode registers and blocks
//     writes for the cycle after /RESET falls (rst); FW5's /WR registers
//     are reset by the /RESET edge only, which fw5-noedge.py takes out of
//     the design this is proved against
//   - the $7Fxx key is the unlock block's last register alone (FW5's
//     unlock has one register per key), with A15 low
//   - the RTC values to set are only hours, day and year ($A00A, $A00B,
//     $A00E): no FW5 register is written as FW4's seconds, minutes,
//     weekday, month and $7FD0 go flag are
//   - the RAM bank: MBC3 takes banks $00-$07 (three bits; FW4 $00-$03),
//     and MBC1's mode-1 bank takes four masked bits as MBC5's does (FW4
//     two)
//   - the $7FB4 command flag: a rising data interrupt sets it with the
//     window enabled ($7F30 bit 0), as on FW4, and clears it without
//   - the shared decodes FW5's other blocks read come out of here
//
// The MBC3 clock select ($08-$0C written to $4000-$5FFF) sets the RAM
// bank register to all ones and loads rtc_sel, as on FW4; psram_ctrl
// turns that into an access to U4 page $08, while gb_data_out drives the
// read from its latched clock registers.
//
// Block: built by scripts/fpga/simblk.py from stage0/blocks/gb_regs.blk
// (stage0/fw5-0918/gb_regs.sim has its arguments), with the names in
// gb_regs.names.

module gb_regs (
    input clk_wr_a,                 // /WR
    input a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input unlocked,                 // the unlock block's last key register
    input d_key_pattern,            // d[7:3] == 11100 (unlock)
    input int_data,                 // the SD data interrupt (sd_controller_wb)
    input int_data_q,               // its mode-domain copy
    input reg_dec,                  // the register window (gb_data_out)
    // shared decodes, from the blocks that make them
    input adr_014d_lo3, win_a000,
    input game_mbc1m, is_mbc5, n_mbc1, n_4000, type_grp, type_lo,
    input gnd1,                     // the shared constant-0 LUT
    // $7Fxx
    output reg kernel_mode,
    output reg mode32_b3,
    output reg win_en, win_en1,
    output reg [3:0] win_mode,
    output reg [3:0] mbc_type,
    output reg rtc_flag,
    output reg [6:0] hdr_chk,
    output reg [7:0] cmd_lba0_i, cmd_lba1_i, cmd_lba2_i, cmd_lba3_i,
    output reg cmd_read, cmd_write,
    output reg cmd_b4_flag,
    output reg load_win, load_start,
    output reg flash_op,
    output reg reset_req,
    // the banks
    output reg [7:0] rom_bank,
    output reg rom_bank8,
    output reg [7:0] bank_4000,
    output reg [8:0] mbc_bank,      // [7:0] the RAM bank, [8] the RAM enable
    output reg [7:0] rtc_sel,
    output reg mbc1_mode,
    output reg [3:0] mbc1m_ram,
    output reg [1:0] mbc1m_hi,
    output reg mbc1m_mode, mbc1m_sel,
    // the RTC values to set
    output reg [7:0] rtc_set_hour, rtc_set_day, rtc_set_year,
    // decodes shared outside
    output key_ok,                  // !a15 & unlocked
    output dec_7fcx,                // $7FC0-C7 and $7FD0-D7, unlocked
    output wr_7fbx,                 // $7FB0-B7, unlocked
    output wr_7fc3,
    output rtc_win,                 // the register window's offsets $x8-$xF, kernel mode
    output rtc_set_wr,              // ... at $A000-$BFFF
    output r2000, n_r6000,
    output game_n3,                 // game mode, type bit 3 clear
    output type0_n2, type1_n2,      // type bit 0 (1) without bit 2, bit 1 without bit 2
    output rtc_sel_d,               // d[7:4] == 0 for MBC3 (the clock select's data, high bits)
    output d_e4, d_0a,              // d == $E4 (with d_key_pattern), d[3:0] == $A
    output a10_any, a210_any,       // a1 | a0, a2 | a1 | a0
    output a2_n1,                   // a2 | !a1
    output a1_n2,                   // a1 & !a2
    output a210_4, a210_6,          // a[2:0] == 4, == 6
    output n_lo0_c                  // not $xC0, $xD0, $xE0 or $xF0
);
    wire [15:0] a = {a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0};
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};

    // ---- the shared decodes
    assign key_ok = !a15 & unlocked;
    assign a10_any = a1 | a0;
    assign a210_any = a2 | a1 | a0;
    assign a2_n1 = a2 | !a1;
    assign a1_n2 = a1 & !a2;
    assign a210_4 = a[2:0] == 3'd4;
    assign a210_6 = a[2:0] == 3'd6;
    assign n_lo0_c = !(a7 & a6 & !a3 & !a210_any);
    assign d_e4 = d_key_pattern & d2 & !d1 & !d0;
    assign d_0a = d[3:0] == 4'ha;
    assign r2000 = !a15 & !a14 & a13;
    assign n_r6000 = !(!a15 & a14 & a13);
    assign game_n3 = !kernel_mode & !mbc_type[3];
    assign type0_n2 = mbc_type[0] & !mbc_type[2];
    assign type1_n2 = mbc_type[1] & !mbc_type[2];
    assign rtc_sel_d = d[7:4] == 4'd0 & !mbc_type[2] & mbc_type[1] & mbc_type[0];

    // ---- $7Fxx, after the unlock
    wire key_3x = key_ok & !a3;
    wire dec_7f3x = key_3x & (a[6:4] == 3'b011);
    assign dec_7fcx = key_3x & a7 & a6 & !a5;
    wire wr_7f3x = dec_7f3x & !a7;
    assign wr_7fbx = dec_7f3x & a7;
    assign wr_7fc3 = dec_7fcx & (a[4:0] == 5'h03);
    wire lock = key_ok & (a[7:0] == 8'hf0) & d_e4;              // $7FF0 = $E4

    initial begin
        kernel_mode = 1'b1; mode32_b3 = 1'b1;
        win_en = 1'b0; win_en1 = 1'b0; win_mode = 4'd0; mbc_type = 4'd0; rtc_flag = 1'b0;
        rom_mask = 8'd0; rom_mask8 = 1'b0; ram_mask = 4'd0; hdr_chk = 7'd0;
        cmd_lba0_i = 8'd0; cmd_lba1_i = 8'd0; cmd_lba2_i = 8'd0; cmd_lba3_i = 8'd0;
        cmd_read = 1'b0; cmd_write = 1'b0; cmd_b4_flag = 1'b0;
        load_win = 1'b0; load_start = 1'b0; flash_op = 1'b0; reset_req = 1'b0;
        rom_bank = 8'd0; rom_bank8 = 1'b0; bank_4000 = 8'd0; mbc_bank = 9'd0; rtc_sel = 8'd0;
        mbc1_mode = 1'b0; mbc1_hi = 2'd0; mbc1m_ram = 4'd0; mbc1m_hi = 2'd0; mbc1m_mode = 1'b0; mbc1m_sel = 1'b0;
        rtc_set_hour = 8'd0; rtc_set_day = 8'd0; rtc_set_year = 8'd0;
    end
    reg [7:0] rom_mask;
    reg rom_mask8;
    reg [3:0] ram_mask;
    always @(posedge clk_wr_a) begin
        if (wr_7f3x & a[2:0] == 3'd2) {kernel_mode, mode32_b3} <= {d7, d3};
        if (wr_7f3x & a[2:0] == 3'd0) {win_en1, win_en} <= d[1:0];
        if (dec_7fcx & a[4:0] == 5'h00) win_mode <= d[3:0];
        if (wr_7f3x & a[2:0] == 3'd6) {load_start, load_win} <= {d1, d0};
        if (wr_7f3x & a[2:0] == 3'd7) {rtc_flag, mbc_type} <= {d7, d[3:0]};
        if (wr_7fbx & a[2:0] == 3'd0) cmd_lba0_i <= d;
        if (wr_7fbx & a[2:0] == 3'd1) cmd_lba1_i <= d;
        if (wr_7fbx & a[2:0] == 3'd2) cmd_lba2_i <= d;
        if (wr_7fbx & a[2:0] == 3'd3) cmd_lba3_i <= d;
        if (dec_7fcx & a[4:0] == 5'h01) rom_mask <= d;
        if (dec_7fcx & a[4:0] == 5'h02) rom_mask8 <= d0;
        if (wr_7fc3) hdr_chk <= d[6:0];
        if (dec_7fcx & a[4:0] == 5'h04) ram_mask <= d[3:0];
        if (dec_7fcx & a[4:0] == 5'h12) flash_op <= d0;
        // the flags the lock write clears
        if (key_ok & a[7:0] == 8'hb4) {cmd_write, cmd_read} <= {d7, !d7};
        else if (lock) {cmd_write, cmd_read} <= 2'b00;
        if (key_ok & a[7:0] == 8'he0) reset_req <= d7;
        else if (lock) reset_req <= 1'b0;
    end

    // ---- the command flag: a rising data interrupt sets it with the window
    // enabled and clears it without; the $7FB4 write clears it
    wire int_set = int_data & win_en & !int_data_q;
    wire int_clr = int_data & !win_en & !int_data_q;
    always @(posedge clk_wr_a or posedge int_clr or posedge int_set)
        if (int_clr) cmd_b4_flag <= 1'b0;
        else if (int_set) cmd_b4_flag <= 1'b1;
        else if (a == 16'h7fb4) cmd_b4_flag <= gnd1;

    // ---- the banks
    wire r0000 = !a15 & !a14 & !a13;                            // $0000-$1FFF
    wire r2000_lo = r2000 & !a12;                               // $2000-$2FFF
    wire r3000 = r2000 & a12;
    wire r4000 = !a15 & a14 & !a13;                             // $4000-$5FFF
    wire r6000 = !n_r6000;
    wire mbc1 = mbc_type == 4'd1;
    wire mbc2 = mbc_type == 4'd2;
    wire mbc3 = mbc_type == 4'd3;
    wire mbc5 = mbc_type == 4'd4;
    reg [1:0] mbc1_hi;

    always @(posedge clk_wr_a)
        if (kernel_mode) begin
            if (r2000_lo) rom_bank <= d;
        end else if (mbc1) begin
            if (r2000) rom_bank <= {1'b0, mbc1_hi[1] & rom_mask[6], mbc1_hi[0] & rom_mask[5], d[4:0] & rom_mask[4:0]};
            else if (r4000 & !mbc1_mode) rom_bank[7:5] <= {1'b0, d1 & rom_mask[6], d0 & rom_mask[5]};
        end else if (mbc2) begin
            if (r2000 & a8) rom_bank <= {3'b000, d[4:0]};
        end else if (mbc3) begin
            if (r2000) rom_bank <= {1'b0, d[6:0]};
        end else if (mbc5) begin
            if (r2000_lo) rom_bank <= d & rom_mask;
        end
    always @(posedge clk_wr_a)
        if (r3000 & (kernel_mode | mbc5)) rom_bank8 <= d0 & (kernel_mode | rom_mask8);
    always @(posedge clk_wr_a)
        if (kernel_mode & r4000) bank_4000 <= d;

    // the RAM bank, the RTC select and the RAM enable
    wire rtc_sel_wr = mbc3 & r4000 & d[7:4] == 4'd0 & d3 & (!d2 | d[1:0] == 2'd0);   // $08-$0C
    // MBC3 takes RAM banks $00-$07 (FW4 $00-$03), and every type takes the
    // four masked bits (FW4 two for MBC1 and MBC3)
    wire ram_bank_wr = r4000 & (mbc1 & mbc1_mode | mbc3 & d[7:3] == 5'd0 | mbc5);
    wire [7:0] ram_bank_val = {4'd0, d[3:0] & ram_mask};
    wire ram_en_wr = r0000 & !type_grp & !(mbc2 & a8);
    always @(posedge clk_wr_a)
        if (!kernel_mode) begin
            if (rtc_sel_wr) begin
                mbc_bank[7:0] <= 8'hff;
                rtc_sel <= d;
            end else if (ram_bank_wr)
                mbc_bank[7:0] <= ram_bank_val;
            if (ram_en_wr) mbc_bank[8] <= d_0a;
        end

    // MBC1: the mode and the two high bits
    always @(posedge clk_wr_a)
        if (!kernel_mode & !n_mbc1) begin
            if (r6000) mbc1_mode <= d0;
            if (r4000 & (!mbc1_mode | mbc_type[2])) mbc1_hi <= d[1:0];
        end

    // the multicart's registers
    always @(posedge clk_wr_a)
        if (game_mbc1m) begin
            if (r4000) {mbc1m_sel, mbc1m_mode} <= {mbc1_mode & d1, mbc1_mode & d0};
            else if (r6000) {mbc1m_sel, mbc1m_mode} <= {mbc1_hi[1] & d0, mbc1_hi[0] & d0};
            if (r2000) mbc1m_ram <= d[3:0] & rom_mask[3:0];
            if (r4000) mbc1m_hi <= d[1:0];
            else if (r2000) mbc1m_hi <= mbc1_hi & rom_mask[5:4];
            else if (r6000) mbc1m_hi <= mbc1_hi;
        end

    // ---- the RTC values to set: the register window's offsets $A00A, $A00B, $A00E
    assign rtc_win = adr_014d_lo3 & !a6 & kernel_mode & reg_dec;
    assign rtc_set_wr = a15 & win_a000 & rtc_win;
    always @(posedge clk_wr_a)
        if (rtc_set_wr & !a4)
            case (a[2:0])
                3'd2: rtc_set_hour <= d;
                3'd3: rtc_set_day <= d;
                3'd6: rtc_set_year <= d;
                default: ;
            endcase

`ifdef FORMAL
    // The shared decodes arrive from the blocks that make them, from the
    // address, the data and this block's type register. Stated as
    // input assumptions.
    always @* begin
        env_adr_014d_lo3:   assume (adr_014d_lo3 == (!a7 & a3 & !a5));
        env_win_a000:       assume (win_a000 == (a13 & !a14));
        env_d_key_pattern:  assume (d_key_pattern == (d[7:3] == 5'b11100));
        env_n_4000:         assume (n_4000 == (!a14 | a15));
        env_n_mbc1:         assume (n_mbc1 == (mbc_type[3] | !mbc_type[0] | mbc_type[1]));
        env_is_mbc5:        assume (is_mbc5 == (mbc_type == 4'd4));
        env_type_lo:        assume (type_lo == (mbc_type[0] | mbc_type[1]));
        env_type_grp:       assume (type_grp == (mbc_type[3] | mbc_type[1] & mbc_type[2] | !mbc_type[1] & !mbc_type[0] & !mbc_type[2]));
        env_game_mbc1m:     assume (game_mbc1m == (!kernel_mode & !n_mbc1 & mbc_type[2]));
        env_gnd1:           assume (gnd1 == 1'b0);
    end
`endif
endmodule
