# What's in the cart's FPGA bitstream

Results of decoding the FW4 bitstream with prjcombine's Spartan-3 database
(2026-10-08). Tooling and how to reproduce: [fpga-toolchain.md](fpga-toolchain.md).
Local-only work on the `bitstream-re` branch; the decoded listing and BRAM
dumps are in the ignored `fpga/fw4-decode/`.

## Summary

- The cart's images are **standard `bitgen` output** for the XC3S200A, not a
  custom container.
- The whole FW4 image decodes: **0 set bits unexplained** by the database.
- **stage1 lives in block RAM, proven.** All 32 KB of `stage1.gb` rebuilt from
  the bitstream alone, byte for byte.
- The design contains a **PicoBlaze soft microcontroller** running a 2K
  program from two BRAMs: SD card, game loader, RTC, config flash, and a
  licence check tied to the chip's Device DNA ([fpga-picoblaze.md](fpga-picoblaze.md)).
- Slot A and slot B differ by **one PicoBlaze instruction** plus CRCs: the
  switch that makes slot A hand over to slot B at boot.

## Images decoded

| Image | Source | Notes |
|---|---|---|
| FW4 slot B | `Update_FW4.gb[$8000:+149516]`, = flash `$40026` | identical bytes |
| FW4 slot A | `EN25F40-repaired-v2.bin[$26:+149516]` | see slot diff below |

Both report IDCODE `0x2218093` (XC3S200A) and parse with the stock prjcombine
parser unchanged.

## The format is standard

[fpga-flash-map.md](fpga-flash-map.md) read the `aa 99 30 a1` head as a
non-standard wrapping because the `aa 99 55 66` sync word never appears. That
was wrong: a Spartan-3A stream syncs on `aa 99` alone, and a stock `bitgen`
file for this part begins exactly the same way (32 × `ff`, `aa 99`, `30 a1` =
type-1 write to CMD). Each slot is a plain 149,516-byte XC3S200A stream
starting at the first `ff` dummy word; the "`$46`-byte header" in the slot is
just the end of the erased region plus those dummy words.

Configuration registers (FW4 slot B):

```
CTL0 0085   COR1 2f08   COR2 89ee   CCLK_FREQ 3c0f   POWERDOWN 0881
HC_OPT 001f   PU_GWE 0005   PU_GTS 0004   SEU_OPT 18f2   MODE 000e
GENERAL1 0000   GENERAL2 0000
```

`GENERAL1/2` (the MultiBoot next-image address) are zero in both slots.

## Resources used

From the decode against the blank baseline:

| Resource | Used |
|---|---|
| CLB tiles touched | 442 |
| LUTs with contents (F/G) | 3,449 |
| Block RAMs (of 16) | 13 with data |
| DCMs | 1 (`DCM_S3E_SE`) |
| I/O tiles | all four edges |

## Block RAM map

| BRAM | Width | Contents |
|---|---|---|
| X19Y5 | x1 | stage1 `$0000-$3FFF`, bit 0 |
| X19Y21 | x1 | stage1 bit 1 |
| X19Y25 | x1 | stage1 bit 2 |
| X3Y13 | x1 | stage1 bit 3 |
| X3Y17 | x1 | stage1 bit 4 |
| X19Y13 | x1 | stage1 bit 5 |
| X19Y9 | x1 | stage1 bit 6 |
| X19Y29 | x1 | stage1 bit 7 |
| X19Y17 | x9 | stage1 `$4000-$47FF`, bytes in order |
| X3Y25 | x18 | PicoBlaze program, bank 2 |
| X3Y29 | x18 | PicoBlaze program, bank 1 |

The other BRAMs have no initial data (unused, or used as RAM at runtime).

## stage1 is in BRAM (proven)

`$0000-$3FFF` is stored as eight 16K × 1 memories, one per data bit, which is
why no byte-oriented or constant-stride search of the flash ever found it
([hardware-board.md](hardware-board.md)). `$4000-$47FF` is one 2K × 8 BRAM.
`$4800-$7FFF` isn't stored; the reference dump has zeros there.

`scripts/fpga/stage1-from-bram.py` rebuilds all 32 KB and it matches
`tools/ezflashjr/stage1/FW4/stage1.gb` exactly. This settles the open question
in [updater-flash-write.md](updater-flash-write.md) and hypothesis (b) in
[hardware-board.md](hardware-board.md): flashing a new bitstream ships a new
stage1, with no separate write.

**Consequence for CGB mode** ([cgb-mode.md](cgb-mode.md)): the bootstrap's
header byte `$0143` is now locatable. It is bit `$143` of each of the eight
plane BRAMs. Patching it is eight bit flips in known frames plus a new CRC.
That needs an encoder (s3decode is decode-only) and would have to be proven
over JTAG before going near the flash, but it is no longer blocked on the
bitstream format.

## PicoBlaze

BRAMs X3Y29 and X3Y25 are configured 1K × 18 and hold KCPSM3 (PicoBlaze for
Spartan-3) code. They are two program banks of one processor, switched by an
output port. Disassembled and annotated in [fpga-picoblaze.md](fpga-picoblaze.md).

## Slot A vs slot B

The decoded listings differ in one place, BRAM X3Y25 word `$1B8`:

```
slot A   00001   LOAD s0, 01
slot B   00002   LOAD s0, 02      (= the FW4 updater payload)
```

The other 6 of the 8 differing bytes sit in the stream's tail, where the CRC
packets are (not individually checked). So the 2-byte cluster at
`+$1982c` that [fpga-flash-map.md](fpga-flash-map.md) grouped with the CRCs is
this instruction. It is the constant that decides whether bank 2 hands over
to slot B at boot: slot A is the golden image, slot B the active one
([fpga-picoblaze.md](fpga-picoblaze.md#bank-2-x3y25-flash-dna-licence)).

**Open:** [hardware-board.md](hardware-board.md) records that writing slot B
wholesale over slot A did not boot, while patching only the erased head did.
Both slots decode as complete, valid bitstreams differing only in that word
and CRC, so the failure isn't explained by their contents. Worth revisiting
with the decoder (check each image's CRC independently, and whether anything
outside the 149,516 bytes matters).

## Next

- Decode the FW5 images (two per updater) and diff 0731 against 0918.
- Cross-check routing hop by hop against XDL.
- An encoder with CRC, tested over JTAG on SRAM only.
