# Hiding non-launchable files in the file browser (1.05e)

The stock Jr browser lists nearly everything on the card. Three kinds of
clutter get hidden by this patch:

- macOS junk: `._<name>` AppleDouble sidecars (**one per file**, so the list
  roughly doubles), `.DS_Store`, `.Spotlight-V100/`, `.fseventsd/`,
  `.Trashes/`, `.TemporaryItems/`
- names starting with `_`, for files and folders the user wants kept on the
  card but out of the list (2026-11-12)
- `*.nds`, `*.sav` and `*.esv` (2026-11-12). Save management reads `SAVER/` with `f_readdir` directly
  ([save_ops.c](../kernel/mod/src/save_ops.c)), not through `DirList`, so hiding
  `*.sav` in the browser does not touch it
- files the Jr can't or shouldn't launch: `*.gba` (GBA ROMs on a card shared
  with an Omega), the settings file (`EZGB.CFG`, see [ezgb-cfg.md](ezgb-cfg.md))
  and its pre-3.0 predecessor `FLAUNCH.CFG`, the kernel's save backup folder
  `SAVER/` (mod 6.5; save management is planned as a per-ROM option instead
  of browsing the folder), plus the stock
  kernel's `ezgb.dat` memcmp

This supersedes the original LFN-only dotfile stub (`DirListSkipDotLongName`,
8 bytes at `00:03cc`, added 2026-08-19); those bytes are `$ff` again.

## The card's list: `.ezgbhide`

Names that are a matter of taste or of what else shares the card are not
built in: they go in `/.ezgbhide` in the card's root (2026-11-13), named like
the plays file `/.ezgbplays` ([stars.md](stars.md)). Unlike that one it is
plain text: one name a line, any case, CRLF or LF:

```
# folders other carts use
RTS
IMGS
CHEAT
*.bak
```

- a plain name hides a file or folder with exactly that name, in any folder
- `*` and an ending hides every name with that ending
- `#` starts a comment line; blank lines and spaces around a name are skipped

The leading dot hides the file itself. Only its first 512 bytes are read. Without the
file nothing extra is hidden. `RTS`, `IMGS` and `CHEAT` were built in for a
day (2026-11-12) and are the first names moved out to the file.

[kernel/mod/src/hide_list.c](../kernel/mod/src/hide_list.c) (`HideLoad`, `0E:5000`)
is far-called by `BrowserSortAll` through `HideLoadFar` (`08:7b80`) before
every listing. It reads the file into ezcfg's sector scratch (`$D800`) and
packs it into the loader's 512-byte scratch at `$C0A0` in the shape of the
built-in table, behind the mark `'H'`, `'L'`. `BrowserHideName` walks the
built-in table and then, if the mark is there, that one. The scratch belongs
to whatever ran last (the loader, the save manager, the text viewer), which
is why the list is packed again for each listing and never kept; a write
watchpoint on `$C0A0`-`$C2A0` across a listing in SameBoy saw no writes. The
cost is one `f_open`, `f_read` and `f_close` each time a folder is opened.

## Why the stock filter misses the junk

`DirList` (`00:0a43`) has a dotfile test at `DirList_skipDot` (`00:0a8b`),
but it tests the first byte of `FILINFO.fname` at `$c9e4`, the **8.3 short
name**, which can never begin with `.`. macOS's `._Foo.gbc` becomes
`_FOO~1.GBC` and the test never fires. The long name is only resolved
*afterwards*, through the `lfname` pointer at `$c9f1` (FILINFO / LFN layout
is [fast-launch-notes.md](fast-launch-notes.md)).

There is also no extension filter anywhere in `DirList`: the only two file
tests are `fattrib & AM_ARC` and a memcmp against `ezgb.dat`.

## Why the filter must see both name paths

