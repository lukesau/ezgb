# Stock kernel from source

A build of the stock 1.05e-0731 kernel (`ezgb.dat`, md5
`91eb7fc67332ef20b5691029181ff748`) that the C rewrite grows in. It starts as
the rgbds disassembly and replaces routines with real source one at a time;
`make` fails unless the result is still byte-identical to stock.

This is separate from `../disassembly`, which is regenerated from the
modded kernel after every injection. Everything here is stock.

```sh
make -C kernel/1.05e-0731/stock        # build/kernel.gb, checked against the stock md5
```

Needs rgbds and SDCC 4.x (`sdasgb`, `sdldgb`, `sdcc`). No dump is needed: the
build compares against the md5, not a file.

## Layout

| Path | What |
|---|---|
| `asm/` | Stock disassembly (mgbdis + `kernel/1.05e-0731/kernel.sym` names and notes). Hand-maintained from here on: a routine that moves to source is deleted here and replaced by an `INCLUDE` of its generated file. |
| `gbdk/` | GBDK library code the kernel links, as EZ Flash modified it. GPLv2 with linking exception, not this repo's AGPLv3: see `gbdk/README.md`. |
| `tools/sdinc.py` | Assembles or compiles one source with SDCC, links its areas at the stock addresses, and writes each address range as an rgbds include (`db` bytes plus `Name::` labels for the source's global symbols). External symbols come from `kernel.sym`. |
| `build/` | Generated includes and the built kernel (gitignored). |

## Moving a routine to source

1. Write the source: GBDK library asm in `gbdk/`, C in `src/` (once the
   compiler is pinned, see below). Give its globals the names `asm/` uses
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

Compiled C is not in yet: the compiler has not been found.

## Toolchain findings

**GBDK.** Bank 0 is a GBDK 2.x program's: `crt0.s` from GBDK 2.96a (the
same file as GBDK-2020 3.0.1) with EZ Flash's changes, listed in
[gbdk/README.md](gbdk/README.md), then other GBDK library modules
(`drawing.s` at least) further up bank 0. Those library routines are
hand-written assembly, not compiled C.

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
