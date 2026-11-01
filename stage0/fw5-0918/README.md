# FW5-0918's SD blocks that differ from FW4

FW5-0918's SD controller proves equivalent to FW4's readable blocks
(`stage0/rtl/`) except for the two modules here, each FW4's with one change
(the module headers say which). `scripts/fpga/fw5-prove-sd.sh` runs the
proofs; the results are in
[re/stage0/docs/firmware-diff.md](../../re/stage0/docs/firmware-diff.md).
