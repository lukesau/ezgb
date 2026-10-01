# 12px browser font

A larger UI for the file browser: its list rows use a proportional 12px-tall
font instead of the kernel's 8x8 tiles. Each glyph has its own width and
neighbouring glyphs kern, the way text is set on modern systems, so a row
holds about 18 characters of a typical name next to the icon (15 of the
widest). Only the browser list (and its long-name marquee) is converted;
the tab strip ([tab-strip12.md](tab-strip12.md)) and the START overlay
([last-rom.md](last-rom.md)) the HELP pane and the SET pane ([set-pane12.md](set-pane12.md)) use the
same font, as do the Reading / Loading / Error boxes; only the boot
messages and `BATTERY DRY!!!` still use the stock 8x8 text. Opt-in through the `UI:` row of the SET tab
([ui-mode.md](ui-mode.md)).

## How the kernel draws text, and why on-the-fly composition works

The browser screen is a 20x18 tile canvas at `$8100` (`EnterGfxMode1`,
`00:2652`), one tile per 8x8 cell, tile map filled linearly. Pixel row `py` of
tile column `tx` lives at `GfxRowTable[py] + tx*16` (`00:2fbb`, one word per
pixel row, planes in consecutive bytes). `DrawGlyph` (`00:2701`) is a pure
8x8 blitter: one glyph == one tile, from the 1bpp sheet at `$3206`.

So the canvas is a framebuffer, not a tilemap in the usual sense, and a glyph
at any pixel position is simply a masked merge into the tiles it overlaps.
Nothing has to be precomposed: a glyph at any `x` straddles two tiles (its
ink is at most 9 px wide, so 9 bits plus a shift of up to 7 fit a 16-bit
row), a 12-tall glyph straddles two or three tile rows, and each glyph row
is shifted into place and merged so the neighbouring pixels in the shared
tile survive.

## Geometry

| | stock | 12px browser |
|---|---|---|
| glyph | 8x8 cell | proportional: ink width (1..8 px) + 2 px gap, 12 px tall; kerned pairs overlap by up to 2 px |
| row | 20 columns | icon (12 px advance) + a 148 px name field |
| list rows | 16 (tile rows 2..17) | 10, at `y = 20 + 12*i` under the 12px tab strip |
| name field | icon + 19 chars | icon + whatever fits: 15 (`WWWWW…`) to 37 (`.....`) characters, about 18 of a typical name (longer names use the stock marquee) |
| cap height | 7 px | 10 px (Menlo Bold 13 px, baseline on row 9, 1 row of leading, 2 rows of descender) |

History: the first version used 12x12 cells (13 columns, icon + 12 chars).
The ink of nearly every glyph is 7 px wide, so 5 px of each cell was
padding; 10x12 cells (16 columns, icon + 15 chars) fit three more
characters. The proportional layout then dropped the cells altogether: the
blank columns that made `i`, `l` and `.` look spaced out are gone, and
`Pokemon Crystal.gbc` (19 characters, 142 px) fits a row without scrolling.

## Pieces

| What | Where |
|---|---|
| glyph sheet, hand-editable ASCII art | `decomp/font12/font12.txt` (`#` ink, `.` paper, 10 columns x 12 rows; `keep` on a header protects it from the renderer) |
| renderer (TTF -> sheet) | `scripts/font12-render.py` (needs Pillow; defaults Menlo Bold 13, baseline 9) |
| packer (sheet -> bitmaps + metrics) | `scripts/font12-pack.py` -> `decomp/font12/font12.bin` (2424 bytes) and `font12-metrics.bin` (~1.7 KB; `--gap`, `--kmax`, `--space`, `--icon-adv` tune the spacing) |
| tables in ROM | `Font12` at `02:6000` and `Font12Metrics` at `02:6978`, placed by `scripts/inject-font12.sh` (which refuses a metrics table reaching `02:7100`: `inject_bytes.py` does not notice a block running into the next label) |
| layout | `decomp/src/layout12.c` -> `Fit12` at `02:7100` |
| renderer code | `decomp/src/draw12.c` -> `DrawString12` at `02:7500` |
| bank-0 far-call stub | `FarCallDrawString12` at `00:05c0` (`cd 8d 07 00 75 02 00 c9`) |
| marquee fit check | `MarqueeWidth12` cave at `00:0229`, reached from the `MarqueeWidth` cave of [ui-mode.md](ui-mode.md) |
| byte-level immediates | `decomp/tools/patch_bytes.py` (verifies the old bytes first) |

