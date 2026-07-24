# Interior naming — loop prompt (phase 2)

Use this after the **notes-only CF pass** is done (`notes.json` cites every
`Jump_`/`jr_` inside named functions). This phase renames those interior labels
in `kernel.sym` so asm reads cleanly and D (interior-debt) rows shrink.

Hands-on checklist: [`MAP-SESSION.md`](MAP-SESSION.md). Philosophy:
[`MAPPING.md`](MAPPING.md).

---

## Copy-paste loop prompt (fresh chat)

```text
/loop 3m ezgb interior-name tick (FatFs / lib banks)

You are continuing ezgb 1.05e reverse-engineering — INTERIOR NAMING phase (not notes).
App-bank interior work is 100% done (map-interior.sh app-scope is interior_complete: 1).
All remaining interior debt is FatFs library code on banks 03/05/06/07/09.

Goal: name auto Jump_/jr_ labels inside already-named FatFs functions by adding
entries to re/1.05e/kernel.sym, then regen. notes.json CF is already substantially
written for these parents (matched against real FatFs source) — use it as the
naming guide, do not rewrite CF unless fixing an error you can prove.

Ground truth: tools/omega-de-kernel/source/ff15/ff.c is ChaN's FatFs R0.15
(EZ Flash's own Omega kernel ships it unmodified). The Jr's FatFs predates this
exact revision but the internal static function names/shapes (dir_find, dir_next,
create_name, follow_path, create_chain, clust2sect, get_fat/put_fat, gen_numname,
sync_window, move_window, ...) are stable across FatFs revisions — that's how the
existing top-level bank-09 names were matched. When a role name is unclear from
the notes CF alone, open the matching function in ff.c before guessing from raw asm.

Each tick:
1. Run: ./scripts/map-interior.sh --include-lib --skip-complete --top 5
   (prefer bank 09 rows first — canonical; 03/05/06/07 twins get covered by
   stamp-bank-clones.py once 09 is named, so don't hand-duplicate that work)
2. Read the packet — TARGET, NOTES CF, UNNAMED INTERIOR LABELS. Cross-check the
   matching ff.c function (search its name, e.g. "static FRESULT dir_find") when
   a label's role isn't obvious from the CF note.
3. Pick the top TARGET parent function. Name its listed interior labels:
   - Format: bank:addr ParentFn_descriptiveSuffix
   - Example: 09:6c59 CreateName_B9_skipLeadSep
   - Qualified names only — NOT top-level APIs (no bare SkipLeadSep).
   - Avoid RGBDS reserved names (Strlen → CStrLen, etc.).
   - Derive suffixes from the notes CF line, verified against ff.c control flow.
4. If a D-row parent has thin/missing CF notes (rare — most already have them),
   write real notes.json CF from ff.c first, then name from that.
5. Apply names either:
   - Edit kernel.sym directly (surgical adds under a ; Interior labels comment), OR
   - Write a batch file and: ./scripts/map-interior.sh 1.05e --apply names.txt
6. Regen: ./scripts/regen-disasm.sh 1.05e (map-interior --apply does this)
7. If you just finished a bank-09 (canonical) parent, immediately run:
   ./scripts/propagate-interior-clones.py 1.05e --base <ParentBaseName> --apply
   then regen again — this stamps 03/05/06/07's copies of the same labels for
   free. Do NOT hand-name the 03/05/06/07 twins yourself; that's redundant
   work the propagate script does mechanically and more reliably.
8. Verify: D count for that parent (and its twins) drops; Jump_/jr_ become
   human names in asm; ./scripts/naming-progress.sh should show the adjusted
   % moving now.
9. Delete the batch .txt after a successful apply (do not leave interior-batch-tick*.txt around).

Scope per tick:
- One parent function per tick (all labels shown, up to --max-labels 40).
- Huge functions (e.g. CreateName_B9 ~92 labels) take multiple ticks; keep
  working the same parent until unnamed=0, then regen.
- Bank 09 first; let stamp-bank-clones.py propagate to 03/05/06/07.

Stop when:
- map-interior.sh --include-lib exits 2 (interior_complete: 1), OR
- worklist empty after regen.

Do NOT:
- Re-derive CF from scratch when notes.json already has it — verify against
  ff.c, don't discard working notes.
- Name interior labels as if they were call targets / public APIs.
- Hunt off-packet or pick random addresses.
- Commit unless asked.

Brief tick summary: parent name, labels named this tick, remaining count, regen y/n.
```

---

## Tooling

| Script | Role |
|---|---|
| `./scripts/map-interior.sh` | Progress + interior worklist + packet + next steps |
| `./scripts/interior-packet.py` | Worklist, unnamed label table, `--apply` batch sym writes |
| `./scripts/propagate-interior-clones.py` | FatFs-only: once one bank's interior labels are named, compute + stamp the other bank twins' names by offset (no re-reading required) — run after naming each canonical (bank 09) parent, before moving to the next |
| `./scripts/regen-disasm.sh 1.05e` | mgbdis applies kernel.sym → renames labels in asm |
| `./scripts/doc-symbol-coverage.py --app --top 10` | D-row ranking (c=Jump_, d=jr_) |

