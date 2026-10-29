# Kernel picker (stage1)

Status: **built 2026-10-26, checked in SameBoy, not yet on hardware.** The
idea had been a "Next" bullet in [fpga-stage1.md](fpga-stage1.md#next) since
the fast-launch work of 2026-10-08. The design below is what was built; the
[As built](#as-built) section at the end lists where the build departed from
it and what it measured.

Stage1 boots `/EZGB.DAT` and nothing else, so trying another kernel means
renaming files on the card. With more than one kernel on the card (stock and
the mod, a release and a test build, 1.04e and 1.05e for a card that moves
between an FW4 and an FW5 cart) stage1 should ask which one to boot.

## Behavior

**Trigger.** On the kernel path only, stage1 scans the card's root for files
whose name ends in `.dat` (any case, long or 8.3 name). It skips directories,
the volume label and names starting with `.`: macOS writes a `._ezgb.dat`
sidecar next to `ezgb.dat` on a FAT card, which would otherwise count as a
second kernel. The first four found, in directory order, are kept.

| `.dat` files in the root | What happens |
|---|---|
| 0 | `EZGB.DAT NOT FOUND`, retried every second, as today |
| 1 | boots it, whatever its name, with no prompt |
| 2 to 4 | the picker |
| more | the picker, with the first four |

The kernel path is reached only after fast launch is ruled out (no
`FLAUNCH=`, START held, or a target stage1 can't launch), so a fast-launch
boot never scans or asks. The pick happens once per boot: when the chosen
file turns out damaged or fragmented, the error shows and the retry loop
keeps trying that file, as it does with `EZGB.DAT` today.

**Screen.** The boot screen stays as it is: icon, wordmark. The picker takes
the five text rows under the wordmark (13 to 17), which in a normal boot hold
`LOADING...`, the detail line and the version line:

```
row 13       CHOOSE A KERNEL
row 14  >EZGB.DAT
row 15   EZGB-104E.DAT
row 16   STOCK-0918.DAT
row 17   MOD-7.0-TEST.DAT
```

Names are drawn from column 1, upper-cased like all stage1 text (the font
has capitals only) and cut at 19 characters; the `>` cursor is column 0. On a
pick the five rows are cleared, `LOADING...` and the version line come back
and the load continues as today.

**Keys.** UP and DOWN move the cursor, wrapping at both ends. A or START
boots the highlighted kernel. A press counts once, on release, the way the
backup prompt reads A and B. B does nothing. There is no timeout: two kernels
on a card is a deliberate setup, and a timer would either hold up every boot
or boot before the list has been read.

**Default.** The cursor starts on `ezgb.dat` when it is in the list, else on
the first entry. `ezgb.dat` stays the name of the main kernel, so a card set
up for the picker still boots on a stock stage1, which knows only that name.
Remembering the last pick (a mark in page `$11` from `$A420`, which is free)
can come later; without a timeout it would only save one press.

## Stage1 changes

| File | Change |
|---|---|
| `fat.c` | Split the inner loop of `lookup()` into `dir_entry()`: the next real entry with `name` filled, deleted entries, LFN pieces and the volume label handled as now. `lookup` keeps calling it with `name_is`. New `fat_scan_dat(list)` calls it over the root and keeps each `.dat` entry's first cluster, size and 19 characters of name, four at most. New `fat_select(cluster, size)` sets the open-file state (`file_cluster`, `file_size`, the chain cursor) so the pick needs no second name lookup. |
| `fpga.c` | `buttons()` reads the button row only (`$FF00 = $10`). Add the d-pad row (`$20`) so UP and DOWN come back in two more bits. |
| `video.c` | `print_at(row, col, s)`, with `print_center` a wrapper over it. The cursor is one `put` at column 0. |
| `main.c` | `kernel()`: scan, pick when there are two or more, select, load command. `EZGB.DAT DAMAGED` and `EZGB.DAT FRAGMENTED` become `KERNEL DAMAGED` and `KERNEL FRAGMENTED`, since the file may not be `EZGB.DAT`; `EZGB.DAT NOT FOUND` stays, it is true when no kernel is found and it is the message people search for. |

WRAM: the list lives in `text[]`, free once fast launch is ruled out: four
entries of cluster, size and name is 112 bytes of its 512.

ROM: about 300 to 450 bytes. Scan ~120, list drawing ~110, keys ~70, select
~20, strings ~30.

## Making room

Stage1 is full. The dark-mode build is 18,419 of the 18,432 BRAM bytes, so
about 450 bytes have to go before the picker goes in. Candidates, biggest
first:

- **Wordmark paint maps, ~190 bytes.** `wordmark.c` carries five 64-byte
  tile maps: the letters alone, three part-painted, the whole mark. The Jr.
  is painted left to right, so each middle map is the final map up to some
  tile column and the letters map past it. Keep only the two end maps and a
  tile-column cutoff per step, and let `wordmark_paint` choose the map per
  column. The cutoffs have to fall on tile edges for this. The Jr. is about
  four tiles wide (x 96 to 127), so four steps of one tile each, which is
  within a pixel of today's equal quarters. Tile-aligned cutoffs also drop
  the part-painted tiles from the tile set, worth another 100 to 200 bytes
  if today's cutoffs aren't aligned.
- **`cfg.c`, 635 bytes for one key.** `is_key` spells out FLAUNCH with its
  own loop; the picker's `.dat` test wants the same case-insensitive compare,
  shared. A few dozen bytes.
- **The biggest functions.** A pass over the `.lst` output for `fat_create`
  and `make_sfn`, `backup_offer` and `game_launch` usually finds a few dozen
  bytes each; so does a higher `--max-allocs-per-node`.

The wordmark alone gets the picker within reach. The rest leaves room for
the remembered pick later.

## Kernel side

Two places in the kernel know the kernel file only by the exact name
`ezgb.dat`, so a second kernel file would show through:

- **Browser.** The stock browser hides `ezgb.dat` with a memcmp against that
  one name (`00:0bc8`, [ezgb-dat-boot.md](ezgb-dat-boot.md)).
  `BrowserHideName` ([browser_hide.c](../kernel/src/browser_hide.c)) adds
  `.gba`, `EZGB.CFG`, `FLAUNCH.CFG`, `SAVER` and dot-files; it gets a `.dat`
  suffix rule, one more `ends_ci` call. The SET tab's PICK ROM runs over the
  filtered list, so a kernel can't be picked as a fast-launch target either.
- **Lone-ROM rule.** `scan_root` in
  [fastlaunch.c](../kernel/src/fastlaunch.c) skips `ezgb.dat` by name when
  it counts the root's real files; a second kernel would count as a file and
  turn the rule off. It skips any `.dat` instead.

Neither is needed for the picker itself; they keep the browser and fast
launch as they are with several kernels on the card. Both ride in the
unreleased kernel 7.0, the stage1 side in the unreleased stage1 2.0; VERSION
changes once per release, so neither moves now.

Compatibility: a picker stage1 with an older kernel works, the extra `.dat`
files just show in that kernel's browser. A stock stage1 with several `.dat`
files boots `ezgb.dat` as always.

## Testing

SameBoy's Jr stub runs stage1 and follows the load command
([fpga-stage1.md](fpga-stage1.md#emulator-support)), so the picker can be
exercised in the emulator. `scripts/make-sd-image.sh` writes `ezgb.dat`; a
second kernel copied in with `mcopy` under another name (a copy of any other
build) brings the picker up, and `scripts/showcase/stage1-shots.py` already
drives stage1 with injected keys and takes screenshots. To check:

- one `.dat` boots silently, and it is the one that runs (HELP tab version)
- a `._ezgb.dat` sidecar doesn't count
- five `.dat` files show four; a 30-character name is cut, not wrapped
- the cursor wraps; A and START boot, B does nothing
- a `FLAUNCH=` boot never shows the picker; START held does
- a damaged pick shows `KERNEL DAMAGED` and retries that file

Then the FW5 cart with the updater from `build-stage1-updater.sh`, and the
FW4 Jr.

## Decisions

Taken as recommended (2026-10-26):

1. A lone `.dat` with another name boots silently, rather than insisting on
   `ezgb.dat` and showing NOT FOUND. A lone kernel is unambiguous and nobody
   has to rename a file.
2. No timeout.
3. Four entries with a title row; the version row is covered while the
   picker is up.
4. Wordmark paint steps on tile columns, the trim's one visible effect.

## Later

- Remember the last pick in page `$11` (`$A420`+) and start the cursor there.
- Show each kernel's version next to its name. The modded kernels keep a
  fixed 10-byte `MOD <n>` field at `08:7aff` ([help-version.md](help-version.md));
  stock kernels have none. One extra SD read per entry.

## As built

Stage1 side (`stage1/src`): `fat.c` got `dir_entry()` (the entry loop
`lookup` used, now shared), `fat_scan_dat()` and `fat_select()`; `fpga.c`
reads the d-pad row in `buttons()` and owns `wait_release()`; `video.c` got
`print_at()`; `main.c` the picker and the new `kernel()`. The kernel side is
the `.dat` rule in `browser_hide.c` and `is_dat()` in `fastlaunch.c`, in the
7.0 patches.

Departures from the design above:

- **The scan tests the 8.3 extension**, `e[8..10] == "DAT"`, plus `name[len
  - 4] == '.'` on the long name so `.data` doesn't count, instead of
  upper-casing the long name's tail: SDCC code for the loop was three times
  the size.
- **A list entry is 32 bytes**, not 28: bytes 20 to 31 of the directory
  entry as they are (cluster and size, with the time stamp in between), then
  the name. `fat_select(list, i)` opens the i-th without a 32-bit store or a
  multiply, both of which cost more than the four spare bytes per entry.
- **The scan reports the default** (`kernel_default`, the index of
  `EZGB.DAT`, through the `name_is` compare fat.c already has) so main.c
  needs no string compare of its own.
- **A failed load comes back to the picker.** `kernel()` scans and asks on
  every pass of the retry loop, so a kernel that fails with `KERNEL DAMAGED`
  or `KERNEL FRAGMENTED` shows the error for a second and then the list
  again, and another can be picked. That is less code than remembering the
  pick, and more useful.
- **Making room took more than the wordmark maps.** The picker came to about
  480 bytes of SDCC output, not 300 to 450, and the three middle wordmark
  maps saved 289 (the tile-aligned cuts also dropped 7 part-painted tiles).
  The rest came from run-length packing the icon and wordmark tile data
  (`scripts/fpga/packbits.py`, unpacked into VRAM by `video.c`): 672 to 457
  bytes and 624 to 441, against a 40-byte decoder.

| Build | BRAM bytes of 18,432 |
|---|---|
| dark-mode theme colors (the base) | 18,419 |
| wordmark maps trimmed | 18,130 |
| with the picker, before packing the tiles | 18,860 |
| with the tiles packed (shipped) | 18,400 |

32 bytes are free. The next stage1 feature needs its own trim first; `cfg.c`
(635 bytes for one key, with 16-bit indexes where pointers would do) and
`fat_create` (about 2 KB) are where to look.

Checked in SameBoy (`--model dmg`, the Jr stub, test cards from `mformat`,
64 MB: a 16 MB FAT32 card from `mformat -F` has too few clusters to be FAT32
and both stage1 and the kernel's FatFs read it wrong, so don't test with
one):

- three kernels plus a `._ezgb.dat` sidecar, a `notes.data` and an empty
  `empty.dat`: the picker lists the three, the long name cut at 19
  characters; DOWN, DOWN, UP x3 wraps the cursor round; B does nothing; A
  loads the highlighted file (the stub's load log names its first sector)
- `sd/card.img`, one kernel: no key wait, `ezgb.dat` loads
- five kernels: four listed, START loads the default
- `alpha.dat`, `ezgb.dat`, `omega.dat` in that order: the cursor starts on
  `ezgb.dat`, A loads it
- the splash still paints the whole wordmark before `LOADING...`
- the 7.0 kernel's browser shows none of the `.dat` files, and the lone-ROM
  rule fast-launches a card's one ROM with two kernels beside it

Not yet: the carts, and a real card with `._ezgb.dat` on it. The FW5-0918
updater is built (`fpga/load/Update_FW5-0918-mod-2.0-picker.gb`, label
`Update: s1 pick`, 2026-10-26): the picker stage1 and the bank 2 flash read
patch round-trip, and only those ten BRAMs differ from stock 0918 slot B. No
FW4 build yet.
