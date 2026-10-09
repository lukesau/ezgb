#!/bin/bash
# Check the ISE 14.7 + s3decode toolchain end to end (run on the build host).
#
#   smoke-test.sh [workdir]
#
# Builds a 4-flop design for xc3s200a-4-vq100, round-trips it through XDL and
# checks bitgen reproduces identical config data, builds the blank baseline,
# then decodes the design against it with s3decode.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
work=${1:-$HOME/fpga/smoke}
part=xc3s200a-4-vq100
ise=${ISE:-$HOME/Xilinx/14.7/ISE_DS}
s3decode=${S3DECODE:-$HOME/fpga/s3decode/target/release/s3decode}
db=${S3DB:-$HOME/fpga/prjcombine/databases/spartan3.zstd}

mkdir -p "$work" && cd "$work"
cp "$here/smoke/top.v" "$here/smoke/blank.xdl" .
echo "verilog work top.v" > top.prj
printf 'run\n-ifn top.prj\n-ifmt mixed\n-top top\n-ofn top.ngc\n-ofmt NGC\n-p %s\n' $part > top.xst

# settings64.sh treats $1 as the install dir, so pass it explicitly or it
# picks up this script's own argument
set +u
source "$ise/settings64.sh" "$ise" > /dev/null
set -u
{
    xst -ifn top.xst
    ngdbuild -p $part top.ngc
    map -w -p $part -o top_map.ncd top.ngd
    par -w top_map.ncd top.ncd
    bitgen -w top.ncd top.bit
    xdl -ncd2xdl top.ncd top.xdl
    xdl -xdl2ncd top.xdl rt.ncd
    bitgen -w rt.ncd rt.bit
    xdl -xdl2ncd -force blank.xdl blank.ncd
    bitgen -w -d blank.ncd blank.bit
} > build.log 2>&1 || { echo "ISE build failed, see $work/build.log"; exit 1; }

python3 - <<'PY'
def body(p):
    d = open(p, "rb").read()
    i = d.index(b"\x65", d.index(b"\x64\x00") + 3)
    n = int.from_bytes(d[i + 1:i + 5], "big")
    return d[i + 5:i + 5 + n]
a, b = body("top.bit"), body("rt.bit")
assert len(a) == 149516, len(a)
assert a == b, "XDL round trip changed the bitstream"
print("xdl round trip: identical,", len(a), "bytes")
PY

"$s3decode" --db "$db" --baseline blank.bit top.bit > top.decode.txt
tail -1 top.decode.txt
grep -q "0 set bits unclaimed" top.decode.txt
grep -c "^tile .* CLB$" top.decode.txt | sed 's/^/slices used (CLB tiles): /'
