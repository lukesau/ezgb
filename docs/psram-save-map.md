# Cart SRAM / PSRAM and saves (1.05e)

How cart save RAM works on the EZ Flash Jr kernel, and where it shows up in the disassembly.
Annotations are kept in tracked files and reinjected into `bank_*.asm`.

On-cart save storage is battery-backed **PSRAM**. Games *see* "battery RAM" because the FPGA
emulates a normal MBC `$A000` window; those writes physically land in PSRAM kept alive by the
coin cell. The coin cell backs **both saves and the RTC**, so a dead cell loses both (the
well-known "EZ Flash Jr battery dies in a month" complaints). The save/settings pSRAM is the
**512 KB pSRAM die inside U4** (the `S71GL032A40` MCP — datasheet-confirmed, and an exact match
for the 64-page / 512 KB map); the *game* ROM lives in a separate, larger pSRAM in U9. Chip
detail: [hardware-board.md](hardware-board.md). The kernel's `BATTERY` / `DRY!!!` notice is
about the **console** AA cells, not the cart.

## Two bus personalities, one PSRAM chip

| Phase | CPU runs | How RAM is accessed |
|---|---|---|
| Kernel menu | `EZGB` (`kernel.gb`) | FPGA unlock/commit on `$7Fxx`; `$7FC0=$03` + `$4000`=page + `$A000`–`$BFFF` |
| Launched game | Loaded `.gb` ROM | Normal MBC only (`$2000`–`$5FFF`, `$A000`–`$BFFF`); **no** `$7Fxx` commands |
| Next kernel boot | `EZGB` again | Kernel reads page `$11` meta; optional PSRAM → `SAVER/` on SD |

The game does not talk to FPGA command registers while saving. The FPGA emulates the
game's MBC and maps `$A000` writes into the **same** physical PSRAM the kernel used
from the menu.

SameBoy stub mirrors this: `mbc_ram` aliases `cart_sram` after `$7FE0` soft-reset.

## Save lifecycle

1. **In-game**: MBC “battery RAM” writes land in PSRAM only (no host power needed to retain).
2. **Before launch**: kernel stamps page `$11` (`$AA` = pending backup, savename, bank count).
3. **After power-up**: if `$AA` still set, `SdMenuMain` offers **BACKUPSAVE** and copies PSRAM to `SAVER/*.SAV` on the SD image.

Details for the emulator workflow: [sd/README.md](../sd/README.md).

## BACKUPSAVE flag lifecycle

The whole feature turns on one byte in PSRAM, page `$11` (bank 17), address **`$A000`**,
reachable only from the kernel via `SetFpgaPage_B1`/`_B0` with `$7FC0=$03`. The prompt shown
on boot (`BACKUPSAVE` / `Saving..` / `[B]NO` `[A]OK`) is `BackupSavePrompt` at `01:6747`.

The same page `$11` window also holds the last-ROM path record at `$A300` (255 bytes, rompage
`$03`), likewise battery-backed and lost with the cell; see [last-rom.md](last-rom.md).

### What sets the flag (arm)

On **every ROM launch**, just before handing off to the game, the loader stamps page `$11`
(`bank_001.asm`, `Jump_001_55c2` region):

| PSRAM addr | Written | Meaning |
|---|---|---|
| `$A000` | `$AA` | Backup pending |
| `$A001` | auto-save flag | `1` = dump without prompting; else prompt |
| `$A00F` | bank count | Size of the save region to dump |
| `$A010`+ | basename | Used to build the `SAVER/<name>.SAV` filename |

The flag is armed **per launch, not per save-write**: launching a game arms it whether or not
you create a new in-game save. Consequences:

- Saving in a game and rebooting **always** shows BACKUPSAVE; launch already armed it.
- The prompt also appears after a session with no new save; the flag reflects "a game was
  launched," not "the save changed." Harmless (it re-dumps whatever is in PSRAM), and the
  source of "false positive" prompts.

### What triggers the prompt on boot

`SdMenuMain` (`00:0de4`), after `Micro SD initial OK!`, maps page `$11` and reads `$A000`:

