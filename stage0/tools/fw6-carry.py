#!/usr/bin/env python3
"""Stitch FW6's logic top from FW5-0918's, under FW6's net names.

    fw6-carry.py FW5/design.v FW6/design.v MATCH FW5BLKDIR FW5TOP.v FW6DIR FW6RAMS FW5RTL...

FW5's stitched top (fw5_logic) is carried instance by instance: every
register and primitive net takes FW6's name through MATCH (belmatch.py's
pairs), its other nets keep theirs under a w5_ prefix. A block with a
module of its own in FW6DIR (stage0/fw6/<block>.v) is wired by port name
instead: to its registers (FW6DIR/fw6.names), to what FW5's instance of
that block had on the port, to another FW6 register of that name, or to
what any FW5 instance had on a port of that name. FW6DIR/fw6.alias names
FW5 registers that FW6 has under another block or name, and
FW6DIR/fw6.ports the nets FW5 has nothing for: a block RAM output a block
reads, a net to a primitive that a block's output drives, a constant 0. FW6DIR/fw6.drop
names the FW5 blocks FW6 does not have.

A net between blocks that is no register takes its driver's name,
<block>_<port>. FW6RAMS is a block file of FW6's PicoBlaze with the LUT
RAM contents named (blkmap.py carries FW5's picoblaze.blk).

Writes FW6DIR/fw6_top.v (fw6_logic, and fw6_top with the primitives
around it, as mktop.py writes them) and FW6DIR/fw6_logic.blk: every FW6
slice bel, each register named u_<block>__<name> and each LUT RAM
<cell>.m by its instance in the readable PicoBlaze. fw6-prove.sh proves
the two against the exported design, with no part of FW5 involved.
"""
import sys, os, re, collections
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../stage0/tools'))
import carve, belmatch, simblk

a_path, b_path, match, blkdir, top5, fw6dir, rams = sys.argv[1:8]
rtl5 = sys.argv[8:]
A, B = belmatch.Graph(a_path), belmatch.Graph(b_path)
ab = {}
for l in open(match):
    a, b = l.split()
    if '-' not in (a, b):
        ab[a] = b
STATE = lambda c: c.kind not in simblk.COMB
NETRE = r'(?<![.\w])' + carve.NET.pattern

# ---- FW5 net -> FW6 net
netmap, drv = {}, {}
STATEBIT = set()
def put(na, nb, inv):
    drv.setdefault(nb, (na, inv))       # copies of one net in FW5 may be one net in FW6
    netmap.setdefault(na, (nb, inv))
for a, b in ab.items():
    ca, cb = A.d.cells[a], B.d.cells[b]
    if not STATE(ca):
        continue
    if ca.slice is not None:
        for na, nb in zip(ca.outs, cb.outs):
            put(na, nb, False)
    else:
        bp = {simblk.pin(cb, n): n for n in cb.outs}
        for na in ca.outs:
            p = simblk.pin(ca, na)
            if p in bp:
                put(na, bp[p], False)
# a block RAM's output bits are wires off its bus
bbit = {}
for n, e in B.d.wires.items():
    m = re.fullmatch(r'(\w+)\[(\d+)\]', e)
    if m:
        bbit[(m.group(1), m.group(2))] = n
for n, e in A.d.wires.items():
    m = re.fullmatch(r'(\w+)\[(\d+)\]', e)
    if m and m.group(1) in netmap and (netmap[m.group(1)][0], m.group(2)) in bbit:
        put(n, bbit[(netmap[m.group(1)][0], m.group(2))], False)
        STATEBIT.add(n)
    elif m and m.group(1) == 'icap_o' and (m.group(1), m.group(2)) in bbit:     # the ICAP's output bus has one name
        put(n, bbit[(m.group(1), m.group(2))], False)
        STATEBIT.add(n)
def parts(e):
    e = e.strip()
    return [x.strip() for x in e.strip('{}').split(',')] if e.startswith('{') else [e]
for a, b in ab.items():
    ca, cb = A.d.cells[a], B.d.cells[b]
    if ca.slice is not None:
        continue
    for p in sorted(set(ca.ins) & set(cb.ins)):
        pa, pb = parts(ca.ins[p]), parts(cb.ins[p])
        if len(pa) != len(pb):
            print('pin not carried:', a, p); continue
        for ea, eb in zip(pa, pb):
            sa, sb = belmatch.simple(ea), belmatch.simple(eb)
            if ea.startswith("1'b") or eb.startswith("1'b"):
                if ea != eb:
                    print('pin not carried:', a, p, ea, eb)
                continue
            if not sa or not sb:
                print('pin not carried:', a, p, ea, eb); continue
            put(sa[0], sb[0], sa[1] != sb[1])

