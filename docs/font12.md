# The 12px font

A proportional, kerned 12px font for the browser, the tab strip, the SET
and HELP panes, the START overlay, the prompts and the status boxes. Only
the boot messages and the battery dry box keep the stock 8x8 text. The SET
tab's `FONT` button chooses it. Addresses are 1.05e-0731's.

## UI modes

`FONT` steps `8px`, `12px` and `SLIM`, saved as `UI=8`, `UI=12` or
`UI=SLIM` ([ezgb-cfg.md](ezgb-cfg.md)). With no key the browser is 8px.

| State | Holds |
|---|---|
| `hUiMode`, HRAM `$fffb` | 0 for 8px, 1 for 12px. HRAM is cleared at boot, which makes 8px the default before the file is read |
| `FONT_SLIM`, WRAM `$DC0C` | set with `UI=SLIM`: the 12px layout with glyph set 1's letters |

| | 8px | 12px |
|---|---|---|
| list rows on screen | 16 | 10 |
| name field | icon + 19 characters | icon + what fits in 148 px, about 18 |
| page step, LEFT and RIGHT | 16 | 10 |
| marquee step | every 2 ticks | every 4 ticks |

The stock browser has the row count as immediates. Each such site calls a
small bank-0 routine that reads `hUiMode` instead:

| Routine | Returns |
|---|---|
| `UiRows` `00:01e3` | A = 16 or 10 |
| `UiRowsHL` `00:01ec` | HL = rows, for the page step and bound |
| `UiRowsMinus1BC` `00:01f3` | BC = rows - 1 |
| `ClampBrowserRows` `00:01fb` | `DrawBrowserEntries`' row clamp |
| `MarqueeWidth` `00:020c` | the marquee's field width: 19 in 8px, measured in 12px (below) |
| `MarqueeDraw` `00:0219` | jumps to `DrawString` or `FarCallDrawString12` |
| `MarqueeShift` `00:0222` | the marquee's tick shift, 1 or 2 |

