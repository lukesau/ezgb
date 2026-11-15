# FW5-0918's blocks that differ from FW4

`stage0/tools/fw5-prove.sh` carries FW4's block files (`stage0/fw4/blocks/`) to
FW5-0918 and proves each against FW4's readable module (`stage0/fw4/rtl/`), or
against the module here where FW5 differs, each FW4's with the change its
header names. A `<block>.names` file adds names the carry can't find (a
clock that moved). Where FW5 packs a block's logic into other LUTs, a
`<block>.sim` file holds `stage0/tools/simblk.py` arguments and the block
is built by what its nets compute instead of carried; its `.names` lines
then come first (an `in` at the end makes a logic net an input). Logic only
FW5 has gets a `<block>.blk` here, in FW5's coordinates, written by
`stage0/tools/fw5blk.py` from its registers; it is carved as it is. The
results are in
[stage0/docs/firmware-diff.md](../docs/firmware-diff.md).

The proofs run against FW5 as it is, console `/RESET` edge included
(`fw5-noedge.py --keep-edge`); `edge.names` holds the names the carried
block files need for it. `reset_edge` is the edge itself, and the modules
the edge reaches have it here, FW4's included (`sd_clock_divider`,
`sd_controller_wb`, `sd_cmd_serial`, `sd_fifos`), so FW4's stay as they are.
`fw5_top.v` is the stitched top (`stage0/tools/fw5-top.sh`).
