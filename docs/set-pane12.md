# 12px SET pane

In 12px UI mode ([ui-mode.md](ui-mode.md)) the SET tab's content is set in
the 12px font ([font12.md](font12.md)) too. 8px mode is unchanged.

## Layout

The pane already had its seven rows on every second tile row (2, 4, .. 14,
see [fastlaunch-set-tab.md](fastlaunch-set-tab.md)), 16 px apart, and a 12px
row fits that pitch: **y stays 8 x row**, from y 16 under the tab strip's
rule (y 12) to y 123. Vertical space was not the constraint; width is. What
changes is x, per field:

| Row | 12px fields (x span) |
|---|---|
| 2 | `TIME:` 0..120; the `SET` / `SAV` button text 127..155, in a box (123,15)-(155,28) |
| 4 | date and time: digits 9 px, `/` 8, `:` 6, the blank 6, 160 px in all |
| 6 | `RTC:` 0..44, `SD` 44..66, `NO SD` 86..130; the checkboxes stay at x 66 and 130 |
| 8, 10 | `AUTO SAVE:`, `FAST LAUNCH:` 0..128; checkbox at x 130 |
| 12 | fast-launch name 0..80 (scrolls from 10 characters up); `PICK ROM` 88..155 in a box (83,95)-(155,108) |
| 14 | `UI:` 0..112; `12px` 120..155 in a box (115,111)-(155,124) |
| 16 | `SGB BOOT:` 0..128; checkbox at x 130 |

The checkboxes (9 px squares at y 8 x row) are not moved: they line up with
the 12px caps as they are. Button boxes are the text row plus a pixel above
and below, where the 8px boxes had 3 px above and 5 below.

## How it is drawn

The stock SET screen (`DrawTimeAutosaveScreen`, bank 4) draws each piece of
text with its own `DrawString(s, len, col, row)`: the labels, the button
text, and in the date row every field and separator, again in the
time-edit path with the edited field in inverse. All 25 of those calls now
call `SetText` (`settext.c`, `04:6400`) with the same frame, and `flcfg.c`'s
rows use it as well.

`SetText` in 8px mode is `DrawString`. In 12px mode it maps `(col, row)` to
the field's x span from the table above and draws through `DrawString12`
with **`hClip12`** (`$fff9`) set to the span's end:

- `DrawString12` normally paints from its start x to the row's right edge.
  With `hClip12` non-zero it stops there instead: it flushes only the tiles
  up to the limit and keeps the last tile's pixels right of it (read back
  just before that tile is flushed, as the first tile's left part always
  was), and `Fit12` places no glyph that would cross the limit.
- So a field repaints exactly its span, in the current ink and paper. The
  time-edit highlight is therefore the field's rectangle, and redrawing one
  field never touches its neighbors, the same contract `DrawString`'s
  fixed-width cells gave the stock code.

The date row needs columns of fixed width for that, which the tabular
digits provide; `SetText`'s `date_x[]` holds the x of each of the 19 columns.

`y = 8 x row` is passed as `row * 8 + 2`: `DrawString12` treats a row
argument of 18 or more as a pixel y and rounds it down to a multiple of 4,
which makes y 16 (row 2) reachable.

## Switching the mode on the pane

The `UI:` button changes the layout of the pane it is on, and of the tab
strip. `flcfg` therefore redraws the strip in the new mode through
`FarCallMenuTabs` (`04:5f70` -> `DrawMenuTabs`, which also clears the pane)
and returns 2; `FlSetADispatch` then drops the screen's stack frame and
jumps to its entry (`04:46f4`), so everything is drawn again in the new
font. `flcfg` leaves a marker (`$DB38` = `$FF`) that its enter op turns
into "cursor on the UI row", redrawing TIME's `SET` button plain (the
entry code draws it highlighted for row 0), so A toggles straight back and
the two layouts can be compared.

## Patches (1.05e; 1.04e has 24 of the 25 text sites, its redraw path lacks the extra `SAV` draw)

| Site | Was | Now |
|---|---|---|
| 25 x `call DrawString` in `04:4761..514c` | `cd b7 08` | `call SetText` (`cd 00 64`) |
| `SetBtnTopHL` (`04:5f60`) | `hl = $9b0d`, or `$9b0e` in 12px | 12px: `hl = $9b0f` and the pushed y1 becomes `$1c` (box y 15..28) |
| `FlSetADispatch` (`04:5f30`) | E = 0 redraw, else leave | E = 0 redraw, 1 leave, 2 `add sp,$6a; jp $46f4` |
| `flcfg.c` | at `04:5990` | moved to `04:6600` (it outgrew the slot); text through `SetText`, 12px button boxes, UI toggle as above |
| `draw12.c`, `layout12.c` | | `hClip12` |

To make room for the larger `DrawString12`, `LastRomName` moved to `02:7260`
and `DrawNameWithIconImpl` to `02:7e80` (their bank-0 stubs follow).

Checked in SameBoy (DMG model, 0731): the pane in both modes, every cursor
row, time-edit mode with a field highlighted and changed, the name marquee,
toggling the mode both ways on the pane, and the browser, START overlay and
BACKUPSAVE prompt afterwards.