- `[$A000] == $AA` → take the backup branch.
- anything else → jump straight to the file browser (`Jump_000_0e73` → `$0f5b`).

`$A001` is then read and passed to `BackupSavePrompt` as the auto-save selector: `1` skips the
`[B]NO`/`[A]OK` prompt and goes straight to `Saving..`; otherwise the prompt waits (A = dump,
B = skip). It also caches `$A202`→`$d3f6` (RTC) and reads the `$A00F`/`$A010`+ metadata.

### What resets the flag

The reset is `[$A000] = $00`, written **on entry to the backup branch** (`jr_000_0e76`),
*before* the prompt is drawn. The flag is cleared as soon as a pending backup is detected,
**regardless of `[A]OK` or `[B]NO`** (NO still clears it). You get the prompt once per launch,
then it's gone until the next launch re-arms it.

The clear is a single PSRAM write with the FPGA page mapped. If that write doesn't commit
(interrupted boot, marginal power, card/FPGA hiccup), `$A000` stays `$AA` and you are prompted
again next boot. The arm side (`$A000=$AA` at launch) is part of the normal launch path and
fires reliably, so arming is more consistent than clearing.

### Auto-save

The SET-menu "AUTO SAVE:" toggle drives the `$A001` value stamped at launch. Because it's
captured **at launch time**, a boot's auto-save behavior reflects the setting active when that
game was last launched. The SET-menu global feeding this stamp is not yet pinned to an address.

### Version parity

The mechanism, PSRAM addresses, and `BackupSavePrompt` exist identically in 1.04e (addresses
shifted; see `docs/DIFF_1.04e_vs_1.05e.md`). The 1.05e-only `$d3f6` cache of `$A202` is RTC
state, adjacent to this path but not part of the save-dump flag itself.

## Key symbols (1.05e)

Human names live in [re/1.05e-0731/kernel.sym](../re/1.05e-0731/kernel.sym). Block comments live in
[re/1.05e-0731/notes.json](../re/1.05e-0731/notes.json) and are injected by
`scripts/annotate-disasm.py`.

| Symbol | Bank:addr | Role |
|---|---|---|
| `KernelEntry` | `00:0150` | C runtime start |
| `BatteryCheck` | `00:1835` | Page `$11` / `$A201` dry-battery gate |
| `SdMenuMain` | `00:0de4` | SD init, BACKUPSAVE, file browser |
| `BackupSavePrompt` | `01:6747` | BACKUPSAVE box; `$A001==1` auto-dumps, else `[B]NO`/`[A]OK` |
| `SetFpgaPage_B0` | `00:1a7a` | `$7FC0` page select (bank 0) |
| `SetFpgaPage_B1` | `01:47a7` | `$7FC0` page select (bank 1) |
| `RomLoad_InitiatePoll` | `04:4000` | `$7F36=$03` ROM load path |
| `SetRomLoadCtrl_B4` | `04:4140` | `$7F36` load mode |
| `RomLoad_Build_B4` | `04:40ab` | Build ROM image from SD into FPGA buffer |

| `RomLoad_SoftReset` | `04:409c` | `$7FE0=$80` boot into loaded ROM |

## Keeping asm readable across mgbdis regen

```sh
# After updating kernel.gb or editing kernel.sym / notes.json:
cd re/1.05e-0731
mgbdis kernel.gb                    # reads kernel.sym for names
../../scripts/annotate-disasm.py 1.05e-0731   # injects ; [ezgb] comment blocks

cd disassembly && make              # byte-identical round-trip check
```

Do **not** rely on hand-edited comments inside `bank_*.asm` alone; mgbdis will wipe them.
Add names to `kernel.sym`, add prose to `notes.json`, then run the annotate script.

## Full page map & free space

The per-page layout of the whole 512 KB pSRAM (which pages the kernel uses, and
~7 KB immediately-free in page 17 plus ~344 KB of untouched pages pending a
hardware probe) is in [psram-page-map.md](psram-page-map.md).

Related: [boot-map.md](boot-map.md), [REGISTERS.md](REGISTERS.md), [launch-trace.md](launch-trace.md), [psram-page-map.md](psram-page-map.md).
