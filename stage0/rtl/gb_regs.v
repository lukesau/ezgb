// The Game Boy's registers, EZ Flash's own: everything the console writes
// into the FPGA, in the two write-strobe clock domains. clk_wr_b is the
// strobe for the $7Fxx registers, which take a write only while the unlock
// sequence has been written (the unlock block's state); clk_wr_a is the
// strobe for $0000-$7FFF and the $A000 window, where the kernel loads the
// bank and RTC registers directly and a game writes its MBC.
//
// The $7Fxx registers (after $7F00=$E1, $7F10=$E2, $7F20=$E3; $7FF0=$E4
// locks again), in the order the kernel uses them:
//
//   $7F32  bit 7 the kernel/game switch (1 at power-up), bit 3 with it
//   $7F30  bits 1:0 the $A000 window enables (bit 0 makes the sector buffer
//          readable, bit 1 makes it read $01)
//   $7FC0  bits 3:0 what the $A000 window shows (see sd_mem_path)
//   $7F37  bits 3:0 the MBC type a game gets (1 MBC1, 2 MBC2, 3 MBC3,
//          4 MBC5, 5 MBC1 multicart), bit 7 the RTC flag
//   $7FC1  the ROM bank mask, $7FC2 bit 0 its ninth bit, $7FC4 bits 3:0
//          the RAM bank mask, $7FC3 the header checksum the game reads at
//          $014D (bit 7 is served from the data pad's own register)
//   $7FB0-B3  the sector address, $7FB4 the sector count with bit 7 for a
//          write; $7FB4 also clears the command flag that the data
//          interrupt sets again when the transfer is done
//   $7F36  bit 0 the load window, bit 1 the loader's start
//   $7FD2  bit 0 the flash writer's go
//   $7FD0  bit 0 the RTC set's go, $7FE0 bit 7 the soft reset request:
//          flags the PicoBlaze side reads, cleared again by the lock write
//          (as are the $7FB4 command bits)
//
// In kernel mode the bank registers are plain: $2000-$2FFF the ROM bank,
// $3000-$3FFF its bit 8, $4000-$5FFF the $4000 bank register, and the
// register window's offsets $A008-$A00E the seven RTC values to set
// (seconds, minutes, hours, day, weekday, month, year; in the window
// gb_data_out reads them back at the same offsets). In game mode the
// writes go through the MBC the type names, masked by the bank masks:
//
//   MBC1   $2000-$3FFF the low five bank bits, $4000-$5FFF the two high
//          bits (mbc1_hi, folded into the bank in mode 0) or the RAM bank
//          (mode 1), $6000-$7FFF the mode
//   MBC2   $2100-$21FF (bit 8 set) the four bank bits, unmasked
//   MBC3   $2000-$3FFF the seven bank bits unmasked, $4000-$5FFF the RAM
//          bank ($00-$03) or the RTC register select ($08-$0C), which also
//          sets the bank register to all ones so the data bus output
//          serves the RTC (with the RAM enable, as on an MBC3)
//   MBC5   $2000-$2FFF the eight bank bits, $3000-$3FFF bit 8, $4000-$5FFF
//          the four RAM bank bits
//   MBC1M  (multicart) its own registers: mbc1m_ram from $2000-$3FFF, and
//          the mbc1m_* bits below; the plain bank register holds
//
// The RAM enable (mbc_bank[8]) is $0A written to $0000-$1FFF for types
// 1-5 (for MBC2 with address bit 8 clear).
//
// rst is the cycle after /RESET falls: it resets the mode registers
// (asynchronously, the slice's SR) and blocks most writes for that cycle.
// Every register starts at 0 but the two $7F32 mode bits.
//
// Block: stage0/blocks/gb_regs.blk.

