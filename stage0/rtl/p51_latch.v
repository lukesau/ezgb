// The one slice latch in the design. P51 (the pSRAM's A13, the config
// flash's MISO) is driven by its IO tile's output latch from the A13 mux
// in sd_mem_path (mem_a13_b); this is a second latch of the same mux
// output, whose value the pSRAM controller takes for A13 when neither
// pSRAM is selected (a13_gb_sel). Both latches are forced to the loader's
// A13 while a load runs (mem_a13_sd sets, mem_a13_sd_n clears) and gated
// by the flash operation bit ($7FD2 bit 0) otherwise.
//
// The gate's polarity: this latch is transparent while the bit is 1, as
// decoded. The IO tile's latch has the same gate, which netlist2v.py
// inverts (transparent while the bit is 0) on the behavioral grounds in
// re/stage0/docs/design.md, where a hardware check of that polarity is
// still owed; it is owed for this one too.
//
// Block: stage0/blocks/p51_latch.blk.

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
        else if (flash_op) a13_latch = mem_a13_b;
endmodule
