#!/bin/sh
# Prove a readable block equivalent to the one carved from the design.
#
#   scripts/fpga/equiv.sh BLOCK [EXPORTDIR]
#
# BLOCK names stage0/blocks/BLOCK.blk (the cells and names) and
# stage0/rtl/BLOCK.v (the readable module, named BLOCK). EXPORTDIR is an
# export-netlist.sh output directory, default fpga/fw4. The carved reference
# lands in EXPORTDIR/blocks/BLOCK_ref.v.
#
# The check matches the two designs by name: ports, and every register the
# block file names. With the registers matched, each next-state and output
# function is proved equal by SAT (equiv_simple), and what that leaves is
# tried by induction (equiv_induct). equiv_status -assert fails the run if
# anything stays unproven.
#
# yosys matches a net only under its canonical name, and after flattening
# that is often the primitive's own hierarchical alias (X18Y31_S0_FFX.Q)
# rather than the block's name for it, so hierarchical names are hidden
# before matching. LUT RAM contents named in the block file are renamed
# first (carve.py writes the rename script next to the reference).
set -e
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../.." && pwd)
blk=${1:?block name}
exp=${2:-$top/fpga/fw4}
blkfile=$top/stage0/blocks/$blk.blk
rtl=${RTL:-$top/stage0/rtl/$blk.v}   # RTL=file.v checks another module of the same name
[ -f "$blkfile" ] || { echo "no $blkfile" >&2; exit 1; }
[ -f "$rtl" ] || { echo "no $rtl" >&2; exit 1; }
[ -f "$exp/design.v" ] || { echo "no $exp/design.v: run export-netlist.sh first" >&2; exit 1; }
mkdir -p "$exp/blocks"
ref=$exp/blocks/${blk}_ref.v
python3 "$here/carve.py" "$exp/design.v" "$blkfile" -o "$ref"
log=$exp/blocks/${blk}_equiv.log
# LUT RAM contents named in the block file keep their (dotted) names on both
# sides; everything else hierarchical is hidden
hide='rename -hide w:*.*'
grep -q 'select -set keep' "${ref%.v}.ys" && hide='rename -hide w:*.* @keep %d'
# A readable module may state reachable-state invariants with assume() under
# `ifdef FORMAL (a one-hot state, a bounded counter). Then every matched
# pair is proved by temporal induction with those assumptions in force: the
# two designs are equivalent on every state the invariants allow. The
# invariants are not proven here; they must be true of the hardware, and
# the module says why. Without assumptions the structural passes
# (equiv_simple, equiv_induct) must prove everything on their own.
formal=''
grep -q 'ifdef FORMAL' "$rtl" && formal='-formal'
prelude="
read_verilog -sv $top/stage0/lib/s3bels.v
read_verilog -sv $ref
prep -flatten -top ${blk}_ref
async2sync
opt_clean
cd ${blk}_ref
script ${ref%.v}.ys
cd ..
$hide
opt_clean
rename -top gold
design -stash gold
read_verilog -sv $top/stage0/lib/s3bels.v
read_verilog -sv $formal $rtl
prep -flatten -top $blk
async2sync
opt_clean
cd $blk
script ${ref%.v}_gate.ys
cd ..
$hide
opt_clean
rename -top gate
design -stash gate
design -copy-from gold -as gold gold
design -copy-from gate -as gate gate
equiv_make gold gate equiv
hierarchy -top equiv
opt_clean
"
if [ -z "$formal" ]; then
    yosys -q -l "$log" -p "$prelude
equiv_simple -seq 4
equiv_induct -seq 4
equiv_status -assert
" && echo "$blk: equivalent" || { echo "$blk: NOT proven, see $log" >&2; exit 1; }
else
    # pass 1 lists the matched pairs (all unproven before any pass runs);
    # pass 2 proves them all together under the assumptions
    yosys -q -l "$log" -p "$prelude
equiv_status
" || { echo "$blk: setup failed, see $log" >&2; exit 1; }
    proves=$(grep -E '^\s+Unproven' "$log" | sed -E 's/.*\$[0-9]+: //; s/ \[/[/g' | awk '{printf "-prove %s %s ", $1, $2}')
    n=$(grep -cE '^\s+Unproven' "$log")
    yosys -q -l "$log" -p "$prelude
sat -verify -tempinduct -set-assumes -seq 1 -maxsteps 8 $proves equiv
" && echo "$blk: equivalent ($n signals, under the module's assumptions)" || { echo "$blk: NOT proven, see $log" >&2; exit 1; }
fi
