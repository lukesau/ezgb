# Naming in the kernel disassembly

Every label in the kernel disassembly has a name. This page gives the
conventions the names follow, for anyone refining one or naming another
build. Names live in `kernel/<ver>/kernel.sym` and comment blocks in
`kernel/<ver>/notes.json`; the disassembly is regenerated from them
([DEVELOPMENT.md](DEVELOPMENT.md#the-disassembly)), so a name edited in a
`bank_*.asm` file is lost.

## Reading the disassembly (`bank:addr`)

Tools print `bank:addr` (e.g. `00:27ba`), not a filename.

- **File:** bank is two hex digits; the file is `bank_` + three hex digits +
  `.asm` under `kernel/1.05e-0731/disassembly/` (`00` → `bank_000.asm`).
- **Label:** mgbdis auto-names are `Call_BBB_AAAA` / `Jump_BBB_AAAA` /
  `jr_BBB_AAAA` (`BBB` = bank in three hex, `AAAA` = address in four). `00:27ba`
  → `Call_000_27ba` / `Jump_000_27ba`. Once named in `kernel.sym` and
  regenerated, the label becomes the human name; the address still finds it:

  ```sh
  rg -n "^Call_000_27ba:|^Jump_000_27ba:" kernel/1.05e-0731/disassembly/bank_000.asm
  rg -n -A 35 "^Call_000_27ba:|^Jump_000_27ba:" kernel/1.05e-0731/disassembly/bank_000.asm  # body window
  ```

A label line ending in `:` alone is the definition; an indented `call
Call_000_27ba` is a caller, not the body.

FatFs bank-start `ret` stubs are `RetStub_B5`/`RetStub_B6`/`RetStub_B9` (`xx:4000`
before `MemCpy16_B*`).

## Naming conventions

| Kind | Style | Examples |
|---|---|---|
| Function | PascalCase verb/noun | `SdMenuMain`, `RomLoaderMain`, `DrawString` |
| Local/label in a traced path | PascalCase | `LastRomOverlay`, `HaltLoop` |
| Hardware helper | Match Omega when 1:1 | `SetFpgaPage_*` ≈ `SetRompage` |
| SDCC runtime | Short typed op | `U32Shr`, `U32Shl`, `Memcpy` |
| Unsure | Leave auto-named | keep `Call_000_27ba` |

`notes.json` block for non-obvious contracts (then `annotate-disasm.py 1.05e-0731`;
comments marked `; [ezgb]`, replaced safely on re-run):

```json
{
  "bank": 0,
  "addr": "27ba",
  "lines": [
    "One-line summary of purpose.",
    "Args / returns / important side effects.",
    "See docs/whatever.md if there is a longer trace."
  ]
}
```

If a note would run to a page, write/extend a `docs/*.md` and point the note at it.

Avoid RGBDS reserved names (`Strlen` → `CStrLen`).

### Interior labels (`Jump_`/`jr_` inside a named function)

Auto `Jump_`/`jr_` labels inside an already-named function are renamed in
`kernel.sym` too, but as qualified interior names, never bare top-level APIs:

1. **Parent prefix**: start with the enclosing function name
   (`FileBrowserEntry_…`, `DrawTimeAutosaveScreen_…`).
2. **Role suffix**: from the control-flow role (`_redraw`, `_inputLoop`,
   `_hiliteGate`); `_` not spaces, ≤ 40 chars. Example
   `09:6c59 CreateName_B9_skipLeadSep`.
3. **`jr_` vs `Jump_`**: both get sym entries; a paired suffix may end in `Jr`
   (`_hiliteJr` vs `_hiliteGate`).
4. **SDCC early-ret shape**: a `Jump_` after a `ret` inside the same parent is an
   interior path label, not a new top-level function.

The FatFs twins in other banks are byte-identical apart from bank-local
immediates, so an interior label's offset from its parent start is the same in
every twin, and their interior names were copied across on that basis.

### FatFs banks

`tools/omega-de-kernel/source/ff15/ff.c` is ChaN's FatFs R0.15 (EZ Flash's Omega
kernel ships it unmodified; only `diskio.c`/`ffsystem.c` are EZ Flash glue). The
Jr's is R0.11a ([stock README](../kernel/1.05e-0731/stock/README.md#toolchain-findings)), but the internal static functions
(`dir_find`, `dir_next`, `create_name`, `follow_path`, `create_chain`,
`clust2sect`, `get_fat`/`put_fat`, `gen_numname`, `sync_window`, `move_window`,
…) are stable across revisions; that is how the bank-09 names (`Clust2Sect_B9`,
`GetFat_B9`, `DirFind_B9`, …) were matched. **Bank 09 is canonical; 03/05/06/07
are near-identical twins**. When a role name is unclear, read the matching
`ff.c` function rather than inferring from raw Z80.

## Omega as a reference

EZ Flash published the source of the Omega's GBA kernel
([omega-de-kernel](https://github.com/ezflash-team/omega-de-kernel), cloned
to `tools/omega-de-kernel`). The Jr uses the same designs at other
addresses, so it is the reference when a Jr routine needs a name:

| Jr | Omega, under `source/` |
|---|---|
| `$7F00`/`$7F10`/`$7F20` unlock, register writes, `$7FF0` commit | `SetSDControl` and friends in `Ezcard_OP.c` |
| SD sector I/O through `$7FB0`-`$7FB4` | `Read_SD_sectors`, `Write_SD_sectors` |
| page and bank select, `$7FC0`-`$7FC4` | `SetRompage`, `SetRampage` |
| FatFs in banks 3, 5, 6, 7 and 9 | `ff15/` |
| the browser and the SET and HELP tabs (`SdMenuMain`) | `ezkernelnew.c`, `setwindow*.c`, `draw.c` |

The two differ in how a game starts. The Omega can burn a game to NOR and
boot it directly (its Mode B, `NORflash_OP.c`); the Jr loads from the SD
card into volatile pSRAM on every launch.

A wrong name is worse than an auto-generated one, because every later reader
trusts it. When unsure, leave the `Call_` label or say so in a note.
