# Mapping workflow (pret-style, for this repo)

**Start here for the hands-on loop:** [`MAP-SESSION.md`](MAP-SESSION.md)
(pick → open → classify → prove → name → note → regen → done).

How to systematically turn `Call_`/`Jump_` noise into named, annotated understanding.
Modeled on how [pret](https://pret.github.io/) runs Game Boy disassemblies (pokered /
pokecrystal / …), adapted to our mgbdis + `kernel.sym` + `notes.json` setup.

**Priority:** naming and documenting ASM beats decomp and B-mode work for now
([`omega-jr-compare.md`](omega-jr-compare.md)).

## What pret actually does (the useful bits)

Pret projects are not “read the whole ROM top to bottom.” They are **incremental,
evidence-driven labeling** with a hard rule: the tree must keep **rebuilding
byte-identical** to the original.

Common habits:

1. **Pick a seam, not a bank.** One UI action, one IRQ, one SD helper — follow it
   until the subgraph is named.
2. **Name high fan-in first.** A leaf called 50 times renames 50 call sites.
3. **Static + dynamic.** Strings and call graphs offline; breakpoints and WRAM
   dumps in an emulator with a `.sym` loaded.
4. **Name only what you can defend.** Prefer `DrawString` over `MaybePrintStuff`.
   Tentative names get a comment (`; TODO: confirm`) or stay auto-named.
5. **Separate “what” from “why.”** Label = what it does. Longer prose goes in
   comments / docs, not in a 40-character symbol.
6. **RAM and constants get names too.** Once `$D732` is “text cursor X”, every
   store becomes readable. Magic bytes → named constants when repeated.
7. **One subsystem at a time.** pret slices (battle, map, menu). We slice
   (boot, SD/FS, browser, loader, FRAM/RTC, draw).
8. **Cross-reference a sibling.** pret compares Red↔Yellow↔Crystal. We compare
   Jr↔Omega DE source + live UX ([`omega-jr-compare.md`](omega-jr-compare.md)).
9. **Decomp is optional and late.** pret’s GB games stayed ASM for years.
   Matching C (`decomp/`) here is a side track after names exist
   ([`PROGRESS.md`](PROGRESS.md)).

Finding work: pret greps `Func_` / `Unknown` / `asm_`. We use the scripts below.

## Source of truth in *this* repo

Do **not** treat hand-edited names inside `bank_*.asm` as permanent. Regen wipes
them. Persist through:

| Artifact | Role |
|---|---|
| `re/1.05e/kernel.sym` | Human symbol names (`bank:addr Name`) — mgbdis applies these |
| `re/1.05e/notes.json` | Multi-line `; [ezgb]` comment blocks at labels |
| `docs/*.md` | Traces, hardware maps, subsystem writeups |
| `decomp/` | Byte-matched C (optional, later) |

Regen loop (after adding sym names):

```sh
./scripts/regen-disasm.sh 1.05e    # mgbdis → annotate → make → progress → worklist
# quiet by default; pass -v for full logs
```

`make` must stay green (byte-identical aside from known header cosmetics).
`--overwrite` is required when `disassembly/` already exists; without it mgbdis
refuses to rewrite the bank files. `annotate-disasm.py` also emits `wram.inc`
for any `kernel.sym` entries with CPU addr ≥ `$C000` (mgbdis rewrites
`[wGfxMode]` but does not define those labels itself).

## Agent vs cron (token-cheap)

| Pass | Who | What |
|---|---|---|
| Session | Human or agent | `map-next.sh` — progress + proposals + worklist + packet |
| Deterministic | `label-cron.sh` (timer, no LLM) | `stamp-bank-clones` → `propose-labels --apply` → `regen-disasm` → `label-packet` |
| Judgment | Human or agent (cron / packet exit 2 / `needs_judgment: 1`) | Ambiguous WRAM, UI/control flow; apply or reject proposals — **do not re-explore** |

