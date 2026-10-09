# FW5 bitstreams: 0731 vs 0918

Decoding of the FW5 updater payloads and what the 0918 update changed
(2026-10-08). Method and FW4 background: [fpga-bitstream.md](fpga-bitstream.md),
[fpga-picoblaze.md](fpga-picoblaze.md). The
decodes, BRAM dumps and listings are in the ignored `fpga/fw5-decode/`.

## Images

Each FW5 updater carries two XC3S200A streams, at `$8000` and `$2C80C`
(`extract-bitstreams.py`). The second is byte-identical in all three FW5
updaters, so there are four distinct designs:

| Name | Source | sha1 |
|---|---|---|
| **0731** | `Update_FW5_7-31.gb` @ `$8000` | `9f05e8ff2816` |
| **0918** | `Update_FW5_2021-9-18.gb` @ `$8000` | `9c3802abc169` |
| **sgb-beta** | `Update_FW5_forSGB.gb` (2020-09-29) @ `$8000` | `c8d9b6932e6c` |
| **second image** | all three @ `$2C80C` | `525d9d8ea9c7` |

All four decode completely (0 unclaimed bits). Same chip settings as FW4
(COR, CCLK, `GENERAL1/2` = 0).

## Comparing builds

Every build is placed and routed from scratch, so the same BRAM content lands
on different tiles and most routing bits move. That is why
[fpga-flash-map.md](fpga-flash-map.md) measured 0731 and 0918 as 61% different
bytes. A tile-by-tile diff is mostly noise; the useful comparisons are by
content:

- **BRAMs** matched by hash of their contents, wherever they were placed.
- **PicoBlaze code** matched routine by routine (`scripts/fpga/picoblaze-diff.py`).
- **I/O, DCM and global settings**, which sit at fixed locations.

## BRAM contents across builds

| Content | FW4 | 2nd image | 0731 | 0918 | sgb-beta |
|---|---|---|---|---|---|
| PicoBlaze bank 2 (flash, DNA, licence, MultiBoot) | X3Y25 | X19Y25 | X19Y21 | X3Y5 | X3Y5 |
| PicoBlaze bank 1 | X3Y29 | X19Y29 | X19Y25 | X3Y1 | X3Y1 |
| stage1 `$4000-$47FF` | X19Y17 | X19Y17 | X3Y17 | X3Y17 | X3Y17 |
| stage1 `$0000-$3FFF` bit planes | 8 | 8 | 8 | 8 | 8 |

- **Bank 2 is identical in every image**, FW4 included: one program,
  never changed. Its `$1B8` constant is `02` everywhere in FW5, i.e. the
  "do not hand over" setting that FW4's slot B carries. So in FW5 neither image
  hands over to the other the way FW4's slot A does; whatever sits at flash 0
  runs. Which image the updater writes to 0 is not known yet (needs an FW5
  flash dump, or reading the updater's write addresses).
- Each image also has three x36 and one x9 BRAM with no initial data (runtime
  RAM), as FW4 does.

## stage1: SGB header

`stage1-from-bram.py --discover` against daid's FW5 `stage1.gb` matches the
**2nd image and 0731 exactly**. 0918 and sgb-beta differ from it in three
header bytes, and are identical to each other:

| Offset | 0731 | 0918 / sgb-beta | Meaning |
|---|---|---|---|
| `$0146` | `00` | `03` | SGB flag: supports SGB functions |
| `$014B` | `00` | `33` | old licensee code; SGB requires `$33` |
| `$014D` | `FA` | `C4` | header checksum, recomputed |

That is the whole of "SGB support" on the bootstrap side: the header the
console reads at power-on now declares SGB features, the same two bytes a
normal SGB-enhanced cartridge sets. (Same idea as the SGB patch in
[sgb-boot.md](sgb-boot.md), done in the bitstream instead.)

## PicoBlaze bank 1: MBC3 RTC fixes

Bank 1 in FW5 has grown an emulated **MBC3 real-time clock**, the in-game
clock of carts like Pokémon Gold/Silver. The PCF8563 provides seconds; bank 1
keeps elapsed seconds/minutes/hours/days in scratchpad `$33-$36` and outputs
`base + elapsed` on ports `A5` (S), `A6` (M), `A7` (H), `A8` (DL), `A9` (DH).
Port `B9` = 1 while a game's RTC is live.

`picoblaze-diff.py` 0731 → 0918: 76 of 78 routines identical. Only the main
loop and the interrupt handler changed:

| | 0731 | sgb-beta | 0918 |
|---|---|---|---|
| Game writes S/M/H (`B5` = `$04`/`$02`/`$01`) or DL/DH (`B8` = 1/2) | not handled; the next tick recomputes base + elapsed over it | handled: take the written value, reset that field's elapsed count | same as beta |
| Halt bit (DH bit 6) | ignored | ignored | honoured, no ticking while set |
| Value ≥ 60 (≥ 24 for H) written | plain wrap arithmetic | same | counts up and masks to 6 (5) bits |
| Day counter overflow | `OR $80`: carry set, day bit 8 stays set | same | `LOAD $80`: carry set, day bit 8 cleared |
| PCF8563 polled every loop | yes | yes | only when no game RTC is running |
| Debug bytes (`DD` + command) on every interrupt | yes | yes | removed |

So the sgb-beta added RTC register writes, and 0918 then fixed halt, range
and day-carry handling. The halt/range/carry rows are consistent with
documented MBC3 behaviour, but nothing here was tested against a game.

The 2nd image's bank 1 is an older design again: 75 of 78 routines shared
with 0731, a 79-instruction main loop and a different port set (`A8`, `A9`,
`AB`-`AF`, `BB`).

## Fabric

0731 vs 0918: I/O, DCM and global settings are identical. Logic changes are
small (3,562 → 3,572 LUTs, same 448 CLB tiles) and not attributable tile by
tile across a re-place.

FW4 vs FW5 (0731), for reference:

- DCM synthesized clock ×3 → ×10/3, about 11% faster (reading the
  database's `CLKFX_MULTIPLY`/`DIVIDE` fields as M−1 / D−1, the standard
  encoding);
- one bottom-edge output (`X24Y0`) gets a registered tristate, one west-edge
  input (`X25Y15`) gets a flip-flop set/reset.

## The reported "SD fix"

Not found in the PicoBlaze: the SD routines are identical between 0731 and
0918. Candidates are the removed per-interrupt debug output (each byte waits
for the debug port), or the unattributed logic change. Unconfirmed.

## Open

- Which FW5 image the updater puts at flash 0, now that neither hands over.
- Pin the MBC3 port mapping (`A5-A9`, `B8`, `B9`) to the GB-side registers.
- What the 2nd image's older RTC design does with ports `AB`-`AF`, `BB`.
