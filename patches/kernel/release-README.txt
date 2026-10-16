EZ Flash Jr mod {MODVER}: kernel and firmware patches
================================================

This folder holds one IPS patch per supported kernel build (1.04e,
1.05e-0731 and 1.05e-0918; EZ Flash released other builds, which the mod
does not cover). Applied to the ezgb.dat from EZ Flash's own firmware
package, each turns it into the modded kernel. This is the safe option: no
firmware updater is involved. The Jr loads ezgb.dat from the microSD card at
every power-on. Swapping the kernel is as simple as changing a file and is
completely reversible.

What the mod adds, and the source, is at https://github.com/lukesau/ezgb

The same patches, plus the experimental firmware mod {FWVER}, are also on the
patcher page, which checks your file before patching it:

  {PATCHER_URL}

The firmware patches are in this folder too (section 4), but the patcher
page is the safer way to apply them: it refuses anything but the exact
stock updater each was built for, and explains the risk first.


1. Find your kernel
-------------------

Take ezgb.dat from the official firmware package you use (the file on your
card's root now, or the one inside the package zip). Match its md5 against
the list below; the md5 tells the supported builds apart even when the package
name does not.

{TABLE}

ezgb-mod-{MODVER}-for-<kernel>.ips is the patch for that kernel. If your
ezgb.dat matches none of the stock md5s it is not a supported build, and
none of the patches will apply cleanly.

  macOS:    md5 ezgb.dat
  Linux:    md5sum ezgb.dat
  Windows:  certutil -hashfile ezgb.dat MD5

Not sure which kernel to use? 1.04e is the build EZ Flash still offers for
download, and it runs on FW4 and FW5 carts alike, so no firmware updater is
ever needed to switch. EZ Flash took its FW5 packages (1.05e) down after
users bricked carts updating to them; the 1.05e patches are for people who
already run FW5. The stock packages, both from EZ Flash:
  1.04e / FW4:     https://www.ezflash.cn/download/  (EZ-FLASH Junior)
  1.05e-0918 FW5:  https://www.ezflash.cn/zip/ezjunior-fw5-0918.zip
The full comparison:
https://github.com/lukesau/ezgb/blob/main/docs/kernel-versions.md


2. Apply the patch
------------------

Any IPS patcher works. Pick the stock ezgb.dat as the file to patch and the
matching .ips as the patch; the result is a new 163,840-byte file.

  Online, nothing to install:
    Rom Patcher JS  https://www.marcrobledo.com/RomPatcher.js/
    (runs in the browser, the file never leaves your machine)
  Windows:
    Flips  https://github.com/Alcaro/Flips  (or Lunar IPS)
  macOS:
    MultiPatch  https://projects.sappharad.com/multipatch/  (or Flips)
  Linux:
    Flips, or from a checkout of the repo:
      python3 scripts/kernel-patch.py apply ezgb.dat
    which detects the build by md5 and verifies the result for you.

The patched file's md5 must equal the modded md5 in the list above. If it
does not, the wrong patch was used or the input was not the stock file.

If a kernel patched with another build's patch is booted anyway, it does not
start: 1.05e-0731 and 1.05e-0918 stop on a WRONG PATCH screen, and a 1.04e /
1.05e mix-up shows a blank screen. Neither writes to the card. Copy the stock
ezgb.dat back and use the patch made for it.


3. Install
----------

Copy the patched file to the root of the microSD card as ezgb.dat, replacing
the one there. Keep the stock file somewhere (for example as ezgb.dat.old on
the card, where the browser will not list it) so you can go back.

Power on. The HELP tab shows MOD {MODVER} under the kernel version when the
modded kernel is running.


4. Firmware mod {FWVER} (experimental)
----------------------------------

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!  THIS CAN BRICK YOUR CART. The patched updater rewrites the cart's  !!
!!  bootloader. A bootloader that runs and then hangs can't be fixed   !!
!!  with another updater: recovery needs an SPI programmer or JTAG.    !!
!!  Only flash it if you accept losing the cart.                       !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Apply each patch only to the updater it names, and check both md5s: a
patch applied to another updater writes a bootloader that fails its CRC
(the cart then falls back to its original one), but don't rely on that.
Use a fast microSD card and fresh batteries, install the kernel first,
launch the patched updater from the browser like a game, press A, and
don't power off until it says it's done.

{FWTABLE}

Going back from the firmware: run EZ Flash's official updater the same way.


Going back
----------

Copy the stock ezgb.dat to the card root again. Nothing else on the card or
the cart is changed by the mod. Its settings live in /EZGB.CFG, which the
stock kernel ignores, except the SGB BOOT checkbox on the SET tab: that one is
kept in the cart's battery-backed RAM, because it is read before the SD card
is up. The stock kernel never reads it either, so it does nothing after going
back. A dead or missing coin cell clears it, which turns SGB BOOT off.
