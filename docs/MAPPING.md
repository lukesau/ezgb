# Mapping workflow (pret-style, for this repo)

How this repo turned `Call_`/`Jump_` noise into named, annotated understanding,
modeled on [pret](https://pret.github.io/) Game Boy disassemblies (pokered /
pokecrystal / …) adapted to our mgbdis + `kernel.sym` + `notes.json` setup. The
disassembly is now fully labeled; this is the durable methodology reference.

## What pret does (the useful bits)

Incremental, evidence-driven labeling with a hard rule: the tree keeps
rebuilding byte-identical to the original.

1. **Pick a seam, not a bank.** One UI action, one IRQ, one SD helper: follow
   it until the subgraph is named.
2. **Name high fan-in first.** A leaf called 50 times renames 50 call sites.
3. **Static + dynamic.** Strings and call graphs offline; breakpoints and WRAM
   dumps in an emulator with a `.sym` loaded.
4. **Name only what you can defend.** Prefer `DrawString` over `MaybePrintStuff`.
   Tentative names get `; TODO: confirm` or stay auto-named.
5. **Separate "what" from "why."** Label = what it does. Prose goes in comments /
   docs, not a 40-character symbol.
6. **RAM and constants get names too.** Once `$D732` is "text cursor X", every
   store becomes readable. Repeated magic bytes → named constants.
7. **One subsystem at a time.** pret slices battle/map/menu; we slice boot,
   SD/FS, browser, loader, PSRAM/RTC, draw.
8. **Cross-reference a sibling.** pret compares Red↔Yellow↔Crystal; we compare
   Jr↔Omega DE source + live UX ([`omega-jr-compare.md`](omega-jr-compare.md)).
9. **Decomp is optional and late.** Matching C (`decomp/`) is a side track after
   names exist ([`PROGRESS.md`](PROGRESS.md)).

## Source of truth in this repo

Hand-edited names inside `bank_*.asm` are not permanent; regen wipes them.
Persist through:

| Artifact | Role |
|---|---|
| `re/1.05e/kernel.sym` | Human symbol names (`bank:addr Name`); mgbdis applies these |
| `re/1.05e/notes.json` | Multi-line `; [ezgb]` comment blocks at labels |
| `docs/*.md` | Traces, hardware maps, subsystem writeups |
| `decomp/` | Byte-matched C (optional, later) |

Regen after adding sym names (details in [`DEVELOPMENT.md`](DEVELOPMENT.md)):

```sh
./scripts/regen-disasm.sh 1.05e    # mgbdis → annotate → make → progress → worklist
```

`make` must stay green (byte-identical aside from known header cosmetics).

## Reading the disassembly (`bank:addr`)

Tools print `bank:addr` (e.g. `00:27ba`), not a filename.

- **File:** bank is two hex digits; the file is `bank_` + three hex digits +
  `.asm` under `re/1.05e/disassembly/` (`00` → `bank_000.asm`).
- **Label:** mgbdis auto-names are `Call_BBB_AAAA` / `Jump_BBB_AAAA` /
  `jr_BBB_AAAA` (`BBB` = bank in three hex, `AAAA` = address in four). `00:27ba`
  → `Call_000_27ba` / `Jump_000_27ba`. Once named in `kernel.sym` and
  regenerated, the label becomes the human name; the address still finds it:

  ```sh
  rg -n "^Call_000_27ba:|^Jump_000_27ba:" re/1.05e/disassembly/bank_000.asm
  rg -n -A 35 "^Call_000_27ba:|^Jump_000_27ba:" re/1.05e/disassembly/bank_000.asm  # body window
  ```

A label line ending in `:` alone is the definition; an indented `call
Call_000_27ba` is a caller, not the body.

Worklist marks (from `map-next.sh` / `doc-symbol-coverage.py`): `F` = frontier
(unnamed callee of a named function); `O` = orphan (unlabeled `add sp,-$…` body
after a `ret`); `J` = `Jump_` after a `ret` with a prologue (a real entry, not a
loop head); `D` = interior debt (a named function still holding auto
`Jump_`/`jr_` labels). `naming-progress.sh` is notes-adjusted: `Jump_`/`jr_`
cited in `notes.json` count as named (raw mgbdis count in brackets). FatFs
bank-start `ret` stubs are `RetStub_B5`/`RetStub_B6`/`RetStub_B9` (`xx:4000`
before `MemCpy16_B*`).

## Agent vs mechanical (token-cheap)

| Pass | Who | What |
|---|---|---|
| Session | Human or agent | `map-next.sh`: progress + proposals + worklist + packet |
| Mechanical | `propose-labels.py --apply` (+ regen) | IRQ wrappers / farcalls / FPGA shapes / bank clones |
| Judgment | Human or agent (`needs_judgment: 1`) | Ambiguous WRAM, UI/control flow; apply or reject (**do not re-explore**) |

Mechanical proposals: IRQ callback wrappers (`ld hl,$Dxxx` / `jp
Install|RemoveCallbackSlot`), `FarCallTrampoline` 4-byte thunks, `SetFpga*`
unlock shapes, bank clones.

## Understand before renaming

