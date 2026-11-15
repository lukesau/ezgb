#!/bin/sh
# Build an ISE project written by mkise.py on the build host: synthesis,
# place and route, bitgen, then s3decode of the result.
#
#   BUILD_HOST=<host> stage0/tools/build-ise.sh PROJDIR
#
# Copies PROJDIR to ~/fpga/ise/<name> on the host and brings back top.bit
# and top.raw (the config data alone, as in a slot B image), top.xdl,
# top.decode.txt (against the blank baseline ~/fpga/blank.bit, as the stock
# decodes are), the reports and the BRAM blobs (bram/). Stops first if the
# host is busy (host-check.sh). ISE runs single-threaded.
# XST_OPTS (options split by ;) and MAP_OPTS add to the defaults, MAP_BASE
# replaces map's "-timing -ol high", BITGEN_OPTS bitgen's options (default
# stock slot B's: ConfigRate 25, DonePipe, Reset_on_err); the
# remote directory is named after PROJDIR.
set -e
proj=${1:?usage: build-ise.sh PROJDIR}
host=${BUILD_HOST:?set BUILD_HOST to the build host}
repo=$(cd "$(dirname "$0")/../.." && pwd)
name=$(basename "$proj")
r="fpga/ise/$name"

"$repo/stage0/tools/host-check.sh" "$host"
ssh "$host" "rm -rf $r && mkdir -p $r"
scp -q "$proj"/*.v "$proj"/top.prj "$proj"/top.ucf "$proj"/top.name "$proj"/map.opts "$host:$r/"
ssh "$host" "set -e; cd $r
part=xc3s200a-4-vq100; ise=\$HOME/Xilinx/14.7/ISE_DS
. \$ise/settings64.sh \$ise >/dev/null
printf 'run\n-ifn top.prj\n-ifmt mixed\n-top %s\n-ofn top.ngc\n-ofmt NGC\n-p %s\n-equivalent_register_removal NO\n-fsm_extract NO\n-register_duplication NO\n-iob auto\n-opt_mode Area\n-opt_level 2\n-shreg_extract NO\n-mult_style lut\n-signal_encoding user\n-max_fanout 100000\n-mux_extract NO\n' \$(cat top.name) \$part > top.xst
printf '%b' '${XST_OPTS:-}' | tr ';' '\\n' | grep . >> top.xst || true
run() { echo \"== \$*\" >> build.log; \"\$@\" >> build.log 2>&1 || { echo \"failed: \$1 (\$PWD/build.log)\"; grep -m20 'ERROR' build.log; exit 1; }; }
run xst -ifn top.xst
run ngdbuild -p \$part -uc top.ucf top.ngc
run map -w -p \$part -pr b ${MAP_BASE--timing -ol high \$(cat map.opts)} ${MAP_OPTS:-} -o top_map.ncd top.ngd top.pcf
run par -w -ol high ${PAR_OPTS:-} top_map.ncd top.ncd top.pcf
run trce -v 20 top.ncd top.pcf -o top.twr
run bitgen -w ${BITGEN_OPTS--g ConfigRate:25 -g DonePipe:Yes -g Reset_on_err:Yes} top.ncd top.bit
run xdl -ncd2xdl top.ncd top.xdl
mkdir -p bram
~/fpga/s3decode/target/release/s3decode --db ~/fpga/prjcombine/databases/spartan3.zstd --baseline ~/fpga/blank.bit --blob-dir bram top.bit > top.decode.txt
tail -1 top.decode.txt
grep -A3 'Timing summary' top.twr | head -4 || true"
scp -q "$host:$r/top.bit" "$host:$r/top.decode.txt" "$host:$r/build.log" "$host:$r/top.twr" "$host:$r/top_map.mrp" "$host:$r/top.par" "$host:$r/top.xdl" "$proj/"
scp -qr "$host:$r/bram" "$proj/"
# the raw config data, as a slot B image holds it
python3 - "$proj/top.bit" "$proj/top.raw" <<'PY2'
import sys
d = open(sys.argv[1], "rb").read()
i = d.index(b"\x65", d.index(b"\x64\x00") + 3)
open(sys.argv[2], "wb").write(d[i + 5:i + 5 + int.from_bytes(d[i + 1:i + 5], "big")])
PY2
