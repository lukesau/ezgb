#!/usr/bin/env python3
"""Write a block file for logic only FW5-0918 has, in FW5's coordinates.

    fw5blk.py DESIGN.v --names OWN.names --context BLK... -o OUT.blk SEED...

SEEDs are the block's registers (X1Y25_S1.FFX) or nets. The block takes
every LUT, mux and carry bel behind them, back to a net with a name
(OWN.names first, then the context block files' [names]) or a register,
pad or other primitive. OWN.names lines are `net name [in|out]`; an `in`
stops the walk at that net. Names are copied for every boundary net the
block reads or drives, so the file stands alone.
"""
import argparse, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import carve

COMB = ('s3_lut4', 's3_mux2', 's3_muxcy', 's3_xorcy')


def names_of(path):
    text = open(path).read()
    body = text.split('[names]', 1)[1] if '[names]' in text else text
    out = []
    for raw in body.splitlines():
        f = raw.split('#', 1)[0].split()
        if len(f) >= 2:
            out.append((f[0], f[1], f[2] if len(f) > 2 else ''))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('design')
    ap.add_argument('seeds', nargs='+')
    ap.add_argument('--names', required=True)
    ap.add_argument('--context', nargs='*', default=[])
    ap.add_argument('--desc', default='')
    ap.add_argument('-o', required=True)
    a = ap.parse_args()
    d = carve.Design(a.design)
    own = names_of(a.names)
    stop = {n for n, _, k in own if k == 'in'}
    name = {}
    for n, nm, _ in own:
        name.setdefault(n, nm)
    ctx = {}
    for f in a.context:
        for n, nm, _ in names_of(f):
            ctx.setdefault(n, nm)
    cells, seen = [], set()
    todo = []
    for s in a.seeds:
        if '.' in s:
            cells.append(s)
            todo.extend(d.cells[s].reads())
        else:
            todo.append(s)
    while todo:
        n = todo.pop()
        if n in seen:
            continue
        seen.add(n)
        if n in stop or (n in ctx and n not in name) and not n.startswith('d_'):
            continue
        p = d.producer.get(n)
        if p and d.cells[p].kind in COMB:
            if p not in cells:
                cells.append(p)
            todo.extend(d.cells[p].reads())
        elif n in d.wires:
            todo.extend(carve.nets_of(d.wires[n]))
    # names for every net the cells touch that has one
    touched = set()
    for c in cells:
        touched.update(d.cells[c].reads())
        touched.update(d.cells[c].outs)
    with open(a.o, 'w') as f:
        f.write(f"# {a.desc}\n[cells]\n")
        for c in sorted(cells):
            f.write(c + '\n')
        f.write('[names]\n')
        done = set()
        for n, nm, _ in own:
            if n not in done:
                f.write(f"{n:<26} {nm}\n"); done.add(n)
        for n in sorted(touched):
            if n in ctx and n not in done:
                f.write(f"{n:<26} {ctx[n]}\n"); done.add(n)
    print(f"{a.o}: {len(cells)} cells", file=sys.stderr)


if __name__ == '__main__':
    main()
