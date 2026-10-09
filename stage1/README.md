# stage1 from source

Our own FW4 bootstrap. It replaces the stock GBDK one in the slot B BRAMs and
does the same job: show the boot screen, find `EZGB.DAT` on the SD card, have
the FPGA load it, and enter it at `$0100`. Local-only (`bitstream-re`).
Design and protocol: [docs/fpga-stage1.md](../docs/fpga-stage1.md).

```bash
stage1/build.sh                     # -> fpga/stage1/stage1.gb
STAGE1_CFLAGS=-DPAUSE_FRAMES=250 stage1/build.sh   # long boot screen, for screenshots
```

Needs SDCC 4.x (`-msm83`), `rgbfix`, and the splash icon tiles
(`fpga/bootsplash/build/icon.2bpp`, from `re/fpga-fw4/bootsplash/build.sh`).

| File | What |
|---|---|
| `src/crt0.s` | entry, WRAM init, interrupts off |
| `src/main.c` | boot sequence, error retry loop |
| `src/fat.c` | FAT16/FAT32 mount, root-directory lookup, load command |
| `src/fpga.c` | FPGA register writes, SD sector reads |
| `src/video.c` | boot screen: icon, text, CGB palettes |
| `src/handoff.s` | runs from WRAM at `$D000` while the cart switches to the kernel |
| `font/font8.txt` | 8x8 font, `$20-$5A` |
