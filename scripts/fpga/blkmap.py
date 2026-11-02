#!/usr/bin/env python3
"""Carry a block file from one design to another through a bel matching.

    blkmap.py A/design.v B/design.v MATCH BLOCK.blk -o OUT.blk

MATCH is belmatch.py --dump output ("a b" pairs, "a -" and "- b" for the
unmatched). The new block holds the B bels matched to the block's A bels,
plus every unmatched combinational B bel in the cones that feed the block's
B flip-flops and outputs (logic B packed differently or added), and the
block's names moved onto B's nets. A name whose net has no partner in B is
reported and left out, as is every A bel without a partner.

With the new block, equiv.sh proves the readable module against B:

    BLK=OUT.blk scripts/fpga/equiv.sh BLOCK B
"""
import sys, os, re, argparse
from collections import OrderedDict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import carve

SEQ = ('s3_ff', 's3_bram', 's3_ioi', 's3_ram16', 's3_srl16', 's3_dcm', 's3_dna', 's3_icap', 's3_bufgmux')


def root(d, net, depth=0):
    """the bel that drives a net, through plain wiring, and which of its outputs"""
    if net in d.producer:
        return d.producer[net], net
    if net in d.wires and depth < 8:
        e = d.wires[net]
        if re.fullmatch(r'\w+', e):
            return root(d, e, depth + 1)
    return None, None


def reader_net(A, B, ab, net):
    """the B net on the same pin of the matched partners of the bels that
    read net, when they all agree (a LUT counts only when its partner has
    the same INIT, so the pins line up)"""
    seen = set()
    for r in A.cell_readers.get(net, ()):
        ca = A.cells[r]
        if r not in ab:
            continue
        cb = B.cells[ab[r]]
        if ca.kind == 's3_lut4' and ca.params.get('INIT') != cb.params.get('INIT'):
            continue
        for k, e in ca.ins.items():
            if e == net and re.fullmatch(r'\w+', cb.ins.get(k, '')):
                seen.add(cb.ins[k])
    return seen.pop() if len(seen) == 1 else None


def pin_net(A, B, ab, cell, net):
    """a net on an output pin of a matched non-slice bel (a BRAM's data
    bus): the B partner's net on the same pin and bit"""
    if cell not in ab or A.cells[cell].slice is not None:
        return None
    ka, _, _, ca = A.inst[cell]
    kb, _, _, cb = B.inst[ab[cell]]
    for p, e in ca.items():
        na = carve.nets_of(e)
        if net in na:
            nb = carve.nets_of(cb.get(p, ''))
            if len(nb) == len(na):
                return nb[na.index(net)]
    return None


