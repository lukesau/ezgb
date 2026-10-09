# CGB mode at power-on: stage1 patch for FW4 slot B

[cgb-mode.md](cgb-mode.md) found that the kernel can never run in CGB mode,
because the console reads the CGB flag from the cart's bootstrap (stage1)
before any of our code exists. Stage1 is BRAM contents in the FPGA bitstream
([fpga-bitstream.md](fpga-bitstream.md)), so the flag is now a data edit. This
is the first patched cart firmware: built and verified offline, **not yet
flashed or tested on hardware.** Local-only (`bitstream-re` branch); built
images stay in the ignored `fpga/cgb/`.

## What the patch does

Source: [`re/fpga-fw4/stage1-cgb.asm`](../re/fpga-fw4/stage1-cgb.asm), overlaid
on the FW4 stage1 with `rgblink -O`.

| Address | Change |
|---|---|
| `$0143` | CGB flag `$00` → `$80` (CGB enhanced, still DMG compatible) |
| `$014D` | header checksum `$FA` → `$7A` (`rgbfix -f h`) |
| `$01BA` | boot LCD-on → `call CgbBootInit`: zero VRAM bank 1 attributes, load the old `BGP $E4` shades as CGB palettes, then the original LCD-on |
| `$0885` | `ld hl,$0B7D` (the `OSINIT...` string) → `call CgbOsinitRed`: wait for vblank, make BG colour 0 red, then the original load |
| `$01E4-$0263` | the two hooks and palettes, in the `$FF` filler after the boot halt loop |

Both hooks feature-test `VBK` and do nothing unless the console really is in
CGB mode. The red background is a proof that stage1 ran in CGB mode and that
patched code executes; it is not meant to stay.

## Verification

- **SameBoy, CGB model:** EZ-FLASH / LOADING look identical to stock. The
  stub can't take stage1 as far as OSINIT (it stops at "Micro SD initial
  error!" for the stock stage1 too), so a test-only build,
  [`test-red-on-error.asm`](../re/fpga-fw4/test-red-on-error.asm), also calls
  the red hook at that message: red background, text readable.
- **SameBoy, DMG model:** pixel-identical to stock.
- **Re-encoding check:** patching slot B with its *original* BRAM contents
  reproduces the original file byte for byte, including both CRC packets.
- **Patched slot B:** 648 BRAM bits flipped, 2 CRC packets recomputed, 589
  bytes differ. Re-parses with no CRC mismatch; `s3decode` against the
  original differs only in the 8 plane BRAMs (0 unclaimed bits); stage1
  rebuilt from it equals the patched ROM exactly.
- **Full flash image:** `EN25F40-repaired-v2.bin` with slot B replaced. 589
  bytes differ, all in `$57A64-$6480D`; slot A, the licence record at
  `$30000` and the boot tally at `$70000` are unchanged.

## Building it

```bash
cd fpga/cgb
rgbasm -o stage1-cgb.o ../../re/fpga-fw4/stage1-cgb.asm
rgblink -O stage1-fw4.gb -o stage1-cgb.gb stage1-cgb.o     # stage1-fw4.gb: stage1-from-bram.py output
rgbfix -f h stage1-cgb.gb
../../scripts/fpga/stage1-to-bram.py stage1-cgb.gb blobs   # prints the s3patch --set arguments
# on the build host (copy blobs/ and the slot B image there):
s3patch --db ~/fpga/prjcombine/databases/spartan3.zstd slotB.bin slotB-cgb.bin <--set args>
```

then splice `slotB-cgb.bin` into a full dump at `$40026`.

`s3patch` ([`scripts/fpga/s3decode/src/bin/s3patch.rs`](../scripts/fpga/s3decode/src/bin/s3patch.rs))
writes any bel attribute (here BRAM `DATA`) by mapping each bit through the
prjcombine database to a frame bit, locating it in the stream's FDRI runs,
refusing frames that are reused via MFWR, recomputing every CRC packet, and
re-parsing the result to prove only the requested bits changed.

## Flashing (not done)

Only on **the FW4 cart this dump came from.** The licence record at `$30000`
is tied to that FPGA's Device DNA ([fpga-picoblaze.md](fpga-picoblaze.md)),
and the image is FW4. Never write it to the FW5 cart.

Why slot B: on power-on the hardware loads slot A, whose PicoBlaze hands over
to slot B ([fpga-picoblaze.md](fpga-picoblaze.md)). If slot B fails to
configure, the boot tally byte stays at `01` and the next power-on stays on
slot A. That covers a broken bitstream. It does not cover a slot B that
configures fine but misbehaves (say, the kernel failing in CGB mode): slot B
marks itself booted, so slot A keeps handing over, and recovery means
rewriting slot B with a programmer (the 2026-08-16 procedure in
[hardware-board.md](hardware-board.md)).

Best practice before writing: read the cart's current flash and splice the
patched slot B into *that* (it differs from the August dump at least in the
boot tally), and only program `$40000-$6FFFF`, the three 64 KB sectors that
hold slot B. Program FLASH only, leave
STATUS/CFG unchecked.

What to expect on a colour console: EZ-FLASH / LOADING as normal, then a red
screen at OSINIT, then the kernel. The stock kernel will boot in CGB mode,
probably still red since it sets no CGB palettes of its own;
games launch as before, each in the mode its own header asks for.

## Next

- An `ezgb.dat` with `CgbInit` (the `cgb-mode` branch, greyscale palette
  restored) so the kernel looks right in CGB mode.
- Drop the red hook once proven; keep the greyscale init.
- A route that doesn't need a programmer: the FW4 updater writes slot B via
  the PicoBlaze's flash-update command, so an updater carrying this slot B
  would do it from the kernel. Not built: running an updater is the one
  operation [cgb-mode.md](cgb-mode.md) warns can brick, so it needs its own
  review.
