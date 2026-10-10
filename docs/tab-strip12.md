# 12px tab strip

In 12px UI mode ([ui-mode.md](ui-mode.md)) the `SD / SET / HELP` strip at the
top of every pane is set in the 12px font ([font12.md](font12.md)), like the
browser list under it. The HELP pane's text is 12px as well (below), and so is the SET pane ([set-pane12.md](set-pane12.md)). In
8px mode nothing changes: the stock drawer runs as before.

## Geometry

| | 8px (stock) | 12px |
|---|---|---|
| labels | 8x8 cells on tile row 0, ` SD ` / ` SET ` / ` HELP ` at columns 0, 4, 9 | the 12px row at y 0..11, the same three strings laid out by `Fit12` |
| rule | 2 px, y 8..9 | 1 px, y 12 |
| entry number | 4 cells at column 16 | from x 124 |
| browser list | from y 16 | from y 20 (`draw12.c` `STRIP_H`): ten rows, y 20..139 |
| SET / HELP content | from y 16 (tile row 2) | unchanged |

The 6 px between the stock rule and the first list row, plus 4 of the 8 px
the 12px list left free at the bottom of the screen, pay for the taller
strip: the gap under the rule is 7 px (y 13..19) and 4 px stay free under
the last row.

The rule is one pixel because the SET pane starts right under it. The TIME
row's `SET` button box had its top edge at y 13; in 12px mode it is at y 14
(`SetBtnTopHL`), which leaves a blank row under the rule and still one row
of padding above the button's text when the box is filled. Nothing else on
SET or HELP reaches above y 16.

## How it is drawn

`DrawString12` always paints from its start x to the right edge of the row,
in the current ink and paper. `TabStrip12` (`tabstrip12.c`, `02:5e00`) uses
that: it draws the three labels left to right, each from its own pixel x,
the selected one in paper on ink, and ends with a blank after ` HELP ` so a
selected HELP tab's highlight stops there. The start positions are the pen
positions `Fit12` reports for one pass over the whole strip text, so they
follow the font's metrics. The rule is a solid `DrawRect` afterwards.

For this, `DrawString12` and `Fit12` take a pixel x: a `col` argument of 2
or more is the start x itself (0 is still x 0, and 1 the name field after
an icon).

`TabStrip12(tab)` mirrors the stock drawer's cases: 0 (SD) clears y 0..19
and draws the strip, 1 and 2 (SET, HELP) clear the whole canvas and draw
it, 3 clears the content area below the rule and leaves the strip alone. In
the SET tab's pick mode (`$DBFE`) case 0 draws ` PICK A ROM ` in paper on
ink instead of the labels; the 8px banner (`flpick_banner.c`, bank 8) steps
aside in 12px mode, since its string is out of the bank-2 renderer's reach.

The entry number at the right end is drawn by the list code after the strip,
through `TabNum12`: 8px goes to `DrawString` unchanged, 12px rewrites the
column argument to 124 and goes to `FarCallDrawString12`, which paints from
there to the edge and so also ends a pick banner.

## HELP pane

The HELP tab's five lines (see [help-version.md](help-version.md)) are drawn
in the 12px font too: `FW5 K1.05e-0731`, `www.ezflash.cn`,
`MOD <version>` and the two-line GitHub link (`github.com/lukesau/`, then `ezgb`), from x 4 at y 24, 44, 64, 84
and 96. The 8px pane's `ver:` label is dropped: with the fixed-width digits
the labeled line would run to the right edge.

`DrawFwVersionScreen` builds `FW<n>  K1.05e` in a stack buffer and then
draws; the draw half (`DrawFwVersionScreen_drawChrome`, `08:70e1`) now starts
with `jp HelpHook` (`08:7b40`). In 8px mode the hook replays the displaced
load and the stock code runs on into `DrawHelpModVersion`. In 12px mode it
calls `Help12` (`help12.c`, `08:7d00`) with that buffer and jumps to the
stock wait loop (`08:7141`). `Help12` composes the version line from the
buffer's FW number and `DrawHelpModVersion`'s kernel text, and draws the
other lines from the same bank-8 strings the 8px pane uses (the stamped
`MODSTR` included), copying each to the stack first because the renderer
runs in bank 2.

## Status boxes

`Reading...`, `Loading...` and `Error file` are three copies of one stock
drawer in bank 8 (`08:7344`, `737f`, `73ba`): ink 0 on paper 3, a filled box
(35,37)-(125,108), ten characters at column 5 of tile row 8. Each now starts
with `jp MsgHook<n>` (`08:7e10` / `7e24` / `7e38`): 8px replays the displaced
load and runs the stock code; 12px calls `MsgBox12(n)` (`msgbox12.c`,
`08:7e80`), which draws the same box and the same string on the 12px row at
y 64 from x 44, clipped at the box's right side (`hClip12`,
[set-pane12.md](set-pane12.md)).

Still 8x8 in 12px mode: the boot messages (`Micro SD initial OK!` and the
SD error texts) and `BATTERY DRY!!!`.

## Patches (1.05e)

| Site | Was | Now |
|---|---|---|
| `08:7169` (`DrawMenuTabs` entry) | `ld hl,$0000` | `jp TabStripHook` (`08:7b20`): 8px replays the load and continues at `08:716c`; 12px pushes the tab number, far-calls `TabStrip12` and returns (through `FlPickBanner` for tab 0, as the stock SD arm does) |
| `01:42ae`, `01:45a7` (entry number, `DrawBrowserEntries` / `DrawBrowserDetail`) | `call DrawString` | `call TabNum12` (`00:0380`) |
| `04:4777`, `04:4931`, `04:5646` (SET button box) | `ld hl,$9b0d` | `call SetBtnTopHL` (`04:5f60`): `hl = $9b0d` in 8px mode; the 12px box is in [set-pane12.md](set-pane12.md) |
| `draw12.c` | `STRIP_H` 16 | 20; `col >= 2` is a pixel x (also `layout12.c`) |
| `flpick_banner.c` | | returns at once in 12px mode |
| `08:70e1` (`DrawFwVersionScreen_drawChrome`) | `ld hl,$0000` | `jp HelpHook` (`08:7b40`) |
| `08:7344`, `08:737f`, `08:73ba` (status boxes) | `ld hl,$0003` | `jp MsgHook<n>` |

The START overlay's 12px layout moved down 4 px with the list
([last-rom.md](last-rom.md)).

Checked in SameBoy (DMG model, 0731): the three tabs, the list with a full
page, the entry number changing with the cursor, pick mode, the START
overlay, and 8px mode unchanged. Switching `UI:` on the SET tab takes
effect when the tab is next drawn; until then the strip keeps the old font.
