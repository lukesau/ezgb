# FW4, FW5-0731 and FW5-0918 side by side

The three updaters in the `juniorkernel-*` folders each carry an FPGA
bitstream: `Update_FW4.gb`, `Update_FW5_7-31.gb` and
`Update_FW5_2021-9-18.gb` (for FW5, the image at `$8000`; see
[fw5.md](fw5.md) for the second image and the BRAM and PicoBlaze
comparisons). Each one is exported to Verilog the same way
([../sim/README.md](../sim/README.md)) and put through the same tools, so
the three map together and their differences fall out. Placement differs
from build to build, so the comparisons are by function (pins, addresses,
data bits), not by slice name. The per-firmware outputs are in
[../maps/](../maps/).

## Pins

`pinconf.py` lists each package pin's output source, tristate source, input
use and register clocking (`maps/<fw>.pins.txt`). All three use the same 68
pins in the same modes, so the board wiring and the FPGA's view of it didn't
change between FW4 and FW5. The differences:

- **Global buffer numbering.** FW5 routes the same clocks through different
  buffers. The SD pins' registers are clocked from `X13Y33[1]` in FW5 and
  from `X0Y17[6]` in FW4; the Game Boy data pins' input registers from
  `X13Y33[0]` (FW5) and `X13Y33[1]` (FW4); the 595's shift clock comes
  straight from `X0Y17[0]` in FW5.
- **P51's tristate is registered in FW5** (`FFT2` on a system clock), not
  driven from logic. P51 is the config flash's MISO before it becomes
  pSRAM address bit 13, so this is the hand-over between the two uses.
- FW5-0731 and FW5-0918 have identical pin configurations.

## Registers written by the Game Boy

`regmap.py` finds the `/WR` clocks itself (FW4 has two global buffers on
`/WR`, one of them ORed with A15; FW5 has one) and lists every flip-flop
they clock with its enabling address; `regsum.py` groups them by address
(`maps/<fw>.regs.txt`).

| Address | FW4 | FW5 (both) |
|---|---|---|
| `$7Fxx` decode | low byte only; A15 handled by the `/WR` OR A15 clock | low byte plus A15=0 in the enable |
| `$7F30/32/36/37`, `$7FB0-B3`, `$7FC0-C2`, `$7FC4`, `$7FD2` | as in [design.md](design.md) | same bits |
| `$7FC3` (header checksum) | D0-D6 | D0-D7 |
| `$7FD3` | none | D0-D6 |
| `$7FD4` | none | 8 flip-flops through logic (a counter or shift register) |
| `$6000-$7FFF` | none | an 8-bit register (MBC3 clock latch or RTC access) |
| `$0000-$1FFF` | none | 4 bits through logic (RAM enable path) |

The kernel writes `$7FD4` in 1.05e (cataloged in `docs/REGISTERS.md`
beside `$7FD0`/`$7FD2`); FW4's design doesn't decode it.

Between FW5-0731 and FW5-0918 the register map is the same except for five
extra flip-flops loaded on every write and a regrouped set of data-path
flip-flops whose enables are too wide for `regmap.py` to resolve. That fits
the MBC3 real-time clock work [fw5.md](fw5.md) found in 0918's PicoBlaze
code; the cone diff is where it gets pinned down.
