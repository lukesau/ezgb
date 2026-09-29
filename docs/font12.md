# 12x12 browser font (prototype)

Prototype of a larger UI: the file browser's list rows use a 12x12-pixel
cell font instead of the kernel's 8x8 tiles. Only the browser list (and its
long-name marquee) is converted; the tab strip, SET and HELP screens, boxes
and boot messages still use the stock 8x8 text. Built and tested on
`1.05e-0731` only; not ported to 0918 / 1.04e, and the IPS patches and dist
folders have not been regenerated.

## How the kernel draws text, and why on-the-fly composition works

The browser screen is a 20x18 tile canvas at `$8100` (`EnterGfxMode1`,
`00:2652`), one tile per 8x8 cell, tile map filled linearly. Pixel row `py` of
tile column `tx` lives at `GfxRowTable[py] + tx*16` (`00:2fbb`, one word per
pixel row, planes in consecutive bytes). `DrawGlyph` (`00:2701`) is a pure
8x8 blitter: one glyph == one tile, from the 1bpp sheet at `$3206`.

So the canvas is a framebuffer, not a tilemap in the usual sense, and a glyph
at any pixel position is simply a masked merge into the tiles it overlaps.
Nothing has to be precomposed: a 12-wide cell at `x = 12*col` straddles two
tiles (`x & 7` is 0 or 4, so 12 bits plus the shift never exceed 16), a
12-tall cell straddles two or three tile rows, and each glyph row is shifted
into place and read-modify-written so the neighbouring cell's pixels in the
shared tile survive.

## Geometry

| | stock | this prototype |
|---|---|---|
| cell | 8x8 | 12x12 |
| columns | 20 | 13 (156 px; the 4 px right slack is painted in paper) |
| list rows | 16 (tile rows 2..17) | 10, at `y = 16 + 12*i` under the 16 px tab strip |
| name field | icon + 19 chars | icon + 12 chars (longer names use the stock marquee) |
| cap height | 7 px | 10 px (Menlo Bold 13 px, baseline on cell row 9, 1 row of leading, 2 rows of descender) |

## Pieces

| What | Where |
|---|---|
| glyph sheet, hand-editable ASCII art | `decomp/font12/font12.txt` (`#` ink, `.` paper; `keep` on a header protects it from the renderer) |
| renderer (TTF -> sheet) | `scripts/font12-render.py` (needs Pillow; defaults Menlo Bold 13, baseline 9) |
| packer (sheet -> 2424-byte table) | `scripts/font12-pack.py` -> `decomp/font12/font12.bin` |
| table in ROM | `Font12` at `02:6000`, placed by `scripts/inject-font12.sh` |
| renderer code | `decomp/src/draw12.c` -> `DrawString12` at `02:5800` |
| bank-0 far-call stub | `FarCallDrawString12` at `00:05c0` (`cd 8d 07 00 58 02 00 c9`) |
| byte-level immediates | `decomp/tools/patch_bytes.py` (new; verifies the old bytes first) |

Table layout: 101 glyphs (codes `$20`-`$7F`, then the five icons `$C0`-`$C4`
in the same codes the 8x8 icons use), 24 bytes each: 12 big-endian words,
leftmost pixel in bit 15, low nibble zero.

### `DrawString12(s, len, col, row)`

Same argument order as `DrawString`, so the stub can replace it by re-pinning.
`row` is still a tile row: rows >= 2 map to `y = 16 + 12*(row-2)`, so the
stock painters' `sel + 2` arithmetic is untouched. `len` is capped at the cells
left on the row, a NUL pads with spaces like `DrawString`, and a string that
reaches cell 13 also paints the 4 px slack. Ink and paper come from the draw
state (`$d734` / `$d735`) so the selection bar inverts as before.

The stub is reached by a `call`, so the trampoline's three words sit between
the stub's own return address and the arguments: the first argument is at
**sp+8**, hence three pad parameters (an inline `call FarCallTrampoline` stub,
the case in `docs/browser-hide-filter.md`, needs two).

