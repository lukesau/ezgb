# The file browser

What the mod changes in the SD tab's file list: it is sorted, clutter is
hidden, names are cleaned up, every row has an icon, and moving around is
faster. Stars and play counts are in [stars.md](stars.md), the hold-A menu
in [rom-menu.md](rom-menu.md), and the colors in [themes.md](themes.md).

Addresses are 1.05e-0731's.

## How the stock browser holds a folder

`DirList` (`00:0a43`) reads a folder with FatFs and stores one 255-byte
record per entry in save pSRAM: page `$12 + (index >> 5)` (FPGA page `$03`),
32 records to a page, the NUL-terminated name at +0 and the attribute byte
(`$10` directory, `$20` file) at +`$fe`. The count is at `$c2a2` and the
end-of-directory latch at `$c5a4`. Stock reads 16 entries at a time as the
list scrolls, in the order they sit in the FAT.

The browser's cursor state is three slots in `FileBrowserEntry`'s stack
frame: a dirty flag, the first row shown and the selected row
([shims.md](../kernel/mod/src/shims.md) has the layout).

## Sorting

Folders first, then files, each group by name without regard to case. The
Omega's kernel does the same; the Jr never got it.

`BrowserSortAll` ([browser_sort.c](../kernel/mod/src/browser_sort.c),
`08:746b`) replaces the browser's first `call DirList` (`00:102f`, through
the stub `BrowserSortAllStub` at `00:03d4`). Bubble-sorting 255-byte records
across banked pSRAM would take minutes, so it sorts keys and moves each
record once:

1. **Enumerate everything**, calling `DirList` until the end latch sets.
   The rest of the browser honors the latch and the count, so it works
   unchanged on the full list.
2. **Build a 16-byte key per entry** on pSRAM page `$1F`: a class byte, 13
   upper-cased name characters and the original index. The class is 0 for a
   folder, 1 for a starred file and 2 for any other, and with SORT BY PLAYS
   on the play count goes in byte 1 ([stars.md](stars.md)).
3. **Heapsort the keys.** The compare is the first 14 bytes; a tie falls
   back to a full caseless compare of the two names.
4. **Apply the permutation in one cycle walk**, so each record is copied
   once.

Opening a folder therefore reads all of it up front, where stock deferred
the tail to the first scroll past the last page.

### The 416-entry cap

Records occupy pages `$12` to `$1E` and the keys page `$1F`, and the cart
keeps only 5 bits of the page number ([psram-page-map.md](psram-page-map.md)).
A 417th record would land on the keys, a 449th on game save RAM, and
later ones on the kernel's own records. Stock has no cap, and on stock a
folder of more than 448 entries overwrites saves.

The cap is in `BrowserHideName`, which `DirList` calls for every entry just
before storing it, so it is ahead of every record write. When 416 entries
are already listed and another would be shown:

1. It zeroes the current sector of `DirList`'s FatFs `DIR` object (`sect`,
   at `$ca03`), which is how FatFs marks the end of a directory, and
   returns "hide". The next `f_readdir` comes back empty without touching
   the card, and `DirList` sets its end latch as at a real end.
2. It sets `LIST_CUT` (`$DBFA`), and the sort is skipped: a cut list stays
   in FAT order, because a sorted selection of whatever came first on the
   card would look complete when it is not.
3. It draws `Too many files. Showing first 416` over the `Reading...` box
   for about 2 seconds.

A hidden entry past the cap does not end the directory, so a folder of
exactly 416 games plus macOS sidecars is listed whole.

## What is hidden

`BrowserHideName` ([browser_hide.c](../kernel/mod/src/browser_hide.c),
`05:7700`) hides an entry, file or folder, when its name:

- starts with `.` (macOS sidecars such as `._Tetris.gb`, `.DS_Store`,
  `.fseventsd`) or with `_`
- ends in `.gba`, `.nds`, `.sav`, `.esv` or `.dat` (kernels; a card can
  carry several for the [kernel picker](kernel-picker.md))
- is `EZGB.CFG`, `FLAUNCH.CFG` or `SAVER`
- is in the card's list, below

The tests ignore case, since 8.3 names come back upper case and long names
keep the case they were written in. The SET tab's ROM picker runs over the
same filtered list, so the settings file can never be picked. Manage saves
reads `SAVER/` with `f_readdir` directly, not through `DirList`, so hiding
`.sav` files does not affect it.

### The card's list: `/.ezgbhide`

A plain text file in the card root, one name to a line, any case, CRLF or
LF:

