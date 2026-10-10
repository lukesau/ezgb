#!/bin/sh
# Boot splash: icon tiles, lab ROM, and the stage1 build for FW4 slot B.
# Inputs (untracked, EZ Flash's): fpga/bootsplash/ezflash-logo.png (marketing
# logo, icon on the left) and fpga/cgb/stage1-fw4.gb (stock stage1 rebuilt
# from the bitstream by stage1-from-bram.py). Outputs go to fpga/bootsplash/.
set -e
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../../.." && pwd)        # tools come from this checkout
root=${EZGB_ROOT:-$repo}                  # checkout whose fpga/ holds the inputs
out="$root/fpga/bootsplash"
mkdir -p "$out/build"
cd "$out"
python3 "$repo/scripts/fpga/mkicon.py" ezflash-logo.png build > build/icon.txt
for src in splash stage1-splash; do
    rgbasm -I "$out/" -o "build/$src.o" "$here/$src.asm"
done
rgblink -o splash.gb -n splash.sym build/splash.o
rgbfix -v -c -p 0xFF -t SPLASH splash.gb
rgblink -O "$root/fpga/cgb/stage1-fw4.gb" -o stage1-splash.gb -n stage1-splash.sym build/stage1-splash.o
rgbfix -f h stage1-splash.gb
tail -1 build/icon.txt
