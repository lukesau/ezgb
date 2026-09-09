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
cd re/1.05e-0731
python3 ../../tools/mgbdis/mgbdis.py kernel.gb --overwrite  # apply kernel.sym names
../../scripts/annotate-disasm.py 1.05e-0731                      # notes.json + wram.inc

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

- [`re/1.05e-0731/kernel.sym`](../re/1.05e-0731/kernel.sym): names (`Call_000_0de4` becomes
  `SdMenuMain`). mgbdis applies these to labels.
- [`re/1.05e-0731/notes.json`](../re/1.05e-0731/notes.json): comment blocks.
  `annotate-disasm.py` injects them, matching either the assigned name or the
  raw `*_bbb_aaaa` label for still-unnamed addresses.

See [psram-save-map.md](psram-save-map.md) for an example of the note format.

## Naming and annotation

The disassembly is 100% labeled. To refine a name or comment, edit
`re/1.05e-0731/kernel.sym` / `notes.json` then regenerate:

```sh
./scripts/regen-disasm.sh 1.05e-0731       # after editing kernel.sym / notes.json
./scripts/map-next.sh                 # progress + proposals + worklist + full packet
```

`map-next` prints body, callers, WRAM/`$7Fxx` touches, and `needs_judgment` for
its top target. Rank table only (no body): `doc-symbol-coverage.py --app --top
10` (`F` = frontier) or `--top 25` (full dump incl. lib banks).

Methodology, `bank:addr` translation, and interior-label conventions:
[MAPPING.md](MAPPING.md).

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

1. Pick a function from `re/1.05e-0731/disassembly/bank_*.asm` (or `1.04e`). Note its
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
decomp/tools/verify.py src/register_callback_slots.c 1.05e-0731 0 062e \
    --pin install_callback_slot=066c

# or a pins file (matched bank-0 symbols for 1.05e)
decomp/tools/verify.py src/register_callback_slots.c 1.05e-0731 0 062e \
    --pins tools/pins/1.05e-0731.bank0
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

## Porting the mod to another kernel build

Features are written and injected against **1.05e-0731**. The other two
official kernels (1.05e-0918, 1.04e) are the same program with code inserted
or removed in a few places, so the mod is carried over mechanically rather
than re-injected by hand:

```sh
scripts/port-mod.py 1.05e-0731 1.05e-0918 --check    # regression: must print "identical"
scripts/port-mod.py 1.05e-0731 1.05e-0918 --apply    # rewrite re/1.05e-0918/kernel.gb
scripts/port-mod.py 1.05e-0731 1.04e --apply --sym   # kernel.gb + kernel.sym + notes.json
scripts/regen-disasm.sh 1.04e && scripts/build-kernel.sh 1.04e
```

How it works (`scripts/portmap.py`, `scripts/port-mod.py`):

- **Address map.** Each bank of both stock ROMs is linear-decoded into a
  stream of opcodes (operands ignored, the 4-byte target after `call
  FarCallTrampoline` folded into one token) and the two streams are aligned
  with difflib. Any address inside a matched run maps by offset. Try it:
  `scripts/portmap.py 1.05e-0731 1.04e 00:1344 04:5990`.
- **C blocks** are recompiled with SDCC at the same address, every `--pin`
  translated through the map (`REGISTRY` in `port-mod.py` records each
  block's source and pins; a source with a hard-coded kernel address must use
  an `extern` + pin instead, as `fastlaunch_do_launch.c` does).
- **Hand-assembled blocks** (shims, hooks) are decoded and their absolute
  operands translated. `ld rr,nn` is treated as a pointer only when `nn` is a
  `kernel.sym` label or injected code, so screen-position constants survive.
  Blocks with string tails use `code_len`; pure data (`FolderIconGlyphs`) is
  copied verbatim; `VERSION_TEXT` holds the per-kernel `K1.0xe-…` string.
- **Hook sites** (every remaining byte that differs from stock) are widened
  to instruction boundaries and translated the same way. Before writing, the
  tool proves the target kernel has the same stock instructions at the
  translated site; a mismatch aborts. Sites that patch code the target does
  not have are listed in `SKIP_SITES` with a reason (1.04e: one extra SET-tab
  string draw that only 1.05e makes), and addresses the map cannot align are
  pinned in `OVERRIDES` after reading both disassemblies (1.04e: the SET-tab
  redraw label).
