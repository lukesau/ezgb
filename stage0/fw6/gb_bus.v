// FW6's Game Boy bus state: FW5-0918's module (stage0/fw5-0918/gb_bus.v)
// with stage1 read another way. FW5 kept stage1 in eight one-bit block
// RAMs and a ninth of bytes, and registered the address bits that pick
// between them. FW6 keeps it as bytes in nine block RAMs of 2 KB each,
// all enabled together, and registers the byte itself: boot_q is the block
// RAM that A14-A11 pick, taken on the 2x clock while the stage1 read is
// enabled. The ninth block RAM is $4000-$47FF; above that stage1 reads $FF.
//
// Proven in the whole-design proof (stage0/tools/fw6-prove.sh).

module gb_bus (
    input clk_2x,
    input clk_mode,
    input clk_pb,
    input a11, a12, a13, a14, a15,
    input wr_n,
    // the window and mode registers (gb_regs) and the shared decodes
    input kernel_mode,
    input load_win,                 // $7F36 bit 0
    input [3:0] win_mode,           // $7FC0
    input win_a000, win_sel,        // the window decode's stages (sd_mem_path)
    input wr_7fbx, a210_4,          // the $7FBx write and A2-A0 = 4 (gb_regs)
    input gb_reset_n_q,             // the debounced /RESET register (reset_edge)
    input rst_prev,                 // and its last value: low after high is the edge
    // the pSRAM controller's terms
    input kernel_b3_lo,             // the stage1 read is enabled
    input pg15_gb, pg15_gb_b,       // the controller's page bit, under both its nets
    input a13_gb, a13_gb_b,         // the controller's A13, likewise
    // the other copied signals
    input port_ef_we,               // the PicoBlaze's port EF write
    input [0:0] out_port,
    input int_data,                 // the SD controller's data interrupt
    // stage1's nine block RAMs, in address order
    input [7:0] rom0, rom1, rom2, rom3, rom4, rom5, rom6, rom7, rom8,
    output reg [7:0] boot_q,        // the byte stage1 reads
    // the copies
    output reg load_busy_2x,
    output reg int_data_q,
    // the decodes
    output tbl_win,                 // the loader's table window
    output adr_pass,                // the address's bits 11 and 12 pass
    output a12_pass, a11_pass,
    output rom_en,                  // stage1's block RAMs
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
    assign rom_en = kernel_b3_lo;
    reg [7:0] rom_byte;
    always @* case ({a14, a13, a12, a11})
        4'b0000: rom_byte = rom0;
        4'b0001: rom_byte = rom1;
        4'b0010: rom_byte = rom2;
        4'b0011: rom_byte = rom3;
        4'b0100: rom_byte = rom4;
        4'b0101: rom_byte = rom5;
        4'b0110: rom_byte = rom6;
        4'b0111: rom_byte = rom7;
        4'b1000: rom_byte = rom8;
        default: rom_byte = 8'hff;
    endcase
    assign tbl_we = tbl_win & !wr_n;
    assign wr_7fb4 = wr_7fbx & a210_4 & !(rst_prev & !gb_reset_n_q);   // not on the /RESET edge

    // ---- the copies
    initial begin
        boot_q = 8'h00;
        load_busy_2x = 1'b0; int_data_q = 1'b0;
    end
    always @(posedge clk_2x)
        if (kernel_b3_lo) boot_q <= rom_byte;
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
