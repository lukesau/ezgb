#!/usr/bin/env python3
"""Match the bels of two exported designs (two firmware builds) by structure.

    belmatch.py A/design.v B/design.v [--ignore-sr NET...] [--seed FILE] [--blocks stage0/blocks/*.blk] [--dump OUT]

Placement differs from build to build, so bels are matched by what they
compute, not where they sit. The matching starts from anchors (the pads by
pin name, the live DCM, DNA and ICAP) and grows outward:

  forward    an unmatched bel whose inputs come from matched bels gets a
             signature from its kind, its fixed parameters and those inputs
             (unmatched ones are wildcards); a LUT's is its function over the
             inputs it depends on, constants and inversions folded in, in the
             input order that gives the smallest key
  backward   the drivers on the same pins of a matched pair are a pair (for
             a LUT, when only one input alignment fits its function)
  fanout     unmatched bels told apart by the matched bels they feed
  registers  unmatched flip-flops told apart by the matched registers in
             their fan-in and fan-out cones, through any logic (and their
             clock and parameters)
  functions  unmatched flip-flops told apart by the function on each pin
             over the matched nets under it, however the LUTs are packed

A signature that occurs once on each side is a match. A clock buffer with a
fixed select is treated as a wire. --ignore-sr names nets of B whose use as
a flip-flop's reset is ignored, for a reset B has and A lacks. --seed adds
pairs found by hand ("a b" per line) to the anchors, for registers that
nothing else tells apart (identical crossings); equiv.sh still checks them.

What stays unmatched is logic that differs (or is packed differently)
between the builds. With --blocks, the report counts, per block of design
A, how many of its bels found a partner in B; --dump writes the pairs for
blkmap.py.
"""
import sys, os, re, argparse, hashlib, itertools
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import carve

TOK = re.compile(r"~|\(|\)|&|1'b[01]|[A-Za-z_]\w*")


def h(*parts):
    return hashlib.blake2b(repr(parts).encode(), digest_size=8).hexdigest()


class Graph:
    def __init__(self, path):
        self.d = d = carve.Design(path)
        self.cells = [c for c in d.cells if c in d.live_cells]
        self.ignore = set()     # flip-flop resets to treat as absent when matching

    def src(self, net):
        """a net -> ('cell', name) | ('pad', P) | ('const', v) | ('expr', tokens)"""
        d = self.d
        if net in d.producer:
            return ('cell', d.producer[net])
        if net in d.wires:
            return ('expr', d.wires[net])
        if re.fullmatch(r'P\d+', net):
            return ('pad', net)
        return ('const', 'x')

    def static(self, name):
        c = self.d.cells[name]
        if c.kind == 's3_ioi':
            pads = [n for n in c.outs if re.fullmatch(r'P\d+', n)]
            return h('ioi', tuple(pads), tuple(sorted(c.params.items())))
        if c.kind == 's3_bram':
            P = {k: v for k, v in c.params.items() if k not in ('DATAFILE', 'PARFILE')}
            return h('bram', tuple(sorted(P.items())))
        if c.kind == 's3_lut4':
            return 'lut'
        if c.kind in ('s3_ram16', 's3_srl16'):
            return h(c.kind)            # contents are runtime state
        return h(c.kind, tuple(sorted(c.params.items())))

def simple(expr):
    """a plain net or its inversion -> (net, inverted), else None"""
    m = re.fullmatch(r'(~?)(\w+)', expr)
    return (m.group(2), bool(m.group(1))) if m else None


