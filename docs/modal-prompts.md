# Boot prompts: BACKUPSAVE and RTC restore

The two prompts that can appear after `Micro SD initial OK!` share the look
of the START overlay ([last-rom.md](last-rom.md)): one closed box, rules
between its parts, a vertical rule between the two options, drawn in the
font of the UI mode ([ui-mode.md](ui-mode.md)). The stock BACKUPSAVE box and
the RTC prompt copied from it drew a frame around each option and then the
option's label over it, and the 8x8 label cells repainted parts of the
frame, so no frame was ever closed.

## BACKUPSAVE

Stock: a black box reading `BACKUPSAVE`, `[B]NO` / `[A]OK`. Now:

```
Back up save?
<save file name>          paper on an ink band; scrolls when too long
Played MM-DD HH:MM        only when an RTC= backup exists
[B]skip | [A]save         "Saving." / ".." / "..." while the dump runs
```

| | 8px | 12px |
|---|---|---|
| box | (0,35)-(159,99) | (0,36)-(159,103) |
| rows | tile rows 5, 7, 9, 11 from column 1 | y 40, 56, 72, 88 from x 12 |
| name band | y 51..67 | y 53..69 |
| rule / vertical | y 83 / x 83 | y 85 / x 79 |

- The name is the basename of the `SAVER/` path the boot code copies from
  the page-`$11` stamp to `$c3a5` ([psram-save-map.md](psram-save-map.md)).
  `LastRomName` draws it, with `LR_GEO` (`$DB3F`) = 1 selecting this box's
  row, and the prompt's joypad poll runs its marquee tick.
- `Played` is the `RTC=` backup ([ezgb-cfg.md](ezgb-cfg.md)), which is
  refreshed at every launch, so at this prompt it is when the game whose
  save is pending was started. Without a valid backup the line is left out.
- Auto save (`$A001` = 1) shows the same box and goes straight to `Saving`.

### Garbage stamp

The pending-backup stamp (page `$11`: `$A000` = `$AA`, path length at `$A00F`,
path at `$A010`) is battery-backed like the last-ROM record, and without a
cell the flag can survive while the path is garbage: the prompt then showed
up to 255 random bytes as the save's name, and A would have dumped under it
(seen on a cart with no battery). The answer is the one for `$A300`
([last-rom.md](last-rom.md)): validate before use. After the boot code has
copied the path to `$c3a5`, ezcfg op `SAVECHK` (8) accepts only what
`PreLaunchSaveStamp` writes, `/SAVER/` followed by a plausible file name (the
last-ROM path test: no control or `$FF` bytes, a NUL within 255, a non-empty
basename with a `.`). Anything else skips the whole backup branch and boots
to the browser, as if no backup were pending; the kernel has already cleared
`$A000` by then, so the prompt does not come back.

| Site (0731; 1.04e in brackets) | Was | Now |
|---|---|---|
| `00:0f1c` (`00:0f10`), in `BackupBranchEntry_openSaverDir` | `push bc; ld a,$00; push af; inc sp` | `jp SaveStampHook` (`00:03aa`): op `SAVECHK`; `EZ_RES` 0 -> `BackupBranchEntry_seedSlashPath`, else the displaced pushes and back to the `SetFpgaPage` far call |

Checked in SameBoy (DMG model, all three kernels): a stamp with `$AA` and 231
printable random bytes boots to the browser; a real stamp still prompts.

`BackupSavePrompt` (`01:6747`) keeps its control flow. Its draws go to
`BkPrompt(op)` (`bkprompt.c`, `04:6000`):

| Site (0731; found by stock bytes in the other builds) | Was | Now |
|---|---|---|
| `01:674b` | box + `BACKUPSAVE` | inline far call, op 0, then `jr` over the rest |
| `01:67d0` | two button frames + labels | inline far call, op 1, then `jr` to the joypad loop |
| `01:6793`, `01:683b` | `call DrawString` (`Saving...`) | `call BkSavingStub` (`00:039d`): op 2 |
| `01:6821` | `call ReadJoypad` | `call LastRomTickStub` (`00:0370`) |
| `01:6549`, `01:656a`, `01:657e` (`BackupSaveDump` spinner) | `call DrawString` | `call BkSpinStub` (`00:0390`): op 3, which redraws `Saving` + 1..3 dots every 8th call |

The two `Saving...` sites keep their argument pushes and only retarget the
call: they load a bank-1 string address that differs per build, and
`port-mod.py` refuses a replaced site whose stock operand it cannot
translate. `BkPrompt` lives in bank 4, so it copies its strings to the stack
before a 12px draw (the renderer runs in bank 2).

## RTC restore

`restore_prompt` in `ezcfg.c` (when the clock looks reset, bad, low on
voltage or behind the backup):

```
RTC BEHIND?
CHIP  26-09-30
      20:44:32
SD    31-09-30
      20:43:08
[B]keep | [A]use SD
```

| | 8px | 12px |
|---|---|---|
| box | (0,27)-(159,99) | (0,20)-(159,115) |
| rows | tile rows 4, 6..9, 11 | y 24, 44, 56, 68, 80, 100 |
| rules / vertical | y 43, 83 / x 75 | y 38, 95 / x 79 |

In 12px mode the labels start at x 12 and the dates and times at x 60, each
its own `DrawString12` call with a pixel x, so the proportional font does not
misalign the columns; the two options are separate calls for the same
reason.

## Not changed

`BATTERY DRY!!!` (`BatteryCheck`, `00:1835`) and the Reading / Loading /
Error boxes are stock.

Checked in SameBoy (DMG model): both prompts in both modes on 0731 (long
name scrolling, A saving through to the browser, B, the RTC prompt followed
by the save prompt), and the 12px prompts on 0918.
