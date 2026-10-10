# Dropped VRAM writes: the stock kernel's streak artifacts

## Symptom

Now and then a row of pixels in one tile of the browser (or any other text
screen) is wrong: a thin horizontal streak, one tile wide, that stays until
the tile is redrawn. On hardware it is seen on the bottom pixel row of a tile
far more often than on any other row, and on the "Reading..." box as an
underline under one letter. Seen on
real hardware with the stock kernel and in SameBoy's DMG model; it looks the
same in both.

## Mechanism

Every text screen is drawn into the tile canvas at `$8100` by `DrawGlyph`
(`00:2701`), one 8x8 glyph per tile, and every pixel row it writes goes
through this tail (`DrawGlyph_statWait`, `00:2754`):

```
DrawGlyph_statWait::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, DrawGlyph_statWait   ; spin while the LCD is in mode 2 or 3
    ld a, d
    ld [hl+], a                 ; plane 0
    ld a, e
    ld [hl+], a                 ; plane 1
    pop de
    ld a, l
    and $0f
    jr nz, DrawGlyph_rowLoop
    ret
```

The check is right: VRAM is only locked during mode 3, and after a pass in
mode 0 there are at least 20 M-cycles of mode 2 before the next mode 3, far
more than the 6 the two writes need. But interrupts are enabled the whole
time, and the kernel takes them during drawing: VBlank, and the LYC interrupt
at line 72 that flips the BG tile addressing for the lower half of the screen
(`EnterGfxMode1`). An interrupt that lands between the `jr` and the first
`ld [hl+], a` runs its handler for hundreds of cycles, and the write then
executes wherever the LCD happens to be. In mode 3 a DMG discards the write,
and that pixel row keeps whatever it held before.

The window is a few cycles wide per row and there are thousands of rows per
screen, so it fires rarely and at random; each hit is one plane byte pair of
one tile row, which is exactly the one-tile streak. (Both writes are in the
same window, so a hit usually loses both planes of the row; the ISR's
return timing decides whether the second write survives.)

`DrawGlyph` is not the only writer. Every line, box, rule, checkbox and
rectangle fill goes through `ApplyPixel` (`00:264a`, four variants for the
draw ops copy / or / xor / set), which does the same STAT spin and then a
read-modify-write of both plane bytes; `GetPixel` (`00:26cc`) spins and
reads. A read that lands in mode 3 returns `$FF`, so for the partial bytes at
the ends of a run the pixels outside the mask come back black instead of
merely stale. `DrawRectImpl` fills a box one scanline at a time through
`DrawLine`, so a box is hundreds of these calls.

Nothing in this predicts a preference for the bottom row of a tile: the
interrupt lands at a uniformly random point of the drawing. The likely reason
the bottom row is what gets noticed is that it is where the old and new
contents usually differ (a rule line, the edge of a highlight bar, a filled
box over text), whereas a dropped middle row of a glyph drawn over a blank
area leaves blank. If the bias survives this fix, that is the thing to chase.

The 12x12 renderer of [font12.md](font12.md) was bitten by the same race
while it was being written, and there it is worse: it merges cells with
read-modify-write, and a mode-3 read returns `$FF`, so a hit does not just
keep the old row but writes garbage back, twelve pixels wide.

## Fix

Hold interrupts off from the check to the last write. `DrawGlyph` has no
spare bytes and `SetTextCursor` follows it directly, so the whole function
(100 bytes, absolute addresses and relative jumps only) is relocated as a
byte copy into the free run at `00:0094`, as `DrawGlyphSafe`, with `di`
inserted before the STAT spin and `ei` after the second write; the backward
`jr nz, DrawGlyph_rowLoop` at the end moves two bytes further from its target
(`cc` -> `ca`). `00:2701` becomes `jp $0094` and the old body is `nop`s, so
every caller still calls `DrawGlyph`.

```
        ...                     ; row composition, unchanged
        pop hl
        di                      ; new
.wait:
        ldh a, [rSTAT]
        bit 1, a
        jr nz, .wait
        ld a, d
        ld [hl+], a
        ld a, e
        ld [hl+], a
        ei                      ; new
        pop de
        ld a, l
        and $0f
        jr nz, .rowLoop
        ret
```

Cost: 2 M-cycles per pixel row plus the 4-cycle `jp` per glyph, about 20
cycles on a glyph of roughly 530, under 4%. The longest interrupt latency
added is one STAT wait plus 6 cycles, well under one scanline.

The `ei` is unconditional, so the fix assumes `DrawGlyph` is never called
with interrupts deliberately off. The kernel keeps a nesting counter for its
`DiNest` / `EiNest` critical sections (`wIntNest`, `$d6d0`); a first version
of this fix re-enabled interrupts only when that counter was zero, at 7 more
cycles per row, and was dropped for speed. Code that uses a bare `di`
(`EnterGfxMode1`) does not draw while inside it, and no interrupt callback
draws text.

### The real budget after the STAT check

Fixing `ApplyPixel` the cheap way, by replacing each 6-byte spin with `di`
+ `call` to a shared spin helper, made things much worse: deterministic
fragments of the previous screen survived every box fill. A SameBoy
watchpoint (`watch $8000 to $9800 if ([$ff41] & 3) == 3`) caught the second
plane write landing in mode 3 on ordinary lines, with the helper build
alone, no `di` at all. The distance from the STAT sample to that write was
20 M-cycles with the `call`/`ret` pair, against 16 in the stock block.