Many top fan-in hits are tiny SDCC runtime leaves (32-bit `<<`/`>>`, mul/div,
memcpy), named from the instruction loop alone; do not open SameBoy for them.
Example: `$298f` / `$29c9` / `$29ac` are `U32Shr` / `U32Shl` / `S32Sar` (stack
args: ulong + shift count). SameBoy is for **ambiguous** functions (UI, SD,
FPGA); even then prefer break + dump + continue over single-stepping.

Minimum bar for a name:

- [ ] Know callers (grep the `Call_xxx` / address)
- [ ] Know what it reads/writes (regs, WRAM, `$7Fxx`, PSRAM)
- [ ] Pure leaf proven from the body, **or** one live way to hit it

## Naming conventions

| Kind | Style | Examples |
|---|---|---|
| Function | PascalCase verb/noun | `SdMenuMain`, `RomLoaderMain`, `DrawString` |
| Local/label in a traced path | PascalCase | `LastRomOverlay`, `HaltLoop` |
| Hardware helper | Match Omega when 1:1 | `SetFpgaPage_*` ≈ `SetRompage` |
| SDCC runtime | Short typed op | `U32Shr`, `U32Shl`, `Memcpy` |
| Unsure | Leave auto-named | keep `Call_000_27ba` |

`notes.json` block for non-obvious contracts (then `annotate-disasm.py 1.05e`;
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

`propagate-interior-clones.py` stamps the FatFs bank twins: since
`stamp-bank-clones.py` proved those functions byte-identical across banks
(modulo bank-local immediates), an interior label's offset from its parent start
is identical in every twin. It verifies a live auto label at each computed
address before stamping, so a divergent twin is skipped, not guessed.

### FatFs banks

`tools/omega-de-kernel/source/ff15/ff.c` is ChaN's FatFs R0.15 (EZ Flash's Omega
kernel ships it unmodified; only `diskio.c`/`ffsystem.c` are EZ Flash glue). The
Jr's build predates that revision, but the internal static functions
(`dir_find`, `dir_next`, `create_name`, `follow_path`, `create_chain`,
`clust2sect`, `get_fat`/`put_fat`, `gen_numname`, `sync_window`, `move_window`,
…) are stable across revisions; that is how the bank-09 names (`Clust2Sect_B9`,
`GetFat_B9`, `DirFind_B9`, …) were matched. **Bank 09 is canonical; 03/05/06/07
are near-identical twins** (`stamp-bank-clones.py` /
`propagate-interior-clones.py`). When a role name is unclear, read the matching
`ff.c` function rather than inferring from raw Z80.

## Suggested subsystem order (Jr)

Work top-down along paths you care about; fill fan-in leaves as you go.

| Order | Slice | Docs |
|---|---|---|
| 1 | Boot / IRQ / LCD helpers | [`boot-map.md`](boot-map.md) |
| 2 | Draw / text primitives | n/a |
| 3 | Joypad | [`launch-trace.md`](launch-trace.md) |
| 4 | SD / FatFs-shaped FS | [`ezgb-dat-boot.md`](ezgb-dat-boot.md) |
| 5 | File browser / menus | [`last-rom.md`](last-rom.md) |
| 6 | ROM load / FPGA handoff | [`launch-trace.md`](launch-trace.md), [`REGISTERS.md`](REGISTERS.md) |
| 7 | PSRAM / saves / RTC | [`psram-save-map.md`](psram-save-map.md) |
| 8 | Settings / HELP / misc UI | Omega `setwindow*.c` |
| 9 | Matching decomp leaves | [`PROGRESS.md`](PROGRESS.md) |

## Confidence and honesty

| Level | What to do |
|---|---|
| Confirmed live | Name + short note; cite SameBoy or hardware |
| Strong static | Name OK; note "static only" if risky |
| Educated guess | Comment only, or `LikelyFoo` + TODO, or leave unnamed |
| String-adjacent only | Name the draw/print helper; don't invent the whole screen FSM |

Wrong names are worse than `Call_`: they poison every future read.

## Anti-patterns

- Opening SameBoy to single-step a 15-instruction shift/mul helper
- Renaming 200 labels in one sitting with weak evidence
- Hand-editing `bank_*.asm` labels without `kernel.sym` (lost on mgbdis regen)
- Writing matching C before the ASM for that function is named and understood
- Copying Omega names onto Jr code that only *looks* similar; note the
  uncertainty if not proven

## Quick reference

```sh
./scripts/map-next.sh [--top 10]                              # progress + proposals + worklist + packet
./scripts/naming-progress.sh 1.05e
./scripts/label-packet.py 1.05e --app --frontier-only --top 5
./scripts/doc-symbol-coverage.py --app --frontier-only --top 5
./scripts/doc-symbol-coverage.py --top 25                     # rank dump incl. lib banks, no body
./scripts/propose-labels.py 1.05e --apply                     # mechanical, then regen
./scripts/regen-disasm.sh 1.05e
./scripts/run-sameboy-debug.sh --breakpoints                  # live
```

pret's broader tooling lives in `tools/gb-asm-tools`
([upstream](https://github.com/pret/gb-asm-tools)); we wrap `unnamed.py` and
`gbdiff.sh`. Their Discord (`pret`, #pokered / #pokecrystal) is the cultural
source for how picky to be about names.
