# Sending the SGB header in the background

Built in mod 7.0, against the 1.05e-0731 disassembly and ported to 0918 and
1.04e: with `SGB BOOT` ticked ([sgb-boot.md](sgb-boot.md)) only the first of
the four header sets blocks the boot (about 0.4 s instead of 6.7 s), and the
other three go out from the VBlank interrupt. The idea and most of the
background come from nitro2k01, who wrote the original SGB Enabler, in
[issue #5](https://github.com/lukesau/ezgb/issues/5). Checked in SameBoy
(below); not yet tried on a real Super Game Boy.

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

## How it works

| Step | When | Cost |
|---|---|---|
| Set 1 (6 packets, 4 frames apart) | at `$0100`, blocking, before `KernelEntry` | 0.42 s on every boot with the box ticked |
| Sets 2-4 (18 packets) | one packet per due frame, from the VBlank interrupt | ~3,800 M-cycles per packet, 18 times |
| Joypad freeze | the 4 frames after each packet | input held at its last state |
| A game launch before all 18 are out | the rest is sent blocking first | up to ~6.3 s, only on a fast launch in the first seconds |

The box gates all of it: unticked, nothing is sent and nothing waits, as
before. nitro2k01 thought the setting might not be needed once the send is in
the background; it stays so that a cart that never goes near an SGB doesn't
pay set 1's 0.42 s on every boot. Everything is in [scripts/sgb/sgb_boot.asm](../scripts/sgb/sgb_boot.asm);
[scripts/inject-sgb.py](../scripts/inject-sgb.py) assembles it with the kernel
addresses from `kernel.sym` and patches the hook sites, and `port-mod.py`
carries it to 0918 and 1.04e.

| Where | What |
|---|---|
| `00:0020` `SgbStub` | `$0100` lands here: map bank 4, `jp SgbUnlock` |
| `04:7d00` `SgbLaunchHook` | the bank-4 block: launch hook, `SgbUnlock` (set 1), `SgbCheck`, the packet sender, `SgbFrame`/`SgbStep`, `SgbFinish` |
| `01:7f00` `SgbBootHook` | `KernelEntry`'s `call CgbInit` (`00:01ba`): start the count to set 2, then `jp CgbInit` |
| `00:0040` | VBlank vector: `call SgbVblList` / `jp SgbVblTail` |
| `00:04e1` `SgbVblList` | the stock vector body (`push hl / ld hl, wVBlankCallbacks / jp RunCallbackList`) |
| `00:02c3` `SgbVblTail` | after the list: if a step is pending, map bank 4, `SgbFrame`, map back |
| `00:05f2` `SgbPadGate` | `ReadJoypadRaw` (`00:3a16`) starts with `jp SgbPadGate` |
| `04:448f` | `RomLoad_CopyCmdWindowPoll_B4` starts with `jp SgbLaunchHook` |

Bank 4 holds the bulk because it is the only bank with room at the same
address in all three kernels (`04:7cc2`, 830 B); bank 1's runs at `$7500` and
`$7391` are not free in 0918.

### Set 1 and the hand-off to `KernelEntry`

`SgbUnlock` runs `SgbCheck` (the pSRAM record and stage1-mark test from mod
5.9), sends packets 0-5 with a 4-frame busy-wait after each, and leaves `E = 1`
(or `E = 0` when it sent nothing) before `jp $0150`. `KernelEntry` clears all
of WRAM and HRAM, but it doesn't touch `E` before its `call CgbInit` at
`$01ba` (the same code in all three kernels), so `SgbBootHook` reads it there,
after the clear: `E = 1` sets `hSgbStep = 1` and `hSgbWait = 192`. `CgbInit`
then runs as before.

### State (HRAM)

| Addr | Name | Meaning |
|---|---|---|
| `$fff2` | `hSgbStep` | 1-18: next packet of sets 2-4; 19: the last packet's freeze; 0: nothing to do |
| `$fff3` | `hSgbWait` | frames until that step is due |
| `$fff4` | `hSgbBusy` | frames of joypad freeze left |

Nothing in the kernel or the mod reads or writes `$fff2`-`$fff4`. A cleared
HRAM means idle, so a boot with the box off never enters `SgbFrame`.

> **Correction (2026-10-12).** The sketch proposed `$fff7`-`$fff9`. `$fff7`
> is `hPadHeld` ([joypad-latch.md](joypad-latch.md), mod 6.8) and `$fff9` is
> `hClip12` ([set-pane12.md](set-pane12.md)); both were taken before this was
> built.

### VBlank: after the callback list, not in it

A packet takes about 3,800 M-cycles in SameBoy (it ends around LY 24 when it
starts in VBlank), more than all of VBlank (~1,140). The callback list does
time-critical work there: `VBlankCallback`'s OAM DMA and `VBlankCb_Bg8000`
(`VBlankPadLatch`), which sets LCDC bit 4 for the top of the screen and
samples the pad. Anything in the list after a packet would land in the
visible frame.

> **Correction (2026-10-12).** The sketch registered `SgbVBlankCb` with
> `RegisterVBlankCallback`. `InstallCallbackSlot` appends, and
> `EnterGfxMode1` registers `VBlankCb_Bg8000` again on every drawn screen
> (`EnterGfxMode2` removes it), so a callback registered at boot ends up
> ahead of it, and the LCDC write would come ~25 lines late on every packet
> frame.

So the vector runs the list as a subroutine and then the tail:

```asm
; 00:0040
    call SgbVblList         ; push hl / ld hl, wVBlankCallbacks / jp RunCallbackList
    jp SgbVblTail           ; RunCallbackList's reti comes back here, IME on

SgbVblTail::                ; 00:02c3
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

`wIntNest` is shared by `DiNest`/`EiNest` and `RunCallbackList`, so no
callback re-enables interrupts and the VBlank list always ends in `reti`.
Main code only writes `$2000` between `DiNest` and `EiNest` (the far-call
trampoline and its return stub), so whenever VBlank is taken, `wRomBank` is
the mapped bank.

Main-code VRAM writes don't care that the interrupt now runs long: since the
[vram-write-race](vram-write-race.md) fixes every one is a STAT check and the
write under `di`. `FillRect`'s VBlank batch just waits a frame.

`SgbFrame` counts the freeze down, decrements `hSgbWait`, and at zero calls
`SgbStep`, which sends packet `(step - 1) mod 6`, sets `hSgbBusy = 4`, and
sets the next wait: 4 frames inside a set, 4 + 64 after set 2, 4 + 48 after
set 3. Step 19 waits out the last packet's freeze and goes to 0.

The packets are built from the live header and streamed, without the 16-byte
WRAM buffer the old `SgbSendHeader` used at `$c000`, which belongs to the
kernel after boot.

## Joypad

The second bullet of that plan says when not to read the pad. nitro2k01 also
flagged a bug to avoid:

> - A bug to watch out for is that the "pressed" button mask should be cleared on the 3 frames where input is not read. Otherwise a button press on that exact frame may trigger 3 additional button presses.

Every pad read goes through `ReadJoypadRaw` (`00:3a16`), whose first two
instructions are now `jp SgbPadGate`:

```asm
SgbPadGate::                ; 00:05f2
    ldh a, [hSgbBusy]
    and a
    jr nz, .frozen
    push bc
    ld a, $20
    jp ReadJoypadRaw + 3    ; ldh [rP1], a and the rest
.frozen
    ldh a, [$fc]            ; last state the latch saw
    ret
```

The frozen value is what `$fffc` already holds, so `VBlankPadLatch` sees no
new presses and the latch at `$fffd` doesn't change: a held button doesn't
repeat, and nothing is counted twice. The pad is read live in the frame a
packet goes out (the list runs before the tail), so inside a set it is read
once every 4 frames. A tap shorter than 4 frames (67 ms) can fall between
two reads and be lost. That can only happen during the three ~0.4 s bursts
of sets 2-4, in the first ~7 s after boot.

## Launching a game

A game never sends the header again, so if a game starts on an SGB before all
the packets are out, the rest must be sent before the handoff. nitro2k01:

> Because sending the packets is a "no-op" on non SGB hardware, the kernel could start sending them preemptively and unschedule the remaining SGB packets, if any packets remain to be sent. But in principle, this should not be needed. Alternatively, the setting could guarantee that all packets are sent, even if a ROM is loaded before all packets are sent. This should never happen through user interaction on SGB because button input can't happen until the header packets are successfully sent. Where this distinction might matter is for auto load, which might trigger before the packets are fully sent, and without user input.

Every launch (browser, START overlay, fast launch) ends in the single far
call to `RomLoad_CopyCmdWindowPoll_B4` at `00:1623`, which maps the command
window, builds the ROM and boots it. Its first instructions (`ld a, $01 /
push af`) are now `jp SgbLaunchHook`, which calls `SgbFinish` and then does
those two instructions and jumps back:

```asm
SgbFinish::
    call DiNest             ; nothing else drives P1 from here on
.loop
    ldh a, [hSgbStep]
    and a
    jr z, .done
    ldh a, [hSgbWait]
    ld d, a
    call SgbWaitFrames      ; cycle-counted, works with the LCD off
    call SgbStep
    jr .loop
.done
    ldh [hSgbBusy], a
    jp EiNest
```

It waits out the same gaps the background would have, so a fast launch with
the box on reaches the game at about the same time as before (7.4 s from
power-on in SameBoy). A launch after sets 2-4 are done costs nothing.

## Costs

| Console | Boot, box on | Input | Fast launch, box on |
|---|---|---|---|
| SGB | 0.42 s, menu usable once the SNES comes up | taps under 67 ms can be lost during sets 2-4 | waits for what's left, up to ~6.3 s |
| DMG / GBC / GBA | 0.42 s | same | same |

With the box off nothing changes from mod 6.9: no packets, no freeze, no
wait.

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

## Status

Checked in SameBoy, all three kernels, with the SGB core's header log
(`SAMEBOY_SGB_LOG=1`, which now also prints the emulated time and LY):

- Box on, `--model sgb`: 24 packets, all checksums good. Set 1 at
  0.47-0.82 s (the boot ROM's packets end at 0.40 s), set 2 at 4.29 s
  (192 frames of LCD-on time after set 1, so a little more than 192 real
  frames), set 3 68 frames after set 2, set 4 52 frames after set 3,
  4 frames between packets. Background packets end at LY 24-25.
- Box off: only the boot ROM's packets.
- Fast launch (`FLAUNCH=/Tetris.gb`), box on: all 18 background packets go
  out blocking (LCD off) with the same gaps before `$7FE0 = $80`.
- `--model dmg`, 47-entry root, 20 DOWN taps across sets 3-4: 100 ms taps
  land on the same row with the box on and off (both runs, 0731 and 1.04e);
  50 ms taps lose 1-3 with the box on, as expected from the freeze.

Not yet tried on a real Super Game Boy.

The gaps are still the Enabler's. Now that set 2 overlaps kernel start-up
instead of delaying it, they could probably be shorter; that needs testing
on an SGB.
