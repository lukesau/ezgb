# Browser scroll hook stubs

Hand-assembled, not SDCC-compiled — same reason as `shims.md`, but a different
constraint: these are not far-call trampolines, they are *frame-preserving*
entry stubs.

`FileBrowserEntry_rowInc` (`00:1200`) and `FileBrowserEntry_rowDec`
(`00:11e7`) are not functions. They are labels inside `FileBrowserEntry`,
reached by `jr nz`, that read and write the enclosing `SdMenuMain` stack frame
at fixed `sp+N` offsets and exit with `jp MenuDispatchAB_waitVBlankLoop`
(`00:16ab`). C cannot address a caller's frame, and any C prologue moves SP.

So each stub is **jumped to**, never called — SP is therefore still exactly the
`FileBrowserEntry` frame pointer on entry — and it computes the frame address
*before* pushing anything:

```asm
    ld hl, sp+$12                      ; f8 12  -> &frame.dirty; MUST precede any push
    push hl                            ; e5     -> struct BrowserScrollState *
    call browser_scroll_{down,up}      ; cd lo hi
    add sp, $02                        ; e8 02  -> drop the pushed arg
    jp MenuDispatchAB_waitVBlankLoop   ; c3 ab 16
```

`ld hl,sp+N` takes a *signed* 8-bit displacement, so `+$12` is in range.
One 2-byte pointer argument in, hence 2 bytes of cleanup.

The frame slots are contiguous, which is what lets a single pointer stand in
for all of them (`browser_scroll.c`, `struct BrowserScrollState`):

| Frame slot | Struct field |
|---|---|
| `sp+$12` | `dirty` |
| `sp+$13..$14` | `base` (u16) |
| `sp+$15` | `sel` |

## BrowserScrollDownHook -> `browser_scroll_down` (`00:01e3`)

```
f8 12 e5 cd e3 01 e8 02 c3 ab 16      (11 bytes)
```

## BrowserScrollUpHook -> `browser_scroll_up` (`00:0297`)

```
f8 12 e5 cd 97 02 e8 02 c3 ab 16      (11 bytes)
```

Both C entry points come from linking `browser_scroll.c` at `_CODE = 0x01e3`
and reading the sdld map, not from counting bytes by hand — the file compiles
to one contiguous 248-byte block, so `browser_scroll_up`'s address is whatever
the linker placed it at and must be re-checked if that file changes:

```sh
sdcc -c -msm83 --sdcccall 0 --no-std-crt0 decomp/src/browser_scroll.c -o bs.rel
# link with -b _CODE = 0x01e3, -g_DirList=0x0a43, then grep the .map
```

## Hooking

Each stub is wired in by overwriting only the first 3 bytes of the stock
handler with a `jp`; the rest of the original handler becomes unreachable dead
code, which is harmless.

| Site | Was | Becomes |
|---|---|---|
| `00:1200` `FileBrowserEntry_rowInc` | `f8 15 4e` | `c3 e0 02` |
| `00:11e7` `FileBrowserEntry_rowDec` | `af f8 15` | `c3 f0 02` |
