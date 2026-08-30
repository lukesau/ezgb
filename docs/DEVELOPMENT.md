# Development guide

Everything a contributor needs to regenerate the disassembly, name functions,
inject C code, and verify a matching decompilation. The [README](../README.md)
covers what the project *is* and how to build a modded kernel; this covers how
the research and tooling underneath it work.

## Prerequisites

- **RGBDS** (`rgbasm`/`rgblink`/`rgbfix`): assembles the disassembly.
- **[mgbdis](https://github.com/mattcurrie/mgbdis)**: the disassembler.
- **[SDCC](https://sdcc.sourceforge.net/)** (4.6.0+ from brew is fine for simple
  functions): compiles the C for `decomp/` and for injected features.
- **[SameBoy](https://sameboy.github.io)** with the EZ Jr FPGA stub, for dynamic
  tracing (see [Tools](#tools)).
- A firmware dump at `re/<version>/kernel.gb` (not tracked; see the README's
  copyright note).

`tools/` reference repos are gitignored; re-clone them per the [Tools](#tools)
section.

## Rebuilding a disassembly

```sh
cd re/1.05e
python3 ../../tools/mgbdis/mgbdis.py kernel.gb --overwrite  # apply kernel.sym names
../../scripts/annotate-disasm.py 1.05e                      # notes.json + wram.inc

cd disassembly
make            # requires rgbasm/rgblink/rgbfix (rgbds)
```

`mgbdis` must run with `--overwrite` when `disassembly/` already exists, or bank
files keep their old `Call_` names. `annotate-disasm.py` also emits `wram.inc`
for `kernel.sym` entries at CPU addr ≥ `$C000` (mgbdis rewrites `[wGfxMode]` but
does not define those labels).

The build reassembles to the original dump exactly (only the 3 cosmetic
ROM-header bytes differ; see [REGISTERS.md](REGISTERS.md)).

Persistent annotations live in two files per version:

- [`re/1.05e/kernel.sym`](../re/1.05e/kernel.sym): names (`Call_000_0de4` becomes
  `SdMenuMain`). mgbdis applies these to labels.
- [`re/1.05e/notes.json`](../re/1.05e/notes.json): comment blocks.
  `annotate-disasm.py` injects them, matching either the assigned name or the
  raw `*_bbb_aaaa` label for still-unnamed addresses.

See [psram-save-map.md](psram-save-map.md) for an example of the note format.

## Naming the next function

The disassembly is already 100% labeled, but naming and annotation is an ongoing
refinement. Use the same context humans and agents share:

```sh
./scripts/map-next.sh                 # progress + proposals + app worklist + full packet
./scripts/map-next.sh --top 10        # wider picker
./scripts/regen-disasm.sh 1.05e       # after editing kernel.sym / notes.json
```

`map-next` prints the body, callers, WRAM/`$7Fxx` touches, and `needs_judgment`
for its top target, so do not re-grep what it already showed.

Rank table only (no body context):

```sh
./scripts/doc-symbol-coverage.py --app --top 10   # app banks; F = frontier
./scripts/doc-symbol-coverage.py --top 25         # full dump incl. lib banks
```

Full pret-style workflow notes: [MAPPING.md](MAPPING.md). Session checklist:
[MAP-SESSION.md](MAP-SESSION.md). Interior `Jump_`/`jr_` naming:
[INTERIOR-NAMING.md](INTERIOR-NAMING.md).

## Matching decompilation (`decomp/`)

A separate, longer-term effort from `re/`: rewriting the kernel
function-by-function in C, verified against the original compiled output the
same way the Pokémon Gen 1-3 or Super Mario 64 decompilations work. `re/` is the
research phase; `decomp/` is the rewrite. Secondary to naming the ASM; see
[PROGRESS.md](PROGRESS.md).

### Why SDCC / `--sdcccall 0`

The kernel's code shape is the fingerprint of SDCC compiling C for the
sm83/gbz80 target with its legacy stack-based calling convention (`--sdcccall
0`, once the GBDK default): parameters passed on the stack and read via `ld hl,
sp+N` (the SM83 has no IX register); callers cleaning up with `add sp, N`; the
`push af` / `inc sp` idiom for a single-byte argument.

Confirmed empirically: `unsigned char return_zero(void) { return 0; }` compiled
with `sdcc -msm83 --sdcccall 0` produces `1E 00 C9`, matching `Call_000_1a77` in
the real 1.05e kernel exactly. See `decomp/src/misc.c` and
`decomp/tools/verify.py`. Modern brew SDCC suffices for simple functions; more
complex ones may expose version-specific codegen differences needing an older
release (bridge small gaps with a peep file under `decomp/tools/peeps/`).

### Workflow

1. Pick a function from `re/1.05e/disassembly/bank_*.asm` (or `1.04e`). Note its
   bank and address.
2. Write equivalent C in `decomp/src/`. One function (or a few closely related)
   per attempt for easier mismatch isolation.
3. Verify:

   ```sh
   decomp/tools/verify.py <file.c> <version> <bank> <address_hex> \
       [--peep peep_file] [--pin SYM=ADDR ...] [--pins pins_file]
   ```

   It compiles with SDCC, links, extracts the raw bytes, and diffs them against
   the real ROM at that address.
4. Iterate on the C (and codegen flags) until it matches. Record in
   [PROGRESS.md](PROGRESS.md).

### Callee pins

When the function under test `call`s/`jp`s a routine not in the same C file,
declare it `extern` and pin its kernel address so sdld encodes the right
absolute target (no stub bytes emitted):

```sh
# single pin
decomp/tools/verify.py src/register_callback_slots.c 1.05e 0 062e \
    --pin install_callback_slot=066c

# or a pins file (matched bank-0 symbols for 1.05e)
decomp/tools/verify.py src/register_callback_slots.c 1.05e 0 062e \
    --pins tools/pins/1.05e.bank0
```

Pins are needed for not-yet-decompiled callees, and for matched ones you choose
not to compile into the same translation unit. `verify` only compares the bytes
SDCC emitted for the C file under test; pinned symbols contribute address fixups
only.

## Injecting a feature (`inject.py`)

`inject.py` compiles a C file and writes the machine code into the build at a
**real** final ROM address (unlike `verify.py`, which links at a throwaway
address just to diff). Linking at the real address matters: any internal
absolute `jp`/`call` the function makes is encoded for where it will actually
live.

```sh
inject.py <file.c> <version> <bank> <address_hex> <name> \
          [--pin SYM=ADDR ...] [--pins pins_file] [--apply] [--regen]
```

The injected bytes land in `kernel.sym` as a `bank:addr .data:LEN:WIDTH` block
(opaque compiled code, not hand-editable asm). The name is an ordinary
`kernel.sym` label, so existing asm and other injected C can `call` it.

Companion tools:

- `inject_bytes.py`: drop hand-assembled bytes (stubs, trampolines) at an
  address as a named block.
- `patch_call.py`: repoint an existing `call`/`jp` operand to a new target
  (`--jp` for tail-`jp`/`ret` hook sites).

**Start here:** [inject-smoke-test.md](inject-smoke-test.md) walks the full
inject, hook, and run chain, documents the free-space map, and explains how to
pick a safe hook site (and the two ways the earlier fastlaunch attempt silently
corrupted the ROM). Read it before choosing an address.

## Tools

Reference repos clone into `tools/` (gitignored; re-clone as needed):

- **[RGBDS](https://rgbds.gbdev.io)**: assembler/linker; verifies disassembly
  round-trips.
- **[mgbdis](https://github.com/mattcurrie/mgbdis)**: the disassembler.
- **[SameBoy](https://sameboy.github.io)**: Game Boy emulator with a debugger,
  for dynamic tracing. Upstream stays out of git; our EZ Jr FPGA stub is tracked
  as patches against a pinned upstream commit:

  ```sh
  ./scripts/setup-sameboy.sh              # clone @ patches/sameboy/BASE_COMMIT + apply
  cd tools/SameBoy && make CONF=debug sdl
  ./scripts/refresh-sameboy-patch.sh      # after editing the stub, rewrite the patch
  ```

  To move to a newer SameBoy: update `patches/sameboy/BASE_COMMIT`, rebase the
  local stub onto that commit, then re-run `refresh-sameboy-patch.sh`.
- **[gb-asm-tools](https://github.com/pret/gb-asm-tools)**: pret's disassembly
  helpers (override the clone location with `GBASM_TOOLS=`):

  ```sh
  git clone https://github.com/pret/gb-asm-tools tools/gb-asm-tools
  ./scripts/gbdiff.sh                    # symbol-annotated byte diff of the two dumps
  ./scripts/gbdiff.sh old.gb new.gb      # ...or any two ROMs
  ./scripts/naming-progress.sh           # % of 1.05e symbols still auto-named by mgbdis
  ./scripts/naming-progress.sh 1.05e all # ...plus the full list of unnamed symbols
  ```

  `gbdiff.sh` names each diff region from a `<rom-basename>.sym` beside each ROM
  (we ship `re/1.05e/kernel.sym`; add `re/1.04e/kernel.sym` to annotate the
  older side). `naming-progress.sh` reads a built `disassembly/game.sym`, so
  `make` the disassembly first.
- **[omega-de-kernel](https://github.com/ez-flash/omega-de-kernel)**: EZ Flash's
  own published Omega DE (GBA) kernel source: FPGA register naming, FatFs/UI
  structure, NOR / Mode B boot path. Pair with a real Omega cart for UX
  side-by-side; see [omega-jr-compare.md](omega-jr-compare.md).
- **[SDCC](https://sdcc.sourceforge.net/)**: C compiler for `decomp/` and for
  injected features.