The DV theme decides the font itself: it is always 12px with its own glyph
set ([themes.md](themes.md#dv)).

## Why drawing at any pixel works

The browser screen is a 20x18 tile canvas at `$8100` with the tile map
filled linearly, so it is a framebuffer: pixel row `py` of tile column `tx`
is at `GfxRowTable[py] + tx*16` (`00:2fbb`). Stock `DrawGlyph` only ever
draws one 8x8 glyph into one tile, but a glyph at any pixel position is
just a masked merge into the tiles it overlaps. A 12px glyph straddles two
tiles across and two or three down.

In 12px mode the tab strip is the 12px row at y 0 to 11 with a 1 px rule
at y 12, and the ten list rows are at `y = 20 + 12*i`.

## Pieces

| What | Where |
|---|---|
| glyph sheets, ASCII art you can edit by hand | `kernel/mod/font12/font12.txt` and `font12_dv.txt`: `#` ink, `.` paper, 10 columns by 12 rows. `keep` on a glyph's header protects it from the renderer |
| TTF to sheet | `scripts/font12-render.py` (needs Pillow; defaults to Menlo Bold 13, baseline on row 9) |
| sheet to bitmaps and metrics | `scripts/font12-pack.py`; `--gap`, `--kmax`, `--space` and `--icon-adv` tune the spacing, `--mono N` packs a fixed-width set |
| placing the tables | `scripts/inject-font12.sh <version> <set>` |
| tables in ROM | set 0: `Font12` `0A:4C00`, `Font12Metrics` `0A:5580`. Set 1: `Font12Dv` `0A:5D00`, `Font12DvMetrics` `0A:6680` |
| layout | [layout12.c](../kernel/mod/src/layout12.c), `Fit12Impl` `0A:4A00` |
| renderer | [draw12.c](../kernel/mod/src/draw12.c), `DrawString12Impl` `0A:4000` |
| entry points | `DrawString12` `02:7500` and `Fit12` `02:7100`: stubs that copy the string to the stack and far-call bank 10. `FarCallDrawString12` `00:05c0` reaches the first from bank 0 |

The engine is in bank 10 beside the glyph tables, because code in one
switchable bank cannot read data in another. Callers in other banks pass
strings that live in their own bank's ROM, which is why the stubs copy the
string to the stack first.

Run `inject-font12.sh` again after editing a sheet or a spacing option: a
new shape can add a kerning class and grow the metrics table.

## The tables

A set is 101 glyphs: codes `$20` to `$7F` (`$7F` is the star) and the five
icons `$C0` to `$C4`.

**Bitmaps**, 24 bytes a glyph: 12 big-endian words, leftmost ink pixel in
bit 15. Text glyphs are trimmed on the left by the packer, so a glyph has
no side bearing and the pen sits on its first ink column. Icons keep their
10 columns.

**Metrics**, in this order: `adv[101]` (advance), `w[101]` (ink width),
`lcol[101]` (left kerning class), `rrow[101]` (u16, the offset of the right
class's row), then the class matrix, one row per right class with 2 bits
per left class. The layout is set by `font12-pack.py`'s docstring and
mirrored by the `M_*` defines in `layout12.c`. A set's metrics sit `$980`
past its bitmaps.

## `DrawString12(s, len, col, row)`

The argument order is `DrawString`'s, so a call site can be repointed.

- `row` is a tile row: rows 2 and up map to `y = 20 + 12*(row-2)`, so the
  stock painters' arithmetic is untouched. A `row` of 18 or more is a pixel
  y, rounded down to a multiple of 4.
- `col` is 0 for the icon cell (pen at x 0), 1 for the name field (pen at
  x 12), and 2 or more for a pixel x.
- `len` caps the characters; 0 means up to the NUL.
- Ink and paper come from the draw state (`$d734`, `$d735`), so the
  selection bar inverts as it does in 8px.
- The row is painted from its start to x 160, paper after the last glyph.
  `hClip12` cuts it short for a caller that needs the rest of the row left
  alone.

## Layout and kerning: `Fit12(s, len, col, xs)`

`Fit12` runs a pen over the string. For each character it moves the pen
back by the glyph's kern against the previous glyph, stops at the first
glyph whose ink would cross x 160, records the pen in `xs[]` and adds the
advance. It returns the number of glyphs placed, at most 40. `DrawString12`
draws exactly those glyphs at those positions.

Advances and kerning are worked out from the glyph shapes when the sheet is
packed:

- The advance is the ink width plus 2 px. A space advances 5 px and an
  icon 12 px.
- Kerning is optical. For a pair the packer measures, row by row, the gap
  between the first glyph's rightmost ink and the second's leftmost, and
  pulls the second glyph left until the smallest gap is 2 px, by at most
  2 px. `To`, `Ta`, `AV`, `r.` and `f.` kern by 2, `Wa` by 1.
- Pairs are stored as class kerning, as OpenType does it: glyphs that kern
  alike on a side share a class, and the matrix is 2 bits per class pair,
  about 1.2 KB where a full table would be 9 KB. Spaces and icons never
  kern.
- The ten digits are tabular: each occupies the same 7 px cell, advances
  9 px and never kerns, so numbers line up in columns and a changing number
  does not shift its neighbors.

### Whether a name fits

The stock marquee scrolls a name when it has more characters than the
field. With a proportional font that is a pixel question, so in 12px mode
`MarqueeWidth` jumps to `MarqueeWidth12` (`00:0229`), which calls `Fit12`
on the name and stores `$FF` in the stock width slot when every glyph fits
and 0 when not. `$FF` never triggers the stock scroll and 0 always does,
and the scroll's draw then arrives with `len = 0`, which `DrawString12`
takes as "as many as fit". The scroll still steps one character a tick.

## The blitter

The whole row is composed in a row buffer on the stack first, one 12-byte
column per tile. Each glyph row is a 16-bit word shifted right by the
glyph's `x & 7` and ORed into the tile it starts in and the next, so kerned
glyphs simply overlap in the buffer and no tile is read back for pixels the
string owns.

A tile the string only partly covers is read from VRAM before the glyphs
are composed and masked to the pixels the string does not own.

The buffer is then flushed one of two ways:

- **The fast path**, for ink 3 on paper 0 or the reverse, outside a
  critical section: both bit planes hold the same byte, so it writes whole
  tile columns in batches of four tile rows, each batch synced to an
  HBlank.
- **The general path**, for any other colors or a caller with interrupts
  nested off: both plane bytes are formed per row and merged into VRAM.
  Edge tiles always take this path, so an accent color beside a label
  survives.

Both follow the rules in [drawing-timing.md](drawing-timing.md).

## Glyph sets

| Set | Sheet | Text | Icons |
|---|---|---|---|
| 0 | `font12.txt` | proportional, Menlo Bold 13 rendered and tuned by hand, capitals 9 px | ours |
| 1 | `font12_dv.txt` | Tamzen 6x12 (Suraj N. Kurapati, after Tamsyn by Scott Fial; [license](../kernel/mod/font12/LICENSE-Tamzen)), fixed 6 px, capitals 7 px | davidesqalv's, from [ezgb-dv](https://github.com/davidesqalv/ezgb-dv) |

The renderer and the layout use set 1 in the DV theme and with `SLIM`
(`GLYPHS_DV` in [vars.h](../kernel/mod/src/vars.h)), set 0 otherwise. `SLIM`
changes only the letters: outside DV the star and the icons still come from
set 0 (`STOCK_ICONS`). Set 1's letters are the 8px font's size in a 12 px
line, so a row holds about 26 characters to set 0's 18.

A set is about 3 to 4 KB. Adding one means a sheet, a set number in
`inject-font12.sh`, and the set's choice in `draw12.c` and `layout12.c`.

## The tab strip

In 12px mode `TabStrip12`
([tabstrip12.c](../kernel/mod/src/tabstrip12.c), `02:7600`, reached through
`TabStripHook` `08:7b20`) draws ` SD `, ` SET ` and ` HELP ` from the pen
positions `Fit12` reports for the whole strip text, the selected one in
paper on ink, then the rule. Its argument mirrors the stock drawer's cases:

| `tab` | Does |
|---|---|
| 0 | clears y 0 to 19 and draws the strip. In the SET tab's pick mode it draws ` PICK A ROM ` instead of the labels |
| 1, 2 | clears the whole canvas and draws the strip |
| 3 | clears the content below the rule and leaves the strip |

The entry number at the right end is drawn by the browser
([browser.md](browser.md#moving-around)). The HELP pane's 12px layout is
`Help12` (`08:7d00`), reached through `HelpHook` (`08:7b40`), and the SET
pane's is in [set-pane12.md](set-pane12.md).
