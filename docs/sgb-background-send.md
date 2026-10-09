# Sending the SGB header in the background

This is a design sketch, not built or tested. It's written against the
1.05e-0731 disassembly. What ships today is the `SGB BOOT` checkbox (mod 5.3),
described in [sgb-boot.md](sgb-boot.md). The idea and most of the background
come from nitro2k01, who wrote the original SGB Enabler, in
[issue #5](https://github.com/lukesau/ezgb/issues/5).

## Why the packets are needed at all

On a Super Game Boy, the SNES side holds the Game Boy CPU in reset while it
starts up, then lets it run briefly so the boot ROM can send six packets
carrying the cartridge header. When the header arrives, the SNES resets the
Game Boy and listens for it again, possibly a third time. If the header has
the SGB flag set, the game is allowed to send SGB commands later. If the flag
is missing, the SNES ignores every later SGB command until it is reset.

The EZ Flash Jr also drives the Game Boy reset line. It holds the CPU in reset
while the FPGA loads, releases it, and from then on holds it in run. Both
sides drive reset badly: the SGB drives it through a 10 kΩ resistor and the
Jr through 330 Ω, so the Jr always wins. The SNES never manages to reset the
Game Boy, the boot ROM has already sent its header before the SNES was
listening, and the SNES waits forever with a black screen.

The Enabler, and the mod's `SGB BOOT` option, fix this by sending the same six
packets again from the kernel: four times, with gaps of 192, 64 and 48 frames
between sets, and 4 frames after every packet. That costs about 6.7 seconds
on every boot, on every console, which is why it is a checkbox.

The gaps were found by testing on NTSC and PAL SNESes with different SD cards.
They aren't exact requirements. The first gap may only matter for fast SD
cards, and nitro2k01 suspects that reading the setting already adds enough
delay that the gaps could be shorter.

## Two goals that pull against each other

- **On an SGB, send early.** The SNES doesn't turn on the picture, sound or
  joypad until it has a valid header, and even then there is a further delay.
  The sooner the packets go out, the sooner the SGB comes up.
- **Everywhere else, don't wait.** On a DMG, GBC or GBA the packets do nothing,
  so any time spent sending them is wasted.

## Why the kernel can't just detect an SGB

Normally a program can tell which console it's on from the CPU registers the
boot ROM leaves behind. On the Jr the kernel doesn't start from the boot ROM.
The stage 1 loader runs first, loads the kernel and jumps to it without a
reset, and it clears memory along the way. Asking the SGB directly with an
`MLT_REQ` packet doesn't work either, because the SGB only answers after it
has received the header. A GBC can probably be recognised by its extra
registers (the mod's CGB mode already tests `VBK`), but a DMG and an SGB look
the same at this point.

## The idea: send the packets from an interrupt

Send the first set at boot exactly as now, then send the other three in the
background while the kernel carries on starting up. On an SGB the header
still goes out early. On everything else the boot is only about 0.4 s
longer, for the first set. Since the packets are harmless on other consoles,
the background sends could always run, and the checkbox might not be needed.

## Counting frames with VBlank

I first planned to count time with the hardware timer, because the kernel
turns the LCD off on every screen change and VBlank doesn't fire while it's
off. nitro2k01 pointed out that this doesn't matter. The SGB only needs each
gap to be at least as long as the Enabler's. With the LCD off, VBlank counting
can only make the gaps longer, never shorter. There are two cases:

1. **On an SGB**, nobody can press anything until the SGB is up, so there are
   few screen changes and the timing stays close to the Enabler's.
2. **On anything else**, screen changes can stretch the gaps, but nothing is
   listening, so it doesn't matter.

So this version counts VBlanks and drops the timer. That also removes the
`rTAC`/`rIE` changes, the `SetIeReg` risk, and the need to stop a live timer
before a game starts.

## How it would work

| Step | When | Cost |
|---|---|---|
| Set 1 (6 packets, 4 frames apart) | at `$0100`, blocking, same code as now | ~0.4 s on every boot |
| Sets 2-4 (18 packets) | counted and sent from a VBlank callback | one packet send per due frame |
| Joypad freeze | the 4 frames after each packet | input held at its last state |
| Fast launch before all 18 are out | send the rest blocking, or drop them | see [Launching a game](#launching-a-game) |

A packet is 130 bits. By instruction count `SgbSendPacket`'s bit loop takes
about 2,500 M-cycles, roughly twice as long as VBlank (~1,140 M-cycles). Any
VBlank callback that writes VRAM or OAM must run before ours, or the packet
pushes its writes into the visible part of the frame. The mid-screen LYC
interrupt at line `$48` is about 8,000 M-cycles away, so it isn't affected.

## State (HRAM)

`KernelEntry` clears HRAM, so this is set up after it. The mod already uses
`$ff80` (OAM DMA stub), `$fffa` hFrame, `$fffb` hUiMode and `$fffc`/`$fffd`
(pad latch). Proposed, to be checked as unused first:

| Addr | Name | Meaning |
|---|---|---|
| `$fff7` | `hSgbStep` | next packet, 0-17 for sets 2-4; 18 means all sent |
| `$fff8` | `hSgbWait` | frames until that packet is due |
| `$fff9` | `hSgbBusy` | frames of joypad freeze left |

## Code

Bank 0 has no free run longer than 31 bytes, so most of this goes in bank 1's
free space at `01:762f` (2,257 B) next to `SgbUnlock`. The two small bank-0
pieces fit in the holes at `00:0597` (31 B) and `00:05f2` (14 B).

### Start (bank 1)

`KernelEntry` maps bank 1 (`ld [$2000], 1`) before it calls `CgbInit` at
`$01ba`, so that call can point straight into bank 1:

```asm
; 00:01ba  call CgbInit  ->  call SgbBootHook
SgbBootHook::               ; 01:7xxx
    call CgbInit            ; as before
    ld a, [$d6c9]           ; boot A, saved by KernelEntry
    cp $11
    ret z                   ; GBC/GBA: nothing to send
    xor a
    ldh [hSgbStep], a
    ldh [hSgbBusy], a
    ld a, 192               ; set 1 already waited 4 frames after its last packet
    ldh [hSgbWait], a
    ld bc, SgbVBlankCb
    jp RegisterVBlankCallback
```

`SgbUnlock` at `$0100` keeps its first `SgbSendHeader` and drops the three
waits and later sends. It becomes set 1 followed by `jp $0150`. If `$d6c9`
really is the boot value, `SgbUnlock` could check A the same way on entry,
and then GBC and GBA wouldn't pay for set 1 either.

### VBlank callback (bank 0, `00:0597`, 17 B)

```asm
SgbVBlankCb::               ; call into bank 1, then put the caller's bank back
    ld a, [wRomBank]
    push af
    ld a, $01
    ld [$2000], a
    call SgbFrame
    pop af
    ld [$2000], a
    ret
```

`RunCallbackList` already saves AF/BC/DE/HL. One race needs ruling out: main
code writing `$2000` before `wRomBank`, with the interrupt landing in between.
Check the order in the far-call trampoline.

The callback stays registered after the last packet and just returns.
Removing it from inside the interrupt isn't safe, because `RunCallbackList`
is walking the list at that moment.

### Per frame (bank 1)

```asm
SgbFrame::
    ldh a, [hSgbBusy]       ; count down the joypad freeze
    and a
    jr z, .notBusy
    dec a
    ldh [hSgbBusy], a
.notBusy
    ldh a, [hSgbStep]
    cp 18
    ret nc                  ; all sent
    ldh a, [hSgbWait]
    dec a
    ldh [hSgbWait], a
    ret nz                  ; not due yet

    ldh a, [hSgbStep]       ; packet index within the set = step % 6
.mod6
    cp 6
    jr c, .gotIdx
    sub 6
    jr .mod6
.gotIdx
    ld c, a
    add a, a
    add a, $f1
    ld b, a                 ; command $F1 + 2*idx
    ld a, c                 ; de = $0104 + 14*idx
    ld e, $04
.mul
    and a
    jr z, .gotPtr
    ld h, a
    ld a, e
    add a, 14
    ld e, a
    ld a, h
    dec a
    jr .mul
.gotPtr
    ld d, $01
    call SgbStreamPacket    ; no wait afterwards
    ld a, 4
    ldh [hSgbBusy], a       ; freeze the joypad for 4 frames
    ldh a, [hSgbStep]
    inc a
    ldh [hSgbStep], a
    ld c, 4                 ; next packet in the same set
    cp 6
    jr nz, .notSet3
    ld c, 64 + 4
.notSet3
    cp 12
    jr nz, .setWait
    ld c, 48 + 4
.setWait
    ld a, c
    ldh [hSgbWait], a
    ret
```

`SgbStreamPacket` is the per-packet part of `SgbSendHeader` without the
16-byte WRAM buffer, since `$c000` belongs to the kernel after boot. It sums
the 14 bytes at `de` (counting anything from `$0150` on as zero), then sends
the reset pulse, `b`, the sum, the 14 bytes and the stop bit, using
`SgbSendPacket`'s bit loop. It must not fall through into `SgbWaitFrames`.

## Joypad

nitro2k01 gave two rules. Don't drive P1 in the 4 frames after a packet,
because that can interfere with the SGB receiving it. And make sure skipped
frames can't turn one press into several: if the "pressed" mask isn't cleared
while input is skipped, a press on that exact frame can fire three more
times. Reading the pad right before a packet is fine, and so is reading it
normally in the long gaps between sets.

Both rules are handled by gating `ReadJoypadRaw` (`00:3a16`), which every pad
read goes through, and returning the last known state while frozen:

```asm
; 00:3a16  push bc / ld a, $20  ->  jp SgbPadGate
SgbPadGate::                ; 00:05f2
    ldh a, [hSgbBusy]
    and a
    jr nz, .frozen
    push bc
    ld a, $20
    jp $3a19                ; ldh [rP1], a and the rest of ReadJoypadRaw
.frozen
    ldh a, [$fc]            ; last state the latch saw
    ret
```

The frozen value is the same as `$fffc`, so `VBlankPadLatch` sees no new
presses and the latch at `$fffd` doesn't change. A held button doesn't
repeat, and a press just before the freeze still gets through. A tap that
starts and ends inside one 4-frame window (67 ms) is lost. There are 18 of
those windows in the first ~6 seconds after boot and none after that.

## Launching a game

A game never sends the header again. So if a game starts on an SGB before all
the packets are out, the rest must be sent before the handoff. On an SGB
nobody can press A until the header has gotten through, so this only matters
for fast launch, which starts a game without any input.

A hook before the launch farcalls (`MenuDispatchAB_launchFarcalls`,
`00:1569`; check that fast launch's `LastRomRelaunch` path goes through it
too) would either send the rest blocking or drop it. `SgbWaitFrames` is a busy
loop, so it works with the LCD off:

```asm
SgbFinish::                 ; bank 1
    ldh a, [hSgbStep]
    cp 18
    ret nc                  ; nothing left
    ; SGB BOOT off: drop the rest (ld a, 18 / ldh [hSgbStep], a / ret)
    di                      ; keep the VBlank callback out of it
.loop
    ldh a, [hSgbWait]
    ld d, a
    call SgbWaitFrames
    ld a, 1
    ldh [hSgbWait], a       ; SgbFrame counts it to 0 and sends
    call SgbFrame
    ldh a, [hSgbStep]
    cp 18
    jr c, .loop
    ei                      ; check IME was on here
    ret
```

That is where the checkbox could still be useful. The background sends could
always run, and `SGB BOOT` would only decide whether fast launch waits for
them. On a DMG with fast launch and the box off, the only change from today
would be set 1's 0.4 s.

## Costs

| Console | Boot | Input | Fast launch |
|---|---|---|---|
| SGB | 0.4 s, menu usable once the SNES comes up | 18 short freezes | waits up to ~6.3 s (box on) |
| DMG | 0.4 s | 18 short freezes | no wait (box off) |
| GBC / GBA | 0.4 s, or 0 if `SgbUnlock` checks A | none | none |

## Fixing it from stage 1 or the FPGA instead

The FPGA's level 1 firmware (stage 1) is now decoded and can be rebuilt (see
the `bitstream-re` branch), which opens up better fixes than anything the
kernel can do:

- **Let the SGB reset the Game Boy.** If the FPGA released reset by switching
  its pin to high-impedance with a weak pull-up, instead of driving it high,
  the SGB's reset pulses would get through and the normal boot sequence would
  work. It isn't known yet whether that pin can be set up this way.
- **Pass the boot registers on.** Stage 1 starts from the real boot ROM, so it
  can save the initial CPU registers and hand them to the kernel at a fixed
  RAM address. The kernel could then tell an SGB from a DMG and only send the
  packets on an SGB. The checkbox and this background scheme would become the
  fallback for carts without that stage 1.
- **Resetting several times from the cart** to imitate the SGB's sequence
  would work in theory, but every other console would visibly stall while it
  resets a few times.

For reference, EZ Flash's 2020 `FW5_forSGB_BETA` firmware only sets the SGB
flags in stage 1's header (confirmed). As far as nitro2k01 knows it doesn't
make SGB boot more reliable; you still press the cart's reset button to get
it to boot on an SGB.

## Still to check

- Does stage 1 leave the boot A value alone, so `$d6c9` is really `$11` on
  GBC/GBA? Check with the debug build.
- Are `$fff7`-`$fff9` free? Is there a spare VBlank callback slot, and does
  `EnterGfxMode1`, which registers one per screen, keep ours?
- Does our callback run after every VBlank callback that writes VRAM or OAM?
- Do both launch paths go through `00:1569`?
- The bank-switch race between `SgbVBlankCb` and the far-call trampoline.
- How short can the gaps be? With set 1 the only blocking one, the 192-frame
  gap now overlaps kernel start-up instead of delaying it, and nitro2k01
  thinks shorter is probably fine.

## Testing

In SameBoy's SGB logging build (see [sgb-boot.md](sgb-boot.md)), check for 24
packets with valid checksums, set gaps at least as long as the Enabler's, no
tearing on the browser while packets go out, and no doubled presses when
`scripts/showcase/keys.swift` taps buttons during the first 7 seconds. DMG
boot time should be stock plus 0.4 s. Then on chunkysteveo's SGB.