The old stub hooked only the long-name branch. That was fine for dotfiles
(macOS always writes an LFN for them) but useless for the new names:
`EZGB.CFG` and upper-case `*.GBA` are valid 8.3 names, so those entries
have **no long name at all** and take the short-name branch. The filter
therefore hooks the point where the two branches converge, with `BC` holding
whichever name pointer (LFN buffer or `$c9e4`) the entry will actually use.

Because `EZGB.CFG` is hidden, the SET-tab ROM picker
([`fastlaunch-set-tab.md`](fastlaunch-set-tab.md)) runs over the already-filtered
list, so the config file itself can never be picked as a fast-launch target.

## The patch

Three pieces, byte-identical in the 0731 and 0918 featured builds (1.04e is a
port, so its bank-0 call targets differ):

| Site | What |
|---|---|
| `00:0a9d` | was `c2 a3 0a` (`jp nz, DirList_bankSlot`; the old stub had made it `c2 cc 03`); now `c3 ae 04`: unconditional `jp DirListHideNameStub`, flags still carrying the `or a` on `lfname[0]` |
| `00:04ae` | `DirListHideNameStub`, 25 bytes (bank-0 cave) |
| `05:7700` | `BrowserHideName` ([kernel/mod/src/browser_hide.c](../kernel/mod/src/browser_hide.c), 601 bytes, free space after FatFs in bank 5). It was `08:7a9c` until mod 3.0, when the `EZGB.CFG` rule made it outgrow the gap before `FlPickBanner` at `08:7b8d`, then `08:7c00` until mod 5.6, when the record cap ([browser-sort.md](browser-sort.md#record-cap)) made it outgrow that slot too |

```asm
DirListHideNameStub::      ; 00:04ae: NZ means BC already = long-name ptr
    jr nz, .have
    ld bc, $c9e4           ; no LFN: use the 8.3 short name
.have:
    push bc                ; save the name ptr for DirList_bankSlot
    push bc                ; arg for BrowserHideName
    call FarCallTrampoline
    db $00, $77, $05, $00  ; -> 05:7700 BrowserHideName
    add sp, $02
    pop bc
    ld a, e                ; 1 = hide
    or a
    jp nz, DirList_readdir ; hidden: drop the entry entirely
    jp DirList_bankSlot    ; kept: continue unchanged, BC = name ptr
```

`BrowserHideName` returns 1 (hide) for: leading `.` or `_`, `*.gba`, `*.nds`, `*.sav`, `*.esv`, `*.dat` (the kernels: the stock
browser hides `ezgb.dat` by that one name, but a card can carry several for stage1's
kernel picker, [kernel-picker.md](kernel-picker.md); mod 7.0), `EZGB.CFG`, `FLAUNCH.CFG`, `SAVER`, any name in the card's list,
and for any entry past the 416th shown, which also ends the directory
([browser-sort.md](browser-sort.md#record-cap)).
(It also hid `*.fastlaunch` until that fast-launch trigger was removed on
2026-09-07.) Extension and name tests are case-insensitive, since 8.3 short
names come back uppercase while long names keep the host's casing.

**Far-call gotcha:** `FarCallTrampoline` pushes three words (restore thunk
`$07ae`, saved-bank AF, real return) between the caller's pushed args and the
jump, so a far-called function finds its first arg at `sp+6`, not `sp+2`.
The kernel's far targets are all compiled that way (e.g. `Opendir_B5`
reads its first arg at frame+6). SDCC compiles a normal function to read
`sp+2`, so `browser_hide_name` declares two dummy leading params to soak up
the trampoline words. Any future injected C that receives stack args via
`FarCallTrampoline` needs the same trick (near calls, like bank-0
`browser_page_end`, don't).

The check sits before the directory/file split, so it hides junk
*directories* (`.fseventsd`, and yes, a folder named `Foo.gba`) as well as
files. Reproduce with:

```bash
cd kernel
# (since mod 3.0 the first two are done by scripts/inject-ezcfg.sh)
python3 tools/inject.py src/browser_hide.c 1.05e-0731 5 7700 BrowserHideName \
    --pin DrawString=08b7 --pin FarCallDrawString12=05c0 --pin DrawRect=27ba \
    --pin StoreDrawParams=2791 --pin Delay=3a93 --apply
python3 tools/inject_bytes.py 1.05e-0731 0 04ae DirListHideNameStub \
    200301e4c9c5c5cd8d0700770500e802c17bb7c2560ac3a30a --apply
python3 tools/patch_call.py 1.05e-0731 0 0a9d 3 00:04ae --jp --apply --regen
```

(the other builds are ports, `scripts/port-mod.py`; the old stub's 8 bytes at
`00:03cc` were reverted to `$ff` by hand.)

### Why not filter on the hidden attribute instead

macOS does set `AM_HID` on its junk (`$22` on `._*` files, `$12` on
`.fseventsd`), so `fattrib & $02` would also catch that half. The name test
was preferred because it does not depend on which host wrote the card, and
because the `.gba`/fast-launch names aren't hidden-flagged anywhere.

## Testing

SameBoy, `scripts/debug/browser-sort.sbd` + `dump-sort-records.sbd`: break at
`$1032` (the `BrowserSortAll` return site) and read the entry count at
`$c2a2` plus the sorted records at `$a000 + 255*k`. With `sd/root/`
containing `TEST.GBA`, `Advance Game.gba` (forces an LFN), an empty
`FLAUNCH.CFG`, and `Pokemon Red.fastlaunch`, the count was 46 with all four
absent from the records; before the patch it was 50 with all four listed.
Verified on both featured builds 2026-08-30. Since the `*.fastlaunch` rule was
dropped (2026-09-07) that same card lists 47 entries, `Pokemon Red.fastlaunch`
included. Those files stay in `sd/root/` as regression fixtures (the empty
`FLAUNCH.CFG` is a no-op for fast launch, since `scan_config` ignores an empty
file).

For the macOS-junk half, keep some junk files in `sd/root/` — the showcase card
does exactly this (a `.DS_Store`, a `._Kirby.gbc` AppleDouble sidecar, an
`EZGB.CFG`, and an `Advance Game.gba`), so `./scripts/make-sd-image.sh` copies
them straight onto the card and the stock browser lists them while the mod hides
them. (`make-sd-image.sh` now builds the FAT with mtools, which never injects
macOS junk of its own, so what you put in `sd/root/` is exactly what you test.)

Underscore rule (2026-11-12, 0731 in SameBoy): a copy of the showcase card
with `_Hidden Game.gb` (LFN), `_SHORT.GB` (8.3 only), a folder `_Private`
and `Shown_Mid.gb` added lists 8 entries, the three `_` names absent and
`Shown_Mid.gb` present.

Table rewrite (2026-11-12, 0731 in SameBoy): the names now sit in one table
(`hide_tab`: length byte, bit 7 = whole name, else suffix). The showcase card
plus `Some Game.nds`, `TETRIS.ESV`, `notes.TXT`, `cheats.gb`, `rts.gb` and
folders `RTS`, `imgs`, `Cheat`, `CHEATS`, `IMAGES` lists 11 entries:
`Some Game.nds`, `TETRIS.ESV`, `Pokemon.sav`, `RTS`, `imgs` and `Cheat` are
absent; `CHEATS`, `IMAGES`, `cheats.gb`, `rts.gb` and `notes.TXT` are listed.

Card list (2026-11-13, 0731 in SameBoy): the showcase card plus folders
`RTS`, `imgs`, `Cheat`, `CHEATS` and files `old.BAK`, `rts.gb`. Without
`.ezgbhide` all six are listed (12 entries). With one holding a comment,
`RTS`, `  imgs  `, a blank line, `CHEAT` and `*.bak` (no final newline) the
listing has 8 entries: `RTS`, `imgs`, `Cheat`, `old.BAK` and the list file
are absent, `CHEATS` and `rts.gb` are listed.

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