`propagate-interior-clones.py` exploits the fact that `stamp-bank-clones.py`
already proved these FatFs functions are byte-identical across banks (modulo
bank-local immediates): an interior label's offset from its parent's start
address is therefore identical in every twin. It verifies each computed
address still has a live auto `Jump_`/`jr_` label in that bank's asm before
stamping, so a divergent twin is skipped, not guessed. Dry-run by default;
`--apply` writes `kernel.sym` (still requires `regen-disasm.sh` after).

```sh
# Default app-only packet
./scripts/map-interior.sh --skip-complete --top 5

# Single function
./scripts/interior-packet.py 1.05e --app --addr 04:46f4 --max-labels 60

# Batch apply + regen (then delete the batch file)
./scripts/map-interior.sh 1.05e --apply interior-batch.txt
rm -f interior-batch.txt

# FatFs twins (after app done)
./scripts/map-interior.sh --include-lib --skip-complete --top 5
```

Apply file format:

```text
# comments and blank lines ok
04:48f5 DrawTimeAutosaveScreen_redraw
04:4906 DrawTimeAutosaveScreen_hiliteGate
04:4909 DrawTimeAutosaveScreen_hilitePath
```

---

## Naming rules

1. **Parent prefix** — every interior name starts with the enclosing function
   name (`DrawTimeAutosaveScreen_…`, `FileBrowserEntry_…`).
2. **Role suffix** — taken from notes CF (`SET redraw`, `field0 yr`, `SAV date`,
   `input loop`). Use `_` not spaces; keep ≤ 40 chars when possible.
3. **jr_ vs Jump_** — both get sym entries; suffix may end in `Jr` when paired
   (`_hiliteJr` vs `_hiliteGate`).
4. **SDCC early-ret shape** — `Jump_` after `ret` inside the same parent stays
   interior (path label), not a new top-level function.
5. **Regen is mandatory** — sym edits do not change asm until regen; D counts
   read from asm auto labels.

---

## Worklist columns

```
addr      parent                   c   d  left sym
04:46f4  DrawTimeAutosaveScreen   117 42   159
```

- **c / d** — total `Jump_` / `jr_` in the function span (debt rank).
- **left sym** — auto labels still in asm (goes to 0 after sym + regen).

With `--skip-complete`, rows with `left sym = 0` are hidden (sticky D until
regen clears them, or truly done).

---

## Current state (1.05e)

- **App-only: 0 D rows.** `map-interior.sh` (default app scope) exits 2 /
  `interior_complete: 1`. Every app-bank `Jump_`/`jr_` inside a named function
  has a `kernel.sym` entry. Do not keep running the app-scope loop — it has
  nothing left to do and will just report empty.
- **App+lib: 144 D rows, all in FatFs banks 03/05/06/07/09** (bank 09 is
  canonical; 03/05/06/07 are near-identical twins — `stamp-bank-clones.py`
  propagates names/notes once bank 09 is done). This is now the entire
  remaining interior-naming queue: `./scripts/map-interior.sh --include-lib --skip-complete --top 5`.
- **notes.json CF for these FatFs parents is already substantially written**
  and matched against real FatFs source (`dir_find`, `create_name`,
  `follow_path`, `create_chain`, …) — spot-checked `CreateName_B9` (09:6c3e),
  `FollowPath_B9`, `DirFind_B9`, `DirNext_B9`, `CreateChain_B9` and their
  03/05/06/07 twins, all have real per-label CF hints already. This means the
  remaining lib work is mostly the mechanical rename-and-regen step, not a
  fresh reverse-engineering pass — same low-judgment shape as the app phase.
- **Ground truth is in the repo**: `tools/omega-de-kernel/source/ff15/ff.c`
  is ChaN's FatFs R0.15 (EZ Flash's own Omega kernel ships it unmodified,
  `diskio.c`/`ffsystem.c` are the only EZ Flash-specific glue). The Jr's FatFs
  build predates this exact revision, but the internal static functions
  (`dir_find`, `dir_next`, `create_name`, `follow_path`, `create_chain`,
  `clust2sect`, `get_fat`/`put_fat`, `gen_numname`, …) are stable across
  FatFs revisions — that's how the existing top-level bank-09 names
  (`Clust2Sect_B9`, `GetFat_B9`, `DirFind_B9`, …) were already matched. When a
  D-row's notes CF is thin or a role name is ambiguous, open the matching
  function in `ff.c` first — it's faster and more accurate than inferring the
  loop's purpose from raw Z80 alone. Any gaps found while doing this (a D-row
  whose notes CF turns out wrong or missing) are worth a real notes.json fix,
  not just a mechanical rename.
- **Primary frontier (F/O/J):** 0 — naming phase is interior-only, in both
  app and lib scope.
- `naming-progress.sh`'s "adjusted %" only moves when a *newly-documented*
  address gets named — renaming a `Jump_`/`jr_` that notes.json already cited
  does not move it (it was already counted as done). It only reads as
  progress once the corresponding `notes.json` CF exists; that's true for
  nearly all of the 144 remaining lib D rows already, so this pass should
  move the number a lot.

---

## Done check (per parent)

- [ ] Every `Jump_`/`jr_` in span has a `kernel.sym` entry
- [ ] Regen + `make` clean
- [ ] Asm shows `ParentFn_suffix:` instead of auto labels
- [ ] D row gone or `left sym = 0` on next packet
- [ ] notes.json unchanged (unless fixing a typo)
