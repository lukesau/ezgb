# Getting a modded kernel: patch or build

The modded kernel is ~160KB of EZ Flash's copyrighted firmware with a few KB
of this project's code injected, so a built `ezgb.dat` is never posted
publicly (GitHub Releases included). Only the *difference* between stock and
modded — the code this project wrote — is distributed, as IPS patches.

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

The patches are plain IPS, so any standard tool also works — Flips, Lunar
IPS, an online ROM patcher — but those don't check md5s. Verify by hand
against [`patches/kernel/manifest.json`](../patches/kernel/manifest.json),
the authoritative record of each version's stock and patched md5 (regenerated
with each patch, so patched md5s are not duplicated here).

Stock bases:

| Version | Stock `ezgb.dat` md5 |
|---|---|
| 1.05e-0731 | `91eb7fc67332ef20b5691029181ff748` |
| 1.05e-0918 | `5238ac5987d23b68a19d40e43af8c786` |

These are the `ezgb.dat` files inside the official
`juniorkernel-1.05e-FW5-*` packages.

## Option B: build from the disassembly

The committed disassembly reassembles the modded kernel directly — no
firmware download needed:

```bash
scripts/build-kernel.sh 1.05e-0731            # -> re/.../disassembly/game_trunc.gb
scripts/build-kernel.sh 1.05e-0918 --install  # also copy to re/.../kernel.gb
```

This runs `make` in `re/<ver>/disassembly`, then undoes two rgbds behaviors
the shipped firmware doesn't have: it truncates the 256KB-padded output back
to the real 160KB (10 banks), and restores the 4 header bytes rgbfix
"corrects" (`$0148` ROM size, `$014D` header checksum, `$014E-$014F` global
checksum — stale in the shipped firmware, and nothing verifies them). The
result is verified against `patched_md5` in the manifest; `--install` puts it
at `re/<ver>/kernel.gb`, where `scripts/build-ezgb-dat.sh` and the SameBoy
scripts expect it.

A mismatch against the manifest means either the disassembly has changes the
patch hasn't picked up yet (see below) or a broken build.

Since the disassembly reassembles the ROM, the `bank_*.asm` files are the
firmware in source-encoded form — the repo sits in the same
tolerated-but-gray zone as other proprietary-binary decomp projects. That is
another reason only patches ship in Releases: attaching a built binary would
escalate from "repo you can build" to "binary handed out".

## Maintainers: regenerating the patches

After changing any injection (and regenerating/re-injecting per the feature
docs), refresh the IPS and manifest from the canonical artifacts
(`re/<ver>/kernel.gb.orig` stock → `re/<ver>/kernel.gb` modded):

```bash
python3 scripts/kernel-patch.py make 1.05e-0731
python3 scripts/kernel-patch.py make 1.05e-0918
```

The command round-trips the patch before writing the manifest entry. Commit
`patches/kernel/*.ips` + `manifest.json` together with the source change.
Keep both versions in sync — the injected code is byte-identical across them
(bank 2 and bank 0 are identical in the stock kernels), so the two patches
should always change together.

For a GitHub Release: attach the `.ips` files (and optionally
`scripts/kernel-patch.py`); never `ezgb.dat`, `kernel.gb`, updater packages,
or FPGA bitstreams.
