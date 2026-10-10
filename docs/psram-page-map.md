# Battery-backed pSRAM page map & free space (1.05e)

Which pages of the battery-backed save pSRAM the kernel actually uses, and how
much is spare for new persistent features. The pSRAM is reached only from the
kernel via page latch `$4000 = <page>` then `$7FC0 = $03`, read/written through
the `$A000`–`$BFFF` window (8 KB per page). See
[personalities.md](../re/stage0/docs/personalities.md) and
[psram-save-map.md](psram-save-map.md).

Method: static sweep of every `$4000` page-latch write in `kernel.gb`, the
browser's record addressing (`decomp/src/browser_scroll.c`,
`decomp/src/browser_sort.c`), plus two real pSRAM dumps (`sd/psram.bin` vs
`sd/psram.bin.pre-milestone0`, 64 pages × 8 KB = 512 KB, page N at file offset
`N*$2000`). The dumps show what the kernel touched in the sessions that made
them; the code bounds what it *can* touch. Where they disagree, the code wins:
an earlier version of this page called pages `$14`–`$3E` free because the
dumps came from an SD card with small directories.

## Page map

| Page | Role | Free? |
|---|---|---|
| `$00`–`$0F` (0–15) | **Game save RAM**: the 128 KB MBC-RAM region the running game sees (max 16 banks = MBC5 ceiling). `$FF` when no save. | No |
| `$10` (16) | Nothing found that writes it; on hardware it held a test pattern across boots and is not an alias of `$00`, `$01` or `$11` ([debug-tab.md](debug-tab.md)) | Yes (one FW4 cart) |
| `$11` (17) | **Meta**: backup-pending `$A000`, save size `$A001`, save path length `$A00F` and path `$A010`+, autosave `$A200`, cart-init canary `$A201`, last-ROM path `$A300`–`$A3FE`; the mod's SGB BOOT record at `$A400`–`$A403` ([sgb-boot.md](sgb-boot.md)); stage1's skip-fast-launch mark `"S1"` at `$A410`–`$A411` (below) | **`$A404`–`$A40F`, `$A412`–`$BFFF`** |
| `$12` and up (18+) | **Browser records**: entry *i* at page `$12 + (i >> 5)`, offset `255 * (i & $1F)` | No, grows with directory size |
| `$3F` (63) | **Sort keys**: `browser_sort.c` uses bank `$FF`, which lands on `$3F` with a 6-bit page latch | No |

The browser keeps 32 entries per page and enumerates the whole directory, so a
directory of N entries fills pages `$12` through `$12 + (N-1)/32`: 100 entries
reach `$15`, 1,000 reach about `$31`. Both dumps show only `$12` (4,163 bytes
changed) and `$13` (164 bytes) because the test card's largest directory had
about 33 entries. Every page from `$12` up is browser space.

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

There is no large free region: everything above `$11` belongs to the browser
once a directory is big enough.

## Open: page-latch width

The 64-page / 512 KB size is the U4 pSRAM die
([hardware-board.md](hardware-board.md)) and the SameBoy stub's model
(`EZJR_SRAM_BANKS=64`). The browser computes record pages unmasked: the 1,473rd
entry lands on page `$40`, and EZ Flash's stated 7,000-file cap would reach page `$EC`.
If the FPGA keeps only 6 bits of the latch, as the stub does, page `$40` aliases
page `$00`: a directory over 1,472 entries would overwrite game save RAM, and
one over 2,016 entries would reach the page `$11` meta (including anything we
store at `$A400`+). Not verified on hardware. A probe would write a sentinel to
page `$00`, write a different one through page `$40`, and read page `$00` back.

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
per-game settings. Page `$10` may add 8 KB once probed. All of it dies with the
coin cell (same limitation as saves); it is convenient persistence, not
permanent storage. Truly battery-independent storage still needs the parallel
NOR path that does not exist ([updater-flash-write.md](updater-flash-write.md)).

## Stage1 skip-fast-launch mark (`$11:$A410`)

The from-source stage1 (`bitstream-re` branch, `re/stage1/`) writes `"S1"` to
page `$11` `$A410`–`$A411` when START was held at power-on, and zeroes it
otherwise. The kernel (mod 5.4+, `ezcfg.c` `stage1_skip_mark`, run by
`RtcBootHook` every boot) clears the mark and sets `fastlaunch_boot`'s
one-shot flag `$DBFF`, so a fast launch the user cancelled in stage1 stays
cancelled even after START is released.
