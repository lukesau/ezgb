# Dark mode: UI themes for the kernel and stage1

[Issue #11](https://github.com/lukesau/ezgb/issues/11). The SET tab has a
`THEME` button on the `UI:` row that switches the browser, every kernel screen
and our stage1's boot screen between light (the stock look) and dark. Dark is
made for OLED screens: a black background, so those pixels stay off, and a
dim, grayish tan ink instead of white. On a DMG, or anything else running the
kernel in DMG mode, dark is the inverted palette.

The mechanics are written for more than two themes: a theme is a number, and
everything that depends on it reads a per-theme table. Further dark themes
(other background colors) are table rows; see "Adding a theme" below.

## What a theme is

| | light (0) | dark (1) |
|---|---|---|
| `BGP`, `OBP0`, `OBP1` | `$E4`, `$E4`, `$1B` (stock) | `$1B`, `$1B`, `$E4` |
| CGB ramp, color index 0..3 | `$7FFF` `$56B5` `$294A` `$0000` | `$0000` `$18E8` `$3611` `$4AD8` |

The kernel draws in color indices only (it wrote `BGP = $E4` once and never
touched a palette again, [cgb-mode.md](cgb-mode.md)), so a theme is nothing
but the four colors those indices draw as. Every theme past 0 is a dark one,
which on a DMG means the inverted `BGP`; on a color console in CGB mode it is
the theme's own ramp, written to all 8 BG and 8 OBJ palettes. The dark ramp
in 8-bit RGB: black, (66,58,49), (140,132,107), (197,181,148).

## Where the setting lives

Two copies, because the first frames are drawn before the SD card is read:

- **`EZGB.CFG` `THEME=1`**, the source of truth ([ezgb-cfg.md](ezgb-cfg.md)).
  Written only when the theme is not 0. A number rather than a name: a key
  with a parsed word value did not fit ezcfg's slot.
- **pSRAM page `$11` `$A414`–`$A417`**: `'T'`, `'H'`, theme, `~theme`
  ([psram-page-map.md](psram-page-map.md)). The kernel rewrites it every time
  it applies the file's theme; the next boot's first frames (stage1's boot
  screen, the kernel's boot) read it. A missing or faded mark (BATTERY DRY)
  is theme 0.

When they disagree (the file was edited on a PC, or the card moved to another
cart), the boot screen and the kernel's first frames use the mark, and the
file's theme takes over at the boot restore, right after `Micro SD initial
OK!`. Stage1 picks it up on the next power-on.

## Kernel

| Block | Address | Does |
|---|---|---|
| `Theme` | `02:43d0`, [theme.c](../kernel/src/theme.c), 269 B | At boot (`CFG_LOADED` 0): `THEME` from the mark. Later: the mark from `THEME`. Then the palette registers, and on a CGB in CGB mode the ramp, each byte written by index and read back in mode 0 or 1, so a call with the LCD on is safe. |
| `CgbInit` | `00:0259`, [cgb_init.c](../kernel/src/cgb_init.c), 49 B | The boot LCD-on hook. Its CGB ramp loop is gone: it maps bank 2 by hand (`$2000 = 2`, interrupts are still off, so not through `FarCallTrampoline`, whose `EiNest` would turn them on early), calls `Theme`, maps bank 1 back. |
| `EzCfg` | `02:4a00` | Parses and writes `THEME=`; the boot restore (op 3) calls `Theme` right after its `cfg_load`. The key parser is now table-driven (`cfg_keys`, one `switch`), which took the module from 5010 to 4897 B with the new key. |
| `ThemeRow` | `04:7670`, [theme_row.c](../kernel/src/theme_row.c), 258 B | The SET tab button, near-called by `FlCfg`: op 0/1 draw it plain or highlighted, op 2 cycles `THEME`, saves `EZGB.CFG` and calls `Theme` through `FarCallTheme_B4` (`04:5990`). |

`THEME` is WRAM `$DB58` (vars.h), cleared at boot with the rest of WRAM.

Bank 1 would have been the natural home (mapped at boot), but its free space
starts at `$7391` in 0731, `$75F3` in 0918 and `$672A` in 1.04e, and the mod
places each block at the same address in every kernel, which leaves nothing
in bank 1 that fits. Bank 2 is byte-identical in all three stock kernels.

### SET tab

The `UI:` row (row 14) holds two buttons: `THEME` (`LIGHT` / `DARK`, columns
8-12) and the 8px/12px one. The cursor gains a row between PICK ROM and UI:
0 TIME SET, 1 RTC, 2 AUTO SAVE, 3 FAST LAUNCH, 4 PICK ROM, 5 THEME, 6 UI,
7 SGB BOOT. The clamp at `04:5604` is now `d6 07`, and RIGHT
(`FlSetJumpBottom`, `04:5f90`) goes to row 7
([fastlaunch-set-tab.md](fastlaunch-set-tab.md)). A on THEME changes the whole
screen at once.

In 12px mode the button is wider to the left (box x 48..108, text from x 53)
because 12px `LIGHT` is about 50 px.

## Stage1

[video.c](../stage1/src/video.c) reads the mark before its first frame and
picks `BGP` (`$1B` for every dark theme) and the three CGB palettes from
`palettes[theme]`: text, icon and wordmark, each with a black background and
the ink and frames from the kernel's ramp. 139 bytes; stage1 is now 18,398 of
18,432 BRAM bytes.

## Games

A game should never see the theme: a kernel launch is a console reset that
runs the boot ROM again ([cgb-mode.md](cgb-mode.md)), which sets its own
palettes, and stage1's fast launch is the same launch
([game.c](../stage1/src/game.c)). To confirm on hardware with a game that
never writes `BGP`.

## Adding a theme

1. `THEME_COUNT` in [vars.h](../kernel/src/vars.h) and `THEMES` in
   [video.c](../stage1/src/video.c).
2. A ramp row in `ramps` ([theme.c](../kernel/src/theme.c)) and a palette set
   in `palettes` ([video.c](../stage1/src/video.c)). DMG needs nothing: any
   theme past 0 is the inverted palette there.
3. A name, five characters wide, in `ThemeRow`'s `names`
   ([theme_row.c](../kernel/src/theme_row.c)). The button cycles through
   them in order.

Space: `Theme` has 35 bytes free after it (8 per ramp row), `ThemeRow` over a
kilobyte, `EzCfg` 223, stage1 34 (24 per palette set, so one more theme
there needs trimming first).

## Testing

SameBoy, `--model cgb` and `--model dmg`, all three kernels: boot dark from
the mark and from `THEME=1`, the file winning over a stale mark both ways,
the mark rewritten after the boot restore, the SET toggle in 8px and 12px
writing `THEME=1` and the mark. Stage1's boot screen in both themes. Not yet
tested on hardware.
