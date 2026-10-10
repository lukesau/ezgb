# Cart SRAM / PSRAM and saves (1.05e)

How cart save RAM works on the EZ Flash Jr kernel, and where it shows up in the disassembly.
Annotations are kept in tracked files and reinjected into `bank_*.asm`.

On-cart save storage is battery-backed **PSRAM**. Games *see* "battery RAM" because the FPGA
emulates a normal MBC `$A000` window; those writes physically land in PSRAM kept alive by the
coin cell. The coin cell backs **both saves and the RTC**, so a dead cell loses both (the
well-known "EZ Flash Jr battery dies in a month" complaints). The save/settings pSRAM is the
**512 KB pSRAM die inside U4** (the `S71GL032A40` MCP, datasheet-confirmed and an exact match
for the 64-page / 512 KB map); the *game* ROM lives in a separate, larger pSRAM in U9. Chip
detail: [hardware-board.md](hardware-board.md). The kernel's `BATTERY` / `DRY!!!` notice is
about **this** cell: `BatteryCheck` (`00:1835`) reads a canary byte at page `$11` `$A201`
(expect `$88`) and re-stamps it after the prompt, so it fires exactly when the pSRAM (and
the RTC, on the same cell) lost power. It never reads the RTC chip's own voltage-low flag.
The RTC backup feature ([ezgb-cfg.md](ezgb-cfg.md)) hooks that re-stamp.

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

Details for the emulator workflow: [DEVELOPMENT.md](DEVELOPMENT.md).

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
| `$A001` | bank count | Size of the save region to dump, in 8 KB banks (4 for a 32 KB save) |
| `$A00F` | name length | Bytes of the save path at `$A010` |
| `$A010`+ | save path | ASCII, e.g. `/SAVER/PKMRED.sav`, used as the dump's filename |

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

`BackupBranchEntry` (`00:0e76`) reads the AUTO SAVE flag `$A200` (kept in C), caches
`$A202`→`$d3f6` (RTC), keeps `$A001` (the bank count), clears `$A000`, and copies `$A00F` bytes
of the path at `$A010` to `$c3a5`. `BackupSavePrompt` gets the bank count as the dump size and
`$A200` as the auto-save selector: `1` skips the `[B]NO`/`[A]OK` prompt and goes straight to
`Saving..`; otherwise the prompt waits (A = dump, B = skip).

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

The SET-menu "AUTO SAVE:" toggle writes `$A200` directly (`DrawTimeAutosaveScreen`, `04:58d6`:
`$4000=$11`, `$7FC0=$03`, `[$A200]` = 0 or 1). The boot branch reads it at the next boot, so
the setting in effect then decides, not the one when the game was launched.

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
| `BackupSavePrompt` | `01:6747` | BACKUPSAVE box; `$A200==1` auto-dumps, else `[B]NO`/`[A]OK` |
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
~7 KB free in page 17 at `$A400`+; every page from `$12` up is browser record
space that grows with directory size) is in [psram-page-map.md](psram-page-map.md).

## Compared with daid/ezflashjr

[daid/ezflashjr](https://github.com/daid/ezflashjr) `doc/Protocol.md` ("SRAM"
section) lists the page `$11` fields too. Checked against the 1.04e/1.05e code
and a pSRAM dump (2026-10-08):

| Field | Protocol.md | Here |
|---|---|---|
| `$A000` | `$AA` = save to back up | agrees |
| `$A001` | save size in SRAM banks | agrees. This repo's docs and disassembly notes called it the auto-save flag and `$A00F` the bank count until 2026-10-08; the launch stamp (`01:55c2` region) and `BackupBranchEntry` show `$A001` is the size passed to the dump and `$A00F` is the copy length of the path |
| `$A00F` | length of the save file name | agrees |
| `$A010`+ | save file name, **in `wchar_t`** | **one byte per character** (ASCII, e.g. `/SAVER/PKMRED.sav`): the launch stamp copies `$A00F` bytes from the ASCII path buffer at `$c3a5`, and the boot branch copies them back the same way |
| `$A200` | auto-save flag | agrees (written by the SET toggle at `04:58d6`, read into C by `BackupBranchEntry`) |
| `$A201` | `$88` = cart initialized, else "Battery dry" | agrees (`BatteryCheck`, `00:1835`) |
| `$A300`+ | last loaded ROM, **in `wchar_t`** | **one byte per character**: `LastRomPersist` (`01:4856`) copies 255 bytes (`$00`..`$FE`), and the dump holds `/PKMRED.GB` as plain ASCII, NUL-terminated ([last-rom.md](last-rom.md)) |
| `$12`+ | extra RAM, mostly the file list cache | agrees ([psram-page-map.md](psram-page-map.md)) |

The `wchar_t` difference matters for free space: as ASCII the last-ROM record
ends at `$A3FE`, so `$A400`+ is free (the SGB BOOT record lives there,
[sgb-boot.md](sgb-boot.md)); as `wchar_t` a 255-character path would run to
`$A4FD`. Protocol.md may describe an older kernel (its notes predate 1.04e);
the 1.04e and 1.05e builds are single-byte throughout.

Related: [boot-map.md](boot-map.md), [REGISTERS.md](REGISTERS.md), [launch-trace.md](launch-trace.md), [psram-page-map.md](psram-page-map.md).
