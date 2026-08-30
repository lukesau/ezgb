# Sorted file browser (1.05e)

The stock Jr kernel lists directory entries in raw FAT order, so a card whose
folders were recreated or re-copied shows them scrambled. This patch sorts the
listing: **directories first, then files, each group case-insensitively by
name**, the same ordering EZ Flash ships on the Omega DE (`Sort_folder` /
`Sort_file` in `tools/omega-de-kernel/source/ezkernelnew.c`: enumerate the
directory into folder and file arrays, bubble sort each with `strcmp`, draw
folders first). The Jr kernel never received it.

## Why it isn't a straight port

The Omega's flat EWRAM array makes an O(n²) bubble sort of full records
affordable. On the Jr the entries are 255-byte records in banked PSRAM behind
the `$A000` window (page `$03`, bank `$12 + (idx>>5)` at `$4000`, record at
`$A000 + 255*(idx&$1f)`, NUL-terminated name at +0, attr `$10`/`$20` at +$fe;
the general `$A000` window mechanism is [psram-save-map.md](psram-save-map.md)),
and the SM83 would take minutes to bubble-sort records across banks. Instead:

1. **Enumerate everything.** Loop `DirList` (16 records per call) until the
   end-of-directory latch `$c5a4` sets. Downstream code honours the latch and
   the running count at `$c2a2`, so the browser, the continuous-scroll patch
   and RIGHT-paging all work unchanged on the full list.
2. **Build one 16-byte key per entry** in scratch PSRAM bank `$ff`: class byte
   (0 = dir, 1 = file), 13 uppercased name chars, original index.
3. **Heapsort the keys.** Compare is a memcmp of the first 14 bytes; the class
   byte makes directories sort ahead of files for free. Prefix ties fall back
   to a full caseless name compare of the records (via the `$c4a4` LFN buffer,
   idle after enumeration).
4. **Apply the permutation with one cycle walk**: each record is copied exactly
   once (name up to its NUL plus attr, chunked through a stack buffer between
   banks), n copies total instead of O(n²) swaps.

The algorithm (heapsort + cycle permutation + tiebreak) was validated against a
Python reference model over 400 randomized directories before injection.

## Pieces

| Piece | Where |
|---|---|
| The code | `decomp/src/browser_sort.c` |
| Where it lives | bank 8 `$746b` (`BrowserSortAll`, 1585 bytes, cave is 2965) |
| Bank-0 stub | `$03d4` `BrowserSortAllStub`: `cd 8d 07 6b 74 08 00 c9` (FarCallTrampoline shim) |
| The hook | `00:102f` in `FileBrowserEntry`: was `call DirList`, now `call $03d4` |

The hooked call is the browser's *initial* `DirList`. The two other
`call DirList` sites (the continuous-scroll hook and RIGHT-paging at `00:117d`)
are latch-gated and never fire after the sort's full enumeration. Reproduce
with:

```bash
cd decomp
python3 tools/inject.py src/browser_sort.c 1.05e 8 746b BrowserSortAll \
    --pin DirList=0a43 --apply
python3 tools/inject_bytes.py 1.05e 0 03d4 BrowserSortAllStub \
    cd8d076b740800c9 --apply
python3 tools/patch_call.py 1.05e 0 102f 3 00:03d4 --apply --regen
```

## Choices and caps

- **Scratch bank `$ff`** (same page `$03`): records would only reach it past
  entry 7584, beyond EZ Flash's stated 7000-file cap. The SameBoy stub masks
  banks to 6 bits (`$ff`→`$3f`), still clear of records below 1440 entries.
- **`MAX_SORT` = 512** (512 × 16-byte keys = exactly one 8KB bank). Bigger
  directories are left in FAT order; a partially sorted list would mislead.
- **`MAX_ENUM` = 4096**: enumeration stops there and forces the latch, so no
  later `DirList` can march record banks toward the save pages (the stock
  kernel would wrap `$4000` past `$ff` on a pathological directory).
- Entering a directory now pays full enumeration up front, including the
  end-of-directory dead-tail walk (`scripts/fat-dir-audit.py`). That cost used
  to hide in the first scroll past the last page; the Omega pays it at list time
  too.
- `EZGB.DAT` can still appear in the listing (under E): the kernel's hide is a
  case-sensitive memcmp against `"ezgb.dat"` and an 8.3-stored copy comes back
  uppercase from FatFs. Pre-existing stock behaviour, unrelated to the sort.

## Verification (SameBoy)

`sd/card.img` root was given deliberately scrambled entries (`zzz.gb`, `ZZTOP/`,
`AAAA.GB`, `AARDVRK/` created in that order, interleaved with the existing TEST
files). With

```bash
./scripts/run-sameboy-debug.sh --script scripts/debug/browser-sort.sbd \
    --dump scripts/debug/dump-sort-records.sbd --trace
```

the breakpoint at `$1032` (the hook's return site; `BrowserSortAll` leaves page
`$03`/bank `$12` mapped precisely so this dump works) showed records 0..9 as
`AARDVRK`, `Pokemon`, `SAVER`, `ZZTOP`, `AAAA.GB`, `IRPROBE.GBC`,
`IRREMOTE.GBC`, `PKMRED.GB`, `Pokemon Red.fastlaunch`, `TEST00.GB` (dirs first,
alphabetical, caseless), with `$c2a2` = 52 = the full directory before the first
draw, and the browser reaching its input loop (`$1107`) normally. If the
emulator boots to the BACKUPSAVE prompt instead of the browser, clear the `$AA`
stamp: byte `0x22000` of `sd/psram.bin`.
