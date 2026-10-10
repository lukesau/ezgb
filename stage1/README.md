# stage1 from source

Our own FW4 bootstrap. It replaces the stock GBDK one in the slot B BRAMs and
does the same job: show the boot screen, find `EZGB.DAT` on the SD card, have
the FPGA load it, and enter it at `$0100`.
Design and protocol: [docs/fpga-stage1.md](../docs/fpga-stage1.md).

```bash
stage1/build.sh                     # -> fpga/stage1/stage1.gb
STAGE1_CFLAGS=-DPAUSE_FRAMES=250 stage1/build.sh   # long boot screen, for screenshots
EZGB_ROOT=<checkout> stage1/build.sh               # inputs/outputs in another checkout's fpga/
```

Needs SDCC 4.x (`-msm83`), `rgbfix`, and the splash icon tiles
(`fpga/bootsplash/build/icon.2bpp`, from `re/fpga-fw4/bootsplash/build.sh`).
Setting all of that up, and turning `stage1.gb` into an updater:
[docs/fpga-setup.md](../docs/fpga-setup.md).

## Version

`VERSION` has two lines: the firmware number, then the mod version. The
build turns them into `version.h` and the boot screen shows
`FW<n>-MOD <m>` on its bottom line, currently `FW6-MOD 1.0`. The firmware
number is what the cart's version register should read for this build
(stock FW4 reads 4; making the register itself say 6 is a separate fabric
change, [re/stage0/docs/version-byte.md](../re/stage0/docs/version-byte.md)). The mod version is
stage1's own, separate from the kernel mod's.

## Build knobs

| Variable | Default | Effect |
|---|---|---|
| `STAGE1_CFLAGS` | empty | extra SDCC flags, e.g. the `-D` options below |
| `-DPAUSE_FRAMES=<n>` | 42 (~700 ms, the stock pause) | frames from power-on to `LOADING...` |
| `-DJR_DELAY=<n>` | 18 | frames EZ-FLASH shows alone before the Jr. is painted |
| `-DJR_STEP=<n>` | 2 | frames per paint step (4 steps) |
| `WORDMARK_FLAGS` | `--no-halo` | flags passed to `mkwordmark.py` |
| `EZGB_ROOT` | this checkout | checkout whose `fpga/` holds the icon tiles and gets `fpga/stage1/` |

Keep `JR_DELAY + 4 * JR_STEP` under `PAUSE_FRAMES`.

| File | What |
|---|---|
| `src/crt0.s` | entry, WRAM init, interrupts off |
| `src/main.c` | boot sequence, START/SELECT at power-on, error retry loop |
| `src/fat.c` | FAT16/FAT32 mount, path lookup, load command, in-place sector writes |
| `src/fpga.c` | FPGA register writes, SD sector reads and writes, pSRAM pages |
| `src/cfg.c` | `EZGB.CFG` parser, `FLAUNCH=` only |
| `src/game.c` | fast launch: the kernel's game launch done from stage1 |
| `src/backup.c` | SELECT save backup to `/SAVER` |
| `src/video.c` | boot screen: icon, text, CGB palettes |
| `src/handoff.s` | runs from WRAM at `$D000` while the cart switches to the kernel |
| `src/game_handoff.s` | the same for a fast-launched game |
| `VERSION` | firmware number and mod version (above) |
| `font/font8.txt` | 8x8 font, `$20-$5A` |
| `art/ezflash.txt` | EZ-FLASH letters: Arial Bold Italic 22 pt, no antialiasing, E/Z join split by hand |
| `art/jr.txt` | the brush "Jr.", traced from a photo of the cart label (`scripts/fpga/jr-trace.py`) |

The wordmark is composed by `scripts/fpga/mkwordmark.py` into one tile map
per step: EZ-FLASH alone, then the Jr. painted on left to right in four steps.
`main.c` plays them inside the stock 700 ms pause (`JR_DELAY`, `JR_STEP`), so
the intro costs no boot time.
