# Stock stage1

Stage1 is the Game Boy program the cart shows at power-on: `EZ-FLASH`,
`LOADING`, `OSINIT`, then the kernel. It is not in flash. It is the initial
contents of block RAMs in the FPGA bitstream
([flash-map.md](../stage0/docs/flash-map.md)):

| Addresses | Stored in |
|---|---|
| `$0000`-`$3FFF` | eight one-bit BRAMs, one per bit plane |
| `$4000`-`$47FF` | one byte-wide BRAM |
| `$4800`-`$7FFF` | nothing; reads as zeros |

Its header title is `BOOTLOADER`, cart type `$01`. EZ Flash built it with
GBDK, the same toolchain and `crt0` as the kernel. The console's boot ROM
reads this header, not the kernel's, so stage1's CGB flag decides which
mode the console is in.

## The disassemblies

| Directory | Firmware | State |
|---|---|---|
| [fw4/](fw4/) | FW4 | disassembled and annotated; rebuilds byte for byte |
| [fw5-0918/](fw5-0918/) | FW5, the 0918 update | FW4's names and notes, ported; rebuilds byte for byte |

Each holds `kernel.sym` (names and data ranges) and the generated
`disassembly/`, and `notes.json`. The binary, `kernel.gb`, is
EZ Flash's and stays local. The file is named as the kernel's is so the
kernel tooling applies.

```bash
stage1/tools/stage1-from-bram.py <bram dir> -o stage1/fw4/kernel.gb   # from a decoded bitstream
stage1/tools/stage1-regen.sh fw4      # regenerate, rebuild, compare: "rebuild matches kernel.gb"
stage1/tools/stage1-trace.py stage1/fw4/kernel.gb --report            # code, data and unreached spans
```

Stock stage1 has a stale global checksum, which the console never checks,
so the regen fixes only the header checksum.

The names came from three places:

- **The kernel's GBDK runtime**, matched by comparing bytes with absolute
  operands masked: `crt0`, the console and font code, the 32-bit math,
  `Memcpy`, `DiskRead`, and the load and hand-off routines.
- **Petit FatFs.** The FAT layer is ChaN's Petit FatFs, so it has `pff.c`'s
  names (`pf_mount`, `pf_open`, `follow_path`, `dir_find`, `get_fat`). The
  FATFS struct layout confirms it.
- **By hand**: `main`, the FPGA register writers, the hand-off.

## What it does

```
crt0 (KernelEntry $0150)
  InitMessages ($4134)          message pointers -> $C2A0-$C2A7
  main ($07F1)
    puts EZ-FLASH, delay(700), puts LOADING
    FpgaSetMode(0)              $7FC0 = 0
    pf_mount                    fail: "Micro SD initial error!", hang
    pf_open("EZGB.DAT")         fail: "ezgb.dat not found...", hang
    puts OSINIT
    build the load command at $C0A0 from the cluster chain
    FpgaSetMode(2)              $7FC0 = 2
    LoadKernel($C0A0)           far call, bank 1
      $7F36 = 1, copy the command to the $A000 window
      HandoffRun: copy HandoffPoll ($4000, $150 bytes) to $D100, call it
        $7F36 = 3, poll $A000 until the FPGA reports done
        $7F36 = 0, $7FC0 = 0, ROM bank 1, $7F31 = 0, $7F32 = $80
        call $0100              the kernel
```

Every register write is inside the unlock and commit envelope
([design.md](../stage0/docs/design.md#unlock-and-commit)).

FW5-0918's stage1 is FW4's with three changes: `main` turns sound off, and
after the delay it writes the console's boot `A` to `$7FD3`
(`FpgaSetBootCpu`, `00:07F1`), which is half of the fast-load key
([firmware-diff.md](../stage0/docs/firmware-diff.md)); and the header has
SGB flag `$03` and old licensee `$33`. Everything after `main` in bank 0 is
the same code `$31` bytes higher, so FW5's `kernel.sym` and `notes.json` are
made from FW4's:

```bash
stage1/tools/stage1-port-sym.py --check    # the layout claim, on the two binaries
stage1/tools/stage1-port-sym.py            # write fw5-0918/kernel.sym and notes.json from fw4/
```

Name things in `fw4/` and port them; don't edit FW5's files by hand.

## In C

[decomp/](decomp/README.md) is the stock stage1 rewritten in C, one source
for both firmwares. EZ Flash compiled it with SDCC 2.9.0 and no options;
under that compiler every C function matches stock byte for byte
(`decomp/tools/match.py`).

### The load command

512 bytes, built at `$C0A0` and copied into the window at `$A000`. It is
the table the kernel builds to launch a game
([boot-and-launch.md](../docs/boot-and-launch.md#the-load-command-table)):
a 0, extent pairs `{start LBA, end}` where `end` is a running total of file
sectors, the file size at `+$1F0`, a 1 at `+$1F4` and the sectors per
cluster at `+$1F8`. The PicoBlaze then streams the file into the game store
by itself.

- The end-of-chain marker is chosen by FAT type: FAT16 `$FFFF`, otherwise
  FAT32's. FAT12 is not handled.
- Nothing bounds the extent count. 61 extents and the closing 0 fit before
  `+$1F0`. A more fragmented `EZGB.DAT` corrupts the tail fields and then
  the message pointers at `$C2A0`.

The kernel's file name exists in one place: `KernelFileName`, `EZGB.DAT`
at `$0B4D`, used only by the `pf_open` in `main`.

## Space

| Region | Bytes |
|---|---|
| live code, traced from the entry and the vectors | about 8.7 KB |
| font descriptor and glyphs (`$300C`-`$390D`) | 2,306 |
| dead code, never called | about 2.8 KB |
| `$FF` filler in `$0000`-`$47FF` | about 2.4 KB |
| `$4800`-`$7FFF`, no BRAM behind it | 14 KB, unusable |

The dead code is `pf_read` (1,061 bytes), unused GBDK library routines, and
six unreferenced functions at `$05BC`-`$07F0` (`PrintLine`, `PrintNumber`,
`WaitButtonB`, `BootRomDirect`, `RunFromWram`, `PrintBlankLines`).

So a stage1 has 18,432 bytes to live in, and stock leaves little of it.
Our replacement, built from source, is described in
[docs/design.md](docs/design.md).
