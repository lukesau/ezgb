# Battery-backed pSRAM page map & free space (1.05e)

Which pages of the battery-backed save pSRAM the kernel actually uses, and how
much is spare for new persistent features. The pSRAM is reached only from the
kernel via page latch `$4000 = <page>` then `$7FC0 = $03`, read/written through
the `$A000`–`$BFFF` window (8 KB per page). See
[personalities.md](../re/stage0/docs/personalities.md) and
[psram-save-map.md](psram-save-map.md).

Method: static sweep of every `$4000` page-latch write in `kernel.gb`, the
browser's record addressing (`kernel/src/browser_scroll.c`,
`kernel/src/browser_sort.c`), plus two real pSRAM dumps (`sd/psram.bin` vs
`sd/psram.bin.pre-milestone0`, 64 pages × 8 KB = 512 KB, page N at file offset
`N*$2000`). The dumps show what the kernel touched in the sessions that made
them; the code bounds what it *can* touch. Where they disagree, the code wins:
an earlier version of this page called pages `$14`–`$3E` free because the
dumps came from an SD card with small directories.

## Page map

> **Correction (2026-10-10).** This page assumes a 6-bit page latch and 64
> pages, as the emulator models it (`EZJR_SRAM_BANKS=64`). Simulating the
> FPGA designs of FW4, FW5-0731 and FW5-0918
> ([firmware-diff.md](../re/stage0/docs/firmware-diff.md#save-pages-from-the-kernel))
> says the page latch is **5 bits**: `$4000 = $20-$3F` drives exactly the
> same memory address as `$00-$1F` (`$FF` lands on `$1F`, not `$3F`), on all
> three. If the hardware agrees, there are 32 pages, the sort keys share
> page `$1F` with browser records, and browser records wrap onto page `$00`
> (game save RAM) once a directory passes 448 entries (`$12 + 448/32 =
> $20`); from 417 entries they reach `$1F` and collide with the sort keys.
> Not yet checked on a cart: the debug tab's alias test only compares page
> `$10` with `$00`, `$01` and `$11`. A `$20`-vs-`$00` alias test would
> settle it.
>
> **Confirmed on hardware (2026-10-10).** The debug tab's B test
> ([debug-tab.md](debug-tab.md#page-latch-alias-test-b)) on an FW5 cart
> running 1.05e-0918 (GBC): a write through page `$20` changed page `$00`, and
> one through `$3F` changed `$1F`. There are 32 pages. The table and the
> sections below are updated for that.


| Page | Role | Free? |
|---|---|---|
| `$00`–`$0F` (0–15) | **Game save RAM**: the 128 KB MBC-RAM region the running game sees (max 16 banks = MBC5 ceiling). `$FF` when no save. | No |
| `$10` (16) | Nothing found that writes it; on hardware it held a test pattern across boots and is not an alias of `$00`, `$01` or `$11` ([debug-tab.md](debug-tab.md)). Stock browser records reach it in directories over 960 entries | Yes with the mod (an FW4 Jr, and an FW5 with its coin cell: pattern kept over 30 minutes off); stock, below 961 entries |
| `$11` (17) | **Meta**: backup-pending `$A000`, save size `$A001`, save path length `$A00F` and path `$A010`+, autosave `$A200`, cart-init canary `$A201`, last-ROM path `$A300`–`$A3FE`; the mod's SGB BOOT record at `$A400`–`$A403` ([sgb-boot.md](sgb-boot.md)); stage1's skip-fast-launch mark `"S1"` at `$A410`–`$A411` (below) | **`$A404`–`$A40F`, `$A412`–`$BFFF`** |
| `$12`–`$1E` (18–30) | **Browser records**: entry *i* at page `$12 + (i >> 5)`, offset `255 * (i & $1F)`. The mod lists at most 416 entries, so records end at `$1E`. The page is computed unmasked, so in the stock kernel they go on past `$1F` and wrap to `$00` | No, grows with directory size |
| `$1F` (31) | **Sort keys** (mod): `browser_sort.c`, 16 bytes per entry. Stock: browser records from entry 417 | No |

The browser keeps 32 entries per page and enumerates the whole directory, so a
directory of N entries fills pages `$12` through `$12 + (N-1)/32`: 100
entries reach `$15`, 416 fill `$1E`. The mod stops there (below); in the
stock kernel the page wraps modulo 32, so 417 entries reach `$1F`, 449 wrap
onto `$00` (game save RAM), 961 reach `$10` and 993 reach `$11` (meta). Both dumps show
only `$12` (4,163 bytes changed) and `$13` (164 bytes) because the test card's
largest directory had about 33 entries. Every page from `$12` up is browser space.

## Spare space

**Page `$11` `$A400`–`$BFFF` = 7168 bytes (7 KB).** The kernel maps page 17
for meta and touches only `$A000`–`$A3FE`; the last-ROM path is the highest use
(255 bytes from `$A300`), and the current dump's highest written byte is
`$A309`. The page is **not cleared on boot** (that is the whole point of the
last-ROM / BACKUPSAVE records persisting), and no routine memsets it. The mod
itself stores nothing in pSRAM (its settings are `EZGB.CFG` on the SD card), so
nothing of ours is there either. No game can reach it: games see only pages
`$00`–`$0F`. Access it exactly as the kernel does: unlock, `$4000=$11`,
`$7FC0=$03`, read/write `$A400`+, `$7FC0=$00`.

**Page `$10`, probably.** Nothing in the code sweep writes it and it is zero in
both dumps, but nothing proves the save path never reaches a 17th bank.
Prefer page `$11` `$A400`+ until a probe confirms it.

With the stock kernel both are only safe while no directory has more than
960 entries (992 for page `$11`); the mod never lists more than 416 (below).
There is no large free region: everything from `$12` up belongs to the
browser once a directory is big enough.

## Page-latch width: 5 bits

Only 5 bits of the `$4000` latch reach the pSRAM, so the kernel sees 32 pages
of 8 KB: simulated on FW4, FW5-0731 and FW5-0918
([firmware-diff.md](../re/stage0/docs/firmware-diff.md#save-pages-from-the-kernel))
and confirmed on an FW5 cart (2026-10-10, the debug tab's B test). The
simulation also says each byte takes one 16-bit word of U4 (low byte lane
only), which is how 256 KB of pages fills the 512 KB die; that part is not
checked on a cart.

The browser computes record pages unmasked. The stock kernel has no cap
short of EZ Flash's stated 7,000 files, and until mod 5.6 the mod stopped
enumerating only at 4,096 (`MAX_ENUM`, chosen for 64 pages), so in both a
large directory overwrote other pSRAM:

| Directory size | Record page reaches | Overwrites |
|---|---|---|
| 417–512 entries | `$1F` | the mod's sort keys, built on the same page for directories up to 512 entries (`MAX_SORT`) |
| 449+ entries | `$00`, then up | game save RAM |
| 961+ entries | `$10` | the probe page |
| 993+ entries | `$11` | meta: pending backup, save path, last ROM, the SGB BOOT record |

Reproduced in SameBoy once the stub modeled 32 pages: a 521-entry root
rewrote pages `$00`–`$02`. The stub modeled 64 pages until 2026-10-10 and hid
all of this.

**Mod 5.6 caps every directory at 416 entries**, records on `$12`–`$1E` and
sort keys alone on `$1F`. The cap sits in the per-entry hook `DirList` calls
before each record write, so no caller can get past it; a cut directory
shows a short notice and is listed in FAT order
([browser-sort.md](browser-sort.md#record-cap)). The stock kernel is
unchanged: on stock firmware a directory over 448 entries still overwrites
saves.

## Hardware verification

A pSRAM analogue of the NOR probe ([nor-reuse.md](nor-reuse.md)): write a
sentinel to page `$11` `$A400` (and page `$10` if it is wanted), power cycle,
and read it back on a later boot.

- Sentinel survives a power cycle → battery-backed and usable.
- Still intact after browsing large directories and launching games → the
  kernel doesn't use it.

## Bottom line

There is a **safe ~7 KB** (page 17 `$A400`–`$BFFF`) for a battery-backed
config store: feature flags, the SGB boot toggle, a richer last-ROM list,
per-game settings. Page `$10` may add 8 KB once probed. Both are only safe
while directories stay under 961 entries (above). All of it dies with the
coin cell (same limitation as saves); it is convenient persistence, not
permanent storage. Truly battery-independent storage still needs the parallel
NOR path that does not exist ([updater-flash-write.md](updater-flash-write.md)).

## Stage1 skip-fast-launch mark (`$11:$A410`)

The from-source stage1 (`bitstream-re` branch, `stage1/`) writes `"S1"` to
page `$11` `$A410`–`$A411` when START was held at power-on, and zeroes it
otherwise. The kernel (mod 5.4+, `ezcfg.c` `stage1_skip_mark`, run by
`RtcBootHook` every boot) clears the mark and sets `fastlaunch_boot`'s
one-shot flag `$DBFF`, so a fast launch the user canceled in stage1 stays
canceled even after START is released.
