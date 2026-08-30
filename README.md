# EZ Flash Jr kernel — reverse engineering & mods

The EZ Flash Jr is a Game Boy / Game Boy Color flash cartridge. Its menu/OS
firmware (the "kernel") runs on the stock Game Boy CPU (SM83) and, unlike its
GBA sibling the [EZ Flash Omega](https://github.com/ez-flash/omega-de-kernel),
has **no published source** — only the compiled firmware ships.

This repo reverse-engineers that kernel and, on top of the understanding,
builds new features you can compile into your own cartridge.

## Where the project is

The reverse engineering is essentially **done**:

- **The disassembly is fully labeled and reassembles byte-identical** to the
  original firmware (both the 1.04e and 1.05e builds; only 3 cosmetic
  ROM-header bytes differ). Every bank is accounted for.
- **The hardware is understood** — the FPGA unlock/command/commit register
  protocol, SD sector I/O, bank switching, PSRAM save storage, the board
  itself, and the "load ROM and launch" boot path. See
  [`docs/hardware-board.md`](docs/hardware-board.md),
  [`docs/REGISTERS.md`](docs/REGISTERS.md),
  [`docs/fpga-flash-map.md`](docs/fpga-flash-map.md),
  [`docs/launch-trace.md`](docs/launch-trace.md).
- **Arbitrary code injection works end to end.** You can compile C, place it in
  verified-free ROM space, hook it into the kernel, and see it run on real
  hardware and in-emulator. That capability is what the features below are
  built on. Recipe and free-space map:
  [`docs/inject-smoke-test.md`](docs/inject-smoke-test.md).

So the interesting part now is the **mods** — patches you apply to your own
firmware dump to get a better cartridge than the one EZ Flash ships.

## Features you can build in

Each of these is a self-contained patch against the 1.05e kernel. Apply the
ones you want, produce an `ezgb.dat`, and run it in SameBoy or flash it to a
cart. Every feature has a doc with the full rationale, wiring, and exact
`inject`/`patch` commands.

| Feature | What it does | Doc |
|---|---|---|
| **Sorted browser** | Lists directories first, then files, each group alphabetically (case-insensitive) instead of raw FAT order. Matches Omega DE behavior the Jr never got. | [`docs/browser-sort.md`](docs/browser-sort.md) |
| **Continuous scrolling** | DOWN/UP scroll the file list one line past the screen edge instead of stopping dead at the top/bottom row. | `decomp/src/browser_scroll.c` |
| **Snappy down-scroll repaint** | Repaints bottom-up so the newly revealed entry appears immediately on DOWN, instead of a visible beat later. | [`docs/browser-scroll-repaint.md`](docs/browser-scroll-repaint.md) |
| **RIGHT jumps to end** | RIGHT on the last page moves the cursor to the bottom entry, mirroring what LEFT already does at the top. | [`docs/browser-page-end.md`](docs/browser-page-end.md) |
| **Hide macOS cruft** | Filters `._*` AppleDouble sidecars, `.DS_Store`, `.Spotlight-V100/` etc. — the junk a Mac scatters on the card, which the stock browser lists (nearly doubling the list). | [`docs/browser-dotfile-filter.md`](docs/browser-dotfile-filter.md) |
| **CGB mode** | Boots the kernel in Game Boy Color mode (identical look), unlocking the CGB-only registers — the prerequisite for using the GBC's IR port and other CGB features. | [`docs/cgb-mode.md`](docs/cgb-mode.md) |

**In progress:** a "fast-launch" / Omega DE–style **Mode B** — boot straight
into one chosen ROM without the file browser. The load-and-launch path is
traced and the last-ROM persistence is fully mapped
([`docs/last-rom.md`](docs/last-rom.md)); the boot-hook wiring is deferred.
Notes: [`docs/fast-launch-notes.md`](docs/fast-launch-notes.md),
[`docs/omega-jr-compare.md`](docs/omega-jr-compare.md).

## Building a modded kernel

You need your **own dump** of the firmware — this repo does not redistribute
EZ Flash's copyrighted binaries. Drop it at `re/1.05e/kernel.gb` (a copy of the
`ezgb.dat` from the official firmware package). Then:

1. **Regenerate the disassembly** from your dump (one-time, per version):

   ```sh
   cd re/1.05e
   python3 ../../tools/mgbdis/mgbdis.py kernel.gb --overwrite
   ../../scripts/annotate-disasm.py 1.05e
   ```

