#!/bin/sh
# Export one cart bitstream as the structural Verilog the stage0 work runs on.
#
#   stage0/tools/export-netlist.sh IMAGE.bin OUTDIR
#
# Writes to OUTDIR (untracked, keep it under fpga/):
#   netlist.jsonl   s3trace --netlist: every configured bel and its input drivers
#   pins.txt        s3pins: package pin -> pad
#   decode.txt      s3decode, with the BRAM contents as blobs in bram/
#   design.v        netlist2v.py: module fpga_top over stage0/sim/s3prims.v,
#                   plus the <tile>.DATA.mem files its BRAMs read
#
# Tools: stage0/tools/s3decode/target/release (cargo build --release there)
# and the prjcombine database, S3DB (default fpga/db/spartan3.zstd).
set -e
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../.." && pwd)
img=${1:?image.bin}
out=${2:?outdir}
db=${S3DB:-$top/fpga/db/spartan3.zstd}
bin=$top/stage0/tools/s3decode/target/release
[ -x "$bin/s3trace" ] || { echo "build the tools first: (cd stage0/tools/s3decode && cargo build --release)" >&2; exit 1; }
[ -f "$db" ] || { echo "no prjcombine database at $db (set S3DB)" >&2; exit 1; }
mkdir -p "$out/bram"
"$bin/s3trace" --db "$db" "$img" --netlist "$out/netlist.jsonl"
"$bin/s3pins" --db "$db" > "$out/pins.txt"
"$bin/s3decode" --db "$db" --blob-dir "$out/bram" "$img" > "$out/decode.txt"
python3 "$top/stage0/sim/netlist2v.py" "$out/netlist.jsonl" "$out/pins.txt" "$out/bram" "$out"
echo "exported to $out"
