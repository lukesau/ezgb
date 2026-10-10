# Sending the SGB header in the background

This is a design sketch, not built or tested. It's written against the
1.05e-0731 disassembly. What ships today is the `SGB BOOT` checkbox (mod 5.3),
described in [sgb-boot.md](sgb-boot.md). The idea and most of the background
come from nitro2k01, who wrote the original SGB Enabler, in
[issue #5](https://github.com/lukesau/ezgb/issues/5).

## SGB packets

A Super Game Boy only enables SGB features after the Game Boy boot ROM sends
it the cartridge header as six packets. The SNES resets the Game Boy to make
that happen, but the Jr holds the reset line, so the header never arrives
when the SNES is listening. From nitro2k01 in
[issue #5](https://github.com/lukesau/ezgb/issues/5):

> The real issue is that both the SGB and the EZFJr implement their respective reset circuit badly. The good way is a pullup resistor+open drain output. The bad way that both are using is a digital out with a series resistor. SGB is using a 10k resistor and EZFJr a 330 ohm resistor. So EZFJr always wins. The real fix would be to make the FPGA toggle between logic low (reset) and hi-z with weak pullup (run) instead of logic low and logic high. I don't even know if a FPGA pin can really be configured this way. If it can, the SGB could send reset pulses that wouldn't just get absorbed by the cartridge.

The Enabler, and the mod's `SGB BOOT` option, send the six packets again from
the kernel: four times, with gaps of 192, 64 and 48 frames between sets and 4
frames after every packet. That's about 6.7 seconds on every boot, on every
console. On the gaps:

> Those delays are not set in stone, but derived empirically through testing on NTSC and PAL SNESes and different SD cards.

Our implementation has to satisfy two opposing constraints:

> - Bring-up speed on SGB. Because of the reset issue specific to EZFlash Jr, discussed above, the SGB runs in the background. However the SNES side doesn't bring up joypad input and audio/video output until a valid header is received by the firmware. Even when such a header is received, there's an adfirional delay before audio/video bring-up. For this reason, it's desirable to start sending header data as early as possible to enable system bring-up on SGB for improved user experience.
> - Minimizing delays on other systems where sending the header data is not necessary, and in fact does nothing at all because these commands are unique to the SGB architecture.

## Why the kernel can't just detect an SGB

> One idea is to detect non-SGB hardware and skip the delays. However the EZFlash Jr hardware loads the kernel from the stage 1 bootloader and doesn't do a system reset. The stage 1 bootloader erases all memory. All the regular detection methods like initial CPU registers are unavailable. Sending `MLT_REQ` packets to detect SGB is not available until SGB bring-up from the header packets, do this can't be done early to prevent the delay. At this point we're working blind and can't know exactly which hardware the code is running on.
>
> Perhaps GBC can be detected through undocumented registers, so the delay can be skipped there, but DMG and SGB look identical at this stage so the DMG will have the delay if using the native approach.

The mod's CGB mode already recognizes a GBC in CGB mode by testing `VBK`
([cgb-mode.md](cgb-mode.md)).

## The idea: send the packets from an interrupt

> This would be more complex but the best of both worlds: the kernel could start sending packets early and have a chance of early SGB bring-up, while the boot process is not held up significantly. With a well understood fully disassembled code base, this extra complexity is less of an issue than it was for the original patch.
>
> With this method a setting for turning off the sending of packets may not be needed. Trying to send the packets in the background basically has no downside, except increased code complexity and a very small increase in CPU usage. (The bulk of the CPU time in the original patch was delay loops which would be eliminated because this design would be interrupt driven.)

nitro2k01's plan for the first set and the rest:

> - First packet send: I'd suggest doing this directly at the entry point like the original patch. This gives a small initial delay (<1 s) but gives a chance if early SGB bring-up. The packet send code can be identical which means it doesn't rely on interrupts or anything else that's initialized later.
> - Second and further packets are scheduled in VBlank interrupts. Care should be taken to treat the 4 frame felt after sending a packet slightly differently than the delay between packet sets. It's probably a good idea to suppress joypad reading in this 4 frame delay window to avoid interfering with the SGB packet. However it should be safe to read the joypad normally right *before* a packet send starts, so that there's never more than 4 frames of missed input. It should be completely safe to read joypad normally in the long delays between packet sets

## Counting frames with VBlank

I first planned to count time with the hardware timer, because the kernel
turns the LCD off on every screen change and VBlank doesn't fire while it's
off. I asked nitro2k01 about it:

> I used VBlank as a convenient timing source, and also because I assumed that's where the current kernel would scan for it, as this is customary. I suspect timing doesn't matter so much as long as the *minimum* wait is met. Turning off the LCD should in principle only make the delay longer, never shorter. You can also consider two cases:
>
> 1. It's running on SGB. No user input can come through until the SGB has been brought up. Therefore, screen updates are less likely and the timing should stay consistent.
> 2. It's not running on SGB. Button input and therefore screen updates can happen, but since it's not running on SGB, the timings don't matter at all because nothing is listening to the commands.

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

The second bullet of that plan says when not to read the pad. nitro2k01 also
flagged a bug to avoid:

> - A bug to watch out for is that the "pressed" button mask should be cleared on the 3 frames where input is not read. Otherwise a button press on that exact frame may trigger 3 additional button presses.

Both are handled by gating `ReadJoypadRaw` (`00:3a16`), which every pad
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

A game never sends the header again, so if a game starts on an SGB before all
the packets are out, the rest must be sent before the handoff. nitro2k01:

> Because sending the packets is a "no-op" on non SGB hardware, the kernel could start sending them preemptively and unschedule the remaining SGB packets, if any packets remain to be sent. But in principle, this should not be needed. Alternatively, the setting could guarantee that all packets are sent, even if a ROM is loaded before all packets are sent. This should never happen through user interaction on SGB because button input can't happen until the header packets are successfully sent. Where this distinction might matter is for auto load, which might trigger before the packets are fully sent, and without user input.

In this kernel that case is fast launch, which starts a game without any input.

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
kernel can do.

The first is the fix in the reset-circuit quote at the top: drive the reset
pin low or high-impedance with a weak pull-up, instead of low or high. It
isn't known yet whether that pin can be set up this way.

The other two options, in nitro2k01's words:

> If you wanted to solve SGB reset sequencing from the cartridge side, you'd need multiple well timed reset cycles that match what the SGB would do. This could work in theory, but then every other console will "hesitate" to start as it resets a couple of time before it gets going. Pretty ugly solution for anything that's not a SGB.
>
> However, one more option remains, if we allow modification of the stage 1 bootloader. The bootloader could simply store the initial registers, and restore them before the kernel runs. Or the kernel could consult a well specified location in RAM. If SGB is detected this way, or conversely a another console version is detected confidently this way, the kernel could then make an informed decision to send or not send the packages. Everything else, like the setting etc, then becomes a fallback for when the FPGA didn't have a compatible stage 1.

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
