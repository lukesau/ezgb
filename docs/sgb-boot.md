# SGB BOOT: Super Game Boy unlock

On a Super Game Boy the EZ Flash Jr shows a black screen forever. The Jr
holds the Game Boy CPU in reset while its FPGA loads, so the CPU misses the
moment the SNES listens for the six packets the boot ROM sends with the
cartridge header, and the SNES never shows a picture. nitro2k01's
[SGB Enabler](https://blog.gg8.se/wordpress/2021/08/19/nitro2k01s-sgb-enabler-for-ez-flash-jr/)
(2021, a patched 1.04e kernel) fixed it by sending those packets again from
the kernel. The mod does the same, behind a SET-tab checkbox.

## Using it

On a DMG, GBC or GBA: SET tab, last row, `SGB BOOT:`, A to tick it. Move the
cart to the Super Game Boy and power on. Every boot with it ticked takes about
7 seconds longer, on every model, so untick it when the cart goes back to a
handheld.

The setting is not in `EZGB.CFG`: the packets go out at the very start of the
boot, long before the SD card is up. It lives in battery-backed pSRAM, so a
dead coin cell turns it off (see below).

## How it works

| Where | What |
|---|---|
| `$0100` | `nop; jp SgbStub` instead of `jp KernelEntry` |
| `00:0020` | `SgbStub`, 9 bytes: `push af`, map ROM bank 1, `jp SgbUnlock` |
| `01:7f00` | `SgbUnlock`, 218 bytes (`scripts/sgb/sgb_boot.asm`) |
| `$0146` | SGB flag `$00` -> `$03` |
| `$014B` | old licensee `$00` -> `$33` (the SGB BIOS ignores a cart without both) |
| `$014D` | header checksum recomputed |

`SgbUnlock` maps pSRAM page `$11` the way the kernel does (`$4000 = $11`,
`$7FC0 = $03`), reads the record at `$A400`, and unmaps again. Only
`'S', 'G', $01, $FE` counts as on; anything else (a cart that never had the
mod, a dead cell's garbage, a record damaged by decay) boots straight on. When
on, it sends the six header packets (commands `$F1`..`$FB`, each the sum of
its 14 bytes and then 14 bytes of `$0104`-`$014F`, zero past the end) four
times, with the Enabler's 192, 64 and 48 frame gaps and 4 frames after each
packet, then restores A and jumps to `$0150`.

Differences from the Enabler: the packets are built from the live header, so
their checksums can't go stale (the Enabler's sixth packet carried an old
global checksum); the waits count CPU cycles instead of halting for VBlank, so
they don't depend on the LCD being on; A is preserved for KernelEntry.

The checkbox is `flcfg.c`'s row 6 (`sgb_get` / `sgb_set`), drawn on row 16 of
the pane; the cursor clamp at `04:5604` allows it. The record's place in
pSRAM: [psram-page-map.md](psram-page-map.md).

## Build

`scripts/inject-sgb.py <ver> --apply` assembles the routine and injects it,
the stub, the `$0100` jump and the header bytes into `re/<ver>/kernel.gb`.
`port-mod.py` carries it between builds (`SgbStub` and `SgbUnlock` are data
blocks; the header is copied as data). `build-kernel.sh` recomputes `$014D`
when it rebuilds from the disassembly.

The `mod-5.2-sgb` test release always sends: `scripts/make-sgb-dist.py`
assembles the same file with `-D SGB_ALWAYS`.

## Status

Checked in SameBoy with a logging build of its SGB core: 24 packets with
valid checksums when on, none when off, on all three kernels. On a GBC (FW4
Jr, 1.05e-0918) the checkbox persisted and boots took longer when on. Not yet
seen on a real Super Game Boy.

A cart without a coin cell keeps the record for about a minute out of the
console (the pSRAM's charge holds that long), then loses it and boots normally.
