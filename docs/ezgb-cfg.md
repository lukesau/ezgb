# `EZGB.CFG`: one settings file, and the RTC backup that lives in it

The cart's coin cell backs both the save pSRAM and the PCF8563 real-time
clock, and it lasts months, not years. When it dies the clock comes back as
the year 2000 (or the 2019 factory default) and every save file gets a wrong
timestamp until you notice and reset it on the SET tab. This feature keeps a
copy of the clock on the SD card and puts it back automatically, so a dead
cell costs you at most the time since your last save, not 26 years.

It also replaces `FLAUNCH.CFG` with a single `EZGB.CFG` holding every
on-card setting as `key=value` lines, so future settings do not each need
their own file. As of mod 3.8 it also stores `LASTROM=`, the SD fallback for
the START overlay's last-ROM record when the coin cell has died (see
[last-rom.md](last-rom.md)).

Mod version 3.x (2026-09-08). Emulator-verified end to end under SameBoy;
**not yet hardware-tested** (see "Verification status").

## The file

`/EZGB.CFG`, 8.3 name, in the card root. Keys are case-insensitive, lines
end in CR/LF or LF, trailing spaces are trimmed, unknown keys are ignored,
and the first occurrence of a key wins.

```
FLAUNCH=/Pokemon/Blue.gb
RTC=2026-09-08 10:15:32
```

| Key | Value | Written by |
|---|---|---|
| `FLAUNCH` | Fast-launch target path, root or nested. A leading `#` on the value means fast launch is **disabled** (every trigger skipped) with the path kept for re-enabling. Empty = enabled, no explicit target (lone-ROM rule). Same semantics as the old `FLAUNCH.CFG` line 1, see [`fast-launch-notes.md`](fast-launch-notes.md). | SET tab (checkbox, PICK) |
| `LASTROM` | Last-launched ROM path, written on every launch. The START overlay uses it only when the battery-backed `$A300` record is corrupt. Same 120-char cap and `/`-prefix rules as `FLAUNCH`. | launch hook (`01:48c1`) |
| `RTC` | Last known good clock. Only the digits matter: the first 14 digits in order are `YYYYMMDDhhmmss`, so `2026-09-08 10:15:32` and `20260908101532` are the same value. Century is dropped (the RTC keeps two year digits, 20xx). | every save-to-SD dump, every TIME SET confirm |

The firmware rewrites the whole file from its known keys as a fixed 192-byte
record padded with spaces (this FatFs build has no `f_truncate`, so a
shorter rewrite must still cover the old bytes). Hand-added lines and
comments do not survive a save, and a file longer than 255 bytes is read only
up to that point.

**Migration:** when `EZGB.CFG` is missing, the loader falls back to a
`FLAUNCH.CFG` in the old one-line format, so an existing card keeps its
fast-launch setting; the next save writes `EZGB.CFG`. Both names are hidden
from the browser and skipped by the lone-ROM count. Delete the old file at
your leisure.

## What it does

**Backup.** After every `BACKUPSAVE` dump to `SAVER/*.SAV`, and after every
TIME SET confirm on the SET tab, the kernel reads the RTC and, if it is
well-formed and later than the copy in the file, writes it to `RTC=`. A dead
clock (zeros, or garbage after a cell swap) can therefore never overwrite a
good backup: the comparison refuses anything earlier than what is stored.

**Restore.** At boot, right after `Micro SD initial OK!` and before the
`BACKUPSAVE` check, the kernel loads the file and reads the RTC. It writes
the stored time back to the clock when any of these hold:

- the `BATTERY DRY!!!` prompt fired this boot (the cell was lost, see below),
- the RTC bytes are not valid BCD or out of range,
- the RTC reads earlier than the stored time.

Restoring before that boot's `BACKUPSAVE` matters: the dump that follows then
stamps a sane time on the `.SAV`, and its own backup step sees "RTC equals
stored" and leaves the file alone.

The restored time is the time of the last save, so the clock lags by however
long the cart sat with a dead cell. Fix it on the SET tab whenever you like;
that confirm updates the backup too.

