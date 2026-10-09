# The FW4 design as simulatable Verilog

`netlist2v.py` turns `s3trace --netlist` output into structural Verilog over
the behavioural primitives in `s3prims.v`; iverilog then simulates the whole
FPGA from power-on. Findings: [docs/fpga-design.md](../../../docs/fpga-design.md).

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
| `xfirst.py` | first signals to go from known to X in a VCD |
| `whyx.py` | walk an X back through the design, cell by cell |

Model choices settled by simulation (each documented in `s3prims.v`):
`F5 = BX ? F : G` as prjcombine documents (checked: the PicoBlaze bank
switch only works with it); `FF_SR_ENABLE` exists only on SLICEMs (SLICEL
flip-flops always honour SR); unconfigured BRAM contents are zero;
flip-flops and pins are held by GSR/GTS until start-up, as on hardware.

Not modelled: Device DNA (the licence check reads 0), ICAP, real DCM
frequencies (the oscillator frequency is unknown; 25 MHz is assumed).
