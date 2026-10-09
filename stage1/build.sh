#!/bin/sh
# Build stage1 from source: stage1.gb, 32 KB, for the FW4 slot B BRAMs.
# Needs SDCC (sm83), rgbfix, and the icon tiles from the splash build
# (fpga/bootsplash/build/icon.2bpp, re/fpga-fw4/bootsplash/build.sh).
# Output: fpga/stage1/ (ignored, like every built firmware image).
set -e
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
root=${EZGB_ROOT:-$repo}                  # checkout whose fpga/ holds inputs/outputs
out="$root/fpga/stage1"
b="$out/build"
mkdir -p "$b"

python3 "$repo/scripts/fpga/font8-pack.py" "$here/font/font8.txt" "$b/font8.c"
python3 - "$root/fpga/bootsplash/build/icon.2bpp" "$b/icon.c" <<'PY'
import sys
data = open(sys.argv[1], "rb").read()
assert len(data) == 6 * 7 * 16, len(data)
with open(sys.argv[2], "w") as f:
    f.write("#include <stdint.h>\nconst uint8_t icon_tiles[%d] = {\n" % len(data))
    for i in range(0, len(data), 16):
        f.write("    " + ", ".join("0x%02X" % x for x in data[i:i + 16]) + ",\n")
    f.write("};\n")
PY

python3 "$repo/scripts/fpga/mkwordmark.py" "$here/art/ezflash.txt" "$here/art/jr.txt"     "$b/wordmark.c" --jr-at 86,4 --pivot 0,0 \
    --width 16 --height 4 --letters-x 10 --stages 4 ${WORDMARK_FLAGS:---no-halo} > "$b/wordmark.txt"

# stage1/VERSION: line 1 the firmware number (what the version register
# should read), line 2 the mod version; shown as FW6-MOD 1.0
fw=$(sed -n 1p "$here/VERSION"); mod=$(sed -n 2p "$here/VERSION")
printf '#define FW_NUMBER %s\n#define FW_TEXT "FW%s-MOD %s"\n' "$fw" "$fw" "$mod" > "$b/version.h"
CFLAGS="-msm83 --opt-code-size --max-allocs-per-node 20000 -I$here/src -I$b ${STAGE1_CFLAGS:-}"
rels=""
for c in "$here"/src/*.c "$b/font8.c" "$b/icon.c" "$b/wordmark.c"; do
    o="$b/$(basename "${c%.c}").rel"
    sdcc $CFLAGS -c "$c" -o "$o"
    rels="$rels $o"
done
for s in crt0 handoff game_handoff; do
    sdasgb -plosgff -o "$b/$s.rel" "$here/src/$s.s"
done
sdldgb -n -m -w -i "$b/stage1.ihx" -b _HOME=0x0150 -b _CODE=0x0200 -b _DATA=0xC000 \
    -k "$(dirname "$(which sdcc)")/../share/sdcc/lib/sm83" -l sm83 \
    "$b/crt0.rel" "$b/handoff.rel" "$b/game_handoff.rel" $rels
makebin -s 32768 "$b/stage1.ihx" "$b/stage1.raw"

# $0000-$47FF is BRAM; $4800-$7FFF has nothing behind it and must be zero
python3 - "$b/stage1.raw" "$out/stage1.gb" <<'PY'
import sys
d = bytearray(open(sys.argv[1], "rb").read())
used = max(i for i, x in enumerate(d) if x not in (0x00, 0xFF)) + 1
if used > 0x4800:
    sys.exit(f"stage1 is {used:#x} bytes: over the $4800 the BRAMs hold")
for i in range(0x4800, 0x8000):
    d[i] = 0
open(sys.argv[2], "wb").write(d)
print(f"stage1: {used} bytes used of {0x4800}")
PY
rgbfix -v -c -t BOOTLOADER -p 0 "$out/stage1.gb"
