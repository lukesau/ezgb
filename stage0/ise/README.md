# Building stage0 from the readable Verilog

The readable designs of FW4 (`stage0/fw4/rtl`) and FW5-0918
(`stage0/fw5-0918`) build with ISE 14.7 into a slot B bitstream with
stage1 in its block RAMs, and each result is proven equivalent to that
firmware's stock bitstream. It is not identical to stock: ISE maps and routes
the logic itself. Every register sits in its stock cell, though, so the
design packs and meets timing the way stock does.

```bash
make stage0 BUILD_HOST=<build host>     # Update-fw4-ise.gb, Update-fw5-0918-ise.gb
STAGE1=stock PATCHES=0 make stage0 BUILD_HOST=<build host>
stage0/tools/build-stage0.sh fw5-0918   # one firmware, no updater
PROVE=0 STAGE1=stock PATCHES=0 stage0/tools/build-stage0.sh fw4   # from the repository alone
```

`stage0/tools/build-stage0.sh` is the whole flow. Only the proof reads
anything of EZ Flash's, and `PROVE=0` skips it.

1. **Stage1 and the PicoBlaze's programs** as block RAM contents. Stage1 is
   built and split as `build-stage1-updater.sh` does it (`STAGE1` as
   there). The two programs are assembled from their listings
   (`picoblaze-dis.py --assemble`, `stage0/<fw>/picoblaze/`), which
   reassemble to stock's words; bank 2 is the same program on both
   firmwares, so FW5 takes FW4's listing. Our patches go on top unless
   `PATCHES=0`. No block RAM contents come from the stock bitstream.
2. **The ISE project** (`tools/mkise.py`): the stitched top and the blocks,
   compiled against `s3prims_ise.v`, which writes the primitives the
   extracted top instantiates over the UNISIM ones. The UCF it writes
   places every pad, block RAM, clock buffer and the DCM as stock has
   them, puts the contents in the block RAMs (`INIT_xx`), and with
   `--place` puts each slice flip-flop (2,135 on FW4, 2,374 on FW5) and the
   PicoBlaze's LUT RAMs in their stock cells, as `<fw>.place` lists them.
   `<fw>.ucf` is appended.
3. **The build** on the build host (`tools/build-ise.sh`): XST, map,
   par, trce, bitgen, and s3decode of the result. Timing must be met, and
   stage1 and the PicoBlaze's programs must decode back out of the block
   RAMs.
4. **The proof.** Slot B from the official updater is exported
   (`export-netlist.sh`) to `fpga/<fw>`, and the result is proven
   equivalent to it (`tools/prove-ise.py`); every register's and LUT RAM's
   power-up value must be stock's. FW5's block files are `fw5-prove.sh`'s
   (`fpga/fw5-nx/edge/blk`), so that runs first.
5. **The updater**: its program built from source
   ([../updater](../updater/README.md)) with the new slot B after it.
   `UPDATER=stock` swaps the payload inside the official updater instead
   (`make-updater.py`).

## What it takes

**Register placement.** Without it the design does not fit: stock FW4
fills 1,727 of the part's 1,792 slices (FW5 1,788), and ISE packing the
same LUTs and flip-flops its own way needs over 1,900. The readable design keeps
the hardware's registers one for one, so each register's stock cell comes
from the block files (their `[names]`, with a port name followed through
`assign port = reg` to the register). `mkise.py --derive-place <stock
export's design.v>` writes that as `<fw>.place`, which is checked in, so a
build reads no stock file; the proof fails if a line of it is wrong, since
it matches the registers by cell. Map then packs the logic around
them. A few flip-flops are left to ISE (`<fw>.unplace`, two each): XST
gives each a clock enable or set/reset its stock slice-mate does not have.

**XST options** (`build-ise.sh`), so the registers stay as written:

- `-shreg_extract NO`: otherwise 178 of the SD crossing's synchronizer
  flip-flops become SRL16s (stock has them as flip-flops)
- `-signal_encoding user`: otherwise registers used as case selectors are
  re-encoded one-hot, which adds bits
- `-equivalent_register_removal NO`, `-fsm_extract NO`,
  `-register_duplication NO`
- `-mult_style lut`; the one multiply (BCD tens times 10, `gb_data_out`)
  is written as shifts, or XST pulls registers into a pipelined multiplier
- `-max_fanout 100000`: FW5's `/RESET` edge resets about 480 flip-flops
  from one LUT; XST copies a LUT past 500 loads, and the copies can't share
  slices with the stock registers on the original
