# Map session — memorize this

The end-to-end loop. Philosophy and pret context live in [`MAPPING.md`](MAPPING.md).
This page is the checklist you run with your hands on the keyboard.

---

## Step 0 — Where is address `00:27ba`?

The worklist prints **`bank:addr`**. That is not a filename. Translate it like this:

### A. Pick the file from the bank number

| Worklist says | Open this file |
|---|---|
| `00:….` | `re/1.05e/disassembly/bank_000.asm` |
| `01:….` | `re/1.05e/disassembly/bank_001.asm` |
| `04:….` | `re/1.05e/disassembly/bank_004.asm` |
| `09:….` | `re/1.05e/disassembly/bank_009.asm` |

Bank is two hex digits. File is `bank_` + **three** decimal-looking hex digits + `.asm`
(`00` → `000`, `01` → `001`, … `09` → `009`).

Everything you care about for naming lives under:

```text
re/1.05e/
├── kernel.sym          ← you ADD names here
├── notes.json          ← you ADD comments here
└── disassembly/
    ├── bank_000.asm    ← you READ these (regen overwrites labels)
    ├── bank_001.asm
    └── …
```

Do **not** hunt in `decomp/` or `tools/` for this loop.

### B. Build the label string from bank + addr

mgbdis auto-names look like:

```text
Call_BBB_AAAA
Jump_BBB_AAAA
jr_BBB_AAAA
```

- `BBB` = bank, **three** hex digits (`00` → `000`)
- `AAAA` = address, **four** hex digits (`27ba` stays `27ba`)

Examples:

| Worklist | Search for any of |
|---|---|
| `00:27ba` | `Call_000_27ba` or `Jump_000_27ba` |
| `00:298f` | `Call_000_298f` (already renamed to `U32Shr` if you regen’d) |
| `01:5db2` | `Call_001_5db2` |
| `04:48f5` | `Call_004_48f5` |

After you name something in `kernel.sym` and regen, the label becomes the human
name (`U32Shr:`) instead of `Call_000_298f:`. Searching the **address** still works:

```sh
rg -n "_27ba" re/1.05e/disassembly/bank_000.asm
```

### C. Jump there in the editor (pick one)

**Terminal (always works):**

```sh
# shows FILE:LINE — then open that line in your editor
rg -n "Call_000_27ba:|Jump_000_27ba:" re/1.05e/disassembly/bank_000.asm
```

Example output: `re/1.05e/disassembly/bank_000.asm:8344:Call_000_27ba:`  
→ open `bank_000.asm` at **line 8344**. That line is the start of the function.
Read downward from there until the next `Call_`/`Jump_`/`jr_` at column 0 (next
function) or a clear `ret` that ends this one.

**Cursor / VS Code:**

1. `Cmd+P` → type `bank_000` → open `bank_000.asm`
2. `Cmd+F` → search `Call_000_27ba` or just `_27ba`
3. Land on the line that is exactly `Call_000_27ba:` (definition). Ignore lines
   that only `call Call_000_27ba` — those are **callers**, not the body.

**One-liner that prints a window of the body:**

```sh
rg -n -A 35 "^Call_000_27ba:|^Jump_000_27ba:" re/1.05e/disassembly/bank_000.asm
```

`-A 35` = show the next 35 lines (the function body). Swap in your bank/addr.

### D. Sanity check you opened the definition

Correct:

```asm
Call_000_27ba:          ; ← label alone on the line, ends with :
    push bc             ; ← indented instructions = body
    …
    ret
```

Wrong place (a caller — go find the definition instead):

```asm
    call Call_000_27ba  ; ← indented call TO the function
```

---

## Agent loop (lean — prefer this)

Deterministic scripts do the hunt and mechanical names. The agent only
**applies/rejects proposals** and deep-reads when judgment is required.

```sh
# Cron / no-LLM pass (clones → propose --apply → regen → packet)
./scripts/label-cron.sh 1.05e
# exit 2 ⇒ WAKE: packet needs judgment

# Or agent tick:
./scripts/propose-labels.py 1.05e          # review; --apply when ok
./scripts/label-packet.py 1.05e --app --frontier-only --top 5
# then: name/edit only if needs_judgment: 1 (or reject a bad proposal)
./scripts/regen-disasm.sh 1.05e
```

