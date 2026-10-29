#!/bin/sh
# Check carve.py's bel decomposition against the exporter's slice model.
#
#   scripts/fpga/check-bels.sh [EXPORTDIR]      (default fpga/fw4)
#
# A block of every live slice bel is carved twice: as whole s3_slice
# instances over stage0/lib/s3prims_synth.v (the simulation primitives,
# validated against the cart) and as bels over stage0/lib/s3bels.v. yosys
# matches the two net for net (every flip-flop and LUT output keeps its
# design.v name in both; the LUT RAM contents are matched by renaming),
# merges what is structurally identical and proves the rest by SAT and
# induction. Output lands in EXPORTDIR/check-bels/.
set -e
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../.." && pwd)
exp=${1:-$top/fpga/fw4}
out=$exp/check-bels
mkdir -p "$out"
printf '# every live slice bel\n[cells]\n*\n' > "$out/all.blk"
python3 "$here/carve.py" "$exp/design.v" "$out/all.blk" --slices -o "$out/all_slices.v" 2>/dev/null
python3 "$here/carve.py" "$exp/design.v" "$out/all.blk" -o "$out/all_bels.v" 2>/dev/null
# LUT RAM contents: bels name them <slice>_F.m / _G.m, the slice model
# <slice>.fm / .gm; both get the same public name so they match. Then every
# hierarchical name is hidden: yosys matches a net only under its canonical
# name, and the primitives' own aliases would otherwise win.
grep -oE ' X[0-9]+Y[0-9]+_S[0-3]_[FG] \(\.RA' "$out/all_bels.v" \
    | perl -ne '/ (X\d+Y\d+_S\d)_([FG]) /; printf "rename \\i_%s.%sm \\ram_%s_%s\n", $1, lc $2, $1, $2' > "$out/ren_gold.ys"
grep -oE ' X[0-9]+Y[0-9]+_S[0-3]_[FG] \(\.RA' "$out/all_bels.v" \
    | perl -ne '/ (X\d+Y\d+_S\d)_([FG]) /; printf "rename \\%s_%s.m \\ram_%s_%s\n", $1, $2, $1, $2' > "$out/ren_gate.ys"
lib=$top/stage0/lib
yosys -q -l "$out/check.log" -p "
read_verilog -sv $lib/s3prims_synth.v
read_verilog -sv $out/all_slices.v
prep -flatten -top all_ref
async2sync
opt_clean
cd all_ref
script $out/ren_gold.ys
cd ..
rename -hide w:*.*
opt_clean
rename -top gold
design -stash gold
read_verilog -sv $lib/s3bels.v
read_verilog -sv $out/all_bels.v
prep -flatten -top all_ref
async2sync
opt_clean
cd all_ref
script $out/ren_gate.ys
cd ..
rename -hide w:*.*
opt_clean
rename -top gate
design -stash gate
design -copy-from gold -as gold gold
design -copy-from gate -as gate gate
equiv_make gold gate equiv
hierarchy -top equiv
opt_clean
equiv_simple -seq 3
equiv_induct -seq 3
equiv_status
" >/dev/null 2>&1 || true
grep -E 'ERROR|Found [0-9]+ .equiv cells|Of those' "$out/check.log" | tail -3
grep -E '^\s+Unproven' "$out/check.log" | sed -E 's/.*: //' | sort > "$out/unproven.txt" || true
echo "$(wc -l < "$out/unproven.txt") unproven, listed in $out/unproven.txt"