# ---- register names: FW5's blocks carried, then FW6's own
names = collections.OrderedDict()       # FW6 net -> (block, name)
reg5 = {}                               # (block, name) -> FW5 net
for path in sorted(os.listdir(blkdir)):
    if not path.endswith('.blk') or path.endswith('.sim.blk'):
        continue
    blk, desc, cells, nm = carve.read_block(os.path.join(blkdir, path), A.d)
    cs = set(cells)
    for net, name in nm.items():
        p = A.d.producer.get(net)
        if name.endswith('.m') or net.endswith('.m') or p not in cs or A.d.cells[p].kind != 's3_ff':
            continue
        reg5[(blk, name)] = net
        if p in ab:
            names.setdefault(B.d.cells[ab[p]].outs[0], (blk, name))
own = set()
f6 = os.path.join(fw6dir, 'fw6.names')
if os.path.exists(f6):
    for l in open(f6):
        l = l.split('#')[0].split()
        if l:
            net = l[0]
            if net in B.d.cells:
                net = B.d.cells[net].outs[0]
            blk, name = l[1].split('.', 1)
            for k in [k for k, v in names.items() if v == (blk, name)]:
                del names[k]
            names[net] = (blk, name); own.add(net)
byname = {v: k for k, v in names.items()}
alias = {}                              # FW5 net -> FW6 net
f6 = os.path.join(fw6dir, 'fw6.alias')
if os.path.exists(f6):
    for l in open(f6):
        l = l.split('#')[0].split()
        if l:
            alias[reg5[tuple(l[0].split('.', 1))]] = byname[tuple(l[1].split('.', 1))]

# nets of FW6 that no FW5 net stands for: FW6DIR/fw6.ports gives a block's
# port bit its net (an input's source, or the net to a primitive that an
# output drives), or 0 for a net to a primitive that is the constant 0
portmap, zeros = {}, []
f6 = os.path.join(fw6dir, 'fw6.ports')
if os.path.exists(f6):
    for l in open(f6):
        l = l.split('#')[0].split()
        if len(l) == 2 and l[1] == '0':
            zeros.append(l[0])
        elif len(l) == 2:
            portmap[tuple(l[1].split('.', 1))] = l[0]

# ---- module ports
def ports_of(path):
    text = re.sub(r'//[^\n]*', '', open(path).read())
    res = {}
    for m in re.finditer(r'\bmodule\s+(\w+)\s*(?:#\s*\(.*?\)\s*)?\((.*?)\);', text, re.S):
        mod, body, plist = m.group(1), m.group(2), []
        d, rng = None, None
        for item in body.split(','):
            item = item.strip()
            if not item:
                continue
            mm = re.match(r'(input|output|inout)\b\s*(?:reg\b|wire\b)?\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])?\s*(\w+)$', item)
            if mm:
                d = mm.group(1)
                rng = (int(mm.group(3)), int(mm.group(4))) if mm.group(2) else None
                plist.append((d, mm.group(5), rng))
            else:
                plist.append((d, item, rng))
        res[mod] = plist
    return res
mods5, mods6 = {}, {}
for p in rtl5:
    mods5.update(ports_of(p))
for p in sorted(os.listdir(fw6dir)):
    if p.endswith('.v') and not p.endswith('_top.v'):
        mods6.update(ports_of(os.path.join(fw6dir, p)))

# ---- FW5's instances
src = open(top5).read()
body = src.split('module fw5_logic (', 1)[1].split('endmodule', 1)[0].split(');', 1)[1]
def ren(m):
    t = m.group(0)
    if t in alias:
        return alias[t]
    p = A.d.producer.get(t)
    if t in STATEBIT or t in netmap and not netmap[t][1] and p and STATE(A.d.cells[p]):
        return netmap[t][0]
    return 'w5_' + t
inst5, bits5, order = {}, {}, []
drop5 = set()                           # FW5 blocks FW6 does not have: FW6DIR/fw6.drop
if os.path.exists(os.path.join(fw6dir, 'fw6.drop')):
    drop5 = {l.split('#')[0].strip() for l in open(os.path.join(fw6dir, 'fw6.drop'))} - {''}
