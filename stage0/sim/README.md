# Simulating the design

`netlist2v.py` turns an exported netlist into structural Verilog over the
behavioral primitives in `s3prims.v`, and the whole FPGA then simulates
from power-on, with models of the config flash, the SD card and the clock
chip, and tasks that drive the Game Boy's bus. It runs FW4, FW5-0731 and
FW5-0918 alike. What the simulations found is in
[design.md](../docs/design.md) and
[firmware-diff.md](../docs/firmware-diff.md).

```bash
stage0/tools/export-netlist.sh <slot B image> fpga/fw4     # design.v and its block RAM files
cd fpga/fw4
iverilog -g2012 -o tb.vvp -s tb -s glbl ../../stage0/sim/s3prims.v design.v ../../stage0/sim/tb_boot.v && vvp -n tb.vvp
```

Verilator is about 100 times faster than iverilog (`--binary --timing`,
`--top-module tb`). One thread is fastest; use the cores by running
independent experiments side by side.

| File | What |
|---|---|
| `s3prims.v` | slice (LUTs, LUT RAM, F5/FX, carry, flip-flops), BRAM, IO tile, BUFGMUX, DCM, and `glbl` (GSR/GTS start-up) |
| `netlist2v.py` | the exporter; wires the dedicated slice cascades from CLB geometry |
| `tb_boot.v` | power-on test: oscillator on P43, idle bus, logs the PicoBlaze program counter |
| `tb_full.v` | full boot: SPI flash and SD card models, Game Boy bus tasks (`gb_write`, `gb_read`); `+define+GB_TEST="file.vh"` adds a GB-side test |
| `models.v` | SPI config flash (EN25F40) and native-mode SD card models |
| `gb_sdread.vh` | GB-side test: stage1's `sd_read`, checked against `card.img` |
| `datvariants.sh` | runs every DAT0-3 pin order in parallel (12 at a time) |
| `fastboot.py` | sim-only copy of the BRAM images with a short `delay_long`; card init at ~29 ms instead of ~50 ms |
| `pinmon.v`, `tb_pcmap.v` | pin activity report; first-execution log of the PicoBlaze PC |
| `xfirst.py` | first signals to go from known to X in a VCD |
| `whyx.py` | walk an X back through the design, cell by cell |
| `gb_glitch.vh` | GB-side test: a console /RESET pulse on P61 (`+define+P61_GLITCH`) during stage1's `sd_read`, then a clean read; `+define+P61_TICK_CAPTURE` models FW5-0918's debounced /RESET register, which zero-delay simulation misses |
| `gb_game.vh` | GB-side test: the kernel's game launch (MBC type, masks, load, `$7FE0` reset), then header and bank reads checked against `rom.hex`; `+define+SNAP` snapshots the design after each bank write |
| `cone.py` | print the logic feeding a net, LUT by LUT, down to flip-flops and pins |
| `regmap.py` | every Game Boy-written flip-flop with the address that enables it and the data bit it takes |
| `topsim.sh`, `topcompare.py` | the testbench over design.v (built with `NO_SLICE_GSR`, see below) and over the readable top (`stage0/fw4/rtl/fw4_top.v`) side by side; the logs are expected to match line for line |

Model choices settled by simulation (each documented in `s3prims.v`):
`F5 = BX ? F : G` as prjcombine documents (checked: the PicoBlaze bank
switch only works with it); `FF_SR_ENABLE` exists only on SLICEMs (SLICEL
flip-flops always honor SR); unconfigured BRAM contents are zero;
flip-flops and pins are held by GSR/GTS until start-up, as on hardware
(`+define+NO_SLICE_GSR` exempts the slice flip-flops, for the comparison
with the readable top, whose registers have no such hold);
REV (BY) sets a flip-flop to the opposite of SRVAL, SR winning (KCPSM3's
interrupt vector depends on it); in a SLICEM, `DIF_MUX=BX` / `DIG_MUX=BY` on
a LUT-mode LUT means the flip-flop takes BX / BY directly.

The other tests and tools, each with a header comment:

| Files | What |
|---|---|
| `gb_kernel.vh`, `gb_load.vh`, `gb_sdload.vh` | stage1's kernel load and hand-off; ROM loads |
| `gb_mbc.vh`, `gb_bank.vh`, `mbctest.py` | every MBC type's banking, save RAM and the game clock, checked against a model |
| `gb_sdwrite.vh`, `gb_sdfault.vh` | sector writes; SD faults for the recovery patch |
| `loadcmd.py`, `memmap.py`, `memcap.v` | build a load command; work out the memory address map from captured writes |
| `pinconf.py`, `regsum.py` | the per-firmware `pins.txt` and `regs.txt` |
| `bankfind.py`, `fanout.py`, `mksnap.py`, `snapdiff.py`, `mkbitmatch.py`, `mkffwin.py` | analysis helpers |
| `rdmon.v`, `wrmon2.v`, `stmon2.v`, `wavemon.v` | monitors |

Not modeled: the Device DNA, so the license check reads 0 and
`fastboot.py --no-license` patches the gate out of a simulation-only copy
of the program. The testbench's oscillator is 25 MHz; the cart's crystal
is 24.545 MHz.