def bus_bit(A, B, ab, net):
    """a net that is one bit of a matched non-slice bel's output bus (a block
    RAM's DOB[i]): B's net for the same pin and bit"""
    m = re.fullmatch(r'(\w+)\[(\d+)\]', A.wires.get(net, ''))
    if not m:
        return None
    for cell, (kind, _, _, conns) in A.inst.items():
        for p, e in conns.items():
            if e == m.group(1) and cell in ab:
                eb = B.inst[ab[cell]][3].get(p, '')
                want = f'{eb}[{m.group(2)}]'
                for w, x in B.wires.items():
                    if x == want and w.startswith('n_'):
                        return w
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('a')
    ap.add_argument('b')
    ap.add_argument('match')
    ap.add_argument('block')
    ap.add_argument('-o', '--out', required=True)
    args = ap.parse_args()
    A, B = carve.Design(args.a), carve.Design(args.b)
    ab, b_free = {}, set()
    for line in open(args.match):
        x, y = line.split()
        if x != '-' and y != '-':
            ab[x] = y
        elif x == '-':
            b_free.add(y)
    ba = {v: k for k, v in ab.items()}
    name, desc, cells, names = carve.read_block(args.block, A)
    cells = [c for c in cells if c in A.live_cells]
    mine = set(cells)
    missing = [c for c in cells if c not in ab]
    bcells = [ab[c] for c in cells if c in ab]
    # aliases: a bel output net -> the design net that carries it
    alias = {}
    for net, e in B.wires.items():
        if re.fullmatch(r'\w+', e) and net.startswith('n_'):
            alias.setdefault(e, net)
    a_alias = {}
    for net, e in A.wires.items():
        if re.fullmatch(r'\w+', e) and net.startswith('n_'):
            a_alias.setdefault(e, net)
    named = lambda c: any(o in names or a_alias.get(o) in names for o in A.cells[c].outs)
    # unmatched combinational B bels feeding the block's B cells, and matched
    # ones whose partner A computes inside another block without a port here
    inblk = set(bcells)
    todo = list(bcells)
    while todo:
        c = B.cells[todo.pop()]
        for k, e in c.ins.items():
            if k == 'CLK':
                continue
            stack = list(carve.nets_of(e))
            while stack:
                net = stack.pop()
                p = B.producer.get(net)
                if p is None:
                    if net in B.wires:
                        stack += carve.nets_of(B.wires[net])
                    continue
                pc = B.cells[p]
                if p in inblk or pc.kind in SEQ or pc.slice is None:
                    continue
                if p in ba and (ba[p] in mine or named(ba[p])):
                    continue        # matched: belongs where its partner belongs
                inblk.add(p)
                bcells.append(p)
                todo.append(p)
    added = len(bcells) - (len(cells) - len(missing))
    # names onto B's nets
    out_names, lost = OrderedDict(), []
    for net, new in names.items():
        if re.fullmatch(r'P\d+', net):
            out_names[net] = new
            continue
        m = re.fullmatch(r'(X\d+Y\d+_S\d_[FG])\.m', net)
        if m:                       # LUT RAM contents
            cell = m.group(1)[:-2] + '.' + m.group(1)[-1]
            if cell in ab:
                b = ab[cell]
                out_names[b[:-2] + '_' + b[-1] + '.m'] = new
            else:
                lost.append(net)
            continue
        if net not in A.producer and net not in A.wires:
            continue                # a common name this design lacks
        cell, bnet = root(A, net)
        if cell is None and bus_bit(A, B, ab, net):
            out_names[bus_bit(A, B, ab, net)] = new
            continue
        if cell is None or cell not in ab:
            # no partner for the driver (a clock buffer, a constant LUT): take
            # the net that the matched readers' partners have on the same pin
            got = reader_net(A, B, ab, net)
            if got:
                out_names[alias.get(got, got)] = new
            else:
                lost.append(net)
            continue
        acell, bcell = A.cells[cell], B.cells[ab[cell]]
        try:
            i = acell.outs.index(bnet)
            target = bcell.outs[i]
        except (ValueError, IndexError):
            target = pin_net(A, B, ab, cell, bnet)
            if target is None:
                lost.append(net)
                continue
        # a name on the bel net itself stays on it; one on its alias takes B's alias
        out_names[target if net == bnet else alias.get(target, target)] = new
    with open(args.out, 'w') as f:
        f.write(f"# {desc} (carried from {os.path.basename(args.a.rstrip('/'))} by blkmap.py)\n[cells]\n")
        for c in bcells:
            f.write(c[2:] + '\n' if c.startswith('i_') else c + '\n')
        f.write('[names]\n')
        for net, new in out_names.items():
            f.write(f"{net} {new}\n")
    print(f"{name}: {len(cells) - len(missing)}/{len(cells)} bels carried, {added} B bels added from the fan-in, "
          f"{len(lost)} names lost", file=sys.stderr)
    for c in missing[:20]:
        print(f"  no partner: {c}", file=sys.stderr)
    for n in lost[:20]:
        print(f"  name lost: {n} {names[n]}", file=sys.stderr)


if __name__ == '__main__':
    main()
