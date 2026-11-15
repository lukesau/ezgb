// The one slice latch in the design. P51 (the pSRAM's A13, the config
// flash's MISO) is driven by its IO tile's output latch from the A13 mux
// in sd_mem_path (mem_a13_b); this is a second latch of the same mux
// output, whose value the pSRAM controller takes for A13 when neither
// pSRAM is selected (a13_gb_sel). Both latches are forced to the loader's
// A13 while a load runs (mem_a13_sd sets, mem_a13_sd_n clears) and gated
// by the flash operation bit ($7FD2 bit 0) otherwise.
//
// The gate's polarity: both latches are transparent while the bit is 0,
// so in the kernel, which leaves it 0, they follow the mux. The decoded
// bit reads the other way. ISE settles it: built from this module with the
// gate the other way round (transparent while 1), it sets this slice's CLK
// inversion where stock's is clear, and built as here it matches stock
// (stage0/ise, 2026-11-14). netlist2v.py inverts latch gates to match.
//
// Block: stage0/fw4/blocks/p51_latch.blk.

module p51_latch (
    input flash_op,                 // $7FD2 bit 0: the gate
    input mem_a13_b,                // the A13 mux (sd_mem_path)
    input mem_a13_sd,               // a load runs and its A13 is 1: set
    input mem_a13_sd_n,             // a load runs and its A13 is 0: clear
    output reg a13_latch
);
    initial a13_latch = 1'b0;
    always @*
        if (mem_a13_sd_n) a13_latch = 1'b0;
        else if (mem_a13_sd) a13_latch = 1'b1;
        else if (!flash_op) a13_latch = mem_a13_b;
endmodule
