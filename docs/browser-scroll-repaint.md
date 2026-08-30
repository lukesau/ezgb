# Bottom-up repaint on down-scroll (1.05e)

Companion to the continuous-scroll patch (`decomp/src/browser_scroll.c`) and
the sorted browser ([browser-sort.md](browser-sort.md)).

## The problem

When DOWN shifts the window, the stock dirty=1 repaint
(`DrawBrowserEntries`, `01:40e3`) sweeps rows top to bottom, so the newly
revealed entry — the reason the user pressed DOWN — paints last, a visible
beat after the press.

## The fix

`browser_scroll_down_repaint` (`decomp/src/browser_scroll_repaint.c`, cave
`00:3d8c`) wraps `browser_scroll_down`. On a window shift it clears `dirty`
(taking the repaint away from `FileBrowserEntry`), replicates the one side
effect of the stock dirty path (zeroing the marquee tick at frame
`sp+$0a..$0d`), and repaints in reverse:

1. Rows 14/15 + highlight handoff + the selection-number field, via
   `DrawBrowserDetail(base, 15, mode 2)` (`01:42ba`) through the
   `FarCallDrawDetailBottom` shim (`00:03dc`) — the same two-row primitive
   the in-screen cursor moves already use.
2. Rows 13 → 0, one at a time, replicating `DrawBrowserEntries`' per-row
   body with the stock primitives (`DrawString` `00:08b7`,
   `StoreDrawParams` `00:2791`) — **including the per-row ink reset after a
   DIR tag**. `StoreDrawParams` is not an (index, value) setter: it stores
   all three draw-state bytes (`$d734/$d735/$d723`,
   `decomp/src/store_d734_d735_d723.c`) every call, so the DIR tag's
   `(0, $0003)` switches everything drawn after it to inverse video until
   the stock `(3, $0000)` reset. Omitting that reset was a real shipped bug
   here: after the first repaint, every row below the topmost directory
   painted white-on-black. No highlight management is needed beyond that:
   the helper's epilogue leaves ink normal and rows 0..13 are never
   selected during a shift (`sel` is pinned at 15).

Why not iterate the two-row helper over all eight pairs: its epilogue prints
the selection-number field as `base+row+1` on **every** call, so the field
would flash wrong values and finish on `base+1`. And its no-hilite mode
(any `mode` other than 2/3) draws `(row, row+1)` with inherited ink — usable,
but the number-field churn kills it; per-row drawing avoids both problems.

Scroll UP is untouched: its new entry appears at the top, which the stock
top-down sweep already paints first. In-screen moves (dirty=2/3) are stock.

## Wiring

| Piece | Where |
|---|---|
| Wrapper | `00:3d8c` `BrowserScrollDownRepaint` (316 bytes; cave is 628) |
| Detail shim | `00:03dc` `FarCallDrawDetailBottom` (24 bytes, hand-assembled — bytes in `browser_scroll_shims.md`) |
| Hook | `00:02e0` down stub: call target repointed `$01e3` → `$3d8c` (bytes 4-5) |

```bash
cd decomp
python3 tools/inject_bytes.py 1.05e 0 03dc FarCallDrawDetailBottom \
    3e02f533010f00c5f8052a666fe5cd8d07ba420100e805c9 --apply
python3 tools/inject.py src/browser_scroll_repaint.c 1.05e 0 3d8c \
    BrowserScrollDownRepaint --pin browser_scroll_down=01e3 \
    --pin FarCallDrawDetailBottom=03dc --pin DrawString=08b7 \
    --pin StoreDrawParams=2791 --apply
# then set stub bytes $02e4-$02e5 to 8c 3d and regen
```

## Verified

- Under SameBoy with CGEvent-driven key presses: repeated window-shift
  presses each hit the `$03dc` shim breakpoint and returned to the input
  loop with the entry count intact — wrapper wired, helper called, browser
  loop healthy across repaints.
- Visually (manual): the new bottom entry paints first and the sweep runs
  upward, with highlight, DIR tags, and the selection number correct.
- Ink-reset regression: with a breakpoint after the wrapper returns,
  `$d734/$d735/$d723` read `03 00 00` (the reset state) after every
  window-shift repaint of the directory-heavy test root; the missing-reset
  bug left `00 03 00` and black rows below the first directory.
