#!/bin/bash
# Prove FW5-0918's SD controller against FW4's readable blocks.
#
#   scripts/fpga/fw5-prove-sd.sh
#
# FW4, FW5 and OUT name export-netlist.sh directories (default fpga/fw4,
# fpga/fw5-0918, and fpga/fw5-nx for the work). The steps:
#
#   1. fw5-noedge.py: FW5's design.v without its console /RESET edge, made
#      comparable with FW4's (OUT/design.v)
#   2. belmatch.py, seeded with fw5-seed.txt; fw5-stages.py repairs the
#      pairing around FW5's extra crossing stage; a second belmatch.py round
#      from those pairs matches the register read-back
#   3. blkmap.py carries each SD block file to OUT/blk/, and fw5-stages.py
#      adds the extra stages to the crossings block
#   4. equiv.sh proves each block: against stage0/rtl/ (FW4's module), or
#      stage0/fw5-0918/ where FW5 differs; TIE/DROP stand in for the
#      constant-0 LUTs FW4 shares between blocks, which FW5 wires as
#      constants (each is an INIT 0000 LUT in FW4)
#
# sd_mem_path does not carry yet: its inputs come from FW5's rebuilt Game
# Boy bus and pSRAM blocks.
set -u
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../.." && pwd)
FW4=$(cd "${FW4:-$top/fpga/fw4}" && pwd)
FW5=$(cd "${FW5:-$top/fpga/fw5-0918}" && pwd)
OUT=${OUT:-$top/fpga/fw5-nx}
mkdir -p "$OUT/blk" && OUT=$(cd "$OUT" && pwd)
cd "$top"
A=$FW4/design.v B=$OUT/design.v
python3 "$here/fw5-noedge.py" "$FW5/design.v" "$B" > "$OUT/noedge.log" || { cat "$OUT/noedge.log"; exit 1; }
python3 "$here/belmatch.py" "$A" "$B" --seed "$here/fw5-seed.txt" --dump "$OUT/m1.match" 2> "$OUT/match.log" | grep '^A:'
python3 "$here/fw5-stages.py" fix "$A" "$B" "$OUT/m1.match" "$OUT/m1s.match" "$OUT/s1names.txt"
awk '$1 != "-" && $2 != "-"' "$OUT/m1s.match" > "$OUT/seed2.txt"
python3 "$here/belmatch.py" "$A" "$B" --seed "$OUT/seed2.txt" --blocks stage0/blocks/sd_*.blk --dump "$OUT/m2.match" 2>> "$OUT/match.log"
python3 "$here/fw5-stages.py" fix "$A" "$B" "$OUT/m2.match" "$OUT/sd.match" "$OUT/s1names.txt"
BLOCKS="sd_clock_divider sd_cmd_master sd_cmd_serial sd_controller_wb sd_crossings sd_data_master sd_data_serial sd_fifo_filler sd_fifos sd_mem_path"
for b in $BLOCKS; do
    python3 "$here/blkmap.py" "$A" "$B" "$OUT/sd.match" stage0/blocks/$b.blk -o "$OUT/blk/$b.blk" > "$OUT/blk/$b.log" 2>&1 || echo "$b: carry failed, see $OUT/blk/$b.log"
done
python3 "$here/fw5-stages.py" add "$OUT/blk/sd_crossings.blk" "$OUT/s1names.txt"
prove() {
    b=$1; shift
    env BLK="$OUT/blk/$b.blk" "$@" "$here/equiv.sh" $b "$OUT" > "$OUT/blk/$b.out" 2>&1
}
for b in $BLOCKS; do
    case $b in
        sd_crossings) prove $b RTL=stage0/fw5-0918/sd_crossings.v ;;
        sd_data_serial) prove $b RTL=stage0/fw5-0918/sd_data_serial.v TIE="gnd_i=0" DROP="gnd gnd1 gnd2 gnd3 gnd4 gnd5 gnd6 gnd7" ;;
        sd_clock_divider) prove $b TIE="gnd_i=0" ;;
        sd_fifo_filler) prove $b TIE="gnd1_i=0 clr_i=0" ;;
        sd_cmd_serial) prove $b DROP="gnd gnd1 gnd2" ;;
        *) prove $b ;;
    esac &
done
wait
for b in $BLOCKS; do
    r=$(grep -E "^$b: (equivalent|NOT|setup failed)" "$OUT/blk/$b.out" | head -1)
    echo "${r:-$b: no result, see $OUT/blk/$b.out}"
done
