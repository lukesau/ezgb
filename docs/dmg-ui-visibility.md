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

## Change 2: folder icon instead of `DIR`

`DrawGlyph` reads glyphs straight from the 256-entry 1bpp sheet at
`$3206` (8 bytes per code, `$3206 + code*8`; the sheet is CP437-shaped with
Hebrew letters in `$C0-$DF` where CP437 has box drawing). No English UI
string uses that block, so three of its codes were repurposed:

| Code | ROM | Glyph |
|---|---|---|
| `$C0` | `00:3806` | blank |
| `$C1` | `00:380e` | left 4px blank, then the left half of the folder |
| `$C2` | `00:3816` | right half of the folder, then 4px blank |

The folder is an 8x7 outline with a square-cornered tab at top-left, split
down the middle so it sits centred across the last two columns with 4px of
padding on each side. Labelled `FolderIconGlyphs` in `kernel.sym`; the rest
of the block is stock.

The three copies of the tag string (`BrowserDirStr` `01:42b6`,
`BrowserDirStr2` `01:45af`, and `dir_tag` inside the injected
`browser_scroll_repaint.c` shim at `00:3e27`) changed from `"DIR",0` to
`$C0,$C1,$C2,0`: a blank in column 17, then the two folder halves. The
`DrawString(ptr, len 3, col $11, row)` calls are untouched.

**The tag inherits the row's ink.** Stock forced inverse video (ink 0,
paper 3) before drawing `DIR` and reset afterwards. The forced set is now
NOPed at the three stock sites (`01:4207`, `01:43f8`, `01:4508`, the
`call StoreDrawParams` at +8) and removed from the shim, so the glyphs are
stored as plain bitmaps: black folder on white on a normal row, and white on
black on the selected row without any per-row logic. The trailing
`(3, $0000)` resets are unchanged.

Caveat: a filename containing bytes `$C0`-`$C2` (Hebrew alef/bet/gimel in
this font) now shows a blank or half a folder in those positions.

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
bar spanning the full row in each case; folder icons on unselected directory
rows and inverted on the selected one; the SD/SET/HELP tab strip;
the SET button, PICK button and both checkboxes on the SET tab; the PICK A
ROM banner; the Loading box.

Real hardware: the highlight change, the folder icon, and the full-width
selection bar are all confirmed on a real Jr (mod 2.8).
