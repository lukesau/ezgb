# EZ Flash Jr kernel reverse engineering

Reverse engineering the menu/OS firmware ("kernel") of the EZ Flash Jr, a Game Boy /
Game Boy Color flash cartridge. Its sibling, the [EZ Flash Omega](https://github.com/ez-flash/omega-de-kernel)
(GBA, ARM7), has published source. The Jr's kernel runs on the stock Game Boy CPU (SM83) and
has no published source, only the compiled firmware.

Goal: understand the kernel well enough to add a fast-launch path, a small on-disk config
file that tells the kernel to boot straight into a specific ROM, skipping the file-browser menu.

## What's here

```
.
├── decomp/
├── docs/
├── patches/
│   └── sameboy/               # diffs applied on top of upstream SameBoy
├── scripts/
│   ├── setup-sameboy.sh
│   ├── refresh-sameboy-patch.sh
│   ├── make-sd-image.sh
│   ├── mount-sd-image.sh
│   ├── gbdiff.sh              # symbol-annotated ROM diff (wraps gb-asm-tools)
│   ├── naming-progress.sh     # disassembly labeling progress (wraps gb-asm-tools)
│   └── doc-symbol-coverage.py # docs vs kernel.sym vs fan-in: what to name next
├── sd/                        # local microSD image for the stub (see sd/README.md)
│   └── README.md
├── ezgb.dat                   # NOT TRACKED, your own kernel dump goes here
├── juniorkernel-1.04e-FW4/    # NOT TRACKED, official firmware package (see below)
│   ├── Changelog.txt
│   ├── ezgb.dat
│   ├── readme.txt
│   └── Update_FW4.gb
├── juniorkernel-1.05e-FW5/    # NOT TRACKED, same idea, newer firmware
│   ├── ezgb.dat
│   └── Update_FW5_7-31.gb
├── re/
│   ├── 1.04e/
│   │   ├── disassembly/
│   │   │   ├── bank_000.asm
│   │   │   ├── ...
│   │   │   ├── bank_009.asm
│   │   │   ├── game.asm
│   │   │   ├── hardware.inc
│   │   │   └── Makefile
│   │   └── kernel.gb          # NOT TRACKED, copy of the firmware package's ezgb.dat
│   ├── 1.05e/                 # same layout as 1.04e
└── tools/                     # NOT TRACKED, cloned reference repos (see Tools below)
    ├── mgbdis/
    ├── SameBoy/               # from scripts/setup-sameboy.sh
    ├── gb-asm-tools/          # pret disassembly helpers (gbdiff, unnamed, ...)
    └── omega-de-kernel/
```

Paths marked NOT TRACKED are gitignored. They're either EZ Flash's copyrighted binaries
(the firmware packages and the `kernel.gb` copies derived from them) or cloned third-party
reference repos, not this project's own work. A fresh checkout needs its own dump of the
kernel (`ezgb.dat`, or a full firmware package folder) placed at the paths above to
regenerate or rebuild against; `tools/` repos can be re-cloned per the Tools section below.

## Status

- Disassembly of both kernel versions reassembles byte-identical to the originals (only the 3
  cosmetic ROM-header bytes differ, see `docs/REGISTERS.md` for why).
- Diffed 1.04e vs 1.05e at the instruction level. Real logic changes are isolated to bank 0
  and bank 1; every other bank just has shifted call targets.
- Identified the FPGA unlock/command/commit register pattern and catalogued the distinct
  command ports in use (SD sector I/O, bank switching, peripheral enable/disable, see
  `docs/REGISTERS.md`).
- Traced the "load ROM and launch" call path through the `$1569` far-call chain to
  bank4 `$448f` / `$7fe0=$80`. See `docs/launch-trace.md`.
- Fully traced the **last-ROM / START overlay** feature: the last-launched ROM's full path
  is persisted to cart NVRAM `$A300` (bank 17 + rompage `$03`) on every launch and read back
  on START; the prompt shows the basename but relaunch uses the full path. See
  `docs/last-rom.md`.
- Fast-launch still the goal; a first binary-hook experiment was tried and
  withdrawn — notes in `docs/fast-launch-notes.md`.
- Matching decompilation in `decomp/` (see `docs/PROGRESS.md`).

## Rebuilding a disassembly

```sh
cd re/1.05e
mgbdis kernel.gb                         # uses kernel.sym for human symbol names
../../scripts/annotate-disasm.py 1.05e   # inject notes from notes.json

cd disassembly
make            # requires rgbasm/rgblink/rgbfix (rgbds)
```

Persistent annotations: [re/1.05e/kernel.sym](re/1.05e/kernel.sym) (names),
[re/1.05e/notes.json](re/1.05e/notes.json) (comment blocks). See [docs/fram-save-map.md](docs/fram-save-map.md).
`mgbdis` applies the `kernel.sym` names to the labels (`Call_000_0de4` → `SdMenuMain`);
`annotate-disasm.py` then injects the `notes.json` blocks, matching either the assigned
name or the raw `*_bbb_aaaa` label for still-unnamed addresses.

To decide what to name next, `scripts/doc-symbol-coverage.py` cross-references the docs,
`kernel.sym`, and call fan-in and lists documented-but-unnamed functions (highest-leverage
first):

```sh
./scripts/doc-symbol-coverage.py            # 1.05e unnamed worklist by fan-in
./scripts/doc-symbol-coverage.py --top 15   # just the top rows
./scripts/doc-symbol-coverage.py 1.04e --all
```

## Matching decompilation (`decomp/`)

Separate, longer-term effort from `re/`: rewriting the kernel function-by-function in C,
verified byte-identical against the original compiled output, the same way projects like the
Pokemon Gen 1-3 or Super Mario 64 decompilations work. `re/` is the research phase, `decomp/`
is the rewrite.

The kernel's code shape (parameters passed on the stack and read back via `ld hl, sp+N`, since
the GB CPU has no IX register so this is how SDCC's Z80-family backend implements a stack
frame; callers pushing arguments and cleaning up afterward with `add sp, N`; the `push af` /
`inc sp` idiom for pushing a single byte argument) is the fingerprint of SDCC compiling C for
the sm83/gbz80 target using its legacy stack-based calling convention (`--sdcccall 0` in modern
SDCC; this used to be the default in older SDCC/GBDK setups).

