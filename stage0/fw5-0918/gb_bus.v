// FW5-0918's Game Boy bus state, FW4's gb_bus (stage0/fw4/rtl/gb_bus.v) with
// these changes:
//
//   - no address pins: FW5 builds A1-A13 in sd_mem_path (with the extra U4
//     and clock-register terms), so mem_a_gb and its n_rom mux are gone
//   - the $7FB4 write is gb_regs's $7FBx write with A2-A0 = 4, all on /WR
//     like the rest of FW5's register file; FW4's "outside the cycle after
//     /RESET falls" term is gone with the rst it came from
//   - no 2x copy of the loader's busy flag: its readers take port EF's
//     register directly, and load_busy_2x is a second copy of that
//     register (port EF bit 0 on the PicoBlaze clock) for fanout
//   - no second stage of /RESET: FW5 still has the register (set while
//     the DCM is unlocked) but nothing reads it, so the block leaves it out
//   - the loader's table block RAM (X3Y13 in FW5) runs its Game Boy port
//     on the PicoBlaze clock; tbl_win and tbl_we are FW4's
//
// clk_2x is the global buffer the stage1 read and its copies run on in FW5
// (FW4's 2x clock). Block: simblk.py from stage0/fw4/blocks/gb_bus.blk with
// stage0/fw5-0918/gb_bus.sim and gb_bus.names.

module gb_bus (
    input clk_2x,
    input clk_mode,
    input clk_pb,
    input a11, a12, a15,
    input wr_n,
    // the window and mode registers (gb_regs) and the shared decodes
    input kernel_mode,
    input load_win,                 // $7F36 bit 0
    input [3:0] win_mode,           // $7FC0
    input win_a000, win_sel,        // the window decode's stages (sd_mem_path)
    input wr_7fbx, a210_4,          // the $7FBx write and A2-A0 = 4 (gb_regs)
    // the pSRAM controller's terms
    input kernel_b3_lo,             // the stage1 read is enabled
    input pg15_gb, pg15_gb_b,       // the controller's page bit, under both its nets
    input a13_gb, a13_gb_b,         // the controller's A13, likewise
    // the other copied signals
    input port_ef_we,               // the PicoBlaze's port EF write
    input [0:0] out_port,
    input int_data,                 // the SD controller's data interrupt
    // the copies
    output reg pg15_gb_q, a12_pass_q, a11_pass_q, a13_gb_q,
    output reg load_busy_2x,
    output reg int_data_q,
    // the decodes
    output tbl_win,                 // the loader's table window
    output adr_pass,                // the address's bits 11 and 12 pass
    output a12_pass, a11_pass,
    output brom_en, plane_en,       // block RAM X3Y17 and the bit planes
    output tbl_we,                  // the table block RAM's Game Boy write
    output wr_7fb4                  // the data pads' input register enable
);
    // ---- the remap
    wire win13_n = !(win_a000 & win_mode[0] & !win_mode[2] & !win_mode[3]);
    assign tbl_win = win_sel & win_mode[1] & load_win;
    assign adr_pass = !(a15 & kernel_mode) | tbl_win | !win13_n;
    assign a12_pass = adr_pass & a12;
    assign a11_pass = adr_pass & a11;

    // ---- the block RAM ports and the pads' registers
    assign brom_en = kernel_b3_lo & pg15_gb & !a11_pass & !a12_pass & !a13_gb;
    assign plane_en = kernel_b3_lo & !pg15_gb;
    assign tbl_we = tbl_win & !wr_n;
    assign wr_7fb4 = wr_7fbx & a210_4;

    // ---- the copies
    initial begin
        pg15_gb_q = 1'b0; a12_pass_q = 1'b0; a11_pass_q = 1'b0; a13_gb_q = 1'b0;
        load_busy_2x = 1'b0; int_data_q = 1'b0;
    end
    always @(posedge clk_2x)
        if (kernel_b3_lo) {pg15_gb_q, a12_pass_q, a11_pass_q, a13_gb_q} <= {pg15_gb_b, a12_pass, a11_pass, a13_gb_b};
    always @(posedge clk_pb) if (port_ef_we) load_busy_2x <= out_port[0];
    always @(posedge clk_mode) int_data_q <= int_data;

`ifdef FORMAL
    // The controller's two terms arrive under both their nets, the LUT's
    // and the slice pin's alias; they are the same signal.
    always @* begin
        env_pg15: assume (pg15_gb_b == pg15_gb);
        env_a13:  assume (a13_gb_b == a13_gb);
    end
`endif
endmodule
