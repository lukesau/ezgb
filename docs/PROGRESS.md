# Decompilation progress

The stock 1.05e-0731 kernel builds from source in [`decomp/`](../decomp/README.md),
byte-identical to stock (`make -C decomp` checks the md5). Ranges there come
from real source; the rest is still disassembly.

> **Correction (2026-10-30).** This page used to list 15 bank-0 functions as
> "matched" C in `kernel/src/` (`register_callback_slots.c`,
> `remove_callback_slot.c`, `install_callback_slot.c`, `vblank_callback.c`,
> `wait_vblank_flag.c`, `lcd_off.c`, `oam_dma_stub.c`, `serial_callback.c`,
> `store_d732_d733.c`, `store_d734_d735_d723.c`). None of them is compiled C:
> they are hand-written GBDK library assembly (`crt0.s`: `.add_int`,
> `.remove_int`, `.vbl`, `.wait_vbl_done`, `.display_off`, the OAM DMA
> template, `.serial_IO`; `drawing.s`: `_gotogxy` at `$2765`, `_color` at
> `$2791`). No SDCC version produces them; the peep files in
> `kernel/tools/peeps/` only forced the bytes. Those C files still work as
> injectable equivalents, but they are not decomp. Only `return_zero`
> (`$1a77`, `1E 00 C9`) may be compiled C.

| Range | Source | Status |
|---|---|---|
| `00:0000`-`01e3` | `decomp/gbdk/crt0.s` (GBDK 2.96a + EZ Flash changes) | Matched |
| `00:0600`-`07bc` | `decomp/gbdk/crt0.s` `_HOME` area | Matched |

## Toolchain findings

**GBDK.** Bank 0 is a GBDK 2.x program's: `crt0.s` from GBDK 2.96a (the
same file as GBDK-2020 3.0.1) with EZ Flash's changes listed in
[`decomp/gbdk/README.md`](../decomp/gbdk/README.md), then other GBDK library
modules (`drawing.s` at least) further up bank 0.

**FatFs.** The FatFs in banks 3, 5, 6, 7 and 9 is **R0.11a**, not R0.10:
the CP437 upper-case table (`ExCvt`, at `09:4082`, inside what `kernel.sym`
calls `MemCpy16_B9`) has the R0.11a values (index 2 `$45`, index `$2d`
`$AD`); `move_window` invalidates the window on a read error (R0.10c+);
`dir_find` resets `lfn_idx` at its start (gone in R0.12). Each bank holds its
own copy of `ff.c`, cut to the API that bank uses: 9 `f_open`/`f_unlink`
(plus code writing a `..` entry, likely `f_mkdir`, inside the `Open_B9`
range), 6 `f_read`, 7 `f_write`, 5 `f_mount` and the directory calls, 3
`f_sync`/`f_lseek`/`f_close`. `ffconf.h`, from the code:

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

**Compiler (open).** The compiled C uses SDCC's gbz80 prologue rule
`(--opt-code-size && frame <= 8) || frame <= 4` for `push af`/`dec sp`
frames, which SDCC dropped in September 2013. Scored against 33 bank-9 FatFs
functions, the closest builds are SDCC trunk from mid-January to March 2012
(3.1.2-3.1.4 development) with `--opt-code-size`: mean byte similarity 0.59
against 0.41-0.48 for the 3.2-3.7 releases and 0.31 for GBDK-2020's. No
function matches byte for byte; the ROM mixes `ld c,(hl)`/`inc hl`/
`ld b,(hl)` with `ld a,(hl+)` and keeps dead `ld c,a` temps, which no build of
the 90 gbz80 codegen commits from November 2011 to March 2012 reproduces.
Either EZ Flash used a patched SDCC or edited the FatFs source in ways that
move the code.