Confirmed empirically: compiling `unsigned char return_zero(void) { return 0; }` with
`sdcc -msm83 --sdcccall 0` produces the machine code `1E 00 C9`, byte-for-byte identical to
`Call_000_1a77` in the real 1.05e kernel (and its counterpart at a shifted address in 1.04e).
See `decomp/src/misc.c` and `decomp/tools/verify.py`. Modern, brew-installable SDCC (this was
done with 4.6.0) is sufficient for simple functions; more complex functions may expose
version-specific codegen differences that require an older release.

Workflow:
1. Pick a function from `re/1.05e/disassembly/bank_*.asm` (or `1.04e`) to decompile. Note its
   bank and address.
2. Write equivalent C in `decomp/src/`. Keep it to one function (or a few closely related ones)
   per attempt for easier isolation of mismatches.
3. Run `decomp/tools/verify.py <file.c> <version> <bank> <address_hex> [--peep peep_file]
   [--pin SYM=ADDR ...] [--pins pins_file]`. It compiles with SDCC, links, extracts the raw
   bytes, and diffs them against the real ROM at that address. Optional peep files live under
   `decomp/tools/peeps/` when modern SDCC's codegen is equivalent but not byte-identical to
   the historical kernel compiler.
4. Iterate on the C (and, if needed, on codegen flags) until it matches. Record the result in
   `docs/PROGRESS.md`.

Callee pins: when the function under test `call`s/`jp`s another routine that is not in the
same C file, declare it `extern` and pin its kernel address so sdld encodes the right
absolute target (no stub bytes emitted):

```sh
# single pin
./tools/verify.py src/register_callback_slots.c 1.05e 0 062e \
    --pin install_callback_slot=066c

# or a pins file (matched bank-0 symbols for 1.05e)
./tools/verify.py src/register_callback_slots.c 1.05e 0 062e \
    --pins tools/pins/1.05e.bank0
```

Pins are still needed for not-yet-decompiled callees, and for matched ones you choose not to
compile into the same translation unit. verify only compares the bytes SDCC emitted for the
C file under test (pinned symbols contribute address fixups only).

## Tools

- [RGBDS](https://rgbds.gbdev.io): assembler/linker used to verify disassembly round-trips
- [mgbdis](https://github.com/mattcurrie/mgbdis): the disassembler itself (cloned into
  `tools/`, gitignored, re-clone if needed)
- [SameBoy](https://sameboy.github.io): Game Boy emulator with a debugger, used for dynamic
  tracing. Upstream stays out of git (`tools/SameBoy`, gitignored); our EZ Jr FPGA stub is
  tracked as patches against a pinned upstream commit:

  ```sh
  ./scripts/setup-sameboy.sh              # clone @ patches/sameboy/BASE_COMMIT + apply patches
  cd tools/SameBoy && make CONF=debug sdl
  ./scripts/refresh-sameboy-patch.sh      # after editing the stub, rewrite the patch file
  ```

  To move to a newer SameBoy: update `patches/sameboy/BASE_COMMIT`, rebase your local stub
  onto that commit, then re-run `refresh-sameboy-patch.sh`.
- [gb-asm-tools](https://github.com/pret/gb-asm-tools): pret's Game Boy disassembly helpers
  (cloned into `tools/`, gitignored, re-clone if needed):

  ```sh
  git clone https://github.com/pret/gb-asm-tools tools/gb-asm-tools
  ```

  Two of them are wired into `scripts/` (override the clone location with `GBASM_TOOLS=`):

  ```sh
  ./scripts/gbdiff.sh                    # symbol-annotated byte diff of the two kernel dumps
  ./scripts/gbdiff.sh old.gb new.gb      # ...or any two ROMs
  ./scripts/naming-progress.sh           # % of 1.05e symbols still auto-named by mgbdis
  ./scripts/naming-progress.sh 1.05e all # ...plus the full list of unnamed symbols
  ```

  `gbdiff.sh` names each diff region from a `<rom-basename>.sym` beside each ROM; we ship
  `re/1.05e/kernel.sym`, so add a `re/1.04e/kernel.sym` (e.g. a built `disassembly/game.sym`)
  to annotate the older side too. `naming-progress.sh` reads a built `disassembly/game.sym`,
  so `make` the disassembly first.
- [omega-de-kernel](https://github.com/ez-flash/omega-de-kernel): EZ Flash's own published
  Omega (GBA) kernel source, used as a reference for hardware-abstraction naming conventions
  (cloned into `tools/`, gitignored)
- [SDCC](https://sdcc.sourceforge.net/): C compiler used for the matching decompilation in
  `decomp/`

## License

GPLv3, see [LICENSE](LICENSE). Applies to this project's own code (disassembly, notes,
tooling). It does not and cannot relicense EZ Flash's original firmware, which isn't
redistributed in this repo (see above).
