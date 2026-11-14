# Stock stage1 in C

EZ Flash's stage1, the FW4 and FW5-0918 versions, rewritten in C from the
annotated disassemblies in [../fw4](../fw4) and [../fw5-0918](../fw5-0918).
It is a best guess at the source EZ Flash compiled, not a byte-identical
rebuild: the SDCC they used has not been found
([kernel/1.05e-0731/stock](../../kernel/1.05e-0731/stock/README.md#toolchain-findings)
has the search so far). Once it is, the C here is what gets tuned to match.

One source covers both firmwares. FW5-0918 differs from FW4 only in
`main.c` (and the header), under `#if FW == 5`; the rest is the same code,
`$31` bytes higher in bank 0 ([../stock.md](../stock.md#what-it-does)).

```bash
make -C stage1/decomp      # compiles every file with -DFW=4 and -DFW=5 into build/
```

Needs SDCC 4.x (`sdcc -msm83`). It only compiles: nothing links yet.

## What is C and what stays assembly

| FW4 range | File | What |
|---|---|---|
| `00:0000`-`01E3` | asm | GBDK `crt0`: vectors, header, startup |
| `00:0400`-`05BB` | asm | GBDK `crt0` `_HOME`: interrupt lists, VBlank and serial handlers, `display_off`, OAM DMA stub, `banked_call` (`FarCallTrampoline`) |
| `00:05BC`-`0B4C` | [src/main.c](src/main.c) | six dead helpers, `FpgaSetMode`, FW5's `FpgaSetBootCpu`, `main`, then its strings |
| `00:0BE6`-`0C15` | [src/diskio.c](src/diskio.c) | `disk_initialize`, `disk_readp` |
| `00:0C16`-`24E2` | [src/pff.c](src/pff.c) | Petit FatFs, plus EZ Flash's accessors `FsFileSize` ... `FsClusterSectors` |
| `00:24E3`-`273D` | [src/sd.c](src/sd.c) | the FPGA sector window: `FpgaSetSdWindow`, `SdWindowStatus`, `disk_readp_impl`, `DiskRead` |
| `00:273E`-`399B`+ | asm | GBDK library: 16/32-bit math, `memcpy`, console and font (`puts`, `putchar`), `set_data`, joypad, `delay` |
| `01:4000`-`4133` | [src/handoff.c](src/handoff.c) | `HandoffPoll` (runs at `$D100`), `HandoffRun`, `LoadKernel`, the dead `RomLoad_Build` |
| `01:4134` | (compiler) | `InitMessages`: the startup code for `main.c`'s initialized message pointers |

[src/gb.h](src/gb.h) declares the GBDK routines the C calls, under GBDK's
names, with the `kernel.sym` name and address of each. [src/hw.h](src/hw.h)
has the cart registers.

RAM: `$C0A0` load command (512 bytes), `$C2A0`-`$C2A7` message pointers
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
- `disk_readp_impl` and `DiskRead` are in bank 0 but called through
  `banked_call` with bank `$FFFF`, so EZ Flash declared them banked.
- `DiskRead` copies `n` sectors to the start of `buf` for every chunk of
  four: wrong for `n > 1`, never used that way.
- The load command's sector totals are a 16-bit product (clusters times
  sectors per cluster), so they wrap at 32 MB.
- `kernel.sym` had `BootRomDirect` at `$0752`, inside `FpgaSetMode`; it is
  at `$075B`, where `RunFromWram` copies from.