- `-mux_extract NO`: XST's F5/FX mux trees need runs of free slices, which
  FW5's full device doesn't have once the registers are placed
- an `initial` value on every register: left to XST, a register with a
  synchronous set (an FDS) starts at 1 (`psram_ctrl`'s `sh_run` did)

**The IOs** (`<fw>.ucf`), each found by building and comparing the IOB
bits with stock's (FW5's are FW4's bit for bit):

- every pad LVCMOS33, 4 mA, slow (LVTTL at 4 or 6 mA sets the same bits)
- the clock chip's I2C lines, P31 and P32, at 2 mA
- pull-ups on the SD lines (P25, P28, P29, P30, P34) and the I2C lines

**bitgen**: `ConfigRate:25`, `DonePipe:Yes`, `Reset_on_err:Yes`, stock
slot B's header.

**Timing** (`<fw>.ucf`). The oscillator, 24.545 MHz on P43, and the DCM's
clocks follow from it (FW4 x3, FW5 x10/3); the Game Boy's write clocks get their own
periods, unrelated to it, since every crossing into or out of them is
synchronized. A clock mux whose select is tied becomes a plain BUFG
(`mkise.py`), or the analyzer times the 2x clock at the multiplied clock's
period through the mux's other input. The memory page register's 2x-to-fx
paths are timing-ignored: it resamples every fx cycle and acts only on two
equal samples (on FW5 also into `page_q`, whose load enable takes the
loader's busy flag). FW5's fx clock gate is a BUFGMUX switched from the 2x
clock; a BUFGMUX switches without a glitch, so its select is
timing-ignored. FW5 places with the cost table in `fw5-0918.map`: by
default three PicoBlaze-to-register-file hold paths come up 0.2-0.6 ns
short (the two gated clocks come from buffers on different sides of the
part), and tables 2, 4 and 5 meet everything. With those, all paths meet
timing; FW4's 2x clock has about 0.25 ns of slack.

## The proof

`prove-ise.py` proves the ISE netlist equivalent to stock's. The registers
are matched by name: each one's export net names the cell it is in, and
the build's XDL says which register is in which cell, so the two that are
not in their stock cell are renamed. The LUT RAMs are matched the same way.
The block RAMs, IO tiles, DCMs, DNA port and ICAP are cut out, so the logic
around them is compared pin for pin; their attributes are compared as
text. yosys proves the matched signals structurally. What is left (the SD
command response buffer, SD pins, on FW5 the memory data pins) holds only
in the states the hardware reaches, so it is proven by temporal induction
under the readable modules' invariants, bound to stock's nets, with the pins
and the registers as two groups. `equiv.sh` proves those invariants hold on
stock. An assumption on a net stock's netlist doesn't name (a LUT output
inside a slice) is left out, which can only make the proof harder. Stock
registers that are copies of each other (the same D, enable, clock and
power-up value, as FW5's two `load_busy_2x`) are assumed equal, which they
are by construction, since the two builds read different copies.

The proof can't see power-up values, so `prove-ise.py` compares them
directly: every slice flip-flop's INIT and every LUT RAM's contents
against its stock cell.

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

## FW5's console `/RESET` edge

FW5's readable design used to be proven against FW5 with its `/RESET`
edge logic removed. Built that way it would not reset the SD controller,
restart the PicoBlaze or clear the `/WR` registers when the console resets,
which is how the kernel starts a game. The edge is now in the readable
design (`stage0/fw5-0918/reset_edge.v` and the modules it reaches), and
the blocks and the top level prove against FW5 as it is
(`stage0/docs/firmware-diff.md`).

## Not yet

- The bitstream is not stock's. Reproducing stock exactly needs its LUT
  contents and routing too (layer 3 in [../README.md](../README.md)).
- FW5-0918's build has not run on hardware. FW4's has (2026-11-16): flashed
  with the from-source updater, the cart boots and runs the kernel built
  from source.

## Files

| File | What |
|---|---|
| `s3prims_ise.v` | the primitives over UNISIM, for XST |
| `fw4.ucf`, `fw5-0918.ucf` | the hand-written constraints |
| `fw4.place`, `fw5-0918.place` | each flip-flop's and LUT RAM's stock cell (`mkise.py --derive-place`) |
| `fw4.unplace`, `fw5-0918.unplace` | flip-flops left to ISE |
| `fw5-0918.map` | map options FW5 needs (the placer cost table) |
| `xc3s200a-slices.txt` | every slice site per CLB tile (`xdl -report`), for the placement |
