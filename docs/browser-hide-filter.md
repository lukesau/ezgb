# Hiding non-launchable files in the file browser (1.05e)

The stock Jr browser lists nearly everything on the card. Two kinds of
clutter get hidden by this patch:

- macOS junk: `._<name>` AppleDouble sidecars (**one per file**, so the list
  roughly doubles), `.DS_Store`, `.Spotlight-V100/`, `.fseventsd/`,
  `.Trashes/`, `.TemporaryItems/`
- files the Jr can't or shouldn't launch: `*.gba` (GBA ROMs on a card shared
  with an Omega), the fast-launch machinery (`FLAUNCH.CFG` and `*.fastlaunch`
  markers — [fast-launch-notes.md](fast-launch-notes.md)), plus the stock
  kernel's own `ezgb.dat` memcmp

This supersedes the original LFN-only dotfile stub (`DirListSkipDotLongName`,
8 bytes at `00:03cc`, added 2026-08-19); those bytes are `$ff` again.

## Why the stock filter misses the junk

`DirList` (`00:0a43`) has a dotfile test at `DirList_skipDot` (`00:0a8b`),
but it tests the first byte of `FILINFO.fname` at `$c9e4` — the **8.3 short
name**, which can never begin with `.`. macOS's `._Foo.gbc` becomes
`_FOO~1.GBC` and the test never fires. The long name is only resolved
*afterwards*, through the `lfname` pointer at `$c9f1` (FILINFO / LFN layout
is [fast-launch-notes.md](fast-launch-notes.md)).

There is also no extension filter anywhere in `DirList`: the only two file
tests are `fattrib & AM_ARC` and a memcmp against `ezgb.dat`.

## Why the filter must see both name paths

The old stub hooked only the long-name branch. That was fine for dotfiles
(macOS always writes an LFN for them) but useless for the new names:
`FLAUNCH.CFG` and upper-case `*.GBA` are valid 8.3 names, so those entries
have **no long name at all** and take the short-name branch. The filter
therefore hooks the point where the two branches converge, with `BC` holding
whichever name pointer (LFN buffer or `$c9e4`) the entry will actually use.

## The patch

Three pieces, byte-identical in the 0731 and 0918 featured builds:

| Site | What |
|---|---|
| `00:0a9d` | was `c2 a3 0a` (`jp nz, DirList_bankSlot`; the old stub had made it `c2 cc 03`) — now `c3 ae 04`: unconditional `jp DirListHideNameStub`, flags still carrying the `or a` on `lfname[0]` |
| `00:04ae` | `DirListHideNameStub`, 25 bytes (bank-0 cave) |
| `08:7a9c` | `BrowserHideName` ([decomp/src/browser_hide.c](../decomp/src/browser_hide.c), 241 bytes, bank-8 cave after `BrowserSortAll`) |

```asm
DirListHideNameStub::      ; 00:04ae — NZ means BC already = long-name ptr
    jr nz, .have
    ld bc, $c9e4           ; no LFN: use the 8.3 short name
.have:
    push bc                ; save the name ptr for DirList_bankSlot
    push bc                ; arg for BrowserHideName
    call FarCallTrampoline
    db $9c, $7a, $08, $00  ; -> 08:7a9c BrowserHideName
    add sp, $02
    pop bc
    ld a, e                ; 1 = hide
    or a
    jp nz, DirList_readdir ; hidden: drop the entry entirely
    jp DirList_bankSlot    ; kept: continue unchanged, BC = name ptr
```

`BrowserHideName` returns 1 (hide) for: leading `.`, `*.gba`, `*.fastlaunch`,
`FLAUNCH.CFG` — extension and name tests case-insensitive, since 8.3 short
names come back uppercase while long names keep the host's casing.

**Far-call gotcha:** `FarCallTrampoline` pushes three words (restore thunk
`$07ae`, saved-bank AF, real return) between the caller's pushed args and the
jump, so a far-called function finds its first arg at `sp+6`, not `sp+2` —
the kernel's own far targets are all compiled that way (e.g. `Opendir_B5`
reads its first arg at frame+6). SDCC compiles a normal function to read
`sp+2`, so `browser_hide_name` declares two dummy leading params to soak up
the trampoline words. Any future injected C that receives stack args via
`FarCallTrampoline` needs the same trick (near calls, like bank-0
`browser_page_end`, don't).

The check sits before the directory/file split, so it hides junk
*directories* (`.fseventsd`, and yes, a folder named `Foo.gba`) as well as
files. Reproduce with:

```bash
cd decomp
python3 tools/inject.py src/browser_hide.c 1.05e-0731 8 7a9c BrowserHideName --apply
python3 tools/inject_bytes.py 1.05e-0731 0 04ae DirListHideNameStub \
    200301e4c9c5c5cd8d079c7a0800e802c17bb7c2560ac3a30a --apply
python3 tools/patch_call.py 1.05e-0731 0 0a9d 3 00:04ae --jp --apply --regen
```

(and the same three commands with `1.05e-0918`; the old stub's 8 bytes at
`00:03cc` were reverted to `$ff` by hand.)

### Why not filter on the hidden attribute instead

macOS does set `AM_HID` on its junk (`$22` on `._*` files, `$12` on
`.fseventsd`), so `fattrib & $02` would also catch that half. The name test
was preferred because it does not depend on which host wrote the card — and
the `.gba`/fast-launch names aren't hidden-flagged anywhere.

## Testing

SameBoy, `scripts/debug/browser-sort.sbd` + `dump-sort-records.sbd`: break at
`$1032` (the `BrowserSortAll` return site) and read the entry count at
`$c2a2` plus the sorted records at `$a000 + 255*k`. With `sd/root/`
containing `TEST.GBA`, `Advance Game.gba` (forces an LFN), an empty
`FLAUNCH.CFG`, and `Pokemon Red.fastlaunch`, the count is 46 with all four
absent from the records; before the patch it was 50 with all four listed.
Verified on both featured builds 2026-08-30. Those four files stay in
`sd/root/` as regression fixtures (the empty `FLAUNCH.CFG` is a no-op for
fast launch — `scan_config` ignores an empty file).

For the macOS-junk half, build a deliberately dirty card:

```bash
SD_KEEP_MACOS_JUNK=1 ./scripts/make-sd-image.sh
```

macOS then writes an AppleDouble beside every file, the real-world case.

## Host-side alternative

The junk can instead be kept off the card:

```bash
dot_clean -m /Volumes/NO\ NAME
mdutil -i off /Volumes/NO\ NAME
rm -rf /Volumes/NO\ NAME/.Spotlight-V100 /Volumes/NO\ NAME/.fseventsd
touch /Volumes/NO\ NAME/.metadata_never_index
```

That needs no kernel change, but has to be repeated after every mount, and
does nothing about `.gba`/fast-launch files. The patch makes the browser
tolerant of a card that was never cleaned.
