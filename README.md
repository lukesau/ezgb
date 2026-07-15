# EZ Flash Jr kernel reverse engineering

Reverse engineering the menu/OS firmware ("kernel") of the EZ Flash Jr, a Game Boy /
Game Boy Color flash cartridge. Its sibling, the [EZ Flash Omega](https://github.com/ez-flash/omega-de-kernel)
(GBA, ARM7), has published source. The Jr's kernel runs on the stock Game Boy CPU (SM83) and
has no published source, only the compiled firmware.

Goal: understand the kernel well enough to add a fast-launch path, a small on-disk config
file that tells the kernel to boot straight into a specific ROM, skipping the file-browser menu.

## What's here

- `re/1.04e/`, `re/1.05e/`: full disassemblies (`disassembly/`) of each firmware version,
  generated with [mgbdis](https://github.com/mattcurrie/mgbdis). Tracked and public.
- `re/REGISTERS.md`: notes on the cart's custom FPGA control registers (`$7f00-$7fff` I/O
  window), derived from the unlock/command/commit write pattern seen in the disassembly,
  cross-referenced against the Omega's public source for naming hypotheses.
- `re/DIFF_1.04e_vs_1.05e.md`: instruction-level diff between the two kernel versions.
- `decomp/`: matching decompilation project, rewriting the kernel function-by-function in C,
  verified byte-identical against the original.
- `decomp/1.05e-instability.md`: investigation into user reports of instability after
  updating to kernel 1.05e.

Not tracked (gitignored, local-only): EZ Flash's official firmware update packages
(`ezgb.dat`, `juniorkernel-1.04e-FW4/`, `juniorkernel-1.05e-FW5/`) and the `kernel.gb` working
copies under `re/*/`. These are EZ Flash's copyrighted binaries, not this project's work. The
disassembly is generated from them locally but the binaries themselves aren't redistributed
here. A fresh checkout needs its own dump of the kernel to regenerate or rebuild against.

## Status

- Disassembly of both kernel versions reassembles byte-identical to the originals (only the 3
  cosmetic ROM-header bytes differ, see `re/REGISTERS.md` for why).
- Diffed 1.04e vs 1.05e at the instruction level. Real logic changes are isolated to bank 0
  and bank 1; every other bank just has shifted call targets.
- Identified the FPGA unlock/command/commit register pattern and catalogued the distinct
  command ports in use (SD sector I/O, bank switching, peripheral enable/disable, see
  `re/REGISTERS.md`).
- Traced the "load ROM and launch" call path as far as static analysis allows. It terminates
  in an indirect (jump-table) call that needs a debugger to resolve. Next step is dynamic
  tracing in SameBoy to identify the actual loader function and how a selected file is passed
  into it.
- Matching decompilation started in `decomp/`: one function matched so far (see
  `decomp/PROGRESS.md`), toolchain and workflow established.

## Rebuilding a disassembly

```sh
cd re/1.05e/disassembly
make            # requires rgbasm/rgblink/rgbfix (rgbds)
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
3. Run `decomp/tools/verify.py <file.c> <version> <bank> <address_hex>`. It compiles with SDCC,
   links, extracts the raw bytes, and diffs them against the real ROM at that address.
4. Iterate on the C (and, if needed, on codegen flags) until it matches. Record the result in
   `decomp/PROGRESS.md`.

Known limitation: `decomp/tools/verify.py` currently only handles leaf functions, ones that
don't call anything else, or whose callees don't need address-accurate `call` instructions for
the byte comparison to work. A function that calls another not-yet-decompiled routine needs
that routine's address pinned via an `extern` declaration and a linker directive (SDCC/sdld
support fixing a symbol to an absolute address), so the compiled `call` instruction encodes the
correct target. Not set up yet. Needed before this scales past trivial standalone functions,
and should be solved before picking the next, less trivial target.

## Tools

- [RGBDS](https://rgbds.gbdev.io): assembler/linker used to verify disassembly round-trips
- [mgbdis](https://github.com/mattcurrie/mgbdis): the disassembler itself (cloned into
  `tools/`, gitignored, re-clone if needed)
- [SameBoy](https://sameboy.github.io): Game Boy emulator with a debugger, used for dynamic
  tracing
- [omega-de-kernel](https://github.com/ez-flash/omega-de-kernel): EZ Flash's own published
  Omega (GBA) kernel source, used as a reference for hardware-abstraction naming conventions
  (cloned into `tools/`, gitignored)
- [SDCC](https://sdcc.sourceforge.net/): C compiler used for the matching decompilation in
  `decomp/`

## License

GPLv3, see [LICENSE](LICENSE). Applies to this project's own code (disassembly, notes,
tooling). It does not and cannot relicense EZ Flash's original firmware, which isn't
redistributed in this repo (see above).
