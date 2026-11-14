# Stock stage1 in C

EZ Flash's stage1, the FW4 and FW5-0918 versions, rewritten in C from the
annotated disassemblies in [../fw4](../fw4) and [../fw5-0918](../fw5-0918).
EZ Flash compiled it with SDCC 2.9.0 and no options. With that compiler
`make` builds both firmwares' stage1 byte for byte: same md5 as the stock
`kernel.gb` from the FPGA.

One source covers both firmwares. FW5-0918 differs from FW4 only in
`main.c` (and the header), under `#if FW == 5`; the rest is the same code,
`$31` bytes higher in bank 0 ([../stock.md](../stock.md#what-it-does)).

```bash
stage1/decomp/tools/build-sdcc29.sh   # once: SDCC 2.9.0 into tools/sdcc-2.9.0
make -C stage1/decomp                 # build/fw4/stage1.gb and build/fw5/stage1.gb
make -C stage1/decomp match           # per function, if one ever differs
```

Needs a current SDCC (`sdcpp`, `sdasgb`, `sdldgb`; 2.9.0's own preprocessor
and linker no longer build), rgbds, and a C compiler to build SDCC 2.9.0
(`build-sdcc29.sh` fetches its source release, or takes the tarball as an
argument). No stock binary is needed: the asm comes from the tracked
disassemblies. When `stage1/<fw>/kernel.gb` is there, `make` compares the ROM
with it and fails if they differ.

## The build

[tools/link.py](tools/link.py) compiles each file with SDCC 2.9.0
(`sdcc -mgbz80`), links with sdldgb at the stock addresses, resolving what
the C calls from the firmware's `kernel.sym` (GBDK names that differ are in
`ALIASES`), and writes the linked bytes as two rgbds includes. These replace
the C regions in a copy of the disassembly (`build/fw<n>/asm/`), and rgbds
builds the ROM. The GBDK `crt0` and library stay assembly: they are GBDK's,
not EZ Flash's, and the disassembly already rebuilds them byte for byte.

| Where | Area | What |
|---|---|---|
| `00:05BC`-`2731` | `_CODE` | `main.c`, `diskio.c`, `pff.c`, `sd.c` |
| `01:4000`-`40AD` | `_HANDOFF` | `handoff_poll.c`, linked to run at `$D100` |
| `01:40AE`-`4133` | `_CODE_1` | `handoff.c` |
| `01:4134`-`415F` | `_GSINIT` | the startup code for `main.c`'s initialized message pointers, which crt0 calls (`InitMessages`); crt0's `ret` follows |
| `$C0A0`-`$C4A9` | `_DATA` | `LoadCmd`, the message pointers, `FatFs`, the sector buffer |

What the build does that EZ Flash's tools did and SDCC 2.9.0 does not:
it writes the bank word of each banked call (2.9.0 writes 0: `BANKS` in
`link.py`), and it stores `HandoffPoll`, linked for `$D100`, at `01:4000`.

## Matching

```bash
stage1/decomp/tools/match.py [fw4|fw5-0918] [-v]
```

[tools/match.py](tools/match.py) compiles each file with SDCC 2.9.0 and
compares every function `kernel.sym` names with the firmware's `kernel.gb`,
masking operands the linker fills in, so a difference shows up by function.
All of them match: 41 functions on FW4, 42 on FW5-0918 (with
`FpgaSetBootCpu`).

The kernel was built by the same compiler, with `--opt-code-size`
([kernel/1.05e-0731/stock](../../kernel/1.05e-0731/stock/README.md#toolchain-findings)).

What fitting the C to it showed about EZ Flash's source:

- Constants with a `U` suffix: GBDK 2.x's `J_B` is `0x20U`, the SD busy
  status is `0xE1U`, the LBA shifts are `>> 8U`. 2.9.0 compares and passes
  those as 16-bit values, which is what stock does.
- Constant addresses as plain casts, `(UBYTE *)0xA000`, not through a
  `volatile` macro. The two status loops in `HandoffPoll` read
  `*(volatile UBYTE *)0xA000` into one variable.
- `disk_readp_impl` and `DiskRead` are banked functions, though they sit in
  bank 0: callers use `banked_call` and the callees read arguments 4 bytes
  higher. 2.9.0 writes the bank word as 0; stock has `$FFFF` for these and
  1 for `LoadKernel`, so EZ Flash's tools filled it in.
- 2.9.0 gives the first-declared local the highest stack slot, so local
  order is fixed by the frame (`main` declares `fs` first). Slots stock
  uses that no local explains are the compiler's temporaries: `main` has
  no `tmp` or `csize`, and `PrintNumber` no `len`.
- The load command is a global array, `LoadCmd[512]`, the first thing in
  RAM (`$C0A0`). 2.9.0 folds a pointer that starts at a constant address
  but not one that starts at an array, which is why stock's `main` keeps
  its table pointer on the stack and adds 4 at run time.
- The three "not found" message pointers are `UBYTE *` and the SD error
  one `char *`: passing a `UBYTE *` to `puts(char *)` loads it through
  `bc`, as stock does for those three only. `main` keeps the `pf_mount`
  and `pf_open` results in one `res` variable.
- `PrintNumber` is K&R's `itoa` with the reversal written inline.
- Petit FatFs is R0.03a unchanged.

## What is C and what stays assembly

| FW4 range | File | What |
|---|---|---|
| `00:0000`-`01E3` | asm | GBDK `crt0`: vectors, header, startup |
| `00:0400`-`05BB` | asm | GBDK `crt0` `_HOME`: interrupt lists, VBlank and serial handlers, `display_off`, OAM DMA stub, `banked_call` (`FarCallTrampoline`) |
| `00:05BC`-`0B4C` | [src/main.c](src/main.c) | six dead helpers, `FpgaSetMode`, FW5's `FpgaSetBootCpu`, `main`, then its strings |
| `00:0BE6`-`0C15` | [src/diskio.c](src/diskio.c) | `disk_initialize`, `disk_readp`, the template's unused `disk_writep` |
| `00:0C16`-`24E2` | [src/pff.c](src/pff.c) | Petit FatFs, plus EZ Flash's accessors `FsFileSize` ... `FsClusterSectors` |
| `00:24E3`-`2731` | [src/sd.c](src/sd.c) | the FPGA sector window: `FpgaSetSdWindow`, `SdWindowStatus`, `disk_readp_impl`, `DiskRead` |
| `00:2732`-`399B`+ | asm | GBDK library: 16/32-bit math, `memcpy`, console and font (`puts`, `putchar`), `set_data`, joypad, `delay` |
| `01:4000`-`40AD` | [src/handoff_poll.c](src/handoff_poll.c) | `HandoffPoll`, run from `$D100` |
| `01:40AE`-`4133` | [src/handoff.c](src/handoff.c) | `HandoffRun`, `LoadKernel`, the dead `RomLoad_Build` |
| `01:4134`-`415F` | [src/main.c](src/main.c) | `InitMessages`: the compiler's startup code for the initialized message pointers |

[src/gb.h](src/gb.h) declares the GBDK routines the C calls, under GBDK's
names, with the `kernel.sym` name and address of each. [src/hw.h](src/hw.h)
has the cart registers.

RAM: `$C0A0` `LoadCmd`, the load command (512 bytes, `main.c`), `$C2A0`-`$C2A7` message pointers
(`main.c`), `$C2A8` `FatFs` (`pff.c`), `$C2AA` the sector buffer (`sd.c`),
`$C4AC` GBDK's `_cpu`.

## Notes from the decompile

- The FAT layer is Petit FatFs R0.03a (`ld_word` and `ld_dword` are
  functions, which R0.03 had as macros), with every function where upstream
  has it and no behavior changes. Configuration, from the asm
  ([src/pffconf.h](src/pffconf.h)): FAT16 and FAT32, no FAT12, `pf_read`
  linked but never called, no directory, seek or write, no case conversion
  in `create_name` (`EZGB.DAT` must be upper case on the card).
- `kernel.sym` had the 32-bit divide and modulo swapped: `$2738` is
  `U32Mod`, `$273E` is `U32Div` (the engine rotates quotient bits into its
  second local). Fixed there.
- `FpgaSetMode` and the other register writers write the unlock and commit
  envelope inline, as the `FPGA_UNLOCK()` / `FPGA_COMMIT()` macros do.
- `DiskRead` copies `n` sectors to the start of `buf` for every chunk of
  four: wrong for `n > 1`, never used that way.
- The load command's sector totals are a 16-bit product (clusters times
  sectors per cluster), so they wrap at 32 MB.
- `kernel.sym` had `BootRomDirect` at `$0752`, inside `FpgaSetMode`; it is
  at `$075B`, where `RunFromWram` copies from. `PrintNumber` is at `$05ED`
  and `PrintBlankLines` at `$07A6` (each was a few bytes off).