Bitmap table: 101 glyphs (codes `$20`-`$7F`, then the five icons `$C0`-`$C4`
in the same codes the 8x8 icons use), 24 bytes each: 12 big-endian words,
leftmost ink pixel in bit 15. Text glyphs are left-trimmed by the packer
(the sheet's blank columns left of the ink are dropped), so a glyph has no
side bearings: the pen sits on its first ink column. Icons keep their 10
columns.

Metrics table (`Font12Metrics`, offsets from its start): `adv[101]`
(advance), `w[101]` (ink width), `lcol[101]` (left kerning class),
`rrow[101]` (u16, byte offset of the right kerning class row), then the
class matrix: one row per right class, 2 bits per left class. The layout
is fixed by `scripts/font12-pack.py`'s docstring and mirrored by the
`M_*` defines in `layout12.c`.

### `DrawString12(s, len, col, row)`

Same argument order as `DrawString`, so the stub can replace it by re-pinning.
`row` is still a tile row: rows >= 2 map to `y = 20 + 12*(row-2)`, so the
stock painters' `sel + 2` arithmetic is untouched. A `row` of 18 or more
is a pixel y instead (rounded down to a multiple of 4, so the 4-row flush
batches stay inside a tile); the START overlay uses it to space its rows
([last-rom.md](last-rom.md)). `col` is 0 for the icon
cell (pen at x = 0), 1 for the name field (pen at x = 12, an icon's
advance), and 2 or more for a pixel x (the tab strip's labels); the row is always painted to x = 160, paper after the last glyph.
`len` caps the characters (0: up to the NUL). Ink and paper come from the
draw state (`$d734` / `$d735`) so the selection bar inverts as before.
`DrawNameWithIconImpl` hands it the icon code followed by up to 39
characters of the name in one string; how many are drawn is up to the
layout.

### Proportional layout and kerning (`Fit12`)

`Fit12(s, len, col, xs)` in `layout12.c` runs a pen over the string: for
each character it looks up the glyph's kern against the previous glyph and
moves the pen back by it, stops at the first glyph whose ink would cross the
row's right edge (`x + w > 160`), records the pen x in `xs[]` and adds the
glyph's advance. It returns the number of glyphs placed (at most 40).
`DrawString12` composes exactly those glyphs at exactly those positions,
and the marquee cave calls the same function on the raw name to learn
whether the whole name fits (below).

Advances and kerning come from the glyph shapes, at pack time (the digits
are the exception, below):

- advance = ink width + 2 px (the gap between two straight stems, `nn`);
  the space advances 5 px, an icon 12 px;
- kerning is optical: for a pair, the packer measures, row by row, the gap
  between the first glyph's rightmost ink and the second's leftmost ink at
  the nominal advance, and pulls the second glyph left until the smallest
  per-row gap is 2 px, by at most 2 px. `To`, `Ta`, `AV`, `r.` and `f.`
  kern by 2, `Wa` by 1, `rn` by 0. The cap is what stops `'.` from
  stacking, since the two share no ink rows.
- the pairs are stored as class kerning, as OpenType does it: glyphs with
  the same kerning behaviour on a side share a class (68 right classes, 65
  left with the current sheet), and the matrix is 2 bits per class pair,
  ~1.2 KB instead of 96 x 96 bytes. A lookup is one indexed byte and a
  shift. Space and icons are class 0 on both sides and never kern.

The ten digits are tabular figures: each is drawn in the same 7 px cell of
the sheet (columns 1..7), is not trimmed to its ink (`1` keeps its side
bearings), advances 9 px and never kerns on either side. Numbers therefore
line up in columns (the dates and times of the boot prompts) and a changing
number (the entry counter in the tab strip) does not shift its neighbours.
The shapes are hand-drawn (`keep`), squared off with 2 px strokes, and the
zero is plain, narrower than `O`.

Everything about the spacing is a packer option (`--gap`, `--kmax`,
`--space`, `--icon-adv`); rerun `scripts/inject-font12.sh` after changing
one, or after editing the sheet, since a new shape can add a class and grow
the matrix.

### The marquee's fit check

The stock marquee (`DrawDirEntryLabel`) scrolls a name when
`namelen > width`, with `width` the field width in characters, and draws
the window with `DrawString(buf, width, 1, y)`. With a proportional font
"fits" is a pixel question, so the `MarqueeWidth` cave, in 12px mode, jumps
to `MarqueeWidth12` (`00:0229`): it recovers the name pointer from the
caller's frame (`[$c2a0] + [sp+$08]`, the same sum the stock code forms
twice), far-calls `Fit12(name, 0, 1, $c4a4)` through an inline
`FarCallTrampoline` (the marquee buffer is free scratch at that point), and
stores `$FF` into the width slot when the count reaches `namelen`, else 0.
`$FF - namelen` never borrows, so the name is left alone; `0 - namelen`
always does, so the stock scroll runs unchanged and its draw call arrives
with `len = 0`, which `DrawString12` takes as "as many as fit". The scroll
still steps one character per tick, so a step is 4 to 10 px depending on
the character leaving the field (a pixel-precise marquee would need the
stock routine's copy-from-offset replaced by a pixel offset).

The stub is reached by a `call`, so the trampoline's three words sit between
the stub's own return address and the arguments: the first argument is at
**sp+8**, hence three pad parameters (an inline `call FarCallTrampoline` stub,
the case in `docs/browser-hide-filter.md`, needs two).

### Blitter

The whole row is composed in a WRAM row buffer first: one 12-byte column
per tile from the field's first tile to the row's end, 252 bytes on the
stack (one spare column, since a glyph ending in the last tile still ORs
its zero low byte one column further). Each glyph row is a 16-bit word
shifted right by the glyph's `x & 7` (one unrolled routine per shift,
`cell_or0..7`, eight expansions of one assembler macro) and OR'd into the
tile the glyph starts in and the next one, so no tile is ever read back
for pixels the string owns, and kerned glyphs simply overlap in the buffer.
A tile the string only partly covers (the marquee starts at x = 12, 4 px
into tile 1, next to the icon) is read from VRAM first (`vram_rd_col`, one
STAT-checked read per row) and masked to the pixels the string does not
own, pre-inverted for a highlighted row so the flush's xor puts them back;
that read happens before the glyphs are composed, since it overwrites the
column (a version that read afterwards wiped the left half of the marquee's
first glyph). The fast path (the browser's ink 3 on paper 0 or the inverse,
where both bit planes hold the same byte) then flushes the buffer one tile
column at a time with `blit_col1`: pure writes, four tile rows per batch.
Any other ink/paper pair, or a caller inside a DiNest section, flushes the
same buffer with `flush_rmw`: per row, both plane bytes are formed from the
buffer bit and masked-merged into VRAM by `vram_rmw2` inside a DiNest ..
EiNest window.

The previous 12x12 version drew cells in aligned pairs (two cells = three
whole tiles) from a second, pre-shifted copy of the font; 10 px cells drift
across tile boundaries in four phases, so that trick no longer applies and
the row buffer replaced it.

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
`DrawString12`, a 13-cell icon + name row, 12x12 version):

