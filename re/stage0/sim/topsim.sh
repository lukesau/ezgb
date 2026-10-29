#!/bin/bash
# Run tb_full.v twice, over design.v and over the readable top (stage0/rtl/
# fw4_top.v, compiled under the testbench's module name), and compare.
#
#   re/stage0/sim/topsim.sh EXPORTDIR [GB_START_NS] [RUN_NS]
#
# EXPORTDIR is an export-netlist.sh output directory with flash.hex (the
# config flash image, one hex byte per line) and card.img beside design.v;
# fastboot.py makes EXPORTDIR/sim from it. Needs verilator. Runs the
# gb_sdread.vh test by default (card init done at ~29 ms with fastboot's
# BRAM copies); the results land in EXPORTDIR/sim/{base,top}/run.log and
# topcompare.py checks them line for line. The design.v run takes
# NO_SLICE_GSR (s3prims.v) so its slice flip-flops start at time 0 as the
# readable registers do; the two logs then match timestamp for timestamp.
set -e
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../../.." && pwd)
exp=$(cd "${1:?exportdir}" && pwd)
START=${2:-31000000}; RUN=${3:-34000000}
[ -f "$exp/flash.hex" ] && [ -e "$exp/card.img" ] || { echo "need $exp/flash.hex and $exp/card.img" >&2; exit 1; }
[ -d "$exp/sim" ] || python3 "$here/fastboot.py" "$exp" "$exp/sim"
cd "$exp/sim"
sed 's/^module fw4_top /module fpga_top /' "$top/stage0/rtl/fw4_top.v" > fpga_top_rtl.v
common="--binary --timing -j 4 -Wno-fatal -Wno-lint -Wno-style +define+RUN_NS=$RUN +define+GB_START_NS=$START +define+GB_TEST=\"gb_sdread.vh\" --top-module tb +incdir+$here"
mkdir -p base top
verilator $common +define+NO_SLICE_GSR --Mdir base/obj -o simv "$here"/s3prims.v "$here"/models.v "$here"/pinmon.v "$here"/tb_pcmap.v ../design.v "$here"/tb_full.v > base/build.log 2>&1 || { echo "base build failed, see $exp/sim/base/build.log" >&2; exit 1; }
verilator $common +define+BANK2=tb.dut.u_logic.u_picoblaze_ports.bank --Mdir top/obj -o simv "$here"/s3prims.v "$top"/stage0/lib/s3bels.v $(ls "$top"/stage0/rtl/*.v | grep -v fw4_top.v) fpga_top_rtl.v "$here"/models.v "$here"/pinmon.v "$here"/tb_pcmap.v "$here"/tb_full.v > top/build.log 2>&1 || { echo "top build failed, see $exp/sim/top/build.log" >&2; exit 1; }
./base/obj/simv > base/run.log 2>&1 &
./top/obj/simv > top/run.log 2>&1 &
wait
python3 "$here/topcompare.py"
