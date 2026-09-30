# The three official kernels: what differs, and which to use

EZ Flash published three builds of the Jr kernel (`ezgb.dat`). This page says
what actually differs between them, read from the binaries, and which one to
put on your card. The byte-level accounting behind it is in
[DIFF_1.04e_vs_1.05e.md](DIFF_1.04e_vs_1.05e.md) and
[DIFF_1.05e-0731_vs_0918.md](DIFF_1.05e-0731_vs_0918.md).

## Short answer

- **Use the 1.05e kernel on an FW5 cart and the 1.04e kernel on an FW4 cart.**
  The HELP tab shows which firmware the cart has (`FW4` / `FW5`).
- **1.04e to 1.05e is one feature: real-time-clock support.** 1.05e keeps the
  clock of RTC games (Pokemon Gold/Silver/Crystal and other MBC3 titles)
  running between sessions and stamps files with the real date. Nothing else a
  player would notice changed in the kernel.
- **1.05e-0731 and 1.05e-0918 behave identically.** 0918 is 0731 plus a
  leftover debug routine that nothing calls. Use whichever file you have.
- The improvements usually credited to "1.05e" and "0918" other than RTC
  (faster loading, the CGB SD-init fix, slow-card fixes, Super Game Boy
  support) are **not in the kernel**. They are in the FPGA firmware, which only
  the `Update_FW*.gb` updater changes. Swapping `ezgb.dat` does not give or
  take them.

## Kernel and firmware are two different things

| | Kernel | Firmware |
|---|---|---|
| What it is | The menu program, `ezgb.dat` on the card root | The FPGA image inside the cart |
| How it changes | Copy a file. Loaded from the card at every power-on, nothing is flashed | Run `Update_FW*.gb` as a game, which rewrites the cart's config flash |
| Risk | None. Copy the old file back to undo | Can brick the cart (EZ Flash's own notes warn about slow cards and weak batteries; see [1.05e-instability.md](1.05e-instability.md)) |
| Shown on HELP tab as | `K1.04e` / `K1.05e`, a digit hard-coded in the kernel | `FW4` / `FW5`, read from the cart |

Everything on this page is about the kernel. This project never runs or
modifies the updaters.

## Identity

| | 1.04e | 1.05e-0731 | 1.05e-0918 |
|---|---|---|---|
| Package | `juniorkernel-1.04e-FW4` | `juniorkernel-1.05e-FW5` (2020-07-31) | `ezjunior-fw5-0918` (2021-09-18), never posted on EZ Flash's site ([issue #1](https://github.com/lukesau/ezgb/issues/1)) |
| `ezgb.dat` date | 2020-03-06 | 2020-07-29 | 2021-09-09 |
| `ezgb.dat` md5 | `b8c29fa5a94c37200434e4c72f0cdfea` | `91eb7fc67332ef20b5691029181ff748` | `5238ac5987d23b68a19d40e43af8c786` |
| Stock HELP text | `K1.04e` | `K1.05e` | `K1.05e` |
| Updater in the package | `Update_FW4.gb` | `Update_FW5_7-31.gb` | `Update_FW5_2021-9-18.gb` |
| Code size vs 1.04e | baseline | +4,209 bytes | +4,819 bytes |

All three are 163,840 bytes (ten 16 KB banks). The two 1.05e builds show the
same text on the stock HELP tab, so only the md5 tells them apart (the modded
kernel prints `K1.05e-0731` / `K1.05e-0918`).

## 1.04e to 1.05e

4,209 bytes of new code, almost all of it for the clock. By bank: bank 0 +953,
bank 1 +3,175, banks 3 / 4 / 6 / 9 +15 / +15 / +35 / +16. Banks 2, 5, 7 and 8
have the same instructions in both; only the addresses of the bank-0 routines
they call moved, plus the version digit in bank 8.

**RTC games keep time (bank 1).** 1.04e has no code for a game's clock: it
never reads or writes RTC state when it loads or dumps a save. 1.05e adds
2.2 KB of routines at `01:48c6`-`01:5162` (`IsLeapYear`,
`DateToDaysSince1970`, `RtcToDayCount`, `RtcWriteTimeFromDayDelta`,
`RtcReadDaysClearRegs`) and hooks them into the save path:

- Launch (`BackupOpenSaverPath`): a `.sav` that ends in a 48-byte RTC record
  has it restored. The kernel works out how long the game was off from the
  cart's clock and writes the advanced game clock to the FPGA (page `$06`,
  `$A018`-`$A01C`) with a copy in save PSRAM (`$A220`-`$A224`).
- Before launch (`PreLaunchSaveStamp`): an RTC game is marked in PSRAM
  (`$A202 = $77`) with the launch time at `$A210`-`$A213`.
- Save dump at next boot (`BackupSaveDump`): if the mark is there, the 48-byte
  RTC record (five registers, five latched copies, a timestamp) is appended to
  the `.sav`.

**Files get real timestamps (banks 0, 3, 6, 9).** 1.04e's FatFs stamps every
file it creates or updates with a hard-coded 2015-01-01 00:00. 1.05e calls a
new bank-0 routine, `RtcReadPage` (`00:1a9a`, 896 bytes), and stamps the
cart's clock instead.

**One new FPGA register write at launch.** `SetFpga7FD4_B1` (`01:480b`) is
new, and the launch path calls it with `$00` (`00:15e2`). 1.04e never touches
`$7FD4`. What the register does is not identified.

