# Stock kernel from source

The stock kernels (`ezgb.dat`) built entirely from source: C compiled with
SDCC 2.9.0, the GBDK and SDCC library code it links, and the asm runtime
rebuilt from the stock bytes. It started as the rgbds disassembly and
replaced routines with source one at a time; `asm/` is now only the bank
sections and `INCLUDE`s. `make` fails unless each result is byte-identical to
stock.

One source builds three kernels:

| Kernel | `make` | Built as | md5 |
|---|---|---|---|
| 1.05e-0918, the latest for FW5 | `0918` | `build-0918/kernel.gb` | `5238ac5987d23b68a19d40e43af8c786` |
| 1.04e, the FW4 kernel | `1.04e` | `build-104/kernel.gb` | `b8c29fa5a94c37200434e4c72f0cdfea` |
| 1.05e-0731 | `0731` | `build-0731/kernel.gb` | `91eb7fc67332ef20b5691029181ff748` |

`make` builds all three. 0731 is the reference: the source was first
matched against it, so the C is 0731's where nothing says otherwise, `K0918`
and `K104` mark where the other two differ ([0918](#0918),
[1.04e](#104e)), and the addresses in the comments are 0731's.

This is separate from `../1.05e-0731/disassembly`, which is regenerated
from the modded kernel after every injection. Everything here is stock.

```sh
make -C kernel/stock          # all three, each checked against stock.sha1
make -C kernel/stock 0918     # only 0918 (or 1.04e, 0731)
```

Needs rgbds, SDCC 4.x (`sdasgb`, `sdldgb`, `sdcpp`) and SDCC 2.9.0, the
compiler EZ Flash used for the C ([below](#sdcc-290)), in `tools/sdcc-2.9.0`
or wherever `SDCC29` points ([INSTALL.md](../../INSTALL.md)). No dump is
needed: the build compares against the hash in
[stock.sha1](../../stock.sha1), not a file.

## Layout

| Path | What |
|---|---|
| `disassembly/` | The annotated disassembly of each stock kernel, one folder per build: mgbdis with this project's names (`kernel.sym`) and notes (`notes.json`), each routine's note starting with the source file that builds it. The build takes its names for addresses from the same `kernel.sym`, so the source and the listing agree; the `.asm` files are not a build input. `kernel/tools/stock-disasm.py <version>` regenerates a folder from the mod's `kernel/<version>/kernel.sym` and `notes.json`, leaving out what describes the mod, and checks that it assembles to the stock kernel. |
| `asm/` | Was the stock disassembly (mgbdis + kernel.sym names); every routine has moved to source, so each bank file is its `SECTION` and the `INCLUDE`s of its generated files. |
| `gbdk/` | GBDK library code the kernel links, as EZ Flash modified it, and GBDK 2.96a's headers (`gbdk/include`) for the kernel C. GPLv2 with linking exception, not this repo's AGPLv3: see `gbdk/README.md`. |
| `src/` | C: FatFs R0.11a (`ff.c`, `option/ccsbcs.c` and headers) as EZ Flash edited it, every edit marked `ezflash:`, `dbg.c`, and the kernel's C (`kernel.c`, `fsglue.c`, `diskio.c` in bank 0, `bank1.c`, `bank2.c`, `bank4_wram.c` and `bank4.c`, `bank8.c`). Also `libasm.s`, bank 0's asm runtime (math, `strcpy`, `memset`, `memcpy`) rebuilt from the stock bytes. FatFs is ChaN's license (in the file headers), not this repo's AGPLv3. |
| `tools/sdinc.py` | Assembles or compiles sources with SDCC (`--sdcc29` for 2.9.0), links their areas at the stock addresses, and writes each address range as an rgbds include (`db` bytes plus `Name::` labels for the source's global symbols, and with `--bank` the bank's kernel.sym entry names). External symbols come from `kernel.sym`, under another name with `-a`. |
| `sdcclib/` | SDCC 2.9.0's library C that bank 0 links, unchanged (GNU LGPL v2+). |
| `tools/match.py` | Per-function byte compare of the C against stock, for finding what differs ([Matching](#matching)). |
| `tools/incdiff.py` | Compares each generated include of a build with a stock kernel and names the first function that differs (how 1.04e was matched). |
| `build-0918/`, `build-104/`, `build-0731/` | Generated includes and the built kernels (gitignored). |

## 0918

0918 is 0731 plus one routine nothing calls, so it builds from the same
source with `K0918` defined for the C (`make K=0918`, against
`disassembly/1.05e-0918/kernel.sym`). Only banks 0 and 1 differ
([kernel-diffs.md](../../docs/kernel-diffs.md#105e-0731-to-105e-0918)):

- `RtcDebugDump` (`01:4c5e`-`4ec9`), an RTC test screen: it reads the clock
  like `RtcToSeconds`, prints `12345678`, the date and the time with
  `DrawU32Decimal`, and waits for SELECT.
- `RtcWriteTimeFromDelta` calls `SetFpgaPage_B1(0)` once at the end, not
  twice.

Everything after `RtcDebugDump` in bank 1 is `$262` higher, `_GSINIT`
included, which the Makefile's `G1`-`G4` place. Bank 0 changes only in the
addresses it calls in bank 1 and the global checksum, which the build sets
with `rgbfix` for every kernel (`crt0.s` has 0731's).

## 1.04e

1.04e is 1.05e without the real-time clock, so it builds from the same
source with `K104` defined for the C (`make K=104`, against
`disassembly/1.04e/kernel.sym`). Banks 2, 5 and 7 are the same C; the rest
differ only where 1.05e added the clock
([kernel-diffs.md](../../docs/kernel-diffs.md#104e-to-105e-0731)):

- FatFs is built with `_FS_NORTC`, so files are stamped 2015-01-01, FatFs's
  default, and there is no `get_fattime` or `SetFpgaPage` in bank 0
  (`diskio.c`).
- Bank 0 (`kernel.c`): no `$d3f6` flag from save pSRAM, no
  `SetFpga7FD4_B1(0)` before launch, and `DrawU32Decimal` prints hex and
  moves along the row instead of down.
- Bank 1: no `SetFpga7FD4_B1`, no date code (`IsLeapYear` to
  `RtcReadDaysClearRegs`), no clock restore in `BackupOpenSaverPath` (which
  opens the save with mode 1, not 3) and no RTC footer in `BackupSaveDump`,
  which sets `color(2, 2, 0)` before its progress dots.
- Bank 4 (`DrawTimeAutosaveScreen`): the screen waits for VBlank and redraws
  the SET box before the mode test, does not redraw `SAV` while editing or
  zero the field on entering edit mode, and the month and day wrap on DOWN
  at 1 (`== 1`, not `< 1`).
- Bank 8: `K1.04e` on the firmware version screen.

The places that move: bank 0's library code from `$20BB` is `$3B9` lower
(the Makefile's `lib`), the runtime globals from `$D6A7` are `$27` lower
(`wram`), bank 1's data starts at `$D3F2` (`D1`), and its `_GSINIT` pieces
at `G1`-`G4`.

## Moving a routine to source

1. Write the source: GBDK library asm in `gbdk/`, C in `src/`. Give its globals the names `asm/` uses
   (`LcdOff::` next to `.display_off::`) so the rest of the disassembly links.
2. Add an `sdinc.py` rule to the `Makefile` with the area placements (`-b`)
   and the address range(s) to emit.
3. In `asm/bank_NNN.asm`, delete the routine's lines and `INCLUDE` the
   generated file in their place.
4. `make`. A wrong byte fails the hash check; a label the rest of the asm still
   needs fails the rgbds link.

## Extra banks

`make MOD=1` builds the same kernels with banks 10 to 15 added, 16 banks
(256 KB) like the modded kernel ([kernel-size.md](../../docs/kernel-size.md)),
in `build-<K>-mod/`. There is no stock check: the ten stock banks are the
stock bytes and only the global checksum differs.

```sh
make -C kernel/stock MOD=1          # all three
make -C kernel/stock 0918 MOD=1     # only 0918
```

A bank is `$FF` unless `kernel/mod/banks/bank<N>.c` exists (`MODSRC` names
another folder). That file is compiled like the kernel's C and linked at
`$4000`:

- A stock routine is called by its `kernel.sym` name. Library routines the
  kernel names differently (`joypad`, `delay`, `strlen`) are in the
  Makefile's `MOD_ALIASES`.
- `__banked` functions call across banks as stock's do, so a new bank needs
  no far stub. A bank can call the new banks below it.
- Nothing places `_DATA`: a file with globals needs a `-b _DATA=` at free
  WRAM first.

Stock code cannot call the new banks yet. Each stock range is linked at its
stock address and size, so a call added to it moves everything after it.

## Status

| Range | Source | What |
|---|---|---|
| `00:0000`-`01e3` | `gbdk/crt0.s` | RST/interrupt vectors, interrupt dispatcher, cartridge header, startup (`KernelEntry`) |
| `00:0600`-`07bc` | `gbdk/crt0.s` | `crt0` `_HOME` area: mode table jump, interrupt list add/remove, VBlank and serial handlers, `display_off`, OAM DMA stub, `banked_call` |
| banks 3, 5, 6, 7, 9 (whole banks) | `src/ff.c`, `src/dbg.c` | FatFs R0.11a, one copy per bank ([FatFs](#fatfs)) |
| `00:07bc`-`1926` | `src/kernel.c` | the kernel's C: `WaitJoypadSelect` to `BatteryCheck`, `SdMenuMain` included ([Bank 0](#bank-0-c)) |
| `00:1926`-`20bb` | `src/fsglue.c`, `src/diskio.c`, `src/option/ccsbcs.c` | the `f_` entry points, the disk layer, `get_fattime`, CP437 conversion |
| `01:4000`-`68b6` | `src/bank1.c` | the kernel's C in bank 1: the browser rows, the RTC and date code, the save load and write, the launch setup and the ROM info screens ([Bank 1](#bank-1-c)) |
| `01:68b6`-`68c0` | `src/kernel.c` | the start of `_GSINIT` (`gsinit`): `wMarqueePos`'s initializer |
| `01:68c0`-`7096` | `src/option/ccsbcs.c` | its `_GSINIT` code: `ff_wtoupper`'s tables into WRAM |
| `01:7096`-`7390` | `src/bank1.c` | its `_GSINIT` code: the tables of `WToUpper_B1` and the date code |
| `01:7390`-`8000` | `gbdk/crt0.s` | `_GSINITTAIL`'s `ret`, then `$FF` fill |
| `02:4000`-`8000` | `src/bank2.c` | bank 2: the SD sector reads and writes `diskio.c` calls ([Bank 2](#bank-2-c)) |
| `04:4000`-`40ab` | `src/bank4_wram.c` | `RomLoad_InitiatePoll`, linked for `$D100`, where it runs ([Bank 4](#bank-4-c)) |
| `04:40ab`-`8000` | `src/bank4.c` | the rest of bank 4: the FPGA ROM loader commands and register writes, `CStrCat`, `U32ToAscii`, the TIME and AUTO SAVE screen ([Bank 4](#bank-4-c)) |
| `08:4000`-`8000` | `src/bank8.c` | bank 8: an unused 8x12 font and QR code, the FW version screen, the menu tabs, the message boxes, the last ROM buttons, and bank 4's loader helpers again ([Bank 8](#bank-8-c)) |
| `00:2c42`, `2cd3`, `2d95` | `sdcclib/` | SDCC 2.9.0's library `strrchr`, `strncpy`, `strlen` |
| `00:20bb`-`20e2` | `sdcclib/crt0_rle.s` | SDCC 2.9.0's `__initrleblock` (`RleUnpack`) |
| `00:2826`-`29e6` | `sdcclib/stubs.s`, `div.s`, `shift.s` | SDCC 2.9.0's gbz80 asm library: math stubs, 8/16-bit divide, 32-bit shifts (`div.s` edited, see `sdcclib/README.md`) |
| `00:20f4`-`2826`, `2a5f`-`2a77`, `2d56`-`2d95`, `2eea`-`3d8c` (then `$FF` to `$4000`) | `gbdk/drawing.s`, `cpy_data.s`, `ibmfixed.s`, `pad.s`, `delay.s`, `font.ms`, `init_tt.s` | GBDK's gb library: graphics mode and drawing, VRAM copy and fill, the IBM font, joypad, `delay`, the text font engine |
| `00:20e2`-`20f4`, `29e6`-`2a5f`, `2a77`-`2c42`, `2ca5`-`2cd3`, `2d4c`-`2d56`, `2dba`-`2eea` | `src/libasm.s` | the long, char and int math `stubs.s` jumps to, `strcpy`, `memset`, `memcpy`: rebuilt from the stock bytes, origin unknown |
| `00:01e3`-`0600` | GBDK `drawing.s`, `font.ms` (`_HEADER`) | their mode table jumps, at `$03C9` and `$05B6` (see [GBDK](#toolchain-findings)), in `$FF` fill |

Nothing is left as disassembly.

## FatFs

Each of banks 3, 5, 6, 7 and 9 is one compile of `src/ff.c` with `-DBANK=n`,
code from `$4000` and `$FF` fill after it. Banks 5, 6 and 9 link `src/dbg.c`
first, an empty function at `$4000`. The globals (`FatFs`, `Fsid`, `LfnBuf`)
are shared at `$C5A5`. What each bank holds:

| Bank | API | Other functions cut |
|---|---|---|
| 3 | `f_sync`, `f_close`, `f_lseek` | `dir_read`, `get_fileinfo`, `check_fs` |
| 5 | `f_mount`, `f_chdir`, `f_getcwd`, `f_opendir`, `f_closedir`, `f_readdir` | (readonly build, see below) |
| 6 | `f_open`, `f_read` | `sync_fs`, `dir_read`, `get_fileinfo`, `check_fs` |
| 7 | `f_write` | `remove_chain`, `check_fs`, `find_volume` |
| 9 | `f_mkdir` | `get_fileinfo` |

No bank has `dir_remove`, `f_stat`, `f_getfree`, `f_truncate`, `f_unlink`,
`f_chmod`, `f_rename` or `f_utime`. EZ Flash's edits to R0.11a, all marked
`ezflash:` in the source:

- The `f_` API is `__banked` (callers use `banked_call`), except bank 3's
  `f_sync`, which its `f_close` calls directly.
- `mem_cpy` and `mem_cmp` take a `BYTE` count, and so does `mem_set` outside
  bank 9.
- Bank 5 is readonly code (`_FS_READONLY` set after `ff.h`, so FATFS keeps
  the writable layout) but keeps `find_volume`'s write-protect checks, and
  its `clust2sect` and `get_fat` are `__banked`.
- `find_volume` in banks 3, 6 and 9 returns `FR_OK` after the "already
  mounted" check: only bank 5 mounts.
- Trace calls to `dbg_out` (`src/dbg.c`, our name): `0x77` and the name's
  `NSFLAG` in `follow_path` (banks 5, 6, 9), and `0x4413`/`dcl`,
  `0x3333`/`res`, `0x2222`/`res` in bank 9's `f_mkdir`.
- Bank 9's `sync_fs` assigns the `disk_ioctl` result to `res`.

The mod's kernel.sym names some of this wrong: its `Open_B9` is `f_mkdir`,
its `FsUnlink` (`09:7cc0`) is a mod label on `$FF` fill, and its `U32Mod`
(`00:2832`) is what 2.9.0 calls `_divulong_rrx_s`, a division. The names
here ([disassembly/](disassembly/)) are corrected: `Mkdir_B9`, `U32Div`.

## Bank 0 C

The kernel's C starts at `00:07bc`, right after crt0's `_HOME`, and is
built with GBDK 2.96a's headers and `-DBYTE_IS_UNSIGNED=1`, which makes
GBDK's `BYTE`/`WORD`/`DWORD` the unsigned types FatFs uses (`integer.h` then
skips its own; that guard is ours). Function names are kernel.sym's, and a
`/* BB:AAAA */` comment above each definition gives `match.py` its address.

All of bank 0's kernel C builds from source. `SdMenuMain` (`$0de4`-`$16f4`:
the mount, save backup, file browser and launch, 2.2 KB) took reading SDCC
2.9.0's register allocator (`src/z80/ralloc.c`): gbz80 has only `b` and `c`
to allocate, so one value more or less in a register anywhere in a big
function moves the rest. Its source forms are inferred from that, not
known:

- `SetFpga7F37_B4((wD3F0 << 7) | (char)wD3EB)`: the cast needs a register
  while `res` is live across the launch calls, which spills `res` for the
  whole function.
- `FR_OK != res` for the mount, chdir and opendir results: SDCC folds
  `res != FR_OK` into a plain test but not this.
- `memset((void *)(UINT16)&wFno, ...)`: casts of `&wFno` itself fold (it is
  constant); the round trip through an integer leaves a real cast.
- `keys = joypad()` in the file-error wait loop too: that keeps `keys` live
  across the last-ROM loop, so its 16-bit copy stays on the stack.

What fitting it showed:

- SDCC 2.9.0 gives a function's first-declared local the highest stack
  slot. A frame that is the right size but has its slots shuffled is a
  declaration-order question.
- A value stock keeps in a stack slot can be a compiler temporary rather
  than a variable: `DrawString` copies its `s` parameter, `DirList` reads
  `f_readdir`'s result through a variable.
- `$08b6` is an empty function nothing calls (`Unused_08b6`).
- Hardware registers are read as `*(volatile UINT8 *)addr`; where the code
  is busy SDCC keeps the address in a stack temporary, which looks like a
  pointer variable but isn't one.
- `SdMenuMain`'s keys are a `UINT8`; the 16-bit value stock keeps is the
  cast for comparing with GBDK's `J_` constants, which are `U` (unsigned
  int).
- SDCC 2.9.0 turns a local into a register candidate unless it is
  volatile, has its address taken, or may be read before it is set; a
  long-lived one is then spilled whole or kept in a register whole, so
  the stack layout of a big function depends on all of it.
- `$1926`-`$20bb` is three files: `fsglue.c`, banked wrappers around the
  `f_` calls; FatFs's `diskio.c` (sector I/O through bank 2, the RTC as
  `get_fattime`); and R0.11a's `option/ccsbcs.c`, unchanged.
- The C files' `_GSINIT` area is linked into bank 1:
  `BootUnpackWramTables` (`01:68b6`) is crt0's `gsinit`, `RleUnpack`
  (`00:20bb`) is `__initrleblock`, and the `ret` at `01:7390` is crt0's
  `_GSINITTAIL`. `ff_wtoupper`'s `static const` tables are WRAM
  (`$CC33`, `$D00F`), copied there at boot.
- `strrchr`, `strncpy` and `strlen` are SDCC 2.9.0's library C, built
  with no options (`sdcclib/`). GBDK 2.96a has no `strrchr` or `memset`;
  `Memset` and `Memcpy` are hand-written asm (`src/libasm.s`). SDCC 2.9.0's gbz80 asm
  library is there too: `stubs.s`, `div.s` and `shift.s` at `$2826`, and
  `crt0_rle.s`'s `__initrleblock` (`RleUnpack`).
- The long and char math that `stubs.s` jumps to, with `memset` and
  `memcpy`, is in no SDCC release (2.7.0 to 4.x, every revision of
  `mul.s`) and no GBDK (2.0.17, 2.96a, 4.0). `src/libasm.s` is a
  reconstruction from the stock bytes under SDCC's runtime names. It works
  on byte arrays with the length in B, writes 33 (`EDOM` in SDCC's
  `errno.h`) to `errno` (`$D6C7`) on a zero divisor, and the multiply
  loads its arguments with `ld hl,sp+2`. Two float helpers sit in it
  unreferenced. GBDK's libc C (`_divulong.c` and the rest) and SDCC
  2.9.0's do not match it.
- Bank 0's GBDK library under kernel.sym names: `ReadJoypad` is `joypad`,
  `Delay` `delay`, `PlotPixelXY` `plot_point`, `SetTextCursor` `gotogxy`,
  `DrawGlyphAdvance` `wrtchr`, `StoreDrawParams` `color`, `DrawRect`
  `box`, `ApplyBasename` `strcpy`, `WaitVBlankFlag` `wait_vbl_done`,
  `LcdOff` `display_off`, `DiNest` `disable_interrupts`. The mod's
  kernel.sym has SDCC's long modulo and division swapped, stubs and bodies.
  Corrected here: `S32Mod` (`$2829`), `U32Mod` (`$282c`), `S32Div`
  (`$282f`), `U32Div` (`$2832`); `S32ModImpl` (`$29e6`) and `U32ModImpl`
  (`$2a77`) return the remainder, `S32DivImpl` and `U32DivImpl` the
  quotient.

## Bank 1 C

`src/bank1.c` is all of bank 1's code, `$4000`-`$68b6`, built like
`kernel.c`. Its initialized data (two month tables, a year table and
`WToUpper_B1`'s tables) lands in WRAM from `$D3F9`, filled by its `_GSINIT`
code at `$7096`.

- The mod's kernel.sym gets several bank 1 names wrong. Corrected here:
  - `FormatFileSize` (`$45b3`) is FatFs's `ff_wtoupper` as `ffunicode.c`
    has it from R0.12 on (R0.15's copy matches, tables included). It is
    banked and nothing calls it: `WToUpper_B1`.
  - `BuildSaverBackupPath` (`$5736`) bubble-sorts the browser's entries by
    name: `SortEntries_B1`.
  - `PreLaunchSaveStamp` (`$55c2`) is the shared tail of
    `BackupOpenSaverPath`, not a function: `BackupOpenSaverPath_stamp`.
  - `DateToDaysSince1970` returns seconds since 1970, less eight hours
    (the RTC holds UTC+8): `DateToSecondsSince1970`.
  - `wFileSizeFmtLo`/`Hi` (`$D3F9`, `$D5EB`) are `WToUpper_B1`'s tables:
    `wWToUpperCvt1`, `wWToUpperCvt2`.
- `$C0A0` is a 512-byte sector buffer (`wSaveBuf`). A `.sav`'s 48-byte RTC
  footer is read into it, so the game's MBC3 clock registers sit there one
  per 4 bytes.
- `BackupSaveDump` (`$643a`) is not banked and takes a path it does not
  use; `BackupSavePrompt` passes `""`. `BackupOpenSaverPath` also ignores
  its second argument.
- Forms that matter: `(UINT16)(row - 1) + 2` (the cast stops a constant
  fold), `j * 255` in the sort (SDCC strength-reduces it into the running
  offset stock has), `volatile` RTC register reads, `wSaveBuf[n]` as an
  array, and `volatile` locals plus `(int)sel < 1` in `BootRomInfoMenu`,
  which reproduce stock keeping all three locals on the stack.
- The ROM info screen prints the RAM size in hex (radix 16), so 128 KB
  shows as `80KB`.

## Bank 2 C

`src/bank2.c` is all of bank 2 (896 bytes, then `$FF`): `SdRead` and
`SdWrite` (`DiskRead_B2` and `DiskWrite_B2` in the mod's kernel.sym), which `diskio.c`
calls, and their two helpers. Each sends at most four sectors a command:
the LBA to `$7FB0`-`$7FB3`, the count to `$7FB4` (`+$80` to write), then
waits while `$A000` reads `$E1`. Both copy `count * 512` bytes through the
`$A000` window for every command and never advance `buff`, so a transfer of
more than four sectors would go wrong; `SdWrite` ends with `delay(10)`.

- The LBA bytes are `(sector + i) & 0xffu` and
  `((sector + i) & 0xff00) >> 8u` and so on: the `u` on the shift count
  makes SDCC 2.9.0 push it as a 16-bit int, as stock does, and the `u` on
  the first mask keeps the double widening stock has.
- `SdRead` compares `count - i > 4u` and takes `4u : (BYTE)(count - i)`;
  `SdWrite` the plain `> 4 ? 4 : count - i`. The busy wait is
  `SdWindowPeek() == 0xe1u` (a 16-bit compare).

## Bank 4 C

All of bank 4 builds from source, in two objects.

- `RomLoad_InitiatePoll` (`$4000`, `src/bank4_wram.c`) runs from WRAM:
  `RomLoad_BuildAndRunPoll` copies 255 bytes from `$4000` to `$D100` and
  calls it there. It is linked for `$D100` (its jumps go to `$D1xx`) and its
  bytes are placed at `$4000`, so it is its own object; the rest of the bank
  calls it by its `$4000` symbol. `RomLoad_ResetIntoRom_B4` is copied to
  `$D000` the same way but linked in ROM as normal.
- `src/bank4.c` is the rest, from `RomLoad_Build_B4` (`$40ab`, a byte
  copy). `RomLoad_Build_B4` keeps `n` in `c` only with local copies of all
  three arguments, `src` declared `char *` against the `UINT8 *` copy, and
  loop induction off (`#pragma noinduction` between `save` and `restore`).
  With induction on, SDCC 2.9.0 makes a loop copy of each induction
  variable, and the parameter `n`'s copy comes last and has no spill
  location, so the allocator spills it; for the whole file the pragma breaks
  `CStrCat` and `U32ToAscii`.
- `RomLoad_InitiatePoll`'s second wait loop reads `p` from its stack slot
  into `de` as stock does only as `UINT8 * volatile p` assigned
  `(volatile UINT8 *)0xa000`, with one `st` shared by both loops (its live
  range over the second loop takes `c`).
- `DrawTimeAutosaveScreen` (`$46f4`, 4,658 bytes) matches as one function
  with three `char[7]` arrays (the RTC's BCD, what was last drawn, the time
  being set).
- SDCC 2.9.0 calls `__moduschar`/`__divuschar` for a `char` by a
  constant. Its gbz80 library has no such routines; stock calls
  `__moduchar`/`__divuchar` (`U8Mod`, `U8Div`) there, so the Makefile
  resolves them so.
- `U32ToAscii` is bank 0's `U32ToAscii_B0` plus padding to two digits.
- `InitTimeAutosaveFpga_B4` sets the cart RTC to 2019-07-24 11:22:33.

## Bank 8 C

`src/bank8.c` is all of bank 8, one file. SDCC 2.9.0 emits a const after the
function that follows its declaration, which puts the font after
`PlotIconGlyphs` and the QR code after `Fpga7FD2WaitClear_B8`, as in stock.

- `wFont8x12` (`$413e`): 128 glyphs of 12 rows, bit 7 the left pixel, and
  one more `$00`. `PlotIconGlyphs` draws one with `plot_point`. Nothing
  calls it.
- `wQrCode` (`$478d`): a 70x70 QR code, one RGB555 word a pixel (`$0000`,
  `$7FFF`), 9,800 bytes. Nothing reads it. Four unused bytes follow it.
- The loader helpers are bank 4's again under `_B8` names.
  `RomLoad_Build_B8` is the same code as `RomLoad_Build_B4` and needs the
  same form. `Fpga7FD2WaitClear_B8` is built for `$473f` and run from
  `$D000`; its loop jumps back into ROM, which works because bank 8 is
  mapped. `RomLoad_ClearCartWindow_B8` (a signed 32-bit counter) is not
  called.
- `DrawFwVersionScreen` shows `FW` plus the cart's version (page 4,
  `$A000`, in decimal) and `K1.05e`, `ver:` and `www.ezflash.cn`, until
  SELECT. Its buffer is `char buf[20] = "FWx  K1.05e"`, which SDCC 2.9.0
  fills one byte at a time.
- `DrawMenuTabs` (`$7169`, name ours) draws the SD, SET and HELP tabs with
  the selected one highlighted. Tab 0 clears the strip first, tabs 1 and 2
  the screen below it; tab 3 only clears below it.
- The strings are stock's: `ver:`, `[B]return`, `[A]start`.

## Matching

```sh
SDCC29=<sdcc 2.9.0 prefix> tools/match.py [-v] [-f func] [-b bank]
SDCC29=<sdcc 2.9.0 prefix> tools/match.py -I gbdk/include -D BYTE_IS_UNSIGNED=1 src/kernel.c   # bank 0
SDCC29=<sdcc 2.9.0 prefix> tools/match.py --cflags " " sdcclib/_strncpy.c   # no options, found by content
```

[tools/match.py](tools/match.py) compiles the sources once per bank and
looks up every function and table in that bank of `build-0731/kernel.gb`, with
the operands the linker fills in masked: a table of addresses, or how many
bytes match at the kernel.sym address. All of them match. `-v` shows the
instructions around the first wrong byte. It was how the edits above were
found; `make` then checks the whole bank, jump targets included. For 0918
or 1.04e, add `--rom`, `--sym` with that kernel's kernel.sym and
`--sym-pins`.

`tools/incdiff.py build-104` compares every generated include of a build
with a stock kernel (default 1.04e's), and names the function holding the
first differing byte, `-v` with the bytes around it.

## SDCC 2.9.0

Build it from `sdcc-src-2.9.0.tar.bz2` (SourceForge), z80 port only, with a
current compiler given old C:

```sh
CFLAGS="-O1 -fcommon -std=gnu89 -Wno-error -Wno-implicit-function-declaration -Wno-int-conversion -Wno-implicit-int" \
CXXFLAGS="-O1 -fcommon -std=gnu++98" ./configure --prefix=<prefix> \
  --disable-mcs51-port --disable-ds390-port --disable-ds400-port --disable-hc08-port \
  --disable-pic-port --disable-pic16-port --disable-xa51-port --disable-avr-port \
  --disable-s08-port --disable-r2k-port --disable-ucsim --disable-device-lib \
  --disable-packihx --disable-sdcpp --disable-sdcdb --disable-non-free
make && make install
```

It ships no `sdcpp` or `sdasgb`. Link `sdasgb` from SDCC 4.x into
`<prefix>/bin`, and give it an `sdcpp` that drops the `-obj-ext=` option
2.9.0 passes, which SDCC 4.x's `sdcpp` reads as `-o` and then writes
nothing:

```sh
#!/bin/sh
for a; do shift; case $a in -obj-ext=*) ;; *) set -- "$@" "$a";; esac; done
exec /path/to/sdcc-4/bin/sdcpp "$@"
```

## Toolchain findings

**GBDK.** Bank 0 is a GBDK 2.x program's: `crt0.s` from GBDK 2.96a (the
same file as GBDK-2020 3.0.1) with EZ Flash's changes, listed in
[gbdk/README.md](gbdk/README.md), then other GBDK library modules
further up bank 0: `drawing.s`, `cpy_data.s`, `ibmfixed.s`, `pad.s`,
`delay.s`, `font.ms` and `init_tt.s`, all from source now. They match
GBDK 2.96a's except for two layout points in `drawing.s` (marked
`;; ezgb:`), so EZ Flash's GBDK was a near revision rather than 2.96a
itself. EZ Flash's `global.s` has `.MODE_TABLE` at `$01E2`,
and their linker appended each module's `_HEADER` piece after the last
instead of placing it at its `.org`: crt0's ends at `$01E3`, so drawing's
`jp .gmode` lands at `$01E3+$01E6 = $03C9` and font's `jp .tmode` at
`$03CC+$01EA = $05B6`. The table itself (`$01E6`, `$01EA`) is `$FF`, so
`set_mode` would jump into the fill; nothing calls `mode()`, and GBDK's
drawing and text routines call `.gmode`/`.tmode` themselves.
All of bank 0 now builds from source.

**FatFs.** The FatFs in banks 3, 5, 6, 7 and 9 is R0.11a. The CP437
upper-case table (`ExCvt`, at `09:4082`) has the R0.11a values,
`move_window` invalidates the window on a read error (R0.10c and later),
and `dir_find` resets `lfn_idx` at its start (gone in R0.12). Each bank
holds its own copy of `ff.c`, cut to the API that bank uses:

| Bank | API |
|---|---|
| 9 | `f_open`, `f_unlink` |
| 6 | `f_read` |
| 7 | `f_write` |
| 5 | `f_mount` and the directory calls |
| 3 | `f_sync`, `f_lseek`, `f_close` |

> **Correction (2026-11-14).** Banks 9 and 6 are wrong above, and so is
> the mod's kernel.sym's `Open_B9`: bank 9's one API function is `f_mkdir`, bank 6 has
> `f_open` as well as `f_read`, and no bank has `f_unlink`. See
> [FatFs](#fatfs).

`ffconf.h`, read from the code:

| Option | Value | Evidence |
|---|---|---|
| `_FS_READONLY`, `_FS_MINIMIZE` | 0, 0 | write and directory functions present |
| `_USE_LFN`, `_MAX_LFN` | 1, 255 | DIR `lfn`/`lfn_idx` at `$16`/`$18`; `create_name` compares with 255; no 512-byte stack buffer |
| `_CODE_PAGE` | 437 | the `ExCvt` table |
| `_FS_RPATH` | 2 | `f_getcwd`; FATFS `cdir` before `n_fatent` (`$16`) |
| `_WORD_ACCESS` | 1 | `LD_WORD` as two plain byte loads through a pointer |
| `_FS_TINY`, `_USE_FASTSEEK` | 0, 0 | FIL buffer at `$20` in `f_read`/`f_write`, nothing at `$22`; `f_lseek` never reads `$20` |
| `_FS_LOCK`, `_FS_REENTRANT` | 0, 0 | no lock helpers; struct offsets leave no room |
| `_MAX_SS`, `_VOLUMES` | 512, 1 (assumed) | no `ssize` field |

**Compiler (open).** The code has the shape SDCC gives C for the sm83
target with the stack calling convention (`--sdcccall 0`): parameters read
through `ld hl, sp+N`, callers cleaning up with `add sp, N`, and
`push af` / `inc sp` for a one-byte argument. It uses the gbz80 prologue
rule `(--opt-code-size && frame <= 8) || frame <= 4` for `push af`/`dec sp`
frames, which SDCC dropped in September 2013. Scored against 33 bank-9
FatFs functions, the closest builds are SDCC trunk from mid-January to
March 2012 (3.1.2 to 3.1.4 development) with `--opt-code-size`: mean byte
similarity 0.59, against 0.41 to 0.48 for the 3.2 to 3.7 releases and 0.31
for GBDK-2020's. No function matches exactly. The ROM mixes
`ld c,(hl)`/`inc hl`/`ld b,(hl)` with `ld a,(hl+)` and keeps dead `ld c,a`
temporaries, which none of the 90 gbz80 codegen commits from November 2011
to March 2012 reproduces. Either EZ Flash used a patched SDCC or edited the
FatFs source in ways that move the code.

> **Correction (2026-11-14).** The compiler is SDCC 2.9.0 (2009), which the
> search above never built: it tested 3.x and later, trunk from November
> 2011, and GBDK 2.96a's SDCC 2.3.1. With `--opt-code-size`, 2.9.0
> compiles R0.11a `ff.c` with this `ffconf.h` into bank 9's `mem_set`,
> `chk_chr`, `clust2sect`, `ld_clust`, `st_clust`, `sum_sfn`, `validate`,
> `check_fs`, `cmp_lfn`, `fit_lfn` and `dir_read` exactly (operands the
> linker fills in masked). The 2012 trunk builds only scored closest, and
> the "patched SDCC" guess is wrong. Found through stage1, built by the same
> compiler without `--opt-code-size`
> ([stage1/decomp](../../stage1/decomp/README.md#matching)).
> The other guess holds: EZ Flash edited the FatFs source, and with those
> edits every FatFs function matches and the five banks build from C
> ([FatFs](#fatfs)). Bank 9's `mem_cmp`, the one miss in that first test,
> was at the right address; its count is a `BYTE`.
