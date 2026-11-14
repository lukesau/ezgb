# Hold A on a ROM: the options menu

Tapping A on a `.gb` or `.gbc` file launches it when A comes up. Holding A
for half a second opens a menu for that ROM instead:

```
Options
<ROM name>                paper on an ink band; scrolls when too long
> Start
  Manage saves
  Star                    Unstar for a starred ROM
[B]back | [A]ok
```

UP/DOWN moves the `>`, A on Start launches, and B closes the menu and puts the
browser back as it was, with the cursor on the same entry. A on Manage saves
opens the save manager ([save-manager.md](save-manager.md)).
The menu is redrawn when it returns. A on Star stars the ROM (or unstars it),
sorts the folder again, closes the menu and puts the cursor back on the ROM
wherever it now sits ([stars.md](stars.md)). UP and DOWN wrap at both ends.

Folders still open on press. Pick mode ([fastlaunch-set-tab.md](fastlaunch-set-tab.md))
takes the stock path straight away. A file that is not a ROM is offered to the
text viewer ([text-viewer.md](text-viewer.md)), which opens `.txt`, `.ini` and
`.md`; any other file takes the stock path too.

## Why A waits for release

No button is spare in the browser: SELECT switches tabs and START opens the
last-ROM overlay. So the menu has to come from a hold, and until A comes up a
tap and a hold look the same. A tap gets one tap's length of extra delay,
about 100 ms. The menu opens as soon as the hold reaches 30 frames, without
waiting for the release, and that release is not counted as a press.

## A held from before

An A held while a folder opens would reach the folder's first entry on the
browser's next poll and open the menu, or launch, on a ROM nobody pressed A
on. So an A that was already down at the browser's previous poll is ignored
until it is let go.

`RomMenuPadTrack` wraps the browser loop's `ReadJoypad` and keeps that poll's
report and the one before it in HRAM. Every path out of `RomMenu` zeroes the
current one, so the poll after the menu never counts as "A held".

## Timing the hold

While the hold is timed nothing on the main thread reads the pad, so
`$fffc`, which `VBlankPadLatch` writes with the live pad every frame
([input.md](input.md)), is the live state once one VBlank has
passed. Reading P1 directly instead would race the VBlank sampler.

## Layout

The box is the BACKUPSAVE prompt's ([prompts.md](prompts.md)),
three rows taller. The name goes on the same band, drawn and scrolled by
`LastRomName` with `LR_GEO` = 1, and the menu polls through
`LastRomTickStub`, which runs the marquee before `ReadJoypad`.

| | 8px | 12px |
|---|---|---|
| box | (0,35)-(159,131) | (0,36)-(159,135) |
| rows | tile rows 5, 7, 9, 11, 13, 15 from column 1 | y 40, 56, 72, 88, 104, 120 from x 12 |
| name band | y 51..67 | y 53..69 |
| rule / vertical | y 115 / x 83 | y 117 / x 79 |
| `[A]ok` | column 11 | x 86 |

The name is copied from its record in the pSRAM window to `$c4a4` before
anything is drawn. The open path clears and refills `$c4a4` itself
afterwards.

Closing the menu clears the box area and sets the loop's redraw code
(`sp+$12`) to 1, the value a page change sets, then returns to
`MenuDispatchAB_waitVBlankLoop`. The page is repainted from the sorted
records, without reading the directory again, and the cursor stays where it
was. Going back through `FileBrowserEntry`, as the START overlay does, would
re-read the folder and zero the cursor (`sp+$13`, `sp+$15`). The page repaint
only draws rows that have entries, which is why the box area is cleared
first.

## The code

| Site | Stock | Now |
|---|---|---|
| `00:1114`, in `FileBrowserEntry_inputLoop` | `call ReadJoypad` | `call RomMenuPadTrack` |
| `00:145f`, `MenuDispatchAB_fileOpen` | a far call to `DrawLoadingBox` | `call RomMenuHoldStub` |

| Block | What |
|---|---|
| `RomMenuPadTrack` `00:0453` | Copies the last poll's report from `$fff6` to `$fff5`, calls `ReadJoypad`, stores the new report in `$fff6` |
| `RomMenuHoldStub` `00:0597` | Passes the record offset from the loop's frame to `RomMenu`. On 0 it returns into the open path; otherwise it drops the return address and jumps to `MenuDispatchAB_waitVBlankLoop` |
| `FarCallDrawLoadingBox` `00:0483` | far stub to the stock `DrawLoadingBox`, for the C |
| `RomMenu` `04:5a00` | [rom_menu.c](../kernel/mod/src/rom_menu.c) |

`RomMenu` returns 0 only after drawing the `Loading...` box itself, so the
open path goes on exactly as the stock far call left it.
