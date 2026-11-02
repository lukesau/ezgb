# FW5-0918's blocks that differ from FW4

`scripts/fpga/fw5-prove.sh` carries FW4's block files (`stage0/blocks/`) to
FW5-0918 and proves each against FW4's readable module (`stage0/rtl/`), or
against the module here where FW5 differs, each FW4's with the change its
header names. A `<block>.names` file adds names the carry can't find (a
clock that moved). The results are in
[re/stage0/docs/firmware-diff.md](../../re/stage0/docs/firmware-diff.md).
