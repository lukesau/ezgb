# EZ Flash Jr modded kernel, mod {MODVER}

This folder holds one IPS patch per official kernel build. Applied to the
`ezgb.dat` from EZ Flash's own firmware package, each turns it into the modded
kernel. No firmware updater is involved: the Jr loads `ezgb.dat` from the
microSD card at every power-on, so installing is a file copy and going back
is copying the stock file again.

What the mod adds, and the source, is at https://github.com/lukesau/ezgb.

## 1. Find your kernel

Take `ezgb.dat` from the official firmware package you use (the file on your
card's root now, or the one inside the package zip). Match it against this
table; the md5 tells the three builds apart even when the package name does
not.

{TABLE}

`ezgb-mod-{MODVER}-for-<kernel>.ips` is the patch for that row. If your
`ezgb.dat` matches none of the stock md5s it is not a supported build, and
none of the patches will apply cleanly.

On macOS or Linux: `md5 ezgb.dat` or `md5sum ezgb.dat`. On Windows:
`certutil -hashfile ezgb.dat MD5`.

## 2. Apply the patch

Any IPS patcher works. Pick the stock `ezgb.dat` as the file to patch and the
matching `.ips` as the patch; the result is a new 163,840-byte file.

- Online, nothing to install: [Rom Patcher JS](https://www.marcrobledo.com/RomPatcher.js/)
  (runs in the browser, the file never leaves your machine).
- Windows: [Flips](https://github.com/Alcaro/Flips) or Lunar IPS.
- macOS: [MultiPatch](https://projects.sappharad.com/multipatch/) or Flips.
- Linux: Flips, or `python3 scripts/kernel-patch.py apply ezgb.dat` from a
  checkout of the repo, which detects the build by md5 and verifies the
  result for you.

The patched file's md5 must equal the "modded md5" in the table. If it does
not, the wrong patch was used or the input was not the stock file.

## 3. Install

Copy the patched file to the root of the microSD card as `ezgb.dat`, replacing
the one there. Keep the stock file somewhere (for example as `ezgb.dat.old` on
the card, where the browser will not list it) so you can go back.

Power on. The HELP tab shows `MOD {MODVER}` under the kernel version when the
modded kernel is running.

## Going back

Copy the stock `ezgb.dat` to the card root again. Nothing else on the card or
the cart is changed by the mod; the settings it writes live in `/EZGB.CFG`,
which the stock kernel ignores.