module gb_regs (
    input clk_wr_a,                 // the write strobe for $0000-$7FFF and the $A000 window
    input clk_wr_b,                 // the write strobe for $7Fxx
    input a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15,
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input gb_reset_n_q,             // /RESET's pad input register
    input gb_reset_n_q2,            // the same, a 2x clock later
    input unlocked, key_e1,         // the unlock state (unlock)
    input d_key_pattern,            // d[7:3] == 11100 (unlock)
    input int_data,                 // the SD data interrupt (sd_controller_wb)
    input int_data_q,               // its mode-domain copy
    input reg_dec,                  // the register window (gb_data_out)
    // shared decodes, from the blocks that make them
    input a1a0_zero, dec_x23y21_s1, adr_014d_lo, win_a000,
    input game_mbc1m, is_mbc5, n_mbc1, n_4000, type_grp, type_lo,
    input gnd2,                     // a constant-0 LUT
    // $7Fxx
    output reg kernel_mode,
    output reg mode32_b3,
    output reg win_en, win_en1,
    output reg [3:0] win_mode,
    output reg [3:0] mbc_type,
    output reg rtc_flag,
    output reg [7:0] rom_mask,
    output reg rom_mask8,
    output reg [3:0] ram_mask,
    output reg [6:0] hdr_chk,
    output reg [7:0] cmd_lba0_i, cmd_lba1_i, cmd_lba2_i, cmd_lba3_i,
    output reg cmd_read, cmd_write,
    output reg cmd_b4_flag,
    output reg load_win, load_start,
    output reg flash_op,
    output reg rtc_set_go,
    output reg reset_req,
    // the banks
    output reg [7:0] rom_bank,
    output reg rom_bank8,
    output reg [7:0] bank_4000,
    output reg [8:0] mbc_bank,      // [7:0] the RAM bank, [8] the RAM enable
    output reg [7:0] rtc_sel,
    output reg mbc1_mode,
    output reg [1:0] mbc1_hi,
    output reg [3:0] mbc1m_ram,
    output reg [1:0] mbc1m_hi,
    output reg mbc1m_mode, mbc1m_sel,
    // the RTC values to set
    output reg [7:0] rtc_set_sec, rtc_set_min, rtc_set_hour, rtc_set_day, rtc_set_wday, rtc_set_month, rtc_set_year,
    // decode terms shared outside
    output rst,
    output dec_7f3x,                // $7F3x and $7FBx, unlocked
    output wr_7fc3,
    output dec_x9y22_s2             // !a2 | rst
);
    wire [15:0] a = {a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0};
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};

    assign rst = !gb_reset_n_q & gb_reset_n_q2;
    assign dec_x9y22_s2 = !a2 | rst;

    // ---- $7Fxx, after the unlock
    wire key_ok = unlocked & !key_e1;
    assign dec_7f3x = key_ok & (a[6:3] == 4'b0110);
    wire dec_7fcx = key_ok & a7 & a6 & !a5 & !a3;              // $7FC0-C7 and $7FD0-D7
    wire wr_7f3x = dec_7f3x & !a7;
    wire wr_7fbx = dec_7f3x & a7;
    assign wr_7fc3 = dec_7fcx & (a[4:0] == 5'h03) & !rst;
    wire lock = key_ok & (a[7:0] == 8'hf0) & d_key_pattern & d2 & !d1 & !d0;   // $7FF0 = $E4

    // every register starts at 0 but the two mode bits
    initial begin
        kernel_mode = 1'b1; mode32_b3 = 1'b1;
        win_en = 1'b0; win_en1 = 1'b0; win_mode = 4'd0; mbc_type = 4'd0; rtc_flag = 1'b0;
        rom_mask = 8'd0; rom_mask8 = 1'b0; ram_mask = 4'd0; hdr_chk = 7'd0;
        cmd_lba0_i = 8'd0; cmd_lba1_i = 8'd0; cmd_lba2_i = 8'd0; cmd_lba3_i = 8'd0;
        cmd_read = 1'b0; cmd_write = 1'b0; cmd_b4_flag = 1'b0;
        load_win = 1'b0; load_start = 1'b0; flash_op = 1'b0; rtc_set_go = 1'b0; reset_req = 1'b0;
        rom_bank = 8'd0; rom_bank8 = 1'b0; bank_4000 = 8'd0; mbc_bank = 9'd0; rtc_sel = 8'd0;
        mbc1_mode = 1'b0; mbc1_hi = 2'd0; mbc1m_ram = 4'd0; mbc1m_hi = 2'd0; mbc1m_mode = 1'b0; mbc1m_sel = 1'b0;
        rtc_set_sec = 8'd0; rtc_set_min = 8'd0; rtc_set_hour = 8'd0; rtc_set_day = 8'd0;
        rtc_set_wday = 8'd0; rtc_set_month = 8'd0; rtc_set_year = 8'd0;
    end
    // the mode registers, reset asynchronously
    always @(posedge clk_wr_b or posedge rst)
        if (rst) begin
            kernel_mode <= 1'b1;
            mode32_b3 <= 1'b1;
            win_en <= 1'b0;
            win_mode <= 4'd0;
        end else begin
            if (wr_7f3x & a[2:0] == 3'd2) {kernel_mode, mode32_b3} <= {d7, d3};
            if (wr_7f3x & a[2:0] == 3'd0) win_en <= d0;
            if (dec_7fcx & a[4:0] == 5'h00) win_mode <= d[3:0];
        end
    always @(posedge clk_wr_b)
        if (!rst) begin
            if (wr_7f3x & a[2:0] == 3'd0) win_en1 <= d1;
            if (wr_7f3x & a[2:0] == 3'd6) {load_start, load_win} <= {d1, d0};
            if (wr_7f3x & a[2:0] == 3'd7) {rtc_flag, mbc_type} <= {d7, d[3:0]};
            if (wr_7fbx & a[2:0] == 3'd0) cmd_lba0_i <= d;
            if (wr_7fbx & a[2:0] == 3'd1) cmd_lba1_i <= d;
            if (wr_7fbx & a[2:0] == 3'd2) cmd_lba2_i <= d;
            if (wr_7fbx & a[2:0] == 3'd3) cmd_lba3_i <= d;
            if (dec_7fcx & a[4:0] == 5'h01) rom_mask <= d;
            if (dec_7fcx & a[4:0] == 5'h02) rom_mask8 <= d0;
            if (dec_7fcx & a[4:0] == 5'h03) hdr_chk <= d[6:0];
            if (dec_7fcx & a[4:0] == 5'h04) ram_mask <= d[3:0];
            if (dec_7fcx & a[4:0] == 5'h12) flash_op <= d0;
            // the flags the lock write clears
            if (key_ok & a[7:0] == 8'hb4) {cmd_write, cmd_read} <= {d7, !d7};
            else if (lock) {cmd_write, cmd_read} <= 2'b00;
            if (key_ok & a[7:0] == 8'hd0) rtc_set_go <= d0;
            else if (lock) rtc_set_go <= 1'b0;
            if (key_ok & a[7:0] == 8'he0) reset_req <= d7;
            else if (lock) reset_req <= 1'b0;
        end

    // ---- the command flag: set when the data interrupt rises, cleared by the $7FB4 write
    wire int_rise = int_data & win_en & !int_data_q;            // the asynchronous set
    always @(posedge clk_wr_a or posedge int_rise)
        if (int_rise) cmd_b4_flag <= 1'b1;
        else if (a == 16'h7fb4) cmd_b4_flag <= gnd2;

    // ---- the banks
    wire r0000 = !a15 & !a14 & !a13;                            // $0000-$1FFF
    wire r2000 = !a15 & !a14 & a13;                             // $2000-$3FFF
    wire r2000_lo = r2000 & !a12;                               // $2000-$2FFF
    wire r3000 = r2000 & a12;
    wire r4000 = !a15 & a14 & !a13;                             // $4000-$5FFF
    wire r6000 = !a15 & a14 & a13;                              // $6000-$7FFF
    wire mbc1 = mbc_type == 4'd1;
    wire mbc2 = mbc_type == 4'd2;
    wire mbc3 = mbc_type == 4'd3;
    wire mbc5 = mbc_type == 4'd4;

    // the ROM bank
    always @(posedge clk_wr_a)
        if (kernel_mode) begin
            if (r2000_lo & !rst) rom_bank <= d;
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
        if (r3000 & !rst & (kernel_mode | mbc5)) rom_bank8 <= d0 & (kernel_mode | rom_mask8);
    always @(posedge clk_wr_a)
        if (kernel_mode & r4000 & !rst) bank_4000 <= d;

    // the RAM bank, the RTC select and the RAM enable
    wire rtc_sel_wr = mbc3 & r4000 & d[7:4] == 4'd0 & d3 & (!d2 | d[1:0] == 2'd0);   // $08-$0C
    wire ram_bank_wr = r4000 & (mbc1 & mbc1_mode | mbc3 & d[7:4] == 4'd0 & !d2 | mbc5);
    wire [7:0] ram_bank_val = mbc5 ? {4'd0, d[3:0] & ram_mask} : {6'd0, d[1:0] & ram_mask[1:0]};
    wire ram_en_wr = r0000 & !type_grp & !(mbc2 & a8);
    always @(posedge clk_wr_a)
        if (!kernel_mode & !rst) begin
            if (rtc_sel_wr) begin
                mbc_bank[7:0] <= 8'hff;
                rtc_sel <= d;
            end else if (ram_bank_wr)
                mbc_bank[7:0] <= ram_bank_val;
            if (ram_en_wr) mbc_bank[8] <= d[3:0] == 4'ha;
        end

    // MBC1: the mode and the two high bits
    always @(posedge clk_wr_a or posedge rst)
        if (rst) begin
            mbc1_mode <= 1'b0;
            mbc1_hi <= 2'd0;
        end else if (!kernel_mode & !n_mbc1) begin
            if (r6000) mbc1_mode <= d0;
            if (r4000 & (!mbc1_mode | mbc_type[2])) mbc1_hi <= d[1:0];
        end

    // the multicart's registers
    always @(posedge clk_wr_a or posedge rst)
        if (rst) begin
            mbc1m_mode <= 1'b0;
            mbc1m_sel <= 1'b0;
        end else if (game_mbc1m) begin
            if (r4000) {mbc1m_sel, mbc1m_mode} <= {mbc1_mode & d1, mbc1_mode & d0};
            else if (r6000) {mbc1m_sel, mbc1m_mode} <= {mbc1_hi[1] & d0, mbc1_hi[0] & d0};
        end
    always @(posedge clk_wr_a)
        if (game_mbc1m & !rst) begin
            if (r2000) mbc1m_ram <= d[3:0] & rom_mask[3:0];
            if (r4000) mbc1m_hi <= d[1:0];
            else if (r2000) mbc1m_hi <= mbc1_hi & rom_mask[5:4];
            else if (r6000) mbc1m_hi <= mbc1_hi;
        end

    // ---- the RTC values to set: the register window's offsets $A008-$A00E, kernel mode
    wire rtc_set_wr = !rst & kernel_mode & reg_dec & a15 & win_a000 & !a6 & adr_014d_lo;
    always @(posedge clk_wr_a)
        if (rtc_set_wr)
            case (a[2:0])
                3'd0: rtc_set_sec <= d;
                3'd1: rtc_set_min <= d;
                3'd2: rtc_set_hour <= d;
                3'd3: rtc_set_day <= d;
                3'd4: rtc_set_wday <= d;
                3'd5: rtc_set_month <= d;
                3'd6: rtc_set_year <= d;
                default: ;
            endcase

`ifdef FORMAL
    // The shared decodes arrive from the blocks that make them, from the
    // address, the data and this block's own type register. Stated as
    // input assumptions.
    always @* begin
        env_a1a0_zero:      assume (a1a0_zero == (!a0 & !a1));
        env_dec_x23y21_s1:  assume (dec_x23y21_s1 == (!a1 | !a2));
        env_adr_014d_lo:    assume (adr_014d_lo == (!a7 & a3 & !a5 & !a4));
        env_win_a000:       assume (win_a000 == (a13 & !a14));
        env_d_key_pattern:  assume (d_key_pattern == (d[7:3] == 5'b11100));
        env_n_4000:         assume (n_4000 == (!a14 | a15));
        env_n_mbc1:         assume (n_mbc1 == (mbc_type[3] | !mbc_type[0] | mbc_type[1]));
        env_is_mbc5:        assume (is_mbc5 == (mbc_type == 4'd4));
        env_type_lo:        assume (type_lo == (mbc_type[0] | mbc_type[1]));
        env_type_grp:       assume (type_grp == (mbc_type[3] | mbc_type[1] & mbc_type[2] | !mbc_type[1] & !mbc_type[0] & !mbc_type[2]));
        env_game_mbc1m:     assume (game_mbc1m == (!kernel_mode & !n_mbc1 & mbc_type[2]));
        env_gnd2:           assume (gnd2 == 1'b0);
    end
`endif
endmodule
