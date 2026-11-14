# Themes

The SET tab's `THEME` button cycles the browser, every kernel screen and
our stage1's boot screen through light, dark, DV, four colored themes and a
custom one. A goes forward, B back, and both wrap. The choice is saved to
`EZGB.CFG` with the rest of the tab ([fastlaunch-set-tab.md](fastlaunch-set-tab.md)).

Addresses are 1.05e-0731's.

## The stock shades

The kernel draws in four color indices and never touches a palette after
writing `BGP = $E4` once. Text goes through `DrawGlyph` (`00:2701`), which
composes each glyph from an ink and a paper index held in the draw state
that `StoreDrawParams` (`00:2791`) writes (`$d734`, `$d735`).

Stock draws the selected row, and every other highlight and box, as ink 3
on paper 2: black on dark gray. Those are adjacent shades, and an original
Game Boy cannot tell them apart. The stock DMG is the baseline every UI
choice in this mod is checked against: it is both the worst case and the
unmodded case. The mod changes the pair at every site, one mapping per
role:

| Stock ink / paper | Role | Now |
|---|---|---|
| 3 / 2 | highlighted text, buttons, the tab strip, the status boxes | 0 / 3 (white on black) |
| 1 / 2 | the boot menu's BOOT / ROM INFO selection | 0 / 3 |
| 2 / 2 | the AUTO SAVE check mark | 3 / 3 |
| 2 / 2 | a checkbox outline under the cursor | 1 / 1 |

Each site is a two-byte immediate change ahead of a `call StoreDrawParams`.

## The themes

A theme is the four colors those indices draw as:

| # | Button | Background (0) | Popups (1) | Shade 2 | Ink (3) |
|---|---|---|---|---|---|
| 0 | `LIGHT` | white | light gray | dark gray | black |
| 1 | `DARK` | black | `$18C6` | `$4631` | white |
| 2 | `RED` | `$0428` | `$1CED` | accent: sky `#42A5FF` | white |
| 3 | `GREEN` | `$0D22` | `$25A8` | accent: rose `#FF94C5` | white |
| 4 | `PURPLE` | `$3048` | `$410D` | accent: gold `#EFD63A` | white |
| 5 | `BLUE` | `$30A2` | `$4148` | accent: apricot `#FFA56B` | white |
| 6 | `CUSTOM` | from `COLORS=` | 3/16 toward the ink | accent | from `COLORS=` |
| 7 | `DV` | black | accent: lime `#7BFF31` | blue `#0063C5` (icons) | white |

The button's order is light, dark, DV, red, green, purple, blue, custom.
The numbers are what `EZGB.CFG` stores, so DV stays 7 and a new theme goes
after it.

Dark is pure black with white ink, so the pixels of an OLED screen stay
off. In every theme past light, shade 1 is the background blended 20%
toward white.

### Where palettes cannot be written

On a color console in CGB mode the four colors go to all 8 BG and 8 OBJ
palettes. A DMG, and a GBC or GBA running the kernel in compatibility mode
(stock firmware), only have `BGP`: light is the stock `$E4`, DV is `$27`,
and every other theme is the inverted `$1B`, which is dark. `Theme` sets
`PAL_LOCKED` (HRAM `$FFF8`) when its palette write gives up, and the button
then offers only light, dark and DV. A colored theme from the file shows as
`DARK` there and keeps its value until the button is pressed, so a card
moved to a color console keeps it.

## Accents

Every color theme draws its highlights in an accent: the selection bar, the
active tab, the name band of the menus and prompts, the rules between
buttons, the checkbox ticks. Light and dark have none.

The kernel draws a highlight as ink 0 on paper 3 and a rule as a solid fill
of index 3. `StoreDrawParams` ends in `DvParams`
([dv_params.c](../kernel/mod/src/dv_params.c), `00:3fe4`), which moves a
stored paper of 3, and the ink too when it is also 3, to `ACC_IDX` (WRAM
`$DC0B`): 1 in DV, 2 in a color theme, 0 in light and dark, where nothing
moves. White text on the background is untouched, and nothing is drawn
twice. `theme_ramp` sets `ACC_IDX` each time a theme is applied.

The built-in accents were picked from each background's complement and
split complements, then made saturated enough to keep their color through
a GBC screen's washout. Each reads on its background at 5:1 or better.

Where `PAL_LOCKED` is set there is no accent, and a color theme is exactly
dark.

## Custom colors

One line in `EZGB.CFG` sets the background and the text color in web hex,
and optionally the accent:

```
THEME=6
COLORS=1E2A44,F2D7A0
COLORS=000000,FFFFFF,7BFF31
```

- The value is read as its first 12 hex digits, or 18 with an accent, so
  `#1E2A44, #F2D7A0` and lower case work. With fewer than 12 the line is
  ignored.
- The console has 5 bits a channel, so each channel keeps its top 5 bits.
- Shade 1 is the background moved 3/16 of the way to the ink.
- Without a third color the accent is the background's complement at full
  brightness, or the ink when the background is a gray.
- The third color is also DV's highlight in place of its lime: `THEME=7`
  with `COLORS=000000,FFFFFF,FF5FA0` is DV in pink.
- `CUSTOM` is in the button's cycle only when the file has a valid
  `COLORS=` line or the picker has set a color.
- Colors on an unlit GBC screen come out much paler than on a computer
  screen. Pick by trying them on the console.

### The picker

The SET tab's third page sets the three colors on the cart:

```
COLORS:    R   G   B
BG:       [17][ 9][22]
TEXT:     [ 0][ 0][ 0]
ACCENT:   [22][16][10]
```

