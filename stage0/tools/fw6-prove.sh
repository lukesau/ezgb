#!/bin/bash
# Prove FW6's slice logic against its readable modules, whole.
#
#   stage0/tools/fw6-prove.sh [EXPORTDIR [OUT]]
#
# EXPORTDIR is an export-netlist.sh directory of FW6 (default fpga/fw6),
# OUT the work directory (default fpga/fw6-nx). FW6 is a new place and
# route of FW5-0918 with its logic packed into other LUTs, so the nets
# between FW5's blocks are not there to cut it by. It is proven in one
# piece instead, matched at the registers:
#
#   1. fw5-noedge.py --keep-edge --other-build: design.v with its
#      constant-0 LUTs as one net and the unused carry inputs tied off
#      (OUT/design.v), as FW5-0918 is proven
#   2. carve.py: every live slice bel as one module, each register under
#      its name in stage0/fw6/fw6_logic.blk (u_<block>__<name>)
#   3. yosys: that module against fw6_logic (stage0/fw6/fw6_top.v) over
#      the readable modules: stage0/fw6/<block>.v where FW6 has one of its
#      own, else FW5-0918's, else FW4's. Every register and every net to a
#      pad, block RAM or other primitive is one proof. What the structural
#      passes leave is proven under the modules' invariants (assume() under
#      `ifdef FORMAL), and then the invariants themselves are proven on the
#      design, from reset and by induction, as prove-top.sh does
#
# stage0/tools/fw6-carry.py wrote fw6_top.v and fw6_logic.blk from
# FW5-0918's; this proof reads no part of FW5 but the modules FW6 shares.
set -u
here=$(cd "$(dirname "$0")" && pwd)
top=$(cd "$here/../.." && pwd)
exp=$(cd "${1:-$top/fpga/fw6}" && pwd)
W=${2:-$top/fpga/fw6-nx}
out=$W/top; lib=$top/stage0/lib; f6=${F6:-$top/stage0/fw6}
mkdir -p "$out" && cd "$top"
python3 "$here/fw5-noedge.py" --keep-edge --other-build "$exp/design.v" "$W/design.v" > "$W/noedge.log" || { cat "$W/noedge.log"; exit 1; }
# the names: registers for carve.py, the LUT RAM contents and the readable
# side's registers as rename scripts. A register that leaves the slice logic
# is a port of the carved module under its name; the readable side exposes
# it the same way
python3 - "$here" "$W/design.v" "$f6/fw6_logic.blk" "$out" <<'PY' || exit 1
import sys, re
here, design, blk, out = sys.argv[1:5]
sys.path.insert(0, here)
import carve
d = carve.Design(design)
names, rams = {}, {}
for l in open(blk).read().split('[names]')[1].splitlines():
    l = l.split('#')[0].split()
    if len(l) == 2:
        (rams if l[0].endswith('.m') else names)[l[0]] = l[1]
open(f'{out}/all.blk', 'w').write('# every live slice bel\n[cells]\n*\n[names]\n' + ''.join(f'{k} {v}\n' for k, v in names.items()))
_, info = carve.carve(d, 'all', carve.expand_cell('*', d, '*'), names)
ffs = {c.outs[0] for n, c in d.cells.items() if n in d.live_cells and c.kind == 's3_ff' and c.slice is not None}
missing = sorted(ffs - set(names))
if missing:
    sys.exit(f'{len(missing)} registers have no name in {blk}: {" ".join(missing[:5])}')
ported = {names[n].split('[')[0] for n in info['out_nets'] if n in names}
raw = [n for n in info['out_nets'] if n in names]
bases = sorted({v.split('[')[0] for v in names.values()})
with open(f'{out}/ren_gate.ys', 'w') as f:
    for b in bases:
        blkname, reg = b[2:].split('__', 1)
        f.write(f'rename \\u_{blkname}.{reg} \\{b}\n')
    for b in sorted(ported):
        f.write(f'expose w:{b}\n')
    f.write('delete -port ' + ' '.join(f'w:{n}' for n in raw) + '\n')
