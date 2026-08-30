# RIGHT on the last page jumps to the bottom (1.05e)

Stock navigation is asymmetric: LEFT on the first page snaps the cursor to the
top (`FileBrowserEntry_pageDecGate`), but RIGHT when the window already shows the
tail of the list falls out of `FileBrowserEntry_pageInc`'s bounds check to the
wait loop and does nothing. This patch adds the mirror: same trigger, cursor to
the last visible row, same full-page dirty.

| Piece | Where |
|---|---|
| The code | `decomp/src/browser_page_end.c` (`00:02fb`, `BrowserPageEnd`, 65 bytes) |
| Frame stub | `00:03f4` `BrowserPageEndHook`: `f8 12 e5 cd fb 02 e8 02 c3 ab 16` |
| Hook | `00:1195` `jp nc, MenuDispatchAB_waitVBlankLoop` → operand repointed to `$03f4` |

The `nc` branch is taken exactly when `base + 16 >= count`, so the handler
just clamps `sel` to `count - base - 1` (the bottom row) and sets dirty = 1
if it moved. The stub is the same frame-preserving pattern as the scroll
hooks (`browser_scroll_shims.md`): reached by `jp`, passes `&frame.dirty`,
exits through the wait loop.

With `count <= 16` (single page) the hook also fires, so RIGHT jumps to the
bottom of a short list, mirroring what LEFT already does at the top.

Verified under SameBoy with driven key presses: paging RIGHT through the
54-entry test root clamps at base 38, the next press sets `sel = $0f`
(entry 54 highlighted), and further presses are no-ops, with the browser
loop healthy throughout.
