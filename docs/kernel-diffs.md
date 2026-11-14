# Stock kernel diffs, byte by byte

The accounting behind [kernel-versions.md](kernel-versions.md): every place
the three stock kernels differ. All three are 163,840 bytes with the same
header (title `EZGB`, `$0147 = $01`).

Byte diffs alone mislead here. When code is inserted partway through a bank,
every later same-bank address shifts, and a byte diff reports those operand
changes as large "replace" regions. Each region below was read as
instructions before being called a change.

## 1.04e to 1.05e-0731

Banks 2, 5, 7 and 8 have the same instructions in both; only the addresses
of the bank-0 routines they call moved, plus the version digit in bank 8.

### Bank 0: +953 bytes

| 1.05e address | Size | What |
|---|---|---|
| `00:092a` `DrawU32Decimal` | -4 | Radix 16 in 1.04e, radix 10 in 1.05e, and it advances its line cursor (`$cc2f`/`$cc30`) differently. A debug printer nothing calls in either build |
| `00:0e89` | +16 | A struct-copy loop also stores one byte to a new global, `$d3f6` |
| `00:15e2` | +13 | The launch path's call to `SetFpga7FD4_B1` |
| `00:1a7a` `SetFpgaPage_B0` | +32 | New: unlock, write the page to `$7FC0`, commit |
| `00:1a9a` `RtcReadPage` | +896 | New: reads the cart clock; the FatFs timestamp sites call it |
| end of bank | -953 | Less `$FF` filler |

The battery check and a few other functions look changed in a byte diff and
are not: their string pointers moved by the 25 bytes inserted above them.

### Bank 1: +3,175 bytes

Almost all of it is the game clock: `IsLeapYear`, `DateToDaysSince1970`,
`RtcToDayCount`, `RtcWriteTimeFromDayDelta` and `RtcReadDaysClearRegs` at
`01:48c6`-`01:5162`, and their hooks in the save path
([kernel-versions.md](kernel-versions.md#104e-to-105e) says what they do).

| 1.05e address | What |
|---|---|
| `01:480b` `SetFpga7FD4_B1` | New: unlock, write a stack-supplied byte to `$7FD4`, commit. On FW5 this is half of the fast-load key |
| `PreLaunchSaveStamp` | Marks an RTC game in save pSRAM (`$A202 = $77`, launch time at `$A210`) |
| `BackupOpenSaverPath`, `BackupSaveDump` | Restore and append the 48-byte RTC record of a `.sav` |

The `$4000 = $11` / `$A000 = $AA` writes in this code select save pSRAM page
`$11` and set the BACKUPSAVE stamp ([psram-save-map.md](psram-save-map.md)).
They are not NOR flash commands.

### Banks 3, 6, 9: +15, +35, +16 bytes

FatFs timestamps. 1.04e stamps directory entries with the constant
`$46210000` (2015-01-01 00:00), loaded as four immediates. 1.05e calls
`RtcReadPage` first and loads the four bytes from its result. Sites, 1.05e
addresses: `03:7619` (`Fsync_B3_updateDir`), `06:7457`
(`Open_B6_createTruncate`, created and modified stamps), `09:7801`
(`Open_B9`, two stamps). Bank 6 has two further small inserts in `Open_B6`
(+17 at `06:7532`, +2 at `06:764f`) that have not been decoded.

### Bank 4: +15 bytes

The SET tab's TIME / AUTO SAVE screen. `DrawTimeAutosaveScreen_redraw`
(`04:48f5`) opens by testing a flag where 1.04e calls `WaitVBlankFlag`;
`DrawTimeAutosaveScreen_savRedraw` draws one extra string (`SAV`, +30 bytes
at `04:4e49`); three jump sequences in the field handlers are 5 bytes
shorter each (`04:545e`, `04:54d5`, `04:54fc`); +3 bytes at `04:566b`.

### WRAM

1.05e's day-count tables sit at `$D6A7`, so the kernel's runtime globals
from `$D6CC` up are 39 bytes higher than in 1.04e. `port-mod.py` carries
this as `WRAM_SHIFT`.

## 1.05e-0731 to 1.05e-0918

Only banks 0 and 1 differ. Banks 2 to 9 are byte-identical.

### Bank 0: 12 bytes

| Offset | 0731 to 0918 | Meaning |
|---|---|---|
| `$014e`-`$014f` | `$7b57` to `$f8b5` | ROM global checksum |
| `$01da` | `$68b6` to `$6b18` | far-call target, +610 |
| `$0f55` | `$6747` to `$69a9` | far-call target, +610 |
| `$1577` | `$5e14` to `$6076` | `RomLoaderMain`, +610 |
| `$15a8` | `$5163` to `$53c5` | `BackupOpenSaverPath`, +610 |
| `$15b5` | `$58b0` to `$5b12` | far-call target, +610 |

### Bank 1: +610 bytes

```
insert  619 bytes at $4c5e
delete    9 bytes at $50cf
delete  610 bytes of $ff filler from the bank tail
```

The inserted routine, `RtcDebugDump` (`01:4c5e`-`01:4ec8`), is an RTC test
screen left in the build. It reads the cart clock, prints `12345678` and
then the year, month, day, hour, minute and second with `DrawU32Decimal`,
and waits for SELECT. No `call`, `jp` or far-call entry in the ROM points at
it, and its seven calls are the only calls to `DrawU32Decimal` in any of the
three kernels.

It opens with the same 370 bytes of clock-reading code as `RtcToDayCount`,
so a byte diff finds the first difference 370 bytes in, at `$4dd0`. The real
`RtcToDayCount` follows at `01:4ec9`, byte for byte the 0731 routine, and
its two callers (`01:505e`, `01:5348`) were repointed.

The 9 deleted bytes are at the end of `RtcWriteTimeFromDayDelta`: 0731 calls
`SetFpgaPage_B1($00)` twice in a row before returning and 0918 drops the
second call.

About 200 two-byte operands after the insertion moved by `+$262` (`+$26b`
between the insertion and the deleted bytes). Stock 0918's bank 1 ends in
2,573 bytes of `$FF`, against 3,183 in 0731.

The two FW5 updaters' program banks (0 and 1) are identical; they differ in
the bitstream they carry ([firmware-diff.md](../stage0/docs/firmware-diff.md)).
