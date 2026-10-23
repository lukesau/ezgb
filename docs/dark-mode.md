# Dark mode: UI themes for the kernel and stage1

[Issue #11](https://github.com/lukesau/ezgb/issues/11). The SET tab has a
`THEME` button on the `UI:` row that cycles the browser, every kernel screen
and our stage1's boot screen through seven themes: light (the stock look),
dark, and five colored ones. On a DMG, or anything else running the kernel in
DMG mode, every theme but light is the inverted palette.

## The themes

| # | Button | Background | Darker mid | Lighter mid | Ink |
|---|---|---|---|---|---|
| 0 | `LIGHT` | `$7FFF` white | `$56B5` | `$294A` | `$0000` black |
| 1 | `DARK` | `$18C6` (49,49,49) | `$254B` (90,82,74) | `$3611` (140,132,107) | `$4AD8` tan (197,181,148) |
| 2 | `BLACK` | `$0000` | `$18C6` | `$4631` | `$7FFF` white |
| 3 | `RED` | `$0428` (66,8,8) | `$1CED` | `$4A55` | `$7FFF` |
| 4 | `GREEN` | `$0D22` (16,74,25) | `$25A8` | `$4EB2` | `$7FFF` |
| 5 | `PURPLE` | `$3048` (66,16,99) | `$410D` | `$5E55` | `$7FFF` |
| 6 | `BLUE` | `$30A2` (16,41,99) | `$4148` | `$5E92` | `$7FFF` |

Dark is aimed at OLED screens: a dim gray background and a grayish tan ink
rather than white. The colored themes have white ink, and their two middle
shades are the background blended 20% and 56% toward white. Green, purple
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

## Where the setting lives

Two copies, because the first frames are drawn before the SD card is read:

- **`EZGB.CFG` `THEME=<n>`**, the source of truth ([ezgb-cfg.md](ezgb-cfg.md)).
  Written only when the theme is not 0. A number rather than a name: a key
  with a parsed word value did not fit ezcfg's slot.
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
| `Theme` | `02:43d0`, [theme.c](../kernel/src/theme.c), 294 B | At boot (`CFG_LOADED` 0): `THEME` from the mark. Later: the mark and colors from `THEME`. Then the palette registers, and on a CGB in CGB mode the ramp, each byte written by index and read back in mode 0 or 1, so a call with the LCD on is safe. |
| `ThemeRamps` | `02:4960`, [theme_ramps.c](../kernel/src/theme_ramps.c), 56 B | The colors, data only, 8 bytes per theme; 160 bytes of room. |
| `CgbInit` | `00:0259`, [cgb_init.c](../kernel/src/cgb_init.c), 49 B | The boot LCD-on hook. Its CGB ramp loop is gone: it maps bank 2 by hand (`$2000 = 2`, interrupts are still off, so not through `FarCallTrampoline`, whose `EiNest` would turn them on early), calls `Theme`, maps bank 1 back. |
| `EzCfg` | `02:4a00` | Parses and writes `THEME=`; the boot restore (op 3) calls `Theme` right after its `cfg_load`. The key parser is now table-driven (`cfg_keys`, one `switch`), which took the module from 5010 to 4897 B with the new key. |
| `ThemeRow` | `04:7670`, [theme_row.c](../kernel/src/theme_row.c), 297 B | The SET tab button, near-called by `FlCfg`: op 0/1 draw it plain or highlighted, op 2 steps `THEME` (wrapping), saves `EZGB.CFG` and calls `Theme` through `FarCallTheme_B4` (`04:5990`). |

`THEME` is WRAM `$DB58` (vars.h), cleared at boot with the rest of WRAM.

Bank 1 would have been the natural home (mapped at boot), but its free space
starts at `$7391` in 0731, `$75F3` in 0918 and `$672A` in 1.04e, and the mod
places each block at the same address in every kernel, which leaves nothing
in bank 1 that fits. Bank 2 is byte-identical in all three stock kernels.

### SET tab

The `UI:` row (row 14) holds two buttons: `THEME` and the 8px/12px one. The
theme name is right-aligned in columns 7-12 in 8px; in 12px it starts at
x 45 in a box (40,111)-(108,124), wide enough for `PURPLE`. The cursor gains
a row between PICK ROM and UI: 0 TIME SET, 1 RTC, 2 AUTO SAVE, 3 FAST LAUNCH,
4 PICK ROM, 5 THEME, 6 UI, 7 SGB BOOT. The clamp at `04:5604` is now
`d6 07`, and RIGHT (`FlSetJumpBottom`, `04:5f90`) goes to row 7
([fastlaunch-set-tab.md](fastlaunch-set-tab.md)). A on THEME changes the
whole screen at once; from the last theme it wraps to light.

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

1. `THEME_COUNT` in [vars.h](../kernel/src/vars.h) (at most 10: `THEME=` is
   one digit).
2. A row in [theme_ramps.c](../kernel/src/theme_ramps.c).
3. A name, six characters wide, in `ThemeRow`'s `names`
   ([theme_row.c](../kernel/src/theme_row.c)). The button steps through them
   in order.

Then re-inject the three blocks and `EzCfg` (it compares against
`THEME_COUNT`), port and regenerate the patches. Stage1 and DMG need nothing.

## Testing

SameBoy, `--model cgb` and `--model dmg`, all three kernels: every theme from
`THEME=<n>` in 8px and 12px, the mark and colors written to pSRAM for each,
the file winning over a stale mark, the SET button stepping and wrapping
from BLUE to LIGHT (which drops `THEME=` from the file), and stage1's boot
screen from the pSRAM the kernel wrote. Not yet tested on hardware.