```sh
./scripts/map-next.sh                  # human default: progress + proposals + packet
./scripts/label-cron.sh 1.05e          # exit 2 = needs judgment
./scripts/label-packet.py 1.05e --app --frontier-only --top 5
./scripts/propose-labels.py 1.05e      # dry-run; --apply to stamp
./scripts/regen-disasm.sh 1.05e
```

Mechanical proposals: IRQ callback wrappers (`ld hl,$Dxxx` / `jp Install|RemoveCallbackSlot`),
`FarCallTrampoline` 4-byte thunks, `SetFpga*` unlock shapes, bank clones.

## Daily / session loop

```text
┌─ packet / proposals ──► apply|reject|judge ──► regen ──┐
│                                                         │
└──────────── naming-progress / SameBoy if needed ────────┘
```

### 1. Build a worklist

```sh
./scripts/map-next.sh                  # preferred: progress + proposals + packet
./scripts/naming-progress.sh 1.05e
./scripts/label-packet.py 1.05e --app --frontier-only --top 5
./scripts/doc-symbol-coverage.py --app --frontier-only --top 5
# full ranking dump (lib banks, no body context):
./scripts/doc-symbol-coverage.py --top 25
```

Good next targets, in order:

1. `map-next` / packet (`F` = callee of a named fn; `O` = unlabeled
   prologue after `ret`; `J` = entry-like `Jump_`)
2. Callees of something you already named (grow the frontier)
3. Code next to a unique string you can trigger in the UI
4. Omega analogue you just watched on hardware ([`omega-jr-compare.md`](omega-jr-compare.md))

Avoid: random mid-bank label with fan-in 1 and no string/UI hook; re-grepping
what `map-next` / `label-packet.py` already printed. `--top 25` alone is a rank
dump — it does not include body, callers, or WRAM context.

### 2. Understand before renaming

**Read the body first.** Many top fan-in hits are tiny SDCC runtime leaves
(32-bit `<<`/`>>`, mul/div, memcpy). Those are named from the instruction loop
alone — **do not** open SameBoy for them. Example: `$298f` / `$29c9` /
`$29ac` are `U32Shr` / `U32Shl` / `S32Sar` (stack args: ulong + shift count).

SameBoy is for **ambiguous** functions (UI, SD, FPGA): you need live WRAM /
`$7Fxx` / which button got you there. Even then, prefer **break + dump +
continue**, not single-stepping thousands of instructions:

```sh
# one-shot: break, dump regs/WRAM, continue (see scripts/debug/)
./scripts/run-sameboy-debug.sh --trace --script scripts/debug/your.sbd
```

Put `breakpoint $ADDR` and a small dump list in an `.sbd`; `--trace` runs
`dump-launch.sbd` (or `--dump`) on every hit then `continue`. You get a log,
not a workout on the `c` key.

Minimum bar for a name:

- [ ] Know callers (grep the `Call_xxx` / address)
- [ ] Know what it reads/writes (regs, WRAM, `$7Fxx`, FRAM)
- [ ] Pure leaf proven from the body, **or** one live way to hit it

Tools:

```sh
# static — always first
rg -n "Call_000_27ba|27ba" re/1.05e/disassembly/
# read ~30 lines at the label; if it's a shift/mul loop, you're done

# live only when static is ambiguous
./scripts/run-sameboy-debug.sh --trace
```

Omega assist: reproduce the same menu action on Omega, skim the matching
`tools/omega-de-kernel/source/*.c` symbol, then hunt the Jr twin.

### 3. Rename (`kernel.sym`)

Add a line (bank hex, address hex, PascalCase or clear verb phrase):

```text
00:27ba SomeDescriptiveName
```

Conventions (pret-flavored, used here already):

| Kind | Style | Examples |
|---|---|---|
| Function | PascalCase verb/noun | `SdMenuMain`, `RomLoaderMain`, `DrawString` |
| Local/label inside a traced path | PascalCase | `LastRomOverlay`, `HaltLoop` |
| Hardware helper | Match Omega when 1:1 | `SetFpgaPage_*` ≈ `SetRompage` |
| SDCC runtime | Short typed op | `U32Shr`, `U32Shl`, `Memcpy` |
| Unsure | Leave auto-named | keep `Call_000_27ba` |