| build | cycles per row |
|---|---|
| single cells, masked RMW | ~28,000 (estimated) |
| aligned pairs, spin per write | ~22,100 |
| aligned pairs, HBlank batches | ~16,300 |
| stock 8x8 `DrawString`, 20 glyphs (~1,026 per glyph) | ~20,500 |

The 10 px row-buffer version has not been re-measured. Its flush is the same
60 batches (20 tile columns, three batches each), and the compose step is
about 40-60 cycles per glyph row (16 cells x 12 rows), so it should land
near the pair version.

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
| `DrawNameWithIcon` `00:3ec8` | the old 293-byte bank-0 block is gone; the address holds an 8-byte far stub to `DrawNameWithIconImpl` (`02:7e80`), which sends icon + up to 39 name characters to `DrawString12` with a near call |
| `DrawDirEntryLabel` marquee `00:0dd8` | `call DrawString` -> `call FarCallDrawString12` |
| marquee field widths `00:0c87`, `00:0c8e` | `$13` -> the `MarqueeWidth` cave of [ui-mode.md](ui-mode.md): 19 in 8px mode, else `MarqueeWidth12` (`00:0229`) measures the name with `Fit12` and stores `$FF` (fits) or 0 (scroll) |
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
python3 tools/inject.py src/layout12.c $V 2 7100 Fit12 --pin Font12Metrics=6978 --pin hClip12=fff9 --replace --apply
python3 tools/inject.py src/draw12.c $V 2 7500 DrawString12 \
    --pin wDrawColor=d734 --pin wDrawColorB=d735 --pin wIntNest=d6d0 \
    --pin GfxRowTable=2fbb --pin Font12=6000 --pin Font12Metrics=6978 --pin Fit12=7100 \
    --pin DiNest=06fd --pin EiNest=0706 --pin hClip12=fff9 --replace --apply