**Small things.**

- SET tab, TIME / AUTO SAVE screen (bank 4): a few dozen bytes of edits; the
  redraw loop tests a flag instead of waiting for VBlank, and one state draws
  an extra `SAV` label.
- The kernel's debug number printer (`DrawU32Decimal`, `00:092a`) prints hex
  in 1.04e and decimal in 1.05e, and advances its line cursor differently.
  Nothing calls it in 1.04e or 0731; its only caller anywhere is the unused
  0918 test screen below.
- WRAM: 1.05e's day-count tables sit at `$D6A7`, so the kernel's runtime
  globals from `$D6CC` up are 39 bytes higher than in 1.04e.

**What is not there.** EZ Flash's 1.05e notes also list faster ("turbo")
loading on CGB and later, and a fix for the "Micro SD Initial Error" on CGB
units without a CPU suffix. The SD driver, the FatFs code apart from the
timestamp, and the ROM loader are instruction-for-instruction the same in both
kernels, so neither item is a kernel change, unless the `$7FD4` write is part
of one. FW5's FPGA image is a new design (64% different from FW4's, see
[fpga-flash-map.md](fpga-flash-map.md)), which is where they would be. The
same goes for the hang at LOADING / OS INIT with slower cards that EZ Flash
acknowledged in the 1.05e release candidate: the kernel diff gives no reason
to expect an older `ezgb.dat` to cure it.

## 1.05e-0731 to 1.05e-0918

Only bank 1 changed, plus six relocated operands and the checksum in bank 0.
Banks 2-9 are byte-identical.

- **A 619-byte routine (`RtcDebugDump`) was added at `01:4c5e` and nothing
  calls it.** It reads
  the cart clock, prints `12345678` and then the year, month, day, hour,
  minute and second with the debug number printer, and waits for SELECT: an
  RTC test screen left in the build. No `call`, `jp` or far-call entry in the
  ROM points at it.
- The real `RtcToDayCount` follows it at `01:4ec9`, byte for byte the 0731
  routine; its two callers were repointed.
- **9 bytes were removed** from the end of `RtcWriteTimeFromDayDelta`: a
  second, redundant `SetFpgaPage($00)` right after the first.
- Net +610 bytes, so everything in bank 1 after the insertion sits `$262`
  higher. Bank 1's free tail shrinks from 3,183 to 2,573 bytes.

So the 0918 kernel does the same thing as the 0731 kernel. What the 0918
package really changes is the firmware: its updater carries two FPGA images,
the fallback one identical to 0731's and the active one 61% different
([fpga-flash-map.md](fpga-flash-map.md)). The improvements reported for 0918
(no SD corruption on slower cards, Super Game Boy support) would be in that
image, and reach a cart only through the updater.

## Which one should I use?

| Your cart (HELP tab) | Use | Why |
|---|---|---|
| `FW5` | 1.05e, either build | RTC games keep time and saves get real dates. 0731 and 0918 do the same thing; take the one from the package you have. |
| `FW4` | 1.04e | It is the kernel EZ Flash shipped for FW4, and the modded 1.04e has run on an FW4 cart. 1.05e on FW4 is untested here: its RTC code drives FPGA registers (`$A018`-`$A01C`, `$7FD4`) that 1.04e never uses, and whether the FW4 image implements them is unknown. |
| `FW5`, but you have 1.04e | It boots (stock 1.04e is confirmed on an FW5 cart) | You give up RTC-game support and file dates and gain nothing identified. |

Things that should not drive the choice:

- **Stability.** EZ Flash called 1.05e/FW5 a release candidate and suggested
  staying on FW4/1.04e unless you need RTC games or the CGB fix. That advice
  is about flashing the firmware. The kernel file adds RTC handling and
  otherwise runs the same SD, loader and menu code as 1.04e.
- **Getting FW5 features on an FW4 cart.** A kernel swap cannot do that.
  RTC-game support on an FW4 cart means updating the firmware, with the risk
  that carries.

### With this project's mod

All three kernels get the same mod (the IPS patches in
[`patches/kernel/`](../patches/kernel/), see
[distribution.md](distribution.md)), with one difference: the fix that stops
an RTC game's clock from resetting when the cart clock has moved backwards
(the negative-elapsed clamp, [ezgb-cfg.md](ezgb-cfg.md)) patches 1.05e's
launch-time RTC code, which 1.04e does not have, so it is absent there.

Features are written and tested against 1.05e-0731 first and carried to the
other two mechanically ([DEVELOPMENT.md](DEVELOPMENT.md#porting-the-mod-to-another-kernel-build)).
For development, 1.04e has the most free ROM (trailing free bytes in bank 0 /
bank 1: 1,581 / 6,358, against 628 / 3,183 in 0731 and 628 / 2,573 in 0918).

## How this was checked

Stock `ezgb.dat` files, md5-verified against the table above, compared on
2026-09-29 two ways: every region where the instruction streams of two builds
stop lining up (`scripts/portmap.py`), and every operand that differs inside
the matching regions and is not a relocated address or a stack-frame offset.
The lists of both are short enough to read in full, and each entry is
accounted for above. Static analysis only: what `$7FD4` does, and how a 1.05e
kernel behaves on FW4 firmware, would need hardware.