class Matcher:
    """grow a one-to-one bel matching outward from anchors (pads, DCM, DNA,
    ICAP). A bel's signature uses only its matched neighbors; unmatched
    ones are wildcards, so a change in one place stays local."""
    def __init__(self, A, B):
        self.A, self.B = A, B
        self.ab, self.ba = {}, {}
        for G in (A, B):
            G.outpin = {}
            for n in G.cells:
                c = G.d.cells[n]
                if c.slice is not None:
                    for i, o in enumerate(c.outs):
                        G.outpin[o] = i
                else:
                    kind, line, P, conns = G.d.inst[n]
                    for p in carve.OUTPINS.get(kind, ()) + carve.INOUT.get(kind, ()):
                        for o in carve.nets_of(conns.get(p, '')):
                            G.outpin[o] = p
        anchor = lambda G: {self.akey(G, n): n for n in G.cells if self.akey(G, n)}
        ka, kb = anchor(A), anchor(B)
        for k in ka.keys() & kb.keys():
            self.pair(ka[k], kb[k])

    def akey(self, G, n):
        c = G.d.cells[n]
        if c.kind == 's3_ioi':
            pads = [o for o in c.outs if re.fullmatch(r'P\d+', o)]
            return ('pad',) + tuple(pads)
        if c.kind == 's3_dcm':
            return ('dcm', 'live') if c.ins.get('CLKIN', "1'b0") != "1'b0" else None
        if c.kind in ('s3_dna', 's3_icap'):
            return (c.kind,)
        return None

    def pair(self, a, b):
        self.ab[a], self.ba[b] = b, a

    def ref(self, G, net, side, depth=0):
        """a net as seen from the matching: a stable token or '*'"""
        d = G.d
        if net in d.producer:
            n = d.producer[net]
            c = d.cells[n]
            if c.kind == 's3_bufgmux' and c.ins.get('S') in ("1'b0", "1'b1"):
                # a clock buffer with a fixed select is a wire
                sel = c.ins.get('I1' if c.ins['S'] == "1'b1" else 'I0', "1'b0")
                return self.expr(G, sel, side, depth + 1)
            m = self.ab.get(n) if side == 'A' else n if n in self.ba else None
            if m is None:
                return '*'
            key = m if side == 'A' else n          # name the pair by its B cell
            return f'{key}.{G.outpin.get(net)}'
        if net in d.wires and depth < 8:
            return '(' + self.expr(G, d.wires[net], side, depth + 1) + ')'
        if re.fullmatch(r'P\d+', net):
            return net
        return '?'

    def expr(self, G, e, side, depth=0):
        out = []
        for t in TOK.findall(e):
            if t in ('~', '(', ')', '&') or t.startswith("1'b"):
                out.append(t)
            else:
                out.append(self.ref(G, t, side, depth))
        return ' '.join(out)

    def sig(self, G, n, side):
        c = G.d.cells[n]
        if G.ignore and c.kind == 's3_ff' and c.ins.get('SR') in G.ignore:
            c = carve.Cell(c.name, c.kind, c.params, dict(c.ins, SR="1'b0"), c.outs, c.slice)
        if c.kind == 's3_lut4':
            key = self.lut_sig(G, c, side)
            if key is None:
                return None
            return ('lut',) + key
        ins = tuple(sorted((k, self.expr(G, e, side)) for k, e in c.ins.items()))
        known = sum(1 for k, v in ins if re.search(r'\w+\.\w+|P\d+', v))
        if known == 0:
            return None
        return (G.static(n), ins)

    def lut_sig(self, G, c, side):
        init = int(c.params['INIT'].split("'h")[-1], 16) if "'h" in c.params['INIT'] else int(c.params['INIT'])
        fixed, live = [0, 0, 0, 0], []
        for i, k in enumerate(('I1', 'I2', 'I3', 'I4')):
            e = c.ins.get(k, "1'b1")
            if e in ("1'b0", "1'b1"):
                fixed[i] = int(e[-1])
                continue
            s = simple(e)
            if s:
                live.append((i, s[1], self.ref(G, s[0], side)))
            else:
                live.append((i, False, self.expr(G, e, side)))
        def table(order):
            t = 0
            for idx in range(1 << len(order)):
                bits = list(fixed)
                for j, (i, neg, _) in enumerate(order):
                    bits[i] = ((idx >> j) & 1) ^ neg
                t |= ((init >> (bits[0] | bits[1] << 1 | bits[2] << 2 | bits[3] << 3)) & 1) << idx
            return t
        changed = True
        while changed:
            changed = False
            for j in range(len(live)):
                t, n = table(live), len(live)
                if not any(((t >> x) & 1) != ((t >> (x ^ (1 << j))) & 1) for x in range(1 << n)):
                    live.pop(j)
                    changed = True
                    break
        if not any(r != '*' for _, _, r in live):
            return None
        best = None
        for perm in itertools.permutations(live):
            key = (table(list(perm)), tuple(p[2] for p in perm))
            if best is None or key < best:
                best = key
        return (len(live),) + best

    def forward(self):
        sa, sb = defaultdict(list), defaultdict(list)
        for n in self.A.cells:
            if n not in self.ab:
                s = self.sig(self.A, n, 'A')
                if s is not None:
                    sa[s].append(n)
        for n in self.B.cells:
            if n not in self.ba:
                s = self.sig(self.B, n, 'B')
                if s is not None:
                    sb[s].append(n)
        added = 0
        for s, la in sa.items():
            lb = sb.get(s)
            if len(la) == 1 and lb and len(lb) == 1:
                self.pair(la[0], lb[0])
                added += 1
        return added

    def backward(self):
        """matched non-LUT pairs: the drivers on the same pins are a pair"""
        added = 0
        for a, b in list(self.ab.items()):
            ca, cb = self.A.d.cells[a], self.B.d.cells[b]
            if ca.kind != cb.kind or ca.kind == 's3_lut4':
                continue
            for k, ea in ca.ins.items():
                eb = cb.ins.get(k)
                if k == 'SR' and eb in self.B.ignore:
                    continue
                sa_, sb_ = simple(ea), simple(eb or '')
                if not sa_ or not sb_ or sa_[1] != sb_[1]:
                    continue
                da, db = self.A.d.producer.get(sa_[0]), self.B.d.producer.get(sb_[0])
                if not da or not db or da in self.ab or db in self.ba:
                    continue
                if self.A.d.cells[da].kind != self.B.d.cells[db].kind:
                    continue
                if self.A.outpin.get(sa_[0]) != self.B.outpin.get(sb_[0]):
                    continue
                self.pair(da, db)
                added += 1
        return added

    def lut_inputs(self, G, c, side):
        """a LUT's live inputs as (pin, inverted, ref, net) and its table function"""
        init = int(c.params['INIT'].split("'h")[-1], 16) if "'h" in c.params['INIT'] else int(c.params['INIT'])
        fixed, live = [0, 0, 0, 0], []
        for i, k in enumerate(('I1', 'I2', 'I3', 'I4')):
            e = c.ins.get(k, "1'b1")
            if e in ("1'b0", "1'b1"):
                fixed[i] = int(e[-1])
                continue
            s = simple(e)
            if not s:
                return None, None
            live.append((i, s[1], self.ref(G, s[0], side), s[0]))
        def table(order):
            t = 0
            for idx in range(1 << len(order)):
                bits = list(fixed)
                for j, o in enumerate(order):
                    bits[o[0]] = ((idx >> j) & 1) ^ o[1]
                t |= ((init >> (bits[0] | bits[1] << 1 | bits[2] << 2 | bits[3] << 3)) & 1) << idx
            return t
        changed = True
        while changed:
            changed = False
            for j in range(len(live)):
                t, n = table(live), len(live)
                if not any(((t >> x) & 1) != ((t >> (x ^ (1 << j))) & 1) for x in range(1 << n)):
                    live.pop(j)
                    changed = True
                    break
        return live, table

    def backward_luts(self):
        """matched LUT pairs: align inputs; a wildcard input that only one
        alignment allows pairs its drivers"""
        added = 0
        for a, b in list(self.ab.items()):
            ca, cb = self.A.d.cells[a], self.B.d.cells[b]
            if ca.kind != 's3_lut4' or cb.kind != 's3_lut4':
                continue
            la, ta = self.lut_inputs(self.A, ca, 'A')
            lb, tb = self.lut_inputs(self.B, cb, 'B')
            if la is None or lb is None or len(la) != len(lb) or not any(x[2] == '*' for x in la):
                continue
            want = ta(la)
            maps = set()
            for perm in itertools.permutations(lb):
                if tb(list(perm)) != want:
                    continue
                if any(x[2] != '*' and y[2] != '*' and x[2] != y[2] for x, y in zip(la, perm)):
                    continue
                if any((x[2] == '*') != (y[2] == '*') for x, y in zip(la, perm)):
                    continue
                maps.add(tuple((x[3], y[3]) for x, y in zip(la, perm) if x[2] == '*'))
            if len(maps) != 1:
                continue
            for na, nb in maps.pop():
                da, db = self.A.d.producer.get(na), self.B.d.producer.get(nb)
                if not da or not db or da in self.ab or db in self.ba:
                    continue
                if self.A.d.cells[da].kind != self.B.d.cells[db].kind or self.A.outpin.get(na) != self.B.outpin.get(nb):
                    continue
                self.pair(da, db)
                added += 1
        return added

    def readers(self, G, net, depth=0):
        out = set()
        for r in G.d.cell_readers.get(net, ()):
            c = G.d.cells[r]
            if c.kind == 's3_bufgmux' and c.ins.get('S') in ("1'b0", "1'b1") and depth < 8:
                sel = c.ins.get('I1' if c.ins['S'] == "1'b1" else 'I0', '')
                if net in carve.nets_of(sel):
                    for o in c.outs:
                        out |= self.readers(G, o, depth + 1)
                continue
            out.add(r)
        if depth < 8:
            for w in G.d.wire_users.get(net, ()):
                out |= self.readers(G, w, depth + 1)
        return out

    def fanout(self):
        """unmatched bels told apart by the matched bels they feed"""
        def sigs(G, side, mine):
            out = defaultdict(list)
            for n in G.cells:
                if n in mine:
                    continue
                c = G.d.cells[n]
                rd = set()
                for o in c.outs:
                    for r in self.readers(G, o):
                        m = self.ab.get(r) if side == 'A' else r if r in self.ba else None
                        if m:
                            rd.add((m, G.outpin.get(o)))
                if rd:
                    out[(G.static(n), tuple(sorted(rd)))].append(n)
            return out
        sa, sb = sigs(self.A, 'A', self.ab), sigs(self.B, 'B', self.ba)
        added = 0
        for s, la in sa.items():
            lb = sb.get(s)
            if len(la) == 1 and lb and len(lb) == 1 and la[0] not in self.ab and lb[0] not in self.ba:
                self.pair(la[0], lb[0])
                added += 1
        return added

    SEQ = ('s3_ff', 's3_bram', 's3_ioi', 's3_ram16', 's3_srl16', 's3_dcm', 's3_dna', 's3_icap')

    def cone(self, G, n, side, back=True, limit=400):
        """the matched sequential cells reached through combinational bels"""
        mine = self.ab if side == 'A' else self.ba
        seen, out, todo = {n}, set(), []
        def push(x):
            if x not in seen:
                seen.add(x)
                todo.append(x)
        c = G.d.cells[n]
        if back:
            for k, e in c.ins.items():
                if k == 'CLK' or (k == 'SR' and e in G.ignore):
                    continue
                for net in self.srcnets(G, e):
                    p = G.d.producer.get(net)
                    if p:
                        push(p)
        else:
            for o in c.outs:
                for r in self.readers(G, o):
                    push(r)
        while todo and len(seen) < limit:
            x = todo.pop()
            cx = G.d.cells[x]
            if cx.kind in self.SEQ or cx.kind == 's3_bufgmux':
                if x in mine:
                    out.add(mine[x] if side == 'A' else x)
                elif cx.kind == 's3_ioi':
                    out.add(x)
                continue
            if back:
                for k, e in cx.ins.items():
                    for net in self.srcnets(G, e):
                        p = G.d.producer.get(net)
                        if p:
                            push(p)
            else:
                for o in cx.outs:
                    for r in self.readers(G, o):
                        push(r)
        return frozenset(out)

    def srcnets(self, G, e, depth=0):
        out = []
        for net in carve.nets_of(e):
            if net in G.d.producer:
                out.append(net)
            elif net in G.d.wires and depth < 8:
                out += self.srcnets(G, G.d.wires[net], depth + 1)
        return out

    def regs(self):
        """unmatched flip-flops told apart by the matched registers around them"""
        def sigs(G, side, mine):
            out = defaultdict(list)
            for n in G.cells:
                c = G.d.cells[n]
                if n in mine or c.kind != 's3_ff':
                    continue
                bk, fw = self.cone(G, n, side, True), self.cone(G, n, side, False)
                if bk or fw:
                    # the same clock and parameters too: cones alone pair
                    # registers of different domains that feed the same mux
                    clk = self.expr(G, c.ins.get('CLK', ''), side)
                    out[(G.static(n), clk, bk, fw)].append(n)
            return out
        sa, sb = sigs(self.A, 'A', self.ab), sigs(self.B, 'B', self.ba)
        added = 0
        for s, la in sa.items():
            lb = sb.get(s)
            if len(la) == 1 and lb and len(lb) == 1:
                self.pair(la[0], lb[0])
                added += 1
        return added

    COMB = ('s3_lut4', 's3_mux2', 's3_muxcy', 's3_xorcy')
    MAXLEAVES = 12

    def leaves(self, G, e, side, out, seen, depth=0):
        """collect the matched nets (as refs) under an expression, through
        unmatched combinational bels; False if it reaches anything else"""
        for net in carve.nets_of(e):
            if net in seen:
                continue
            seen.add(net)
            r = self.ref(G, net, side)
            if '*' not in r and '?' not in r:
                out[r] = net
            elif net in G.d.producer:
                c = G.d.cells[G.d.producer[net]]
                if c.kind not in self.COMB or depth > 40:
                    return False
                for x in c.ins.values():
                    if not self.leaves(G, x, side, out, seen, depth + 1):
                        return False
            elif net in G.d.wires:
                if not self.leaves(G, G.d.wires[net], side, out, seen, depth + 1):
                    return False
            else:
                return False
            if len(out) > self.MAXLEAVES:
                return False
        return True

    def evaluate(self, G, e, side, env, full, memo):
        """an expression's truth table (a bit vector over the leaf assignments)"""
        toks = TOK.findall(e)
        pos = [0]
        def atom():
            t = toks[pos[0]]; pos[0] += 1
            if t == '~':
                return full ^ atom()
            if t == '(':
                v = conj()
                pos[0] += 1             # ')'
                return v
            if t.startswith("1'b"):
                return full if t == "1'b1" else 0
            return self.net_value(G, t, side, env, full, memo)
        def conj():
            v = atom()
            while pos[0] < len(toks) and toks[pos[0]] == '&':
                pos[0] += 1
                v &= atom()
            return v
        return conj()

    def net_value(self, G, net, side, env, full, memo):
        r = self.ref(G, net, side)
        if r in env:
            return env[r]
        if net in memo:
            return memo[net]
        if net in G.d.producer:
            c = G.d.cells[G.d.producer[net]]
            ev = lambda k, default="1'b0": self.evaluate(G, c.ins.get(k, default), side, env, full, memo)
            if c.kind == 's3_lut4':
                init = int(c.params['INIT'].split("'h")[-1], 16) if "'h" in c.params['INIT'] else int(c.params['INIT'])
                ins = [ev(k, "1'b1") for k in ('I1', 'I2', 'I3', 'I4')]
                v = 0
                for m in range(16):
                    if init >> m & 1:
                        t = full
                        for i in range(4):
                            t &= ins[i] if m >> i & 1 else full ^ ins[i]
                        v |= t
            elif c.kind in ('s3_mux2', 's3_muxcy'):
                s = ev('S')
                a1, a0 = (ev('I1'), ev('I0')) if c.kind == 's3_mux2' else (ev('CI'), ev('DI'))
                v = (s & a1) | ((full ^ s) & a0)
            else:
                v = ev('LI') ^ ev('CI')
        else:
            v = self.evaluate(G, G.d.wires[net], side, env, full, memo)
        memo[net] = v
        return v

    def funcs(self):
        """unmatched flip-flops told apart by the functions on their pins,
        each over the matched nets under it, however the logic is packed"""
        def sigs(G, side, mine):
            out = defaultdict(list)
            for n in G.cells:
                c = G.d.cells[n]
                if n in mine or c.kind != 's3_ff':
                    continue
                key, ok = [G.static(n), ('CLK', self.expr(G, c.ins.get('CLK', ''), side))], True
                for k in ('D', 'CE', 'SR', 'REV'):
                    e = c.ins.get(k, "1'b0" if k != 'CE' else "1'b1")
                    if k == 'SR' and e in G.ignore:
                        e = "1'b0"
                    lv = {}
                    if not self.leaves(G, e, side, lv, set()):
                        ok = False
                        break
                    order = sorted(lv)
                    nb = 1 << len(order)
                    full = (1 << nb) - 1
                    env = {}
                    for j, r in enumerate(order):
                        v = 0
                        for x in range(nb):
                            if x >> j & 1:
                                v |= 1 << x
                        env[r] = v
                    key.append((k, tuple(order), self.evaluate(G, e, side, env, full, {})))
                if ok and any(o for _, o, _ in key[2:]):
                    out[tuple(key)].append(n)
            return out
        sa, sb = sigs(self.A, 'A', self.ab), sigs(self.B, 'B', self.ba)
        added = 0
        for s, la in sa.items():
            lb = sb.get(s)
            if len(la) == 1 and lb and len(lb) == 1:
                self.pair(la[0], lb[0])
                added += 1
        return added

    def run(self, log=sys.stderr):
        r = 0
        while True:
            r += 1
            f = self.forward()
            b = self.backward() + self.backward_luts()
            o = 0 if f + b else self.fanout()
            g = 0 if f + b + o else self.regs()
            p = 0 if f + b + o + g else self.funcs()
            print(f"round {r}: +{f} forward, +{b} backward, +{o} fanout, +{g} registers, +{p} functions, "
                  f"{len(self.ab)} matched", file=log)
            if f + b + o + g + p == 0:
                break


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('a')
    ap.add_argument('b')
    ap.add_argument('--blocks', nargs='*', default=[])
    ap.add_argument('--ignore-sr', nargs='*', default=[], metavar='NET',
                    help="design B nets whose use as a flip-flop's SR is ignored when matching (a reset A lacks)")
    ap.add_argument('--seed', help='file of "A-bel B-bel" pairs to start from')
    ap.add_argument('--dump', help='write A-bel -> B-bel pairs and the unmatched bels here')
    args = ap.parse_args()
    A, B = Graph(args.a), Graph(args.b)
    B.ignore = set(args.ignore_sr)
    m = Matcher(A, B)
    if args.seed:
        for line in open(args.seed):
            if line.split() and not line.startswith('#'):
                a, b = line.split()
                m.pair(a, b)
    m.run()
    pairs = m.ab
    ma, mb = set(pairs), set(pairs.values())
    print(f"A: {len(A.cells)} live cells, {len(pairs)} matched")
    print(f"B: {len(B.cells)} live cells, {len(B.cells) - len(mb)} unmatched")
    kinds = lambda G, names: Counter(G.d.cells[n].kind for n in names)
    print('unmatched in A by kind:', dict(kinds(A, [n for n in A.cells if n not in ma])))
    print('unmatched in B by kind:', dict(kinds(B, [n for n in B.cells if n not in mb])))
    for path in args.blocks:
        name, desc, cells, names = carve.read_block(path, A.d)
        cells = [c for c in cells if c in A.d.live_cells]
        ff = [c for c in cells if A.d.cells[c].kind == 's3_ff']
        print(f"{name:20s} bels {sum(c in ma for c in cells):5d}/{len(cells):5d}   flip-flops {sum(c in ma for c in ff):4d}/{len(ff):4d}")
    if args.dump:
        with open(args.dump, 'w') as f:
            for a, b in pairs.items():
                f.write(f"{a} {b}\n")
            for n in A.cells:
                if n not in ma:
                    f.write(f"{n} -\n")
            for n in B.cells:
                if n not in mb:
                    f.write(f"- {n}\n")


if __name__ == '__main__':
    main()
