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
| `+$000` | 0 |
| `+$004` | extents: `{u32 start LBA, u32 end}`, one per contiguous cluster run. `end` is a running total of file sectors from the start of the file, not a count. The last extent's `end` is `$FFFFFFFF` (rest of the file), and the word after it is 0 |
| `+$1F0` | file size in bytes |
| `+$1F4` | 1 |
| `+$1F8` | sectors per cluster |

The PicoBlaze then streams the file into pSRAM by itself. This is the same
mechanism the kernel uses to launch games, which is why a level-1 launcher
can load something other than the kernel.

- The cluster-chain end marker is chosen from `FsType()`: FAT16 `$FFFF`,
  otherwise FAT32 `$0FFFFFF7`. FAT12 isn't handled.
- Nothing bounds the extent count. 61 extents plus the closing 0 fit before
  `+$1F0`. A more fragmented `EZGB.DAT` corrupts the tail fields, then
  `$C2A0+`, which holds the message pointers and the FATFS pointer.

> **Correction (2026-10-09).** The first version of this page (commit
> "stage1 disassembly") gave the extents as `{file_sector, lba}`, starting at
> `+$000`. Wrong: `+$000` is a lone 0 and the pairs are `{lba, end}`. That
> version also didn't say that `end` is a running total, which is the part that
> matters. The kernel's `LaunchSetup` builds the same table for games. The
> kernel-side write-up, including what daid's `Protocol.md`, the SameBoy stub
> and `norreuse_clamp_extents.c` get wrong, is on main in
> [launch-trace.md](launch-trace.md#the-load-command-table).

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

## Rewrite from source

[`stage1/`](../stage1/README.md) is our own stage1: SDCC C plus two small
assembly files, no GBDK and no Petit FatFs. It does the same job with the
same FPGA register sequence, and builds the same load command as stock.

| | Stock | Rewrite |
|---|---|---|
| Size | ~18 KB (8.7 KB live code, 2.3 KB font, 2.8 KB dead) | 5.0 KB |
| SD reads to boot the test card | 366 | 20 |
| Error handling | message, hang | message, retry every second |
| CGB | DMG-only header | CGB flag, icon in colour, greys on DMG |

- **Reads.** Stock re-reads the FAT sector for every cluster. The rewrite
  caches one sector, so a chain walk costs one read per FAT sector. The test
  card is FAT32 with one sector per cluster, which makes `EZGB.DAT` 320
  clusters: stock takes about 40 seconds there in the emulator.
- **FAT.** FAT16 and FAT32, MBR or superfloppy, root directory only, 8.3
  names. FAT12 is refused with a message, as stock does implicitly.
- **Hand-off.** `src/handoff.s` runs at `$D000`. It is stock's `HandoffPoll`
  sequence, then the screen clear the splash added. The kernel is entered at
  `$0100` with A = `$E4`, the value stock leaves in A.
- **Load command bounds.** A file with more than 61 extents gets "EZGB.DAT
  FRAGMENTED" instead of overflowing.

Verified in SameBoy: boots the kernel on CGB and DMG, shows "EZGB.DAT NOT
FOUND" and retries on a card without it. The updater
(`fpga/stage1/Update_FW4-stage1src.gb`, label "Update: src v1") carries
slot B with the rewrite in its BRAMs, and its slot B decodes back to the
built stage1 byte for byte. **Not yet run on hardware.**

### Emulator support

The SameBoy stub (`tools/SameBoy/Core/ezflash_jr.c`) now runs stage1, which
it never could before. Changes, in `patches/sameboy` on this branch:

- Enabled for the title `BOOTLOADER` (stage1) as well as `EZGB`. No SD-init
  soft-patch there.
- After stage1's `$7F31`/`$7F32` write, the loaded file replaces the cart
  without a reset, and CPU state is kept. That is what the FPGA does before
  stage1 calls `$0100`.
- `$7F30=$03` reads now return the read status (`$01`, done) instead of
  sector data. Serving data hung stock stage1 whenever a FAT sector started
  with `$E1`, the busy value.
- Extent `end` words are read as running totals
  ([launch-trace.md](launch-trace.md#the-load-command-table)).
- `SAMEBOY_EZFLASH_JR_LOG=1` sends the stub's messages to stderr, because
  `GB_log` only reaches a terminal when the debugger console starts.

## Next

- Name the rest: the console/printf internals, `check_fs`/`pf_mount`
  details, `disk_readp_impl`.
- Run the rewrite on hardware.
- Level-1 features on top of the rewrite: read `EZGB.CFG`, pick the kernel,
  fast launch, SGB packets.