2. **Apply the features you want.** Each feature doc lists its exact commands;
   for example the sorted browser:

   ```sh
   cd decomp
   python3 tools/inject.py src/browser_sort.c 1.05e 8 746b BrowserSortAll \
       --pin DirList=0a43 --apply
   python3 tools/inject_bytes.py 1.05e 0 03d4 BrowserSortAllStub \
       cd8d076b740800c9 --apply
   python3 tools/patch_call.py 1.05e 0 102f 3 00:03d4 --apply --regen
   ```

   Injection edits `re/1.05e/kernel.gb` in place, so it becomes the
   authoritative patched artifact.

3. **Stage it as `ezgb.dat`** (the name the cart's bootstrap loads) and build a
   card image for the emulator:

   ```sh
   scripts/build-ezgb-dat.sh 1.05e     # copies kernel.gb -> sd/root/ezgb.dat
   scripts/make-sd-image.sh            # builds the SameBoy card image
   ```

4. **Run it.** In SameBoy (with the EZ Jr FPGA stub — see
   [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md#tools)), or copy the `ezgb.dat`
   onto a real cart's microSD via the official updater.

Full injection mechanics, hook-site rules, and the free-space map are in
[`docs/inject-smoke-test.md`](docs/inject-smoke-test.md).

## Repo layout

```
re/               Reverse-engineered disassemblies, one dir per firmware version
  1.04e/          FW4
  1.05e/          FW5 (2020-07-31) — primary target
  1.05e-0918/     FW5 (2021-09-18, unreleased)
    disassembly/  bank_*.asm, hardware.inc, Makefile — reassembles byte-identical
    kernel.sym    persistent names        (NOT TRACKED: kernel.gb — your own dump)
    notes.json    persistent comment blocks
decomp/           Matching C decompilation + injectable feature sources
  src/            browser_sort.c, browser_scroll*.c, cgb_init.c, ... (features + decomp)
  tools/          inject.py, inject_bytes.py, patch_call.py, verify.py
docs/             All findings, feature write-ups, hardware notes  (start below)
scripts/          Disassembly regen, mapping loop, SD image, SameBoy stub helpers
patches/sameboy/  EZ Jr FPGA stub as diffs over a pinned SameBoy commit
sd/               Local microSD image for the emulator stub  (see sd/README.md)
fpga/             Local FPGA config-flash dumps               (NOT TRACKED)
tools/            Cloned reference repos                      (NOT TRACKED)
```

**NOT TRACKED** paths are gitignored: either EZ Flash's copyrighted binaries
(firmware packages, `kernel.gb`, FPGA bitstreams) or third-party reference
repos. A fresh checkout supplies its own firmware dump and re-clones `tools/`
(see [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md#tools)). Always name a specific
version — the FW5 packages differ
([`docs/DIFF_1.05e-0731_vs_0918.md`](docs/DIFF_1.05e-0731_vs_0918.md)).

## Digging deeper

- **[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)** — rebuild the disassembly,
  name functions, inject code, verify a matching decompilation, set up the
  tools. Start here to contribute.
- **Hardware:** [`docs/hardware-board.md`](docs/hardware-board.md),
  [`docs/REGISTERS.md`](docs/REGISTERS.md),
  [`docs/fpga-flash-map.md`](docs/fpga-flash-map.md),
  [`docs/game-slot-access.md`](docs/game-slot-access.md),
  [`docs/psram-save-map.md`](docs/psram-save-map.md).
- **Boot & launch:** [`docs/boot-map.md`](docs/boot-map.md),
  [`docs/ezgb-dat-boot.md`](docs/ezgb-dat-boot.md),
  [`docs/launch-trace.md`](docs/launch-trace.md),
  [`docs/last-rom.md`](docs/last-rom.md).
- **Version diffs:** [`docs/DIFF_1.04e_vs_1.05e.md`](docs/DIFF_1.04e_vs_1.05e.md),
  [`docs/DIFF_1.05e-0731_vs_0918.md`](docs/DIFF_1.05e-0731_vs_0918.md),
  [`docs/1.05e-instability.md`](docs/1.05e-instability.md).
- **Mapping methodology:** [`docs/MAPPING.md`](docs/MAPPING.md),
  [`docs/MAP-SESSION.md`](docs/MAP-SESSION.md),
  [`docs/INTERIOR-NAMING.md`](docs/INTERIOR-NAMING.md).

## License

AGPLv3 — see [LICENSE](LICENSE). Applies to this project's own work
(disassembly, notes, tooling, feature code). It does not and cannot relicense
EZ Flash's original firmware, which is not redistributed here.
