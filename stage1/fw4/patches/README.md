# Patches on the stock FW4 stage1

RGBDS overlays on EZ Flash's FW4 stage1, from before the rewrite in
[stage1/src](../../README.md) replaced it. They were the first patched
firmware to run on a cart.

| File | What it does |
|---|---|
| `stage1-cgb.asm` | Sets the CGB flag (`$0143 = $80`, header checksum at `$014D`), with a boot hook at `$01BA` that zeroes VRAM bank 1 and loads the `BGP $E4` shades as CGB palettes. A second hook at `$0885` turns the `OSINIT` screen red, as proof the patched code ran. |
| `bootsplash/stage1-splash.asm` | The CGB flag and palettes again, without the red hook, plus the EZ Flash icon drawn above `EZ-FLASH` by a hook at `$07FC`. |
| `bootsplash/splash.asm` | The same splash as a standalone ROM, for trying it in SameBoy. |
| `test-red-on-error.asm`, `bootsplash/test-reset.asm` | Test overlays. |

## Building one

```bash
rgbasm -o stage1-cgb.o stage1-cgb.asm
rgblink -O stage1-fw4.gb -o stage1-cgb.gb stage1-cgb.o    # stage1-fw4.gb: stage1-from-bram.py output
rgbfix -f h stage1-cgb.gb
../../tools/stage1-to-bram.py stage1-cgb.gb blobs          # prints the s3patch --set arguments
```

`s3patch` then writes those BRAM contents into the slot B bitstream, and
`make-updater.py` wraps the result in an updater
([docs/fpga-setup.md](../../../docs/fpga-setup.md)).

`bootsplash/build.sh` builds the splash, and also makes the icon tiles that
[stage1/build.sh](../../build.sh) needs. It reads the logo PNG and the stock
stage1 from the untracked `fpga/` folder.

## What they established

- The console reads the CGB flag from stage1's header, never from
  `ezgb.dat`, so CGB mode is a BRAM data edit.
- Stock stage1 clears VRAM on its first print (`$07F3`), so anything drawn
  before that is wiped. Draw after it.
- The kernel turns the LCD on before it draws, so the hand-off has to clear
  the tile map and the CGB attributes or the splash shows through.
  `stage1/src/handoff.s` does this now.
