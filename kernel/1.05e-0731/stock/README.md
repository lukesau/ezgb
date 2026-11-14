# Stock kernel from source

A build of the stock 1.05e-0731 kernel (`ezgb.dat`, md5
`91eb7fc67332ef20b5691029181ff748`) that the C rewrite grows in. It starts as
the rgbds disassembly and replaces routines with real source one at a time;
`make` fails unless the result is still byte-identical to stock.

This is separate from `../disassembly`, which is regenerated from the
modded kernel after every injection. Everything here is stock.

```sh
SDCC29=<sdcc 2.9.0 prefix> make -C kernel/1.05e-0731/stock   # build/kernel.gb, checked against the stock md5
```

Needs rgbds, SDCC 4.x (`sdasgb`, `sdldgb`, `sdcpp`) and SDCC 2.9.0, the
compiler EZ Flash used for the C ([below](#sdcc-290)). No dump is needed: the
build compares against the md5, not a file.

## Layout

| Path | What |
|---|---|
| `asm/` | Stock disassembly (mgbdis + `kernel/1.05e-0731/kernel.sym` names and notes). Hand-maintained from here on: a routine that moves to source is deleted here and replaced by an `INCLUDE` of its generated file. |
| `gbdk/` | GBDK library code the kernel links, as EZ Flash modified it, and GBDK 2.96a's headers (`gbdk/include`) for the kernel C. GPLv2 with linking exception, not this repo's AGPLv3: see `gbdk/README.md`. |
| `src/` | C: FatFs R0.11a (`ff.c`, `option/ccsbcs.c` and headers) as EZ Flash edited it, every edit marked `ezflash:`, `dbg.c`, and the kernel's bank 0 C (`kernel.c`, `fsglue.c`, `diskio.c`). Also `libasm.s`, bank 0's asm runtime (math, `strcpy`, `memset`, `memcpy`) rebuilt from the stock bytes. FatFs is ChaN's license (in the file headers), not this repo's AGPLv3. |
| `tools/sdinc.py` | Assembles or compiles sources with SDCC (`--sdcc29` for 2.9.0), links their areas at the stock addresses, and writes each address range as an rgbds include (`db` bytes plus `Name::` labels for the source's global symbols, and with `--bank` the bank's kernel.sym entry names). External symbols come from `kernel.sym`, under another name with `-a`. |
| `sdcclib/` | SDCC 2.9.0's library C that bank 0 links, unchanged (GNU LGPL v2+). |
| `tools/match.py` | Per-function byte compare of the C against stock, for finding what differs ([Matching](#matching)). |
| `build/` | Generated includes and the built kernel (gitignored). |

## Moving a routine to source

1. Write the source: GBDK library asm in `gbdk/`, C in `src/`. Give its globals the names `asm/` uses
   (`LcdOff::` next to `.display_off::`) so the rest of the disassembly links.
2. Add an `sdinc.py` rule to the `Makefile` with the area placements (`-b`)
   and the address range(s) to emit.
3. In `asm/bank_NNN.asm`, delete the routine's lines and `INCLUDE` the
   generated file in their place.
4. `make`. A wrong byte fails the md5 check; a label the rest of the asm still
   needs fails the rgbds link.

## Status

| Range | Source | What |
|---|---|---|
| `00:0000`-`01e3` | `gbdk/crt0.s` | RST/interrupt vectors, interrupt dispatcher, cartridge header, startup (`KernelEntry`) |
| `00:0600`-`07bc` | `gbdk/crt0.s` | `crt0` `_HOME` area: mode table jump, interrupt list add/remove, VBlank and serial handlers, `display_off`, OAM DMA stub, `banked_call` |
| banks 3, 5, 6, 7, 9 (whole banks) | `src/ff.c`, `src/dbg.c` | FatFs R0.11a, one copy per bank ([FatFs](#fatfs)) |
| `00:07bc`-`1926` | `src/kernel.c` | the kernel's C: `WaitJoypadSelect` to `BatteryCheck`, `SdMenuMain` included ([Bank 0](#bank-0-c)) |
| `00:1926`-`20bb` | `src/fsglue.c`, `src/diskio.c`, `src/option/ccsbcs.c` | the `f_` entry points, the disk layer, `get_fattime`, CP437 conversion |
| `01:68c0`-`7096` | `src/option/ccsbcs.c` | its `_GSINIT` code: `ff_wtoupper`'s tables into WRAM |
| `00:2c42`, `2cd3`, `2d95` | `sdcclib/` | SDCC 2.9.0's library `strrchr`, `strncpy`, `strlen` |
| `00:20bb`-`20e2` | `sdcclib/crt0_rle.s` | SDCC 2.9.0's `__initrleblock` (`RleUnpack`) |
| `00:2826`-`29e6` | `sdcclib/stubs.s`, `div.s`, `shift.s` | SDCC 2.9.0's gbz80 asm library: math stubs, 8/16-bit divide, 32-bit shifts (`div.s` edited, see `sdcclib/README.md`) |
| `00:20f4`-`2826`, `2a5f`-`2a77`, `2d56`-`2d95`, `2eea`-`3d8c` (then `$FF` to `$4000`) | `gbdk/drawing.s`, `cpy_data.s`, `ibmfixed.s`, `pad.s`, `delay.s`, `font.ms`, `init_tt.s` | GBDK's gb library: graphics mode and drawing, VRAM copy and fill, the IBM font, joypad, `delay`, the text font engine |
| `00:20e2`-`20f4`, `29e6`-`2a5f`, `2a77`-`2c42`, `2ca5`-`2cd3`, `2d4c`-`2d56`, `2dba`-`2eea` | `src/libasm.s` | the long, char and int math `stubs.s` jumps to, `strcpy`, `memset`, `memcpy`: rebuilt from the stock bytes, origin unknown |
| `00:01e3`-`0600` | GBDK `drawing.s`, `font.ms` (`_HEADER`) | their mode table jumps, at `$03C9` and `$05B6` (see [GBDK](#toolchain-findings)), in `$FF` fill |

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

kernel.sym names some of this wrong: `Open_B9` is `f_mkdir`, `FsUnlink`
(`09:7cc0`) is a mod label on `$FF` fill, and `U32Mod` (`00:2832`) is what
2.9.0 calls `_divulong_rrx_s`, a division.

## Bank 0 C

The kernel's own C starts at `00:07bc`, right after crt0's `_HOME`, and is
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
  `BootUnpackWramTables` (`01:68b6`) is it, and `RleUnpack` (`00:20bb`) is
  GBDK's `__initrleblock`. `ff_wtoupper`'s `static const` tables are WRAM
  (`$CC33`, `$D00F`), copied there at boot.
- `strrchr`, `strncpy` and `strlen` are SDCC 2.9.0's own library C, built
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
  `LcdOff` `display_off`, `DiNest` `disable_interrupts`. kernel.sym has
  SDCC's `_modulong` and `_divulong` swapped: `U32Div` (`$282c`) is the
  modulo, `U32Mod` (`$2832`) the division. The same goes for the bodies:
  `S32DivImpl` (`$29e6`) and `U32DivImpl` (`$2a77`) return the remainder,
  `S32ModImpl` and `U32ModImpl` the quotient.

## Matching

```sh
SDCC29=<sdcc 2.9.0 prefix> tools/match.py [-v] [-f func] [-b bank]
SDCC29=<sdcc 2.9.0 prefix> tools/match.py -I gbdk/include -D BYTE_IS_UNSIGNED=1 src/kernel.c   # bank 0
SDCC29=<sdcc 2.9.0 prefix> tools/match.py --cflags " " sdcclib/_strncpy.c   # no options, found by content
```

[tools/match.py](tools/match.py) compiles the sources once per bank and
looks up every function and table in that bank of `build/kernel.gb`, with
the operands the linker fills in masked: a table of addresses, or how many
bytes match at the kernel.sym address. All of them match. `-v` shows the
instructions around the first wrong byte. It was how the edits above were
found; `make` then checks the whole bank, jump targets included.

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
> kernel.sym's `Open_B9`: bank 9's one API function is `f_mkdir`, bank 6 has
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
for GBDK-2020's. No function matches byte for byte. The ROM mixes
`ld c,(hl)`/`inc hl`/`ld b,(hl)` with `ld a,(hl+)` and keeps dead `ld c,a`
temporaries, which none of the 90 gbz80 codegen commits from November 2011
to March 2012 reproduces. Either EZ Flash used a patched SDCC or edited the
FatFs source in ways that move the code.

> **Correction (2026-11-14).** The compiler is SDCC 2.9.0 (2009), which the
> search above never built: it tested 3.x and later, trunk from November
> 2011, and GBDK 2.96a's SDCC 2.3.1. With `--opt-code-size`, 2.9.0
> compiles R0.11a `ff.c` with this `ffconf.h` into bank 9's `mem_set`,
> `chk_chr`, `clust2sect`, `ld_clust`, `st_clust`, `sum_sfn`, `validate`,
> `check_fs`, `cmp_lfn`, `fit_lfn` and `dir_read` byte for byte (operands the
> linker fills in masked). The 2012 trunk builds only scored closest, and
> the "patched SDCC" guess is wrong. Found through stage1, built by the same
> compiler without `--opt-code-size`
> ([stage1/decomp](../../../stage1/decomp/README.md#matching)).
> The other guess holds: EZ Flash edited the FatFs source, and with those
> edits every FatFs function matches and the five banks build from C
> ([FatFs](#fatfs)). Bank 9's `mem_cmp`, the one miss in that first test,
> was at the right address; its count is a `BYTE`.
