# Joypad latch: no more lost taps

## Problem

Every UI loop in the kernel reads the pad through `ReadJoypad` (`00:3a4a`),
which is a plain sample of P1 (`ReadJoypadRaw`, `00:3a16`): no interrupt, no
latch. The browser loop samples once per iteration, and an iteration is
`Delay($2d)`, the sample, dispatch, then `WaitVBlankFlag`: 3 frames on a row
that does not scroll, 4 to 6.5 on a scrolling one (the marquee redraw). A
press shorter than the current period can fall entirely between two samples
and is simply never seen, and the 12x12 browser ([font12.md](font12.md))
made this easier to hit because more names scroll.

Measured with `scripts/showcase/keys.swift` (60 ms taps, 180 ms apart) in a
15-entry folder: the stock kernel happened to phase well and lost nothing;
the 12px build lost one to three of fifteen. With 25 ms taps both lose
presses.

## Fix

Sample the pad once per frame from the VBlank interrupt and remember which
buttons went down since the loop last looked, so a tap of at least one
frame is always delivered on the next `ReadJoypad`.

Two HRAM bytes (HRAM is cleared at boot and otherwise holds only the OAM DMA
stub at `$ff80`): `$fffc` the previous frame's pad state, `$fffd` the latch.

`VBlankCb_Bg8000` (`00:2a5f`), the VBlank callback `EnterGfxMode1` registers
for every drawn screen, is extended: it becomes `jp VBlankPadLatch`
(`00:05cf`, 35 bytes; the last 5, `ldh a,[$fa]; inc a; ldh [$fa],a`, keep
`hFrame` at `$fffa` counting VBlanks for the SET-tab name marquee), which does its original work (BG tile data back to
`$8000`, `LYC = $48`) and then:

```
    push bc
    call ReadJoypadRaw      ; a = pad, bit set = down
    ld b, a
    ldh a, [$fc]            ; previous
    cpl
    and b                   ; newly down since previous
    ld c, a
    ld a, b
    ldh [$fc], a
    ldh a, [$fd]
    or c
    ldh [$fd], a            ; latch |= new
    pop bc
    ret
```

`ReadJoypad` becomes `jp ReadJoypadLatched` (`00:2746`, 17 bytes, in the
freed old `DrawGlyph` body). Interrupts are off across the raw read too: the
VBlank sampler writes P1's select bits, so if it ran between the main loop's
select and read it left P1 deselected and a held button read as released.
Mod 4.6 had the `di` after the raw read, and that race was reliable wherever
code spun on `ReadJoypad` waiting for a release: PICK ROM returned to the
browser with A still down, which then opened the first folder.

```
    di
    call ReadJoypadRaw
    ld e, a
    ldh a, [$fd]
    or e
    ld e, a                 ; reported = live | latch
    xor a
    ldh [$fd], a            ; latch consumed
    ld a, e
    ldh [$fc], a            ; previous := reported
    ei
    ret
```

Result in A and E as before. Writing the reported state back as "previous"
is what stops a tap from being counted twice: a press the loop saw live is
not seen as a fresh edge by the next frame's sampler. A held button behaves
exactly as before (the live read carries it every iteration), so auto-repeat
is unchanged. The callback runner saves AF/BC/DE/HL around callbacks and
holds `wIntNest`, so nothing in the ISR path needs extra care; the `di`/`ei`
in the read is the same IME-on assumption as the VRAM fixes
([vram-write-race.md](vram-write-race.md)).

Side effects worth knowing:

- A press made while the loop is busy (a page repaint, a directory read,
  the marquee) is delivered when the loop next reads, instead of being lost.
  That also means a tap during "Reading..." acts afterwards.
- The ISR's own `ReadJoypadRaw` can interrupt the loop's in the few cycles
  between selecting a button group and reading it, which makes that one
  live sample read as "nothing"; the latch carries the press, so nothing is
  lost.
- Any screen that uses `ReadJoypad` (SET, HELP, prompts) gets the same
  behaviour; `WaitJoypadMask` reads `ReadJoypadRaw` directly and is
  unchanged.

## Verification

SameBoy `--model dmg`, 15-entry folder, `keys` at 60 ms and a 25 ms variant:
eleven DOWNs land on entry 12, RIGHT jumps to 15, three UPs return to 12,
and a single SELECT opens the SET tab once (no double delivery). Before the
latch the 12px build lost one to three of those presses at 60 ms.

```sh
cd decomp
python3 tools/inject_bytes.py $V 0 05cf VBlankPadLatch \
    f040f610e0403e48e045c5cd163a47f0fc2fa04f78e0fcf0fdb1e0fdc1c9 --apply
python3 tools/inject_bytes.py $V 0 2746 ReadJoypadLatched f3cd163a5ff0fdb35fafe0fd7be0fcfbc9 --apply
python3 tools/patch_call.py $V 0 2a5f 11 00:05cf --jp --apply
python3 tools/patch_call.py $V 0 3a4a 5 00:2746 --jp --apply
```

Applied to `1.05e-0731`; bank 0 is identical in 0918 and the routine uses no
WRAM address that moves in 1.04e, so it ports byte for byte.
