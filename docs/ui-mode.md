# UI mode: 8px or 12px browser, chosen on the SET tab

The 12x12 browser of [font12.md](font12.md) is opt-in. A new `UI:` row on
the SET tab (row 16, under the ROM line) carries a button that reads `8px`
or `12px`; A toggles it, the choice is written to `EZGB.CFG` as `UI=8` or
`UI=12` ([ezgb-cfg.md](ezgb-cfg.md)) and read back at boot. With no key, or
no card, the browser is the 8px one, so shipping this changes nothing
visible until the user opts in. The VRAM-race fix
([vram-write-race.md](vram-write-race.md)) and the joypad latch
([joypad-latch.md](joypad-latch.md)) apply in both modes.

The flag is one HRAM byte, `$fffb` (`hUiMode`): 0 = 8px, 1 = 12px. HRAM is
cleared at boot, which is what makes 8px the default before the config is
read. Everything that differs between the modes derives from it at run time;
the value is meant to grow into a third one for an icon-grid UI, and the
row-count helpers below are the places that would get a third case.

| | 8px | 12px |
|---|---|---|
| list rows on screen | 16 | 10 |
| name field | icon + 19 | icon + 12 |
| marquee width / step | 19 / every 2 ticks | 12 / every 4 ticks |
| page step (LEFT/RIGHT) | 16 | 10 |

## Where the mode is consulted

`ezcfg.c` parses `UI=` into `$fffb` on every load (boot restore included)
and writes it back on every save. `flcfg.c` draws the row and toggles it.

The browser sites, all in bank 0 unless noted. The stock immediates could
not hold a memory load in place, so each became a `call` into a small cave
in the space freed by moving `BrowserScroll`:

| Cave | Address | Does |
|---|---|---|
| `UiRows` | `00:01e3` | A = 16 or 10 from `$fffb` |
| `UiRowsHL` | `00:01ec` | HL = rows; replaces `ld hl, $0010` at `00:113e`, `00:1185`, `00:11ca` (page step and bound) |
| `UiRowsMinus1BC` | `00:01f3` | BC = rows - 1; replaces `ld bc, $000f` inside `FarCallDrawDetailBottom` (`00:03e0`) |
| `ClampBrowserRows` | `00:01fb` | the 17-byte row clamp of `DrawBrowserEntries` (`01:411b`), with the variable |
| `MarqueeWidth` | `00:020c` | stores 19 or 12 into the marquee's width slot; replaces `ld hl, sp+$0f; ld [hl], n` at `00:0c84` and `00:0c8b` |
| `MarqueeDraw` | `00:0219` | `jp DrawString` or `jp FarCallDrawString12`; the marquee's draw call at `00:0dd8` calls it |
| `MarqueeShift` | `00:0222` | pushes the tick shift (1 or 2) in place of `ld a, n; push af` at `00:0cb9` |

The C shims read the flag directly (`--pin hUiMode=fffb`):
`browser_scroll.c` (rows, now at `00:3ed0`; its second entry
`browser_scroll_up` moved to `00:3fbb` and the up hook at `00:02f0` was
re-pointed), `browser_page_end.c`, `browser_scroll_repaint.c` (rows - 2
in the bottom-up loop) and `browser_icons.c`, whose 8px branch is the
pre-12px drawing: icon at column 0, name from column 1, 19 wide.

SET tab: the cursor clamp at `04:5604` allows row 4, `FlSetADispatch`
already routes any row but 1 to `flcfg` op A, and `draw_rows` paints the
new button like PICK (box at `(115,125)-(155,137)`, text at column 15).

Switching mode and returning to the browser redraws the page from scratch,
so no stale rows remain from the other layout (the tab switch clears the
canvas). The cursor state is re-created on entry.

## Caveat: fast taps on the SET tab

The SET loop moves the cursor once per press and waits for a release before
the next; the joypad latch keeps presses but cannot keep a release it never
sampled, so two taps closer together than one loop iteration merge into one
move. Human taps are well apart; the automated 60 ms burst was not.

## Reproduce

Everything is in the registry of `scripts/port-mod.py` (C blocks with pins)
or listed above (caves via `inject_bytes.py`, sites via `patch_bytes.py` /
`patch_call.py`). Blocks moved for space: `BrowserScroll` `00:01e3` ->
`00:3ed0`, `DrawString12` `02:5800` -> `02:7500` (the far stub at `00:05c0`
follows), `EzCfg` grew to `02:4a00..5858`.
