# Text viewer

A on a `.txt`, `.ini` or `.md` file in the browser opens it read-only. The
three types share the page icon ([browser.md](browser.md)).

| Button | Does |
|---|---|
| UP / DOWN | one line, repeating when held |
| LEFT / RIGHT | one page back / on (A also pages on) |
| B | back to the browser, cursor where it was |

The text takes the list area under the tab strip and looks the same in the
8px and 12px UI: 12 rows of 26 characters in the slim font (Tamzen 6x12, the
DV glyph set), rows 10 px apart. Lines wrap at the last space that fits, or
mid-word when a word is longer than a row.

## Limits

- The first 65,024 bytes and the first 3,072 rows of a file; it stops
  scrolling there.
- ASCII only. CR is dropped, TAB is one space, other control codes and `$7F`
  show as `?`, and a UTF-8 sequence shows as one `?`.
- A one-line scroll repaints all twelve rows, about 0.3 s in SameBoy, so a
  held UP or DOWN moves about three lines a second. Paging costs the same
  repaint and is the quick way through a long file.

## How it works

[kernel/mod/src/textview.c](../kernel/mod/src/textview.c), bank 14 at `0E:4000`.
`RomMenu` ([rom-menu.md](rom-menu.md)) offers every file that is not a ROM to
`TextViewFar` (`04:59a8`, an 8-byte far stub); the viewer checks the
extension and returns 0 for anything else, which then takes the stock open
path as before.

**Font.** The 12px renderer ([font12.md](font12.md)) places rows on 4 px
steps and paints 12 pixel rows each, so it cannot set rows 10 px apart. The
viewer has its own table, `tv_font` in `kernel/mod/src/textview_font.h`, written
by `scripts/textview-font.py` from `kernel/mod/font12/font12_dv.txt`: codes
`$20`-`$7E`, ten bytes each, rows 1-10 of the 6x12 cell. Row 11 is empty in
every glyph; row 0 holds one pixel row of `$`, `{` and `}`, which is lost.

**Drawing.** A row is composed in a stack buffer, one 10-byte column per
tile (`glyph_or`: character `i` is at x = 2 + 6i, so its shift in a tile is
2, 0, 6 or 4). `blit_col` copies a column to the tile canvas, ink 3 on paper
0, with `blit_col1`'s sync from `draw12.c`: a batch is written at once during
VBlank, and on a visible line with interrupts off from before mode 3 until
the batch is written. A batch is two pixel rows: three can reach 70 cycles when
a tile boundary falls in the batch, which is too long
([drawing-timing.md](drawing-timing.md)). Interrupts are never held off over
the start of VBlank or of line 72, whose handlers switch the BG tile
addressing. Only the tile columns a row, or the row it
replaces, has ink in are written.

**File.** Nothing but one sector is held: `have(pos)` reads the 512-byte
sector of a position into the loader's scratch (`$C0A0`) through the kernel
FIL (`$CA0F`), both idle in the browser. `next_line` lays a row out straight
from that buffer. The twelve rows on screen are kept as text, so one line
down reads only the new bottom row. To go back, the file position of every
32nd row is recorded as the text is passed (96 entries), and the wanted row
is found by laying out forward from the nearest one.

WRAM, all inside `$D780`-`$D9FF`, scratch that ezcfg and SaveOp use only
while they run:

| Address | What |
|---|---|
| `$D780` | 96 words: file position of row 32k |
| `$D840` | 12 x 28: the rows on screen |
| `$D990` | 28: each character's distance from its row's start |
| `$D9AC` | 13 words: file position of each row on screen and of the next |
| `$D9C6` | 12: tile columns each screen row has ink in |
| `$D9D2`-`$D9D7` | sector in the buffer, its length, the top row's number |
| `$D900` | 256: the path, for `f_open` only (it overlaps the above) |

The 0918 build has run on a cart.
