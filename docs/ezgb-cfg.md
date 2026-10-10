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
| `UI` | `8` or `12`: which browser the SD tab draws, see [ui-mode.md](ui-mode.md). Missing = 8. | SET tab (`UI:` button) |
| `RTC` | Last known good clock. The value is split on any punctuation into six numeric fields `YYYY MM DD HH MM SS`; the last two digits of each are used, so `2026-09-08 10:15:32`, `26-9-8 10:15:32`, and a stale `026-...` all restore to the same time (the century is dropped). | every save-to-SD dump, every TIME SET confirm |

The firmware rewrites the whole file from its known keys as a fixed one-sector (512-byte)
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

**Backup.** `RTC=` is refreshed at every game launch (a browser launch already
rewrites the file for `LASTROM=`; the START-overlay relaunch and fast launch,
which jump past that step to `$1570`, go through `RelaunchRtcHook` `00:0588`,
op 7), every `BACKUPSAVE` dump and every TIME SET.
A launch or dump stores the reading only when it is valid, the PCF8563's VL
flag (seconds bit 7: "supply dipped, time not guaranteed") is clear, and it is
later than the stored copy. TIME SET always stores (see below). A restore
therefore loses at most the time since the last launch or dump.

**RTC: SD / NO SD (SET tab, `RTCSD=`).** Everything in this section is the
`SD` setting, the default (no key). `NO SD` (`RTCSD=0`) is for carts where the
clock does not matter: no clock read or prompt at boot, and the launch, dump,
TIME SET and relaunch hooks return without touching the card for the RTC. The
boot still reads `EZGB.CFG` once (it holds the setting); the flag then stays
in WRAM (`$DB3A`) for the later hooks.

**Restore (boot).** Right after `Micro SD initial OK!` and before the
`BACKUPSAVE` check, with an `RTC=` on file, the kernel reads the RTC and asks
whether the reading looks damaged:

| | Trigger |
|---|---|
| `Z` | year 2000, what a PCF8563 that lost power comes back as |
| `I` | not a valid BCD date/time |
| `V` | VL flag set |
| `E` | earlier than `RTC=` (the clock stopped or glitched since the last launch/dump) |

