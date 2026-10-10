# CGB mode at power-on: stage1 patch for FW4 slot B

[cgb-mode.md](cgb-mode.md) found that the kernel can never run in CGB mode,
because the console reads the CGB flag from the cart's bootstrap (stage1)
before any of our code exists. Stage1 is BRAM contents in the FPGA bitstream
([bitstream.md](../re/stage0/docs/bitstream.md)), so the flag is now a data edit. This
is the first patched cart firmware: built and verified offline, then
**installed with the CGB updater and confirmed working on hardware
(2026-10-08)**: red OSINIT screen on a color console. Built
images stay in the ignored `fpga/cgb/`.

## What the patch does

Source: [`re/fpga-fw4/stage1-cgb.asm`](../re/fpga-fw4/stage1-cgb.asm), overlaid
on the FW4 stage1 with `rgblink -O`.

| Address | Change |
|---|---|
| `$0143` | CGB flag `$00` → `$80` (CGB enhanced, still DMG compatible) |
| `$014D` | header checksum `$FA` → `$7A` (`rgbfix -f h`) |
| `$01BA` | boot LCD-on → `call CgbBootInit`: zero VRAM bank 1 attributes, load the old `BGP $E4` shades as CGB palettes, then the original LCD-on |
| `$0885` | `ld hl,$0B7D` (the `OSINIT...` string) → `call CgbOsinitRed`: wait for vblank, make BG color 0 red, then the original load |
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
  bytes differ, all in `$57A64-$6480D`; slot A, the license record at
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
compare, no version gate. It shows a fixed `Update to ver:4` line (it never
reads the cart's version, see the correction in
[version-byte.md](../re/stage0/docs/version-byte.md)), waits for A, writes 149,516 bytes and stops. Its payload is
exactly slot B.

So `scripts/fpga/make-updater.py` builds `Update_FW4-cgb.gb`: the stock file
with the payload replaced by the patched slot B and the on-screen line
changed to `Update: CGB test`. The updater code is byte-identical to stock;
only the payload, those 16 label bytes and the global checksum differ.
SameBoy shows the expected start screen.

