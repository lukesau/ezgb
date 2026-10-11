# Getting a modded kernel: patch or build

The modded kernel is ~160KB of EZ Flash's copyrighted firmware with a few KB
of this project's code injected, so a built `ezgb.dat` is never posted
publicly (GitHub Releases included). Only the *difference* between stock and
modded (the code this project wrote) is distributed, as IPS patches.

There are two supported ways to get a modded kernel:

| | You need | You run |
|---|---|---|
| **A. Patch** | official `ezgb.dat` + a file from `patches/kernel/` | any IPS patcher |
| **B. Full build** | this repo + rgbds + Python 3 | `scripts/build-kernel.sh` |

Both produce byte-identical output.

## Option A: patch the official firmware (recommended for users)

1. Download the official firmware package for your kernel version from EZ
   Flash's site and take its `ezgb.dat`.
2. Apply the matching IPS from [`patches/kernel/`](../patches/kernel/):

```bash
python3 scripts/kernel-patch.py apply ~/Downloads/ezgb.dat
```

The script detects the version by md5, refuses a wrong or already-patched
base, verifies the result, and writes `ezgb-patched.dat` beside the input
(`-o PATH` to choose). Rename it to `ezgb.dat` on the card root.

The patches are plain IPS, so any standard tool (Flips, Lunar IPS, an online
ROM patcher) also works, but those don't check md5s. Verify by hand
against [`patches/kernel/manifest.json`](../patches/kernel/manifest.json),
the authoritative record of each version's stock and patched md5 (regenerated
with each patch, so patched md5s are not duplicated here).

Stock bases:

| Version | Stock `ezgb.dat` md5 |
|---|---|
| 1.04e | `b8c29fa5a94c37200434e4c72f0cdfea` |
| 1.05e-0731 | `91eb7fc67332ef20b5691029181ff748` |
| 1.05e-0918 | `5238ac5987d23b68a19d40e43af8c786` |

These are the `ezgb.dat` files inside the official `juniorkernel-1.04e-FW4`
and `juniorkernel-1.05e-FW5-*` packages. The 1.04e kernel runs on FW4 and FW5
carts alike (the kernel is loaded from the card at every boot; nothing is
flashed), so a cart on FW4 needs no updater to use the mod.

### Release assets

A GitHub release carries, for the mod version in `patches/kernel/VERSION`:
the three `ezgb-mod-N.M-for-<ver>.ips` files, `manifest.json`, and the
`README.txt` that `scripts/make-dist.sh` renders into `dist/mod-N.M/` from
[`patches/kernel/release-README.txt`](../patches/kernel/release-README.txt)
(the version and the stock/modded md5 table filled in). That README is a
patching guide only: which build you have, which patcher to use, how to
install and go back. The repo's own README is not attached.

```sh
gh release create mod-N.M --title mod-N.M --notes-file notes.md \
    dist/mod-N.M/*.ips patches/kernel/manifest.json dist/mod-N.M/README.txt
```

## Option B: build from the disassembly

The committed disassembly reassembles the modded kernel directly, with no
firmware download needed:

```bash
scripts/build-kernel.sh 1.05e-0731            # -> re/.../disassembly/game_trunc.gb
scripts/build-kernel.sh 1.05e-0918 --install  # also copy to re/.../kernel.gb
scripts/build-kernel.sh 1.04e
```

This runs `make` in `re/kernel/<ver>/disassembly`, then undoes two rgbds behaviors
the shipped firmware doesn't have: it truncates the 256KB-padded output back
to the real 160KB (10 banks), and restores the 4 header bytes rgbfix
"corrects" (`$0148` ROM size, `$014D` header checksum, `$014E-$014F` global
checksum; all are stale in the shipped firmware, and nothing verifies them).
The result is verified against `patched_md5` in the manifest; `--install`
puts it at `re/kernel/<ver>/kernel.gb`, where the SameBoy scripts expect it;
`scripts/make-dist.sh` then lays out `dist/mod-N.M/` with a card-ready
`ezgb-mod-N.M-for-<ver>.dat` (rename to `ezgb.dat`) and the matching `.ips`
for every version.

A mismatch against the manifest means either the disassembly has changes the
patch hasn't picked up yet (the patches are regenerated per
[DEVELOPMENT.md](DEVELOPMENT.md#regenerating-the-kernel-patches)) or a
broken build.

## The firmware updater patch

Our slot B (stage1 plus the bank 2 flash read patch) ships the same way: an
IPS from EZ Flash's stock FW5-0918 updater (`Update_FW5_2021-9-18.gb`) to
ours, in `patches/updater/` with its own `manifest.json` (stock and patched
md5s, and the stage1 version from `stage1/VERSION`). It is kept apart from
`patches/kernel/` so `make-dist.sh` doesn't take it for a kernel.

```sh
# maintainer: build the updater, then diff it against the stock one
BUILD_HOST=<build host> scripts/fpga/build-stage1-updater.sh fw5-0918 "Update: FW5 v5rd" fpga/load/Update_FW5-0918-stage1-v5.gb
scripts/kernel-patch.py updater make fw5-0918 fpga/load/Update_FW5-0918-stage1-v5.gb

# user: patch the official updater (md5-checked on both sides)
scripts/kernel-patch.py updater apply Update_FW5_2021-9-18.gb
```

The patch carries only bytes that differ from the stock updater: the stage1
and bank 2 BRAM frames, the screen label, and the bitstream and header
checksums. Patching is byte-granular, so a changed byte can still hold
unchanged bits of the stock bank 2 program, as with the kernel patches.
