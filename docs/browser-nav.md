# Moving around the file browser

DOWN and UP in the browser, after
[davidesqalv's ezgb-dv fork](https://github.com/davidesqalv/ezgb-dv): the code
in [browser_nav.c](../kernel/src/browser_nav.c) is his, fitted to this kernel.
His is 12px and one palette; this takes both fonts and every theme, and goes
through 0731 and `port-mod.py` to all three kernels.

- **The list wraps** at both ends.
- **A move inside the page draws no text.** The old row goes back to plain and
  the new one to the bar by recoloring them in VRAM, about 2 frames instead of
  about 13.
- **A scroll moves the rows that stay** in VRAM and draws the ones it uncovers,
  the bar's row first, so the cursor is at its new place from the start.
- **A held key** repeats after 18 frames, then every 6 6 5 5 4 4 3 frames, and
  while the list scrolls it moves by 1 1 2 2 3 3 4 rows a step.
- **In 12px the entry number reads `n/total`**, from an x that holds for the
  whole folder. The field is right of HELP (x 105 on), and in the proportional
  font two 3-digit numbers don't fit it, so there it reads `n` alone. 8px has
  four cells, as stock, so it stays `n`.

## Pieces

Bank 12, `0C:4000`, a three-jump table first so the far stubs keep their
targets:

| Address | What | Reached from |
|---|---|---|
| `0C:4000` | `NavDown` | `BrowserScrollDownHook` (`00:02e0`) through the stub at `00:3d8c` |
| `0C:4003` | `NavUp` | `BrowserScrollUpHook` (`00:02f0`) through the stub at `00:3fa0` |
| `0C:4006` | `TabNumFar` | `TabNum12` (`00:0380`) in 12px; 8px goes on to `DrawString` |
| `00:03dc` | `BrowserDelay` | `00:110f`, the browser loop's `Delay(45)`: skipped while UP or DOWN is held, since the pace is now in frames. A skipped pass takes its marquee tick back, so a long name starts scrolling when it did |

This replaced `browser_scroll.c` (`00:3ed0`) and `browser_scroll_repaint.c`
(`00:3d8c`), which left most of those two caves free.

## Recoloring

A plain row and the bar differ only in color, so with `g` the row's glyph bits:

| Row | Plane 0 | Plane 1 |
|---|---|---|
| plain | `g` | `g` |
| bar | `~g` | `~g` |
| DV plain | `g`, clear in tile column 0 and bit 7 of column 1 (the blue icon) | `g` |
| DV bar | `~g` | `0` |

Every theme draws the same indices and differs in the palette, so outside DV
both directions are one routine, `InvertRow`, for 3 groups of 4 pixel rows
(12px) or 2 (8px). DV has `HighlightRow` and `UnhighlightRow`; it is always 12px.

The recolor is only right while the old row shows its name from the start. The
marquee keeps the index it last drew at `$cc31`; every move puts the boot value
`$EEEE` back, so any other value means the bar's long name has scrolled and the
move takes the stock repaint. So does a move inside a DiNest section, where the
sync's `di` / `ei` would end the section early.

## Tests

SameBoy, same list positions on this kernel and on the one before it (the stock
repaint), list area compared pixel for pixel: in-page moves, scrolls and wraps,
in light 12px, light 8px, dark, purple, DV and DMG. Only a selected long name
differs, because the slower kernel's marquee had already started.
The DV runs also showed the older kernel moving two rows on some taps, which this
one doesn't. Wrap-around and the counter were also run on 0918 and 1.04e. None of
this has been on hardware yet.