So the time a passing sample guarantees is about 20 cycles, not "the rest
of mode 0 plus mode 2": a sample can pass with mode 2 as the only thing left
(the DMG reports mode 0 briefly at the start of a line before mode 2), and
that happens often enough that a routine spending more than ~18 cycles after
its sample streaks every screen. The stock sequences are 10 (`DrawGlyph`) and
16 (`ApplyPixel`) cycles; they were tuned to this, deliberately or not. Rule
for any patch: nothing between the spin and the last access but the access
itself, and the `di` goes before the spin, where it costs nothing.

`ApplyPixel`'s four variants have no room for the extra `di`/`ei`, so each
spin-and-write block moved as a byte copy, with `di` in front and `ei` right
before the last write, into the freed old `DrawGlyph` body (`ApplyPixelSafe`,
`00:2704`, 66 bytes), and each original block became a `jp` to its copy. The
`jp` runs before the sample so it is free; after the sample the copies use
17 cycles. `GetPixel`'s spin does use the shared helper (`VramWaitSpin`,
`00:05c8`): its sequence after the sample is 14 cycles even with the `ret`.

| Site | Variant | Now | Copy at |
|---|---|---|---|
| `00:266b` | copy (op 0) | `jp $2704` + 16 nop | `00:2704`, 21 B |
| `00:268b` | or (op 1) | `jp $2719` + 10 nop | `00:2719`, 15 B |
| `00:26a5` | xor (op 2) | `jp $2728` + 10 nop | `00:2728`, 15 B |
| `00:26bf` | set (op 3) | `jp $2737` + 10 nop | `00:2737`, 15 B |
| `00:26e7` | `GetPixel` | `f3 cd c8 05 2a 57 fb 2a 5f 06 00 00` | helper `00:05c8` |

Cost: 6 M-cycles per `ApplyPixel` call (`jp`, `di`, `ei`) on a routine of
roughly 40; 12 per `GetPixel`.

Not covered, on purpose: `VramFill` (only used with the LCD off),
`VramCopy` / `BlitTile` (the boot logo), and the tile-mode text path
(`PutBgTile`, `CopyTilesVram`, `ClearBgMap`, `ScrollBgUp`), which has no
callers.

The 12x12 renderer already does the same per access (bare `di`/`ei` in its
fast loops, which it only uses when `wIntNest` is 0, and `DiNest`/`EiNest`
in the general loop), and additionally keeps each critical section to at most
7 cycles after the check; see [font12.md](font12.md).

```sh
cd kernel
python3 tools/inject_bytes.py $V 0 0094 DrawGlyphSafe \
    21bb2f1600fa33d70707075f191946236668fa32d70707075f191979444d626f29292911063219545d6069fa34d74f1a13d5e52135d76e47afcb4528012fb0cb412001a857afcb4d28012fb0cb492001a85fe1f3f041cb4f20fa7a227b22fbd17de60f20cac9 --apply
python3 tools/patch_call.py $V 0 2701 100 00:0094 --jp --apply
python3 tools/inject_bytes.py $V 0 2704 ApplyPixelSafe \
    f3f041cb4f20fa7ea1b0227ea1b3fb7778b7c0c1c9f3f041cb4f20fa7eb0227eb1fb77c9f3f041cb4f20fa7ea8227ea9fb77c9f3f041cb4f20fa7ea0227ea1fb77c9 --apply
python3 tools/patch_call.py $V 0 266b 19 00:2704 --jp --apply
python3 tools/patch_call.py $V 0 268b 13 00:2719 --jp --apply
python3 tools/patch_call.py $V 0 26a5 13 00:2728 --jp --apply
python3 tools/patch_call.py $V 0 26bf 13 00:2737 --jp --apply
python3 tools/inject_bytes.py $V 0 05c8 VramWaitSpin f041cb4f20fac9 --apply
python3 tools/patch_bytes.py $V 0 26e7 f041cb4f20fa2a572a5f0600 f3cdc8052a57fb2a5f060000 --apply
```

The interior `DrawGlyph_*` labels (`00:2730`..`00:2754`) were removed from
`kernel.sym`; they labeled code that is now `nop`s. Applied to
`1.05e-0731`. Bank 0 is identical in 0918 and the function has no WRAM
address that differs in 1.04e, so the port is byte-for-byte in both.

## A second trap: LY reads 0 on the last VBlank line

Code that writes freely "because we are in VBlank" must not decide that
from LY alone. During line 153 the LY register reads 0 after its first few
dots, while STAT still reports mode 1, so a check of the form "mode 1 and
LY < 153" passes with almost no VBlank left and the write lands in line 0's
mode 3. The 12x12 renderer's batch writer had exactly that bug; it now
requires LY in 144..151 (docs/font12.md). Same symptom as the rest of this
note, same watchpoint to catch it.

## Verification

Checked in SameBoy (`--model dmg`): browser, SET tab (boxes, checkboxes,
cursor move), HELP and the browser after cursor moves and a folder entry all
draw as before. Whether the streaks are gone
can only be confirmed statistically, on hardware, over a long session; the
race itself was never caught in the act with a watchpoint, so the mechanism
above is the best-fitting explanation rather than a traced one. A SameBoy
watchpoint on VRAM writes during mode 3 against the stock kernel would settle
it.
