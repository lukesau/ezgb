# Stage1, stock

EZ Flash's own stage1 programs, disassembled: the Game Boy code each
firmware's slot B carries in block RAM (splash, then loading the kernel).
One directory per firmware release, the most recent of each line, so they
can be compared. Our replacement, built from source, is
[stage1/](../../stage1/README.md) at the top of the repo; the FPGA logic
around it is [re/stage0](../stage0/README.md).

| Directory | Firmware | Status |
|---|---|---|
| [fw4/](fw4/) | FW4 (the Jr carts we test on) | disassembled and annotated; rebuilds byte for byte |
| `fw5-0918/` | FW5, the 0918 update | to do |

Each directory holds `kernel.sym` (names and data ranges), `notes.json`
(comment blocks) and the generated `disassembly/`. The binary itself,
`kernel.gb`, is EZ Flash's and stays local: `scripts/fpga/stage1-from-bram.py`
writes it from a bitstream's BRAM, and `scripts/fpga/stage1-regen.sh
stage1/<fw>` regenerates and checks the disassembly. The method is in
[docs/fpga-stage1.md](../../docs/fpga-stage1.md).