After editing `kernel.sym`, run the regen loop above so every bank file picks up
the label.

### 4. Annotate (`notes.json`)

Names are not enough for non-obvious contracts. Add a block:

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

Then `./scripts/annotate-disasm.py 1.05e`. Comments are marked `; [ezgb]` and
replaced safely on re-run.

### 5. Document the subsystem (when the slice is big enough)

If you just mapped a whole feature (last-ROM, BACKUPSAVE, launch chain), give it
a short `docs/*.md` (or extend an existing one) so the next session does not
re-derive it. Link addresses by **name** once named; keep raw addresses in
tables for searchability.

### 6. Verify

```sh
./scripts/regen-disasm.sh 1.05e
./scripts/map-next.sh
```

Optional: SameBoy break on the new label and confirm the UX path you claimed.

## Suggested subsystem order (Jr)

Work top-down along paths you already care about; fill fan-in leaves as you go.

| Order | Slice | Already started | Docs |
|---|---|---|---|
| 1 | Boot / IRQ / LCD helpers | mostly named | [`boot-map.md`](boot-map.md) |
| 2 | Draw / text primitives | `DrawString`, cursors | — |
| 3 | Joypad | `ReadJoypad*` | [`launch-trace.md`](launch-trace.md) |
| 4 | SD / FatFs-shaped FS | `DirList`, `SdMenuMain` | [`ezgb-dat-boot.md`](ezgb-dat-boot.md) |
| 5 | File browser / menus | partial | [`last-rom.md`](last-rom.md) |
| 6 | ROM load / FPGA handoff | `RomLoaderMain`, `RomLoad_*` | [`launch-trace.md`](launch-trace.md), [`REGISTERS.md`](REGISTERS.md) |
| 7 | FRAM / saves / RTC | partial | [`fram-save-map.md`](fram-save-map.md) |
| 8 | Settings / HELP / misc UI | mostly unnamed | Omega `setwindow*.c` |
| 9 | Matching decomp leaves | optional | [`PROGRESS.md`](PROGRESS.md) |

## Confidence and honesty

| Level | What to do |
|---|---|
| Confirmed live | Name + short note; cite SameBoy or hardware |
| Strong static | Name OK; note “static only” if risky |
| Educated guess | Comment only, or `LikelyFoo` + TODO — or leave unnamed |
| String-adjacent only | Name the draw/print helper; don’t invent the whole screen FSM yet |

Wrong names are worse than `Call_` — they poison every future read. pret is
conservative for the same reason.

## Anti-patterns

- Opening SameBoy to single-step a 15-instruction shift/mul helper
- Renaming 200 labels in one sitting with weak evidence
- Hand-editing `bank_*.asm` labels without `kernel.sym` (lost on mgbdis regen)
- Writing matching C before the ASM for that function is named and understood
- Chasing B-mode / patches before the load + SD frontier is mapped
- Copying Omega names onto Jr code that only *looks* similar — note the
  uncertainty if not proven

## Quick reference

```sh
# human default (progress + proposals + worklist + packet)
./scripts/map-next.sh
./scripts/map-next.sh --top 10

# pieces
./scripts/naming-progress.sh 1.05e
./scripts/label-packet.py 1.05e --app --frontier-only --top 5
./scripts/doc-symbol-coverage.py --app --frontier-only --top 5
# rank dump only (incl. lib banks, no body):
./scripts/doc-symbol-coverage.py --top 25

# mechanical + regen
./scripts/label-cron.sh 1.05e
./scripts/propose-labels.py 1.05e --apply
./scripts/regen-disasm.sh 1.05e

# live
./scripts/run-sameboy-debug.sh
```

pret’s broader tooling lives in `tools/gb-asm-tools` ([upstream](https://github.com/pret/gb-asm-tools));
we wrap `unnamed.py` and `gbdiff.sh` already. Their Discord (`pret`, #pokered /
#pokecrystal) is the cultural source for “how picky to be about names.”
