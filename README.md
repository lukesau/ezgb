# EZ Flash Jr kernel reverse engineering

Reverse engineering the menu/OS firmware ("kernel") of the **EZ Flash Jr**, a Game Boy /
Game Boy Color flash cartridge. Unlike its sibling the [EZ Flash Omega](https://github.com/ez-flash/omega-de-kernel)
(GBA, ARM7, published source), the Jr's kernel runs on the stock Game Boy CPU (SM83) and has
never had source released — only the compiled firmware.

Goal: understand the kernel well enough to add a fast-launch path — a small on-disk config
file that tells the kernel to boot straight into a specific ROM, skipping the file-browser menu.

## What's here

- `re/1.04e/`, `re/1.05e/` — full disassemblies (`disassembly/`) of each firmware version,
  generated with [mgbdis](https://github.com/mattcurrie/mgbdis). This is the actual codebase
  of the project and is tracked/public.
- `re/REGISTERS.md` — notes on the cart's custom FPGA control registers (`$7f00-$7fff` I/O
  window), reverse engineered from the unlock/command/commit write pattern seen in the
  disassembly, cross-referenced against the Omega's public source for naming hypotheses.

Not tracked (gitignored, local-only): EZ Flash's official firmware update packages
(`ezgb.dat`, `juniorkernel-1.04e-FW4/`, `juniorkernel-1.05e-FW5/`) and the `kernel.gb` working
copies under `re/*/`. These are EZ Flash's copyrighted binaries, not this project's work — the
disassembly is generated from them locally but the binaries themselves aren't redistributed
here. If you're checking this out fresh, you'll need your own dump of the kernel to regenerate
or rebuild against.

## Status

- Disassembly of both kernel versions verified to reassemble byte-identical to the originals
  (only the 3 cosmetic ROM-header bytes differ — see `re/REGISTERS.md` intro for why).
- Diffed 1.04e vs 1.05e at the instruction level; real logic changes are isolated to bank 0
  and bank 1, everything else just has shifted call targets.
- Identified the FPGA unlock/command/commit register pattern and catalogued the distinct
  command ports in use (SD sector I/O, bank switching, peripheral enable/disable — see
  `re/REGISTERS.md`).
- Traced the "load ROM and launch" call path as far as static analysis allows; it terminates
  in an indirect (jump-table) call that needs a debugger to resolve. Next step is dynamic
  tracing in SameBoy to identify the actual loader function and how a selected file is passed
  into it.

## Rebuilding a disassembly

```sh
cd re/1.05e/disassembly
make            # requires rgbasm/rgblink/rgbfix (rgbds)
```

## Tools

- [RGBDS](https://rgbds.gbdev.io) — assembler/linker used to verify disassembly round-trips
- [mgbdis](https://github.com/mattcurrie/mgbdis) — the disassembler itself (cloned into
  `tools/`, gitignored — re-clone if needed)
- [SameBoy](https://sameboy.github.io) — Game Boy emulator with a debugger, used for dynamic
  tracing
- [omega-de-kernel](https://github.com/ez-flash/omega-de-kernel) — EZ Flash's own published
  Omega (GBA) kernel source, used as a reference for hardware-abstraction naming conventions
  (cloned into `tools/`, gitignored)

## License

GPLv3 — see [LICENSE](LICENSE). Applies to this project's own code (disassembly, notes,
tooling); it does not and cannot relicense EZ Flash's original firmware, which isn't
redistributed in this repo (see above).
