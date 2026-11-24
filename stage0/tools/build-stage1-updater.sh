#!/bin/sh
# Build a stage1 updater: our stage1 plus the bank 2 flash read patch
# (stage0/flash-read.psm) in slot B, and on FW5-0918 and FW6 the bank 1 SD
# error recovery patch (stage0/sd-recover-fw5-0918.psm), round-trip checked.
#
#   BUILD_HOST=<host> stage0/tools/build-stage1-updater.sh fw4|fw5-0918|fw6 LABEL OUT.gb
#
# BUILD_HOST=local runs s3patch and s3decode from stage0/tools/s3decode on
# this machine, with the database in fpga/db and the stock slot B image in
# fpga/cart/ (fw6.bin for FW6).
#
# STAGE1=ours (default) runs stage1/build.sh first; STAGE1=stock builds the
# stock stage1 from source instead (stage1/decomp, needs SDCC 2.9.0).
# PATCHES=0 leaves the PicoBlaze programs stock. STAGE1=stock PATCHES=0 is the
# check of the whole flow: the slot B it makes must be exactly stock's,
# and it stops there (no updater; LABEL and OUT.gb are not needed). The build host needs prjcombine's database and
# s3patch/s3decode (stage0/docs/setup.md), plus the stock slot B images
# ~/fpga/cart/fw4-updater.bin and ~/fpga/cart/fw5/0918.bin. Local inputs: the
# stock bank 2 BRAMs from fpga/fw4-decode/bram and fpga/fw5-decode/bram-0918,
# and FW5-0918's stock bank 1 from the latter; FW6's from fpga/fw6/bram.
# FW6's updater program is built from source (stage0/updater), FW5-0918's
# with the other label, and its stock stage1 is FW5-0918's.
# Stops first if the host is busy (host-check.sh).
set -e
fw=$1; label=$2; out=$3
stage1=${STAGE1:-ours}; patches=${PATCHES:-1}
check=; [ "$stage1" = stock ] && [ "$patches" = 0 ] && check=1
[ -n "$fw" ] && { [ -n "$check" ] || { [ -n "$label" ] && [ -n "$out" ]; }; } || { sed -n 5p "$0"; exit 2; }
host=${BUILD_HOST:?set BUILD_HOST to the build host}
repo=$(cd "$(dirname "$0")/../.." && pwd)
case $fw in
fw4)      layout=; bank2=D0X3Y25; bank2_in=fw4-decode/bram/D0X3Y25.BEL.BRAM; bank1=; s1fw=fw4
          base=fw4-updater.bin; stock=tools/ezflashjr/official/2020-03-10_FW4_K1.04e/Update_FW4.gb ;;
fw5-0918) layout="--layout fw5-0918"; bank2=D0X3Y5; bank2_in=fw5-decode/bram-0918/D0X3Y5.BEL.BRAM
          bank1=D0X3Y1; bank1_in=fw5-decode/bram-0918/D0X3Y1.BEL.BRAM; bank1_psm=stage0/sd-recover-fw5-0918.psm
          bank1_allow="--allow 12B --allow 19F --allow 1A0 --allow 1A5 --allow 224 --allow 23A --allow 326 --allow 370 --allow 377"
          base=fw5/0918.bin; stock=tools/ezflashjr/official/2021-09-18_FW5_K1.05e/Update_FW5_2021-9-18.gb; s1fw=fw5 ;;
# FW6: FW5-0918's two programs at other tiles, bank 1 with two words
# changed. Bank 2 lost one instruction at $1BD, so the two routines the read
# patch calls sit a word lower. Stage1 is stored as bytes
fw6)      layout="--layout fw6"; bank2=D0X19Y25; bank2_in=fw6/bram/D0X19Y25.BEL.BRAM
          bank2_def="--define TBL_READ=226 --define FLASH_UPDATE=22E"
          bank1=D0X19Y29; bank1_in=fw6/bram/D0X19Y29.BEL.BRAM; bank1_psm=stage0/sd-recover-fw5-0918.psm
          bank1_allow="--allow 12B --allow 19F --allow 1A0 --allow 1A5 --allow 224 --allow 23A --allow 326 --allow 370 --allow 377"
          base=fw6.bin; stock=; s1fw=fw5 ;;
