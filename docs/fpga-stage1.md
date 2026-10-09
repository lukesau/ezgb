# Stage1 (the FW4 bootstrap) disassembly

Stage1 is the Game Boy program the cart shows at power-on: EZ-FLASH,
LOADING, OSINIT, then the kernel. It lives in FPGA BRAM, not in flash
([fpga-bitstream.md](fpga-bitstream.md)): 32 KB address space, `$0000-$3FFF`
from 8 one-bit BRAM planes, `$4000-$47FF` from one x9 BRAM, `$4800-$7FFF`
reads as zeros. Header title `BOOTLOADER`, cart type `$00` (no MBC). Built with
GBDK, the same toolchain and crt0 as the kernel.

Local-only (`bitstream-re`), like everything derived from the bitstream.

## Workspace

| Path | What |
|---|---|
| `re/stage1-fw4/kernel.gb` | stage1 as written by `stage1-from-bram.py` (ignored; `kernel.gb` so the kernel tooling applies) |
| `re/stage1-fw4/kernel.sym` | names and `.data` ranges for mgbdis |
| `re/stage1-fw4/notes.json` | comment blocks, injected by `annotate-disasm.py` |
| `re/stage1-fw4/disassembly/` | generated; rebuilds stage1 byte for byte |
| `scripts/fpga/stage1-regen.sh` | regenerate + rebuild + compare |
| `scripts/fpga/stage1-trace.py` | recursive-descent trace: code vs data, unreached spans |

```bash
scripts/fpga/stage1-regen.sh        # "rebuild matches kernel.gb"
```

Stock stage1 has a stale global checksum (the console never checks it), so
the regen patches the Makefile to `rgbfix -f h` and only fixes the header
checksum.

Names came from three places:

- **The kernel's GBDK runtime**, matched by comparing bytes with absolute
  operands masked: crt0 is the kernel's crt0 (`$0000-$03FF` nearly identical,
  `$0400-$05BB` the kernel's `$0600-$07BB` shifted by `-$200`), plus the
  console/font code, the 32-bit math, `Memcpy`, `DiskRead`, and
  `RomLoad_Build`/`HandoffPoll` (the kernel's `RomLoad_InitiatePoll` twin).
- **Petit FatFs**: the FAT layer is ChaN's Petit FatFs, so it gets `pff.c`
  names (`pf_mount`, `pf_open`, `follow_path`, `dir_find`, `get_fat`...). The
  FATFS struct layout confirms it: `fsize` at `+$1A`, `org_clust` at `+$1E`.
- **By hand**: `main`, the FPGA register writers, the hand-off.

## What stage1 does

```
crt0 (KernelEntry $0150)
  InitMessages ($4134)          message pointers -> $C2A0-$C2A7
  main ($07F1)
    puts EZ-FLASH, delay(700), puts LOADING
    FpgaSetMode(0)              $7FC0 = 0
    pf_mount                    fail: "Micro SD initial error!", hang
    pf_open("EZGB.DAT")         fail: "ezgb.dat not found...", hang
    puts OSINIT
    build load command at $C0A0 from the cluster chain
    FpgaSetMode(2)              $7FC0 = 2
    LoadKernel($C0A0)           far call, bank 1
      $7F36 = 1, copy the command to the $A000 window
      HandoffRun: copy HandoffPoll ($4000, $150 bytes) to $D100, call it
        $7F36 = 3, poll $A000 until the FPGA reports done
        $7F36 = 0, $7FC0 = 0, ROM bank 1, $7F31 = 0, $7F32 = $80
        call $0100              the kernel
```

Every FPGA register write uses the kernel's unlock sequence: `$7F00=$E1`,
`$7F10=$E2`, `$7F20=$E3`, the register, then `$7FF0=$E4`.

### The load command

512 bytes, built at `$C0A0` and copied into the window at `$A000`:

| Offset | Content |
|---|---|
| `+$000` | extents: `{u32 file_sector, u32 lba}`, one per contiguous cluster run, first `file_sector` = 0, terminated by `{$FFFFFFFF, 0}` |
| `+$1F0` | file size in bytes |
| `+$1F4` | 1 |
| `+$1F8` | sectors per cluster |

The PicoBlaze then streams the file into pSRAM by itself. This is the same
mechanism the kernel uses to launch games, which is why a level-1 launcher
can load something other than the kernel.

- The cluster-chain end marker is chosen from `FsType()`: FAT16 `$FFFF`,
  otherwise FAT32 `$0FFFFFF7`. FAT12 isn't handled.
- Nothing bounds the extent count. 61 extents plus the terminator fit before
  `+$1F0`. A more fragmented `EZGB.DAT` corrupts the tail fields, then
  `$C2A0+`, which holds the message pointers and the FATFS pointer.

### The kernel's name

The kernel file name exists in one place: `KernelFileName`, `EZGB.DAT` at
`$0B4D`, used only by the `pf_open` in `main`. The lowercase `ezgb.dat` at
`$0B87` is just the error message.

## Space

| Region | Bytes |
|---|---|
| Live code, traced from the entry and the vectors | ~8.7 KB |
| Font descriptor + glyphs (`$300C-$390D`) | 2,306 |
| Dead code: never called | ~2.8 KB |
| `$FF` filler in `$0000-$47FF` (stock) | ~2.4 KB |
| `$4800-$7FFF`: no BRAM behind it | 14 KB, unusable |

Dead code, largest first:

- `pf_read` (`$2018-$243C`), 1,061 bytes
- unused GBDK library: callback register/remove variants and parts of the
  32-bit math and console code
- three unreferenced user functions (`$05BC-$07F0`): `BootRomDirect`,
  `RunFromWram`, `PrintBlankLines`

The splash ([fpga-cgb.md](fpga-cgb.md)) uses about 900 bytes of the filler.

## Next

- Name the rest: the console/printf internals, `check_fs`/`pf_mount`
  details, `disk_readp_impl`.
- Rewrite stage1 as our own source. It is small: one `main`, Petit FatFs, the
  GBDK console, and two FPGA routines. A from-source stage1 with no `printf`
  console and no `pf_read` frees several KB in the same BRAMs, and makes
  level-1 features ordinary code.
