// The Game Boy bus's state in the 2x domain and its address on the pSRAM
// pins, written by EZ Flash. What is here:
//
//   - the copies: four page bits the data bus block's stage1 read uses
//     (the controller's pg15 and A13 terms and the remapped A12 and A11),
//     registered on the 2x clock while the stage1 read is enabled
//     (kernel mode, $7F32 bit 3, below $8000), the loader's busy flag
//     (port EF) into the 2x domain, the second stage of the console's
//     /RESET after its pad register (the register block's rst is the
//     cycle between the two), and the data interrupt's first stage on
//     the mode clock (the register block's command flag sets on its
//     rising edge)
//   - the window remap: in kernel mode at $8000 and above the address's
//     bits 11 and 12 are forced low, except in the loader's table window
//     ($A000 with $7FC0 = 2 and $7F36 bit 0) and in window modes 1 and
//     3 at $A000; a11_pass and a12_pass are what the pins, the stage1
//     bit-plane block RAMs' addresses and the copies above take
//   - the lower address pins: A1-A10 carry the next address bit up for a
//     U9 (word-addressed ROM) access and the bit itself otherwise, U4's
//     byte address; A10's "bit itself" is a11_pass, the pins above are
//     in pb_periph, and sd_mem_path puts the loader's address on them
//     instead while a load runs
//   - the block RAM ports: the byte ROM X19Y17 (brom_en) reads when the
//     stage1 read is enabled, the page bit is set and the remapped
//     A11-A13 are 0, the eight bit-plane block RAMs (plane_en) when the
//     page bit is clear; the loader's table X3Y21 is enabled in its
//     window and written there on /WR
//   - the data pads' input registers: their clock enable is the $7FB4
//     write (outside the cycle after /RESET falls), so they hold the
//     sector count and command bit the PicoBlaze reads at port B4 and
//     the checksum register's bit 7
//
// Block: stage0/blocks/gb_bus.blk.

module gb_bus (
    input clk_2x,
    input clk_mode,
    input a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a15,
    input wr_n,
    // the window and mode registers (gb_regs) and the shared decodes
    input kernel_mode,
    input load_win,                 // $7F36 bit 0
    input [3:0] win_mode,           // $7FC0
    input win_a000, win_sel,        // the window decode's stages (sd_mem_path)
    input a1a0_zero,                // !a1 & !a0 (gb_data_out)
    input dec_7f3x,                 // the unlocked $7F3x/$7FBx decode (gb_regs)
    input dec_x9y22_s2,             // !a2 | rst (gb_regs)
    // the pSRAM controller's terms
    input hi_n_win1, chk_sel,       // not a U9 access when either is set
    input kernel_b3_lo,             // the stage1 read is enabled
    input pg15_gb, pg15_gb_b,       // the controller's page bit, under both its nets
    input a13_gb, a13_gb_b,         // the controller's A13, likewise
    // the other copied signals
    input load_busy,                // port EF
    input gb_reset_n_q,             // the /RESET pad's input register
    input int_data,                 // the SD controller's data interrupt
    // the copies
    output reg pg15_gb_q, a12_pass_q, a11_pass_q, a13_gb_q,
    output reg load_busy_2x,
    output reg gb_reset_n_q2,
    output reg int_data_q,
    // the decodes
    output win13_n,                 // not window mode 1 or 3 at $A000
    output tbl_win,                 // the loader's table window
    output adr_pass,                // the address's bits 11 and 12 pass
    output a12_pass, a11_pass,
    output brom_en, plane_en,       // block RAM X19Y17 and the bit planes
    output tbl_we,                  // block RAM X3Y21's Game Boy write
    output wr_7fb4,                 // the data pads' input register enable
    // the address pins
    output [10:1] mem_a_gb
);
    // ---- the remap
    assign win13_n = !(win_a000 & win_mode[0] & !win_mode[2] & !win_mode[3]);
    assign tbl_win = win_sel & win_mode[1] & load_win;
    assign adr_pass = !(a15 & kernel_mode) | tbl_win | !win13_n;
    assign a12_pass = adr_pass & a12;
    assign a11_pass = adr_pass & a11;

    // ---- the pins
    wire n_rom = hi_n_win1 | chk_sel;
    wire [11:1] a = {a11_pass, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1};
    assign mem_a_gb = n_rom ? a[10:1] : a[11:2];

    // ---- the block RAM ports and the pads' registers
    assign brom_en = kernel_b3_lo & pg15_gb & !a11_pass & !a12_pass & !a13_gb;
    assign plane_en = kernel_b3_lo & !pg15_gb;
    assign tbl_we = tbl_win & !wr_n;
    assign wr_7fb4 = dec_7f3x & a7 & a1a0_zero & !dec_x9y22_s2;

    // ---- the copies
    initial begin
        pg15_gb_q = 1'b0; a12_pass_q = 1'b0; a11_pass_q = 1'b0; a13_gb_q = 1'b0;
        load_busy_2x = 1'b0; gb_reset_n_q2 = 1'b1; int_data_q = 1'b0;
    end
    always @(posedge clk_2x) begin
        if (kernel_b3_lo) {pg15_gb_q, a12_pass_q, a11_pass_q, a13_gb_q} <= {pg15_gb_b, a12_pass, a11_pass, a13_gb_b};
        load_busy_2x <= load_busy;
        gb_reset_n_q2 <= gb_reset_n_q;
    end
    always @(posedge clk_mode) int_data_q <= int_data;

`ifdef FORMAL
    // The controller's two terms arrive under both their nets, the LUT's
    // own and the slice pin's alias; they are the same signal.
    always @* begin
        env_pg15: assume (pg15_gb_b == pg15_gb);
        env_a13:  assume (a13_gb_b == a13_gb);
    end
`endif
endmodule
