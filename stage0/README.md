# stage0: the FPGA design, readable

The goal: human-readable Verilog for the EZ Flash Jr's FPGA that we can
show is the same design as the FW4 bitstream, block by block, and that we
can later place and route back into an identical bitstream. The reversing
work it builds on is in [re/stage0/](../re/stage0/README.md): the decoded
bitstream, the PicoBlaze programs, the pin and register maps, and the
whole-design simulation.

Three layers were planned
([re/stage0/docs/design.md](../re/stage0/docs/design.md), plan):

1. **Encoder**: `s3encode` rebuilds every cart bitstream byte for byte
   from its decode. Done.
2. **Readable Verilog, proven equivalent to the extracted netlist**: this
   directory. In progress.
3. **Placement and routing sidecar**: the data that turns the readable
   design back into the exact bitstream. Not started; it needs layer 2's
   block structure first.

## How layer 2 works

The design is cut into blocks. For each block there is a block file, a
readable module, and a machine-made reference carved from the design:

| | Where | What |
|---|---|---|
| block file | `blocks/<name>.blk` | the bels that make up the block, and readable names for its boundary nets and flip-flops |
| readable module | `rtl/<name>.v` | our Verilog, module `<name>`, with the block file's port and register names |
| reference | `fpga/<fw>/blocks/<name>_ref.v` (untracked) | module `<name>_ref`: the block's bels exactly as the bitstream configures them, over `lib/s3bels.v` |

A **bel** is one LUT, flip-flop, wide mux or carry mux. `scripts/fpga/carve.py`
decomposes every configured slice of the exported design into its bels and
drops the ones whose output reaches nothing (an unused carry chain, an
unconnected flip-flop). The slice's fixed selections (which LUT feeds the
flip-flop, where the carry starts, input inversions) become wiring. A
block can take one LUT of a slice and leave the other to another block.

`scripts/fpga/equiv.sh <name>` proves the readable module equivalent to the
reference with yosys. The two are matched by name: the ports, and every
flip-flop the block file names. With the registers matched, each
next-state function and output is a combinational proof (SAT); what that
leaves is tried by induction. The check must reject a broken module to
mean anything: three mutants of `unlock` (an address off by one, the lock
data ignored, a feedback term dropped) all fail it.

One yosys detail matters: it matches a net only under its canonical name,
and after flattening that is often the primitive's own hierarchical alias
(`X18Y31_S0_FFX.Q`) rather than the block's name for it, in which case it
silently makes no check cell for that net. The scripts hide every
hierarchical name before matching, so the block file's names are the ones
that count. Unmatched state can only make a proof fail, never pass.