*)        echo "unknown firmware: $fw" >&2; exit 2 ;;
esac

[ "$patches" = 0 ] && { bank2=; bank1=; }

[ "$host" = local ] || "$repo/stage0/tools/host-check.sh" "$host"
case $stage1 in
ours)  "$repo/stage1/build.sh" | grep -v "Overwrote"
       s1="$repo/fpga/stage1/stage1.gb"; w="$repo/fpga/stage1/$fw" ;;
stock) make -s -C "$repo/stage1/decomp" "build/$s1fw/stage1.gb"
       s1="$repo/stage1/decomp/build/$s1fw/stage1.gb"; w="$repo/fpga/stage1/$fw-stock" ;;
*)     echo "STAGE1 is ours or stock, not $stage1" >&2; exit 2 ;;
esac
[ "$patches" = 0 ] && w="$w-nopatch"
rm -rf "$w"; mkdir -p "$w"
cd "$w"
cp "$s1" stage1.gb
# relative blob paths: the --set args are used as-is on the build host
"$repo/stage1/tools/stage1-to-bram.py" stage1.gb blobs $layout > sets.txt
if [ -n "$bank2" ]; then
    "$repo/stage0/tools/picoblaze-patch.py" "$repo/fpga/$bank2_in" "$repo/stage0/flash-read.psm" \
        blobs --tile $bank2 --allow 1B7 ${bank2_def:-} >> sets.txt
fi
if [ -n "$bank1" ]; then
    "$repo/stage0/tools/picoblaze-patch.py" "$repo/fpga/$bank1_in" "$repo/$bank1_psm" \
        blobs --tile $bank1 $bank1_allow >> sets.txt
fi

if [ "$host" = local ]; then
    t="$repo/stage0/tools/s3decode/target/release"; db="$repo/fpga/db/spartan3.zstd"
    "$t/s3patch" --db "$db" "$repo/fpga/cart/$base" slotB.bin $(cat sets.txt) >/dev/null
    "$t/s3decode" --db "$db" --blob-dir bram-new/ slotB.bin > decode.txt
    tail -1 decode.txt
    [ -z "$check" ] || { cmp slotB.bin "$repo/fpga/cart/$base" && echo 'slot B: identical to stock'; }
else
r="fpga/cart/s1-$(basename "$w")"
same=; [ -n "$check" ] && same="cmp slotB.bin ~/fpga/cart/$base && echo 'slot B: identical to stock'"
ssh "$host" "rm -rf $r && mkdir -p $r"
scp -qr blobs sets.txt "$host:$r/"
ssh "$host" "set -e; cd $r; db=~/fpga/prjcombine/databases/spartan3.zstd; t=~/fpga/s3decode/target/release
\$t/s3patch --db \$db ~/fpga/cart/$base slotB.bin \$(cat sets.txt) >/dev/null
\$t/s3decode --db \$db --blob-dir bram-new/ slotB.bin > decode.txt
tail -1 decode.txt
$same"
scp -qr "$host:$r/bram-new" "$host:$r/slotB.bin" .
fi

# both halves must decode back to what went in
"$repo/stage1/tools/stage1-from-bram.py" bram-new -o stage1-check.gb --ref stage1.gb ${layout:+--discover} | tail -1 | grep -q "True" \
    || { echo "stage1 round trip failed" >&2; exit 1; }
for b in $bank2 $bank1; do
    for p in DATA DATAP; do
        cmp -s "blobs/$b.$p.bin" "bram-new/$b.BEL.BRAM.$p.bin" \
            || { echo "$b round trip failed ($p)" >&2; exit 1; }
    done
done
echo "round trip: stage1${bank2:+, bank 2}${bank1:+ and bank 1} match"
[ -n "$check" ] && exit 0

cd "$repo"
if [ -n "$stock" ]; then
    stage0/tools/make-updater.py "$stock" "$w/slotB.bin" "$out" --label "$label"
else
    python3 stage0/updater/tools/link.py "$fw" --label "$label" --payload "$w/slotB.bin" -o "$out"
fi