glob, gconf = {}, set()                 # (port, bit) -> expression over FW6 names
for l in body.splitlines():
    m = re.match(r'(\w+) u_(\w+) \((.*)\);\s*$', l)
    if not m:
        continue
    mod, blk, conns = m.groups()
    if blk in drop5:
        continue
    order.append(blk)
    cd = collections.OrderedDict()
    for c in carve.CONN.finditer(conns):
        cd[c.group(1)] = re.sub(NETRE, ren, c.group(2).strip())
    inst5[blk] = cd
    rngs = {n: r for _, n, r in mods5.get(mod, [])}
    bits5[blk] = {}
    for p, e in cd.items():
        bl = parts(e); r = rngs.get(p)
        keys = [(p, None)] if r is None and len(bl) == 1 else \
               [(p, i) for i in range((r[0] if r else len(bl) - 1), (r[1] if r else 0) - 1, -1)]
        if len(keys) != len(bl):
            print(f'{blk}.{p}: {len(bl)} bits connected, {len(keys)} declared'); continue
        for k, b in zip(keys, bl):
            if k in glob and glob[k] != b:
                gconf.add(k)
            glob.setdefault(k, b)
            bits5[blk][k] = b

newreg = {}                             # FW6's own registers by bare name
for net in own:
    blk, name = names[net]
    m = re.fullmatch(r'(\w+)\[(\d+)\]', name)
    newreg[(m.group(1), int(m.group(2))) if m else (name, None)] = net

used, lines, loose = set(), [], []
TOK = r'\bw5_\w+|\bx6_\w+|' + NETRE
for blk in order + [m for m in mods6 if m not in order]:
    if blk not in mods6:
        lines.append(f'{blk} u_{blk} ({", ".join(f".{p}({e})" for p, e in inst5[blk].items())});')
        for e in inst5[blk].values():
            used.update(m.group(0) for m in re.finditer(TOK, e))
        continue
    conns = []
    b5 = bits5.get(blk, {})
    for d, p, rng in mods6[blk]:
        keys = [(p, None)] if rng is None else [(p, i) for i in range(rng[0], rng[1] - 1, -1)]
        if not any(k in b5 for k in keys) and p in inst5.get(blk, {}):   # FW5 connects it at another width
            e = inst5[blk][p]
            conns.append(f'.{p}({e})'); used.update(m.group(0) for m in re.finditer(TOK, e))
            continue
        bl = []; nosrc = 0
        for k in keys:
            nm = p if k[1] is None else f'{p}[{k[1]}]'
            e = byname.get((blk, nm)) or portmap.get((blk, nm)) or b5.get(k) or (newreg.get(k) if d == 'input' else None)
            if e is not None and e.startswith("1'b") and d == 'input' and not glob.get(k, e).startswith("1'b"):
                e = None        # FW5's block took the bit through a decode
            if e is None and d == 'input' and k in glob:
                e = next((bits5[b][k] for b in order if k in bits5[b] and not bits5[b][k].startswith("1'b")), glob[k])
                if k in gconf:
                    print(f'{blk}.{nm}: taken from another block, where the name has more than one net: {e}')
            if e is None:
                if d == 'input':
                    print(f'{blk}.{nm}: input with no source')
                loose.append(f'{blk}.{nm}')
                nosrc += 1
                e = f'x6_{blk}_{p}' + ('' if k[1] is None else f'_{k[1]}')
            bl.append(e)
        if d == 'input' and nosrc == len(keys):
            continue                    # an input FW5's instance leaves open too (a constant the proof ties off)
        for e in bl:
            used.update(m.group(0) for m in re.finditer(TOK, e))
        conns.append(f'.{p}({bl[0]})' if len(bl) == 1 else f'.{p}({{{", ".join(bl)}}})')
    lines.append(f'{blk} u_{blk} ({", ".join(conns)});')
if loose:
    print('outputs left open:', ' '.join(loose))

# ---- FW6's slice logic as one block
cells = carve.expand_cell('*', B.d, '*')
flat = collections.OrderedDict((n, f'u_{b}__{nm}') for n, (b, nm) in names.items())
_, info = carve.carve(B.d, 'all', cells, {})
ext_in, ext_out, ext_inout = info['in_nets'], info['out_nets'], info['inout_nets']
pset = set(ext_in + ext_out + ext_inout)
assigns = {}
for nb, (na, inv) in drv.items():
    p = A.d.producer.get(na)
    if p and STATE(A.d.cells[p]) and not inv:
        continue
    if nb in ext_out:
        s = 'w5_' + na if not (p and STATE(A.d.cells[p])) else netmap[na][0]
        assigns[nb] = ('~' if inv else '') + s
        used.add(s)
