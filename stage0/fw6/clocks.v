// FW6: FW5-0918's module below without the PicoBlaze clock gate. FW6's
// PicoBlaze and the SD controller's register side run on CLK2X straight
// from its buffer (X13Y0 [2]), always; there is no pb_clk_run, and the
// mode clock is not gated by kernel_mode. The shift clock gate and the
// DCM reset are FW5's. Proven in the whole-design proof
// (stage0/tools/fw6-prove.sh).
//
// FW5-0918's clocks and ties: FW4's (stage0/fw4/rtl/clocks.v) with these
// changes:
//
//   - no wr_a15_n: FW5 has no /WR | A15 clock, its Game Boy registers all
//     run on the /WR pad's buffer with A15 in their enables
//   - gnd has 22 constant-0 LUTs (FW4 15), on block RAM spare pins and
//     write enables, the DCM's phase-shift inputs and the gated buffers'
//     other inputs; the design's shared one (gnd1, X24Y18) belongs to the
//     blocks that read it
//
// The gates are FW4's, on other buffers: pb_clk_run on the PicoBlaze's
// (X13Y33 [3]), sh_clk_run selecting the shift clock buffer (X0Y17 [0]),
// whose other input is clk_fx_n, and dcm_rst on DCM X13Y1. The mode
// clock (X25Y17 [4]) and clk_sys4 (X25Y17 [0]) are gated by kernel_mode
// and gb_bus's copy of the loader's busy flag directly.
//
// Block: simblk.py from stage0/fw4/blocks/clocks.blk with
// stage0/fw5-0918/clocks.sim and clocks.names.

module clocks (
    input sh_run, sh_done,          // the serializer (psram_ctrl)
    input clk_fx,
    input dcm_locked, dcm_status2,
    output sh_clk_run,
    output dcm_rst,
    output clk_fx_n,
    output [21:0] gnd
);
    assign sh_clk_run = sh_run & !sh_done;
    assign dcm_rst = dcm_status2 & !dcm_locked;
    assign clk_fx_n = !clk_fx;
    assign gnd = 22'd0;
endmodule
