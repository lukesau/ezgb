# Dark mode: UI themes for the kernel and stage1

[Issue #11](https://github.com/lukesau/ezgb/issues/11). The SET tab has a
`THEME` button on the `UI:` row that cycles the browser, every kernel screen
and our stage1's boot screen through six themes: light (the stock look),
dark, and four colored ones, plus a seventh, custom, whose two colors are set
by hand in `EZGB.CFG` (see [Custom](#custom)). On a DMG, or anything else
running the kernel in DMG mode, every theme but light is the inverted
palette.

## The themes

| # | Button | Background | Darker mid | Lighter mid | Ink |
|---|---|---|---|---|---|
| 0 | `LIGHT` | `$7FFF` white | `$56B5` | `$294A` | `$0000` black |
| 1 | `DARK` | `$0000` black | `$18C6` | `$4631` | `$7FFF` white |
| 2 | `RED` | `$0428` (66,8,8) | `$1CED` | `$4A55` | `$7FFF` |
| 3 | `GREEN` | `$0D22` (16,74,25) | `$25A8` | `$4EB2` | `$7FFF` |
| 4 | `PURPLE` | `$3048` (66,16,99) | `$410D` | `$5E55` | `$7FFF` |
| 5 | `BLUE` | `$30A2` (16,41,99) | `$4148` | `$5E92` | `$7FFF` |
| 6 | `CUSTOM` | `COLORS=` | 3/16 toward ink | 9/16 toward ink | `COLORS=` |

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

## Custom

Since 2026-10-30. One line in `EZGB.CFG` sets the background and the ink
(text), in web hex, the format every color picker gives:

```
THEME=6
COLORS=1E2A44,F2D7A0
```

- The value is read as its first 12 hex digits, so `#1E2A44, #F2D7A0` and
  lower case work too. Fewer than 12 and the line is ignored. The kernel
  writes it back as `RRGGBB,RRGGBB`, the 8-bit values as read.
- The console has 5 bits per channel (BGR555, `$7FFF` style, which nobody
  can type), so each channel keeps its top 5 bits: `1E2A44` draws as
  `$20A3`.
- The two middle shades are the background moved 3/16 and 9/16 of the way to
  the ink, about where the built-in dark themes have theirs. Any pair works,
  light or dark: the popups draw on the first middle shade either way.
- `CUSTOM` is in the SET tab's `THEME` cycle only when the file has a valid
  `COLORS=` line; without one, `THEME=6` is light and the button goes from
  BLUE to LIGHT. The two lines can be in either order.
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
| `Theme` | `02:43d0`, [theme.c](../kernel/src/theme.c), 299 B | At boot (`CFG_LOADED` 0): `THEME` from the mark. Later: the mark and colors from `THEME`. Then the palette registers, and on a CGB in CGB mode the ramp, each byte written by index and read back in mode 0 or 1, so a call with the LCD on is safe. |
| `ThemeRamps` | `02:4960`, [theme_ramps.c](../kernel/src/theme_ramps.c), 48 B | The colors, data only, 8 bytes per theme; custom has no row. |
| `ThemeCustom` | `02:4990`, [theme_pick.c](../kernel/src/theme_pick.c), 48 B | `FarCallColors` (8 B), ezcfg's stub to `ThemeColors`, then `theme_ramp` (`02:4998`): the colors for `Theme`, a `ThemeRamps` row or, for custom, `CUST_RAMP`, which it loads from the mark at boot. |
| `ThemeColors` | `05:7b50`, [theme_colors.c](../kernel/src/theme_colors.c), 289 B | Asm. Op 0 parses `COLORS=` into `CUST_RGB` and builds `CUST_RAMP`; op 1 writes the `THEME=` and `COLORS=` lines on a save. |
| `CgbInit` | `00:0259`, [cgb_init.c](../kernel/src/cgb_init.c), 49 B | The boot LCD-on hook. Its CGB ramp loop is gone: it maps bank 2 by hand (`$2000 = 2`, interrupts are still off, so not through `FarCallTrampoline`, whose `EiNest` would turn them on early), calls `Theme`, maps bank 1 back. |
| `EzCfg` | `02:4a00` | Parses `THEME=` (light unless it is one digit naming a theme, and custom only with a valid `COLORS=`) and hands `COLORS=` and the save's two theme lines to `ThemeColors`; the boot restore (op 3) calls `Theme` right after its `cfg_load`. The key parser is now table-driven (`cfg_keys`, one `switch`), which took the module from 5010 to 4897 B with the new key. |
| `PopupDrawParams` | `00:0290`, [popup_params.c](../kernel/src/popup_params.c), 37 B | Popup ink and paper per theme, below. |
| `ThemeRow` | `04:7670`, [theme_row.c](../kernel/src/theme_row.c), 254 B | The SET tab button, near-called by `FlCfg`: op 0/1 draw it plain or highlighted, op 2 steps `THEME` (wrapping, past custom without `COLORS=`), saves `EZGB.CFG` and calls `Theme` through `FarCallTheme_B4` (`04:5990`). |
| `ThemeNames` | `04:7f20`, [theme_names.c](../kernel/src/theme_names.c), 49 B | The button's names, data only, moved out of `ThemeRow` to make room for the seventh. |

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

> Since 2026-10-30 the button is on the SET tab's second page, row 2, after
> `THEME:`, cursor row 7 ([fastlaunch-set-tab.md](fastlaunch-set-tab.md#pages)).
> The rest of this section is how it was first built.

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
  stock, in light). `MsgBox12` now draws them in both UI modes: the
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

## Adding a theme

Custom stays the last theme, so a new one takes its number and pushes it up
one: a card with `THEME=` set to custom then needs that line changed.

1. `THEME_COUNT` and `THEME_CUSTOM` in [vars.h](../kernel/src/vars.h) (at
   most 10 themes: `THEME=` is one digit), and the two literal `6`/`7`
   compares in [theme_pick.c](../kernel/src/theme_pick.c) and
   [theme_colors.c](../kernel/src/theme_colors.c) (asm).
2. A row in [theme_ramps.c](../kernel/src/theme_ramps.c).
3. A name, six characters wide, before `CUSTOM` in
   [theme_names.c](../kernel/src/theme_names.c). The button steps through
   them in order.

Then re-inject the blocks and `EzCfg` (it compares against `THEME_CUSTOM`),
port and regenerate the patches. Stage1 and DMG need nothing.

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