What it touches: config flash `$040000-$064831` (erasing the three 64 KB
sectors from `$040000`). Not slot A, not the license record at `$030000`,
not the boot tally. The bitstream is the same for every cart, so this is
safe on any cart whose slot A hands over to slot B. The dumped cart's slot A
does (it is labeled FW5 but its flash held FW4 firmware when dumped; check
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
  only to the cart it was dumped from (license record, slot A and tally are
  that cart's); for any other cart, splice slot B into a fresh dump of that
  cart and program only `$40000-$6FFFF`. FLASH only, STATUS/CFG unchecked.
- **JTAG:** loads the FPGA's SRAM after power-on, but the console reads the
  CGB flag during its own power-on, so JTAG alone can't show this patch
  unless the cart is powered separately before the console starts. Good for
  everything else (PicoBlaze and loader changes). Always JTAG-load a
  slot-B-type image (`$1B8 = 02`): a slot A type hands over and reboots into
  whatever slot B holds.

### What to expect

On a color console: EZ-FLASH / LOADING as normal, then a red screen at
OSINIT, then the kernel. The stock kernel will boot in CGB mode, probably
still red since it sets no CGB palettes of its own; games launch as before,
each in the mode its own header asks for. To undo: run the stock
`Update_FW4.gb`.

## Boot splash (second build)

Replaces the red proof build. Source:
[`re/fpga-fw4/bootsplash/stage1-splash.asm`](../re/fpga-fw4/bootsplash/stage1-splash.asm),
overlaid on the stock FW4 stage1 (so slot B goes straight from stock or the
red build to this one).

- CGB flag `$80` and the grayscale text palette, as before. No red hook.
- The EZ Flash icon (the two-shape console from the marketing logo), 44×53
  px, 6×7 tiles, drawn on map rows 1-7 directly above `EZ-FLASH`. CGB:
  palette 1 = white, orange screen, darkened frames, dark lip. DMG: the same
  tiles under `BGP $E4` (frames dark gray, screen light gray, lip black).
- Drawn by a hook at `$07FC`, just before `EZ-FLASH` is printed: stage1's
  console setup clears VRAM on its first print (`$07F3`), so drawing at the
  LCD-on hook gets wiped. The hook waits for vblank, switches the LCD off
  for the copy (the screen is still blank then), and switches it back on.
- At the hand-off to the kernel the LCD is switched off and left off, both
  tile maps and tile 0 (in both addressing modes) are cleared, and on CGB
  every tile attribute is reset to palette 0. The kernel's `LcdOff` is a
  no-op on an already-off LCD, and it switches the LCD on *before* it
  draws, so anything left in VRAM showed for a moment: the icon in gray
  (splash build 3). Now it sees a blank screen until its own screen is
  drawn, on CGB and DMG alike. Without
  the reset the kernel, which knows nothing about attributes, kept drawing
  the icon's 42 cells through the icon palette (a "shadow" in the browser,
  splash build 1). Doing it at `$4130` (splash build 2) was too early: that
  call starts the WRAM routine that waits for the FPGA to load the kernel,
  so the icon sat in gray for the whole load. Now: the stub's copy of
  `$4000` to `$D100` is extended from `$0150` to `$0200` bytes to carry
  `HandoffBlank` (ROM `$4161`, runs at `$D261`), and the routine's final
  `call $0100` goes there. It runs with interrupts off (the cart space is
  already the kernel) and restores AF/BC/DE/HL so the kernel sees the same
  registers as stock (it stores the entry A). Test-only check:
  [`test-reset.asm`](../re/fpga-fw4/bootsplash/test-reset.asm) runs the
  copied routine at `LOADING...` in SameBoy: registers identical at entry
  and exit, LCDC 00, and once the test re-enables the LCD the screen is
  blank (only the text stage1 prints afterwards appears), on CGB and DMG.
- Background color is plain white (`PAPER = $7FFF`). An off-white build
  (splash 5) was tried and reverted.
- Tiles `$80-$A9` (`$8800`, unused: the font is tiles `$20-$7F`); data in
  the `$FF` filler at `$39A4` (verified unreferenced), code at `$01E4-$027E` and `$4161-$41B3`.
  GBDK's display-mode dispatcher (`$0400`) jumps through a 4-entry table at
  `$01E2` whose entries 1-3 were `$FF` filler (a crash in stock), so they
  are unused and now land in this code.

Build option: `rgbasm -D NO_HANDOFF_CLEAR` drops the map/tile clear at the
hand-off (keeps LCD off and the attribute reset), for comparison against a
kernel that does its own CGB init (`CgbInit`, mod 5.3). Updater label
`Update: no clear`.

Lab and build: `re/fpga-fw4/bootsplash/build.sh` (needs the untracked logo
PNG and stock stage1 in `fpga/`) builds a standalone `splash.gb` for
iterating in SameBoy and the stage1 image; `scripts/fpga/mkicon.py` converts
the logo. Verified: SameBoy CGB and DMG show the icon above EZ-FLASH;
slot B patch flips 5,036 bits in the 8 plane BRAMs only; stage1 rebuilt from
the patched bitstream equals the tested ROM. Installed with
`Update_FW4-splash.gb` (`make-updater.py`, label `Update: splash 6`; builds 1-3 had
the hand-off bugs described above).

## Next

- An `ezgb.dat` with `CgbInit` (the `cgb-mode` branch, grayscale palette
  restored) so the kernel looks right in CGB mode. Done: part of the mod
  since 5.3 ([cgb-mode.md](cgb-mode.md)).
- Drop the red hook once proven; keep the grayscale init. Done in the boot
  splash build above, and the stage1 rewrite ([fpga-stage1.md](fpga-stage1.md))
  replaces both.
