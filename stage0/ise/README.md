# Building stage0 from the readable Verilog

The readable FW4 design (`stage0/fw4/rtl`) builds with ISE 14.7 into a slot B
bitstream with stage1 in its block RAMs, and the result is proved equivalent
to the stock bitstream. It is not stock byte for byte: ISE maps and routes
the logic itself. Every register sits in its stock cell, though, so the
design packs and meets timing the way stock does.

```bash
make stage0 BUILD_HOST=<build host>             # fpga/stage1/Update-fw4-ise.gb
STAGE1=stock PATCHES=0 make stage0 BUILD_HOST=<build host>
```

`stage0/tools/build-stage0.sh` is the whole flow:

1. **The stock export.** Slot B from the official updater, exported
   (`export-netlist.sh`) to `fpga/fw4-export`: the placement source and
   the proof's reference.
2. **Stage1 and the PicoBlaze patches** as block RAM contents, as
   `build-stage1-updater.sh` makes them (`STAGE1`, `PATCHES` as there).
3. **The ISE project** (`tools/mkise.py`): `fw4_top.v` and the blocks,
   compiled against `s3prims_ise.v`, which writes the primitives the
   extracted top instantiates over the UNISIM ones. The UCF it writes
   places every pad, block RAM, clock buffer and the DCM as stock has
   them, puts the contents in the block RAMs (`INIT_xx`), and with
   `--place` puts each of the 2,135 slice flip-flops in its stock cell.
   `fw4.ucf` is appended.
4. **The build** on the build host (`tools/build-ise.sh`): XST, map,
   par, trce, bitgen, and s3decode of the result.
5. **The checks.** Timing must be met; the result is exported and proved
   equivalent to stock (`tools/prove-ise.py`); stage1 must decode back out
   of the block RAMs.
6. **The updater**, as `make-updater.py` makes them.

## What it takes

**Register placement.** Without it the design does not fit: stock fills
1,727 of the part's 1,792 slices, and ISE packing the same 3,050 LUTs and
2,135 flip-flops its own way needs over 1,900. The readable design keeps
the hardware's registers one for one, so each register's stock cell comes
from the block files (their `[names]`, with a port name followed through
`assign port = reg` to the register). Map then packs the logic around
them. Two flip-flops are left to ISE (`fw4.unplace`): XST gives each a clock
enable its stock slice-mate does not have.

**XST options** (`build-ise.sh`), so the registers stay as written:

- `-shreg_extract NO`: otherwise 178 of the SD crossing's synchronizer
  flip-flops become SRL16s (stock has them as flip-flops)
- `-signal_encoding user`: otherwise registers used as case selectors are
  re-encoded one-hot, which adds bits
- `-equivalent_register_removal NO`, `-fsm_extract NO`,
  `-register_duplication NO`
- `-mult_style lut`; the one multiply (BCD tens times 10, `gb_data_out`)
  is written as shifts, or XST pulls registers into a pipelined multiplier

**The IOs** (`fw4.ucf`), each found by building and comparing the IOB
bits with stock's:

- every pad LVCMOS33, 4 mA, slow (LVTTL at 4 or 6 mA sets the same bits)
- the clock chip's I2C lines, P31 and P32, at 2 mA
- pull-ups on the SD lines (P25, P28, P29, P30, P34) and the I2C lines

**bitgen**: `ConfigRate:25`, `DonePipe:Yes`, `Reset_on_err:Yes`, stock
slot B's header.

**Timing** (`fw4.ucf`). The oscillator, 24.545 MHz on P43, and the DCM's
clocks follow from it; the Game Boy's two write clocks get their own
periods, unrelated to it, since every crossing into or out of them is
synchronized. A clock mux whose select is tied becomes a plain BUFG
(`mkise.py`), or the analyzer times the 2x clock at the multiplied clock's
period through the mux's other input. The memory page register's 2x-to-fx
paths are timing-ignored: it resamples every fx cycle and acts only on two
equal samples. With those, all paths meet timing; the 2x clock's has
about 0.25 ns of slack.

## The proof

`prove-ise.py` proves the ISE netlist equivalent to stock's. The registers
are matched by name: each one's export net names the cell it is in, and
the build's XDL says which register is in which cell, so the two that are
not in their stock cell are renamed. The LUT RAMs are matched the same way.
The block RAMs, IO tiles, DCMs, DNA port and ICAP are cut out, so the logic
around them is compared pin for pin; their attributes are compared as
text. yosys proves the matched signals structurally. What is left, the SD
command response buffer and four SD pin outputs, holds only in the states
the hardware reaches, so it is proved by temporal induction under the
readable modules' invariants, bound to stock's nets. `equiv.sh` proves
those invariants hold on stock.

With the per-block proofs (readable == stock), that shows the ISE build
does what the readable design says.

## A finding: the latch polarity

The first proof failed on one register, the P51 slice latch. ISE, asked
for it transparent while `$7FD2` bit 0 is 1 (what `p51_latch.v` said,
from the decoded bit), set the slice's CLK inversion where stock's is
clear. So the decoded gate bit of a latch reads inverted, as `netlist2v.py`
already assumed for P51's IO-tile latch on behavioral grounds, and both
latches are transparent while the bit is 0. `p51_latch.v` and
`netlist2v.py` are corrected (see `stage0/docs/design.md`).

## Not yet

- FW5-0918: its design proves in 26 blocks, but the flow is FW4 only.
- The bitstream is not stock's. Reproducing stock exactly needs its LUT
  contents and routing too (layer 3 in [../README.md](../README.md)).
- Not run on hardware yet.

## Files

| File | What |
|---|---|
| `s3prims_ise.v` | the primitives over UNISIM, for XST |
| `fw4.ucf` | the hand-written constraints |
| `fw4.unplace` | flip-flops left to ISE |
| `xc3s200a-slices.txt` | every slice site per CLB tile (`xdl -report`), for the placement |
