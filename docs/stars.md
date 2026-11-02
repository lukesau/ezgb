# Stars and play counts

Hold A on a ROM and pick **Star** ([rom-menu.md](rom-menu.md)): the ROM moves to
the top of its folder's files, under the folders, with a star in place of its
cartridge icon. **Unstar** in the same menu puts it back. Every launch also adds
one to the ROM's play count, and with **SORT BY PLAYS:** ticked on the SET tab's
second page, files are listed most played first, unplayed ones A-Z after them.
Starred files stay on top either way.

The idea comes from davidesqalv's fork
([ezgb-dv](https://github.com/davidesqalv/ezgb-dv)), built on mod 6.9. This is a
rewrite for 7.0, not a port of its code: his table had 64 slots and no way to
free one, 16-bit hashes, and scores that stopped growing after 21 plays; the
sort setting took the SGB BOOT row; and the menu sent the cursor to the top of
the list after a star.

Emulator-tested (SameBoy, CGB and DMG, 8px and 12px, 0731 and 0918). Not yet on
hardware.

## The table

Battery-backed pSRAM, page `$11` ([psram-page-map.md](psram-page-map.md)):

| Where | What |
|---|---|
| `$B7F8` | `'P'`, `'L'`, entry count (up to 254), star count |
| `$B800`+ | 8 bytes per entry, sorted by hash: hash (4), launches (2, little-endian), flags (bit 0 = starred), 0 |
| `$A404` | SORT BY PLAYS: `'S'`, `'O'`, 1, `$FE` when on, beside SGB BOOT's record at `$A400` |

A ROM gets an entry the first time it is launched or starred. The key is a hash
of the file name alone, uppercased: djb2 (`a = a * 33 + c`, from 5381) and the
running sum of it (`b = b + a`), stored `a` hi, `a` lo, `b` hi, `b` lo. So a ROM
keeps its count when it moves to another folder, and copies of one ROM in two
folders share it. A lookup is a binary search over the sorted entries.

When the table is full, a new name takes the place of the least-launched entry
without a star. With 254 stars, a new star is refused and nothing changes.
Unstarring a ROM that was never launched drops its entry. A header that is not
`'P'`, `'L'` (a new cart, or a dry coin cell) starts an empty table. Since
2026-10-31 the table is also kept on the card (below), so a cart without a
coin cell keeps its stars and counts too.

## On the card

`/.ezgbplays`, in the card's root: the leading dot hides it from the browser
and from stage1's kernel picker. 2048 bytes, four sectors, and file offset `k`
is pSRAM page `$11` at `$B7F8 + k`, except bytes 4..7, which hold the SORT BY
PLAYS record (`$A404`):

| Offset | What |
|---|---|
| 0..3 | `'P'`, `'L'`, entries, stars (`$B7F8`) |
| 4..7 | `'S'`, `'O'`, 1, `$FE` when SORT BY PLAYS is on (`$A404`) |
| 8..2047 | the entries (`$B800`) |

**Boot.** `PlayLoad` runs in `ezcfg`'s boot restore, after `EZGB.CFG`: a
file with a valid header replaces the pSRAM table, so the card is the source of
truth (stars and counts follow the card from cart to cart). No file, or a
header that is not ours: pSRAM is kept, so a cart with a battery carries its
table over the first time. Booting writes nothing.

**Writes, kept to a minimum.** `PlaySync` runs after a launch (from
`PlayLaunchHook`), after Star and Unstar (`StarToggleSync`) and after a SORT
BY PLAYS toggle. It reads each of the four sectors, compares it with pSRAM,
and writes only a sector that differs:

| Action | Sectors written |
|---|---|
| launch of a ROM already in the table | 1 |
| first launch of a ROM, star, unstar | 1 or 2 (the header sector, and the entry's when it is not in sector 0) |
| SORT BY PLAYS | 1 |
| the first time on a card | the file is created: its four sectors, plus FAT, directory and FSInfo, about a dozen writes once |

After it is created the file keeps its size and clusters, and it is not
closed, so FatFs never rewrites its directory entry. Writes are whole aligned
sectors only: this FatFs mishandles partial-sector writes (`ezcfg.c`
`far_write`). A launch also rewrites `EZGB.CFG` (`LASTROM=`, `RTC=`), which
the stars do not change: in SameBoy that is about seven more writes per launch,
since `ezcfg` recreates the file each time.

Checked in SameBoy with the SD write trace (`SAMEBOY_EZFLASH_JR_LOG=1`): a
star on a fresh card creates the file, a launch writes one sector, SORT BY
PLAYS one, and after pSRAM page `$11` is filled with random bytes the next boot
shows the same stars, order and setting.

## How the sort uses it

The sort ([browser-sort.md](browser-sort.md)) builds a 16-byte key per entry,
class byte first. After `build_keys`, `PlayKeys` looks up every file:

- class 0 stays a folder, 1 is a starred file, 2 any other file, so folders
  sort first and starred files right after them
- with SORT BY PLAYS on, key byte 1 becomes 255 minus the launches (0 past
  255) and the name moves one byte on, so more played sorts first and equal
  counts sort by name

With no star and the setting off, nothing is looked up and the sort costs what
it did. Hashing is roughly 45 cycles a character, so a 416-entry folder adds
about half a second on a DMG when there is something to look up (an estimate).

`PlayKeys` leaves the folder and star counts after the keys on the key page
(`$BA00`). The star icon comes from the records themselves: as the sort's last
step, `PlayMark` writes `$2A` into byte 253 of the starred records, which are
entries `folders` to `folders + stars - 1`, and 0 into every other record.
Byte 253 is the name's guard NUL (names are at most 253 bytes, and the sort
writes it 0), so a name that runs to byte 253 has no room for the mark and
shows no star. A listing that was not sorted (under two entries, or cut at 416,
`LIST_CUT`) gets no marks.

`DrawNameWithIcon` ([browser_icons.c](../kernel/src/browser_icons.c)) draws
glyph `$7F` for a marked record: the 8px font's tile `$7F` (`StarGlyph8`,
`00:35fe`) and the 12px font's `$7F`, an icon like `$C0`-`$C4` with the 12 px
icon advance ([font12.md](font12.md)). Both are a plain five-point star,
mirror-symmetric, with the points as close to one size as the cell allows:
7x7 in the 8px tile, 9x9 in the 12px cell with the legs splayed out to
balance the arms.

## Star in the menu

`StarQuery` hashes the name the menu copied to `$c4a4` and says whether it is
starred, for the Star / Unstar label. `StarToggle` hashes it again (before the
sort reuses `$c4a4`), flips the flag, sorts the folder again through
`BrowserSortAllStub` (the directory is already read, so no SD access), hashes
records until it finds the ROM, and moves the cursor there, on the same screen
row when the list allows. Both map the cursor's record page again before they
return, since the stock open path reads the record from the window. In a cut
listing the star is still saved but the order and icons stay as they are.

## Pieces

| Piece | Where |
|---|---|
| `Bump`, `PlayKeys`, `StarQuery`, `StarToggle` and the table code | `05:7c9f`, [play.c](../kernel/src/play.c), 865 B of asm (SDCC made 1982 B of the C) |
| `PlayKeysFar` (stub to `PlayKeys`), `PlayMark` | `08:7f29`, [play_mark.c](../kernel/src/play_mark.c), beside the sort that near-calls them |
| `PlayLaunchHook` | `01:7ec6`: far call to `Bump`, then `jp LastRomSaveHook`; `01:48c1`, `LastRomPersist`'s tail, jumps here instead of to `LastRomSaveHook` |
| `StarQueryFar`, `StarToggleFar` | `04:5998`, `04:59a0`: far stubs for `RomMenu`; `StarToggleFar` goes to `StarToggleSync` (bank 11) since the table is on the card |
| `PlayLoad`, `PlaySync`, `StarToggleSync` | `0B:4700`, [play_file.c](../kernel/src/play_file.c), 845 B: `/.ezgbplays`; stubs `FarCallPlayLoad` `02:78b0` (from `ezcfg`) and `FarCallPlaySync_B4` `04:7792` (from `SetPage`); `PlayLaunchHook` calls `PlaySync` after `Bump` |
| `RecFlag` | `04:7f51`, [rec_flag.c](../kernel/src/rec_flag.c): SGB BOOT's and SORT BY PLAYS' pSRAM records, read and toggled for `SetPage` |
| SET tab row | page 2, row 10, cursor row 10 (PREV is now 11, clamp `04:5604` `d6 0b`), [setpage.c](../kernel/src/setpage.c), [flcfg.c](../kernel/src/flcfg.c) |
| `DrawNameWithIconImpl` | moved from `02:7e80` to `02:7e00` to make room for the star test |

## Not done

- Not tested on hardware, and the full-table eviction is untested anywhere.
  The card file is checked in SameBoy only.
- The play count is not shown anywhere, only used for the order.
- Stage1's fast launch boots a game without the kernel, so it is not counted.
