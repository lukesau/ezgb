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

### Other screens that still use the dark-gray pair

26 more `ink 3, paper 2` sites exist outside the browser: the `SD/SET/HELP`
tab bar and `BatteryCheck` (bank 0), `DrawInfoPanelRect`,
`BootRomInfoMenu_*` and `BackupSavePrompt` (bank 1), the
`DrawTimeAutosaveScreen_*` settings pages (bank 4), and the
`DrawFwVersionScreen` / `Reading` / `Loading` / error boxes (bank 8). They
are left stock in this change. If they should follow, the cleanest route is
one remap inside `StoreDrawParams` (a cave + `jp`, since the stock body has
no spare bytes) rather than 26 more two-byte edits.

## Change 2: folder icon instead of `DIR`

`DrawGlyph` reads glyphs straight from the 256-entry 1bpp sheet at
`$3206` (8 bytes per code, `$3206 + code*8`; the sheet is CP437-shaped with
Hebrew letters in `$C0-$DF` where CP437 has box drawing). No English UI
string uses that block, so two of its codes were repurposed:

| Code | ROM | Glyph |
|---|---|---|
| `$C0` | `00:3806` | blank |
| `$C1` | `00:380e` | left 4px blank, then the left half of the folder |
| `$C2` | `00:3816` | right half of the folder, then 4px blank |

The folder itself is an 8x7 outline with a tab at top-left, split down the
middle so it sits centred across the last two columns with 4px of padding on
each side. Labelled `FolderIconGlyphs` in `kernel.sym`; the rest of the block
is stock.

The three copies of the tag string (`BrowserDirStr` `01:42b6`,
`BrowserDirStr2` `01:45af`, and `dir_tag` inside the injected
`browser_scroll_repaint.c` shim at `00:3e27`) changed from `"DIR",0` to
`$C0,$C1,$C2,0`: a blank in column 17, then the two folder halves. The
`DrawString(ptr, len 3, col $11, row)` calls and their surrounding
`StoreDrawParams(0, 3)` / `(3, 0)` bracket are untouched.

**Why the glyphs are stored complemented.** The tag is only ever drawn under
that inverse ink (ink 0, paper 3: set bits render white, clear bits black).
Storing the bitmap inverted makes it come out as a black folder on the white
background, and an all-ones glyph renders as a plain white space. This keeps
the change data-only; the alternative was flipping the ink at all three draw
sites plus re-injecting the shim.

Caveat: a filename containing bytes `$C0`-`$C2` (Hebrew alef/bet/gimel in
this font) now shows a blank or half a folder in those positions.

## Verification

SameBoy with the EZ Jr stub, `--model dmg` (the run script's default `cgb`
hides the problem):

```sh
./scripts/run-sameboy-debug.sh --model dmg
```

Checked: selected row white on black on boot, after cursor moves, and after
scrolling past the first page (rows painted by the repaint shim); folder
icons on both selected and unselected directory rows.

Not yet checked on real hardware.