```
# folders other carts use
RTS
IMGS
*.bak
```

- A plain name hides a file or folder with exactly that name, in any
  folder.
- `*` and an ending hides every name with that ending.
- `#` starts a comment. Blank lines and spaces around a name are skipped.

Only the first 512 bytes are read. `HideLoad`
([hide_list.c](../kernel/mod/src/hide_list.c), `0E:5000`) is far-called by
`BrowserSortAll` through `HideLoadFar` (`08:7b80`) before every listing. It
packs the file into the loader's 512-byte scratch at `$C0A0`, in the same
shape as the built-in table, behind the mark `'H'`, `'L'`. That scratch
belongs to whatever ran last (the loader, the save manager, the text
viewer), which is why the list is packed again for each listing and never
kept. The cost is one open, read and close per folder.

### Why the hook is where it is

Stock `DirList` has a dotfile test (`DirList_skipDot`, `00:0a8b`), but it
tests the first byte of the 8.3 short name, which can never be a dot:
`._Foo.gbc` is `_FOO~1.GBC` there. The long name is resolved afterwards.
Stock has no extension test at all, only a compare against `ezgb.dat`.

Names such as `EZGB.CFG` are valid 8.3 names and have no long name, so the
filter has to see both paths. `DirListHideNameStub` (`00:04ae`, reached by
`jp` from `00:0a9d`) sits where the two branches join, with `BC` holding
whichever name the entry will use:

```asm
DirListHideNameStub:       ; NZ means BC already holds the long name
    jr nz, .have
    ld bc, $c9e4           ; no long name: use the 8.3 one
.have:
    push bc                ; kept for DirList_bankSlot
    push bc                ; argument
    call FarCallTrampoline
    db $00, $77, $05, $00  ; BrowserHideName
    add sp, $02
    pop bc
    ld a, e                ; 1 = hide
    or a
    jp nz, DirList_readdir ; hidden: drop the entry
    jp DirList_bankSlot    ; kept: continue as stock
```

## Clean names

With `CLEAN UP NAMES` ticked on the SET tab, the default,
`Tetris (World) (Rev 1).gb` and `Tetris.gb` both show as `Tetris`.

The name as drawn is cut at the first ` (` or ` [`, or, when it has neither,
at its last `.`, with blanks before the cut dropped. No-Intro and GoodTools
both keep parentheses and brackets out of the title itself, so no list of
tags is needed. A name that starts with a tag or a dot is left alone, and a
folder is never cut.

The cut is display only. The record keeps the whole name, so sorting,
launching and the save file's name are unchanged, and two files that differ
only in a tag show the same name. The full name is one hold of A away
([rom-menu.md](rom-menu.md)).

Two places draw a browser name, the row draw and the marquee that scrolls a
selected name too long to fit, and both measure it through one function:

| Block | Does |
|---|---|
| `TagLen` (`05:7a55`, [tagtrim.c](../kernel/mod/src/tagtrim.c)) | The name's length as drawn: the cut when `TAGS_HIDE` is set and the record is not a folder, else `strlen`. Sets `TAG_CUT` |
| `FarCallTagLen` (`00:0408`) | Far stub to `TagLen`. The marquee's `call CStrLen` on the name (`00:0c55`) calls this, so its scroll check and wrap use the short length. The row draw calls it too |
| `TagCat` (`05:7a00`) | Replaces the marquee's far call to `CStrCat_B1` (`00:0d6c`). With `TAG_CUT` set it ends the buffer at the cut before appending the gap |

`TAGS_HIDE` is WRAM `$DBF6` and `TAG_CUT` is `$DAFF`. In `EZGB.CFG` the key
is `TAGS`: `TAGS=0`, or no key, cuts the names, and any other value shows
them in full ([ezgb-cfg.md](ezgb-cfg.md)).

## Icons and the selection bar

Every row starts with one icon in column 0, and the name has columns 1 to
19, for folders and files alike. Stock gave folders 17 columns and a `DIR`
tag in the last three; the tag is gone (its three `StoreDrawParams` and
three `DrawString` call sites in bank 1 are NOPed).

`DrawNameWithIcon` ([browser_icons.c](../kernel/mod/src/browser_icons.c),
`02:7e00`, through the stub at `00:3ec8`) replaces the six stock name
draws. It picks the glyph, draws it, then draws the name beside it in the
row's ink, so the icon inverts with the selection bar.

