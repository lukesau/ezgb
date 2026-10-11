# Hold A on a ROM: options menu

Tapping A on a `.gb`/`.gbc` file launches it, as before, but now when A comes
up. Holding A for half a second opens a menu for that ROM instead:

```
Options
<ROM name>                paper on an ink band; scrolls when too long
> Start
  Manage saves
[B]back | [A]ok
```

UP/DOWN moves the `>`, A on Start launches, and B closes the menu and puts the
browser back as it was, with the cursor on the same entry. Manage saves is a
placeholder: A on it does nothing yet. It is where save management goes now
that `SAVER/` is hidden from the browser ([browser-hide-filter.md](browser-hide-filter.md)).

Folders still open on press. Pick mode ([fastlaunch-set-tab.md](fastlaunch-set-tab.md))
and files that are not ROMs take the stock path straight away.

## Why A waits for release

No button is spare in the browser: SELECT switches tabs and START opens the
last-ROM overlay. So the menu has to come from a hold, and until A comes up a
tap and a hold look the same. A tap gets one tap's length of extra delay,
about 100 ms. The menu opens as soon as the hold reaches 30 frames, without
waiting for the release, and that release is not counted as a press.

## A held from before

Holding A to open a folder used to fall through to the folder's first entry
on the browser's next poll. With the hold, that would open the menu (or
launch) on a ROM nobody pressed A on. So an A that was already down at the
browser's previous poll is ignored until it is let go.

`RomMenuPadTrack` wraps the browser loop's `ReadJoypad` and keeps that poll's
report and the one before it in HRAM. Every path out of `RomMenu` zeroes the
current one, so the poll after the menu never counts as "A held".

## Timing the hold

While the hold is timed nothing on the main thread reads the pad, so
`$fffc`, which `VBlankPadLatch` writes with the live pad every frame
([joypad-latch.md](joypad-latch.md)), is the live state once one VBlank has
passed. Reading P1 directly instead would race the VBlank sampler.

## Layout

The BACKUPSAVE prompt's box ([modal-prompts.md](modal-prompts.md)) made two
rows taller. The name goes on the same band, drawn and scrolled by
`LastRomName` with `LR_GEO` = 1, and the menu polls through
`LastRomTickStub`, which runs the marquee before `ReadJoypad`.

| | 8px | 12px |
|---|---|---|
| box | (0,35)-(159,115) | (0,36)-(159,119) |
| rows | tile rows 5, 7, 9, 11, 13 from column 1 | y 40, 56, 72, 88, 104 from x 12 |
| name band | y 51..67 | y 53..69 |
| rule / vertical | y 99 / x 83 | y 101 / x 79 |
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

## The patch

| Site (0731) | Was | Now |
|---|---|---|
| `00:1114`, in `FileBrowserEntry_inputLoop` | `call ReadJoypad` | `call RomMenuPadTrack` |
| `00:145f`, `MenuDispatchAB_fileOpen` | inline far call to `DrawLoadingBox` (`08:737f`) | `call RomMenuHoldStub` + 4 `nop` |

| Block | Size | What |
|---|---|---|
| `RomMenuPadTrack` `00:0453` | 11 | `$fff5` := `$fff6`; `ReadJoypad`; `$fff6` := the report. A and E unchanged |
| `RomMenuHoldStub` `00:0597` | 19 | passes `sp+6` (the loop's `sp+4`, the record offset) to `RomMenu`; E = 0: `ret` into the open path, else drop the return and `jp MenuDispatchAB_waitVBlankLoop` |
| `FarCallDrawLoadingBox` `00:0483` | 8 | far call to `DrawLoadingBox`, for the C |
| `RomMenu` `04:5a00` | 1122 | [kernel/src/rom_menu.c](../kernel/src/rom_menu.c) |

```asm
RomMenuPadTrack::          ; 00:0453
    ldh a, [$f6]
    ldh [$f5], a
    call ReadJoypad
    ld a, e
    ldh [$f6], a
    ret

RomMenuHoldStub::          ; 00:0597
    ld hl, sp+$06
    push hl
    call FarCallTrampoline
    db $00, $5a, $04, $00  ; -> 04:5a00 RomMenu
    add sp, $02
    ld a, e
    or a
    ret z                  ; 0: open (DrawLoadingBox already drawn)
    pop hl
    jp MenuDispatchAB_waitVBlankLoop
```

`RomMenu` returns 0 after drawing `DrawLoadingBox` itself, so the open path
goes on exactly as the stock far call left it.

```sh
cd kernel
V=1.05e-0731
python3 tools/inject.py src/rom_menu.c $V 4 5a00 RomMenu \
    --pin FarCallDrawString12=05c0 --pin LastRomNameStub=0368 \
    --pin LastRomTickStub=0370 --pin FarCallDrawLoadingBox=0483 \
    --pin DrawString=08b7 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
    --pin hUiMode=fffb --apply
python3 tools/inject_bytes.py $V 0 0483 FarCallDrawLoadingBox cd8d077f730800c9 --apply
python3 tools/inject_bytes.py $V 0 0453 RomMenuPadTrack f0f6e0f5cd4a3a7be0f6c9 --apply
python3 tools/inject_bytes.py $V 0 0597 RomMenuHoldStub f806e5cd8d07005a0400e8027bb7c8e1c3ab16 --apply
python3 tools/patch_call.py $V 0 1114 3 00:0453 --apply
python3 tools/patch_call.py $V 0 145f 7 00:0597 --apply --regen
```

The other builds are ports (`scripts/port-mod.py`). In 1.04e the stub's loop
target is `$1692` and the tracker's `ReadJoypad` is `$3691`.

`RomMenu` leaves 158 bytes free before the end of the bank-4 run, so Manage
saves needs a block of its own.

## Testing

SameBoy `--model dmg`, the `sd/` test card, A held with a CGEvent key-down
and key-up (X = A), on 0731 and 0918, 8px and `UI=12`:

- A held 0.9 s on `Tetris.gb`: the menu, name on the band
- DOWN moves `>` to Manage saves, and B closes the menu, leaving the page
  intact and the cursor on the same entry (index 6)
- a 100 ms tap: `Loading...`, as before
- A held 3 s on the `Pokemon` folder: the folder opens and its only entry,
  `Pokemon Red.gb`, is neither launched nor given a menu; a new 0.9 s hold
  opens the menu
