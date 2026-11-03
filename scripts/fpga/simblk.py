#!/usr/bin/env python3
"""Build another build's block file from FW4's by what its nets compute.

    simblk.py A/design.v B/design.v MATCH A.blk -o B.blk [--alias A-FF=B-FF,B-FF ...]

blkmap.py carries a block through belmatch.py's pairs, and that fails
where the other build packs the same logic into different LUTs: a named
net (n_save, hi_n_win1) then has no bel of its own to carry to. This
instead simulates both designs on random values, the matched flip-flops
and pads sharing theirs, and names each B net that computes what a named
A net does. The block's cells are B's logic between the named inputs and
the named outputs. --names takes B nets named by hand first (logic as
outputs, registers and constants as inputs; a line ending in `in` or
`out` says which); --context-a and --context-b
take other blocks' names (A block files mapped the same way, B names as
given) as inputs, so the cone stops at them. --alias gives an A flip-flop's value to B flip-flops
that stand in for it without a pair (FW5's copies of one register).

Names with no B net of the same function are listed; so are nets the cone
reaches that no name covers. A random simulation can't tell a wide AND
from 0, so a decode like $x14D needs --hit to set its inputs in some
samples (several --hit sets go to overlapping samples). A named
output that drives a pad and has no B net of its function is named by the
B net at the same pin: the logic changed, and the proof shows how.
"""
import sys, os, re, random, argparse
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import carve, belmatch

COMB = ('s3_lut4', 's3_mux2', 's3_muxcy', 's3_xorcy')
W = 8192
RARE = 16          # a value with fewer ones (or zeros) than this proves nothing
FULL = (1 << W) - 1


def pin(c, net):
    """a leaf's output: a slice bel has one; a block RAM or pad output goes by
    its pin (n_X3Y1_BRAM_DOB_10 -> DOB_10, n_X13Y0c_BUFGMUX1_O -> O), as the output lists differ"""
    if c.slice is not None:
        return 0
    return re.sub(r"^(?:[nbd]_X\d+Y\d+[a-z]?_[A-Z]+\d*_|bo_D\d+X\d+Y\d+_)", "", net)