A normal boot reads once and returns: no wait, no file write. A suspect read
waits about a second, then reads until two reads a frame apart agree (the
FPGA's copy of the RTC registers may not be filled yet early in a cold boot),
and checks again. Nothing is ever written to the clock without the user:

- **Prompt.** A widened copy of the stock `BATTERY DRY!!!` box shows the
  reason (`RTC RESET?` / `RTC BAD?` / `RTC LOW V?` / `RTC BEHIND?`), the
  chip's settled reading (`CHIP`, raw hex so garbage and VL show as-is) and
  the backup (`SD`), with `A:SD  B:KEEP`. It first consumes the joypad latch
  and waits for A and B to be up for 8 frames
  ([`joypad-latch.md`](joypad-latch.md): a tap from before the box existed
  would otherwise answer it unseen), takes A or B, waits for the release so
  it cannot carry into the `BACKUPSAVE` prompt, and clears the box.
- **A** writes `RTC=` to the clock. **B** keeps the chip's time; for a VL
  prompt it rewrites that time, which clears VL so the prompt does not return
  every boot.

Restoring before that boot's `BACKUPSAVE` matters: the dump that follows then
stamps a sane time on the `.SAV`, and its own backup step sees "RTC equals
stored" and leaves the file alone.

The restored time is the time of the last save, so the clock lags by however
long the cart sat with a dead cell. Fix it on the SET tab whenever you like;
that confirm updates the backup too.

**History.** Mod 4.3 restored automatically when the RTC read invalid,
earlier than stored, or after BATTERY DRY. On cold boots the early read could
trip the "earlier" test with a good battery and roll the clock back to the
last save; Pokemon Crystal launched after that saw its saved timestamp in the
future and `RtcWriteTimeFromDayDelta` zeroed the game's RTC. 4.4/4.5 restored
automatically on year 2000 only. The test builds after 4.5 make every trigger a
prompt, add the VL and "behind" triggers back as prompts, back up at launch,
and clamp negative elapsed time (below).

**TIME SET replaces `RTC=` outright.** The confirm hook runs op 6
(`TIMESET`) instead of op 2: the set time is stored even when it is earlier
than the stored copy, so a clock set back from a wrong future date does not
leave `RTC=` stuck in that future.

**`RTCLOG=` (test builds only).** Compiled in with `EZCFG_RTCLOG`; release
builds have none of it and drop a leftover `RTCLOG=` line at their next save.
Build a test kernel with the macro set for the whole build (inject and port):

```sh
export EZGB_DEFINES=EZCFG_RTCLOG
scripts/inject-ezcfg.sh 1.05e-0731
scripts/port-mod.py 1.05e-0731 1.05e-0918 --apply --sym
scripts/port-mod.py 1.05e-0731 1.04e --apply --sym
```

Do not run `kernel-patch.py make` on such a build. Events prepend a 14-byte
entry `YYMMDDhhmmssE` (the raw register bytes of that read in hex, then the
event), newest first, 10 kept; a boot writes the file only after a suspect
read.

| E | Event |
|---|---|
| `Z` `I` `V` `E` | boot, first read suspect (triggers above) |
| `S` | ...fine after the settle wait: no prompt |
| `Y` / `N` | ...prompt answered A / B (entry shows the settled read) |
| `L` | game launch |
| `B` | after a `BACKUPSAVE` dump |
| `T` | after a TIME SET confirm |

**Negative-elapsed clamp (bank 1, 1.05e only).** On launch,
`RtcWriteTimeFromDayDelta` adds `now - .sav launch stamp` to the game's saved
RTC registers; stock, a negative difference (the clock went backwards since
that launch) falls into `zeroHms` and zeroes the game's RTC, which is what
made Pokemon Crystal's clock jump to its stored offset. `RtcNegClampHook`
(`01:7620`, 15 B) replaces the sign test (`bit 7,a; jp z,seedC0a0` at
`01:4e33` in 0731, `01:509e` in 0918): a negative elapsed value is set to 0
and the saved registers are used as-is, so the game only loses the gap. A
zero timestamp (no trailer) still zeroes, as stock. 1.04e predates this
routine, so the port skips the hook there (`SKIP_SITES`/`SKIP_BLOCKS` in
`scripts/port-mod.py`).

**BATTERY DRY is a canary, not the chip's flag.** `BatteryCheck` (`00:1835`)
maps pSRAM page `$11` and reads `$A201`, expecting `$88`; anything else
draws BATTERY / DRY!!!, waits for A, and writes `$88` back. It never reads the
PCF8563's voltage-low bit. A DRY boot always comes with the clock at 2000,
but the clock can also reset to 2000 without the canary dying, so the
restore keys on the year alone. `BatteryDryHook` still sets `$DBFD`, which
nothing reads any more.
(An older note in [`psram-save-map.md`](psram-save-map.md) claiming the
prompt was about the console's AA cells was wrong and has been corrected.)

## RTC access

**Hardware finding (2026-09-09, FW4 cart, 1.04e, mod 4.1).** `RTC=` stayed
empty after TIME SET, and a hand-written time was lost at the next save, so a
battery-less cart came up at year 2000. The cause is in the kernel's FatFs,
not the clock: a partial-sector `f_write` or `f_read` goes through
`MemCpy16_B7`, whose byte count is 8-bit, while the file pointer still
advances by the full length. The kernel only ever moves whole sectors or
48-byte records, so it never noticed. The 320-byte record introduced in mod
3.6 therefore landed as `320 & 0xFF = 64` bytes, the rest of the sector
keeping whatever it held before; a 60-byte FLAUNCH line put the `RTC=` value
at byte 64, so it never reached the card. Reproduced in SameBoy with a
digit-filler record read back through the FAT. Splitting the transfer into
two partial calls does not work either (the second write restarts the
sector). Since mod 4.3 the record is exactly one sector (`REC_LEN` 512) and
is read and written with one whole-sector call each, FatFs's direct path,
the same one the kernel's save dumps use. A shorter file still reads fine up
to 255 bytes; a 256-511-byte one (the mod 3.6-4.2 shape) yields only its
first `size & 0xFF` bytes once and is rewritten whole at the next save.
`rtc_read` also masks the PCF8563 flag bits (VL, century, unused) since mod
4.2, hygiene rather than the cause. A build compiled with `-DEZCFG_RTCRAW`
always saves and adds an `RTCRAW=` line with the raw registers, masked read,
stored time and the backup decision.

FPGA page `$06` exposes seven BCD bytes at `$A008..$A00E` in PCF8563 register
order: seconds, minutes, hours, day, weekday, month, year (two digits, 20xx).
`RtcToDayCount` (`01:4c5e`; `01:4ec9` in 0918) reads them; the factory init
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
| `EzCfg` | `02:4a00`, [kernel/src/ezcfg.c](../kernel/src/ezcfg.c), 4386 B release, 4988 B with `EZCFG_RTCLOG` (slot `02:4a00-5fff`) | The module: load/save the file, parse keys, RTC read/write/compare, the backup and restore ops. **No stack argument**: the op is passed in WRAM `$DBFC` so the same entry works for a plain bank-2 `call` and for `FarCallTrampoline` (which shifts stack args by 6). Op 0 LOAD, 1 SAVE, 2 BACKUP, 3 RESTORE, 4 LASTSAVE (also backs up the RTC), 5 LASTLOAD, 6 TIMESET, 7 RELAUNCH, 8 SAVECHK (the BACKUPSAVE stamp check, [modal-prompts.md](modal-prompts.md)). |
| `FastLaunchScan` | `02:4500`, [kernel/src/fastlaunch.c](../kernel/src/fastlaunch.c), 766 B | Now calls `ezcfg` (op LOAD) instead of parsing a file itself; skips `ezgb.cfg` in the lone-ROM count. |
| `FlCfg` | `04:6600`, [kernel/src/flcfg.c](../kernel/src/flcfg.c), 778 B | SET-tab UI, now a client of `ezcfg` through `FarCallEzCfg`. Shrank from 1258 B. |
| `FarCallEzCfg` | `04:5f00`, 8 B | `call FarCallTrampoline; db $00,$4a,$02,$00; ret` |
| `RtcSetHook` | `04:5f10`, 11 B | TIME SET confirm tail: op BACKUP, then `jp DrawTimeAutosaveScreen_redraw` (`$48f5`) |
| `RtcBootHook` | `00:0510`, 27 B | Boot restore: op RESTORE, re-assert `$4000=$11`, replay the displaced `SetFpgaPage(3)` far-call, `jp $0e50` |
| `BatteryDryHook` | `00:0530`, 12 B | `$DBFD=1`, then the displaced `$A201=$88`, `ret` |
| `RtcDumpHook` | `01:7600`, 15 B | `BackupSaveDump` epilogue: `add sp,$0b`, op BACKUP, `ret` |
| `BrowserHideName` | `05:7700`, [kernel/src/browser_hide.c](../kernel/src/browser_hide.c), 567 B | Hides `ezgb.cfg` too, and caps directories at 416 entries ([browser-sort.md](browser-sort.md#record-cap)). Relocated from `08:7a9c` and then `08:7c00` as it grew; `DirListHideNameStub` (`00:04ae`) re-emitted with the new target. |

### Hook map (stock bytes → patch)

| Site | Stock | Patch | Purpose |
|---|---|---|---|
| `00:0e49` | `cd 8d 07 e7 41 04 00` (far-call `SetFpgaPage(3)` after "Micro SD initial OK!") | `jp $0510` + 4 nop | boot restore, then replay |
| `00:18e5` | `01 01 a2 3e 88 02` (`BatteryCheck_markOk`: `$A201=$88`) | `call $0530` + 3 nop | DRY flag |
| `01:6738` (0731) / `01:699a` (0918) | `e8 0b c9` (`BackupSaveDump_epilogueRet`) | `jp $7600` | backup after a dump |
| `04:58d3` | `c3 f5 48` (confirm tail `jp _redraw`) | `jp $5f10` | backup after TIME SET |
| `00:1382` (1.04e `00:1376`) | `c3 70 15` (`LastRomRelaunch` tail, `jp $1570`) | `jp $0588` | RTC backup on relaunch / fast launch (op 7), then `jp $1570` |

Banks 0, 2, 4 and 8 are byte-identical across 1.05e-0731 and 1.05e-0918, so
every injection is the same bytes for both; only the bank-1 site differs
(bank 1 is shifted by `$262` in 0918). The bank-1 hook body itself contains
no version-specific address.

### WRAM

| Addr | Use |
|---|---|
| `$D800-$D9FF` | `CFGBUF`, 512 B: file contents on read, record on write (grown from 256 B and moved down from `$D980` for the third `LASTROM` line) |
| `$DA00-$DA7E` / `$DA7F` | `LR_PATH` (LASTROM path) / `LR_VALID` |
| `$DBFA` | `LIST_CUT`: 1 when `BrowserHideName` cut the directory being listed ([browser-sort.md](browser-sort.md#record-cap)) |
| `$DBFB` | `EZ_RES`, op result byte read by the last-ROM stubs |
| `$DA80` / `$DA81` / `$DA82-$DAF9` | `FL_EN`, `FL_PLEN`, `FL_PATH` (unchanged) |
| `$DB00-$DB0F` | `FL_SCR`, file-name bounce for `f_open` (path must be in WRAM) |
| `$DB10-$DB37` | `FL_DISP` (SET tab, unchanged) |
| `$DB40-$DB46` | `RTC_BK`, stored time, 7 BCD bytes in register order |
| `$DB47` | `RTC_VALID`, 1 when the file held a usable `RTC=` |
| `$DB48-$DB4E` | `RTC_CUR`, the last RTC read (masked) |
| `$DB4F` | `LOG_LEN`, `RTCLOG=` text length |
| `$DB50-$DB56` | `RTC_RAW`, the last RTC read (raw) |
| `$DB60-$DBEB` | `LOG_BUF`, `RTCLOG=` text, 140 B |
| `$DBFC` | `EZ_OP`, operation selector for `ezcfg` |
| `$DBFD` | set by `BatteryDryHook`; unused since mod 4.4 |
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
