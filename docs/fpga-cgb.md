# CGB mode at power-on: stage1 patch for FW4 slot B

[cgb-mode.md](cgb-mode.md) found that the kernel can never run in CGB mode,
because the console reads the CGB flag from the cart's bootstrap (stage1)
before any of our code exists. Stage1 is BRAM contents in the FPGA bitstream
([fpga-bitstream.md](fpga-bitstream.md)), so the flag is now a data edit. This
is the first patched cart firmware: built and verified offline, then
**installed with the CGB updater and confirmed working on hardware
(2026-10-08)**: red OSINIT screen on a colour console. Local-only (`bitstream-re` branch); built
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

## Installing it

### Recommended: the CGB updater

`Update_FW4.gb` is a launched game that writes its payload to config flash
`$040000 + offset`, one 256-byte page at a time through the PicoBlaze's
flash-update command (the staging header is built at `00:13e9`: loop offset
`+ $040000`). Checked in the code: no payload checksum, no read-back
compare, no version gate. It shows the cart's current firmware version for
display only, waits for A, writes 149,516 bytes and stops. Its payload is
exactly slot B.

So `scripts/fpga/make-updater.py` builds `Update_FW4-cgb.gb`: the stock file
with the payload replaced by the patched slot B and the on-screen line
changed to `Update: CGB test`. The updater code is byte-identical to stock;
only the payload, those 16 label bytes and the global checksum differ.
SameBoy shows the expected start screen.

What it touches: config flash `$040000-$064831` (erasing the three 64 KB
sectors from `$040000`). Not slot A, not the licence record at `$030000`,
not the boot tally. The bitstream is the same for every cart, so this is
safe on any cart whose slot A hands over to slot B. The dumped cart's slot A
does (it is labelled FW5 but its flash held FW4 firmware when dumped; check
what yours runs now).

Running any updater is the operation [cgb-mode.md](cgb-mode.md) flags as
brick-risky: a power loss mid-write leaves slot B half written. Slot A's
fallback covers a slot B that fails to configure (the tally byte stays `01`
and the next power-on stays on slot A). It does not cover a slot B that
configures but misbehaves, which then needs the stock `Update_FW4.gb`
(if the kernel still runs) or a programmer.

### Alternatives

- **Programmer:** the full image `EN25F40-fw4-cgb-slotB.bin` is the
  `EN25F40-repaired-v2.bin` dump with slot B replaced. A full image belongs
  only to the cart it was dumped from (licence record, slot A and tally are
  that cart's); for any other cart, splice slot B into a fresh dump of that
  cart and program only `$40000-$6FFFF`. FLASH only, STATUS/CFG unchecked.
- **JTAG:** loads the FPGA's SRAM after power-on, but the console reads the
  CGB flag during its own power-on, so JTAG alone can't show this patch
  unless the cart is powered separately before the console starts. Good for
  everything else (PicoBlaze and loader changes). Always JTAG-load a
  slot-B-type image (`$1B8 = 02`): a slot A type hands over and reboots into
  whatever slot B holds.

### What to expect

On a colour console: EZ-FLASH / LOADING as normal, then a red screen at
OSINIT, then the kernel. The stock kernel will boot in CGB mode, probably
still red since it sets no CGB palettes of its own; games launch as before,
each in the mode its own header asks for. To undo: run the stock
`Update_FW4.gb`.

## Next

- An `ezgb.dat` with `CgbInit` (the `cgb-mode` branch, greyscale palette
  restored) so the kernel looks right in CGB mode.
- Drop the red hook once proven; keep the greyscale init.
