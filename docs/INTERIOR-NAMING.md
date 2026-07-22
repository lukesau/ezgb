# Interior naming — loop prompt (phase 2)

Use this after the **notes-only CF pass** is done (`notes.json` cites every
`Jump_`/`jr_` inside named functions). This phase renames those interior labels
in `kernel.sym` so asm reads cleanly and D (interior-debt) rows shrink.

Hands-on checklist: [`MAP-SESSION.md`](MAP-SESSION.md). Philosophy:
[`MAPPING.md`](MAPPING.md).

---

## Copy-paste loop prompt (fresh chat)

```text
/loop 3m ezgb interior-name tick

You are continuing ezgb 1.05e reverse-engineering — INTERIOR NAMING phase (not notes).

Goal: name auto Jump_/jr_ labels inside already-named functions by adding
entries to re/1.05e/kernel.sym, then regen. notes.json CF is already complete;
use it as the naming guide, do not rewrite CF unless fixing an error.

Each tick:
1. Run: ./scripts/map-interior.sh --skip-complete --top 5
   (app-only by default; add --include-lib for FatFs banks 03/05/06/07/09)
2. Read the packet only — TARGET, NOTES CF, UNNAMED INTERIOR LABELS. Do not re-grep.
3. Pick the top TARGET parent function. Name its listed interior labels:
   - Format: bank:addr ParentFn_descriptiveSuffix
   - Example: 04:48f5 DrawTimeAutosaveScreen_redraw
   - Qualified names only — NOT top-level APIs (no bare DrawRedraw).
   - Avoid RGBDS reserved names (Strlen → CStrLen, etc.).
   - Derive suffixes from the notes CF line that mentions each Jump_/jr_.
4. Apply names either:
   - Edit kernel.sym directly (surgical adds under a ; Interior labels comment), OR
   - Write a batch file and: ./scripts/map-interior.sh 1.05e --apply names.txt
5. Regen: ./scripts/regen-disasm.sh 1.05e (map-interior --apply does this)
6. Verify: D count for that parent drops; Jump_/jr_ become human names in asm.
7. Delete the batch .txt after a successful apply (do not leave interior-batch-tick*.txt around).

Scope per tick:
- One parent function per tick (all labels shown, up to --max-labels 40).
- Huge functions (e.g. DrawTimeAutosaveScreen ~159 labels) take multiple ticks;
  keep working the same parent until unnamed=0, then regen.
- Skip lib banks unless explicitly using --include-lib.

Stop when:
- map-interior.sh exits 2 (interior_complete: 1) with --skip-complete, OR
- worklist empty after regen.

Do NOT:
- Re-annotate CF in notes.json (already done).
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
| `./scripts/regen-disasm.sh 1.05e` | mgbdis applies kernel.sym → renames labels in asm |
| `./scripts/doc-symbol-coverage.py --app --top 10` | D-row ranking (c=Jump_, d=jr_) |

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

- **App-only:** ~116 D rows; notes CF complete for all; interior sym entries not yet added.
- **App+lib:** ~260 D rows (FatFs twins on banks 03/05/06/07/09).
- **Primary frontier (F/O/J):** 0 — naming phase is interior-only.
- Start with smaller parents (`LcdOff`, `WaitVBlankFlag`) before mega-functions,
  or tackle high-debt UI (`DrawTimeAutosaveScreen`) if you want maximum impact.

---

## Done check (per parent)

- [ ] Every `Jump_`/`jr_` in span has a `kernel.sym` entry
- [ ] Regen + `make` clean
- [ ] Asm shows `ParentFn_suffix:` instead of auto labels
- [ ] D row gone or `left sym = 0` on next packet
- [ ] notes.json unchanged (unless fixing a typo)
