# Stage1, stock

EZ Flash's stage1 programs, disassembled: the Game Boy code each
firmware's slot B carries in block RAM (splash, then loading the kernel).
One directory per firmware release, the most recent of each line, so they
can be compared. Our replacement, built from source, is
[stage1/](../README.md), one level up; the FPGA logic
around it is [stage0/re](../../stage0/re/README.md).

| Directory | Firmware | Status |
|---|---|---|
| [fw4/](fw4/) | FW4 (the Jr carts we test on) | disassembled and annotated; rebuilds byte for byte |
| [fw5-0918/](fw5-0918/) | FW5, the 0918 update | disassembled, not annotated yet; rebuilds byte for byte |

Each directory holds `kernel.sym` (names and data ranges), `notes.json`
(comment blocks) and the generated `disassembly/`. The binary itself,
`kernel.gb`, is EZ Flash's and stays local: `stage1/tools/stage1-from-bram.py`
writes it from a bitstream's BRAM, and `stage1/tools/stage1-regen.sh
<fw>` regenerates and checks the disassembly. The method is in
[docs/fpga-stage1.md](../../docs/fpga-stage1.md).
