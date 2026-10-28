#!/usr/bin/env python3
"""Print a block's logic as equations, with the block file's names.

    scripts/fpga/dumpblk.py fpga/fw4/design.v stage0/blocks/NAME.blk [OUT]

For every bel in the block: flip-flops as `q <= D=... CE=... SR=...`, LUTs as
a sum of products over their named inputs, muxes, carry muxes and XORs. Nets
the block file names are shown by that name; everything else by its bel
(x18y31_s0_f, x7y26_s0_ffx). The dump is the map between the netlist and the
readable module while a block is being written.
"""
import sys, re, itertools, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import carve
from collections import defaultdict

design, blkfile = sys.argv[1], sys.argv[2]
out_path = sys.argv[3] if len(sys.argv) > 3 else None
d = carve.Design(design)
blk = open(blkfile).read()
cells_txt, names_txt = blk.split('[names]') if '[names]' in blk else (blk, '')
block = [l.strip() for l in cells_txt.splitlines() if l.strip() and not l.startswith(('#', '['))]
names, ramname = {}, {}
for l in names_txt.splitlines():
    l = l.split('#')[0].strip()
    if not l: continue
    k, v = l.split()
    if k.endswith('.m'): ramname[k[:-2].replace('_F', '.F').replace('_G', '.G')] = v
    else: names[k] = v
for c, v in ramname.items():
    names[d.cells[c].outs[0]] = v
# unnamed bel outputs take their bel's name
for c in block:
    for o in d.cells[c].outs:
        names.setdefault(o, c.replace('.', '_').lower())
# design-level aliases (n_X.. = b_X..) take the bel's name too
for net, expr in d.wires.items():
    src = carve.nets_of(expr)
    if len(src) == 1 and expr.strip() == src[0] and src[0] in names and net not in names:
        names[net] = names[src[0]]

def nm(expr):
    return carve.NET.sub(lambda m: names.get(m.group(1), m.group(1)), expr)

def sop(tt, ins):
    """a minimal-ish sum of products for a 16-entry truth table"""
    on = {i for i in range(16) if tt >> i & 1}
    if not on: return '0'
    if len(on) == 16: return '1'
    cubes = []
    for c in itertools.product((0, 1, None), repeat=4):
        ms = [i for i in range(16) if all(c[k] is None or (i >> k & 1) == c[k] for k in range(4))]
        if all(i in on for i in ms): cubes.append((c, set(ms)))
    primes = [c for c in cubes if not any(o[1] > c[1] for o in cubes)]
    cover, left = [], set(on)
    while left:
        best = max(primes, key=lambda c: len(c[1] & left)); cover.append(best[0]); left -= best[1]
    return ' | '.join('&'.join(('' if c[k] else '!') + ins[k] for k in range(4) if c[k] is not None) or '1' for c in cover)

out, kinds = [], defaultdict(list)
for c in block: kinds[d.cells[c].kind].append(c)
def xy(c):
    m = re.match(r'X(\d+)Y(\d+)', c); return int(m.group(1)), int(m.group(2)), c
for kind in ('s3_ff', 's3_ram16', 's3_srl16', 's3_lut4', 's3_mux2', 's3_muxcy', 's3_xorcy'):
    if not kinds[kind]: continue
    out.append(f"\n==== {kind} ({len(kinds[kind])})")
    for c in sorted(kinds[kind], key=xy):
        cl = d.cells[c]; o = names[cl.outs[0]]
        ins = {k: nm(v) for k, v in cl.ins.items()}
        if kind == 's3_lut4':
            init = cl.params['INIT']
            tt = int(init[4:], 16) if "'h" in init else int(init.split("'b")[1], 2)
            out.append(f"{o:16s} = {sop(tt, [ins['I1'], ins['I2'], ins['I3'], ins['I4']])}")
        elif kind == 's3_ff':
            P = cl.params
            out.append(f"{o:16s} <= D={ins['D']} CE={ins['CE']} SR={ins['SR']} REV={ins['REV']} clk={ins['CLK']}"
                       f" init={P['INIT']} srval={P['SRVAL']}{' SYNC' if P['SYNC'] else ''}{' LATCH' if P['LATCH'] else ''}")
        elif kind in ('s3_ram16', 's3_srl16'):
            out.append(f"{o:16s} ram RA={ins.get('RA')} WA={ins.get('WA')} WE={ins.get('WE')} D={ins.get('D')} init={cl.params['INIT']}")
        elif kind == 's3_mux2':
            out.append(f"{o:16s} = {ins['S']} ? {ins['I1']} : {ins['I0']}")
        elif kind == 's3_muxcy':
            out.append(f"{o:16s} = {ins['S']} ? CI({ins['CI']}) : DI({ins['DI']})")
        elif kind == 's3_xorcy':
            out.append(f"{o:16s} = {ins['LI']} ^ {ins['CI']}")
text = '\n'.join(out) + '\n'
if out_path:
    open(out_path, 'w').write(text); print(len(out), 'lines ->', out_path)
else:
    sys.stdout.write(text)
