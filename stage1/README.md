# Stage1

The bootloader: the Game Boy program the FPGA serves at power-on, which
shows the boot screen, finds the kernel on the SD card, has the FPGA load
it and enters it. This folder has ours, built from source, and EZ Flash's,
disassembled.

| | |
|---|---|
| [docs/design.md](docs/design.md) | what ours does: the boot sequence, fast launch, the save backup, game clocks, the Super Game Boy |
| [stock.md](stock.md) | EZ Flash's stage1: where it lives, what it does, the disassemblies in `fw4/` and `fw5-0918/` |
| [fw4/patches/](fw4/patches/README.md) | overlays on the stock FW4 stage1, from before the rewrite |

Ours replaces the stock one in the slot B bitstream and runs on FW4 and
FW5 carts.

## Building

```bash
stage1/build.sh                     # -> fpga/stage1/stage1.gb
STAGE1_CFLAGS=-DPAUSE_FRAMES=250 stage1/build.sh   # a long boot screen, for screenshots
EZGB_ROOT=<checkout> stage1/build.sh               # inputs and outputs in another checkout's fpga/
```

It needs SDCC 4.x (`-msm83`), `rgbfix`, and the splash icon tiles
(`fpga/bootsplash/build/icon.2bpp`), which
`stage1/fw4/patches/bootsplash/build.sh` makes from the logo. The output
goes to the ignored `fpga/` folder.

`stage1.gb` is a 32 KB image. Putting it into a bitstream and an updater
is a stage0 job: [setup.md](../stage0/docs/setup.md).

## Version

`VERSION` has two lines: the firmware number, then the mod version. The
build turns them into `version.h` and the boot screen shows
`FW<n>-MOD <m>` on its bottom line, as `FW5-MOD 2.1` on an FW5 cart. The FW4 and FW5 updaters carry the same
stage1, so `<n>` is read at boot from the cart's version register
(`fw_version()`, 4 or 5), with line 1 of `VERSION` only the fallback for a
reading outside 1-9. The register is wiring in the FPGA
([version-byte.md](../stage0/docs/version-byte.md)). Stage1's mod version
is separate from the kernel mod's.

## Build knobs

| Variable | Default | Effect |
|---|---|---|
| `STAGE1_CFLAGS` | empty | extra SDCC flags, e.g. the `-D` options below |
| `-DPAUSE_FRAMES=<n>` | 42 (~700 ms, the stock pause) | frames from power-on to `LOADING...` |
| `-DJR_DELAY=<n>` | 18 | frames EZ-FLASH shows alone before the Jr. is painted |
| `-DJR_STEP=<n>` | 2 | frames per paint step (4 steps) |
| `WORDMARK_FLAGS` | `--no-halo` | flags passed to `mkwordmark.py` |
| `-DFORCE_DMG` | off | a test build that acts as a DMG on a color console ([skip-boot-rom.md](../docs/skip-boot-rom.md#trying-the-dmg-path-on-a-color-console)) |
| `EZGB_ROOT` | this checkout | checkout whose `fpga/` holds the icon tiles and gets `fpga/stage1/` |

Keep `JR_DELAY + 4 * JR_STEP` under `PAUSE_FRAMES`.

| File | What |
|---|---|
| `src/crt0.s` | entry: saves the boot ROM's registers, WRAM init, interrupts off |
| `src/hw.h` | register and pSRAM addresses, the marks on page `$11` |
| `src/main.c` | boot sequence, START/SELECT at power-on, save backup offer, kernel picker ([docs/kernel-picker.md](../docs/kernel-picker.md)), error retry loop |
| `src/fat.c` | FAT16/FAT32 mount, path lookup, root scan for the kernels, load command, in-place sector writes, file create |
| `src/fpga.c` | FPGA register writes, SD sector reads and writes, pSRAM pages |
| `src/cfg.c` | `EZGB.CFG` parser: `FLAUNCH=` and `BOOTROM=` |
| `src/game.c` | fast launch: the kernel's game launch done from stage1 |
| `src/backup.c` | save backup to `/SAVER` before a fast launch, or on SELECT |
| `src/rtc.c` | a clock game's clock, set as the kernel sets it (FW5) |
| `src/video.c` | boot screen: icon and wordmark tiles unpacked into VRAM, text, CGB palettes |
| `src/sgb.c` | Super Game Boy: detection from the boot ROM's registers, header packets resent |
| `src/handoff.s` | runs from WRAM at `$D000` while the cart switches to the kernel |
| `src/game_handoff.s` | the same for a fast-launched game |
| `VERSION` | firmware number and mod version (above) |
| `font/font8.txt` | 8x8 font, `$20-$5A` |
| `art/ezflash.txt` | EZ-FLASH letters: Arial Bold Italic 22 pt, no antialiasing, E/Z join split by hand |
| `art/jr.txt` | the brush "Jr.", traced from a photo of the cart label (`stage0/tools/jr-trace.py`) |

The wordmark is composed by `stage1/tools/mkwordmark.py` into two tile maps,
EZ-FLASH alone and the whole mark, plus the tile columns at which the Jr. is
painted on left to right in four steps. `main.c` plays the steps inside the
stock 700 ms pause (`JR_DELAY`, `JR_STEP`), so the intro costs no boot time.
The icon and wordmark tiles are run-length packed (`stage1/tools/packbits.py`,
about 400 bytes saved) and unpacked into VRAM at boot.

Stage1 has 18,432 bytes of block RAM to live in. `build.sh` prints how many
are used.
