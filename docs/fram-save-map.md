# Cart SRAM / FRAM and saves (1.05e)

How cart save RAM works on the EZ Flash Jr kernel, and where it shows up in the disassembly.
Annotations are kept in tracked files and reinjected into `bank_*.asm`.

**Hardware note:** on-cart save storage is **FRAM** — non-volatile by itself, no battery
required. The only battery-backed part of the Jr is the **RTC**. Games still *see* “battery
RAM” because the FPGA emulates a normal MBC `$A000` window; physically those writes land in
FRAM. (The kernel’s `BATTERY` / `DRY!!!` notice is about the **console** AA cells, not the
cart.)

## Two bus personalities, one FRAM chip

| Phase | CPU runs | How RAM is accessed |
|---|---|---|
| Kernel menu | `EZGB` (`kernel.gb`) | FPGA unlock/commit on `$7Fxx`; `$7FC0=$03` + `$4000`=page + `$A000`–`$BFFF` |
| Launched game | Loaded `.gb` ROM | Normal MBC only (`$2000`–`$5FFF`, `$A000`–`$BFFF`); **no** `$7Fxx` commands |
| Next kernel boot | `EZGB` again | Kernel reads page `$11` meta; optional FRAM → `SAVER/` on SD |

The game does not talk to FPGA command registers while saving. The FPGA emulates the
game's MBC and maps `$A000` writes into the **same** physical FRAM the kernel used
from the menu.

SameBoy stub mirrors this: `mbc_ram` aliases `cart_sram` after `$7FE0` soft-reset.

## Save lifecycle

1. **In-game** — MBC “battery RAM” writes land in FRAM only (no host power needed to retain).
2. **Before launch** — kernel stamps page `$11` (`$AA` = pending backup, savename, bank count).
3. **After power-up** — if `$AA` still set, `SdMenuMain` offers **BACKUPSAVE** and copies FRAM to `SAVER/*.SAV` on the SD image.

Details for the emulator workflow: [sd/README.md](../sd/README.md).

## BACKUPSAVE flag lifecycle

The whole feature turns on one byte in FRAM, page `$11` (bank 17), address **`$A000`**,
reachable only from the kernel via `SetFpgaPage_B1`/`_B0` with `$7FC0=$03`. The prompt shown
on boot (`BACKUPSAVE` / `Saving..` / `[B]NO` `[A]OK`) is `BackupSavePrompt` at `01:6747`.

### What sets the flag (arm)

On **every ROM launch**, just before handing off to the game, the loader stamps page `$11`
(`bank_001.asm`, `Jump_001_55c2` region):

| FRAM addr | Written | Meaning |
|---|---|---|
| `$A000` | `$AA` | Backup pending |
| `$A001` | auto-save flag | `1` = dump without prompting; else prompt |
| `$A00F` | bank count | Size of the save region to dump |
| `$A010`+ | basename | Used to build the `SAVER/<name>.SAV` filename |

Key consequence: the flag is armed **per launch, not per save-write**. Launching a game arms
it whether or not you actually create a new in-game save. That's why:

- Saving in a game and rebooting **always** shows BACKUPSAVE (launch already armed it — you
  never "miss" the chance to dump). Consistent, as observed.
- You can also get the prompt after a session where you **didn't** make a new save — the flag
  reflects "a game was launched," not "the save changed." Harmless (it just re-dumps whatever
  is in FRAM), but it's the source of the "false positive" prompts.

### What triggers the prompt on boot

`SdMenuMain` (`00:0de4`), after `Micro SD initial OK!`, maps page `$11` and reads `$A000`:

- `[$A000] == $AA` → take the backup branch.
- anything else → jump straight to the file browser (`Jump_000_0e73` → `$0f5b`).

`$A001` is then read and passed to `BackupSavePrompt` as the auto-save selector: `1` skips the
`[B]NO`/`[A]OK` prompt and goes straight to `Saving..`; otherwise the prompt waits (A = dump,
B = skip). It also caches `$A202`→`$d3f6` (RTC) and reads the `$A00F`/`$A010`+ metadata.

### What resets the flag

The reset is `[$A000] = $00`, written **on entry to the backup branch** (`jr_000_0e76`),
*before* the prompt is drawn. So the flag is cleared as soon as a pending backup is detected —
**regardless of whether you pick `[A]OK` or `[B]NO`**. Choosing NO still clears it; you get the
prompt once per launch, then it's gone until the next launch re-arms it.

Practical caveat (matches the "seems inconsistent" observation): the clear is a single FRAM
write with the FPGA page mapped. If that write doesn't commit (interrupted boot, marginal
power, a card/FPGA hiccup), `$A000` can stay `$AA` and you'll be prompted again next boot. The
arm side (`$A000=$AA` at launch) is a normal part of the launch path and fires reliably, which
is why arming feels far more consistent than clearing.

### Auto-save

The SET-menu "AUTO SAVE:" toggle drives the `$A001` value stamped at launch. Because it's
captured **at launch time**, a given boot's auto-save behavior reflects the setting that was
active when that game was last launched. (The SET-menu global that feeds this stamp is not yet
pinned to a specific address.)

### Version parity

The mechanism, FRAM addresses, and `BackupSavePrompt` exist identically in 1.04e (addresses
shifted; see `docs/DIFF_1.04e_vs_1.05e.md`). The 1.05e-only `$d3f6` cache of `$A202` is RTC
state, adjacent to this path but not part of the save-dump flag itself.

## Key symbols (1.05e)

Human names live in [re/1.05e/kernel.sym](../re/1.05e/kernel.sym). Block comments live in
[re/1.05e/notes.json](../re/1.05e/notes.json) and are injected by
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
cd re/1.05e
mgbdis kernel.gb                    # reads kernel.sym for names
../../scripts/annotate-disasm.py 1.05e   # injects ; [ezgb] comment blocks

cd disassembly && make              # byte-identical round-trip check
```

Do **not** rely on hand-edited comments inside `bank_*.asm` alone — mgbdis will wipe them.
Add names to `kernel.sym`, add prose to `notes.json`, then run the annotate script.

Related: [boot-map.md](boot-map.md), [REGISTERS.md](REGISTERS.md), [launch-trace.md](launch-trace.md).
