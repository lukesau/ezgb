#!/bin/sh
# Build a stage1 updater: our stage1 plus the bank 2 flash read patch
# (stage0/flash-read.psm) in slot B, round-trip checked.
#
#   BUILD_HOST=<host> scripts/fpga/build-stage1-updater.sh fw4|fw5-0918 LABEL OUT.gb
#
# Runs stage1/build.sh first. The build host needs prjcombine's database and
# s3patch/s3decode (fpga-setup.md), plus the stock slot B images
# ~/fpga/cart/fw4-updater.bin and ~/fpga/cart/fw5/0918.bin. Local inputs: the
# stock bank 2 BRAMs from fpga/fw4-decode/bram and fpga/fw5-decode/bram-0918.
# Stops first if the host is busy (host-check.sh).
set -e
fw=$1; label=$2; out=$3
[ -n "$fw" ] && [ -n "$label" ] && [ -n "$out" ] || { sed -n 5p "$0"; exit 2; }
host=${BUILD_HOST:?set BUILD_HOST to the build host}
repo=$(cd "$(dirname "$0")/../.." && pwd)
case $fw in
fw4)      layout=; bank2=D0X3Y25; bank2_in=fw4-decode/bram/D0X3Y25.BEL.BRAM
          base=fw4-updater.bin; stock=juniorkernel-1.04e-FW4/Update_FW4.gb ;;
fw5-0918) layout="--layout fw5-0918"; bank2=D0X3Y5; bank2_in=fw5-decode/bram-0918/D0X3Y5.BEL.BRAM
          base=fw5/0918.bin; stock=juniorkernel-1.05e-FW5-0918/Update_FW5_2021-9-18.gb ;;
*)        echo "unknown firmware: $fw" >&2; exit 2 ;;
esac

"$repo/scripts/fpga/host-check.sh" "$host"
"$repo/stage1/build.sh" | grep -v "Overwrote"
w="$repo/fpga/stage1/$fw"
rm -rf "$w"; mkdir -p "$w"
cd "$w"
cp ../stage1.gb .
# relative blob paths: the --set args are used as-is on the build host
"$repo/scripts/fpga/stage1-to-bram.py" stage1.gb blobs $layout > sets.txt
"$repo/scripts/fpga/picoblaze-patch.py" "$repo/fpga/$bank2_in" "$repo/stage0/flash-read.psm" \
    blobs --tile $bank2 --allow 1B7 >> sets.txt

r="fpga/cart/s1-$fw"
ssh "$host" "rm -rf $r && mkdir -p $r"
scp -qr blobs sets.txt "$host:$r/"
ssh "$host" "set -e; cd $r; db=~/fpga/prjcombine/databases/spartan3.zstd; t=~/fpga/s3decode/target/release
\$t/s3patch --db \$db ~/fpga/cart/$base slotB.bin \$(cat sets.txt) >/dev/null
\$t/s3decode --db \$db --blob-dir bram-new/ slotB.bin > decode.txt
tail -1 decode.txt"
scp -qr "$host:$r/bram-new" "$host:$r/slotB.bin" .

# both halves must decode back to what went in
"$repo/scripts/fpga/stage1-from-bram.py" bram-new -o stage1-check.gb --ref stage1.gb ${layout:+--discover} | tail -1 | grep -q "True" \
    || { echo "stage1 round trip failed" >&2; exit 1; }
for p in DATA DATAP; do
    cmp -s "blobs/$bank2.$p.bin" "bram-new/$bank2.BEL.BRAM.$p.bin" \
        || { echo "bank 2 round trip failed ($p)" >&2; exit 1; }
done
echo "round trip: stage1 and bank 2 match"

cd "$repo"
scripts/fpga/make-updater.py "$stock" "$w/slotB.bin" "$out" --label "$label"
