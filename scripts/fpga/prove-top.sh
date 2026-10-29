#!/bin/sh
# Prove the stitched top level against the exported design, in two steps
# that compose with the per-block proofs (equiv.sh) and the bel check
# (check-bels.sh):
#
#   scripts/fpga/prove-top.sh wiring [EXPORTDIR]
#   scripts/fpga/prove-top.sh rtl    [EXPORTDIR]
#
# wiring: a block of every live slice bel, carved flat from design.v, is
# proved equivalent to fw4_logic (scripts/fpga/mktop.py) instantiating the
# blocks as carved references under their design net names. Every cell is
# the same on both sides; what this checks is that the top wires the
# blocks to each other and to the primitives exactly as design.v does.
#
# rtl: fw4_logic over the named carved references (the modules equiv.sh
# proves each readable module against) is proved equivalent to fw4_logic
# over the readable modules. The two share the hierarchy, so every
# register matches under its u_<block>.<name> path; LUT RAM contents are
# matched by renaming. Readable modules that state invariants (assume()
# under `ifdef FORMAL) are proved by temporal induction with them in
# force, as in equiv.sh, and then the invariants themselves are proved on
# the reference side, including the env_* ones, which are facts about
# other blocks here.
#
# Together: design.v's slice logic == fw4_logic over the readable modules;
# fw4_top adds the primitives copied from design.v (mktop.py). Output in
# EXPORTDIR/top/.
set -e
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../.." && pwd)
mode=${1:?wiring|rtl}
exp=${2:-$top/fpga/fw4}
out=$exp/top
lib=$top/stage0/lib
mkdir -p "$out/raw"
blks=$(ls "$top"/stage0/blocks/*.blk)
# the LUT RAM contents: <cell>.m in the references, the readable name in the RTL
python3 - "$top" "$out" <<'PY'
import sys, re
top, out = sys.argv[1:3]
names = {}
for l in open(f'{top}/stage0/blocks/picoblaze.blk').read().split('[names]')[1].splitlines():
    l = l.split('#')[0].strip()
    if l.endswith('.m') or '.m ' in l:
        k, v = l.split(); names[k] = v
cells = sorted(names)
open(f'{out}/ren_all.ys', 'w').write(''.join(f"rename \\{k} \\ram_{k[:-2]}\n" for k in cells))
open(f'{out}/ren_ref.ys', 'w').write(''.join(f"rename \\u_picoblaze.{k} \\ram_{k[:-2]}\n" for k in cells))
open(f'{out}/ren_rtl.ys', 'w').write(''.join(f"rename \\u_picoblaze.{names[k]}.m \\ram_{k[:-2]}\n" for k in cells))
PY
case $mode in
wiring)
    printf '# every live slice bel\n[cells]\n*\n' > "$out/all.blk"
    python3 "$here/carve.py" "$exp/design.v" "$out/all.blk" -o "$out/all_bels.v" >/dev/null 2>&1
    # the references without names: the same raw net names as the flat carve
    for b in $blks; do
        sed '/^\[names\]/,$d' "$b" > "$out/raw/$(basename "$b")"
        python3 "$here/carve.py" "$exp/design.v" "$out/raw/$(basename "$b")" -o "$out/raw/$(basename "${b%.blk}")_ref.v" >/dev/null 2>&1
    done
    python3 "$here/mktop.py" "$exp/design.v" "$out"/raw/*.blk --suffix _ref -o "$out/top_raw.v" --strip "$out/strip_all.ys" >/dev/null
    log=$out/wiring.log
    # the gate's block-internal nets get their flat names back; a net yosys
    # optimized away while flattening (a LUT feeding a mux the register
    # never takes) is skipped
    yosys -q -p "
read_verilog -sv $lib/s3bels.v
read_verilog -sv $out/raw/*_ref.v
read_verilog -sv $out/top_raw.v
prep -flatten -top fw4_logic
async2sync
opt_clean
cd fw4_logic
tee -q -o $out/gate_wires.txt select -list w:*
" >/dev/null 2>&1
    python3 - "$out" <<'PY'
import sys, re
out = sys.argv[1]
have = set(l.strip().split('/', 1)[1].lstrip('\\') for l in open(f'{out}/gate_wires.txt') if '/' in l)
keep = [l for l in open(f'{out}/strip_all.ys') if re.match(r'rename \\(\S+) ', l).group(1) in have]
open(f'{out}/strip_raw.ys', 'w').writelines(keep)
PY
    yosys -q -l "$log" -p "
read_verilog -sv $lib/s3bels.v
read_verilog -sv $out/all_bels.v
prep -flatten -top all_ref
async2sync
opt_clean
cd all_ref
script $out/ren_all.ys
cd ..
rename -hide w:*.*
opt_clean
rename -top gold
design -stash gold
read_verilog -sv $lib/s3bels.v
read_verilog -sv $out/raw/*_ref.v
read_verilog -sv $out/top_raw.v
prep -flatten -top fw4_logic
async2sync
opt_clean
cd fw4_logic
script $out/strip_raw.ys
script $out/ren_ref.ys
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
equiv_simple -seq 1
equiv_induct -seq 1
equiv_status -assert
" && echo "wiring: fw4_logic over the carved blocks == every slice bel of design.v ($(grep -oE 'Found [0-9]+ .equiv' "$log" | tail -1 | awk '{print $2}') signals)" || { echo "wiring: NOT proven, see $log" >&2; exit 1; }
    ;;
rtl)
    refs=''
    for b in $blks; do
        r=$exp/blocks/$(basename "${b%.blk}")_ref.v
        python3 "$here/carve.py" "$exp/design.v" "$b" -o "$r" >/dev/null 2>&1
        refs="$refs $r"
    done
    python3 "$here/mktop.py" "$exp/design.v" $blks --suffix _ref -o "$out/top_ref.v" >/dev/null
    python3 "$here/mktop.py" "$exp/design.v" $blks -o "$top/stage0/rtl/fw4_top.v" >/dev/null
    log=$out/rtl.log
    prelude="
read_verilog -sv $lib/s3bels.v
read_verilog -sv $refs
read_verilog -sv $out/top_ref.v
prep -flatten -top fw4_logic
async2sync
opt_clean
cd fw4_logic
script $out/ren_ref.ys
cd ..
rename -hide w:*.*.*
opt_clean
rename -top gold
design -stash gold
read_verilog -sv $lib/s3bels.v
read_verilog -sv -formal $top/stage0/rtl/*.v
prep -flatten -top fw4_logic
async2sync
opt_clean
cd fw4_logic
script $out/ren_rtl.ys
cd ..
rename -hide w:*.*.*
opt_clean
rename -top gate
design -stash gate
design -copy-from gold -as gold gold
design -copy-from gate -as gate gate
equiv_make gold gate equiv
hierarchy -top equiv
opt_clean
"
    # pass 1: the structural passes; what they leave needs the invariants
    yosys -q -l "$log" -p "$prelude
equiv_simple -seq 4
equiv_induct -seq 4
equiv_status
" || { echo "rtl: setup failed, see $log" >&2; exit 1; }
    total=$(grep -oE 'Found [0-9]+ .equiv' "$log" | tail -1 | awk '{print $2}')
    left=$(grep -cE '^\s+Unproven' "$log" || true)
    echo "rtl: $total signals, $left left for the invariants"
    if [ "$left" != 0 ]; then
        proves=$(grep -E '^\s+Unproven' "$log" | sed -E 's/.*\$[0-9]+: //; s/ \[/[/g' | awk '{printf "-prove %s %s ", $1, $2}')
        yosys -q -l "$out/rtl_inv.log" -p "$prelude
sat -verify -tempinduct -set-assumes -seq 1 -maxsteps ${STEPS:-8} $proves equiv
" && echo "rtl: the rest proven under the modules' invariants" || { echo "rtl: NOT proven, see $out/rtl_inv.log" >&2; exit 1; }
    fi
    yosys -q -l "$out/rtl_asm.log" -p "$prelude
chformal -assume2assert
sat -verify -tempinduct -set-assumes -prove-asserts -seq 1 -maxsteps ${STEPS:-8} equiv
" && echo "rtl: every invariant, env_* included, holds on the reference (from reset, by induction)" || { echo "rtl: invariants NOT proven, see $out/rtl_asm.log" >&2; exit 1; }
    ;;
*) echo "mode: wiring or rtl" >&2; exit 1 ;;
esac
