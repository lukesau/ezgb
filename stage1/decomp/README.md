# Stock stage1 in C

EZ Flash's stage1, the FW4 and FW5-0918 versions, rewritten in C from the
annotated disassemblies in [../fw4](../fw4) and [../fw5-0918](../fw5-0918).
EZ Flash compiled it with SDCC 2.9.0 and no options, and the C here is
fitted to that compiler: every function compiles to stock's bytes
([Matching](#matching)). The ROM
that `make` builds is still linked from SDCC 4's output, so it runs like
stock but is not stock's bytes.

One source covers both firmwares. FW5-0918 differs from FW4 only in
`main.c` (and the header), under `#if FW == 5`; the rest is the same code,
`$31` bytes higher in bank 0 ([../stock.md](../stock.md#what-it-does)).

```bash
make -C stage1/decomp      # build/fw4/stage1.gb and build/fw5/stage1.gb
```

Needs SDCC 4.x (`sdcc`, `sdasgb`, `sdldgb`) and rgbds. No stock binary is
needed: the asm comes from the tracked disassemblies.

## Linking against the stock asm

[tools/link.py](tools/link.py) compiles the C with `--sdcccall 0`, which
passes every argument on the stack as GBDK 2.x does, so the C calls the
stock runtime (`puts`, `memcpy`, the 16- and 32-bit math) where it is. It
links with sdldgb at the stock addresses, resolving what the C calls from
the firmware's `kernel.sym` (GBDK names that differ are in `ALIASES`), and
writes the linked bytes as two rgbds includes. These replace the C regions
in a copy of the disassembly (`build/fw<n>/asm/`), and rgbds builds the
ROM. The C is smaller than stock's, so each region ends in `$FF` fill and
every asm address stays the same. The only byte outside the C regions that
differs from stock is crt0's `call main`.

| Where | Area | What |
|---|---|---|
| `00:05BC` up to `U32Mul` | `_CODE`, `_HOME` | `main.c`, `diskio.c`, `pff.c`, `sd.c`, then `bcall.s` |
| `01:4000` | `_HANDOFF` | `handoff_poll.c`, linked to run at `$D100` |
| `01:4134` | `_GSINIT` | `gsinit.s`, where crt0 calls `InitMessages` |
| `01:4150` | `_INITIALIZER`, `_CODE_1` | the message pointers' values, `handoff.c` |
| `$C2A0`-`$C4A9` | `_INITIALIZED`, `_DATA` | message pointers, `FatFs`, the sector buffer: stock's RAM exactly |

Two pieces of glue stand in for what EZ Flash's toolchain did:
[src/bcall.s](src/bcall.s) is SDCC 4's banked call, the same switch as
stock's `banked_call`, and [src/gsinit.s](src/gsinit.s) copies the
initialized globals, where stock's compiler wrote code that stored each one.

## Matching

```bash
SDCC29=<sdcc 2.9.0 prefix> stage1/decomp/tools/match.py [fw4|fw5-0918] [-v]
```

[tools/match.py](tools/match.py) compiles each file with SDCC 2.9.0
(`sdcc -mgbz80`, nothing else) and compares every function `kernel.sym`
names with the firmware's `kernel.gb`, masking operands the linker fills in.
All of them match: 40 functions on FW4, 41 on FW5-0918 (with
`FpgaSetBootCpu`).

SDCC 2.9.0 needs building from its source release (z80 port only; it builds
with a current gcc given `-fcommon -std=gnu89`). It ships no `sdcpp` or
`sdasgb` under those names; later ones work (`SDASGB=` for the assembler).

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
| `00:0BE6`-`0C15` | [src/diskio.c](src/diskio.c) | `disk_initialize`, `disk_readp` |
| `00:0C16`-`24E2` | [src/pff.c](src/pff.c) | Petit FatFs, plus EZ Flash's accessors `FsFileSize` ... `FsClusterSectors` |
| `00:24E3`-`2731` | [src/sd.c](src/sd.c) | the FPGA sector window: `FpgaSetSdWindow`, `SdWindowStatus`, `disk_readp_impl`, `DiskRead` |
| `00:2732`-`399B`+ | asm | GBDK library: 16/32-bit math, `memcpy`, console and font (`puts`, `putchar`), `set_data`, joypad, `delay` |
| `01:4000`-`40AD` | [src/handoff_poll.c](src/handoff_poll.c) | `HandoffPoll`, run from `$D100` |
| `01:40AE`-`4133` | [src/handoff.c](src/handoff.c) | `HandoffRun`, `LoadKernel`, the dead `RomLoad_Build` |
| `01:4134` | (compiler) | `InitMessages`: the startup code for `main.c`'s initialized message pointers |

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
