# FW6

FW6 (`Update_FW6_20261124.gb`, released 2026-11-24 with kernel 1.06e) as
readable Verilog. It is FW5-0918 placed and routed again with the game
clock in the FPGA and stage1 stored as bytes, so most of it is FW5-0918's
modules: `fw6_top.v` instantiates `stage0/fw6/<block>.v` where FW6 has a
module here, FW5-0918's (`stage0/fw5-0918/`) where that build has one, and
FW4's (`stage0/fw4/rtl/`) otherwise. What changed is in
[stage0/docs/fw6.md](../docs/fw6.md), with what the test build of
2026-11-17 this directory first described did differently.

| File | What |
|---|---|
| `mbc3_rtc.v` | the game clock, new in FW6: a one-second divider and the seconds, minutes, hours and day counters |
| `mbc3_clock.v` | the value to load into the clock and a toggle per register, flipped by a game's write or the kernel's; the `$6000` latch and its copy of the clock |
| `gb_bus.v` | FW5's, with stage1 read as a byte from nine block RAMs |
| `gb_data_out.v` | FW5's, reading the clock live or latched, the kernel reading it at `$A018-$A01C`, with version byte 6 |
| `picoblaze_ports.v` | FW5's, without the registers FW6 dropped |
| `picoblaze.v` | FW4's, with FW6's carry select |
| `psram_ctrl.v` | FW5's, with two equal bank bits read the other way round |
| `fw6_top.v` | the stitched top: `fw6_logic` over the blocks, and `fw6_top` with the pads, block RAMs and clock primitives around it |
| `fw6_logic.blk` | every slice bel of FW6 as one block, each register named `u_<block>__<name>` |
| `fw6.names`, `fw6.alias`, `fw6.ports` | what `fw6-carry.py` needs beyond FW5's block files: the registers only FW6 has, FW5 registers FW6 has under another block or name, and the nets to and from stage1's block RAMs |
| `picoblaze/` | the two programs disassembled: the first with the three words FW6 changed, the second without the one instruction it lost |

## The proof

FW6 packs its logic into other LUTs than FW5, so the nets FW5's blocks
are cut at mostly do not exist in it. It is proven in one piece instead:

```
stage0/tools/fw6-prove.sh          # needs fpga/fw6 (export-netlist.sh of slot B)
```

carves every live slice bel of the exported design into one module and
proves it equivalent to `fw6_logic` over the readable modules, matched at
the 2,378 registers and at every net to a primitive: 3,551 signals. The
invariants the modules state are proven on the design afterward, as for
FW4 and FW5.

`fw6_top.v` and `fw6_logic.blk` were written by
`stage0/tools/fw6-carry.py` from FW5-0918's stitched top and block files
and a pairing of the two builds' bels (FW5 to the test build by
`belmatch.py`, the test build to the release the same way, the pairs
whose logic changed set by hand). The proof does not use that pairing: a
wrong pair fails it.

What the proof does not see is the same as for the other builds: which
clock edge a register uses, and its value at configuration; the ISE
build below checks both. FW6 has not been simulated or run on a cart from
this Verilog.

## Updaters

FW6's stock updater builds from source, byte for byte
([stage0/updater](../updater/README.md)), and
`stage0/tools/build-stage1-updater.sh fw6` puts our stage1 and the two
PicoBlaze patches into its slot B ([setup.md](../docs/setup.md)).

`make stage0-fw6 BUILD_HOST=<build host>` builds slot B from this
directory's Verilog with ISE instead, proves it equivalent to stock FW6 and
wraps it in the updater built from source
([stage0/ise](../ise/README.md)). That is the FW6 mod, versioned in
`stage1/VERSION.fw6`. Not yet run on a cart.

The official package goes in
`tools/ezflashjr/official/2026-11-24_FW6_K1.06e/`, and its slot B (the
updater from `$8000` on) in `fpga/cart/fw6.bin`.
