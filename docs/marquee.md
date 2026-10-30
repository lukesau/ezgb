# Marquee: shared scrolling text

Since 2026-10-30 every name line that may not fit its field scrolls through
one routine, `Marquee` (`02:7260`,
[kernel/src/marquee.c](../kernel/src/marquee.c), 580 B), in either UI font.
Before that there were three copies of the same window-and-wrap loop, each
fitted to its screen: the SET tab's fast-launch name in `flcfg.c`, the
SET tab's tag example in `tagexample.c`, and the START overlay's and
BACKUPSAVE prompt's lines in `lastrom_name.c`. Each guessed 12px widths in
its own way (a character count, or `Fit12` with a hand-picked trim).

| User | Instance | Field (8px / 12px) | Colors |
|---|---|---|---|
| SET page 1, fast-launch name ([fastlaunch-set-tab.md](fastlaunch-set-tab.md)) | `MQ_A` | x 0..79 on row 12 (ten cells) / the same span, y 96 | ink 3 on paper 0 |
| SET page 2, tag example ([browser-tags.md](browser-tags.md)) | `MQ_A` | x 32..159 on row 8 / x 28..159, y 64 | ink 3 on paper 0 |
| START overlay name, BACKUPSAVE prompt name ([last-rom.md](last-rom.md)) | `MQ_A` | x 8..151 (18 cells) / x 12..156 | popup paper 3 on ink 0, the band |
| BACKUPSAVE prompt `Played` line ([modal-prompts.md](modal-prompts.md)) | `MQ_B` | as above, on its row | popup ink 3 on paper 0 |

The SET tab and the overlays are never on screen together, so they share
`MQ_A`; whoever takes the screen sets it up again.

## Interface

A caller owns an `Mq` in WRAM ([kernel/src/marquee.h](../kernel/src/marquee.h)):

| Byte | Field | |
|---|---|---|
| 0-1 | `s` | the text, NUL-terminated |
| 2 | `len` | its length (set by `MQ_START`) |
| 3 | `pos` | first character shown |
| 4 | `tick` | frames since the last step |
| 5 | `fr` | `hFrame` at the last `MQ_STEP` |
| 6, 7 | `x0`, `x1` | the field, pixels `x0..x1`, in the current font's layout |
| 8 | `y` | tile row `y / 8` in 8px; the 12px row at `y` (`DrawString12` rounds it down to a multiple of 4) |
| 9 | `attr` | ink, paper `<< 2`; bit 7 `MQ_POPUP` draws with `PopupDrawParams` (popups in a dark theme), else `StoreDrawParams`; bit 6 `MQ_SCROLLS` is the marquee's |

It fills in `s`, the field and `attr` for the current font, then runs it:

- `MQ_START` measures the text, resets the scroll and draws it.
- `MQ_STEP`, once per pass of the caller's input loop, advances it when
  due and redraws when it moved. It stamps `fr` even when the text fits, so
  `flcfg` reads `hFrame - fr` before the step for its D-pad repeat.
- `MQ_DRAW` repaints it where it is.

The call takes no stack arguments: the instance pointer is `MQ_ARG`
(`$DBC2`) and the op `MQ_OPS` (`$DBCE`), set by the `MQ_RUN(fn, m, op)`
macro, like `ezcfg`'s op in `$DBFC`. So the same entry works for a bank-2
`call` and for `FarCallTrampoline`, which shifts stack arguments by 6 or 8,
with no padding parameters. Bank 2 calls `Marquee`; every other bank calls
`FarCallMarquee` (`00:0410`, `cd 8d 07 60 72 02 00 c9`).

Because it runs in bank 2, everything it reads, the `Mq` and the text, must
be in RAM, bank 0 or bank 2. The SET tab's code is in bank 4, so it copies
`(AUTO)` and the tag example to `FL_DISP` (`$DB10`) first; the fast-launch
basename is already in WRAM (`FL_PATH`).

## Drawing

The window is the text from `pos`, then blanks; a scrolling text starts
again after `MQ_GAP` (3) blanks. Pacing is the old marquees': a 60-frame
hold at the start, then one character every 20 frames, timed by `hFrame`
(`$fffa`).

- **8px:** `DrawString` of `(x1 + 1 - x0) / 8` cells from column `x0 / 8`,
  so the window overwrites the whole field every time. The text fits when
  its length is at most that many cells.
- **12px:** `hClip12 = x1 + 1`, then `DrawString12` from pixel `x0`. It
  places only whole glyphs that end by the clip and repaints the row to
  it, so the field is filled as far as glyphs fit and nothing crosses
  `x1`. The text fits when `Fit12`, with the same clip, places all of it.

## Memory

`Marquee` copies the instance into a work copy at `$DBC4`, runs on that
and copies it back: fields at fixed addresses compile to plain loads and
stores, where SDCC spent about 200 more bytes on pointer arithmetic.

| WRAM | |
|---|---|
| `$DBC2-$DBC3` | `MQ_ARG` |
| `$DBC4-$DBCD` | the work copy |
| `$DBCE` | `MQ_OPS` |
| `$DBD0-$DBD9` | `MQ_A` |
| `$DBDA-$DBE3` | `MQ_B` |

These were the tail of `RTCLOG=`'s buffer, which only test builds have
(`EZCFG_RTCLOG`); it now holds 7 entries instead of 10 ([ezgb-cfg.md](ezgb-cfg.md)).
The old marquee bytes `$DB38`, `$DB39`, `$DB3B`-`$DB3E` and `$DB58-$DB5F`
are free again (`bkprompt.c` still borrows `$DB3E` as its dump counter).

## Placement

The 12px renderer (`Fit12`, `DrawString12`) is in bank 2, so `Marquee` is
too: a bank-4 marquee would make two far calls back to bank 2 for every
redraw. It took `LastRomName`'s slot at `02:7260`, and `LastRomName`, now a
167-byte set-up and tick, moved to `02:5d58`, after `EzCfg`; its stub
`LastRomNameStub` (`00:0368`) and `ezcfg`'s near call follow it.

## Checked

SameBoy (DMG model) on 0731, in 8px and 12px:
- the SET tab's fast-launch name and tag example, ticked and unticked;
- the START overlay with a 48-character last ROM, and `(none)`;
- the BACKUPSAVE prompt, with both lines scrolling at once.

1.04e: the overlay and both SET marquees. 0918 is the 0731 port, byte for
byte.