### Blitter

Cells are drawn in aligned pairs where possible: cells 2k and 2k+1 start at
x = 24k and cover tiles 3k..3k+2 exactly, so the pair is three columns of
pure writes with no reads or masks. Tile 3k is the first cell's high byte,
tile 3k+2 the low byte of the second cell taken from a second copy of the
font with every row pre-shifted right by 4 (`FONT12_SH4`, emitted by the
packer after the plain table), and the shared middle tile is
`(first.lo & $F0) | shifted.hi`, composed into a 12-byte buffer once
(`compose_mid`). An odd starting column draws its first cell alone, and cell
12 is drawn as a pair with the blank glyph so the 4 px slack comes out in
paper. `DrawNameWithIcon` now sends icon + name as one 13-cell string so the
whole browser row is pairs. Single cells (`blit_fast0/4`) and other
ink/paper pairs (`blit_rows`) keep the older masked read-modify-write loops.

Each column is written in batches of four tile rows (`blit_col1/2`). A STAT
spin before every write caps the rate at one or two writes per scanline,
because the rest of the line is mode 2/3; a batch instead syncs to a fresh
HBlank (wait for mode 3, then for mode 0) and writes four rows inside the
51 + 20 cycles that are then guaranteed, or writes at once during VBlank
when LY reads 144..151. That LY range matters: on the last VBlank line the
register already reads 0 (the line-153 alias), and a first version that
only asked for LY < 153 started batches there with almost no VBlank left,
so they ran into line 0's mode 3 and lost writes, one plane of one tile
row at a time. On a real CGB that showed as thin streaks in the last cell
of rows the cursor had left (their old content was black, so a dropped
write stayed visible); SameBoy's CGB model reproduced it and
`watch $8000 to $9800 if ([$ff41] & 3) == 3` put every hit at LY 0.
Interrupts are off from the sync to the last write (under two scanlines of
added latency), except near the end of the frame: a sync from LY >= 143
waited for the next mode 3 on the far side of VBlank with interrupts off, so
the VBlank callback that points the BG tile data back at `$8000` (the canvas
uses `$8800` below LYC 72) ran late and the tab strip drew from the wrong
tiles for a frame: a flicker in the top rows while the list redrew (mod
4.5-4.7). Such a batch now enables interrupts, waits for LY 145..150 or the
next frame, and starts over. `watch/w $ff40 if [$ff44] < $0a` (the callback's
LCDC write landing in the top lines) counted 15 late switches over 60 cursor
moves before, 0 after, the same as 8px mode. See [vram-write-race.md](vram-write-race.md) for why the
post-sample budget is only 20 cycles when writing one row at a time.

Measured in SameBoy with the debugger's `ticks` (M-cycles per far call into
`DrawString12`, a 13-cell icon + name row):

| build | cycles per row |
|---|---|
| single cells, masked RMW | ~28,000 (estimated) |
| aligned pairs, spin per write | ~22,100 |
| aligned pairs, HBlank batches | ~16,300 |
| stock 8x8 `DrawString`, 20 glyphs (~1,026 per glyph) | ~20,500 |

So a 12px row now costs less than a stock row. The remainder is roughly
half HBlank floor (240 tile rows at four per line) and half C overhead per
pair; a full-asm pair loop would take another few thousand off.

### The marquee and the input loop

