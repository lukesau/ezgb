# The kernel in CGB mode

Stock declares itself DMG-only (`$0143 = $00`) and touches no CGB register,
so a Game Boy Color runs it in compatibility mode: four shades, no
palettes, no CGB-only hardware. The modded kernel carries the CGB flag and
is ready to run in CGB mode, which is what the color themes need
([themes.md](themes.md)). Addresses are 1.05e-0731's.

## Which mode the console is in

The kernel's header does not decide it. The console's boot ROM reads the
header before any of our code exists, and what it reads is stage1's, served
from the FPGA. `ezgb.dat` is loaded later, by stage1.

| Firmware | Stage1's CGB flag | The kernel runs in |
|---|---|---|
| stock | not set | DMG compatibility mode on a GBC or GBA |
| the firmware mod ([stage1/](../stage1/README.md)) | set | CGB mode |

An emulator that runs `ezgb.dat` directly reads the kernel's header, and
runs it in CGB mode.

## What the kernel does

| Site | Change |
|---|---|
| `$0143` | `$80`: CGB enhanced, still DMG compatible |
| `$014D` | the header checksum, recomputed |
| `00:01ba`, the boot's LCD-on | calls `SgbBootHook` (`01:7f00`, [sgb-boot.md](sgb-boot.md)), which goes on to `CgbInit` |
| `CgbInit` `00:0259` | [cgb_init.c](../kernel/mod/src/cgb_init.c) |

The hook site runs with the LCD still off, the only safe time for a bulk
VRAM write. `CgbInit`:

1. **Zeroes VRAM bank 1.** In CGB mode every tile map byte has an attribute
   byte there choosing palette, tile bank and flips. `KernelEntry` clears
   WRAM, OAM and HRAM but never VRAM, so without this the attributes are
   whatever the boot ROM left: random palettes and mirrored tiles.
2. **Calls `Theme`** (`02:43d0`) for the palettes, with bank 2 mapped by
   hand, since interrupts are still off and `FarCallTrampoline` would turn
   them on.
3. **Turns the LCD on**, as the stock instructions it replaced did.

Translating the stock look to palettes is direct, because stock writes
`BGP` exactly once, with `$E4`, and never changes it: color index N is
shade N.

## Telling the modes apart

- **`VBK` (`$FF4F`) cannot.** It reads back what was written on a GBC in
  compatibility mode, as it does in CGB mode. `CgbInit` uses it only to
  skip a DMG, where clearing bank 1 would write over bank 0.
- **Palette RAM can.** It takes writes only in CGB mode, so `Theme` writes
  a palette byte and reads it back, and sets `PAL_LOCKED` when it does not
  stick.
- **The boot `A` saved at `$d6c9` cannot.** Stage1 enters the kernel with
  `A = $E4` on every console. With the firmware mod, the console's real
  boot registers are in a pSRAM record
  ([skip-boot-rom.md](skip-boot-rom.md)).

To test compatibility mode in an emulator, clear `$0143` in a copy of the
kernel.

## Facts learned on the way

- A launch is a real console reset: the boot ROM runs again and reads the
  launched game's header, so a game gets the mode its header asks for
  (unless the boot ROM is skipped, [skip-boot-rom.md](skip-boot-rom.md)).
- A kernel started as a launched game finds no cart control interface (the
  cause was not found), so the kernel cannot chain into a second copy of
  itself to change mode.