python3 tools/inject.py src/browser_icons.c $V 2 7e80 DrawNameWithIconImpl \
    --pin DrawString12=7500 --pin DrawString=08b7 --pin hUiMode=fffb --replace --apply
python3 tools/inject_bytes.py $V 0 3ec8 DrawNameWithIcon cd8d07807e0200c9 --apply   # once
python3 tools/inject_bytes.py $V 0 0229 MarqueeWidth12 \
    f80a2a666ffaa0c25ffaa1c2571911a4c4d53e01f533aff533e5cd8d0700710200e8067bf810be3eff3001aff81177c9 --apply   # once
python3 tools/patch_bytes.py $V 0 020c f0fbb73e1328023e0ff81177c9 f0fbb720183e13f81177c90000 --apply   # MarqueeWidth: jr nz -> MarqueeWidth12
../scripts/inject-font12.sh $V
```

All kernel references in the C files are `--pin`'d externs (no raw
addresses), and the blocks are registered in `scripts/port-mod.py`'s
`REGISTRY` (`draw12.c`, `layout12.c`, `browser_icons.c`, and `Font12` /
`Font12Metrics` as verbatim data), so `scripts/rebuild-blocks.py` checks
them and `port-mod.py` carries them to the other kernels with the WRAM pins
translated. `MarqueeWidth12` is a hand-assembled block, relocated like the
other caves.

## Next

- Input: done, see [joypad-latch.md](joypad-latch.md): a VBlank sampler
  latches presses so nothing shorter than the loop period is lost.
- Tearing: the marquee and cursor repaints are visible mid-draw in a 1/60 s
  screenshot (a cell half old, half new). Faster drawing shrinks the window;
  drawing a row into a buffer and copying it in VBlank would remove it.
- The rest of the UI (tab strip, SET, HELP, boxes) is still 8x8; SET / HELP
  would need a re-layout for the 12px font, not a scale.
- The 12px browser is opt-in through the `UI:` row on the SET tab
  ([ui-mode.md](ui-mode.md)); the patch table above describes the 12px
  side, and each of those sites branches on the mode.
- The marquee steps by characters, so its pixel steps are uneven with the
  proportional font. A pixel-precise scroll would replace the stock
  copy-from-character-offset with a pixel offset handed to the layout.
- The layout costs about 100 cycles per glyph on top of composition (a
  class lookup per pair); the row cost has not been re-measured.
