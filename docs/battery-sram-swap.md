# Coin-cell drain and the U4 SRAM swap

The EZ Flash Jr's coin cell (CR2016/CR2032 in the front-side holder) keeps the
RTC running and holds the 512 KB save/settings store. Many later carts drain
that cell in about a month. The cause is a parts substitution, not a firmware
bug: U4's RAM die changed from true SRAM to pseudo-SRAM (pSRAM), and pSRAM
draws one to two orders of magnitude more standby current. The fix is to swap
U4 for a pin-identical member of the same chip family that has an SRAM die.

## Credit

This was first worked out by **moon_rabbit** in the GBAtemp thread
[Rapid battery drain EZ Flash Junior](https://gbatemp.net/threads/rapid-battery-drain-ez-flash-junior.620759/)
(Oct-Dec 2022): they identified the SRAM-to-pSRAM change, wrote the
"80 = pSRAM, 08 = SRAM" rule of thumb, performed the swap
(`71PL032J80` to `71PL032J08`), and reported a year-plus of battery life after
it. EZ-Flash's own reply in the sibling thread
[EZ Flash Jr battery drains quickly](https://gbatemp.net/threads/ez-flash-jr-battery-drains-quickly.617501/)
confirms the design intent: the cell powers "both the RTC chip and the SRAM"
and is expected to last "usually around 1 year". This page adds the datasheet
verification (part-number decoder, standby currents, ball map) and current
sourcing.

## What U4 is

U4 is a Spansion S71 stacked multi-chip package: one S29PL NOR flash die plus
one RAM die on a shared x16 bus, in a 56-ball 7 x 9 mm FBGA (Spansion package
code TLC056, 0.8 mm pitch). Only the RAM die matters to the Game Boy side: it
is the battery-backed 64-page / 512 KB store mapped in
[psram-page-map.md](psram-page-map.md). The NOR die has no GB-visible use
(see [hardware-board.md](hardware-board.md)).

Boards seen so far, oldest first:

| U4 marking | Family | RAM die | Source |
|---|---|---|---|
| `71GL064A08` | S71GL064A | 8 Mbit **SRAM** | nitro2k01's board survey (`tools/ezflashjr/hardware/README.md`), early carts |
| `71GL032A08` | S71GL032A | 8 Mbit **SRAM** | moon_rabbit, GBAtemp |
| `71PL032J80` | S71PL032J | 8 Mbit pSRAM | moon_rabbit, boards dated 0822 and 1022 |
| `71GL032A40BFW0F` | S71GL032A | 4 Mbit pSRAM | this project's cart (`tools/IMG_8744.jpeg`) |

## Reading the part number

The two-digit RAM field after the flash density is the same in both the
S71GL-A family (`tools/S71GL032A.PDF`, ordering information) and the newer
S71PL-J family (S71PL-J "Valid Combinations" table):

| Code | RAM die | Standby (datasheet) |
|---|---|---|
| `40` | 4 Mbit pSRAM ("Type 4") | ISB2 40 uA max (15 uA typ) with inputs static; ISB1 250 uA max with inputs toggling; no data-retention spec below 2.7 V |
| `80` | 8 Mbit pSRAM | same class |
| `04` | 4 Mbit SRAM | 10 uA max, 1 uA typ; data retention down to 1.5 V at 3 to 10 uA |
| `08` | 8 Mbit SRAM | 15 uA max, 1 uA typ; retention to 1.5 V |

So `71xL0xxx80` / `71xL0xxx40` is pSRAM and `71xL0xxx08` / `71xL0xxx04` is
SRAM, exactly moon_rabbit's rule.

Rough life on a 220 mAh CR2032, ignoring the RTC's sub-microamp draw:

| Standby current | Life |
|---|---|
| 250 uA (pSRAM, inputs toggling) | ~5 weeks |
| 40 uA (pSRAM, best case) | ~7 months |
| 10 uA (SRAM worst case) | ~2.5 years |
| 1 uA (SRAM typical) | decades (cell self-discharge dominates) |

The "about a month" reports line up with the pSRAM worst case, and the SRAM
numbers match EZ-Flash's "around 1 year" with a smaller CR2016.

## Drop-in replacements

Every part below is the same TLC056 56-ball package. The S71PL032J connection
diagram was checked ball-by-ball against the S71GL032A one (both on 56-ball
7 x 9 mm, balls A1/A8/D4/D5/E4/E5/H1/H8 depopulated) and they are identical:
A0 at E1, CE1#f at F1, CE1#s at G1, OE# at F2, WE# at A5, CE2s at B5, UB# at
B3, LB# at A3, and so on. EZ-Flash themselves fitted GL and PL parts to the
same PCB, and moon_rabbit's PL-for-PL swap ran saves, RTC, recent-games list
and firmware updates with no change.

| Part | RAM | Notes |
|---|---|---|
| `S71PL032J04` (`BFW0B0` / `BAW0B0`) | 4 Mbit SRAM | Closest match to the current 4 Mbit pSRAM part. |
| `S71GL032A08` (`BAW0F0`) | 8 Mbit SRAM | Same family as the current U4. |
| `S71PL032J08` | 8 Mbit SRAM | moon_rabbit's proven swap. |
| `S71GL064A08`, `S71PL064J08` | 8 Mbit SRAM | Bigger NOR die (unused); what the earliest carts shipped with. |

The 8 Mbit parts turn A18 into a shared flash/RAM address ball (on the 4 Mbit
parts A18 is flash-only). This is harmless: the FPGA drives whatever it drives
on A18 and the RAM just decodes it as a second half, and the `064A08` boards
shipped that way. The kernel's 64-page model is unaffected either way, since
pages 0-63 sit in the low 512 KB.

Avoid anything ending in `A0`, `B0`, `40` or `80`, and note that some
distributor databases describe every S71 part as "Flash+PSRAM" regardless of
suffix; trust the suffix, not the blurb.

### Suffix decoder (from the S71GL032A ordering information)

`S71GL032A40BFW0F0` breaks down as family `S71GL`, flash `032` (32 Mbit),
process `A`, RAM `40`, package `BF`, temperature `W`, package modifier `0`,
model `F`, packing `0`. Two letters matter for soldering:

- `BF` = Pb-free balls (SAC alloy), reflow around 245 C.
- `BA` = "Pb-free compliant" with SnPb-compatible balls, reflows cooler
  (around 220 C), which is friendlier for a hand hot-air job.

The BGA top marking drops the leading `S` and the packing digit.

## Sourcing (checked September 2026)

All of these parts are long discontinued; the only supply is surplus brokers.

- eBay, seller `chipsgate` (about 49k feedback): `S71GL032A08BAW0F0` at about
  $20 each.
- eBay, several sellers: `S71PL032J04BFW0B0` in lots of 5 for about $22-30.
- eBay, US seller `specspecialty`: single `S71PL032J04BAW0B0` for about $7.
- Depu, UTsource and similar brokers list the family but their search pages
  were not fetchable at the time of writing.

Buy from a seller with a large feedback count. "New" BGA listings from surplus
brokers are sometimes reballed pulls; inspect the balls under magnification
before soldering.

## Doing the swap

New chips arrive pre-balled, so no stencil or solder paste is needed; the balls
are the joint.

1. Remove the cell. Note that everything in the pSRAM (saves, settings,
   last-ROM path, RTC) is lost; back up saves to the SD card first.
2. Preheat the board, then hot-air the old U4 off (around 380 C air, generous
   flux). The 74HC595 and RTC sit near it; shield them if the nozzle is wide.
3. Wick the pads flat and clean with IPA. Leaving the old solder bumps under
   the new balls sometimes works but hurts alignment and coplanarity.
4. Apply tacky flux, align the new chip to the silkscreen outline with the A1
   corner matched, and reflow. Pb-free (`BF`) balls need the hotter profile.
5. Refit the cell, boot: the kernel will rebuild its settings and offer
   BACKUPSAVE-style recovery as on a fresh cart.

A stencil and loose 0.4 mm solder balls are only needed if a chip arrives with
missing or damaged balls and has to be reballed (generic 0.8 mm-pitch stencils
exist).

## Verification after the swap

moon_rabbit's check was simply RTC still running after five weeks, then a year.
A faster check is to measure the cell current with the cart unplugged: tens to
hundreds of microamps means pSRAM, single-digit microamps means SRAM. The
kernel-side pSRAM probes in [psram-page-map.md](psram-page-map.md) also work
unchanged for confirming the store is still battery-backed.

## Sources

- GBAtemp, [Rapid battery drain EZ Flash Junior](https://gbatemp.net/threads/rapid-battery-drain-ez-flash-junior.620759/) (moon_rabbit, Mancore, dotted532)
- GBAtemp, [EZ Flash Jr battery drains quickly](https://gbatemp.net/threads/ez-flash-jr-battery-drains-quickly.617501/) (EZ-Flash2's reply)
- Spansion, S71GL032A Based MCPs datasheet (`tools/S71GL032A.PDF`)
- Spansion, S71PL-J Based MCPs datasheet, rev B3 March 2006 ([alldatasheet mirror](https://www.alldatasheet.com/html-pdf/164764/SPANSION/S71PL064JA0-07/5552/14/S71PL064JA0-07.html))
- nitro2k01 / daid, `ezflashjr` board survey (`tools/ezflashjr/hardware/README.md`)
