# Super Game Boy

On a Super Game Boy the stock Jr shows a black screen forever. The Jr holds
the Game Boy CPU in reset while its FPGA loads, so the CPU misses the
moment the SNES listens for the six packets the boot ROM sends with the
cartridge header, and the SNES never shows a picture. nitro2k01's
[SGB Enabler](https://blog.gg8.se/wordpress/2021/08/19/nitro2k01s-sgb-enabler-for-ez-flash-jr/),
a patched 1.04e kernel, fixed it by sending those packets again from the
kernel. The mod does the same, and sends most of them in the background, as
he proposed in [issue #5](https://github.com/lukesau/ezgb/issues/5).
Addresses are 1.05e-0731's.

## Using it

On a DMG, GBC or GBA: SET tab, second page, tick `SGB BOOT:`. Move the cart
to the Super Game Boy and power on.

With the box ticked every boot takes about 0.4 s longer, on any console. A
fast launch in the first few seconds waits for the rest of the packets, so
with fast launch set up, untick the box when the cart goes back to a
handheld.

With our stage1 the box is not needed: stage1 detects the SGB and sends the
packets itself, and the SET tab shows `SGB: AUTO`
([fpga-stage1.md](fpga-stage1.md#super-game-boy)).

## Where the setting lives

Not in `EZGB.CFG`: the packets go out at the very start of the boot, long
before the SD card is up. It is a record in pSRAM, page `$11` at `$A400`
([psram-map.md](psram-map.md#page-11)). Only `'S'`, `'G'`, `$01`, `$FE`
counts as on. Anything else boots straight on: a cart that never had the
mod, or garbage from a dead cell. A cart without a coin cell keeps the
record for about a minute out of the console.

The kernel first reads stage1's mark at `$A412`. `"SB"` or `"SN"` means our
stage1 handles the SGB, and the kernel sends nothing.

## What is sent

The boot ROM's six header packets: commands `$F1` to `$FB`, each carrying
its checksum and 14 bytes of `$0104`-`$014F`, zero past the end. The
Enabler sends the set four times, with gaps of 192, 64 and 48 frames, and
so does the mod. The packets are built from the live header, so their
checksums cannot go stale.

The SGB BIOS ignores a cart without both header marks, so the kernel's
header carries them: `$0146 = $03` and `$014B = $33`, with `$014D`
recomputed.

| Step | When | Cost |
|---|---|---|
| Set 1, six packets 4 frames apart | at `$0100`, before `KernelEntry`, blocking | 0.42 s on every boot with the box ticked |
| Sets 2 to 4, 18 packets | one packet per due frame, from the VBlank interrupt | about 3,800 M-cycles a packet |
| The pad is frozen | for the 4 frames after each packet | input held at its last state |
| A game launched before all 18 are out | the rest is sent first, blocking | up to about 6.3 s, only on a fast launch in the first seconds |

With the box unticked nothing is sent and nothing waits.

## The code

Everything is in [sgb_boot.asm](../kernel/mod/asm/sgb_boot.asm).
`scripts/inject-sgb.py <ver> --apply` assembles it with the kernel's
addresses from `kernel.sym` and patches the hook sites and the header. Run
it on 1.05e-0731 and port.

| Where | What |
|---|---|
| `$0100` | `nop; jp SgbStub` where stock has `jp KernelEntry` |
| `SgbStub` `00:0020` | maps bank 4 and jumps to `SgbUnlock` |
| `SgbLaunchHook` `04:7d00` | the bank-4 block: `SgbUnlock` (set 1), `SgbCheck`, the packet sender, `SgbFrame`, `SgbStep`, `SgbFinish` |
| `SgbBootHook` `01:7f00` | `KernelEntry`'s call at `00:01ba`: starts the count to set 2, then `jp CgbInit` ([cgb-mode.md](cgb-mode.md)) |
| `00:0040`, the VBlank vector | `call SgbVblList` / `jp SgbVblTail` |
| `SgbVblList` `00:04e1` | the stock vector's body: run the callback list |
| `SgbVblTail` `00:02c3` | after the list: when a step is pending, map bank 4 and call `SgbFrame` |
| `SgbPadGate` `00:05f2` | `ReadJoypadRaw` (`00:3a16`) starts with a `jp` here |
| `04:448f` | `RomLoad_CopyCmdWindowPoll_B4` starts with `jp SgbLaunchHook` |

Bank 4 holds the bulk because it is the only bank with room at the same
address in all three kernels.

### Set 1 and the hand-off

`SgbUnlock` checks the record and the stage1 mark, sends packets 0 to 5
with a cycle-counted 4-frame wait after each, restores `A`, and jumps to
`$0150` with `E = 1`, or `E = 0` when it sent nothing. `KernelEntry` clears
all of WRAM and HRAM but does not touch `E` before its call at `$01ba`, so
`SgbBootHook` reads it there: `E = 1` sets the state for set 2.

### State

| HRAM | Name | Meaning |
|---|---|---|
| `$fff2` | `hSgbStep` | 1 to 18: the next packet of sets 2 to 4. 19: the last packet's freeze. 0: nothing to do |
| `$fff3` | `hSgbWait` | frames until that step is due |
| `$fff4` | `hSgbBusy` | frames of pad freeze left |

A cleared HRAM means idle, so a boot with the box off never enters
`SgbFrame`.

These three bytes are declared only in the assembly. **Search
`kernel/mod/asm` as well as `kernel/mod/src` before taking an HRAM byte**:
a C block that reused two of them hung the browser on hardware and never in
the emulator.

### Sending from VBlank

The send runs after the callback list, not as one of its callbacks,
because a packet takes far longer than a callback may. The vector calls the
list as a subroutine, and the list's `reti` returns to the tail with
interrupts on:

```asm
SgbVblTail:
    push af
    ldh a, [hSgbStep]
    and a
    jr z, .done             ; the usual case: 9 cycles a frame
    di
    ld a, [wRomBank]
    push af
    ld a, BANK(SgbFrame)
    ld [$2000], a
    call SgbFrame
    pop af
    ld [$2000], a
.done
    pop af
    reti
```

Main code writes `$2000` only between `DiNest` and `EiNest`, so whenever
VBlank is taken `wRomBank` is the mapped bank. Main-code VRAM writes do not
mind the long interrupt, since each is a STAT check and a write under `di`
([drawing-timing.md](drawing-timing.md)).

`SgbFrame` counts the freeze down, decrements `hSgbWait`, and at zero calls
`SgbStep`, which sends packet `(step - 1) mod 6`, sets `hSgbBusy = 4` and
sets the next wait.

### The pad

While a packet's freeze lasts, the pad must not be driven. `SgbPadGate`
returns the last state the latch saw (`$fffc`) in place of a live read, so
`VBlankPadLatch` sees no new presses, a held button does not repeat, and
nothing is counted twice ([input.md](input.md)). Inside a set the pad is
read once every 4 frames, so a tap shorter than that can be lost. That is
possible only during the three bursts of sets 2 to 4, in the first seven
seconds after boot.

### Launching a game

A game never sends the header again, so a launch on an SGB before all the
packets are out must send the rest first. Every launch ends in the one far
call to `RomLoad_CopyCmdWindowPoll_B4`, whose first instructions are
`jp SgbLaunchHook`. `SgbFinish` there waits out the same gaps the
background would have and sends what is left, with interrupts nested off.
A launch after sets 2 to 4 are done costs nothing.

## Differences from the Enabler

- The packets are built from the live header.
- Set 1's waits count CPU cycles, so they do not depend on the LCD being
  on.
- `A` is preserved for `KernelEntry`.
- Only set 1 holds up the boot.

## Status

The kernel's unlock is confirmed on a real Super Game Boy. The background
send of sets 2 to 4, and stage1's detection, are checked in SameBoy only.
