# The FW version byte

The kernel reads the cart's firmware version by writing `$7FC0 = $04` and
reading any byte in `$A000-$BFFF` (FW4 reads `$04`, FW5 `$05`; the HELP tab
draws `ver: FW<n>`). The byte comes from the FPGA fabric, not from either
PicoBlaze program. Found with `s3trace --netlist` and the scripts in
[`re/stage0/netlist/`](../netlist/README.md), on the FW4
slot B design.

## The cartridge data bus

24 IO pins are bidirectional: the 16-bit memory bus and the cartridge's 8
data lines, which are the 8 on the left edge. Each data bit reads its own
block-RAM output bit, which names them:

| Bit | IOI (`O1` = output to the bus) |
|---|---|
| D0 | `X0Y32 IOI[1]` |
| D1 | `X0Y19 IOI[1]` |
| D2 | `X0Y19 IOI[0]` |
| D3 | `X0Y18 IOI[1]` |
| D4 | `X0Y18 IOI[0]` |
| D5 | `X0Y15 IOI[1]` |
| D6 | `X0Y15 IOI[0]` |
| D7 | `X0Y2 IOI[1]` |

Each output is a small OR-of-terms tree of LUTs, one per-bit F5 mux among
them.

> **Correction (2026-10-09).** This page first said the F5 mux is
> `BX ? G : F` because only that convention gave clean results in a
> data-forced-to-0 test. Simulating the whole design proved the opposite:
> prjcombine's documented `BX ? F : G` is right (the PicoBlaze bank switch
> fails with the other). Re-run with the correct mux, the constant-byte
> results below are unchanged (`$00 $01 $04 $E1` for FW4, `$00 $01 $05 $E1`
> for FW5), and the decode LUTs and their sinks are structural facts. The
> LUT-edit search in "Making it 6" was run with the wrong mux and is not
> reliable.

## Registers seen from the bus

Grouping flip-flops that latch the data pins by their clock enable gives
the write registers. Two are needed here:

- **Mode** (`X14Y20 SLICE[0]`/`[1]` YQ, latching D7 and D3, power-on `11`):
  `11` = stage1, `10` after stage1 writes `$7F32 = $80`, `00` after the
  kernel writes `$7F31/$7F32 = $00` before a game. Matches the
  `$7F31`/`$7F32` writes in docs/fpga-stage1.md.
- **Page** (`$7FC0`): a 4-bit register latching D0-D3; bit 2 is
  `X14Y19 SLICE[0]` YQ, bit 3 `X14Y18 SLICE[3]` YQ, bits 0/1 in
  `X13Y16 SLICE[1]`.

Address bits A15/A14/A13 arrive on `X0Y29 IOI[0]`, `X0Y30 IOI[0]`,
`X0Y30 IOI[1]` (the version read needs them at `1 0 1`).

## Constant bytes

With the data-carrying leaves (block-RAM outputs, data pins) quantified
out, the bus can only drive a fixed byte for these: in kernel mode `$00`,
`$01` (SD done), `$E1` (SD busy) and `$04`; in game mode only `$01`. The
`$04` state is exactly: kernel mode, page = 4, `$A000-$BFFF`, and one more
flip-flop (`X17Y22 SLICE[2]`) clear.

## Where the 4 comes from

`X12Y18 SLICE[3] X` (LUT `0008`) is the version select: page bit 2 and the
`$A000` region with page bits 0 and 1 clear. It feeds only D2's F5 mux
(`X17Y18 SLICE[0]`, F table `FFDC`, which outputs 1 for it) and one other
LUT. So the version's 1 reaches D2 alone.

## How the version is stored: as wiring

The same analysis on the two FW5 designs (0731 and 0918) gives constant
bytes `$00 $01 $05 $E1`: the FW4 set with 5 for 4. The data pins are the
same pins in all three designs; everything else is placed differently.

| Design | Version-read decode | Its sinks | Byte |
|---|---|---|---|
| FW4 | `X12Y18 SLICE[3]` X, LUT `0008` | D2's tree only | `$04` |
| FW5 0731 | `X9Y23 SLICE[2]` Y, LUT `0400` | D0's tree and D2's tree | `$05` |
| FW5 0918 | `X9Y21 SLICE[3]` X, LUT `0400` | D0's tree and D2's tree | `$05` |

In each design one LUT decodes "version read" (kernel mode, page 4,
`$A000-$BFFF`), and the version number is simply **which data bits that
signal is wired into**: one OR term in each bit that is 1. There is no
register, ROM cell or flash byte holding the number; it is a constant in
EZ Flash's HDL that synthesis turned into routing. Each new firmware is a
complete new design, written whole to slot B by the updater, which is
why the number changes with no "set version" step anywhere.

What the updater contributes is only text: its screen line
`Update to ver:4` is a fixed string at `$11D2` (the 16 bytes
`make-updater.py` relabels). It never reads the cart's version: its only
`$7FC0` write is in an unreferenced function
([../../../docs/updater-flash-write.md](../../../docs/updater-flash-write.md)).

> **Correction (2026-10-09).** [../../../docs/fpga-cgb.md](../../../docs/fpga-cgb.md) said the updater
> "shows the cart's current firmware version for display only". It
> doesn't: the version on its screen is the fixed `Update to ver:4` label,
> and nothing in it reads `$7FC0=$04`.

## Making it 6

(Computed with the wrong F5 convention; see the correction above. Kept for
the record; the routing conclusion needs re-checking before any use.)

6 = `$06` needs the same select on D1. Searched with BDDs:

- No truth table for any single LUT in D1's tree gives
  "D1 = old D1 OR version read" in every state.
- The nearest candidate, `X13Y16 SLICE[0]` (its X feeds D1's F5 mux), is
  a shared select that also feeds the F5 muxes of D3-D7; editing it changes
  those bits.
- D1's F5 mux, `X23Y32 SLICE[1]`, has two **unused inputs** (F1, F2). Routing
  the version select (`X12Y18 SLICE[3] X`) to one of them, and adding it to
  that mux's F table (`F000` -> `F3&F4 | F1`), would put the 1 on D1 without
  touching any other bit. That is one hand-routed net, about 11 columns and
  14 rows, through switches that are currently off.

So FW6 in the register is a routing edit, not a table edit.
