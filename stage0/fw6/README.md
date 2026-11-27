# FW6

FW6 (`Update_FW6_20261127.gb`, the build of 2026-11-27 that replaced the
release of 2026-11-24) as readable Verilog. It is FW5-0918 built again
with the game clock in the FPGA, stage1 stored as bytes, no clock gates
and a narrower SD controller, so most of it is FW5-0918's modules: `fw6_top.v` instantiates `stage0/fw6/<block>.v` where FW6 has a
module here, FW5-0918's (`stage0/fw5-0918/`) where that build has one, and
FW4's (`stage0/fw4/rtl/`) otherwise. What changed is in
[stage0/docs/fw6.md](../docs/fw6.md), with what the withdrawn release of
2026-11-24 and the test build of 2026-11-17, which this directory
described before, did differently.

| File | What |
|---|---|
| `mbc3_rtc.v` | the game clock, new in FW6: a one-second divider and the seconds, minutes, hours and day counters |
| `mbc3_clock.v` | the value to load into the clock and a toggle per register, flipped by a game's write or the kernel's; the `$6000` latch and its copy of the clock |
| `gb_bus.v` | FW5's, with stage1 read as a byte from nine block RAMs, and the busy flag's copy for the loader's write clock |
| `gb_regs.v` | FW5's, without the `$7F37` bit 7 register |
| `clocks.v` | FW5's, without the PicoBlaze clock gate |
| `sd_clock_divider.v`, `sd_controller_wb.v`, `sd_crossings.v`, `sd_cmd_master.v` | FW5's (FW4's for the last), with a 5-bit clock divider and an 8-bit command timeout |
| `sd_data_serial.v` | FW5's, with FW4's 4-bit data cycle count |
| `gb_data_out.v` | FW5's, reading the clock live or latched, the kernel reading it at `$A018-$A01C`, with version byte 6 |
| `picoblaze_ports.v` | FW5's, without the registers FW6 dropped and without the timer's ports |
| `picoblaze.v` | FW4's, with FW6's carry select and a second register for `port_id` bit 1 |
| `psram_ctrl.v` | FW5's, with two equal bank bits read the other way round |
| `fw6_top.v` | the stitched top: `fw6_logic` over the blocks, and `fw6_top` with the pads, block RAMs and clock primitives around it |
| `fw6_logic.blk` | every slice bel of FW6 as one block, each register named `u_<block>__<name>` |
| `fw6.names`, `fw6.alias`, `fw6.ports`, `fw6.drop` | what `fw6-carry.py` needs beyond FW5's block files: the registers only FW6 has, FW5 registers FW6 has under another block or name, the nets to and from stage1's block RAMs, and the FW5 block FW6 does not have (the PicoBlaze timer) |
| `picoblaze/` | the two programs disassembled: the first with the two words FW6 changed, the second without the one instruction it lost |

## The proof

FW6 packs its logic into other LUTs than FW5, so the nets FW5's blocks
are cut at mostly do not exist in it. It is proven in one piece instead:

```
stage0/tools/fw6-prove.sh          # needs fpga/fw6 (export-netlist.sh of slot B)
```

carves every live slice bel of the exported design into one module and
proves it equivalent to `fw6_logic` over the readable modules, matched at
the 2,306 registers and at every net to a primitive: 3,478 signals. The
invariants the modules state are proven on the design afterward, as for
FW4 and FW5.

`fw6_top.v` and `fw6_logic.blk` were written by
`stage0/tools/fw6-carry.py` from FW5-0918's stitched top and block files
and a pairing of the two builds' bels (FW5 to the test build by
`belmatch.py`, the test build to the release of 2026-11-24 and that to
this build the same way, the pairs whose logic changed set by hand). The proof does not use that pairing: a
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

The SD recovery patch was written for FW5-0918 and sets the command
timeout to `$FFFF` SD clocks. FW6 keeps eight bits of that register, so
on FW6 the patch's timeout is 255 clocks, which a command that waits on
the card's busy line can outlast. That has not been reviewed or tested:
do not flash a patched FW6 build before it is.

`make stage0-fw6 BUILD_HOST=<build host>` builds slot B from this
directory's Verilog with ISE instead, proves it equivalent to stock FW6 and
wraps it in the updater built from source
([stage0/ise](../ise/README.md)). That is the FW6 mod, versioned in
`stage1/VERSION.fw6`. Not yet run on a cart.

The official package goes in
`tools/ezflashjr/official/2026-11-27_FW6_K1.06e/`, and its slot B (the
updater from `$8000` on) in `fpga/cart/fw6.bin`.
