# DMG UI visibility: readable highlight + folder icon

Requested in [issue #2](https://github.com/lukesau/ezgb/issues/2) by
gus33000: on an original Game Boy / Pocket the browser's selected row is
close to unreadable, and directories could use an icon instead of the `DIR`
tag. Both changes are data/immediate-only patches, identical in both 1.05e
kernels (0731 and 0918), with no new code.

## Why the stock highlight is unreadable on a DMG

The kernel draws text through `DrawGlyph` (`00:2701`), a 1bpp blitter that
composes each glyph from two shade numbers held in the draw state written by
`StoreDrawParams` (`00:2791`): `wDrawColor` (`$d734`, the *ink*, glyph
pixels) and `wDrawColorB` (`$d735`, the *paper*, background pixels). `BGP` is
set once to `$E4` (identity) and never changed, so shade N is the DMG's shade
N: 0 white, 1 light gray, 2 dark gray, 3 black.

| Context | Ink | Paper |
|---|---|---|
| Normal row | 3 | 0 |
| Selected row (stock) | 3 | **2** |
| `DIR` tag | 0 | 3 |

Black on dark gray is two adjacent steps of the four-shade ramp. A GBC in
DMG-compat mode spreads those apart with its auto palette, which is why it
looks fine there; an unlit DMG screen does not.

## Change 1: selected row is white on black

The four browser sites that set the highlight ink now push `ink 0, paper 3`
(the same pair the `DIR` tag already used) instead of `ink 3, paper 2`. Each
is a two-byte immediate change (`ld hl, $0002` → `$0003`, `ld a, $03` →
`$00`) ahead of a `call StoreDrawParams`:

| Site | Address | What it highlights |
|---|---|---|
| `DrawBrowserEntries_hilite` | `01:415d` | initial page draw |
| `DrawBrowserDetail_mode3Hilite` | `01:4365` | cursor move, mode 3 |
| `DrawBrowserDetail_afterFocusInk` | `01:4459` | cursor move, mode 2 (also the scroll-repaint shim's path) |
| `DrawDirEntryLabel` | `00:0be7` | the scrolling marquee for names too long to fit |

The trailing `(3, $0000)` reset after each highlighted draw is unchanged, so
nothing downstream sees a different draw state.

### Every other dark-gray site

The same pair was used for every highlight and box in the kernel, so all 26
remaining sites were changed too, with one mapping per role:

| Stock ink/paper | Role | Now |
|---|---|---|
| 3 / 2 | highlighted text, buttons, tab strip, Reading/Loading/error boxes | 0 / 3 (white on black) |
| 1 / 2 | boot-menu BOOT / ROM INFO selection | 0 / 3 |
| 2 / 2 | AUTO SAVE check-mark fill (`04:47d1`, `04:49d0`) | 3 / 3 (solid black) |
| 2 / 2 | checkbox outline while the cursor is on it (`04:4995`) | 1 / 1 (light gray) |

Sites: `BatteryCheck` (`00:1868`, `00:18a8`); `DrawInfoPanelRect`,
`BootRomInfoMenu_hiliteBoot`, `BootRomInfoMenu_romInfoInk`, `BackupSavePrompt`
x2 (bank 1); `DrawTimeAutosaveScreen` and its time-set digit and checkbox
paths (`04:4766`..`04:5635`, 14 sites); the tab-strip drawer's three arms
(`08:71b3`, `08:722e`, `08:72a9`) and `DrawReadingBox`, `DrawLoadingBox`,
`DrawErrorFileBox` (bank 8). All are the same two-byte immediate edit as
above, and all bank 0/4/8 addresses are identical in both kernels.

The two injected C shims followed suit at source level and were re-injected:
`flcfg.c` (PICK button 0/3, checkbox outline 1/1, check mark 3/3) and
`flpick_banner.c` (0/3). SDCC emits `xor a` for the zero ink where it used
`ld a, $03`, so each blob is 2 bytes shorter (`FlCfg` `$4ea`, `FlPickBanner`
`$40`); the freed tail bytes were restored to stock.

The checkbox outline keeps its stock "dimmed while selected" idea but in light
gray, which is two ramp steps from the normal black outline instead of one.

## Change 2: icon column on the left, `DIR` tag back on the right

Every browser row now starts with one icon glyph in column 0 and the name in
columns 1 onward, one column narrower than stock (16 for directories, 19 for
files). Directories keep the stock text `DIR` tag in columns 17-19, drawn in
the row's ink (stock forced inverse video there; those three
`call StoreDrawParams` sites, `01:4207`, `01:43f8`, `01:4508` at +8, are
NOPed and the shim no longer sets it), so the tag reads black on white on a
normal row and white on black inside the selection bar.

### Glyphs

`DrawGlyph` reads glyphs straight from the 256-entry 1bpp sheet at `$3206`
(8 bytes per code, `$3206 + code*8`; CP437-shaped with Hebrew letters in
`$C0-$DF`). No English UI string uses that block, so five codes were
repurposed, labelled `FolderIconGlyphs` in `kernel.sym`:

| Code | ROM | Glyph |
|---|---|---|
| `$C0` | `00:3806` | folder, square-cornered tab at top-left |
| `$C1` | `00:380e` | `.gb` cartridge (placeholder: outline with a label band) |
| `$C2` | `00:3816` | `.gbc` cartridge (placeholder: outline with a checkered label) |
| `$C3` | `00:381e` | boxed `?` for any other file type |
| `$C4` | `00:3826` | `.sav` page (dog-eared top-right corner) |

Rows: `F0 90 FF 81 81 81 FF 00`, `7E 81 B5 B5 81 81 7E 00`,
`7E 81 A9 95 A9 81 7E 00`, `7E 99 A5 89 81 89 7E 00`, `F8 8C 8E 81 81 81 FF 00`.
Redraw any of them by writing 8 bytes at those
offsets. Bit 0 of each row is the pixel next to the name's first letter, so
leaving it clear gives a 1px gap.

Caveat: a filename containing bytes `$C0`-`$C3` (Hebrew alef to dalet in
this font) shows an icon in that position.

### `DrawNameWithIcon` (`00:3ec8`, [decomp/src/browser_icons.c](../decomp/src/browser_icons.c), 254 B)

The six stock name draws are one `DrawString(name, len, 0, row)` each, with
`len` 0 for directories (the 17-wide default) and `$14` for files. They now
call a wrapper with the same stack convention instead, so each site is a
3-byte `call` retarget and no stock code grows. The wrapper picks the glyph
(folder when `len` is 0, else by extension: `.gb`, `.gbc`, case-insensitive,
anything else the boxed `?`), draws it at column 0 with `DrawString`, then draws
the name at column 1 with `len` 16 or `len-1`. It draws in whatever ink the
row has, so the icon inverts with the selection bar. It lives in the free
tail of the `00:3d8c` cave, after `BrowserScrollDownRepaint`.

| Site | Address | Was |
|---|---|---|
| `DrawBrowserEntries` dir / file | `01:4202` / `01:424e` | `call DrawString` |
| `DrawBrowserDetail` entry0 dir / file | `01:43f3` / `01:443d` | `call DrawString` |
| `DrawBrowserDetail` entry1 dir / file | `01:4503` / `01:454d` | `call DrawString` |
| `browser_scroll_repaint.c` dir / file | in the shim | `DrawString(rec, ...)` |

The long-name marquee (`DrawDirEntryLabel`, `00:0be7`) redraws only the name,
so its field widths moved with it: `00:0c87` `$11` to `$10`, `00:0c8e` `$14`
to `$13`, and its `DrawString` x at `00:0dcc` `0` to `1`. The icon drawn by
the row painter stays put.

```sh
cd decomp
python3 tools/inject.py src/browser_icons.c $V 0 3ec8 DrawNameWithIcon --pin DrawString=08b7 --apply
python3 tools/inject.py src/browser_scroll_repaint.c $V 0 3d8c BrowserScrollDownRepaint \
    --pin browser_scroll_down=01e3 --pin FarCallDrawDetailBottom=03dc --pin DrawString=08b7 \
    --pin StoreDrawParams=2791 --pin DrawNameWithIcon=3ec8 --apply
```

`inject.py` places the first-defined function at the origin, so the wrapper
must stay the first definition in the file (the `up()` helper is prototyped
above it and defined below).

## Change 3: the selection bar spans the whole row

Stock `DrawString` pads a short string with spaces up to `len` (or 17 when
`len` is 0), and before the first padding space it calls
`StoreDrawParams(3, 0)`, so the padding is always drawn in normal ink and the
highlight band stopped at the end of the name. That call (`00:0912`, 3 bytes)
is now NOPed; the surrounding push / `add sp` stay balanced. Padding inherits
the current ink, so a selected file row (name field 20 wide) and a selected
directory row (17 wide, then the tag) are black edge to edge.

This is a global change to a primitive with ~86 callers, so every highlight
site was checked: apart from the browser, all of them draw strings at their
exact length (tab labels, `SET`/`PICK`, the time digits, the prompt and box
strings), so the reset never fired for them. The one padded highlight,
`BootRomInfoMenu` (`01:62d0`, `len 0`), has no callers anywhere in the ROM.
Both browser painters (`DrawBrowserEntries` per-row epilogue,
`DrawBrowserDetail` focus/drawSize resets) restore normal ink explicitly, so
nothing leaks into following rows. The long-name marquee
(`DrawDirEntryLabel`) always draws exactly `width` characters.

## Verification

SameBoy with the EZ Jr stub, `--model dmg` (the run script's default `cgb`
hides the problem):

```sh
./scripts/run-sameboy-debug.sh --model dmg
```

Checked in the emulator: browser selection on boot, after cursor moves, and
after scrolling past the first page (rows painted by the repaint shim), the
bar spanning the full row in each case; the icon column (folder, .gb, .gbc,
boxed ?) on normal rows, inverted on the selected one, and on rows painted by
the repaint shim; the long-name marquee scrolling from column 1; the SD/SET/HELP tab strip;
the SET button, PICK button and both checkboxes on the SET tab; the PICK A
ROM banner; the Loading box.

Real hardware: the highlight change, the folder icon, and the full-width
selection bar are all confirmed on a real Jr (mod 2.8).
