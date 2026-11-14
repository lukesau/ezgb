# Prompts and status boxes

The two prompts that can appear after `Micro SD initial OK!` share the look
of the START overlay ([last-rom.md](last-rom.md)): one closed box, rules
between its parts, a vertical rule between the two options, drawn in the
font of the UI mode ([font12.md](font12.md)). Stock drew a frame around each
option and then the option's label over it, and the label cells repainted
parts of the frame, so no frame was ever closed.

## BACKUPSAVE

Stock: a black box reading `BACKUPSAVE`, `[B]NO` / `[A]OK`. Now:

```
Back up save?
<save file name>          paper on an ink band; scrolls when too long
Played Oct 23 14:05       only when an RTC= backup exists; scrolls in 8px
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
  The date is month name and day (`Oct 03`, no year) rather than `MM-DD`;
  the line is 19 characters, one over the 8px row, so it is `LastRomName`'s
  second marquee line (`LR_GEO` = 2, text in `FL_DISP`) and scrolls like
  the name. In 12px it usually fits and stays still.
- Auto save (`$A200` = 1) shows the same box and goes straight to `Saving`.

### Garbage stamp

The pending-backup stamp (page `$11`: `$A000` = `$AA`, path length at `$A00F`,
path at `$A010`) is battery-backed like the last-ROM record, and without a
cell the flag can survive while the path is garbage: the prompt would show
up to 255 random bytes as the save's name, and A would dump under it. So
the path is validated before use, as the last-ROM record is
([last-rom.md](last-rom.md)). After the boot code has
copied the path to `$c3a5`, ezcfg op `SAVECHK` (8) accepts only what
`PreLaunchSaveStamp` writes, `/SAVER/` followed by a plausible file name (the
last-ROM path test: no control or `$FF` bytes, a NUL within 255, a non-empty
basename with a `.`). Anything else skips the whole backup branch and boots
to the browser, as if no backup were pending; the kernel has already cleared
`$A000` by then, so the prompt does not come back.

| Site (0731; 1.04e in brackets) | Was | Now |
|---|---|---|
| `00:0f1c` (`00:0f10`), in `BackupBranchEntry_openSaverDir` | `push bc; ld a,$00; push af; inc sp` | `jp SaveStampHook` (`00:03aa`): op `SAVECHK`; `EZ_RES` 0 -> `BackupBranchEntry_seedSlashPath`, else the displaced pushes and back to the `SetFpgaPage` far call |

A valid path is not enough on a BATTERY DRY boot: the save itself faded
with the canary. Since mod 6.9 op RESTORE clears `$A000` on such a boot
before this check runs, and `SAVECHK` refuses any stamp then as well, so a
dead cell never prompts or dumps (with AUTO SAVE either), see
[ezgb-cfg.md](ezgb-cfg.md) "AUTO SAVE backup".

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
before a 12px draw (the 12px engine is in another bank).

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

## BATTERY DRY

Stock: the Reading box's rectangle, (35,37)-(125,108), with `BATTERY`,
`DRY!!!` and a framed `[A]OK`. Now it is the small status box of
[font12.md](font12.md) "Status boxes" around two lines:

```
Battery dry!
   [A] ok
```

112 px wide, (24,46)-(135,89), tile rows 7 and 9, the same double frame and
rounded corners. `MsgBox` (`msgbox.c`, `0B:4B00`) draws it as box 3. It comes
up before `EZGB.CFG` is read, so it is always 8px.

| Site (0731) | Was | Now |
|---|---|---|
| `00:1868`, in `BatteryCheck` | `StoreDrawParams`, the box, three strings, the button frame | `ld a,3; push af; inc sp; push hl`, inline far call to `MsgBox`, `add sp,3; jr BatteryCheck_waitA` |

| `00:1878`, the stock draws | dead after the `jr` | `ld a,4; push af; inc sp; push hl`, inline far call to `MsgBox`, `add sp,3; jr $18ea` |
| `00:18e8`, in `BatteryCheck_markOk` | three `nop` after `call BatteryDryHook` | `jr $1878; nop` |

Box 4 erases the box once A is pressed. Nothing clears the screen between
here and the first `Reading...` box, which is smaller, so without it that
box would be drawn over this one.

The draw before it stays: `BatteryCheck` first draws a one-space string,
which is what puts the screen in graphics mode, and that resets the ink and
paper. A box drawn ahead of it comes out in the default colors, black on
white. The far call is inline, so a pushed pad word puts the argument where
`MsgBox` reads it (the status boxes reach it through a called stub). The
stock draws after the `jr` are left in place as dead code.

`SAMEBOY_EZFLASH_JR_DRY=1` makes SameBoy's stub boot as a cart with a dry
cell. Confirmed on hardware.

## Status boxes

`Reading...`, `Loading...` and `Error file` are three copies of one stock
drawer in bank 8 (`08:7344`, `08:737f`, `08:73ba`). Each starts with a `jp`
to a hook (`MsgHookReading` `08:7e10`, `MsgHookLoading` `08:7e24`,
`MsgHookError` `08:7e38`) that far-calls `MsgBox(n)`
([msgbox.c](../kernel/mod/src/msgbox.c), `0B:4B00`), in both fonts and
every theme.

The box is 96 px wide (x 32 to 127) and only as tall as the text plus a
margin: y 52 to 87 in 12px, y 54 to 81 in 8px. Its frame is a 2 px outer
line, a 1 px gap and a 1 px inner line in the text's color, after
davidesqalv's ezgb-dv fork. The four corner pixels are not drawn, so what
is behind them stays.

The boot messages (`Micro SD initial OK!` and the SD error texts) and
`BATTERY DRY!!!` stay 8x8 in 12px mode.

