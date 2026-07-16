# Cart SRAM / FRAM and saves (1.05e)

How battery-backed save RAM works on the EZ Flash Jr kernel, and where it shows up in
the disassembly. Annotations are kept in tracked files and reinjected into `bank_*.asm`.

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

1. **In-game** — MBC battery RAM writes land in FRAM only.
2. **Before launch** — kernel stamps page `$11` (`$AA` = pending backup, savename, bank count).
3. **After power-up** — if `$AA` still set, `SdMenuMain` offers **BACKUPSAVE** and copies FRAM to `SAVER/*.SAV` on the SD image.

Details for the emulator workflow: [sd/README.md](../sd/README.md).

## Key symbols (1.05e)

Human names live in [re/1.05e/kernel.sym](../re/1.05e/kernel.sym). Block comments live in
[re/1.05e/notes.json](../re/1.05e/notes.json) and are injected by
`scripts/annotate-disasm.py`.

| Symbol | Bank:addr | Role |
|---|---|---|
| `KernelEntry` | `00:0150` | C runtime start |
| `BatteryCheck` | `00:1835` | Page `$11` / `$A201` dry-battery gate |
| `SdMenuMain` | `00:0de4` | SD init, BACKUPSAVE, file browser |
| `SetFpgaPage_B0` | `00:1a7a` | `$7FC0` page select (bank 0) |
| `SetFpgaPage_B1` | `01:47a7` | `$7FC0` page select (bank 1) |
| `RomLoad_InitiatePoll` | `04:4000` | `$7F36=$03` ROM load path |
| `SetRomLoadCtrl` | `04:4140` | `$7F36` load mode |
| `RomLoad_Build` | `04:40ab` | Build ROM image from SD into FPGA buffer |

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