class Sim:
    def __init__(self, G, key, rnd, vals):
        self.d, self.key, self.rnd, self.vals, self.memo = G.d, key, rnd, vals, {}

    def leaf(self, k):
        if k not in self.vals:
            self.vals[k] = self.rnd.getrandbits(W)
        return self.vals[k]

    def expr(self, e):
        toks, pos = belmatch.TOK.findall(e), [0]
        def atom():
            t = toks[pos[0]]; pos[0] += 1
            if t == '~':
                return FULL ^ atom()
            if t == '(':
                v = conj(); pos[0] += 1
                return v
            if t.startswith("1'b"):
                return FULL if t == "1'b1" else 0
            return self.net(t)
        def conj():
            v = atom()
            while pos[0] < len(toks) and toks[pos[0]] == '&':
                pos[0] += 1
                v &= atom()
            return v
        return conj()

    def net(self, n):
        if n in self.memo:
            return self.memo[n]
        self.memo[n] = 0                    # breaks combinational loops
        d = self.d
        if n in d.producer:
            cn = d.producer[n]
            c = d.cells[cn]
            if c.kind not in COMB:
                # by pin (n_X3Y1_BRAM_DOB_10 -> DOB_10, n_X13Y0c_BUFGMUX1_O -> O): the output lists differ
                v = self.leaf(self.key(cn, pin(c, n)))
            else:
                g = lambda k, df="1'b0": self.expr(c.ins.get(k, df))
                if c.kind == 's3_lut4':
                    init = c.params['INIT']
                    init = int(init.split("'h")[-1], 16) if "'h" in init else int(init)
                    ins = [g(k, "1'b1") for k in ('I1', 'I2', 'I3', 'I4')]
                    v = 0
                    for m in range(16):
                        if init >> m & 1:
                            t = FULL
                            for i in range(4):
                                t &= ins[i] if m >> i & 1 else FULL ^ ins[i]
                            v |= t
                elif c.kind in ('s3_mux2', 's3_muxcy'):
                    s = g('S')
                    a1, a0 = (g('I1'), g('I0')) if c.kind == 's3_mux2' else (g('CI'), g('DI'))
                    v = (s & a1) | ((FULL ^ s) & a0)
                else:
                    v = g('LI') ^ g('CI')
        elif n in d.wires and re.fullmatch(r'\w+\[\d+\]', d.wires[n]):
            # a bit of a block RAM's output bus
            bus, bit = re.fullmatch(r'(\w+)\[(\d+)\]', d.wires[n]).groups()
            cn = d.producer.get(bus)
            v = self.leaf(self.key(cn, f'{pin(d.cells[cn], bus)}[{bit}]')) if cn else self.leaf(('net', id(self), n))
        elif n in d.wires:
            v = self.expr(d.wires[n])
        elif re.fullmatch(r'P\d+', n):
            v = self.leaf(('pad', n))
        else:
            v = self.leaf(('net', id(self), n))
        self.memo[n] = v
        return v


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('a'); ap.add_argument('b'); ap.add_argument('match'); ap.add_argument('blk')
    ap.add_argument('-o', required=True)
    ap.add_argument('--alias', nargs='*', default=[])
    ap.add_argument('--names', help='B nets named by hand (net name per line); they win over the simulation')
    ap.add_argument('--context-a', nargs='*', default=[], metavar='BLK',
                    help="other A block files: their names, found in B, are this block's inputs")
    ap.add_argument('--context-b', nargs='*', default=[], metavar='NAMES',
                    help="other blocks' B names (net name per line), taken as inputs")
    ap.add_argument('--hit', nargs='*', default=[], metavar='NAME=V,...',
                    help='named inputs set to these values in a quarter of the samples')
    args = ap.parse_args()
    A, B = belmatch.Graph(args.a), belmatch.Graph(args.b)
    ab = {}
    for l in open(args.match):
        a, b = l.split()
        if '-' not in (a, b):
            ab[a] = b
    alias = {}
    for s in args.alias:
        a, bs = s.split('=')
        for b in bs.split(','):
            alias[b] = ab.get(a, ('A', a))
    rnd, vals = random.Random(1), {}
    sa = Sim(A, lambda c, p: (ab.get(c, ('A', c)), p), rnd, vals)
    sb = Sim(B, lambda c, p: (alias.get(c, c), p), rnd, vals)
    name, desc, cells, names = carve.read_block(args.blk, A.d)
    acells = set(cells)
    byname = {nm: net for net, nm in names.items()}
    for hit in args.hit:            # a wide decode random values never reach
        rows = rnd.getrandbits(W) & rnd.getrandbits(W)
        for kv in hit.split(','):
            k, v = kv.split('=')
            net = byname[k]
            cn = A.d.producer[net]
            key = sa.key(cn, pin(A.d.cells[cn], net))    # a pad: no bus
            x = sa.leaf(key)
            vals[key] = x | rows if v == '1' else x & ~rows & FULL
    # every B net by value
    byval = {}
    for n in list(B.d.producer) + list(B.d.wires):
        v = sb.net(n)
        if RARE <= bin(v).count('1') <= W - RARE:
            byval.setdefault(v, []).append(n)
    def rank(n, want_ff):
        p = prod(B.d, n)
        kind = B.d.cells[p].kind if p else ''
        return (want_ff != (kind == 's3_ff'), not n.startswith('n_'), n)
    def pads(G):
        out = {}
        for n, c in G.d.cells.items():
            if c.kind == 's3_ioi':
                for pin in ('O1', 'T1'):
                    sx = belmatch.simple(c.ins.get(pin, ''))
                    if sx and not sx[1]:
                        out.setdefault(sx[0], (n, pin))
        return out
    apad = pads(A)
    bpad = {k: n for n, k in pads(B).items()}
    apad = {n: k for n, k in apad.items() if k in bpad}
    out_names, bnames, missing, changed = set(), {}, [], []
    given, given_in, given_out = {}, set(), set()
    if args.names:
        for l in open(args.names):
            l = l.split('#')[0].split()
            if l:
                given[l[0]] = l[1]
                if l[2:] == ['in']:
                    given_in.add(l[1])
                elif l[2:] == ['out']:
                    given_out.add(l[1])
    def prod(d, net):
        for _ in range(8):
            if net in d.producer:
                return d.producer[net]
            sx = belmatch.simple(d.wires.get(net, ''))
            if not sx:
                return None
            net = sx[0]
    for net, nm in names.items():
        if nm in given.values():
            continue
        p = prod(A.d, net)
        inside = p in acells
        want_ff = bool(p) and A.d.cells[p].kind == 's3_ff'
        if net not in A.d.producer and net not in A.d.wires and not re.fullmatch(r'P\d+', net):
            continue
        v = sa.net(net)
        if p and A.d.cells[p].kind == 's3_ff' and not inside and p not in ab and \
                ('A', p) not in alias.values():
            missing.append(f'{nm} ({net}: input register with no pair)')
            continue
        cands = sorted(byval.get(v, []), key=lambda n: rank(n, want_ff))
        rare = not RARE <= bin(v).count('1') <= W - RARE
        if rare and v not in (0, FULL):
            missing.append(f'{nm} ({net}: too rarely 1 or 0 to tell, give it by hand)')
            continue
        if not cands and inside and net in apad:
            cands = [bpad[apad[net]]]       # the net at the same pin
            changed.append(f'{nm} ({net}: named by its pin, {apad[net][0]}.{apad[net][1]})')
        if not cands:
            if inside or v not in (0, FULL):
                missing.append(f'{nm} ({net})')
            continue
        if want_ff and not inside and len([c for c in cands if rank(c, True)[0] is False]) > 1:
            # copies of one register: name them all
            for c in cands:
                if rank(c, True)[0] is False:
                    bnames[c] = nm
        else:       # two names on one net (a LUT's b_ and n_ sides) take one each
            bnames[next((c for c in cands if c not in bnames), cands[0])] = nm
        if inside:
            out_names.add(nm)
    # other blocks' names stop the cone: they are inputs here
    ctx = {}
    for path in args.context_a:
        for net, nm in carve.read_block(path, A.d)[3].items():
            if nm in names.values() or nm in given.values():
                continue
            v = sa.net(net) if (net in A.d.producer or net in A.d.wires) else None
            cands = [n for n in byval.get(v, []) if n.startswith('n_')] if v is not None else []
            if len(cands) >= 1:
                for c in cands:
                    ctx.setdefault(c, nm)
    for path in args.context_b:     # a names file, or a block file's [names]
        text = open(path).read()
        for l in (text.split('[names]', 1)[1] if '[names]' in text else text).splitlines():
            l = l.split('#')[0].split()
            if len(l) >= 2 and l[1] not in names.values() and l[1] not in given.values():
                ctx[l[0]] = l[1]
    for n, nm in ctx.items():
        if n not in bnames and nm not in bnames.values():
            bnames[n] = nm
    for n, nm in given.items():     # logic is an output; a register or a constant an input
        bnames[n] = nm
        c = B.d.cells.get(prod(B.d, n))
        if nm in given_out or nm not in given_in and c and c.kind in COMB and \
                any(not x.startswith("1'b") for x in c.ins.values()):
            out_names.add(nm)
    # the cone: back from the outputs to the inputs
    roots = {}
    for n, nm in list(bnames.items()):  # an input on a LUT's n_ side: its own slice reads the b_ side
        if nm in out_names:
            continue
        root = n
        for _ in range(8):
            sx = belmatch.simple(B.d.wires.get(root, ''))
            if not sx or sx[1] or sx[0] in bnames:
                break
            root = sx[0]
        if root != n:
            roots[root] = nm
    inputs = {n for n, nm in bnames.items() if nm not in out_names} | set(roots)
    bcells, unnamed, seen = [], set(), set()
    stack = [n for n, nm in bnames.items() if nm in out_names]
    while stack:
        n = stack.pop()
        if n in seen:
            continue
        seen.add(n)
        if n in inputs:
            continue
        if n in B.d.producer:
            cn = B.d.producer[n]
            c = B.d.cells[cn]
            if c.slice is None or (c.kind == 's3_ff' and n not in bnames):
                unnamed.add(n)
                continue
            if cn not in bcells:
                bcells.append(cn)
                for x in c.ins.values():
                    stack.extend(carve.nets_of(x))
        elif n in B.d.wires:
            stack.extend(carve.nets_of(B.d.wires[n]))
        elif not re.fullmatch(r'P\d+', n):
            unnamed.add(n)
    read = {x for c in bcells for v in B.d.cells[c].ins.values() for x in carve.nets_of(v)}
    for n, nm in roots.items():
        if n in read:
            bnames[n] = nm
    with open(args.o, 'w') as f:
        f.write(f'# {desc} (simblk.py from {args.blk})\n[cells]\n')
        for c in sorted(bcells):
            f.write(c + '\n')
        f.write('[names]\n')
        for n, nm in bnames.items():
            f.write(f'{n:26s} {nm}\n')
    print(f'{name}: {len(bcells)} cells, {len(bnames)} names')
    for m in changed:
        print('  different function,', m)
    for m in missing:
        print('  no B net computes', m)
    for n in sorted(unnamed):
        print('  unnamed input', n, '<-', B.d.producer.get(n, ''))


if __name__ == '__main__':
    main()
