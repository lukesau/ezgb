# EZ Flash Jr kernel: reverse engineering & mods

The EZ Flash Jr is a Game Boy / Game Boy Color flash cartridge. Its menu/OS
firmware (the "kernel") runs on the stock Game Boy CPU (SM83) and, unlike its
GBA sibling the [EZ Flash Omega](https://github.com/ez-flash/omega-de-kernel),
ships only as a compiled binary with no published source.

This repo reverse-engineers that kernel and adds new features you can compile
into your own cartridge.

## Where the project is

The reverse engineering is essentially done:

- **Full disassembly.** Every bank is labeled, and it reassembles to the exact
  original firmware (both the 1.04e and 1.05e builds; only 3 cosmetic
  ROM-header bytes differ).
- **Hardware understood:** the FPGA unlock/command/commit registers, SD sector
  I/O, bank switching, PSRAM save storage, the board, and the ROM launch path.
  See [`docs/hardware-board.md`](docs/hardware-board.md),
  [`docs/REGISTERS.md`](docs/REGISTERS.md),
  [`docs/fpga-flash-map.md`](docs/fpga-flash-map.md),
  [`docs/launch-trace.md`](docs/launch-trace.md).
- **Code injection works.** You can compile C, place it in verified-free ROM,
  hook it into the kernel, and run it on real hardware and in emulator. The
  features below are built on this. Recipe and free-space map:
  [`docs/inject-smoke-test.md`](docs/inject-smoke-test.md).

## Features you can build in

Self-contained patches against the 1.05e kernel. Apply the ones you want,
produce an `ezgb.dat`, and run it. Each doc has the rationale, wiring, and exact
commands.

| Feature | What it does | Doc |
|---|---|---|
| **Sorted browser** | Directories first, then files, each group alphabetical (case-insensitive), instead of raw FAT order. | [`docs/browser-sort.md`](docs/browser-sort.md) |
| **Continuous scrolling** | DOWN/UP scroll one line past the screen edge instead of stopping at the top/bottom row. | `decomp/src/browser_scroll.c` |
| **Snappy down-scroll** | Repaints bottom-up so the new entry appears immediately on DOWN. | [`docs/browser-scroll-repaint.md`](docs/browser-scroll-repaint.md) |
| **RIGHT jumps to end** | RIGHT on the last page moves the cursor to the bottom entry, mirroring LEFT at the top. | [`docs/browser-page-end.md`](docs/browser-page-end.md) |
| **Hide macOS cruft** | Filters `._*` sidecars, `.DS_Store`, `.Spotlight-V100/` etc. that a Mac scatters on the card and the stock browser lists. | [`docs/browser-dotfile-filter.md`](docs/browser-dotfile-filter.md) |

**In progress:** an Omega DE-style **Mode B** that boots straight into one ROM
without the file browser. The launch path and last-ROM persistence are mapped
([`docs/last-rom.md`](docs/last-rom.md)); the boot-hook wiring is deferred
([`docs/fast-launch-notes.md`](docs/fast-launch-notes.md)).

**Tested dead end:** running the kernel in CGB mode (to unlock the GBC IR port)
cannot be reached at first boot without FPGA firmware changes. Kept as a record,
not shipped: [`docs/cgb-mode.md`](docs/cgb-mode.md).

## Building a modded kernel

You supply your own firmware dump; this repo does not redistribute EZ Flash's
binaries. Drop it at `re/1.05e/kernel.gb` (a copy of the `ezgb.dat` from the
official firmware package), then:

```sh
# 1. Regenerate the disassembly from your dump (one-time per version)
cd re/1.05e
python3 ../../tools/mgbdis/mgbdis.py kernel.gb --overwrite
../../scripts/annotate-disasm.py 1.05e

# 2. Apply features (example: sorted browser; see each doc for its commands)
cd ../../decomp
python3 tools/inject.py src/browser_sort.c 1.05e 8 746b BrowserSortAll \
    --pin DirList=0a43 --apply
python3 tools/inject_bytes.py 1.05e 0 03d4 BrowserSortAllStub \
    cd8d076b740800c9 --apply
python3 tools/patch_call.py 1.05e 0 102f 3 00:03d4 --apply --regen

# 3. Stage as ezgb.dat and build the emulator card image
cd ..
scripts/build-ezgb-dat.sh 1.05e
scripts/make-sd-image.sh
```

Injection edits `re/1.05e/kernel.gb` in place, so it becomes the patched
artifact. Run it in SameBoy (with the EZ Jr FPGA stub, see
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md#tools)), or copy `ezgb.dat` to the
root of a real cart's microSD. Hook-site rules and the free-space map:
[`docs/inject-smoke-test.md`](docs/inject-smoke-test.md).

## Repo layout

```
re/               Disassemblies, one dir per firmware version (1.04e, 1.05e, 1.05e-0918)
  1.05e/          Primary target; disassembly/ reassembles to the original
    kernel.sym    Persistent names     (kernel.gb is your own dump, not tracked)
    notes.json    Persistent comments
decomp/           Matching C decompilation + injectable feature sources
  src/            browser_sort.c, browser_scroll*.c, cgb_init.c, ...
  tools/          inject.py, inject_bytes.py, patch_call.py, verify.py
docs/             Findings, feature write-ups, hardware notes
scripts/          Disassembly regen, mapping loop, SD image, SameBoy helpers
patches/sameboy/  EZ Jr FPGA stub as diffs over a pinned SameBoy commit
sd/               Local microSD image for the emulator     (see sd/README.md)
fpga/, tools/     FPGA dumps and cloned reference repos     (not tracked)
```

Untracked paths are gitignored: EZ Flash's copyrighted binaries (firmware,
`kernel.gb`, FPGA bitstreams) or third-party repos. A fresh checkout supplies
its own dump and re-clones `tools/` (see
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md#tools)). Name a specific version;
the FW5 packages differ
([`docs/DIFF_1.05e-0731_vs_0918.md`](docs/DIFF_1.05e-0731_vs_0918.md)).

## Digging deeper

- **[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)**: rebuild the disassembly,
  name functions, inject code, verify the decompilation, set up tools. Start
  here to contribute.
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
- **Methodology:** [`docs/MAPPING.md`](docs/MAPPING.md),
  [`docs/MAP-SESSION.md`](docs/MAP-SESSION.md),
  [`docs/INTERIOR-NAMING.md`](docs/INTERIOR-NAMING.md).

## License

AGPLv3, see [LICENSE](LICENSE). Covers this project's own work (disassembly,
notes, tooling, feature code). It does not relicense EZ Flash's original
firmware, which is not redistributed here.
