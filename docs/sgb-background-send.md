# SGB header in the background (design sketch, not built)

Response to nitro2k01's suggestion in
[issue #5](https://github.com/lukesau/ezgb/issues/5): send the first header
set at boot as now, then send the other three from an interrupt while the
kernel boots normally, so nobody waits 6.7 s. This is a sketch against the
1.05e-0731 disassembly; nothing here is injected or tested. Current
implementation: [sgb-boot.md](sgb-boot.md).

## Shape

| Step | When | Cost |
|---|---|---|
| Set 1 (6 packets, 4 frames apart) | at `$0100`, blocking, unchanged code | ~0.4 s on every boot |
| Sets 2-4 | timer-counted, sent from the VBlank callback | ~0.5 ms per packet, 18 packets |
| Pad freeze | 4 frames after each packet | input held at its last state |
| Before a game launches | wait for, or cancel, what is left | see [Launch](#launch) |

Gaps stay the Enabler's: 192, 64 and 48 frames before sets 2, 3 and 4, and
4 frames after every packet.

## Clock: timer, not VBlank

VBlank only fires with the LCD on, and `EnterGfxMode1` turns the LCD off on
every screen change. Counting VBlanks would stretch the gaps by an unknown
amount, and the gaps were tuned on hardware. The timer runs whether the LCD
is on or not, the kernel never touches it (no `rTAC`/`rTMA` writes anywhere),
and the callback machinery already has an unused timer list
(`TimerOverflowInterrupt` -> `wTimerCallbacks`, `RegisterTimerCallback`
`00:063a`).

`TAC = $04` (4096 Hz) with `TMA = $C0` overflows every 64 counts: a 64 Hz
tick, close to the 59.73 Hz frame rate. In ticks:

| Frames | Seconds | Ticks |
|---|---|---|
| 192 | 3.215 | 206 |
| 64 | 1.072 | 69 |
| 48 | 0.804 | 52 |
| 4 | 0.067 | 5 (rounded up) |

Time with interrupts off (SD reads, `DiNest` sections) still stretches the
count, by at most one tick per such stretch since a pending timer IRQ waits
in `IF`. That's far less than VBlank counting would lose.

## Where the packet goes out: VBlank

A packet is 130 bits, about 2,000 M-cycles. Sending it from the timer ISR at a
random scanline could delay the LYC interrupt at line `$48` (`LycCb_Bg8800`,
the mid-screen tile-bank switch) and tear one frame. So the timer only counts;
when a packet is due it sets `hSgbDue`, and a VBlank callback sends it at the
top of VBlank, with ~8,000 cycles before line `$48`. With the LCD off there's
no VBlank and no split to protect, so the timer sends directly.

## State (HRAM)

KernelEntry clears HRAM, so this is set up after it. Mod HRAM today: `$ff80`
OAM DMA stub, `$fffa` hFrame, `$fffb` hUiMode, `$fffc`/`$fffd` pad latch.
Proposed (confirm unused first):

| Addr | Name | Meaning |
|---|---|---|
| `$fff6` | `hSgbStep` | next packet, 0-17 (sets 2-4); 18 = done |
| `$fff7` | `hSgbWait` | ticks until that packet is due |
| `$fff8` | `hSgbBusy` | ticks of pad freeze left |
| `$fff9` | `hSgbDue` | 1 = VBlank should send now |

## Code

Bank 0 has no run of free bytes over 31, so the bulk goes in bank 1's free run
at `01:762f` (2,257 B) next to `SgbUnlock`, with small bank-0 pieces in the
holes at `00:0597` (31 B) and `00:05f2` (14 B).

### Start (bank 1, no bank-0 bytes)

KernelEntry maps bank 1 (`ld [$2000], 1`) before `call $0259` (CgbInit), so
that call can point straight at bank 1:

```asm
; 00:01ba  call $0259  ->  call SgbBootHook
SgbBootHook::               ; 01:7xxx
    call $0259              ; CgbInit, as before
    ; skip on GBC/GBA: boot A is $11 there (KernelEntry saved it at $d6c9)
    ld a, [$d6c9]
    cp $11
    ret z
    ; (optionally: ret if the SGB BOOT record is off, see Launch)
    xor a
    ldh [hSgbStep], a
    ldh [hSgbBusy], a
    ldh [hSgbDue], a
    ld a, 206 + 5           ; 192-frame gap, after set 1's last 4 frames
    ldh [hSgbWait], a
    ld bc, SgbTimerCb
    call RegisterTimerCallback
    ld bc, SgbVBlankCb
    call RegisterVBlankCallback
    ld a, $c0
    ldh [rTMA], a
    ldh [rTIMA], a
    ld a, $04
    ldh [rTAC], a
    ret
```

and one byte a few lines later: KernelEntry's `ld a, $09 / ldh [rIE], a` (operand at `00:01c0`)
becomes `ld a, $0d` (VBlank + timer + serial). `EnterGfxMode1` ORs `$02` into
`rIE`, so it keeps the bit. `SetIeReg` (`00:0710`) writes `rIE` outright and
would drop it; its callers need checking.

`SgbUnlock` at `$0100` keeps its first `SgbSendHeader` and drops the three
waits and later sends: it becomes set 1 and then `jp $0150`.

### Callbacks (bank 0, `00:0597`, ~24 B)

```asm
SgbVBlankCb::
    ldh a, [hSgbDue]
    and a
    ret z
    ld hl, SgbSendDue
    jr SgbBank1
SgbTimerCb::
    ld hl, SgbTick
SgbBank1:                   ; call bank-1 hl, put the caller's bank back
    ld a, [wRomBank]
    push af
    ld a, $01
    ld [$2000], a
    call CallHL             ; 00:0093
    pop af
    ld [$2000], a
    ret
```

`RunCallbackList` already saves AF/BC/DE/HL. The race to rule out: main code
writing `$2000` before `wRomBank` and the ISR landing in between. Check the
far-call trampoline's order.

### Tick and send (bank 1)

```asm
SgbTick::                   ; 64 Hz
    ldh a, [hSgbBusy]
    and a
    jr z, .notBusy
    dec a
    ldh [hSgbBusy], a
.notBusy
    ldh a, [hSgbStep]
    cp 18
    ret nc                  ; done
    ldh a, [hSgbDue]
    and a
    ret nz                  ; waiting for VBlank to send
    ldh a, [hSgbWait]
    dec a
    ldh [hSgbWait], a
    ret nz
    ldh a, [rLCDC]
    bit 7, a
    jr z, SgbSendDue        ; LCD off: no VBlank coming, send now
    ld a, 1
    ldh [hSgbDue], a
    ret

SgbSendDue::
    xor a
    ldh [hSgbDue], a
    ldh a, [hSgbStep]
.mod6                       ; a = step % 6
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
    call SgbStreamPacket    ; no trailing wait
    ld a, 5
    ldh [hSgbBusy], a       ; freeze the pad for 4 frames
    ldh a, [hSgbStep]
    inc a
    ldh [hSgbStep], a
    cp 18
    jr z, SgbStop
    ld c, 5                 ; next packet in the same set
    cp 6
    jr nz, .notSet3
    ld c, 69 + 5
.notSet3
    cp 12
    jr nz, .setWait
    ld c, 52 + 5
.setWait
    ld a, c
    ldh [hSgbWait], a
    ret

SgbStop::                   ; leave the callbacks registered as no-ops
    xor a
    ldh [rTAC], a
    ldh a, [rIE]
    and ~$04
    ldh [rIE], a
    ret
```

`SgbStreamPacket` is `SgbSendHeader`'s per-packet body without the 16-byte
WRAM buffer (`$c000` is the kernel's after boot): sum the 14 bytes from `de`
(zero from `$0150` on), then clock out reset, `b`, the sum, the 14 bytes, and
the stop bit, reusing `SgbSendPacket`'s bit loop. It must not fall into
`SgbWaitFrames`.

Callbacks are not removed from inside the ISR: `RunCallbackList` is walking
the list at that moment.

### Pad freeze (bank 0, `00:05f2`, 14 B)

nitro2k01's two joypad rules: don't drive P1 in the 4 frames after a packet,
and don't let skipped frames turn one press into several. Both are handled by
gating `ReadJoypadRaw` (`00:3a16`), the one primitive every pad read goes
through, and returning the last known state while frozen:

```asm
; 00:3a16  push bc / ld a, $20  ->  jp SgbPadGate
SgbPadGate::
    ldh a, [hSgbBusy]
    and a
    jr nz, .frozen
    push bc
    ld a, $20
    jp $3a19                ; ldh [rP1], a; rest of ReadJoypadRaw
.frozen
    ldh a, [$fc]            ; last state the latch saw
    ret
```

Because the frozen value equals `$fffc`, `VBlankPadLatch` sees no new edges
and the latch at `$fffd` stays as it was, so a held button doesn't repeat and
a press just before the freeze is still delivered. A tap that starts and ends
inside one 67 ms window is lost. That's 18 windows in the ~6 s after boot,
and none after.

## Launch

A game never resends the header, so on an SGB that hasn't come up yet the
remaining sets must go out before the handoff, and the timer has to be off
before the game's code runs (the `$7fe0 = $80` handoff may not reset the CPU,
and a live timer IRQ would land in the game's `$0050`).

On an SGB nobody can press A until the header has gotten through, so this
matters only for fast launch. A hook before the launch farcalls
(`MenuDispatchAB_launchFarcalls`, `00:1569`; confirm fast launch's
`LastRomRelaunch` path reaches it too) would do:

```asm
SgbFinish::
    ldh a, [hSgbStep]
    cp 18
    jr nc, .stop
    ; wait (SGB BOOT on) or skip the wait (off)
.wait
    halt                    ; IME on here?
    ldh a, [hSgbStep]
    cp 18
    jr c, .wait
.stop
    call SgbStop
    ldh a, [rIF]
    and ~$04
    ldh [rIF], a
    ret
```

The choice of wait or cancel is where the checkbox could live on: with this
design, background sends are harmless, so they could always run, and
`SGB BOOT` would only decide whether fast launch waits for them. On a DMG
with fast launch and the box off nothing changes from today except set 1's
0.4 s.

## Costs

| Console | Boot | Input | Fast launch |
|---|---|---|---|
| SGB | 0.4 s, menu usable once the SNES comes up | 18 short freezes | waits ≤ 6.3 s (box on) |
| DMG | 0.4 s | 18 short freezes | no wait (box off) |
| GBC / GBA | 0 if the `$d6c9` check holds | none | none |

## Open questions

- Is `$d6c9` really `$11` on GBC/GBA under the Jr, i.e. does stage 1 leave
  boot A alone? Check with the debug build.
- Who calls `SetIeReg`, and with what? Any absolute write without `$04`
  silently stops the timer.
- Are `$fff6`-`$fff9` free, and is there a spare VBlank callback slot
  (`EnterGfxMode1` registers one per screen)?
- Do both launch paths pass `00:1569`?
- Bank-switch race in `SgbBank1` against the far-call trampoline.
- Do the gaps still work when set 1 is the only blocking one? The SGB
  side doesn't care who sends, but the 192-frame gap now overlaps kernel init
  instead of delaying it; nitro2k01 thinks shorter is probably fine.

## Testing

SameBoy's SGB logging build (see [sgb-boot.md](sgb-boot.md)): 24 packets,
valid checksums, set spacing within a tick of the table; no tear on the
browser at line `$48` while packets go out; `scripts/showcase/keys.swift` taps
during the first 7 s with no doubled presses; DMG boot time back to stock
+0.4 s. Then chunkysteveo's SGB.
