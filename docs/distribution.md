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
install and go back. The repo's README is not attached.

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

Our slot B (stage1 plus the bank 2 flash read patch) is kept the same way:
an IPS from EZ Flash's stock updater to ours, one per firmware
(`Update_FW4.gb` and `Update_FW5_2021-9-18.gb`), in `patches/updater/` with
its own `manifest.json` (stock and patched md5s, and the stage1 version from
`stage1/VERSION`). It is kept apart from `patches/kernel/` so `make-dist.sh`
doesn't take it for a kernel.

**Released as IPS files since mod 6.9 / firmware 1.9**, named
`ezgb-firmware-mod-F-for-<fw>.ips`, with their stock and patched md5s in the
release README behind a brick warning. The patcher page (below) stays the
recommended route because it patches nothing but the exact stock updater;
someone using a generic patcher on the wrong updater gets a slot B that
fails its CRC (see "Wrong patch"). `make-dist.sh` checks both firmware
patches against their manifest md5 and copies them into the release folder.

```sh
# maintainer: build the updater, then diff it against the stock one
BUILD_HOST=<build host> scripts/fpga/build-stage1-updater.sh fw5-0918 "Update: FW5 v5rd" fpga/load/Update_FW5-0918-stage1-v5.gb
scripts/kernel-patch.py updater make fw5-0918 fpga/load/Update_FW5-0918-stage1-v5.gb

# from a checkout: patch the official updater (md5-checked on both sides)
scripts/kernel-patch.py updater apply Update_FW5_2021-9-18.gb
```

The patch carries only bytes that differ from the stock updater: the stage1
and bank 2 BRAM frames, the screen label, and the bitstream and header
checksums. Patching is byte-granular, so a changed byte can still hold
unchanged bits of the stock bank 2 program, as with the kernel patches.

## The patcher page

`scripts/make-patcher-page.py` writes `dist/patcher/index.html`, one
self-contained page (template `scripts/patcher/patcher.html`) with every
kernel and firmware patch inlined. It runs entirely in the browser: the
chosen file is hashed (SHA-256, with SHA-1 shown because EZ Flash publishes
SHA-1) and patched only when it is a stock file the page knows, always with
that file's patch; the result is hashed again before it can be saved.
Already-patched files, the FW5 2020-7-31 updater and anything unknown are
refused. The firmware section stays disabled until the risk notice is
acknowledged. Hashing needs a secure context, so the page has to be served
over https. Hosted on GitHub Pages at `https://lukesau.github.io/ezgb/patcher/`
(`scripts/publish-patcher.sh` builds it onto the `gh-pages` branch and
pushes; `--hold fw4` keeps a firmware off the page until it has run on a
cart). The release README prints that URL (`PATCHER_URL` in `make-dist.sh`).

**Counting patches.** After each patch that passes its output hash check the
page loads `https://lukesau.com/ezgb/p.gif?k=<patch id>&t=<ms>` (ids
`k-<kernel>`, `f-<firmware>`), a 1x1 GIF on lukesau.com, so each patch is one
hit in that server's access log. No file data leaves the browser. The tally
is kept on that server and isn't part of this repository.

## Wrong patch

An ordinary IPS patcher writes a patch over any file, so every mix-up was
tested (`scripts/test-patch-mismatch.py`, `--boot` for the kernel runs):

- **Firmware patch on another updater** (each patch on each of the three
  stock updaters). Below `$8000` a patch changes only the screen label (the
  same string at `$11d8` in every updater) and the global checksum, so the
  updater program runs as stock and writes its slot B region (file `$8000`,
  149,516 bytes). In every wrong combination that region is a mix of two
  bitstreams whose CRC packets fail (no image sets the CRC bypass), while
  every stock and correctly patched image passes. The FPGA does not
  configure from a bad CRC, and the boot tally then keeps the cart on its
  slot A ([picoblaze.md](../re/stage0/docs/picoblaze.md#at-boot-3f--0)), so
  the right updater can be run again. The fallback is confirmed on the FW4
  Jr (2026-10-12, two bad slot B writes each recovered to stock FW4); no FW5
  cart's slot A has been dumped yet, so on FW5 it is still inferred from the
  updater writing the same slot.
- **Kernel patch on another kernel.** A 1.05e patch on 1.04e, or the
  reverse, halts on an illegal opcode at boot: blank screen, no SD or flash
  write. 1.05e-0731 and 1.05e-0918 differ only in bank 1, so either patched
  with the other's patch used to boot to a normal browser while its bank-1
  hooks sat inside the stock `BackupSaveDump` write loop and
  `BootUnpackWramTables`: the first save backup would have corrupted the
  `.sav`. Since mod 6.9 the kernel checks at boot that `BuildSaverBackupPath`
  opens where its patch expects it (`PatchGuard`, `01:7d70`,
  [kernel/src/patch_guard.c](../kernel/src/patch_guard.c), called first in
  ezcfg's boot op through `FarCallPatchGuard` `02:43c0`) and otherwise stops
  on a WRONG PATCH screen before the BACKUPSAVE check. In SameBoy no mix-up
  writes the card or touches `$7FD2`/`$7FD3`.

`scripts/kernel-patch.py apply` and `updater apply` refuse a wrong base by
md5, and so does the patcher page by SHA-256; the guard and the CRC are what
protect someone using a generic patcher.

