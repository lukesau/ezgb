# Hiding macOS cruft in the file browser (1.05e)

An SD card mounted on a Mac picks up junk that the stock Jr browser lists nearly
all of:

- `._<name>` AppleDouble sidecars, **one per file**, so the list roughly doubles
- `.DS_Store`
- `.Spotlight-V100/`, `.fseventsd/`, `.Trashes/`, `.TemporaryItems/`

## Why the existing filter misses them

`DirList` (`00:0a43`) already has a dotfile test at `DirList_skipDot`
(`00:0a8b`):

```asm
DirList_skipDot::
    ld a, c
    sub $2e          ; '.'
    jp z, DirList_readdir
```

but `c` holds the first byte of `FILINFO.fname` at `$c9e4`, the **8.3 short
name**. A FAT short name can never begin with `.`, so macOS's `._Foo.gbc`
becomes something like `_FOO~1.GBC` and the test never fires. The long name is
only resolved *afterwards*, through the `lfname` pointer at `$c9f1` (FILINFO /
LFN layout is [fast-launch-notes.md](fast-launch-notes.md)).

There is also **no extension filter** anywhere in `DirList`: the only two file
tests are `fattrib & AM_ARC` and a memcmp against `ezgb.dat`, so every file on
the card is a browser entry.

## The patch

Re-test the first character *after* the long name has been resolved. At that
point `A` already holds it (loaded by `ld a, [bc]` / `or a`), so the whole fix
is a retarget plus an 8-byte stub.

| Site | Was | Now |
|---|---|---|
| `00:0a9d` | `c2 a3 0a` (`jp nz, DirList_bankSlot`) | `c2 cc 03` |
| `00:03cc` | `ff ff …` (490-byte cave) | `fe 2e ca 56 0a c3 a3 0a` |

```asm
DirListSkipDotLongName::   ; 00:03cc
    cp $2e                 ; long name starts with '.'?
    jp z, DirList_readdir  ;   yes: skip this entry entirely
    jp DirList_bankSlot    ;   no:  carry on unchanged
```

The check sits before the directory/file split, so it hides junk *directories*
(`.fseventsd`, `.Spotlight-V100`) as well as files, and it costs one `cp` and
one `jp` on the common path. Reproduce with:

```bash
python3 decomp/tools/inject_bytes.py 1.05e 0 03cc DirListSkipDotLongName \
    fe2eca560ac3a30a --apply --regen
```

then set the two operand bytes at `$0a9e`/`$0a9f` to `cc 03`.

### Why not filter on the hidden attribute instead

macOS does set `AM_HID` on this junk (`$22` on `._*` files, `$12` on
`.fseventsd`), so `fattrib & $02` would also work. The name test was preferred
because it does not depend on which host wrote the card: a card populated on
Linux or Windows gets the dot but not necessarily the attribute.

## Testing

`scripts/make-sd-image.sh` normally scrubs this junk. Build a deliberately dirty
card instead:

```bash
SD_KEEP_MACOS_JUNK=1 ./scripts/make-sd-image.sh
```

macOS then writes an AppleDouble beside every file, the real-world case. Before
the patch the browser shows ~90 entries for ~45 ROMs; after it, only the ROMs.

## Host-side alternative

The junk can instead be kept off the card:

```bash
dot_clean -m /Volumes/NO\ NAME
mdutil -i off /Volumes/NO\ NAME
rm -rf /Volumes/NO\ NAME/.Spotlight-V100 /Volumes/NO\ NAME/.fseventsd
touch /Volumes/NO\ NAME/.metadata_never_index
```

That needs no kernel change, but has to be repeated after every mount. The patch
makes the browser tolerant of a card that was never cleaned.