**Do not** re-grep body/callers/WRAM each tick — the packet already has them.
**Do not** open lib banks `03/05/06/07/09` unless a named app callee leads there.
Prefer `--app --frontier-only --top 5` once `F` rows exist.
Avoid RGBDS reserved names (`Strlen` → `CStrLen`, etc.).

Hand loop below is still valid when you are not using the scripts.

---

## The loop (8 steps)

```text
1 PICK → 2 OPEN → 3 CLASSIFY → 4 PROVE → 5 NAME → 6 NOTE → 7 REGEN → 8 DONE?
         ↑                                                              │
         └──────────────── next address from worklist ←─────────────────┘
```

You finish **one function** (sometimes a tight cluster of siblings) per pass.
“Done” means that function — not the bank, not the feature.

---

### 1. PICK

```sh
./scripts/label-packet.py 1.05e --app --frontier-only --top 5
# fallback worklist:
./scripts/doc-symbol-coverage.py --app --frontier-only --top 5
```

Take the **top unnamed** row (`F` preferred). Write down `bank:addr`.

If the top rows are all tiny math helpers you already understand, skip down the
list until something stores to WRAM / calls something else / touches `$7Fxx`.

---

### 2. OPEN

Prefer the packet body/callers sections. Manual recipe for `00:27ba`:

```sh
rg -n -A 40 "^Call_000_27ba:|^Jump_000_27ba:" re/1.05e/disassembly/bank_000.asm
rg -n "call Call_000_27ba|jp Jump_000_27ba" re/1.05e/disassembly/
```

---

### 3. CLASSIFY (read the instructions)

Ask only: **what shape is this body?**

| You see… | Likely class | Emulator? |
|---|---|---|
| `ld hl,$0002` / `add hl,sp` then load several bytes, then a **tight loop** of `rr`/`rl`/`sra`/`sla` with `dec a` / `ret z` | SDCC **shift** runtime | **No** |
| Same stack load, then long mul/div loop (`rl` + `sbc` + bit counter) | SDCC **mul/div** runtime | **No** |
| Short; copies bytes; `ret` | `Memcpy`-family / small util | Usually **no** |
| Loads from `sp+N`, stores to `$Dxxx` / `$Cxxx`, maybe one `call` | **App helper** (draw, state) | Maybe later |
| Unlock `$7f00`/`$7f10`/`$7f20` … commit `$7ff0` | **FPGA** helper | Maybe later |
| Big; many calls; loops on joypad / strings | **Control flow** (menu, loader) | Often **yes** |

**How I spotted `$298f` as runtime (you can repeat this):**

```asm
ld hl, $0002
add hl, sp          ; point at first stack arg (SDCC --sdcccall 0)
ld e,[hl] / ld d,[hl] / ld c,[hl] / ld b,[hl] / ld a,[hl]
ld l,c / ld h,b     ; 32-bit value now in HL:DE, count in A
or a / ret z        ; shift count 0 → done
rr h / rr l / rr d / rr e
dec a
jp …                ; loop = logical >> on unsigned long
```

No WRAM. No `$7Fxx`. No “business” calls. High fan-in + pure ALU loop ⇒
**compiler helper**, name it, move on.

Sibling checks (same file, nearby):

- `sra h` instead of `rr h` → signed `>>`
- `rl e` / `rl d` / … → `<<`

You do **not** need SameBoy to confirm that.

---

### 4. PROVE (only as hard as the class needs)

**Runtime / pure util:** body is the proof. Stop.

**App helper:** read every absolute address it touches.

```text
stores to $D725, $D726, …  →  write them down
calls Call_000_22c6         →  open THAT next if unnamed (frontier)
```

Optional: one caller site — are args pushed right before the `call`?
(`push hl` / `push af` / `inc sp` patterns = SDCC stack args.)

**Still unclear after reading body + one caller?** Then live dump — not single-step:

```sh
# scripts/debug/tmp.sbd
breakpoint $27ba
continue
```

