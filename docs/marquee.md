# Marquee: shared scrolling text

Every name line that may not fit its field scrolls through one routine,
`Marquee` (`02:7260`, [marquee.c](../kernel/mod/src/marquee.c)), in either
font. The browser's list is the exception: it keeps the stock marquee
([font12.md](font12.md#whether-a-name-fits)). Addresses are 1.05e-0731's.

| User | Instance | Field (8px / 12px) | Colors |
|---|---|---|---|
| SET page 1, the fast-launch name ([fastlaunch-set-tab.md](fastlaunch-set-tab.md)) | `MQ_A` | x 0..79 on row 12 / the same span, y 96 | ink 3 on paper 0 |
| SET page 2, the name example ([browser.md](browser.md#clean-names)) | `MQ_A` | x 0..159 on row 4 / the same span, y 32 | ink 3 on paper 0 |
| the START overlay's name and the BACKUPSAVE prompt's name ([last-rom.md](last-rom.md)) | `MQ_A` | x 8..151 / x 12..156 | popup paper 3 on ink 0, the band |
| the BACKUPSAVE prompt's `Played` line ([prompts.md](prompts.md)) | `MQ_B` | as above, on its row | popup ink 3 on paper 0 |

The SET tab and the overlays are never on screen together, so they share
`MQ_A`. Whoever takes the screen sets it up again.

## Interface

A caller owns an `Mq` in WRAM ([marquee.h](../kernel/mod/src/marquee.h)):

| Byte | Field | |
|---|---|---|
| 0-1 | `s` | the text, NUL-terminated |
| 2 | `len` | its length, set by `MQ_START` |
| 3 | `pos` | first character shown |
| 4 | `tick` | frames since the last step |
| 5 | `fr` | `hFrame` at the last `MQ_STEP` |
| 6, 7 | `x0`, `x1` | the field, pixels `x0..x1`, in the current font's layout |
| 8 | `y` | tile row `y / 8` in 8px; the 12px row at `y` |
| 9 | `attr` | ink, paper `<< 2`. Bit 7, `MQ_POPUP`, draws with `PopupDrawParams`, else `StoreDrawParams`. Bit 6, `MQ_SCROLLS`, is set by `MQ_START` when the text does not fit |

It fills in `s`, the field and `attr` for the current font, then runs one
of three ops:

- `MQ_START` measures the text, resets the scroll and draws it.
- `MQ_STEP`, once per pass of the caller's input loop, advances it when
  due and redraws when it moved. It stamps `fr` even when the text fits,
  which the SET tab uses to time its D-pad repeat.
- `MQ_DRAW` repaints it where it is.

### No stack arguments

The instance pointer goes in `MQ_ARG` (`$DBC2`) and the op in `MQ_OPS`
(`$DBCE`), set by the `MQ_RUN(fn, m, op)` macro. So one entry serves a
plain `call` from bank 2 and a far call from any other bank, with no pad
parameters ([shims.md](../kernel/mod/src/shims.md)). Bank 2 calls `Marquee`;
every other bank calls `FarCallMarquee` (`00:0410`).

### The text must be in RAM

`Marquee` runs in bank 2, so everything it reads, the `Mq` and the text,
must be in RAM, bank 0 or bank 2. A caller in another bank copies ROM text
to WRAM first: the SET tab's code is in bank 4, so it copies `(AUTO)` and
the name example to `FL_DISP` (`$DB10`).

## Drawing

The window is the text from `pos`, then blanks. A scrolling text starts
again after `MQ_GAP` (3) blanks. It holds for `MQ_HOLD` (60) frames at the
start, then steps one character every `MQ_RATE` (20) frames, timed by
`hFrame` (`$fffa`).

- **8px:** `DrawString` of `(x1 + 1 - x0) / 8` cells from column `x0 / 8`,
  so the window overwrites the whole field every time. The text fits when
  its length is at most that many cells.
- **12px:** `hClip12 = x1 + 1`, then `DrawString12` from pixel `x0`. It
  places only whole glyphs that end by the clip and repaints the row up to
  it, so nothing crosses `x1`. The text fits when `Fit12`, with the same
  clip, places all of it. The 12px engine is in bank 10, reached through
  the stubs in bank 2 ([font12.md](font12.md#pieces)).

## Memory

`Marquee` copies the instance into a work copy, runs on that and copies it
back. Fields at fixed addresses compile to plain loads and stores, which
is much smaller than what SDCC makes of pointer arithmetic.

| WRAM | |
|---|---|
| `$DBC2-$DBC3` | `MQ_ARG` |
| `$DBC4-$DBCD` | the work copy |
| `$DBCE` | `MQ_OPS` |
| `$DBD0-$DBD9` | `MQ_A` |
| `$DBDA-$DBE3` | `MQ_B` |
