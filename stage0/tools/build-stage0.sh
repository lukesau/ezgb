#!/bin/sh
# Build stage0 from the readable Verilog with stage1 in it, prove it, and
# wrap it in an updater: one step.
#
#   BUILD_HOST=<host> stage0/tools/build-stage0.sh fw4|fw5-0918|fw6 [LABEL OUT.gb]
#
# STAGE1=ours (default) or stock picks stage1 as build-stage1-updater.sh
# does; PATCHES=0 leaves the PicoBlaze programs stock. Steps:
#   1. stage1 built and split into block RAM blobs; the PicoBlaze's two
#      programs assembled from their listings (stage0/<fw>/picoblaze), with
#      our patches unless PATCHES=0
#   2. mkise.py: the ISE project, every register in its stock cell
#      (stage0/ise/<fw>.place)
#   3. build-ise.sh: synthesis, place and route, bitgen on the build host,
#      and its block RAMs decoded back to the stage1 and programs that went in
#   4. the proof: stock slot B exported (fpga/<fw>, from the official
#      updater) and the result proven equivalent to it (prove-ise.py); FW5's
#      block files come from fw5-prove.sh (fpga/fw5-nx/edge/blk)
#   5. the updater, when LABEL and OUT.gb are given: its program built from
#      source (stage0/updater) with the new slot B after it
# Only step 4 needs anything of EZ Flash's. PROVE=0 skips it, for a build
# without the official updater.
# Work in fpga/ise/<fw>-<stage1>[-nopatch]/ (ignored).
set -e
fw=${1:?usage: build-stage0.sh fw4|fw5-0918|fw6 [LABEL OUT.gb]}; label=$2; out=$3
host=${BUILD_HOST:?set BUILD_HOST to the build host}
repo=$(cd "$(dirname "$0")/../.." && pwd)
stage1=${STAGE1:-ours}; patches=${PATCHES:-1}; prove=${PROVE:-1}
case $fw in
fw4)      stock_updater=$repo/tools/ezflashjr/official/2020-03-10_FW4_K1.04e/Update_FW4.gb
          layout=; decomp=fw4; blocks=; bank2_psm=fw4/picoblaze/X3Y25.psm; bank2_def=
          bank2=D0X3Y25; bank1=D0X3Y29; bank1_psm=fw4/picoblaze/X3Y29.psm; bank1_patch= ;;
fw5-0918) stock_updater=$repo/tools/ezflashjr/official/2021-09-18_FW5_K1.05e/Update_FW5_2021-9-18.gb
          layout="--layout fw5-0918"; decomp=fw5
          blocks="--blocks $repo/fpga/fw5-nx/edge/blk"; bank2_psm=fw4/picoblaze/X3Y25.psm; bank2_def=
          bank2=D0X3Y5; bank1=D0X3Y1; bank1_psm=fw5-0918/picoblaze/bank1.psm
          bank1_patch=$repo/stage0/sd-recover-fw5-0918.psm
          bank1_allow="--allow 12B --allow 19F --allow 1A0 --allow 1A5 --allow 224 --allow 23A --allow 326 --allow 370 --allow 377" ;;
# FW6: stage1 is FW5-0918's stored as bytes, bank 2 has its own listing
# (one instruction fewer), and the read patch's two routines sit a word lower
fw6)      stock_updater=$repo/tools/ezflashjr/official/2026-11-27_FW6_K1.06e/Update_FW6_20261127.gb
          layout="--layout fw6"; decomp=fw5; blocks=
          bank2=D0X19Y25; bank2_psm=fw6/picoblaze/bank2.psm; bank2_def="--define TBL_READ=226 --define FLASH_UPDATE=22E"
          bank1=D0X19Y29; bank1_psm=fw6/picoblaze/bank1.psm
          bank1_patch=$repo/stage0/sd-recover-fw5-0918.psm
          bank1_allow="--allow 12B --allow 19F --allow 1A0 --allow 1A5 --allow 224 --allow 23A --allow 326 --allow 370 --allow 377" ;;
*)        echo "unknown firmware: $fw" >&2; exit 2 ;;
esac
db=${S3DB:-$repo/fpga/db/spartan3.zstd}
export S3DB=$db

if [ "$prove" != 0 ]; then
    [ -f "$repo/fpga/$fw/design.v" ] || [ -f "$stock_updater" ] || { echo "no stock export (fpga/$fw) or official updater ($stock_updater): PROVE=0 builds without the proof" >&2; exit 1; }
    [ -z "$blocks" ] || [ -f "$repo/fpga/fw5-nx/edge/blk/picoblaze.blk" ] || { echo "run stage0/tools/fw5-prove.sh first (fpga/fw5-nx)" >&2; exit 1; }
fi