```sh
./scripts/run-sameboy-debug.sh --trace --script scripts/debug/tmp.sbd
```

On hit, dump **the addresses this function uses** (edit `dump-*.sbd` or type
`examine/16 $d725`, `registers`, `backtrace`). Then `continue`. One or two hits
beat stepping.

**Control flow:** trigger the UI path (open file, press START, …), break on the
label, dump, continue. Same `--trace` idea.

---

### 5. NAME

Edit `re/1.05e/kernel.sym` only:

```text
00:27ba YourNameHere
```

Rules of thumb:

- Verb or clear noun: `U32Shr`, `DrawGlyph`, `SdReadSector`
- Match a known sibling if it’s the same shape: `U32Shl` next to `U32Shr`
- If you only know “stores draw params but not which,” either leave unnamed or
  use a cautious name and say so in the note — **wrong names are worse than
  `Call_`**

---

### 6. NOTE

Edit `re/1.05e/notes.json` — a few lines max:

```json
{
  "bank": 0,
  "addr": "27ba",
  "lines": [
    "What it does in one sentence.",
    "Args / returns / important WRAM or ports.",
    "How you know (body / caller / SameBoy)."
  ]
}
```

If the note would be a page, stop and write/extend a `docs/*.md` instead; the
note should point at that doc.

---

### 7. REGEN (persist + check)

```sh
./scripts/regen-disasm.sh 1.05e          # quiet; -v for full logs
# equivalent: mgbdis → annotate → make → naming-progress → app worklist
```

`make` must succeed. Spot-check the label in `bank_*.asm`: human name + `; [ezgb]`
comment present.

---

### 8. DONE? (for this function)

Check all that apply:

- [ ] Has a **defensible** name in `kernel.sym` (or you consciously left it unnamed)
- [ ] `notes.json` says what/args/how-you-know (if non-obvious)
- [ ] Regen + `make` clean
- [ ] You could explain it to yourself tomorrow in one sentence
- [ ] **Out of scope on purpose:** every callee, every caller, the whole feature

Then go back to **1. PICK**. Growing the frontier means: if this function’s
important callee is still `Call_…`, that callee is a natural next pick.

A **section** (e.g. “draw primitives”) is done when the worklist’s top hits for
that area are named and you’re no longer discovering mystery WRAM in that
cluster — not when every byte in the bank is labeled.

---

## Decision cheat card (pocket)

```text
OPEN body
  │
  ├─ only ALU + stack + tiny loop?     → NAME runtime → REGEN → DONE
  ├─ WRAM/$7Fxx stores, few calls?     → list addresses → NAME or NOTE gap
  │                                       → optional 1 dump → REGEN → DONE
  └─ big / many calls / UI?            → name what you know, break on it once,
                                          dump, map callees one at a time
```

---

## Practice drill (do this once without asking anyone)

1. Run `./scripts/label-packet.py 1.05e --app --frontier-only --top 5`.
2. Read TARGET + BODY + ABS TOUCHES (do not re-grep).
3. Say out loud: **runtime / util / app helper / FPGA / control**.
4. If runtime or mechanical: name it (or `propose-labels.py --apply`), regen, stop.
5. If app helper: use the packet’s WRAM/`$7Fxx` list; name only what that allows.
6. Do **not** open SameBoy on the first drill unless the body has no clear shape.

When `$27ba` is next: it stores stack fields into `$D724`–`$D728` and calls
`$22c6`. Your job is to classify it as app helper, name it only as specifically
as that evidence allows, and decide whether `$22c6` is the next pick.

---

## What “figuring out what it does” actually means

It does **not** mean understanding the whole program.

It means answering, in order:

1. **Inputs** — registers and/or stack slots (`sp+2`, `sp+4`, …)
2. **Outputs** — return regs (`DE`/`HL`/`A`) and/or memory written
3. **Effect** — one sentence (“logical shr u32”, “stash draw rect”, “FPGA page select”)
4. **Role** — runtime vs game logic (affects how hard you prove)

If you can fill those four, you can name it. If you can’t, your next action is
narrower proof (one caller, or one breakpoint dump) — not “keep pressing `c`.”
