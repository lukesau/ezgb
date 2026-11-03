#!/bin/bash
# Stitch FW5-0918's blocks into a top level and prove it whole, as
# prove-top.sh does for FW4:
#
#   scripts/fpga/fw5-top.sh wiring|rtl [OUT]
#
# OUT is fw5-prove.sh's work directory (its design.v and blk/). The blocks
# are the ones fw5-prove.sh carried or copied there; each block's readable
# module is stage0/fw5-0918/<block>.v where FW5 has one, FW4's in
# stage0/rtl/ otherwise. The stitched top is stage0/fw5-0918/fw5_top.v.
# TIES are fw5-prove.sh's TIE settings: FW4 modules whose constant-0 input
# FW5 wires as a constant.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../.." && pwd)
mode=${1:?wiring|rtl}
OUT=$(cd "${2:-$top/fpga/fw5-nx}" && pwd)
blks=$(ls "$OUT"/blk/*.blk | grep -v '\.sim\.blk$')
rtls=''
for b in $blks; do
    n=$(basename "${b%.blk}")
    r=$top/stage0/fw5-0918/$n.v; [ -f "$r" ] || r=$top/stage0/rtl/$n.v
    rtls="$rtls $r"
done
PREFIX=fw5 BLKS="$blks" RTLS="$rtls" TOPRTL=$top/stage0/fw5-0918/fw5_top.v \
TIES="sd_data_serial:gnd_i=0 sd_clock_divider:gnd_i=0 sd_fifo_filler:gnd1_i=0 sd_fifo_filler:clr_i=0" \
    exec "$here/prove-top.sh" "$mode" "$OUT"
