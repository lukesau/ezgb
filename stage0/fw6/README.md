# FW6

FW6 (`Update_FW6_11-17.gb`, a test build from November 2026) as readable
Verilog. It is FW5-0918 placed and routed again with a new game clock, so
most of it is FW5-0918's modules: `fw6_top.v` instantiates
`stage0/fw6/<block>.v` where FW6 has a module here, FW5-0918's
(`stage0/fw5-0918/`) where that build has one, and FW4's
(`stage0/fw4/rtl/`) otherwise. What changed is in
[stage0/docs/fw6.md](../docs/fw6.md).

| File | What |
|---|---|
| `mbc3_rtc.v`, `mbc3_rtc.blk` | the game clock, new in FW6: a one-second divider and the seconds, minutes, hours and day counters |
| `mbc3_clock.v` | the clock registers a game writes, with a toggle per register in place of FW5's write flags and latch |
| `gb_data_out.v` | FW5's, reading the clock live, with version byte 6 |
| `picoblaze_ports.v` | FW5's, without the registers FW6 dropped |
| `picoblaze.v` | FW4's, with FW6's carry select |
| `psram_ctrl.v` | FW5's, with two equal bank bits read the other way round |
| `fw6_top.v` | the stitched top: `fw6_logic` over the blocks, and `fw6_top` with the pads, block RAMs and clock primitives around it |
| `fw6_logic.blk` | every slice bel of FW6 as one block, each register named `u_<block>__<name>` |
| `fw6.names`, `fw6.alias` | the registers only FW6 has, and FW5 registers FW6 has under another block or name: what `fw6-carry.py` needs beyond FW5's block files |
| `picoblaze/` | the first program disassembled, with the one word FW6 changed |

## The proof

FW6 packs its logic into other LUTs than FW5, so the nets FW5's blocks
are cut at mostly do not exist in it. It is proven in one piece instead:

```
stage0/tools/fw6-prove.sh          # needs fpga/fw6 (export-netlist.sh)
```

carves every live slice bel of the exported design into one module and
proves it equivalent to `fw6_logic` over the readable modules, matched at
the 2,349 registers and at every net to a primitive: 3,539 signals. The
invariants the modules state are proven on the design afterward, as for
FW4 and FW5. `mbc3_rtc` is also proven as a block
(`BLK=stage0/fw6/mbc3_rtc.blk RTL=stage0/fw6/mbc3_rtc.v stage0/tools/equiv.sh mbc3_rtc fpga/fw6-nx`).

`fw6_top.v` and `fw6_logic.blk` were written by
`stage0/tools/fw6-carry.py` from FW5-0918's stitched top and block files
and a pairing of the two builds' bels. The proof does not use that
pairing: a wrong pair fails it.

What the proof does not see is the same as for the other builds: which
clock edge a register uses, and its value at configuration. FW6 has not
been simulated, built with ISE or run on a cart from this Verilog.