- The rows show the colors on screen, read back from palette RAM, 0 to 31
  a channel.
- A on a row starts setting it: LEFT and RIGHT pick the channel, UP and
  DOWN change it, A or B ends. Every step applies, so the screen is the
  preview.
- The first change made in a built-in theme copies that theme's three
  colors to the custom one and switches THEME to `CUSTOM`. Red with a
  darker background is: pick `RED`, turn BG down.
- In DV only the accent row can be set. It sets DV's highlight and leaves
  DV on.
- Saved as `COLORS=RRGGBB,RRGGBB,RRGGBB`. A channel the picker set is its
  5 bits widened to 8; one it did not touch keeps the file's digits.
- Where palette RAM is locked the picker is not shown.

## DV

Theme 7 is an homage to davidesqalv's
[ezgb-dv](https://github.com/davidesqalv/ezgb-dv) fork: its 12px glyph set
(Tamzen 6x12 and his icons, [font12.md](font12.md#glyph-sets)) and its
colors, black, lime, blue and white.

- **The font follows the theme.** DV's glyph set is 12px only, so stepping
  onto DV switches to 12px, the FONT button reads `SLIM` and the cursor
  passes over it. A card whose file says `THEME=7` with `UI=8` comes up in
  12px.
- **Blue icons.** On a normal row the 12px renderer draws the row's leading
  icon in index 2, by clearing plane 0 under it as the row is written. A
  selected row keeps a black icon.
- **Stock firmware.** In compatibility mode DV sets `BGP = $27`, and a
  GBC's boot ROM gives an unknown DMG game white, lime, blue and black, so
  a stock-firmware GBC shows nearly the same colors. A DMG shows the layout
  in four grays.

## Popups

The status boxes, the START overlay, the prompts, the ROM menu and the
save manager are drawn in indices 0 and 3 like everything else, so in a
dark theme a popup would be a black box on black. Each popup's drawing goes
through `PopupDrawParams(ink, paper)` (`00:0290`,
[popup_params.c](../kernel/mod/src/popup_params.c)), which is
`StoreDrawParams` except that in any theme past light index 0 becomes
index 1. Erasing a popup back to the screen still calls `StoreDrawParams`.

## Where the setting lives

Two copies, because the first frames are drawn before the SD card is read:

- **`EZGB.CFG`**, `THEME=<n>` and `COLORS=`, the source of truth
  ([ezgb-cfg.md](ezgb-cfg.md)). `THEME=` is written only when the theme is
  not 0.
- **pSRAM page `$11`, `$A414`-`$A41F`**: `'T'`, `'H'`, theme, `~theme`,
  then the four colors ([psram-page-map.md](psram-page-map.md)). The kernel
  rewrites it whenever it applies the file's theme, and the next boot's
  first frames read it. A missing or faded mark is theme 0.

When they disagree, stage1's boot screen and the kernel's first frames use
the mark, and the file's theme takes over once the card is mounted.

Stage1 ([video.c](../stage1/src/video.c)) keeps no theme table. It reads the
mark and overlays the four colors onto its light palettes, so a new theme
needs no stage1 change.

A game never sees the theme: a launch is a console reset that runs the boot
ROM, which sets its own palettes, unless the boot ROM is skipped
([skip-boot-rom.md](skip-boot-rom.md)).

## The code

| Block | Where | Does |
|---|---|---|
| `Theme` | `02:43d0`, [theme.c](../kernel/mod/src/theme.c) | At boot, the theme from the mark; later, the mark from the theme. Then the palette registers. Each palette byte is written and read back, and after 8 failed tries it gives up and sets `PAL_LOCKED`: palette RAM takes writes only in CGB mode |
| `ThemeRamps` | `02:4960`, [theme_ramps.c](../kernel/mod/src/theme_ramps.c) | The colors, 8 bytes a theme, for themes 0 to 5 |
| `ThemeCustom` | `02:4990`, [theme_pick.c](../kernel/mod/src/theme_pick.c) | `theme_ramp`: the colors for `Theme`, from `ThemeRamps`, from `CUST_RAMP` for custom, or DV's row |
| `ThemeColors` | `05:7b50`, [theme_colors.c](../kernel/mod/src/theme_colors.c) | Assembly. Parses `COLORS=` and writes the `THEME=` and `COLORS=` lines on a save |
| `CgbInit` | `00:0259`, [cgb_init.c](../kernel/mod/src/cgb_init.c) | The boot hook. Maps bank 2 by hand, since interrupts are still off, and calls `Theme` |
| `ThemePage` | `0D:4000`, [themepage.c](../kernel/mod/src/themepage.c) | The SET tab's third page: the THEME and FONT buttons and the picker |

## Adding a theme

1. `THEME_COUNT` in [vars.h](../kernel/mod/src/vars.h) (at most 10:
   `THEME=` is one digit), and the same number in the compare in
   [theme_colors.c](../kernel/mod/src/theme_colors.c).
2. Its colors in `theme_ramp` in
   [theme_pick.c](../kernel/mod/src/theme_pick.c). `ThemeRamps` ends at
   custom's number, so a later theme gets its own row, as DV has.
3. A name, six characters wide, at the end of `theme_names` in
   [themepage.c](../kernel/mod/src/themepage.c), and its place in the
   button's order there (`theme_step`).
4. Its glyph set, if it has one: a sheet, a set in
   `scripts/inject-font12.sh`, and the set's choice in `draw12.c` and
   `layout12.c`.

Then rebuild the blocks, port, and cut the patches
([DEVELOPMENT.md](DEVELOPMENT.md#changing-the-mod)). Stage1 needs nothing.
