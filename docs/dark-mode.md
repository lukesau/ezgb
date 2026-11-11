# Dark mode: UI themes for the kernel and stage1

[Issue #11](https://github.com/lukesau/ezgb/issues/11). The SET tab has a
`THEME` button that cycles the browser, every kernel screen and our stage1's
boot screen through light (the stock look), dark, DV (see [DV](#dv)), four
colored ones, and custom, whose colors are set with the picker under the
button or by hand in `EZGB.CFG` (see [Color picker](#color-picker) and
[Custom](#custom)), in that order: A goes forward, B back, and both wrap.
The file is written on NEXT, on PREV or on leaving the tab
([fastlaunch-set-tab.md](fastlaunch-set-tab.md)). Light and dark are the DMG baseline:
on a DMG, or anything else running the kernel in DMG mode, light is the stock
palette and every other theme but DV the inverted one. DV and the colored
themes are for backlit and OLED screens. Where palette RAM is locked (a DMG, or
a GBC or GBA in compatibility mode on stock firmware) the colored themes and
custom look the same as dark, so the button only offers light, dark and DV.
One of the others set in the file shows as `DARK` there and keeps its value
until the button is pressed, so a card moved to a color console keeps it.
`Theme` sets `PAL_LOCKED` (HRAM `$FFF8`) when its palette write gives up.

> For part of 2026-10-31 only light, dark and DV were left; the colored ones
> and custom came back the same day, after DV on the button and with their
> old numbers (2 to 6), so a card's `THEME=` means what it did.

## The themes

| # | Button | Background (0) | Popups (1) | Shade 2 | Ink (3) |
|---|---|---|---|---|---|
| 0 | `LIGHT` | `$7FFF` white | `$56B5` | `$294A` | `$0000` black |
| 1 | `DARK` | `$0000` black | `$18C6` | `$4631` | `$7FFF` white |
| 2 | `RED` | `$0428` (66,8,8) | `$1CED` | accent `$7E88` sky | `$7FFF` |
| 3 | `GREEN` | `$0D22` (16,74,25) | `$25A8` | accent `$625F` rose | `$7FFF` |
| 4 | `PURPLE` | `$3048` (66,16,99) | `$410D` | accent `$1F5D` gold | `$7FFF` |
| 5 | `BLUE` | `$30A2` (16,41,99) | `$4148` | accent `$369F` apricot | `$7FFF` |
| 6 | `CUSTOM` | `COLORS=` | 3/16 toward ink | accent: `COLORS=`'s third, or the complement | `COLORS=` |
| 7 | `DV` | `$0000` black | accent `$1BEF` lime | `$6180` blue (icons) | `$7FFF` white |

Until 2026-11-09 shade 2 of the color themes and custom was a second middle
shade, the background 56% (custom 9/16) of the way to white; see
[Accents](#accents).

Dark is pure black with white ink, what the issue asked for on an OLED
screen: those pixels stay off. (A dim gray background with a tan ink was
tried first; the requester preferred plain black and white.) Every theme past
0 has white ink, and its two middle shades are the background blended 20% and
56% toward white. Green, purple
and blue are about half again as bright as red: at red's level the three
were hard to tell apart on an unlit GBC screen. The darker mid
shade matters: it is the cursor outline on a SET checkbox, so it has to stand
off the background.

The kernel draws in color indices only (it wrote `BGP = $E4` once and never
touched a palette again, [cgb-mode.md](cgb-mode.md)), so a theme is nothing
but the four colors those indices draw as: one row of
[theme_ramps.c](../kernel/src/theme_ramps.c). On a color console in CGB mode
that row goes to all 8 BG and 8 OBJ palettes. On a DMG, light is `BGP`,
`OBP0`, `OBP1` = `$E4`, `$E4`, `$1B` (stock) and every other theme
`$1B`, `$1B`, `$E4`.

## Accents

Since 2026-11-09 ([issue #13](https://github.com/lukesau/ezgb/issues/13)).
Every color theme draws its highlights in an accent the way DV draws them in
lime: the selection bar, the active tab, the name band of the menus and
prompts, the rules and dividers between their buttons, the checkbox ticks.
Light and dark have none and look as before.

- **How.** The kernel draws a highlight as black on white (ink 0 on paper
  3) and a rule as a solid white fill. `StoreDrawParams` ends in `DvParams`
  ([dv_params.c](../kernel/src/dv_params.c), 27 B at `00:3fe4`), which moves a
  stored paper of 3, and the ink too when it is 3 as well, to `ACC_IDX`
  (WRAM `$DC0B`): 1 in DV (its lime), 2 in a color theme (its shade 2), 0 in
  light and dark (nothing moved). `theme_ramp`
  ([theme_pick.c](../kernel/src/theme_pick.c)) sets `ACC_IDX` each time a
  theme is applied. White text on the background is untouched, and popups
  keep shade 1 as their background, so a popup is the lighter shade with
  accent rules.
- **The color.** For red, green, purple and blue it was picked by hand
  (2026-11-10): from the background's complement and its two split
  complements (worked out in OKLCH), one per hue family, then made more
  saturated until it kept its color through a GBC screen's washout (pastels
  near white turned white under SameBoy's color correction). The background,
  the bar's text color, reads on each at 5:1 or better: red takes sky
  `#42A5FF`, green rose `#FF94C5`, purple gold `#EFD63A` (royal purple and
  gold), blue apricot `#FFA56B` (navy and orange). They are baked into
  [theme_ramps.c](../kernel/src/theme_ramps.c)'s shade 2. Until then each was
  the plain complement at full brightness (cyan, magenta, lime, amber).
- **Custom** works it out the same way from `COLORS=`'s background, or takes
  a third color from the line (see [Custom](#custom)).
- **DV** keeps black, white and its blue icons, and its lime is the
  highlight a third `COLORS=` color sets, when there is one: `THEME=7` with
  `COLORS=000000,FFFFFF,FF5FA0` is DV in pink. ezcfg builds that ramp
  (`DV_RAMP`, WRAM `$DC11`) and `theme_ramp` returns it for DV. The line's
  first two colors are custom's and change nothing in DV. Only on a color
  console in CGB mode, like every color.
- **The browser bar** moves by recoloring the two rows in VRAM, which an
  inversion (index 0 <-> 3) can't do for an accent, so with any accent
  `move_bar` takes the routines DV used, now for both fonts and either
  accent plane ([browser-nav.md](browser-nav.md)).
- **The SET tab** lays the screen out again when the THEME button goes onto
  or off an accent, as it did onto or off DV: bars already drawn in white
  would stay white otherwise.
- **Stock firmware and the DMG** only have `BGP`: where `PAL_LOCKED` is set,
  a color theme from the file (the button there offers light, dark and DV,
  and shows it as `DARK`) gets no accent, so it is dark exactly. The first
  `Theme` call at boot runs before the palette test, but nothing is drawn in
  bars before the config load applies the theme again.
- **Stage1** builds its boot screen from the mark, which now holds the
  accent where the lighter middle shade was, as DV's mark always did.

## Color picker

Since 2026-11-10. The SET tab's third page, under THEME and FONT, sets the
custom theme's three colors on the cart:

```
COLORS:    R   G   B
BG:       [17][ 9][22]
TEXT:     [ 0][ 0][ 0]
ACCENT:   [22][16][10]
```

- **What it shows.** The colors on screen, whatever the theme: color index
  0, index 3 and the accent's index (shade 2 in light and dark, which have
  no accent), read back from palette RAM, so 0 to 31 a channel, what the
  console has. Stepping THEME changes the rows with it.
- **Setting one.** A on a row, then LEFT and RIGHT pick the channel, UP and
  DOWN change it (held, they repeat), A or B ends: the keys TIME's `SET`
  uses for the clock. The screen is the preview; every step applies.
- **It starts from the theme on screen.** The first change in a built-in
  theme copies that theme's background and text to the custom one and
  switches THEME to `CUSTOM`, so red with a darker background is: pick
  `RED`, turn BG down. This replaces the earlier custom background and
  text, but only once a value changes; looking does nothing. In `CUSTOM` a
  change is just that change.
- **The accent is only set on its row.** It is DV's highlight as well as
  custom's (the third color, since 2026-11-09), so a built-in theme's
  accent is never copied along with its background: DV keeps its lime, or
  the accent already set, whatever BG and TEXT are changed from. Custom's
  accent stays the one worked out from its background until the ACCENT row
  is changed, which starts from the accent on screen.
- **DV.** Only the accent row can be set in DV: it sets DV's highlight and
  leaves DV on. DV is black and white the way its font is its font, so BG,
  TEXT and FONT can't be set there: they are drawn in color index 2, DV's
  blue (a dark gray on a DMG), without a highlight, and the cursor passes
  over them, from THEME straight to ACCENT. The accent is still the one
  in `COLORS=`, the custom theme's too: with no line yet, the save writes
  `COLORS=000000,FFFFFF,` and the accent, which also puts `CUSTOM` on the
  THEME button.
- **Saved** with the rest of the tab, on NEXT, PREV or leaving it, as
  `COLORS=RRGGBB,RRGGBB,RRGGBB`; a channel the picker set is its 5 bits
  widened to 8 (31 is `FF`), one it didn't touch keeps the file's digits.
  An accent that `COLORS=` left to the complement stays the complement
  until the ACCENT row is changed.
- **Where palette RAM is locked** (a DMG, compatibility mode on stock
  firmware) there are no colors to set, and the picker is not there: the
  page is THEME, FONT and the page row. (Until 2026-11-10 the cells read
  `--`.)

`ThemePage` ([themepage.c](../kernel/src/themepage.c), bank 13) does it.
While a row is being set (`CP_EDIT`, WRAM `$DC19`, 1 + the channel) its
tick, called from `FlCfg` op TICK with the pad, hands the stock loop no
keys. A change writes `CUST_RGB` or `ACC_RGB`, rebuilds `CUST_RAMP` (and
`DV_RAMP`) the way `ThemeColors` and `colors_accent` do from the line, and
calls `Theme`. When the first change moves the accent to another color
index (light and dark draw their bars in index 3, custom in 2) or leaves
DV's glyph set, the bars and text on screen are stale, as after a THEME
step: the tick sets `CP_EDIT` bit 7 and returns A, the stock loop
dispatches it as a press, and op A returns 2 for it, which lays the screen
out again with the row still being set.

Checked in SameBoy (2026-11-10, CGB model): all three rows in 8px, 12px and
SLIM on 0731, the switch to `CUSTOM` from light with its relayout, the
accent in DV (and BG, TEXT and FONT there doing nothing), DV still lime after a background set from dark, the saved
line and the same colors after a reboot, DV's locked rows in blue with
the cursor passing over them, a DMG model's page without the picker; the page and one change on 1.04e, the page on 0918.
Not tested on hardware.

## Custom

Since 2026-10-30. One line in `EZGB.CFG` sets the background and the ink
(text), in web hex, the format every color picker gives, and since
2026-11-09 optionally the accent:

```
THEME=6
COLORS=1E2A44,F2D7A0
COLORS=000000,FFFFFF,7BFF31      (a third color: the accent)
```

The third color is also DV's highlight in place of its lime ([Accents](#accents)).

With `UI=SLIM` that last line is close to DV on any console: black, lime
and white with the Tamzen font, though the icons are the stock ones in white
(DV's icons and their blue are its own).

- The value is read as its first 12 hex digits, so `#1E2A44, #F2D7A0` and
  lower case work too. Fewer than 12 and the line is ignored. The kernel
  writes it back as `RRGGBB,RRGGBB`, the 8-bit values as read.
- The console has 5 bits per channel (BGR555, `$7FFF` style, which nobody
  can type), so each channel keeps its top 5 bits: `1E2A44` draws as
  `$20A3`.
- Shade 1, the popups' background, is the background moved 3/16 of the way
  to the ink, about where the built-in dark themes have theirs. Any pair
  works, light or dark.
- Shade 2 is the accent: digits 13 to 18 when the line has them (written back
  as a third `RRGGBB`), else the background's complement at full brightness
  ([Accents](#accents)), or the ink when the background is a gray (black
  and white too: a gray is its own complement, bars nobody could see, until
  2026-11-10), worked out by `colors_accent` in
  [ezcfg.c](../kernel/src/ezcfg.c) after `ThemeColors` has read the first
  two. Until 2026-11-09 it was the background moved 9/16 toward the ink.
- `CUSTOM` is in the SET tab's `THEME` cycle only when the file has a valid
  `COLORS=` line or the picker has set a color; without either, `THEME=6`
  is light and the button goes from BLUE to LIGHT. The two lines can be in either order.
- On a DMG it is the inverted palette like every other theme past 0, and
  stage1's boot screen (which already reads the colors from the mark) needs
  no change.
- Colors on an unlit GBC screen come out much paler and less saturated than
  on a computer screen; pick by trying them on the console.

The code is three small blocks, since ezcfg and theme.c had almost no
room. `ThemeColors` (bank 5, asm: SDCC made 610 bytes of the C) parses the
line, builds the four colors and writes both `THEME=` and `COLORS=` on a
save (moving the `THEME=` write there made room for the rest in ezcfg).
`ThemeCustom` (bank 2) is ezcfg's far stub to it and `theme_ramp`, which
`Theme` calls for the colors: it cannot far-call, since the boot runs it
with interrupts off. Each middle shade is four halving steps,
`acc = (acc + (bit ? ink : bg)) / 2` over the weight's bits from the low
end, which needs no multiply.

## Where the setting lives

Two copies, because the first frames are drawn before the SD card is read:

- **`EZGB.CFG` `THEME=<n>`**, the source of truth ([ezgb-cfg.md](ezgb-cfg.md)).
  Written only when the theme is not 0. A number rather than a name: a key
  with a parsed word value did not fit ezcfg's slot. `COLORS=` holds the
  custom theme's two colors.
- **pSRAM page `$11` `$A414`–`$A41F`**: `'T'`, `'H'`, theme, `~theme`, then
  the theme's four colors ([psram-page-map.md](psram-page-map.md)). The
  kernel rewrites it every time it applies the file's theme; the next boot's
  first frames (stage1's boot screen, the kernel's boot) read it. A missing
  or faded mark (BATTERY DRY) is theme 0.

When they disagree (the file was edited on a PC, or the card moved to another
cart), the boot screen and the kernel's first frames use the mark, and the
file's theme takes over at the boot restore, right after `Micro SD initial
OK!`. Stage1 picks it up on the next power-on.

## Kernel

| Block | Address | Does |
|---|---|---|
| `Theme` | `02:43d0`, [theme.c](../kernel/src/theme.c), 304 B (full) | At boot (`CFG_LOADED` 0): `THEME` from the mark. Later: the mark and colors from `THEME`. Then the palette registers, and the ramp, each byte written by index and read back in mode 0 or 1, so a call with the LCD on is safe. A byte that still reads back wrong after 8 tries ends the ramp: palette RAM only takes writes in CGB mode. |
| `ThemeRamps` | `02:4960`, [theme_ramps.c](../kernel/src/theme_ramps.c), 48 B | The colors, data only, 8 bytes per theme; custom has no row. |
| `ThemeCustom` | `02:4990`, [theme_pick.c](../kernel/src/theme_pick.c), 48 B | `FarCallColors` (8 B), ezcfg's stub to `ThemeColors`, then `theme_ramp` (`02:4998`): the colors for `Theme`, a `ThemeRamps` row or, for custom, `CUST_RAMP`, which it loads from the mark at boot. |
| `ThemeColors` | `05:7b50`, [theme_colors.c](../kernel/src/theme_colors.c), 335 B | Asm. Op 0 (or 8, ezcfg's key index) parses `COLORS=` into `CUST_RGB` and builds `CUST_RAMP`; op 1 writes the `THEME=` and `COLORS=` lines on a save (and `BOOTROM=1`, [skip-boot-rom.md](skip-boot-rom.md)); op 9 parses `BOOTROM=`. |
| `CgbInit` | `00:0259`, [cgb_init.c](../kernel/src/cgb_init.c), 49 B | The boot LCD-on hook. Its CGB ramp loop is gone: it maps bank 2 by hand (`$2000 = 2`, interrupts are still off, so not through `FarCallTrampoline`, whose `EiNest` would turn them on early), calls `Theme`, maps bank 1 back. |
| `EzCfg` | `02:4a00` | Parses `THEME=` (light unless it is one digit naming a theme, and custom only with a valid `COLORS=`) and hands `COLORS=` and the save's two theme lines to `ThemeColors`; the boot restore (op 3) calls `Theme` right after its `cfg_load`. The key parser is now table-driven (`cfg_keys`, one `switch`), which took the module from 5010 to 4897 B with the new key. |
| `PopupDrawParams` | `00:0290`, [popup_params.c](../kernel/src/popup_params.c), 37 B | Popup ink and paper per theme, below. |
| `ThemePage` | `0D:4000`, [themepage.c](../kernel/src/themepage.c), 2753 B | The SET tab's third page, far-called by `FlCfg` through `FarCallThemePage` (`04:5990`): the THEME button (it steps through the order table, back when `THEME_BACK` (`$DAFB`) is set, sets `SET_DIRTY` and applies the theme; `FlCfg` op TICK hands it the pad, and it turns B into A with that flag when `SET_CUR` (`$DAFC`) is the THEME row), its names, the FONT button and the [color picker](#color-picker). Until 2026-11-10 the button was `ThemeRow` (`04:77a0`, theme_row.c) with `ThemeNames` (`04:7eeb`), on page 2. |

> **Correction (2026-10-30).** `Theme` used to write the ramp only when
> `VBK` read back bit 0 clear, taken from `CgbInit` as the CGB-mode test, and
> retried each byte until it read back. On a GBC running the kernel in DMG
> compatibility mode (stock stage1, which has no CGB flag) `VBK` reads back
> what was written, so the test passed, palette RAM ignored the writes, and
> the retry never ended: the 7.0 kernel hung before its first frame with a
> blank screen, on hardware (a GBC-family console on stock FW4) and in
> SameBoy with the header's CGB flag cleared. The retries are capped at 8
> and the `VBK` test is gone; the 7.0 release's patches were replaced in
> place with the fix. [cgb-mode.md](cgb-mode.md)'s claim that `VBK` reads
> `$FF` in DMG compatibility mode was wrong the same way.

`THEME` is WRAM `$DBF7` (vars.h), cleared at boot with the rest of WRAM.
Custom adds `CUST_RGB` (`$DBE4`-`$DBE9`, the colors as read), `CUST_OK`
(`$DBEA`) and `CUST_RAMP` (`$DB58`-`$DB5F`, the four colors).
(It was `$DB58` at first, which is `LastRomName`'s copy of the second
marquee line's state: the BACKUPSAVE prompt's `Played` line overwrote it,
so the rest of that prompt drew in light-theme colors, black paper and a
stray white column on the dark box.)

Bank 1 would have been the natural home (mapped at boot), but its free space
starts at `$7391` in 0731, `$75F3` in 0918 and `$672A` in 1.04e, and the mod
places each block at the same address in every kernel, which leaves nothing
in bank 1 that fits. Bank 2 is byte-identical in all three stock kernels.

### SET tab

> Since 2026-11-10 the button is on the SET tab's third page, row 2, after
> `THEME:`, cursor row 14 ([fastlaunch-set-tab.md](fastlaunch-set-tab.md#pages));
> from 2026-10-30 it was on the second. The rest of this section is how it
> was first built.

The `UI:` row (row 14) holds two buttons: `THEME` and the 8px/12px one. The
theme name is right-aligned in columns 7-12 in 8px; in 12px it starts at
x 45 in a box (40,111)-(108,124), wide enough for `PURPLE`. The cursor gains
a row between PICK ROM and UI: 0 TIME SET, 1 RTC, 2 AUTO SAVE, 3 FAST LAUNCH,
4 PICK ROM, 5 THEME, 6 UI, 7 SGB BOOT (8 TAGS since
[browser-tags.md](browser-tags.md)). The clamp at `04:5604` was
`d6 07`, and RIGHT (`FlSetJumpBottom`, `04:5f90`) goes to row 7
([fastlaunch-set-tab.md](fastlaunch-set-tab.md)). A on THEME changes the
whole screen at once; from the last theme it wraps to light.

### Popups

The status boxes (`Reading...`, `Loading...`, `Error file`), the START
overlay, the BACKUPSAVE and RTC prompts, the ROM menu, the save manager and
the too-many-files notice are drawn in colors 0 and 3 like everything else,
so in a dark theme a popup came out as the background itself (a black box on
black) and a status box as a white one. In a dark theme they now use a
lighter shade of the background with white text:

- `PopupDrawParams(ink, paper)` (`00:0290`,
  [popup_params.c](../kernel/src/popup_params.c), 37 B, in the room
  `CgbInit` left) is `StoreDrawParams(ink, paper, 0)`, except that in any
  theme past 0 color 0 becomes color 1: the background blended 20% toward
  white. Each popup's drawing goes through it; erasing a popup back to the
  screen still calls `StoreDrawParams`. Every one of those blocks got
  smaller, since the call takes one argument less.
- The status boxes draw white on color 1 in a dark theme (ink 0 on paper 3,
  stock, in light). `MsgBox` (msgbox.c) draws them in both UI modes: the
  `jr nz` in `MsgHookReading` / `Loading` / `Error` (`08:7e13`, `7e27`,
  `7e3b`) is a `jr`, so 8px no longer runs the stock drawer.
- The name band and a selected row stay a white bar; their text, color 0 on
  3, becomes color 1 on white.

Light is unchanged. On a DMG, where a dark theme is the inverted palette,
color 1 is the dark gray, so a popup is white text on dark gray.

## Stage1

[video.c](../stage1/src/video.c) keeps no theme table. Before its first frame
it reads the mark and, for any theme past 0, overlays the four colors the
kernel left after it onto its light palettes: the background and ink of all
three palettes (text, icon, wordmark), the text's two middle shades and the
icon's frames. The orange screen and the Jr. brush stay. `BGP` is `$1B` for
every dark theme. A new theme needs no stage1 change; stage1 is 18,419 of
18,432 BRAM bytes.

## Games

A game should never see the theme: a kernel launch is a console reset that
runs the boot ROM again ([cgb-mode.md](cgb-mode.md)), which sets its own
palettes, and stage1's fast launch is the same launch
([game.c](../stage1/src/game.c)). To confirm on hardware with a game that
never writes `BGP`.

## DV

Theme 7, an homage to davidesqalv's
[ezgb-dv](https://github.com/davidesqalv/ezgb-dv) fork: its 12px glyph set
(Tamzen 6x12 and his icons, glyph set 1, [font12.md](font12.md#glyph-sets))
and its colors. The button steps light, dark, DV, red, green, purple, blue,
custom; DV keeps number 7 so the numbers already in people's `EZGB.CFG` keep
their meaning. Its colors are `dv_ramp` in
[theme_pick.c](../kernel/src/theme_pick.c), which `theme_ramp` returns for 7.

**Colors.** Black, lime `#7BFF31`, blue `#0063C5` and white, as color indices
0 to 3. The kernel draws normal text white on black (ink 3, paper 0) and
highlights black on white (ink 0, paper 3), the same index for both, so a
palette alone cannot make the highlight lime. With DV, `StoreDrawParams`
(`00:2791`) ends in `DvParams` (`00:3fe4`, [dv_params.c](../kernel/src/dv_params.c)):
a stored paper of 3 becomes 1, and an ink of 3 on that paper too. So the
selection bar, the active tab, the hold-A menu's name band, the rules and the
checkbox ticks are lime and black, white text on black is untouched, and
nothing is drawn twice. Popups stay black with their white frame
(`PopupDrawParams` gives dark's lighter popup to dark only).

**Both firmwares, one look.** On a color console in CGB mode (the firmware
mod's stage1) the four colors are DV's row of `theme_ramps.c`. On stock
firmware the console runs the kernel in DMG compatibility mode, where only
`BGP` counts: DV sets `$27` (index 0 black, 1 light, 2 dark, 3 white), and a
GBC's boot ROM gives an unknown DMG game white, lime, blue and black, so a
stock-firmware GBC shows nearly the same lime and blue. A DMG shows the same
layout in four grays, with a light-gray selection bar that black text stays
readable on.

**Blue icons.** On a normal row (white on black) the 12px renderer draws
the row's leading icon, the browser's folder, cart, star, `.sav` or `?` at
x 0, in color 2: it also ORs the icon into a two-tile mask and clears plane 0
under it when the row is written (`draw12.c`), so the row is still one pass
and nothing flashes. A selected row (black on lime) keeps a black icon, as
in his fork. Blue on the firmware mod, the boot ROM's blue on a
stock-firmware GBC, dark gray on a DMG.

The renderer's fast path kept only plane 0 of an edge tile it partly
covered, which turned lime pixels next to a label white (the SET tab beside
HELP); since 2026-10-31 edge tiles go through its per-plane read-modify-write
([font12.md](font12.md)).

DV's glyph set is 12px only, so the theme decides the font: the SET tab's
FONT button reads `SLIM` while DV is on (DV's letters are SLIM's; it read `AUTO` until 2026-11-10), grayed like the color rows DV locks, and the cursor passes over it. Stepping
the THEME button onto or off DV draws the tab strip and the pane again in the
new glyphs, as the FONT button does (what is on screen keeps the glyphs it was
drawn in); onto DV in 8px mode it also switches to 12px (saved as `UI=12`), and a card whose `EZGB.CFG` says `THEME=7` with
`UI=8` comes up in 12px anyway (`cfg_load`). Leaving DV keeps 12px; FONT
switches back as before. Any later theme with one font can do the same.

## Adding a theme

A new theme goes after DV, so the numbers in people's `EZGB.CFG` keep their
meaning.

1. `THEME_COUNT` in [vars.h](../kernel/src/vars.h) (at most 10 themes:
   `THEME=` is one digit), and the literal `THEME_COUNT` compare in
   [theme_colors.c](../kernel/src/theme_colors.c) (asm).
2. Its colors in [theme_pick.c](../kernel/src/theme_pick.c)'s `theme_ramp`
   (asm): [theme_ramps.c](../kernel/src/theme_ramps.c)'s rows end at custom's
   number, so a later theme gets its own row, as DV's `dv_ramp` is.
3. A name, six characters wide, at the end of `theme_names` in
   [themepage.c](../kernel/src/themepage.c), and its place in the button's
   order there (`theme_step`: light, dark, DV, red .. custom), which is not
   the number order.
4. Its own glyph set, if any: a sheet, a set in `scripts/inject-font12.sh`,
   and the set's choice in `draw12.c` and `layout12.c`.

Then re-inject the blocks and `EzCfg` (its `THEME=` check lets custom
through only with `COLORS=`, and lets DV through), port and regenerate the
patches. Stage1 and DMG need nothing.

## Testing

SameBoy, `--model cgb` and `--model dmg`, all three kernels: every theme from
`THEME=<n>` in 8px and 12px, the mark and colors written to pSRAM for each,
the file winning over a stale mark, the SET button stepping and wrapping
from BLUE to LIGHT (which drops `THEME=` from the file), and stage1's boot
screen from the pSRAM the kernel wrote. Not yet tested on hardware.

Custom (2026-10-30), SameBoy: on 0731, `COLORS=` before and after `THEME=6`,
with `#` and spaces, in 8px and 12px (the 12px `CUSTOM` fits its box), the
START overlay, `--model dmg` (inverted), the saved file and the mark's
colors, the kernel's first boot frames in the mark's custom colors while the
file said light, an 11-digit `COLORS=` (light, and the button skipping
custom); a boot and the SET page on 0918 and 1.04e. Not tested on hardware
or with stage1's boot screen.
