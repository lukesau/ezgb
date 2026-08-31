# Battery-backed pSRAM page map & free space (1.05e)

Which pages of the battery-backed save pSRAM the kernel actually uses, and how
much is spare for new persistent features. The pSRAM is reached only from the
kernel via page latch `$4000 = <page>` then `$7FC0 = $03`, read/written through
the `$A000`–`$BFFF` window (8 KB per page). See
[fpga-personalities.md](fpga-personalities.md) and
[psram-save-map.md](psram-save-map.md).

Method: static sweep of every `$4000` page-latch write in `kernel.gb`, plus
empirical diff of two real pSRAM dumps (`sd/psram.bin` vs
`sd/psram.bin.pre-milestone0`, 64 pages × 8 KB = 512 KB, page N at file offset
`N*$2000`). The dumps reveal what the kernel touches in practice; the code sweep
bounds what it *can* touch.

## Page map

| Page | Bytes changed across dumps | Role | Free? |
|---|---|---|---|
| `$00`–`$0F` (0–15) | 3 B each | **Game save RAM** — the 128 KB MBC-RAM region the running game sees (max 16 banks = MBC5 ceiling). `$FF` when no save. | No |
| `$10` (16) | 0 (all-zero both dumps) | first page above the save region | **untouched** |
| `$11` (17) | 39 B | **Meta**: autosave flag `$A001`, backup savename `$A00F-$A025`, cart-init `$A201`, last-ROM path `$A300-$A316`. Highest byte ever used: **`$A316`**. | **partly** |
| `$12` (18) | 4163 B | browser path/name scratch (heavily rewritten) | No |
| `$13` (19) | 164 B | browser filename scratch | No |
| `$14`–`$3E` (20–62) | 0 (all-zero both dumps) | never touched | **untouched** |
| `$3F` (63) | 532 B | directory-listing cache (rewritten on browse) | No |

Untouched in both dumps: **page `$10` and pages `$14`–`$3E` = 44 pages × 8 KB =
352 KB** all-zero. The browser save-index paths mask the page to `& $1F`
(`00:0ad5`, `00:0c1f`, `01:4196/4350/4499`), i.e. they only ever reach pages
0–31; the fixed high pages (18, 19, 63) are written by dedicated cache routines,
not by that masked index.

## Spare space, by confidence

**Tier 1 — safe now: ~7 KB inside page 17.** The kernel maps page 17 for meta
and touches only `$A000`–`$A316` (autosave, backup savename, cart stamp,
last-ROM path). It is **not cleared on boot** (that is the whole point of the
last-ROM / BACKUPSAVE records persisting), and no routine memsets the page. With
a margin above the longest possible LFN savename (`$A010`+255 ≈ `$A10F`),
**`$A400`–`$BFFF` = 7168 bytes (7 KB)** is free, already battery-backed, and
kernel-preserved. Ideal for a small persistent config/state blob for our
features. Access it exactly as the kernel does: `$4000=$11`, `$7FC0=$03`,
read/write `$B400`+ region… (use `$A400`+ within the window), `$7FC0=$00`.

**Tier 2 — larger but unconfirmed: pages `$14`–`$3E` (20–62) ≈ 344 KB.** These
are above the `& $1F` save-index range and away from the browser caches, and sit
all-zero in both real dumps. Prefer these over pages 16–31 (which a hypothetical
>16-bank save could reach, though no real GB/GBC game does). Two things must be
confirmed on hardware before trusting them:

1. **Physically present & battery-backed.** The 64-page / 512 KB figure is the
   SameBoy stub's model (`EZJR_SRAM_BANKS=64`). daid's teardown lists U4's pSRAM
   die as 1 MB; how much is actually battery-backed and latch-addressable is
   unverified. A high page might alias a low one, or read open bus.
2. **Kernel truly never writes them** — the dumps are strong but not exhaustive
   (a code path my sessions didn't exercise could differ).

## Hardware verification (recommended before Tier 2 use)

A pSRAM analogue of the NOR probe ([nor-reuse.md](nor-reuse.md)): at the START
overlay, map `$7FC0=$03`, and for candidate pages (e.g. `$10`, `$20`, `$3E`)
write a known sentinel at a fixed offset, then on a *later* boot read those
pages back and draw the bytes.

- Sentinel survives a power cycle → that page is battery-backed and usable.
- Page still reads the sentinel (not overwritten) after normal browsing/launch →
  the kernel doesn't use it.
- Reads back `$FF`/open-bus or aliases page 17 → not real independent storage.

Do the same read-only check on page 17 `$A400`+ first (cheapest Tier 1 proof):
write a sentinel there, power cycle, confirm it persists and that normal use
never disturbs it.

## Bottom line

There is a **safe ~7 KB today** (page 17 `$A400`–`$BFFF`) for a battery-backed
config store — enough for feature flags, a fast-launch config, a richer
last-ROM/most-recent list, per-game settings, etc. — with a **potential ~344 KB
more** (pages 20–62) pending a one-time hardware probe. All of it dies with the
coin cell (same limitation as saves); it is convenient persistence, not
permanent storage. Truly battery-independent storage still needs the parallel
NOR path that does not exist ([updater-flash-write.md](updater-flash-write.md)).
