# Drawing and VRAM timing

The rules for writing to VRAM while the LCD is on, why the stock kernel
breaks them, and the two places the mod made drawing faster. Addresses are
1.05e-0731's.

## Why stock streaks

Now and then the stock kernel leaves a thin streak one tile wide in a
screen of text, which stays until the tile is redrawn. It happens on real
hardware and in SameBoy's DMG model.

Every text screen is drawn into the tile canvas at `$8100` by `DrawGlyph`
(`00:2701`), and every pixel row it writes goes through this:

```asm
.wait:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .wait        ; spin while the LCD is in mode 2 or 3
    ld a, d
    ld [hl+], a         ; plane 0
    ld a, e
    ld [hl+], a         ; plane 1
```

The check is right, but interrupts are enabled, and the kernel takes them
while it draws: VBlank, and the LYC interrupt at line 72 that switches the
BG tile addressing for the lower half of the screen. An interrupt that
lands between the `jr` and the first write runs its handler for hundreds of
cycles, and the write then executes wherever the LCD happens to be. In mode
3 a DMG discards it.

`ApplyPixel` (`00:264a`), which every line, box and fill goes through, has
the same spin followed by a read-modify-write. A read in mode 3 returns
`$FF`, so there a hit writes garbage back.

## The rules

1. **Interrupts off from the STAT sample to the last access**, and the `di`
   goes before the spin, where it costs nothing.
2. **Nothing between the sample and the last access but the access.** A
   passing sample guarantees only about 20 M-cycles, not the rest of mode 0
   plus mode 2: a sample can pass with mode 2 as the only thing left. The
   stock sequences use 10 cycles (`DrawGlyph`) and 16 (`ApplyPixel`). A
   version that reached the write through a `call` and `ret` took 20 and
   streaked every screen.
3. **To write several rows, sync to a fresh HBlank.** Wait for mode 3, then
   for mode 0, and write up to four tile rows in the 51 + 20 cycles that
   follow. One write per STAT spin caps the rate at one or two writes a
   scanline.
4. **VBlank means LY 144 to 151.** On line 153 the LY register reads 0
   while STAT still reports mode 1, so "mode 1 and LY < 153" passes with
   almost no VBlank left, and the write lands in line 0's mode 3.
5. **Do not hold interrupts off across the end of the frame.** A sync begun
   at LY 143 or later waits for the next mode 3 on the far side of VBlank,
   and the VBlank callback that switches the BG tile data back then runs
   late: the tab strip draws from the wrong tiles for a frame. Such a batch
   enables interrupts, waits for the next frame, and starts over.

To catch a violation in SameBoy:

```
watch $8000 to $9800 if ([$ff41] & 3) == 3
```

## How stock is fixed

Neither routine has spare bytes, so each was moved as a byte copy with the
`di` and `ei` added, and the original became a `jp` to the copy.

| Stock | Copy | Notes |
|---|---|---|
| `DrawGlyph` `00:2701` | `DrawGlyphSafe` `00:0094` | `di` before the spin, `ei` after the second write |
| `ApplyPixel`'s four spin-and-write blocks (`00:266b`, `268b`, `26a5`, `26bf`) | `ApplyPixelSafe` `00:2704`, in the old `DrawGlyph` body | one copy per draw op: copy, or, xor, set |
| `GetPixel`'s spin `00:26e7` | calls `VramWaitSpin` `00:05c8` | its sequence after the sample is 14 cycles even with the `ret` |

The `ei` is unconditional, so `DrawGlyph` must not be called with
interrupts deliberately off. The kernel's nested critical sections
(`DiNest` / `EiNest`, counter `wIntNest` at `$d6d0`) do not draw text.

Not covered, on purpose: `VramFill` (used only with the LCD off),
`VramCopy` and `BlitTile` (the boot logo), and the tile-mode text path,
which has no callers.

The mechanism is inferred from the code and from the watchpoint, not from a
trace of a streak as it happened on hardware.

The 12px renderer follows the same rules in its own loops
([font12.md](font12.md)).

## Faster fills and digits

`FillRect` (`02:6f40`, [fillrect.asm](../kernel/mod/asm/fillrect.asm))
replaces `DrawRectImpl`'s per-scanline `DrawLine` loop (`00:236d`). For draw
op 0, the common case, it writes each scanline's two edge tiles under their
masks and the whole tiles between them in batches of five byte pairs, each
batch synced to an HBlank. The other ops keep the stock loop.

`U32ToAsciiFast` (`04:7c00`, [u32dec.asm](../kernel/mod/asm/u32dec.asm))
takes over bank 4's `U32ToAscii` (`04:44f7`), which the SET tab's clock
uses and which made every digit with a 32-bit divide and a modulo. Radix 10
with a value under 65536 is done by subtracting powers of ten; anything
else runs the original.

Tab switch times in SameBoy (DMG model), before and after both:

| Switch | 8px | 12px |
|---|---|---|
| SD to SET | 1035 to 531 ms | 1296 to 773 ms |
| SET to HELP | 503 to 267 ms | 652 to 402 ms |
| HELP to SD | 1181 to 858 ms | 1295 to 968 ms |

SameBoy's SD reads take no time, so the HELP to SD figure, which rereads a
folder, is only indicative.

## Profiling a screen

Every idle screen polls the joypad through `ReadJoypad` (`00:3a4a`), so the
gap between two polls around a key press is how long the new screen took.
The SameBoy stub has a sampling profiler for those gaps: with
`SAMEBOY_PROFILE_GAP=<file>` set it samples the PC and the call stack every
256 T-cycles and writes out each gap longer than 1M T-cycles.

```sh
SAMEBOY_PROFILE_GAP=prof.txt SAMEBOY_EZFLASH_JR_IMG=sd/card.img \
    tools/SameBoy/build/bin/SDL/sameboy --model dmg kernel/1.05e-0731/kernel.gb
scripts/debug/gap-profile.py kernel/1.05e-0731/kernel.sym prof.txt
```

`gap-profile.py` prints each gap's self and inclusive time per function.
