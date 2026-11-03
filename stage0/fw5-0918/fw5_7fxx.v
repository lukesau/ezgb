// The registers FW5-0918 adds to the $7Fxx file, all on /WR:
//
//   - $7FD3: bits 6:0 here, bit 7 in the d7 pad's input register (d7_q),
//     which FW5 loads on this write where d0-d6 load on $7FB4; wr_7fd3 is
//     that pad's clock enable
//   - sum_7fd4: $7FD3 + the byte written to $7FD4, taken on the $7FD4
//     write; the PicoBlaze reads it at port BB (the fast-load key checks
//     it for $11)
//   - $7FC3 bit 7 (hdr_chk7), the top bit of the header checksum
//     substitute gb_data_out serves at $014D
//
// A3 isn't decoded, so $7FDB and $7FDC write the same registers. The
// carry-in is the design's shared constant-0 LUT.
//
// Block: stage0/fw5-0918/fw5_7fxx.blk (FW5 only).

module fw5_7fxx (
    input clk_wr_a,
    input a0, a2, a4,
    input d0, d1, d2, d3, d4, d5, d6, d7,
    input dec_7fcx,                 // the unlocked $7FC0-$7FDF decode (gb_regs)
    input a10_any, a1_n2,           // gb_regs's shared decodes
    input wr_7fc3,                  // the $7FC3 write (gb_regs)
    input d7_q,                     // the d7 pad's input register: $7FD3 bit 7
    input gnd1,
    output wr_7fd3,
    output reg [7:0] sum_7fd4,
    output reg hdr_chk7
);
    wire [7:0] d = {d7, d6, d5, d4, d3, d2, d1, d0};
    reg [6:0] r7fd3;

    assign wr_7fd3 = dec_7fcx & a4 & a1_n2 & a0;            // $7FD3 (and $7FDB)
    wire wr_7fd4 = dec_7fcx & a4 & a2 & !a10_any;           // $7FD4 (and $7FDC)

    initial begin r7fd3 = 7'd0; sum_7fd4 = 8'd0; hdr_chk7 = 1'b0; end
    always @(posedge clk_wr_a) begin
        if (wr_7fd3) r7fd3 <= d[6:0];
        if (wr_7fd4) sum_7fd4 <= {d7_q, r7fd3} + d + gnd1;
        if (wr_7fc3) hdr_chk7 <= d7;
    end
endmodule
