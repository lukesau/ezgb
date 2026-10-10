# The FW4 design as simulatable Verilog

`netlist2v.py` turns `s3trace --netlist` output into structural Verilog over
the behavioral primitives in `s3prims.v`; iverilog then simulates the whole
FPGA from power-on. Findings: [re/stage0/docs/design.md](../docs/design.md).

```bash
# on the build host, from ~/fpga/verilog
s3trace --db ../prjcombine/databases/spartan3.zstd ../cart/fw4-updater.bin --netlist ../cart/fw4-netlist.jsonl
s3pins  --db ../prjcombine/databases/spartan3.zstd > ../cart/vq100-pins.txt
python3 netlist2v.py ../cart/fw4-netlist.jsonl ../cart/vq100-pins.txt ../cart/bram-fw4-updater fw4
cd fw4 && iverilog -g2012 -o tb.vvp -s tb -s glbl ../s3prims.v design.v ../tb_boot.v && vvp -n tb.vvp
```

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
| `gb_game.vh` | GB-side test: the kernel's game launch (MBC type, masks, load, `$7FE0` reset), then header and bank reads checked against `rom.hex`; `+define+SNAP` snapshots the design after each bank write |
| `cone.py` | print the logic feeding a net, LUT by LUT, down to flip-flops and pins |
| `regmap.py` | every Game Boy-written flip-flop with the address that enables it and the data bit it takes |

Model choices settled by simulation (each documented in `s3prims.v`):
`F5 = BX ? F : G` as prjcombine documents (checked: the PicoBlaze bank
switch only works with it); `FF_SR_ENABLE` exists only on SLICEMs (SLICEL
flip-flops always honor SR); unconfigured BRAM contents are zero;
flip-flops and pins are held by GSR/GTS until start-up, as on hardware;
REV (BY) sets a flip-flop to the opposite of SRVAL, SR winning (KCPSM3's
interrupt vector depends on it); in a SLICEM, `DIF_MUX=BX` / `DIG_MUX=BY` on
a LUT-mode LUT means the flip-flop takes BX / BY directly.

Verilator is about 100 times faster than iverilog (`--binary --timing`,
same files, `--top-module tb`). One thread is fastest: `--threads 4` and
`8` ran 1.7x and 2.5x slower on a 5 ms boot. Use the cores by running
independent experiments side by side instead.

Not modeled: Device DNA (the license check reads 0), ICAP, real DCM
frequencies (the oscillator frequency is unknown; 25 MHz is assumed).