A synthesized FSM adds a wrinkle. XST decodes a one-hot state with a test
per bit, so a register assigned in several states takes the OR of what
every active state assigns; the readable module writes those registers the
same way (`sd_cmd_serial` shows the pattern). What it cannot reproduce is
the hardware's behavior in states that never occur, such as a buffer index
past its end, and the proof covers all states. So a module may state
reachable-state invariants with `assume()` under `` `ifdef FORMAL`` (the
state is one-hot, the counter is bounded per state), and `equiv.sh` then
proves every matched signal by temporal induction with those assumptions
in force.

The invariants have to be true of the hardware, and a wrong one fails
silently: the proof says nothing about the states it excludes, and the
run still reports "equivalent". Writing `sd_data_serial`, a wrong code
for one FSM state hid that whole state from the proof, and a bound that
was off by one hid another; mutants in those states passed. So `equiv.sh`
has a third pass that turns the assumptions into assertions and proves
them on the reference itself, from its reset state and by induction. That
needs them written inductively (what they allow at one step must imply
them at the next): the data host's crc_c assumption, for one, tracks the
counter exactly through the CRC window. Assumptions about inputs (a
constant-0 LUT another block owns) can't be proven and are labeled
`env_…`, which the pass leaves as assumptions. The other check on a proof
is mutation: a module with one thing wrong in each state must fail, and
the blocks table says how many such mutants each block was tried with.

The rule that makes this work: **the readable design keeps the hardware's
registers one for one.** Every flip-flop in the bitstream has a named
register in the readable module; the combinational logic between them is
rewritten freely. That is also what layer 3 needs, since a register that
does not exist in the bitstream cannot be placed.

Block RAMs, the DCM, the Device DNA port and the IO tiles are not
decomposed: blocks are cut at them, their pins become block ports, and the
readable design will instantiate the same primitives.

LUT RAM is kept cell for cell too. `lib/s3bels.v` has the shapes a design
builds from 16x1 cells (`s3_ram16x1d`, `s3_ram32x1s`, `s3_ram64x1s`); the
readable module instantiates them, and the block file names each hardware
cell after the instance path (`X7Y26_S0_F.m regs0.sy`), which is how the
proof matches the contents. A `pc[3]`-style name in the block file makes
a vector port.

## Setup

Everything runs on this machine. The cart bitstreams are EZ Flash's and
stay out of the repository (`/fpga/` is ignored), so the first step
exports a design from a local image:

```bash
brew install yosys icarus-verilog rust
(cd scripts/fpga/s3decode && cargo build --release)
# fpga/db/spartan3.zstd: prjcombine's Spartan-3 database (see re/stage0/docs/toolchain.md)
scripts/fpga/export-netlist.sh fpga/cart/fw4-updater.bin fpga/fw4
```

`fpga/fw4/design.v` is then the structural design (`netlist2v.py`, module
`fpga_top`), and:

```bash
python3 scripts/fpga/carve.py fpga/fw4/design.v stage0/blocks/unlock.blk --stub   # port skeleton for a new block
python3 scripts/fpga/carve.py fpga/fw4/design.v --cone n_X18Y31_S0_XQ            # bels driving a net
python3 scripts/fpga/carve.py fpga/fw4/design.v --coverage stage0/blocks/*.blk    # what no block claims yet
python3 scripts/fpga/dumpblk.py fpga/fw4/design.v stage0/blocks/unlock.blk          # the block's equations, with its names
scripts/fpga/equiv.sh unlock                                                      # the proof
```

## Checking the decomposition itself

The bel decomposition is checked against the exporter's slice model, which
the simulations validated against the cart: `scripts/fpga/check-bels.sh`
carves a block of every live slice bel twice, as whole `s3_slice`
instances (`--slices`, over `lib/s3prims_synth.v`, the simulation
primitives without their start-up and delay modeling) and as bels, and
matches the two net for net: every flip-flop, LUT RAM and LUT output. For
FW4 that is 4,883 matched signals, all proven (about five minutes).

## Blocks

| Block | Bels | What | Proof |
|---|---|---|---|
| `unlock` | 23 | the `$7F00/$7F10/$7F20` unlock state machine that gates the `$7Fxx` registers | equivalent |
| `picoblaze` | 425 | the KCPSM3 soft CPU with EZ Flash's two-bank instruction register: 108 flip-flops, all 68 LUT RAMs (register file, 31-deep stack, 64-byte scratchpad) | equivalent, 1,213 signals |
| `sd_cmd_serial` | 1,333 | the SD command line: OpenCores `sd_cmd_serial_host` (LGPL, kept in the module), 358 flip-flops, 975 LUTs and muxes, most of them the 32-bit counter's compares and the response buffer's indexed writes | equivalent, 361 signals, under stated invariants (proven); 3 mutants |
| `sd_cmd_master` | 338 | OpenCores `sd_cmd_master`: the command and argument latch, the 16-bit timeout watchdog, the response and interrupt-status registers; 205 flip-flops | equivalent, 212 signals, under stated invariants (proven); 2 mutants |
| `sd_data_serial` | 1,347 | OpenCores `sd_data_serial_host`: the DAT lines, the four CRC16s, the 14-bit transfer counter, the receive word and its write enable; 174 flip-flops | equivalent, 180 signals, under stated invariants (proven); 28 mutants, all caught |
| `sd_data_master` | 107 | OpenCores `sd_data_master` with `sd_data_xfer_trig`: starts and stops the data host, the 8-bit timeout watchdog, the command-with-data trigger; 30 flip-flops | equivalent, 35 signals, under stated invariants (proven); 12 mutants, all caught |

The `sd_cmd_serial` proof was first made with an IDLE counter bound of 4;
the hardware hands IDLE a 5 for one cycle, so that one state was outside
the proof until the invariant was corrected (2026-10-27).

Coverage: 3,573 of 6,529 live cells (3,004 LUTs, 2,122 flip-flops, 68 LUT
RAMs, 916 muxes, 283 carry XORs, and the 16 BRAMs, 68 IO tiles, 24 clock
buffers, DCM and DNA port).

What the PicoBlaze block settled: the core is stock KCPSM3 (two cycles per
instruction, the ALU as three partial-result registers OR-ed together, the
stack pointer counting up and down across the two phases), the
instruction register in front of it is clocked on the falling edge and
picks bank 1 or 2 by the port C8 bit, in_port arrives through eight
falling-edge registers outside the block, and the interface is otherwise
KCPSM3's own: pc, port_id, out_port, read/write strobes, interrupt and
its ack.

What the SD block settled: the controller is Czerski's 2013 version
(https://github.com/mczerski/SD-card-controller), unchanged in this module
apart from what synthesis did to it; the Wishbone side lives in the mode
clock domain and crosses into the SD clock domain through the source's
two-flop synchronizers; `cmd_dat_reg` is the pad's input register and
`cmd_out_o`/`cmd_oe_o` are registered again in the pad's output cells.
The command master's timeout register and watchdog are 16 bits (the
register file never sets the upper byte), and its busy input is the DAT0
pad inverted: the card holds DAT0 low while busy.

What the data host settled: it is the source at revision bf94521b (2013:
the abort from every state, a three-bit crc_status), built with
`BLKSIZE_W` 10 and `BLKCNT_W` 8, so the transfer counter is 14 bits and
the block count 8. The synthesis made its FSM binary (IDLE 000, WRITE_DAT
001, WRITE_CRC 101, WRITE_BUSY 010, READ_WAIT 100, READ_DAT 011), kept
only the two bits of `blksize_reg` the byte-alignment update reads, and
dropped their reset. One thing is not in the source: in 4-bit mode the
cycle count is `((blksize | 4) << 1) + 2`, as if bit 2 of the block size
were always set; harmless for the sizes used (8n - 1 bytes), origin
unknown. Around the block: `data_in` is the transmit buffer's read port
(block RAM X3Y9) and `data_out` feeds the receive buffer's write port
(X3Y1) directly, `we` is that RAM's write enable, and `rd`/`we` step EZ
Flash's own address counters; the DAT pads take the next values of
`DAT_dat_o` and `DAT_oe_o` into their own output registers, and the DAT2
pad is input only.

What the data master settled: the synthesis merged it with the transfer
trigger (`sd_data_xfer_trig`) and kept both FSMs' source codes; the
timeout is 8 bits (`DATA_TIMEOUT_W`); the data interrupt status register
is gone, nothing reads it, and with it the CRC result; the command start
reaches the trigger as the two sync taps of the source's monostable
crossing; the command master's `int_status_cc` and `cmd_int_n` LUTs feed
the trigger, so they stay in that block. The buffer flags it watches
(`tx_fifo_full`, `tx_fifo_empty`, `rx_fifo_full`) are EZ Flash's own, and
`tx_fifo_full` is a Game Boy-domain register read without a synchronizer.

## Next

- The rest of the SD controller: the clock divider and the register
  crossings, with the source in hand; then EZ Flash's own buffer logic
  around the data host (the address counters, the buffer flags, the
  status registers that watch the data master's timeout and flags).
- The PicoBlaze's ports: the `$7Fxx`-side and peripheral registers it
  reads and writes (the in_port mux, port C8's bank bit, the interrupt
  source at `X23Y29_S1`), which the carve of `picoblaze` leaves as its
  neighbors.
- Marek Czerski's `sdc_controller` (OpenCores), with a published source to
  compare against.
- The `$7Fxx` register file and the Game Boy bus decode around `unlock`.
