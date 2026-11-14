# The SET tab

Stock's SET tab has the clock and an AUTO SAVE box. The mod makes it three
pages that hold every setting, so the cart is configured without a
computer. Addresses are 1.05e-0731's.

## The pages

SELECT steps SD, SET, HELP. START returns to the SD tab from the other two.

| Row | Page 1 | Page 2 | Page 3 |
|---|---|---|---|
| 2 | `TIME:` and `SET` (stock) | `CLEAN UP NAMES:` ([browser.md](browser.md#clean-names)) | `THEME:` ([themes.md](themes.md)) |
| 4 | the date and time (stock) | an example name, scrolling | `FONT:` ([font12.md](font12.md#ui-modes)) |
| 6 | `RTC:  SD [ ]  NO SD [ ]` ([ezgb-cfg.md](ezgb-cfg.md#the-clock-backup)) | `SORT BY PLAYS:` ([stars.md](stars.md)) | `COLORS:` and the `R` `G` `B` heads |
| 8 | `AUTO SAVE:` (stock) | `SGB BOOT:`, or `SGB: AUTO` ([sgb-boot.md](sgb-boot.md)) | `BG:` ([the picker](themes.md#the-picker)) |
| 10 | `FAST LAUNCH:` ([fast-launch.md](fast-launch.md)) | `SKIP BOOT ROM:` ([skip-boot-rom.md](skip-boot-rom.md)) | `TEXT:` |
| 12 | the fast-launch game's name, and `PICK ROM` | `DAILY BACKUP:` ([save-manager.md](save-manager.md#daily-backup)) | `ACCENT:` |
| 16 | `< PREV`, `1/3`, `NEXT >` | the same, `2/3` | the same, `3/3` |

The pages go round: PREV on page 1 is page 3. A row a console cannot use is
drawn gray and the cursor passes over it.

### The cursor

UP and DOWN move a cursor over the page's rows and wrap within the page.
LEFT puts it on the page's PREV button and RIGHT on NEXT, from any row.
While the time is being set, LEFT and RIGHT step through its fields as in
stock.

The cursor's row numbers run on across the pages, and a page's last two are
its PREV and NEXT:

| Page | Rows |
|---|---|
| 1 | 0 TIME SET, 1 RTC, 2 AUTO SAVE, 3 FAST LAUNCH, 4 PICK ROM, 5 PREV, 6 NEXT |
| 2 | 7 CLEAN UP NAMES, 8 SORT BY PLAYS, 9 SGB BOOT, 10 SKIP BOOT ROM, 11 DAILY BACKUP, 12 PREV, 13 NEXT |
| 3 | 14 THEME, 15 FONT, 16 BG, 17 TEXT, 18 ACCENT, 19 PREV, 20 NEXT |

**Adding a row** means changing all of these: the clamp at `04:5604`
(`d6 14`, the last row number), `SetWrapUp` (`04:5fdc`) and `SetWrapDown`
(`04:5fe4`), and the `first` and `last` tables in
[flcfg.c](../kernel/mod/src/flcfg.c) and
[setpage.c](../kernel/mod/src/setpage.c).

### When settings reach the card

Changes stay in RAM and set `SET_DIRTY` (WRAM `$DAFD`). `SetCommit`
(`04:5fc0`) writes `EZGB.CFG`, and the plays file when it changed, on NEXT,
on PREV and when the tab is left. Nothing is written if nothing changed.
Power off before one of those and the file keeps the old values.

Three things change at once:

- TIME SET writes the clock and `RTC=`.
- The pSRAM records: SGB BOOT, SORT BY PLAYS, and the theme mark.
- Ticking FAST LAUNCH first shows a box, `Hold START at boot to cancel`,
  since a card that boots straight into a game gives no hint of how to
  reach the browser again.

### Picking the fast-launch game

A on PICK ROM arms pick mode (`FL_PICK`, WRAM `$DBFE`) and drops into the
browser, whose tab strip reads ` PICK A ROM `. A on a `.gb` or `.gbc` writes
its full path as `FLAUNCH=` and returns to the SET tab. SELECT, or B at the
card's root, returns without choosing. Picking does not change whether
fast launch is enabled.

## How it is built

The stock screen is one long function, `DrawTimeAutosaveScreen`
(`04:46f4`), that draws the clock, runs its own input loop and keeps
running for as long as the tab is open. The mod leaves it running and hooks
it.

### Hooks in the stock screen

| Site | Now goes to | For |
|---|---|---|
| `04:47ef`, the prologue | `FlSetEnterHook` | drawing the mod's rows on entry |
| `04:5404`, `04:560d`, the cursor tails | `FlSetRowsHook` | redrawing after a cursor move |
| `04:5174`, `04:51a5`, LEFT and RIGHT | `FlSetJumpTop` (`04:5f80`), `FlSetJumpBottom` (`04:5f90`) | the jump to PREV and NEXT ([inject-set-jump.py](../scripts/inject-set-jump.py)) |
| `04:5604` | the clamp, `d6 14` | 21 cursor rows |
| `04:5632`, A off row 0 | `FlSetADispatch` (`04:5f30`) | row 2 to the stock AUTO SAVE toggle, the rest to `FlCfg` |
| `04:5162`, the loop's `call ReadJoypad` | `SetLoopTickHook` (`04:5f20`) | the per-pass tick: the name marquee and the D-pad repeat ([input.md](input.md#repeat-on-the-set-tab)) |
| `04:5912`, the exit | `SetExitHook` (`04:5fb0`) | `SetCommit`, back to page 1 |
| `00:1263`, after SET returns | `FlSetExitHook` | the browser when pick mode is armed or START left the tab, else HELP |
| `00:1569`, the browser's launch | `FlPickHook` | capturing the ROM in pick mode |
| `00:164e`, B at the root | `FlPickCancelHook` | back to SET in pick mode |
| `08:7200`, the tab strip's tail | `FlPickBanner` | the banner |
| `08:714c` | `$c0` for `$40` | HELP's wait loop leaves on SELECT or START |

The hooks' frame rules are in [shims.md](../kernel/mod/src/shims.md). A
hook reached by `call` finds the screen's locals two bytes further up the
stack than one reached by `jp`.

### `FlCfg`

All the hooks call `FlCfg(frame, op)` ([flcfg.c](../kernel/mod/src/flcfg.c),
`04:6d19`, through the fixed entry `FlCfgJump` at `04:6600`):

| Op | When | Does |
|---|---|---|
| 0 | entering the screen | loads the settings and draws the page's rows |
| 1 | after a cursor move | keeps the cursor on its page and redraws the rows |
| 2 | A on a row | toggles or steps that setting. Returns 2 when the whole screen must be laid out again |
| 3 | a ROM picked in the browser | builds the path and stores it |
| 5 | every pass of the loop | reads the pad, steps the marquee |

A return of 2 from op 2 makes `FlSetADispatch` drop the screen's stack
frame and jump to its entry, so everything is drawn again. That is how a
page switch, a font change and a theme change onto or off an accent work.
`SET_PAGE` (WRAM `$DBEE`) holds the page and `SET_RE` (`$DBEF`) the cursor
row to come back to.

Page 2 and the page row are drawn by `SetPage`
([setpage.c](../kernel/mod/src/setpage.c), `04:6610`). Page 3 is `ThemePage`
([themepage.c](../kernel/mod/src/themepage.c), `0D:4000`), reached through
`FarCallThemePage` (`04:5990`), since bank 4 has no room for it.

### Pages 2 and 3 over a running stock screen

The stock screen keeps running under pages 2 and 3: the clock still ticks
and its fields are redrawn every second. Two things keep its rows off
them:

- All stock text goes through `SetText` (below), which draws nothing while
  `SET_PAGE` is 1 or 2. `FlCfg` sets bit 7 of `SET_PAGE` while it runs, so
  its text still draws.
- The stock boxes are drawn only when the screen's dirty flag (`sp+$3e`)
  is set after a cursor move, and op 1 clears it on pages 2 and 3.

### The tab-switch clear

The tab drawer wipes the content area with a `DrawRect` whose top is one
byte in each of three per-tab copies (`08:7222`, `08:729d`, `08:7318`).
Stock's `$0f` left the top of the SET button's box on HELP; it is `$0a`,
just below the tab rule.

## The 12px layout

In 12px mode the rows keep their place, `y = 8 x row`, and only x changes.
All 25 of the stock screen's `DrawString` calls go to `SetText`
([settext.c](../kernel/mod/src/settext.c), `04:6400`), and so do the mod's
rows.

`SetText` in 8px mode is `DrawString`. In 12px mode it maps `(col, row)` to
the field's x span and draws through `DrawString12` with `hClip12` (HRAM
`$fff9`) set to the span's end. With `hClip12` set, the renderer stops
there and keeps the pixels right of it, and the layout places no glyph that
would cross it. So a field repaints exactly its span, and redrawing one
field never touches its neighbors: the same contract `DrawString`'s fixed
cells gave the stock code.

| Row | Page 1 fields (x span) |
|---|---|
| 2 | `TIME:` 0..120; the `SET` button's text 127..155, in a box (123,15)-(155,28) |
| 4 | the date and time: digits 9 px, `/` 8, `:` 6, the blank 6, 160 px in all |
| 6 | `RTC:` 0..44, `SD` 44..66, `NO SD` 86..130; checkboxes at x 66 and 130 |
| 8, 10 | `AUTO SAVE:`, `FAST LAUNCH:` 0..128; checkbox at x 130 |
| 12 | the name 0..79; `PICK ROM` 88..155 in a box (83,95)-(155,108) |
| 16 | `< PREV` 8..64 in a box (3,127)-(65,140), `1/3` 70..97, `NEXT >` 104..155 in a box (99,127)-(155,140) |

Page 2's labels are 0..128 with the checkbox at x 130. Page 3's fields are
in `themepage.c`, which draws its own text.

Two details:

- The date row needs columns of fixed width, which the tabular digits give.
  `SetText`'s `date_x[]` holds the x of each of its 19 columns.
- A row is passed to `DrawString12` as `row * 8 + 2`. It treats a row
  argument of 18 or more as a pixel y and rounds down to a multiple of 4,
  which makes y 16 reachable.