`DrawDirEntryLabel` already redraws only when the visible offset changes:
offset = (tick - 20) >> shift, and the shift immediate at `00:0cba` went from
1 to 2, so a long name steps every 4 ticks instead of 2. What a "tick" is
matters more: the browser loop (`FileBrowserEntry_inputLoop`) is
`Delay($2d)`, one `ReadJoypad` poll, dispatch, then `WaitVBlankFlag`, and
`ReadJoypad` is a plain read of P1 with no interrupt and no latch. The loop
period, measured with a breakpoint on the loop head, is 3.0 frames in both
builds on a row that does not scroll. On a scrolling row the stock build
alternates 6.5 / 3.5 frames (it redraws every second tick, and a 19-glyph
redraw is ~1.1 frames), mean 5.0; this build runs 4, 4, 6.3, 3.7, mean 4.5
(the marquee bookkeeping pushes an idle tick over the next VBlank, the
redraw every fourth tick costs ~0.9 frame). A press shorter than the period
can fall between two polls and is lost; a longer one is seen with up to one
period of lag. That, not rendering time, is what the key-injection test
showed: 60 ms taps at 180 ms spacing happen to phase well with the stock
pattern and less well with this one.

## Patches (1.05e-0731)

| Site | Change |
|---|---|
| `DrawNameWithIcon` `00:3ec8` | the old 293-byte bank-0 block is gone; the address holds an 8-byte far stub to `DrawNameWithIconImpl` (`02:7300`), which calls `DrawString12` with a near call |
| `DrawDirEntryLabel` marquee `00:0dd8` | `call DrawString` -> `call FarCallDrawString12` |
| marquee field widths `00:0c87`, `00:0c8e` | `$13` -> `$0c` |
| `DrawBrowserEntries` row clamp `01:411c`, `01:4128` | `$10` -> `$0a` |
| page step / bound `00:113f`, `00:1186`, `00:11cb` | `$10` -> `$0a` |
| `FarCallDrawDetailBottom` `00:03e1` | bottom row `$0f` -> `$09` |
| `browser_scroll.c` `ROWS`, `browser_page_end.c`, `browser_scroll_repaint.c` | 16 -> 10 rows (14 -> 8 in the repaint loop); re-injected in place |
| marquee shift `00:0cba` | `$01` -> `$02` (step every 4 ticks) |

Note: the two `call DrawString` sites at `00:0e1c` / `00:0e32` are in
`SdMenuMain` (boot messages), not the marquee, although they sit between
`DrawDirEntryLabel` and `GotoFileBrowser`. They were retargeted by mistake at
first and put back.

Rebuild from `decomp/`:

```sh
V=1.05e-0731
python3 tools/inject.py src/draw12.c $V 2 5800 DrawString12 \
    --pin wDrawColor=d734 --pin wDrawColorB=d735 --pin wIntNest=d6d0 \
    --pin GfxRowTable=2fbb --pin Font12=6000 --pin DiNest=06fd --pin EiNest=0706 --replace --apply
python3 tools/inject.py src/browser_icons.c $V 2 7300 DrawNameWithIconImpl --pin DrawString12=5800 --replace --apply
python3 tools/inject_bytes.py $V 0 3ec8 DrawNameWithIcon cd8d0700730200c9 --apply   # once
../scripts/inject-font12.sh $V
```

All kernel references in `draw12.c` are `--pin`'d externs (no raw addresses),
and the three blocks are registered in `scripts/port-mod.py`'s `REGISTRY`
(`draw12.c`, `browser_icons.c`, and `Font12` as verbatim data), so
`scripts/rebuild-blocks.py` checks them and `port-mod.py` carries them to the
other kernels with the WRAM pins translated.

## Next

- Input: done, see [joypad-latch.md](joypad-latch.md): a VBlank sampler
  latches presses so nothing shorter than the loop period is lost.
- Tearing: the marquee and cursor repaints are visible mid-draw in a 1/60 s
  screenshot (a cell half old, half new). Faster drawing shrinks the window;
  drawing a row into a buffer and copying it in VBlank would remove it.
- The rest of the UI (tab strip, SET, HELP, boxes) is still 8x8; at 12 px
  cells the screen is 13x12 and SET / HELP need a re-layout, not a scale.
- The 12px browser is now opt-in through the `UI:` row on the SET tab
  ([ui-mode.md](ui-mode.md)); the patch table below describes the 12px
  side, and each of those sites now branches on the mode. Ported to 0918;
  1.04e, the IPS patches and the disassembly regeneration are still to do.