| Code | Glyph |
|---|---|
| `$C0` | folder |
| `$C1` | `.gb` cartridge |
| `$C2` | `.gbc` cartridge |
| `$C3` | boxed `?`, any other file |
| `$C4` | text page: `.txt`, `.ini`, `.md` (A opens the [text viewer](text-viewer.md)) |
| `$7F` | star, a starred ROM |

The 8px glyphs are in the stock 1bpp sheet at `$3206` (8 bytes a code), in
codes no English string uses (`FolderIconGlyphs`, `00:3806`). A file name
that contains bytes `$C0` to `$C4` shows an icon in that position. The 12px
sets have their own icons ([font12.md](font12.md)).

The selected row is white on black. Stock drew it black on dark gray, two
adjacent shades that an original Game Boy cannot tell apart, and used the
same pair for every highlight and box in the kernel. The mapping that
replaced it everywhere is in [themes.md](themes.md#the-stock-shades).

The bar spans the whole row. Stock `DrawString` pads a short string with
spaces and resets the ink before the first one, so the highlight stopped at
the end of the name. That reset (`00:0912`) is NOPed, and the padding
inherits the row's ink. `DrawString` has about 86 callers; the others draw
strings at their exact length, so the reset never fired for them.

## Moving around

[browser_nav.c](../kernel/mod/src/browser_nav.c) (`BrowserNav`, `0C:4000`)
is davidesqalv's code from his
[ezgb-dv fork](https://github.com/davidesqalv/ezgb-dv), fitted to this
kernel so it works in both fonts and every theme.

- **The list wraps** at both ends.
- **A move inside the page draws no text.** The old row goes back to plain
  and the new one to the bar by recoloring them in VRAM: about 2 frames,
  against about 13 for stock's redraw.
- **A scroll moves the rows that stay** in VRAM and draws only the ones it
  uncovers, the bar's row first.
- **A held key** repeats after 18 frames, then every 6, 6, 5, 5, 4, 4, 3
  frames, and while the list scrolls it moves 1, 1, 2, 2, 3, 3, 4 rows a
  step. The repeat's state is WRAM `$DC1A` and `$DC1B`.
- **The entry number reads `n/total`** when `total/total` fits right of
  HELP, and `n` alone for the whole folder when it does not.
- **RIGHT on the last page jumps to the bottom row**, mirroring what stock
  LEFT does at the top ([browser_page_end.c](../kernel/mod/src/browser_page_end.c),
  `00:02fb`, hooked at `FileBrowserEntry_pageInc`'s bounds check `00:1195`).

`BrowserNav` opens with a three-jump table, so the far stubs keep their
targets when the code changes:

| Address | What | Reached from |
|---|---|---|
| `0C:4000` | DOWN | `BrowserScrollDownHook` (`00:02e0`), through the stub at `00:3d8c` |
| `0C:4003` | UP | `BrowserScrollUpHook` (`00:02f0`), through the stub at `00:3fa0` |
| `0C:4006` | the entry number | `TabNum12` (`00:0380`) |

### Recoloring a row

A plain row and the bar differ only in color. With `g` the row's glyph
bits:

| Row | Plane 0 | Plane 1 |
|---|---|---|
| plain | `g` | `g` |
| bar, light and dark | `~g` | `~g` |
| DV plain | `g`, clear where the blue icon is | `g` |
| bar, DV (index 1) | `~g` | `0` |
| bar, a color theme (index 2) | `0` | `~g` |

Light and dark draw the bar in index 3, so both directions are one
inversion (`InvertRow`). With an accent color the bar is index 1 or 2,
which an inversion cannot reach, so `HighlightRow` and `UnhighlightRow`
build it from the planes.

The recolor is only right while the old row shows its name from the start.
The marquee keeps the index it last drew at `$cc31`, and every move puts
the boot value `$EEEE` back, so any other value means the bar's long name
has scrolled and the move takes the stock repaint. So does a move inside a
section that has interrupts disabled.

### Idle waits

The browser loop's `Delay(45)` at `00:110f` is `BrowserDelay` (`00:03dc`):
two `WaitVBlankFlag` halts, skipped while UP or DOWN is held since the pace
is then counted in frames. The stock waits that spun on `ReadJoypad` call
`PadWait` (`00:0502`) instead, which halts until the next frame first. An
idle screen has the CPU halted about 95% of the time, where stock spun, so
the bus the save pSRAM shares stops toggling.

Two stock facts the row drawing relies on: `StoreDrawParams` (`00:2791`)
stores all three draw-state bytes (`$d734`, `$d735`, `$d723`) on every
call, and `DrawBrowserDetail` (`01:42ba`) prints the selection number on
every call.
