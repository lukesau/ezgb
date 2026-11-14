# Reading the pad

Stock reads the pad with a plain sample of P1 in each UI loop, and a pass
of the browser loop is 3 to 6 frames, so a short tap can fall between two
samples and is never seen. The mod samples the pad every frame and reports
each press once. Addresses are 1.05e-0731's.

## State

| HRAM | Name | Holds |
|---|---|---|
| `$fffa` | `hFrame` | a count of VBlanks |
| `$fffc` | | the pad as last reported (the "previous" state) |
| `$fffd` | | the latch: buttons that went down since the last read |
| `$fff7` | `hPadHeld` | buttons that are not reported again until let go |

The pad byte is not in `hardware.inc` order, because the stock read ends in
a `swap a`: Right `$01`, Left `$02`, Up `$04`, Down `$08`, A `$10`, B `$20`,
SELECT `$40`, START `$80`.

## Every frame: `VBlankPadLatch`

`VBlankCb_Bg8000` (`00:2a5f`), the VBlank callback every drawn screen
registers, jumps to `VBlankPadLatch` (`00:05cf`). After the callback's
stock work it reads the pad with `ReadJoypadRaw` (`00:3a16`), ORs the
buttons that are newly down since the previous state into the latch, and
counts the frame in `hFrame`.

## Every read: `ReadJoypadLatched`

`ReadJoypad` (`00:3a4a`) jumps to `ReadJoypadLatched` (`00:2746`), which
with interrupts off:

1. reads the pad live and ORs in the latch, then clears the latch
2. stores the result as the previous state, so the next frame's sampler
   does not count a press the loop already saw as a new edge
3. removes the buttons in `hPadHeld` from the result, and sets `hPadHeld`
   to the reported A, B, SELECT and START

So a tap of one frame or more is always delivered on the next read, and A,
B, SELECT and START are reported once per press. The D-pad is not masked,
so holding a direction still repeats. The result is in `A` and `E`, as
stock.

Interrupts must be off across the raw read as well as the latch update.
The VBlank sampler writes P1's select bits, so if it ran between the main
loop's select and its read, a held button would read as released.

## What follows from it

- A press made while the loop is busy (a page repaint, a directory read) is
  delivered when the loop next reads. A tap during `Reading...` acts
  afterwards.
- Anything down at a screen change is masked: the boot's clock check and
  every entry to the browser do `hPadHeld |= ReadJoypad()`. A START held
  from power-on, or the A that confirmed a prompt, needs a new press.
- The fast-launch START check reads `ReadJoypad() | hPadHeld`, so a START
  held since boot still cancels fast launch.
- The ROM menu's hold timer reads the live pad at `$fffc`, which the mask
  does not touch ([rom-menu.md](rom-menu.md)).
- `WaitJoypadMask` reads `ReadJoypadRaw` directly and is unchanged.
- Idle loops wait in `PadWait` (`00:0502`), which halts until the next
  frame before it reads ([browser.md](browser.md#idle-waits)).

## Repeat on the SET tab

The SET loop acts on a direction on every pass, and a pass is a fraction of
a frame, so stock moves the cursor two or three steps on one tap. The
loop's read goes through `SetLoopTickHook` (`04:5f20`) to `FlCfg`'s tick
op, which does the read and returns the pad.

A direction acts once, then after 24 frames held, then every 6, counted on
`hFrame`. WRAM `$DBEC` holds the direction and `$DBED` the frames left
until it repeats. A new edge in the latch is a new press even when the same
direction is still down, so a quick second tap during a redraw is not taken
for a hold. The browser has its own repeat
([browser.md](browser.md#moving-around)).