# 1. stage1 and the PicoBlaze's programs as blobs
w=$repo/fpga/ise/$fw-$stage1
[ "$patches" = 0 ] && w=$w-nopatch
rm -rf "$w"; mkdir -p "$w/blobs"
case $stage1 in
ours)  "$repo/stage1/build.sh" 2>/dev/null | grep -v "Overwrote"; s1=$repo/fpga/stage1/stage1.gb ;;
stock) make -s -C "$repo/stage1/decomp" build/$decomp/stage1.gb; s1=$repo/stage1/decomp/build/$decomp/stage1.gb ;;
*)     echo "STAGE1 is ours or stock, not $stage1" >&2; exit 2 ;;
esac
cp "$s1" "$w/stage1.gb"
"$repo/stage1/tools/stage1-to-bram.py" "$w/stage1.gb" "$w/blobs" $layout > /dev/null
# the PicoBlaze's programs from their listings; bank 2 (the flash, the
# license check, the hand-over) is the same program on FW4 and FW5
mkdir -p "$w/pb"
pbdis=$repo/stage0/tools/picoblaze-dis.py
python3 "$pbdis" --assemble "$repo/stage0/$bank2_psm" "$w/pb/$bank2.BEL.BRAM"
python3 "$pbdis" --assemble "$repo/stage0/$bank1_psm" "$w/pb/$bank1.BEL.BRAM"
patched=
if [ "$patches" != 0 ]; then
    "$repo/stage0/tools/picoblaze-patch.py" "$w/pb/$bank2.BEL.BRAM" \
        "$repo/stage0/flash-read.psm" "$w/blobs" --tile $bank2 --allow 1B7 $bank2_def > /dev/null
    patched=$bank2
    if [ -n "$bank1_patch" ]; then
        "$repo/stage0/tools/picoblaze-patch.py" "$w/pb/$bank1.BEL.BRAM" \
            "$bank1_patch" "$w/blobs" --tile $bank1 $bank1_allow > /dev/null
        patched="$bank2 $bank1"
    fi
fi

# 2-3. the ISE build
python3 "$repo/stage0/tools/mkise.py" "$w/proj" --fw $fw --bram "$w/blobs" --bram "$w/pb" --place
"$repo/stage0/tools/build-ise.sh" "$w/proj" > "$w/build.txt" 2>&1 || { cat "$w/build.txt" >&2; exit 1; }
grep "Timing errors" "$w/build.txt"
grep -q "Timing errors: 0 " "$w/build.txt" || { echo "timing not met: $w/proj/top.twr" >&2; exit 1; }

# stage1 and the programs back out of the block RAMs
"$repo/stage1/tools/stage1-from-bram.py" "$w/proj/bram" -o "$w/stage1-check.gb" --ref "$w/stage1.gb" ${layout:+--discover} | tail -1 | grep -q True \
    || { echo "stage1 is not in the block RAMs" >&2; exit 1; }
for b in $bank2 $bank1; do
    d=$w/pb/$b.BEL.BRAM; case " $patched " in *" $b "*) d=$w/blobs/$b ;; esac
    for p in DATA DATAP; do
        cmp -s "$d.$p.bin" "$w/proj/bram/$b.BEL.BRAM.$p.bin" || { echo "$b: the PicoBlaze program is not in the block RAM" >&2; exit 1; }
    done
done
echo "round trip: stage1 and the PicoBlaze programs match"

if [ "$prove" = 0 ]; then
    echo "built, not proven (PROVE=0): $w/proj/top.raw"
else
# 4. the proof against stock
exp=$repo/fpga/$fw
if [ ! -f "$exp/design.v" ]; then
    mkdir -p "$exp"
    python3 -c "import sys; d = open(sys.argv[1], 'rb').read(); open(sys.argv[2], 'wb').write(d[0x8000:0x8000 + 149516])" \
        "$stock_updater" "$exp/slotB.bin"
    "$repo/stage0/tools/export-netlist.sh" "$exp/slotB.bin" "$exp" > /dev/null
fi
"$repo/stage0/tools/export-netlist.sh" "$w/proj/top.raw" "$w/export" > "$w/export.txt"
python3 "$repo/stage0/tools/prove-ise.py" "$exp" "$w/export" "$w/proj" --swap64 $blocks > "$w/prove.txt" 2>&1 \
    || { grep -v "^Warning" "$w/prove.txt" >&2; exit 1; }
grep -v "^Warning" "$w/prove.txt"
fi

# 5. the updater: its program from source (stage0/updater) with this slot B
# after it. UPDATER=stock swaps the payload inside the official updater
# instead, which also keeps the second, unwritten bitstream FW5's carries.
if [ -n "$out" ]; then
    if [ "${UPDATER:-source}" = stock ]; then
        python3 "$repo/stage0/tools/make-updater.py" "$stock_updater" "$w/proj/top.raw" "$out" --label "$label"
    else
        python3 "$repo/stage0/updater/tools/link.py" $fw --label "$label" --payload "$w/proj/top.raw" -o "$out" | tail -1
    fi
fi
