#!/bin/bash
# Prove FW5-0918's design against FW4's readable blocks.
#
#   scripts/fpga/fw5-prove.sh [BLOCK...]     (default: every block)
#
# FW4, FW5 and OUT name export-netlist.sh directories (default fpga/fw4,
# fpga/fw5-0918, and fpga/fw5-nx for the work). The steps:
#
#   1. fw5-noedge.py: FW5's design.v without its console /RESET edge, made
#      comparable with FW4's (OUT/design.v)
#   2. belmatch.py, seeded with fw5-seed.txt, the Game Boy registers
#      regseed.py pairs from the register maps and the pad drivers
#      padseed.py pairs by pin; fw5-stages.py repairs the
#      pairing around FW5's extra crossing stage; a second belmatch.py round
#      from those pairs, with the shape pass, matches the register read-back
#      and logic that moved to another clock (the soft reset counter)
#   3. blkmap.py carries each block file to OUT/blk/ (simblk.py builds it
#      instead where stage0/fw5-0918/<block>.sim gives its arguments: logic
#      FW5 packs into other LUTs), stage0/fw5-0918/
#      <block>.names adds the names it can't carry (a clock that moved), and
#      fw5-stages.py adds the extra stages to the crossings block
#   4. equiv.sh proves each block: against stage0/rtl/ (FW4's module), or
#      stage0/fw5-0918/ where FW5 differs; TIE/DROP stand in for the
#      constant-0 LUTs FW4 shares between blocks, which FW5 wires as
#      constants (each is an INIT 0000 LUT in FW4)
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
maps=$top/re/stage0/maps
{ cat "$here/fw5-seed.txt"; python3 "$here/regseed.py" "$maps/fw4.regmap.txt" "$maps/fw5-0918.regmap.txt"
  python3 "$here/padseed.py" "$A" "$B"; } > "$OUT/seed1.txt"
python3 "$here/belmatch.py" "$A" "$B" --seed "$OUT/seed1.txt" --dump "$OUT/m1.match" 2> "$OUT/match.log" | grep '^A:'
python3 "$here/fw5-stages.py" fix "$A" "$B" "$OUT/m1.match" "$OUT/m1s.match" "$OUT/s1names.txt"
awk '$1 != "-" && $2 != "-"' "$OUT/m1s.match" > "$OUT/seed2.txt"
python3 "$here/belmatch.py" "$A" "$B" --seed "$OUT/seed2.txt" --shape --blocks stage0/blocks/*.blk --dump "$OUT/m2.match" 2>> "$OUT/match.log"
python3 "$here/fw5-stages.py" fix "$A" "$B" "$OUT/m2.match" "$OUT/m.match" "$OUT/s1names.txt"
BLOCKS=${*:-$(cd stage0/blocks && ls *.blk | sed 's/\.blk$//' | tr '\n' ' ')}
for b in $BLOCKS; do
    if [ -f stage0/fw5-0918/$b.sim ]; then      # packed differently: name nets by what they compute
        names=; [ -f stage0/fw5-0918/$b.names ] && names="--names stage0/fw5-0918/$b.names"
        python3 "$here/simblk.py" "$A" "$B" "$OUT/m.match" stage0/blocks/$b.blk -o "$OUT/blk/$b.blk" $names \
            $(grep -v '^#' stage0/fw5-0918/$b.sim) > "$OUT/blk/$b.log" 2>&1 || echo "$b: simblk failed, see $OUT/blk/$b.log"
    else
        python3 "$here/blkmap.py" "$A" "$B" "$OUT/m.match" stage0/blocks/$b.blk -o "$OUT/blk/$b.blk" > "$OUT/blk/$b.log" 2>&1 || echo "$b: carry failed, see $OUT/blk/$b.log"
    fi
done
for b in $BLOCKS; do        # names the carry can't find (a clock that moved)
    [ -f stage0/fw5-0918/$b.names ] && [ ! -f stage0/fw5-0918/$b.sim ] && grep -v '^#' stage0/fw5-0918/$b.names >> "$OUT/blk/$b.blk"
done
case " $BLOCKS " in *" sd_crossings "*) python3 "$here/fw5-stages.py" add "$OUT/blk/sd_crossings.blk" "$OUT/s1names.txt" ;; esac
prove() {
    b=$1; shift
    env BLK="$OUT/blk/$b.blk" "$@" "$here/equiv.sh" $b "$OUT" > "$OUT/blk/$b.out" 2>&1
}
for b in $BLOCKS; do
    case $b in
        sd_crossings|soft_reset|psram_ctrl|sd_mem_path|gb_regs) prove $b RTL=stage0/fw5-0918/$b.v ;;
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