- **Symbols.** `--sym` ports `kernel.sym` and `notes.json` through the same
  map; 1.04e's runtime WRAM sits 39 bytes below 1.05e's from `$D6CC` up
  (`WRAM_SHIFT`), and names inside 1.05e's inserted RTC tables are dropped.

The tool also warns about stale bytes in free space (old versions of a block
that were never blanked); blank them in the source build rather than porting
them. `--check` against a build that already has a `kernel.gb` is the
regression test: porting 0731 onto 0918 must reproduce the committed 0918
kernel byte for byte.

After porting, regenerate the patches (below) and run
`scripts/stamp-mod-version.sh`, which stamps and rebuilds every version in the
manifest.

## Regenerating the kernel patches

The IPS patches in `patches/kernel/` are how the modded kernel is distributed
(see [distribution.md](distribution.md)). After changing any injection (and
regenerating/re-injecting per the feature docs), refresh the IPS and manifest
from the canonical artifacts (`re/<ver>/kernel.gb.orig` stock →
`re/<ver>/kernel.gb` modded):

```sh
python3 scripts/kernel-patch.py make    # all versions in the manifest
```

The command round-trips each patch before writing its manifest entry, and
regenerates every supported base in one run. The injected code is
byte-identical across them (bank 2 and bank 0 are identical in the stock
kernels), so the patches always change together. Commit
`patches/kernel/*.ips` + `manifest.json` + `VERSION` together with the
source change.

### Mod version

`patches/kernel/VERSION` holds the mod version `N.M`, the version releases
are tagged with (`mod-N.M`). `make` bumps **M** automatically whenever a
regen actually changes patch content (an identical regen doesn't bump).
**N** is bumped by hand when a feature lands: edit the file to `N.0`, and
the next content-changing regen produces `N.1`.

### Release policy

Since the disassembly reassembles the ROM, the `bank_*.asm` files are the
firmware in source-encoded form, which puts the repo in the same
tolerated-but-gray zone as other proprietary-binary decomp projects.
Attaching a built binary to a Release would escalate that from "repo you can
build" to "binary handed out", so a GitHub Release gets only the `.ips` files
(and optionally `scripts/kernel-patch.py`), never `ezgb.dat`, `kernel.gb`,
updater packages, or FPGA bitstreams.

Releases are tagged `mod-N.M` (from `patches/kernel/VERSION`) and carry one
asset per supported base, named `ezgb-mod-N.M-for-<base>.ips`, e.g.
`ezgb-mod-4.1-for-1.04e.ips`.

`scripts/make-dist.sh` (run automatically at the end of
`scripts/stamp-mod-version.sh`) assembles `dist/mod-N.M/` with, for every
version in the manifest, that `.ips` plus `ezgb-mod-N.M-for-<base>.dat`, the
patched kernel ready to copy to a card as `ezgb.dat`. Each `.dat` is checked
against the manifest md5 and each `.ips` is checked to reproduce it. `dist/`
is gitignored; only the `.ips` files leave the machine. Nothing is staged
into `sd/root/` any more: `scripts/make-sd-image.sh` copies the chosen
version's `re/<ver>/kernel.gb` straight into the emulator card image
(`EZGB_KERNEL_VERSION`, default 1.05e-0731).

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
  ./scripts/naming-progress.sh           # % of 1.05e-0731 symbols still auto-named by mgbdis
  ./scripts/naming-progress.sh 1.05e-0731 all # ...plus the full list of unnamed symbols
  ```

  `gbdiff.sh` names each diff region from a `<rom-basename>.sym` beside each ROM
  (we ship `re/1.05e-0731/kernel.sym`; add `re/1.04e/kernel.sym` to annotate the
  older side). `naming-progress.sh` reads a built `disassembly/game.sym`, so
  `make` the disassembly first.
- **[omega-de-kernel](https://github.com/ez-flash/omega-de-kernel)**: EZ Flash's
  own published Omega DE (GBA) kernel source: FPGA register naming, FatFs/UI
  structure, NOR / Mode B boot path. Pair with a real Omega cart for UX
  side-by-side; see [omega-jr-compare.md](omega-jr-compare.md).
- **[SDCC](https://sdcc.sourceforge.net/)**: C compiler for `decomp/` and for
  injected features.
