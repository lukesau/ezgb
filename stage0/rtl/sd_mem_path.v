// The memory side of an SD transfer, EZ Flash's own. Two things meet here:
//
//   - block RAM X3Y5's Game Boy port: the 2 KB sector buffer the FIFO
//     filler writes and reads, mapped at $A000-$BFFF in kernel mode when
//     $7FC0's low nibble is 0 and the window is enabled (a bit written at
//     $7F30); the Game Boy's address and data pads go to the port
//     directly, this block makes its enable and write enable
//   - the ROM load path into the pSRAM: each word the filler takes from
//     the rx FIFO (X3Y1's read port) is latched with the filler's address
//     into the memory clock, and a 16-cycle sequencer on the system clock
//     then presents it as four bytes, top byte first, with a byte strobe;
//     the pad muxes put the latched address and the byte on the pSRAM
//     pins while the loader runs (port EF, through its 2x-domain copy),
//     and the Game Boy's own address and data otherwise
//
// The address on the pins is the filler's word address ORed with the
// loader's destination (load_addr, in 512-byte units, on bits 14:9): not
// added, so a run must not cross into the bits the destination sets.
// Only the destination's low six bits go through here; the rest select
// the pSRAM page elsewhere. The pin names follow common.names: mem_a is
// the pSRAM's word address (byte address bit k on mem_a[k-1]; the pad
// for bit 1 and the byte strobes are outside), and the data pads' names
// are the pads', so the byte's bit 0 lands on mem_d7 and so on.
//
// Block: stage0/blocks/sd_mem_path.blk.

module sd_mem_path (
    input clk_dcm1,
    input clk_sys4,
    // the filler
    input [14:2] wbm_adr_o,
    input wbm_we_o,
    input [31:0] wbm_dat_o,         // the rx FIFO's read port (X3Y1 DOB)
    // the loader
    input [5:0] load_addr,
    input load_busy_2x,             // port EF, in the 2x domain
    // the Game Boy bus and the window registers
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input a13, a14, a15,
    input wr_n,
    input kernel_mode,
    input [3:0] win_mode,           // $7FC0 bits 3:0
    input win_en,                   // $7F30 bit 0
    // the Game Boy side of the pad muxes
    input [13:1] mem_a_gb,
    input mem_d_ones,               // forces the data pins high
    // the buffer's port
    output buf_en,
    output buf_we,
    output win_a000,                // the decode's stages, shared outside
    output win_kernel,
    output win_sel,
    // the pSRAM pins
    output [13:1] mem_a,
    output mem_a13_b,               // mem_a[13] again, on the mux's own net: a register outside takes it
    output mem_a13_sd,              // the loader's A13 and its inverse, for the page logic
    output mem_a13_sd_n,
    output mem_d0_o, mem_d1_o, mem_d2_o, mem_d3_o, mem_d4_o, mem_d5_o, mem_d6_o, mem_d7_o,
    // the sequencer, for the strobes outside
    output wr_start,
    output reg [3:0] cnt,
    output reg done,
    output reg byte_we_n
);
    // ---- the buffer's window
    assign win_a000 = a13 & !a14;
    assign win_kernel = win_a000 & kernel_mode & a15 & !win_mode[3];
    assign win_sel = win_kernel & !win_mode[0] & !win_mode[2];
    assign buf_en = win_sel & !win_mode[1] & win_en;
    assign buf_we = buf_en & !wr_n;

    // ---- the word and its address, into the memory clock
    reg [14:2] adr_q;
    reg [31:0] dat_q;
    always @(posedge clk_dcm1) begin
        adr_q <= wbm_adr_o;
        dat_q <= wbm_dat_o;
    end

    // ---- the byte sequencer: 16 system-clock cycles from the write's edge
    reg we_q, we_qq;
    reg [7:0] sd_byte;
    always @(posedge clk_sys4) begin
        we_q <= wbm_we_o;
        we_qq <= we_q;
    end
    assign wr_start = we_q & !we_qq;
    always @(posedge clk_sys4 or posedge wr_start)
        if (wr_start) begin
            cnt <= 4'd0;
            done <= 1'b0;
        end else if (!done) begin
            cnt <= cnt + 4'd1;
            done <= cnt == 4'hf;
        end
    initial byte_we_n = 1'b1;
    always @(posedge clk_sys4)
        byte_we_n <= cnt[1] | done;                 // low in the first two cycles of each byte
    always @(posedge clk_sys4)
        if (done) sd_byte <= 8'd0;
        else case (cnt[3:2])                        // top byte first
            2'b00: sd_byte <= dat_q[31:24];
            2'b01: sd_byte <= dat_q[23:16];
            2'b10: sd_byte <= dat_q[15:8];
            2'b11: sd_byte <= dat_q[7:0];
        endcase

    // ---- the pad muxes, SD side
    wire [14:2] sd_a = adr_q | {load_addr, 7'd0};
    assign mem_a = load_busy_2x ? sd_a[14:2] : mem_a_gb;
    assign mem_a13_b = mem_a[13];
    assign mem_a13_sd = load_busy_2x & sd_a[14];
    assign mem_a13_sd_n = load_busy_2x & !sd_a[14];
    assign mem_d7_o = mem_d_ones | (load_busy_2x ? sd_byte[0] : d0);
    assign mem_d6_o = mem_d_ones | (load_busy_2x ? sd_byte[1] : d1);
    assign mem_d5_o = mem_d_ones | (load_busy_2x ? sd_byte[2] : d2);
    assign mem_d1_o = mem_d_ones | (load_busy_2x ? sd_byte[3] : d3);
    assign mem_d2_o = mem_d_ones | (load_busy_2x ? sd_byte[4] : d4);
    assign mem_d3_o = mem_d_ones | (load_busy_2x ? sd_byte[5] : d5);
    assign mem_d0_o = mem_d_ones | (load_busy_2x ? sd_byte[6] : d6);
    assign mem_d4_o = mem_d_ones | (load_busy_2x ? sd_byte[7] : d7);
endmodule
