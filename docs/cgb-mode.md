# Running the kernel in CGB mode

## Why

The Game Boy Color's IR port (`RP`, `$FF56`) — and every other CGB-only
register — is locked out when the console runs in DMG compatibility mode. The
stock kernel declares itself DMG-only (ROM header CGB flag `$0143 = $00`) and
never touches a single CGB register: zero accesses to `$FF56`, `$FF68`/`$FF69`
(palettes), or `$FF4D` (double speed) anywhere in the ROM. So IR features are
not "not implemented" — they are unreachable until the kernel runs in CGB mode.

This change is the prerequisite. It does not add IR.

## What changed

| Site | Change |
|---|---|
| `$0143` | `$00` → `$80` (CGB enhanced, still DMG compatible) |
| `$014D` | header checksum recomputed — **the boot ROM verifies this one**; a wrong value locks the console up at the logo |
| `$01ba` | `ld a,$c0 / ldh [rLCDC],a` → `call CgbInit` + `nop` |
| `00:02fb` | `CgbInit`, 96 bytes, from `decomp/src/cgb_init.c` |

`$01ba` is the boot LCD-on. Hooking it means the new code runs with the LCD
still off — the only safe window for a bulk VRAM write — and it performs the
LCD-on itself at the end.

## What CgbInit does

1. **Feature-tests `VBK`** (`$FF4F`): writes 0, reads back, checks bit 0. In
   DMG or DMG-compat mode the register is unmapped and reads as `$FF`, so bit 0
   can never be observed as 0; in CGB mode it reads `$FE`. Everything below is
   behind this test, so the same ROM is correct on DMG hardware.

   The saved boot `A` at `$d6c9` is *not* usable for this: on CGB hardware `A`
   is `$11` even in DMG compatibility mode, which is exactly the case that must
   be skipped.

2. **Zeroes VRAM bank 1** (`$8000-$9FFF`). In CGB mode every tilemap byte has a
   companion attribute byte there selecting palette, tile bank and flips — and
   `KernelEntry` clears WRAM, OAM and HRAM but never VRAM
   (`bank_000.asm:337-363`). Left alone those attributes are boot-ROM leftovers,
   which renders as random per-tile palettes and mirroring. Zero means
   palette 0, tile bank 0, no flip.

3. **Writes the shade ramp** to all 8 BG and 8 OBJ palettes (`$7FFF` white,
   `$56B5` light, `$294A` dark, `$0000` black). All eight so that a stray
   non-zero attribute still renders sanely.

Replicating the old look is a direct translation because the kernel writes
`BGP` exactly once, at `00:01b0`, with `$E4` — the identity mapping, so colour
index N is simply shade N — and never touches it again. There are no runtime
palette effects to preserve. (Byte-scanning for `e0 47`/`f0 47` suggests other
`BGP` writes in banks 3 and 4; those are false positives, `and $f0` followed by
`ld b,a`. The disassembly shows only the one write.)

## Outcome: CGB mode is not reachable at first boot. This branch is a dead end.

Tested on a Game Boy Advance SP with a real Jr. Summary of what was proved,
in order:

1. **Flipping `$0143` in `ezgb.dat` does nothing.** The kernel booted normally,
   in the usual DMG compatibility palette. Confirmed by comparison against
   SameBoy running the same image, which honours the flag and came up in the
   diagnostic red. The console's boot ROM never sees `ezgb.dat`'s header — the
   factory bootstrap presents its own at power-on, DMG mode latches in `$FF4C`
   before our code exists, and nothing in software can undo that.

2. **The flag *is* honoured on a game launch.** Loading the same image from the
   browser as a game produced the red screen. So the launch path is a genuine
   console reset that re-reads the loaded ROM's header — which is exactly why
   launched GBC games get real colour rather than a compatibility palette.

3. **But a launched kernel has no cart hardware.** It hangs with both
   "Micro SD initial error" and the BATTERY DRY warning — identical to running
   the stock kernel under an emulator with no EZ Flash stub at all. Not a
   partial failure; the FPGA control interface is simply absent.

4. **Header fixes did not help.** Declaring an MBC with RAM (`$0147=$03`,
   `$0149=$03`), correcting the ROM size (`$0148=$03`, since `$00`/32 KB would
   leave banks 1-9 unmapped), and adding the standard MBC RAM-enable write
   (`$0A` → `$0000`) changed nothing. The hypothesis was that an emulated MBC
   was gating `$A000-$BFFF`; it was wrong.

**Why is unresolved, and one tempting explanation is wrong.** It is *not* that
the FPGA stops decoding `$7F00-$7FFF` as control registers once it emulates a
game cart (an appealing theory, since that range sits inside the ROMX window
and a real cart must return ROM bytes there). `Update_FW*.gb` refutes it:

|  | `Update_FW5` (works as a launched game) | kernel (fails) |
|---|---|---|
| `$0147` cart type | `$01` MBC1, no RAM | `$01` — identical |
| `$0149` RAM size | `$00` none | `$00` — identical |
| unlock triples / commits | 7 / 7 | 29 / 29 |
| `$a000` pointer loads | 11 | 9 |

The updater has the same header profile as the kernel, reaches both `$7Fxx` and
`$A000`, and is launched as an *ordinary game* — the kernel contains no
`UPDATE` string and special-cases nothing. So ordinary launched ROMs evidently
can drive the FPGA, and the chain-boot approach is not blocked by any mechanism
we have identified. The kernel is failing for a reason specific to itself,
most likely something its SD init depends on that the factory bootstrap
normally establishes.

Diagnosing that means finding what the kernel's `f_mount` path needs and the
game slot does not provide. It cannot be done under SameBoy — the stub models
OS mode only, and even soft-patches the SD init hang
(`soft_patch_sd_init_hang`). It would need on-hardware instrumentation: a
chain-boot build that performs the unlock handshake, reads a register back, and
renders the result as hex on screen. That is safe to try (it is only an SD
file), just unbudgeted.

**Do not test by modifying `Update_FW*.gb`.** Running it flashes FPGA firmware.
That is the one genuinely brick-risky operation on this cart, and unlike
`ezgb.dat` it cannot be undone by swapping a file back.

Getting CGB mode at first boot therefore requires changing what the *factory
bootstrap* presents to the console at power-on. That is FPGA firmware territory
— the one genuinely brick-risky area, on a layer this project has no dump of.

## Status of the code on this branch

`CgbInit` itself works and is verified under SameBoy: it is reached from the
boot hook, the VBK feature test passes, the CGB branch executes, and boot
continues into the browser. `scripts/debug/cgb-init.sbd` re-runs that check.
The code is correct; there is just no way to get the console into CGB mode for
it to matter on real hardware.

The palette currently in `decomp/src/cgb_init.c` is the **diagnostic** one
(shade 0 is bright red, deliberately unmistakable). The faithful greyscale ramp
it replaced is recorded in a comment directly above it. Restore that first if
this branch is ever revived.

Do not merge this branch. It is kept as the record of a tested dead end.

## Risk

None to the cart. This is `ezgb.dat`, a file on the SD card — if a build does
not boot, copy the previous `ezgb.dat` back. Only `Update_FW*.gb` writes cart
firmware, and nothing here goes near it.
