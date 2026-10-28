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

The rule that makes this work: **the readable design keeps the hardware's
registers one for one.** Every flip-flop in the bitstream has a named
register in the readable module; the combinational logic between them is
rewritten freely. That is also what layer 3 needs, since a register that
does not exist in the bitstream cannot be placed.

Block RAMs, the DCM, the Device DNA port and the IO tiles are not
decomposed: blocks are cut at them, their pins become block ports, and the
readable design will instantiate the same primitives.

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
scripts/fpga/equiv.sh unlock                                                      # the proof
```

## Checking the decomposition itself

The bel decomposition is checked against the exporter's slice model, which
the simulations validated against the cart: a block of every live slice
bel is carved twice, as whole `s3_slice` instances (`--slices`, over
`lib/s3prims_synth.v`, the simulation primitives without their
start-up and delay modeling) and as bels, and the two are matched net for
net. See the status below for where that stands.

## Blocks

| Block | Bels | What | Proof |
|---|---|---|---|
| `unlock` | 23 | the `$7F00/$7F10/$7F20` unlock state machine that gates the `$7Fxx` registers | equivalent |

Coverage: 23 of 6,529 live cells (3,004 LUTs, 2,122 flip-flops, 68 LUT
RAMs, 916 muxes, 283 carry XORs, and the 16 BRAMs, 68 IO tiles, 24 clock
buffers, DCM and DNA port).

## Next

- The PicoBlaze (KCPSM3): the program counter is the ten flip-flops in
  `X2Y25_S1`, `X2Y25_S3`, `X2Y26_S1`, `X2Y26_S3`, `X2Y27_S1` (address of
  both program BRAMs), and all 68 LUT RAMs in the design are its register
  file, stack and scratchpad. KCPSM3 has a published structure, so it is
  the block to prove the method on at size before EZ Flash's own logic.
- Marek Czerski's `sdc_controller` (OpenCores), likewise with a published
  source to compare against.
- The `$7Fxx` register file and the Game Boy bus decode around `unlock`.
