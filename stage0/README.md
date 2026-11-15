# Stage0: the FPGA design

Everything custom about the Jr is in a Xilinx Spartan-3A (XC3S200A): the
Game Boy bus decode, the `$7Fxx` registers, the SD controller, the memory
addressing, and a PicoBlaze soft CPU that sequences SD, ROM loads and the
clock. EZ Flash published none of it. This folder holds the design decoded
from their bitstreams and rewritten as readable Verilog that is proven,
block by block, to be the same design.

## The boot chain

| Step | What runs | Where it lives |
|---|---|---|
| slot A | the FPGA's first configuration. Its PicoBlaze updates the boot tally, then reconfigures the FPGA from slot B | config flash `$00000`, never rewritten |
| slot B | the configuration the cart runs from then on: the logic, the PicoBlaze's programs, and stage1 in block RAM | config flash `$40000`, written by the updater |
| stage1 | the Game Boy program served from slot B's block RAM, which loads the kernel ([stage1/](../stage1/README.md)) | inside slot B |
| kernel | the menu, loaded from `ezgb.dat` | the SD card |

Slots A and B are both stage0: two configurations of the same chip.

## What is here

| Path | What |
|---|---|
| `fw4/`, `fw5-0918/` | one folder per firmware: its decoded bitstream (`decode.txt`), pin and register maps (`pins.txt`, `regs.txt`, `regmap.txt`), and the PicoBlaze's programs disassembled (`picoblaze/`) |
| `fw4/rtl/`, `fw4/blocks/` | the readable Verilog of FW4 and the block files that tie it to the bitstream |
| `fw5-0918/` | the modules and block files where FW5-0918 differs from FW4 |
| `updater/` | the firmware updater's program in C, FW4's and FW5-0918's, byte for byte ([README](updater/README.md)) |
| `fw4/updater/` | the FW4 updater, disassembled |
| `flash-read.psm`, `sd-recover-fw5-0918.psm` | our patches to the PicoBlaze's programs |
| `sim/` | the whole design as simulatable Verilog, with models of the flash, the SD card and the Game Boy bus |
| `netlist/` | scripts from the analysis of the netlist |
| `lib/` | Verilog for the FPGA's primitives |
| `tools/` | the bitstream decoder, patcher and encoder, the carving and proof scripts, the updater builder |
| `floorplan/` | a [browsable map](https://lukesau.github.io/ezgb/floorplan/) of where each block sits on the chip |

EZ Flash's bitstreams are not in the repository. They, and everything
exported from them, live in the ignored `fpga/` folder.

## The docs

| Doc | Covers |
|---|---|
| [setup.md](docs/setup.md) | the tools, and building a firmware updater end to end |
| [design.md](docs/design.md) | the pins, the clocks, every register the Game Boy sees, the values of `$7FC0`, the version byte |
| [blocks.md](docs/blocks.md) | what each block of the design is, in detail |
| [picoblaze.md](docs/picoblaze.md) | the soft CPU's two programs: SD, the loader, the clock, the flash, the license check |
| [flash-map.md](docs/flash-map.md) | the config flash's layout and what a bitstream contains |
| [firmware-diff.md](docs/firmware-diff.md) | FW4 against FW5-0731 and FW5-0918 |
| [updater.md](docs/updater.md) | how the stock updater writes the flash |
| [flash-dump.md](docs/flash-dump.md), [sd-recovery.md](docs/sd-recovery.md) | our two PicoBlaze patches |
| [toolchain.md](docs/toolchain.md) | reference for prjcombine, the `s3*` tools and ISE |

## Status

The goal is readable Verilog that can be shown to be EZ Flash's design and
later placed and routed back into an identical bitstream. Three layers:

1. **An encoder.** `s3encode` rebuilds every cart bitstream byte for byte
   from its decode. Done.
2. **Readable Verilog, proven equivalent to the extracted netlist.** Done
   for FW4: every slice cell is in one of 22 blocks, each proven, and the
   stitched top level is proven and simulates identically. FW5-0918 is
   proven in 27 blocks, its console `/RESET` edge included, and its
   stitched top level is proven too.
3. **Placement and routing data**, to turn the readable design back into
   the exact bitstream. Started: [ise/](ise/README.md) builds the readable
   designs of FW4 and FW5-0918 with ISE, every register in its stock cell,
   and proves each result equivalent to stock. The LUTs and routing come
   from ISE, so the bitstreams are not stock's byte for byte.

## How the proof works

The design is cut into blocks. For each there are three things:

| | Where | What |
|---|---|---|
| block file | `fw4/blocks/<name>.blk` | the bels that make up the block, and readable names for its boundary nets and flip-flops |
| readable module | `fw4/rtl/<name>.v` | our Verilog, with the block file's port and register names |
| reference | `fpga/<fw>/blocks/<name>_ref.v`, untracked | the block's bels exactly as the bitstream configures them |

A **bel** is one LUT, flip-flop, wide mux or carry mux. `tools/carve.py`
decomposes every configured slice of the exported design into its bels and
drops those whose output reaches nothing.

`tools/equiv.sh <name>` proves the readable module equivalent to the
reference with yosys. The two are matched by name: the ports, and every
flip-flop the block file names. With the registers matched, each
next-state function and each output is a combinational proof.

**The rule that makes this work: the readable design keeps the hardware's
registers one for one.** Every flip-flop in the bitstream has a named
register in the readable module, and the logic between them is rewritten
freely. Layer 3 needs the same, since a register that is not in the
bitstream cannot be placed.

Block RAMs, the clock managers, the Device DNA port, the ICAP and the IO
tiles are not decomposed. Blocks are cut at them and their pins become
block ports.

### Invariants

Synthesis decodes a one-hot state machine with a test per bit, and the
proof covers all states, including ones that never occur. So a module may
state invariants about reachable states with `assume()` under
`` `ifdef FORMAL``, and `equiv.sh` proves every matched signal by
induction with them in force.

**A wrong invariant fails silently.** The proof says nothing about the
states an assumption excludes, and the run still reports "equivalent". So
`equiv.sh` has a third pass that turns the assumptions into assertions and
proves them on the reference itself, from reset and by induction.
Assumptions about a block's inputs cannot be proven that way and are named
`env_…`; the top-level proof discharges them.

The other check is mutation: a module with one thing wrong in each state
must fail. Every block was tried with mutants.

### What the proof does not see

- **Which clock edge a register uses, or which clock.** The structural
  passes compare next-state and output functions, so a module clocked on
  the other edge proves the same.
- **A register's power-up value.**

Both come from the block file and the bels. A mutant that changes only
them passes.

## Reproducing it

The tools run on a Mac or Linux machine. The first step exports a design
from a slot B image ([setup.md](docs/setup.md) says how to get one):

```bash
brew install yosys icarus-verilog rust
(cd stage0/tools/s3decode && cargo build --release)
# fpga/db/spartan3.zstd: prjcombine's database (docs/setup.md)
stage0/tools/export-netlist.sh <slot B image> fpga/fw4
```

`fpga/fw4/design.v` is then the structural design. With it:

```bash
stage0/tools/equiv.sh unlock                # prove one block
stage0/tools/check-bels.sh                  # the bel decomposition against the slice model
stage0/tools/prove-top.sh wiring            # the stitching of the blocks
stage0/tools/prove-top.sh rtl               # the readable top level against the references
stage0/sim/topsim.sh fpga/fw4               # simulate the readable top beside design.v (needs verilator,
                                            # and flash.hex and card.img in fpga/fw4)

python3 stage0/tools/carve.py fpga/fw4/design.v --coverage stage0/fw4/blocks/*.blk   # cells no block claims
python3 stage0/tools/carve.py fpga/fw4/design.v stage0/fw4/blocks/unlock.blk --stub  # a port skeleton for a new block
python3 stage0/tools/dumpblk.py fpga/fw4/design.v stage0/fw4/blocks/unlock.blk       # a block's equations
```

For FW5-0918, `tools/fw5-prove.sh` carries FW4's block files across and
proves each block, and `tools/fw5-top.sh wiring|rtl` proves its top level
([fw5-0918/README.md](fw5-0918/README.md)).

## The blocks

6,429 of the design's 6,543 live cells are in these 22 blocks: every slice
cell. The other 114 are the primitives the blocks are cut at (16 block
RAMs, 68 IO tiles, 24 clock buffers, the clock managers, the DNA port and
the ICAP). What each block turned out to be is in
[blocks.md](docs/blocks.md).

| Block | Bels | What |
|---|---|---|
| `unlock` | 23 | the `$7F00`/`$7F10`/`$7F20` unlock state machine |
| `gb_regs` | 358 | every register the Game Boy writes: the `$7Fxx` registers and the bank registers, through the MBC a game's type names |
| `gb_data_out` | 202 | what a Game Boy read returns, and the bus's output enable |
| `gb_bus` | 28 | the bus's state in the fast clock domain, and its address on the memory pins |
| `psram_ctrl` | 185 | which memory chip an access reaches and the page it gets; the 74HC595 serializer |
| `soft_reset` | 74 | the console reset that a `$7FE0` write starts |
| `clocks` | 20 | the clock gates |
| `p51_latch` | 1 | the one slice latch |
| `picoblaze` | 425 | the KCPSM3 soft CPU, with a two-bank instruction register |
| `picoblaze_ports` | 393 | the registers its `OUTPUT`s write and the mux its `INPUT`s read |
| `pb_periph` | 43 | its peripherals: the ICAP, I2C, the SPI flash's pins, the interrupt source |
| `rtc_bridge` | 147 | the clock chip's readings, passed to the Game Boy's register window |
| `sd_controller_wb` | 531 | the SD controller's register file |
| `sd_cmd_master`, `sd_cmd_serial` | 338, 1,333 | the SD command line |
| `sd_data_master`, `sd_data_serial` | 123, 1,347 | the SD data lines |
| `sd_clock_divider` | 53 | the SD clock |
| `sd_crossings` | 414 | every register and pulse synchronizer between the two SD clock domains |
| `sd_fifos`, `sd_fifo_filler` | 71, 189 | the two data FIFOs and the master that moves their words to memory |
| `sd_mem_path` | 131 | the sector buffer at `$A000`, and the path that writes a loading ROM into the game store |

The SD controller is Marek Czerski's
[SD card controller](https://github.com/mczerski/SD-card-controller) from
OpenCores, at its 2013 revision (LGPL, kept in the modules), with EZ
Flash's widths. The PicoBlaze is Xilinx's KCPSM3. The rest EZ Flash wrote.

## The top level

`tools/mktop.py` stitches the blocks into `fw4/rtl/fw4_top.v`: a module
`fw4_logic` that instantiates the 22 blocks, wrapped by `fw4_top` with the
114 primitives copied from the exported design as wired there.

`tools/prove-top.sh` proves it against the exported design in two steps:

- **`wiring`**: every live slice bel, carved flat, against `fw4_logic`
  over the blocks' carved references. The same cells on both sides, so
  what it proves is the stitching. 7,282 signals.
- **`rtl`**: `fw4_logic` over the references against `fw4_logic` over the
  readable modules. 4,314 signals, then every invariant.

With `check-bels.sh`, which proves the exported design's slices equal
their bels, that chain makes `fw4_top` equivalent to the exported design.

`fw4_top` also runs in the testbench in the exported design's place: a
full boot with the flash and SD card models, through stage1's first sector
read. The two logs are identical line for line, timestamps included. One
allowance makes that so: the exported design's run is built with
`NO_SLICE_GSR`, which lets its flip-flops start from their initial values
at time 0 as the readable registers do.