**BATTERY DRY is a canary, not the chip's flag.** `BatteryCheck` (`00:1835`)
maps pSRAM page `$11` and reads `$A201`, expecting `$88`; anything else
draws BATTERY / DRY!!!, waits for A, and writes `$88` back. It never reads the
PCF8563's voltage-low bit. Since one cell backs both the pSRAM and the RTC, a
lost canary is a reliable "the clock was lost too" signal, and the hook on
the write-back sets a WRAM flag the boot restore honours unconditionally.
(An older note in [`psram-save-map.md`](psram-save-map.md) claiming the
prompt was about the console's AA cells was wrong and has been corrected.)

## RTC access

FPGA page `$06` exposes seven BCD bytes at `$A008..$A00E` in PCF8563 register
order: seconds, minutes, hours, day, weekday, month, year (two digits, 20xx).
`RtcToDayCount` (`01:4c5e`) reads them; the factory init
`InitTimeAutosaveFpga_B4` writes 2019-07-24 11:22:33. Writing is the SET
tab's recipe (`DrawTimeAutosaveScreen_confirmBcdWrite`, `04:5747`): select
page 6, store the seven bytes (weekday hardcoded to `$03`), commit with
`$7FD0=1`, back to page 0. Page select and commit are the same
unlock/commit register sequence as `SetFpgaPage_B4` / `SetFpga7FD0_B4`
(`$7F00=$E1`, `$7F10=$E2`, `$7F20=$E3`, register, `$7FF0=$E4`), inlined in C
since they are plain stores that work from any bank.

## Code

| Piece | Where | What |
|---|---|---|
| `EzCfg` | `02:4a00`, [decomp/src/ezcfg.c](../decomp/src/ezcfg.c), 3028 B | The module: load/save the file, parse keys, RTC read/write/compare, the backup and restore ops. **No stack argument**: the op is passed in WRAM `$DBFC` so the same entry works for a plain bank-2 `call` and for `FarCallTrampoline` (which shifts stack args by 6). Op 0 LOAD, 1 SAVE, 2 BACKUP, 3 RESTORE, 4 LASTSAVE, 5 LASTLOAD. |
| `FastLaunchScan` | `02:4500`, [decomp/src/fastlaunch.c](../decomp/src/fastlaunch.c), 766 B | Now calls `ezcfg` (op LOAD) instead of parsing a file itself; skips `ezgb.cfg` in the lone-ROM count. |
| `FlCfg` | `04:5990`, [decomp/src/flcfg.c](../decomp/src/flcfg.c), 778 B | SET-tab UI, now a client of `ezcfg` through `FarCallEzCfg`. Shrank from 1258 B. |
| `FarCallEzCfg` | `04:5f00`, 8 B | `call FarCallTrampoline; db $00,$4a,$02,$00; ret` |
| `RtcSetHook` | `04:5f10`, 11 B | TIME SET confirm tail: op BACKUP, then `jp DrawTimeAutosaveScreen_redraw` (`$48f5`) |
| `RtcBootHook` | `00:0510`, 27 B | Boot restore: op RESTORE, re-assert `$4000=$11`, replay the displaced `SetFpgaPage(3)` far-call, `jp $0e50` |
| `BatteryDryHook` | `00:0530`, 12 B | `$DBFD=1`, then the displaced `$A201=$88`, `ret` |
| `RtcDumpHook` | `01:7600`, 15 B | `BackupSaveDump` epilogue: `add sp,$0b`, op BACKUP, `ret` |
| `BrowserHideName` | `08:7c00`, [decomp/src/browser_hide.c](../decomp/src/browser_hide.c), 255 B | Hides `ezgb.cfg` too. Relocated from `08:7a9c` (it outgrew the gap before `FlPickBanner` at `08:7b8d`); `DirListHideNameStub` (`00:04ae`) re-emitted with the new target. |

### Hook map (stock bytes → patch)

| Site | Stock | Patch | Purpose |
|---|---|---|---|
| `00:0e49` | `cd 8d 07 e7 41 04 00` (far-call `SetFpgaPage(3)` after "Micro SD initial OK!") | `jp $0510` + 4 nop | boot restore, then replay |
| `00:18e5` | `01 01 a2 3e 88 02` (`BatteryCheck_markOk`: `$A201=$88`) | `call $0530` + 3 nop | DRY flag |
| `01:6738` (0731) / `01:699a` (0918) | `e8 0b c9` (`BackupSaveDump_epilogueRet`) | `jp $7600` | backup after a dump |
| `04:58d3` | `c3 f5 48` (confirm tail `jp _redraw`) | `jp $5f10` | backup after TIME SET |

Banks 0, 2, 4 and 8 are byte-identical across 1.05e-0731 and 1.05e-0918, so
every injection is the same bytes for both; only the bank-1 site differs
(bank 1 is shifted by `$262` in 0918). The bank-1 hook body itself contains
no version-specific address.

### WRAM

| Addr | Use |
|---|---|
| `$D800-$D9FF` | `CFGBUF`, 512 B: file contents on read, record on write (grown from 256 B and moved down from `$D980` for the third `LASTROM` line) |
| `$DA00-$DA7E` / `$DA7F` | `LR_PATH` (LASTROM path) / `LR_VALID` |
| `$DBFB` | `EZ_RES`, op result byte read by the last-ROM stubs |
| `$DA80` / `$DA81` / `$DA82-$DAF9` | `FL_EN`, `FL_PLEN`, `FL_PATH` (unchanged) |
| `$DB00-$DB0F` | `FL_SCR`, file-name bounce for `f_open` (path must be in WRAM) |
| `$DB10-$DB37` | `FL_DISP` (SET tab, unchanged) |
| `$DB40-$DB46` | `RTC_BK`, stored time, 7 BCD bytes in register order |
| `$DB47` | `RTC_VALID`, 1 when the file held a usable `RTC=` |
| `$DB48-$DB4E` | `RTC_CUR`, the last RTC read |
| `$DBFC` | `EZ_OP`, operation selector for `ezcfg` |
| `$DBFD` | `DRY_FLAG`, set by `BatteryDryHook` |
| `$DBFE` / `$DBFF` | `FL_PICK`, fast-launch one-shot (unchanged) |

WRAM is cleared at `KernelEntry` before `BatteryCheck`, so the flag is
reliably 0 on a boot without the prompt. None of these addresses are
referenced by the stock kernel (`$D780-$D980` was already the fast-launch
scratch window; the kernel's own variables top out near `$D73B`).

### SD I/O discipline

As in every earlier feature: `WaitVBlankFlag` + `$7FC0=$00` before `f_open`,
`f_read`, `f_write` and `f_close`; file names bounced through WRAM because
`f_open` runs in bank 6. Every `ezcfg` op leaves `$7FC0=$00`; callers restore
their own personality (the boot hook replays the kernel's `SetFpgaPage(3)`,
the SET tab rests at 0, the browser sets its pages on entry). The FIL at
`$CA0F` is idle at all three hook points (before the backup branch, after the
dump's own `f_close`, on the SET tab).

## Reproduce

```bash
scripts/inject-ezcfg.sh 1.05e-0731
scripts/inject-ezcfg.sh 1.05e-0918
python3 scripts/kernel-patch.py make
```

[`scripts/inject-ezcfg.sh`](../scripts/inject-ezcfg.sh) drops the old
`kernel.sym` entries, blanks the superseded byte ranges to `$FF`, re-injects
`ezcfg.c`, `fastlaunch.c`, `flcfg.c` and `browser_hide.c`, drops the shims and
hooks, patches the sites, and regenerates the disassembly. It replaces the
per-feature recipes in [`fastlaunch-set-tab.md`](fastlaunch-set-tab.md) and
[`browser-hide-filter.md`](browser-hide-filter.md) for those files.

## Verification status

Structural: both versions round-trip byte-exact through `scripts/build-kernel.sh`;
`scripts/kernel-patch.py make` regenerates matching IPS patches (mod 3.1).

Under SameBoy (EZ Jr stub, 1.05e-0731), driven by key injection with
watchpoints on `$DBFC` and `$7FD0`:

- **Boot, legacy read.** With only an empty `FLAUNCH.CFG` on the card, the
  boot hook ran op RESTORE, loaded the legacy file (`FL_EN=1`, no path, no
  RTC), and the browser came up normally with the fast-launch state intact.
- **TIME SET confirm.** A on the TIME row wrote `$7FD0=1` (stock), then the
  hook wrote `EZGB.CFG` = `FLAUNCH=` / `RTC=2026-09-08 10:13:08` (192 B).
- **Save dump.** With page `$11` armed (`$A000=$AA`), `[A]OK` on BACKUPSAVE
  ran the dump, the epilogue hook fired op BACKUP, and the file's `RTC=` line
  advanced to the current time.
- **Restore write.** With `RTC=2027-01-01 00:00:00` in the file, boot parsed
  it (`RTC_BK` = `00 00 00 01 03 01 27`), read the host clock (2026), and
  wrote `$7FD0=1` from inside `ezcfg` before the BACKUPSAVE check; the
  following boot steps were unaffected.
- **Hide filter.** `EZGB.CFG` is absent from the browser listing.

Not verifiable in the emulator: the stub always serves `$A201=$88`, so the
BATTERY DRY prompt (and the DRY flag path) never triggers there, and its RTC
reads always return the host clock, so a restored value cannot be read back.
Banked breakpoints (`$02:$4a00`) did not fire in this harness; watchpoints
on `$DBFC` were used instead.

**Hardware testing is required** before relying on it, as with every earlier
feature: confirm a normal boot, a save dump, and a TIME SET each rewrite
`EZGB.CFG` with the right time; that the clock survives a BATTERY DRY boot
with the stored time rather than 2000; that fast launch (config path and
lone-ROM) still works from the new file; and that browsing and launching
are unaffected after the hooks (no wedged SD controller).
