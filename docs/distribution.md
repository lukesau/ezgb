# Getting a modded kernel: patch or build

The modded kernel is EZ Flash's firmware with this project's code injected,
so a built `ezgb.dat` is never posted, GitHub Releases included. Only the
difference between stock and modded is distributed, as IPS patches.

| | You need | You run |
|---|---|---|
| **Patch** | the official `ezgb.dat` and an `.ips` | the [patcher page](https://lukesau.github.io/ezgb/patcher/), `scripts/kernel-patch.py`, or any IPS patcher |
| **Build** | this repo, rgbds, Python 3 | `scripts/build-kernel.sh` |

Both produce the same bytes.

## Patching

Take `ezgb.dat` from EZ Flash's firmware package for your kernel
([which one](kernel-versions.md)), then:

```bash
scripts/kernel-patch.py apply ~/Downloads/ezgb.dat
```

The script detects the version by md5, refuses a wrong or already patched
file, verifies the result, and writes `ezgb-patched.dat` beside the input
(`-o PATH` to choose). Copy it to the card root as `ezgb.dat`.

The patches are plain IPS, so Flips, Lunar IPS or an online patcher also
work, but they check nothing. Compare md5s by hand against
[`patches/kernel/manifest.json`](../patches/kernel/manifest.json), which
records the stock and patched md5 of every version.

The 1.04e kernel runs on FW4 and FW5 carts alike, so a cart on FW4 needs no
firmware update to use the mod.

## Building

The committed disassembly reassembles the modded kernel, with no firmware
download:

```bash
scripts/build-kernel.sh 1.05e-0731            # kernel/1.05e-0731/disassembly/game_trunc.gb
scripts/build-kernel.sh 1.05e-0918 --install  # also copies it to kernel/1.05e-0918/kernel.gb
```

It runs `make` in `kernel/<ver>/disassembly` and then restores the four
header bytes `rgbfix` rewrites: `$0148` (ROM size), `$014D` (header
checksum) and `$014E`-`$014F` (global checksum, stale in the shipped
firmware; nothing verifies it). The result is checked against `patched_md5`
in the manifest. A mismatch means the disassembly has changes the patches
have not picked up yet, or a broken build.

## What a release carries

A release is tagged `mod-N.M`, from `patches/kernel/VERSION`, and carries:

- `ezgb-mod-N.M-for-<ver>.ips`, one per kernel
- `ezgb-firmware-mod-F-for-<fw>.ips`, one per firmware
- `manifest.json`
- `README.txt`, a patching guide rendered by `scripts/make-dist.sh` from
  [`patches/kernel/release-README.txt`](../patches/kernel/release-README.txt)
  with the version and the md5 table filled in

```sh
gh release create mod-N.M --title mod-N.M --notes-file notes.md \
    dist/mod-N.M/*.ips patches/kernel/manifest.json dist/mod-N.M/README.txt
```

`make-dist.sh` checks every patch against its manifest before copying it
into `dist/mod-N.M/`, and also writes each patched kernel there for copying
to a card. Those `.dat` files stay on the machine.

## The firmware updater patch

The firmware mod is kept the same way: an IPS from EZ Flash's stock updater
to ours, one per firmware (`Update_FW4.gb` and `Update_FW5_2021-9-18.gb`),
in `patches/updater/` with its own `manifest.json` (stock and patched md5s,
and the stage1 version from `stage1/VERSION`).

```sh
# maintainer: build the updater, then diff it against the stock one
BUILD_HOST=<host> stage0/tools/build-stage1-updater.sh fw5-0918 "To FW5-MOD 2.1" out.gb
scripts/kernel-patch.py updater make fw5-0918 out.gb

# anyone: patch the official updater, md5-checked on both sides
scripts/kernel-patch.py updater apply Update_FW5_2021-9-18.gb
```

The screen label is at most 16 characters, and names the firmware so the
updater says which cart it is for.

The patch carries only the bytes that differ from the stock updater: the
stage1 and PicoBlaze BRAM frames, the screen label, and the bitstream and
header checksums. How the updater is built is in
[fpga-setup.md](fpga-setup.md).

## The patcher page

`scripts/make-patcher-page.py` writes `dist/patcher/index.html`, one
self-contained page (template `scripts/patcher/patcher.html`) with every
kernel and firmware patch inlined. It runs entirely in the browser:

- The chosen file is hashed and patched only when it is a stock file the
  page knows, always with that file's patch.
- The result is hashed again before it can be saved.
- Already patched files, the FW5 2020-7-31 updater and anything unknown are
  refused.
- The firmware section stays disabled until the risk notice is
  acknowledged.

Hashing needs a secure context, so the page has to be served over https.
`scripts/publish-patcher.sh` builds it onto the `gh-pages` branch and
pushes; `--hold fw4` keeps a firmware off the page until it has run on a
cart.

After each successful patch the page requests a 1x1 GIF from lukesau.com
with the patch id and mod version, so patches can be counted. No file data
leaves the browser.

## Wrong patch

An ordinary IPS patcher writes a patch over any file, so every mix-up is
tested (`scripts/test-patch-mismatch.py`, `--boot` for the kernel runs).

**A firmware patch on another updater.** The updater program itself runs as
stock and writes its slot B region. In every wrong combination that region
is a mix of two bitstreams whose CRC packets fail, while every stock and
correctly patched image passes. The FPGA does not configure from a bad CRC,
and the boot tally then keeps the cart on slot A
([picoblaze.md](../stage0/docs/picoblaze.md#at-boot-3f--0)), so the right
updater can be run again. The fallback is confirmed on an FW4 cart. On FW5
it is inferred from the updater writing the same slot.

**A kernel patch on another kernel.** A 1.05e patch on 1.04e, or the
reverse, halts on an illegal opcode at boot: blank screen, nothing written.
1.05e-0731 and 1.05e-0918 differ only in bank 1, so either one patched with
the other's patch would boot to a normal browser with its bank-1 hooks
sitting inside stock code, and the first save backup would corrupt the
`.sav`. The kernel therefore checks at boot that `BuildSaverBackupPath`
opens where its patch expects (`PatchGuard`, `01:7d70`,
[patch_guard.c](../kernel/mod/src/patch_guard.c)) and otherwise stops on a
WRONG PATCH screen before it touches a save.

`kernel-patch.py apply` and `updater apply` refuse a wrong base by md5, and
the patcher page by SHA-256. The guard and the CRC protect someone using a
generic patcher.