for n in zeros:
    assigns[n] = "1'b0"
undriven = [n for n in ext_out if n not in assigns and n not in used]
print(f'{len(lines)} instances, {len(flat)} registers named, {len(assigns)} outputs assigned, {len(undriven)} outputs with no source')
for n in undriven[:40]:
    print('  no source:', n)

# a net between blocks takes its driver's name
dirs = {}
for mods in (mods5, mods6):
    for mod, pl in mods.items():
        if mod not in mods6 or mods is mods6:
            dirs[mod] = {p: (d, r) for d, p, r in pl}
wname, taken = {}, set()
for l in lines:
    m = re.match(r'(\w+) u_(\w+) \((.*)\);$', l)
    for c in carve.CONN.finditer(m.group(3)):
        d, r = dirs.get(m.group(1), {}).get(c.group(1), (None, None))
        bl = parts(c.group(2))
        if d != 'output':
            continue
        hi = r[0] if r else len(bl) - 1
        for k, e in enumerate(bl):
            if re.fullmatch(r'w5_\w+', e) and e not in wname:
                nm = f'{m.group(2)}_{c.group(1)}' + (f'_{hi - k}' if len(bl) > 1 else '')
                while nm in taken:
                    nm += '_'
                wname[e] = nm; taken.add(nm)
fix = lambda t: re.sub(r'\bw5_\w+', lambda m: wname.get(m.group(0), m.group(0)), t)
left = sorted({w for w in used if w.startswith('w5_') and w not in wname})
if left:
    print(len(left), 'nets no block drives (read as 0):', ' '.join(left[:6]))
lines = [fix(l) for l in lines]
used = {fix(u) for u in used}

ramnames = [l.split('#')[0].split() for l in open(rams).read().split('[names]')[1].splitlines()]
ramnames = [l for l in ramnames if len(l) == 2 and l[0].endswith('.m')]
with open(f'{fw6dir}/fw6_logic.blk', 'w') as f:
    f.write("# FW6's slice logic whole: every register by its block and name (u_<block>__<name>), every LUT RAM by its instance in the readable PicoBlaze (fw6-carry.py)\n[cells]\n*\n[names]\n")
    for n, nm in flat.items():
        f.write(f'{n:<22} {nm}\n')
    for k, v in ramnames:
        f.write(f'{k:<22} {v}\n')

o = ["// fw6_top / fw6_logic: the readable blocks stitched together by stage0/tools/fw6-carry.py; do not edit",
     f"// blocks: {' '.join(re.match(r'(\w+) u_', l).group(1) for l in lines)}", "",
     "module fw6_logic ("]
o.append('    ' + ',\n    '.join([f'input {n}' for n in ext_in] + [f'output {n}' for n in ext_out] + [f'inout {n}' for n in ext_inout]))
o.append(');')
for n in sorted(used - pset):
    o.append(f'wire {n};')
for nb, e in sorted(assigns.items()):
    o.append(f'assign {nb} = {fix(e)};')
o += lines + ['endmodule', '']
# the top: the design's primitives around the logic, as mktop.py writes it
src = open(b_path).read().split('\n')
header = [l for l in src if l.startswith('module ') or l.startswith('    inout ')]
o += [header[0].replace('fpga_top', 'fw6_top'), header[1], ');']
prims = [l for l in src if re.match(r'^(s3_\w+)\b', l) and not l.startswith('s3_slice')]
wires = [l for l in src if l.startswith('wire ')]
usedp = set(re.findall(r'\b[A-Za-z_]\w*\b', '\n'.join(prims + wires))) | pset
done = set()
for l in wires:
    m = re.match(r'wire\s+(\[[^\]]+\]\s+)?(\w+)\s*(=|;)', l)
    if not m:
        o.append(l); continue
    n = m.group(2)
    if m.group(3) == '=' and n in ext_out:
        continue
    if n in usedp or m.group(3) == '=':
        o.append(l); done.add(n)
for n in sorted(pset):
    if n not in done and n not in B.d.ports:
        o.append(f'wire {n};')
o.append('fw6_logic u_logic (' + ', '.join(f'.{n}({n})' for n in ext_in + ext_out + ext_inout) + ');')
o += prims + ['endmodule']
open(f'{fw6dir}/fw6_top.v', 'w').write('\n'.join(o) + '\n')
