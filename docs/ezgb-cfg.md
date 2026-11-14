# `EZGB.CFG`: the settings file

Every setting the mod keeps on the card is a `key=value` line in
`/EZGB.CFG`. The file also holds a copy of the clock and of AUTO SAVE, so a
dead coin cell does not lose them. Addresses are 1.05e-0731's.

## The file

`/EZGB.CFG` in the card root. Keys ignore case, lines end in CR/LF or LF,
trailing spaces are trimmed, unknown keys are ignored, and the first
occurrence of a key wins.

```
FLAUNCH=/Pokemon/Blue.gb
UI=12
THEME=1
RTC=2026-09-08 10:15:32
```

| Key | Value | Set by |
|---|---|---|
| `FLAUNCH` | The fast-launch game's path. A leading `#` disables fast launch and keeps the path. Empty means enabled with no game named ([fast-launch.md](fast-launch.md)) | the SET tab |
| `LASTROM` | The last launched ROM's path, the fallback for the START overlay when the pSRAM record has faded ([last-rom.md](last-rom.md)) | every launch |
| `UI` | `8`, `12` or `SLIM` ([font12.md](font12.md#ui-modes)). Missing is 8 | the SET tab |
| `THEME` | The theme number, 0 to 7 ([themes.md](themes.md)). Written only when not 0 | the SET tab |
| `COLORS` | The custom theme's background and text as `RRGGBB,RRGGBB`, with an optional third color for the accent ([themes.md](themes.md#custom-colors)) | by hand, or the color picker |
| `TAGS` | `0` or missing: the browser cuts file names at their tags. Any other value shows full names ([browser.md](browser.md#clean-names)) | the SET tab |
| `BOOTROM` | `1`: every launch resets through the boot ROM ([skip-boot-rom.md](skip-boot-rom.md)). Missing means jump when it is safe | the SET tab |
| `DAILYBACKUP` | `1`: keep a dated copy of a save on the day's first backup ([save-manager.md](save-manager.md#daily-backup)) | the SET tab |
| `AUTOSAVE` | `0` or `1`: a copy of the SET tab's AUTO SAVE box | the SET tab, every launch |
| `RTC` | The last good clock reading, as `YYYY-MM-DD HH:MM:SS`. Read as six numbers split on any punctuation, using the last two digits of each | every launch, save backup and TIME SET |
| `RTCSD` | `0`: turn the clock backup off entirely, the SET tab's `RTC: NO SD` | the SET tab |

Path values are at most 120 characters and start with `/`.

**The kernel rewrites the whole file** from the keys it knows, as one
512-byte sector padded with spaces. Lines and comments added by hand do not
survive a save, and only the first sector is read.

The record is exactly one sector for a reason: this FatFs build mishandles
writes of part of a sector, and it has no `f_truncate`, so a shorter
rewrite must still cover the old bytes.

When `EZGB.CFG` is missing, a one-line `FLAUNCH.CFG` from older versions of
the mod is read instead, and the next save writes `EZGB.CFG`. Both names
are hidden from the browser.

## The clock backup

The coin cell runs the PCF8563 clock as well as the save pSRAM. When it
dies the clock comes back as the year 2000, and every save gets a wrong
timestamp. `RTC=` keeps a copy on the card so the clock can be put back.

**When it is saved.** At every launch, every save backup and every TIME
SET. A launch or backup stores the reading only when it is a valid date,
the chip's voltage-low flag (seconds bit 7) is clear, and it is later than
the stored copy. TIME SET always stores.

**When it is offered back.** At boot, after `Micro SD initial OK!` and
before the save backup, the kernel reads the clock and compares:

| Prompt | Trigger |
|---|---|
| `RTC RESET?` | the year is 2000, what the chip comes back as after losing power |
| `RTC BAD?` | not a valid BCD date and time |
| `RTC LOW V?` | the voltage-low flag is set |
| `RTC BEHIND?` | earlier than `RTC=` |

A normal boot reads once and goes on. A suspect reading waits about a
second, then reads until two reads a frame apart agree, since the FPGA's
copy of the clock registers may not be filled yet early in a cold boot.
The prompt shows the chip's reading and the stored one. **A** writes the
stored time to the clock. **B** keeps the chip's time, and for a low
voltage prompt rewrites it, which clears the flag. Nothing is written to
the clock without an answer.

The restored time is that of the last launch or backup, so the clock is
behind by however long the cart sat. Setting it on the SET tab updates the
backup.

Restoring before that boot's save backup matters: the backup then stamps a
sane time on the `.sav`.

**`RTCSD=0`** turns all of it off: no clock read or prompt at boot, and the
launch, backup and TIME SET hooks do not touch the card for the clock.

### An RTC game's clock going backwards

At launch, 1.05e's `RtcWriteTimeFromDayDelta` adds the time since the
save's launch stamp to the game's saved clock. In stock, a negative
difference zeroes the game's clock. `RtcNegClampHook` (`01:7620`) replaces
the sign test (`01:4e33`): a negative difference is taken as 0 and the
saved clock is used as it is, so the game only loses the gap. 1.04e has no
such routine, so the hook is not ported there.

## The AUTO SAVE backup

Stock keeps AUTO SAVE only in pSRAM (`$A200` on page `$11`), so a dead cell
turns it off, or into garbage. Every toggle writes `AUTOSAVE=`, and so does
every launch. A faded `$A200`, neither 0 nor 1, is never recorded.

It is put back only on a `BATTERY DRY` boot, right after the file is read
and before the kernel looks at the pending backup stamp. The order is the
safety rule:

1. **`$A000 = 0` first.** A dry boot means the save waiting in pSRAM faded
   with everything else, so it must never reach the card. The good `.sav`
   on the card stays, and the next launch loads it.
2. **Then `$A200` from `AUTOSAVE=`**, when the file has the key.

`BATTERY DRY` is a canary, not the clock chip's flag: `BatteryCheck`
(`00:1835`) reads `$A201` on page `$11` and expects `$88`. The clock can
reset to 2000 without the canary dying, so the clock restore keys on the
year alone.

## The module

`EzCfg` (`02:4a00`, [ezcfg.c](../kernel/mod/src/ezcfg.c)) does all of it.
It takes no stack argument: the caller puts an op in WRAM `$DBFC` and
calls, so one entry serves a call from bank 2 and a far call from anywhere
([shims.md](../kernel/mod/src/shims.md)).

| Op | Name | Does |
|---|---|---|
| 0 | `OP_LOAD` | read the file |
| 1 | `OP_SAVE` | write it |
| 2 | `OP_BACKUP` | after a save backup: store the clock |
| 3 | `OP_RESTORE` | the boot hook: read the file, the dry-boot steps, the clock check, the theme |
| 4 | `OP_LASTSAVE` | a launch: record `LASTROM=`, the clock and AUTO SAVE |
| 5 | `OP_LASTLOAD` | the START overlay: validate the pSRAM record, else use `LASTROM=` |
| 6 | `OP_TIMESET` | TIME SET confirmed: the new time replaces `RTC=` |
| 7 | `OP_RELAUNCH` | a relaunch or fast launch: the clock only |
| 8 | `OP_SAVECHK` | boot: validate the pending backup's path before the prompt |
| 9 | `OP_AUTOSAVE` | the AUTO SAVE box changed |

Every op leaves `$7FC0 = $00`; a caller restores the page it needs.

The hooks that call it:

| Hook | At | Op |
|---|---|---|
| `RtcBootHook` `00:0510` | `00:0e49`, after the card mounts | 3 |
| `SaveStampHook` `00:03aa` | `00:0f1c`, in the backup branch | 8 |
| the launch hook | `01:48c1`, `LastRomPersist`'s tail | 4 |
| `RelaunchRtcHook` `00:0588` | the START-overlay relaunch and fast launch | 7 |
| `RtcDumpHook` `01:7600` | `BackupSaveDump`'s epilogue | 2 |
| `RtcSetHook` `04:5f10` | the TIME SET confirm tail | 6 |
| `AutosaveSetHook` `04:5fa0` | the AUTO SAVE toggle's tail | 9 |
| `BatteryDryHook` `00:0530` | `BatteryCheck`'s canary write | sets `$DBFD` |

The SET tab's code (`FlCfg`, bank 4) reaches it through `FarCallEzCfg`
(`04:5f00`).

The WRAM it loads the settings into is declared in
[ezcfg.h](../kernel/mod/src/ezcfg.h) and [vars.h](../kernel/mod/src/vars.h).
Stock's variables end near `$D73B`, and the mod's WRAM starts at `$D780`.

## Reading the clock

FPGA page `$06` exposes seven BCD bytes at `$A008`-`$A00E` in the PCF8563's
register order: seconds, minutes, hours, day, weekday, month, year (two
digits). To write, select page 6, store the seven bytes, commit with
`$7FD0 = 1`, and go back to page 0, as the SET tab's confirm does
(`04:5747`). FW4 has the clock chip and this page too.

## Adding a key

1. Its name in `cfg_keys` in `ezcfg.c`, in the order of the parser's
   `switch`, and a case there.
2. A WRAM byte for it in `ezcfg.h` or `vars.h`.
3. A line in the save path, so it is written back.
4. A row on the SET tab if it has one
   ([set-tab.md](set-tab.md)).

The first eight keys each have a bit in the parser's `seen` mask, which is
what makes the first occurrence win. Keys past the eighth have no bit, so
for them the last occurrence wins.