open(f'{out}/ren_all.ys', 'w').write(''.join(f"rename \\{k} \\ram_{k[:-2]}\n" for k in sorted(rams)))
open(f'{out}/ren_rtl.ys', 'w').write(''.join(f"rename \\u_picoblaze.{rams[k]}.m \\ram_{k[:-2]}\n" for k in sorted(rams)))
print(f'{len(names)} registers, {len(rams)} LUT RAMs, {len(ported)} register ports')
PY
python3 "$here/carve.py" "$W/design.v" "$out/all.blk" -o "$out/all_ref.v" > "$out/carve.log" 2>&1 || { cat "$out/carve.log"; exit 1; }
rtls=''
for m in $(sed -n 's/^\([a-z0-9_]*\) u_[a-z0-9_]* (.*/\1/p' "$f6/fw6_top.v" | grep -v '^fw6_logic$' | sort -u); do
    r=$f6/$m.v; [ -f "$r" ] || r=$top/stage0/fw5-0918/$m.v; [ -f "$r" ] || r=$top/stage0/fw4/rtl/$m.v
    [ -f "$r" ] || { echo "no module $m" >&2; exit 1; }
    rtls="$rtls $r"
done
# FW4 modules whose constant-0 input the build wires as a constant (fw5-prove.sh's TIE)
ties=''
for t in sd_data_serial:gnd_i=0 sd_clock_divider:gnd_i=0 sd_fifo_filler:gnd1_i=0 sd_fifo_filler:clr_i=0; do
    m=${t%%:*}; t=${t#*:}
    ties="$ties
cd $m
delete -port w:${t%%=*}
connect -set ${t%%=*} 1'b${t#*=}
cd .."
done
sed '/^module fw6_top/,$d' "$f6/fw6_top.v" > "$out/fw6_logic.v"
prelude="
read_verilog -sv $lib/s3bels.v
read_verilog -sv $out/all_ref.v
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
read_verilog -sv -formal $rtls $out/fw6_logic.v
hierarchy -top fw6_logic
proc$ties
prep -flatten -top fw6_logic
async2sync
opt_clean
cd fw6_logic
script $out/ren_rtl.ys
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
"
log=$out/rtl.log
# pass 1: the structural passes; what they leave needs the invariants
yosys -q -l "$log" -p "$prelude
equiv_simple -seq 4
equiv_induct -seq 4
equiv_status
" > /dev/null 2>&1 || { echo "fw6: setup failed, see $log" >&2; grep -i '^ERROR' "$log" | head -3 >&2; exit 1; }
total=$(grep -oE 'Found [0-9]+ .equiv' "$log" | tail -1 | awk '{print $2}')
left=$(grep -cE '^\s+Unproven' "$log" || true)
echo "fw6: $total signals, $left left for the invariants"
if [ "$left" != 0 ]; then
    proves=$(grep -E '^\s+Unproven' "$log" | sed -E 's/.*\$[0-9]+: //; s/ \[/[/g' | awk '{printf "-prove %s %s ", $1, $2}')
    yosys -q -l "$out/rtl_inv.log" -p "$prelude
sat -verify -tempinduct -set-assumes -seq 1 -maxsteps ${STEPS:-8} $proves equiv
" > /dev/null 2>&1 && echo "fw6: the rest proven under the modules' invariants" || { echo "fw6: NOT proven, see $out/rtl_inv.log" >&2; exit 1; }
fi
yosys -q -l "$out/rtl_asm.log" -p "$prelude
chformal -assume2assert
sat -verify -tempinduct -set-assumes -prove-asserts -seq 1 -maxsteps ${STEPS:-8} equiv
" > /dev/null 2>&1 && echo "fw6: every invariant, env_* included, holds on the design (from reset, by induction)" || { echo "fw6: invariants NOT proven, see $out/rtl_asm.log" >&2; exit 1; }
