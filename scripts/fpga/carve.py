#!/usr/bin/env python3
"""Carve a block out of the exported design (netlist2v.py's design.v) as a
Verilog module of its own, so a readable rewrite can be checked against it.

    carve.py DESIGN.v BLOCK.blk [-o OUT.v] [--stub] [--slices]
    carve.py DESIGN.v --coverage BLOCK.blk...

Every configured slice is decomposed into its bels: the F and G LUTs (or
LUT RAM / shift register), the X and Y flip-flops, the F5 and FX muxes and
the carry chain's MUXCY/XORCY cells, over stage0/lib/s3bels.v. The slice's
fixed selections (FXMUX, DXMUX, CYINIT, BXINV ...) become wiring. Bels
whose output reaches nothing (an unused carry chain, an unconnected
flip-flop) are dropped.

A block file names bels and gives boundary nets and registers readable names:

    # one-line description
    [cells]
    X18Y31_S0.FFX       # one bel: F G FFX FFY F5 FX CYF CYG XORF XORG
    X18Y31_S3           # a whole slice: all its live bels
    X3Y29_bram          # other cells by the design's instance name
    *                   # every live slice bel
    [names]
    n_X18Y31_S0_XQ  unlocked      # a net of the design -> its name in the block
    n_X2Y25_S1_XQ   pc[0]         # pc[i] names make a vector port / wire
    X7Y26_S0_F.m    regs0.sy      # a LUT RAM's contents -> the readable
                                  # module's s3_ram16 instance path
    P84             wr_n

stage0/blocks/common.names holds [names] shared by every block (pins,
clocks, mode bits); a block's own names win.

The module `<block>_ref` keeps the block's bels as they are in the design,
renamed; nets crossing the boundary become ports (direction from where they
are driven). Unnamed boundary nets are reported, and so are the block's
flip-flops, because the equivalence check (equiv.sh) matches registers by
name. --stub prints a skeleton of the readable module with the same ports.
--slices keeps whole s3_slice instances instead of bels (the exporter's
own form; the block must then hold whole slices), which is how the bel
decomposition itself is checked. --coverage lists the live bels no block
claims yet.
"""
import re, sys, os, argparse
from collections import OrderedDict

OUTPINS = {
    's3_slice': ('X', 'Y', 'XQ', 'YQ', 'XB', 'YB', 'COUT', 'F5', 'FX', 'SHIFTOUT', 'DIG'),
    's3_bram': ('DOA', 'DOB', 'DOPA', 'DOPB'),
    's3_ioi': ('I', 'IQ1', 'CLKPAD'),
    's3_bufgmux': ('O',),
    's3_dcm': ('CLK0', 'CLK2X', 'CLKFX', 'LOCKED', 'STATUS'),
    's3_dna': ('DOUT',),
}
INOUT = {'s3_ioi': ('PAD',)}
NET = re.compile(r'\b(n_\w+|d_\w+|b_\w+|bo_\w+|dcm_status_\w+|P\d+)\b')
INST = re.compile(r'^(s3_\w+)\s*(?:#\((.*)\))?\s*(i_\w+)\s*\((.*)\);\s*$')
CONN = re.compile(r'\.(\w+)\(((?:[^()]|\([^()]*\))*)\)')
PARAM = re.compile(r'\.(\w+)\(([^()]*)\)')
BELS = ('F', 'G', 'FFX', 'FFY', 'F5', 'FX', 'CYF', 'CYG', 'XORF', 'XORG')


def nets_of(expr):
    return NET.findall(expr)


def is_const(expr):
    return expr in ("1'b0", "1'b1")


def inv(expr):
    """negate a connection expression"""
    if expr == "1'b0":
        return "1'b1"
    if expr == "1'b1":
        return "1'b0"
    if re.fullmatch(r'~\w+', expr):
        return expr[1:]
    if re.fullmatch(r'~\(.*\)', expr):
        return expr[2:-1]
    return f"~({expr})" if not re.fullmatch(r'\w+', expr) else '~' + expr


class Cell:
    """a bel (or a whole non-slice cell): one output net, input expressions"""
    def __init__(self, name, kind, params, ins, outs, slice_=None):
        self.name, self.kind, self.params, self.ins, self.outs, self.slice = name, kind, params, ins, outs, slice_

    def reads(self):
        s = set()
        for e in self.ins.values():
            s.update(nets_of(e))
        return s


class Design:
    def __init__(self, path):
        self.inst = OrderedDict()   # instance name -> (kind, line, params, conns)
        self.assign = OrderedDict() # net -> (expr, line)
        self.decl = OrderedDict()
        self.ports = []
        for raw in open(path):
            s = raw.strip()
            m = INST.match(s)
            if m:
                kind, params, name, body = m.groups()
                conns = {c.group(1): c.group(2).strip() for c in CONN.finditer(body)}
                P = {p.group(1): p.group(2).strip() for p in PARAM.finditer(params or '')}
                self.inst[name] = (kind, s, P, conns)
                continue
            m = re.match(r'wire\s+(?:\[\d+:\d+\]\s+)?(\w+)\s*=\s*(.*?);', s)
            if m:
                self.assign[m.group(1)] = (m.group(2).strip(), s)
                continue
            m = re.match(r'wire\s+(?:\[\d+:\d+\]\s+)?(\w+);', s)
            if m:
                self.decl[m.group(1)] = s
                continue
            if s.startswith('inout '):
                self.ports = [p.strip() for p in s.replace('inout ', '').split(',')]
        self.cells = OrderedDict()   # bel/cell name -> Cell
        self.wires = OrderedDict()   # net -> expression (the slices' fixed wiring)
        for name, (kind, line, P, conns) in self.inst.items():
            if kind == 's3_slice':
                self.decompose(name, P, conns)
            else:
                ins = {p: e for p, e in conns.items() if p not in OUTPINS.get(kind, ()) and p not in INOUT.get(kind, ())}
                outs = [n for p in OUTPINS.get(kind, ()) + INOUT.get(kind, ()) for n in nets_of(conns.get(p, ''))]
                self.cells[name] = Cell(name, kind, P, ins, outs)
        for net, (expr, _) in self.assign.items():
            self.wires[net] = expr
        self.producer = {}
        for c in self.cells.values():
            for o in c.outs:
                self.producer[o] = c.name
        self.liveness()

    def decompose(self, name, P, c):
        """one slice into bels + wiring, as s3prims.v's s3_slice computes them"""
        sl = name[2:]  # X18Y31_S0
        b = lambda s: f"b_{sl}_{s}"
        g = lambda k, d: c.get(k, d) or d
        s = lambda k, d: P.get(k, f'"{d}"').strip('"')
        i = lambda k, d: int(P.get(k, str(d)))
        F1, F2, F3, F4 = (g(f'F{k}', "1'b1") for k in (1, 2, 3, 4))
        G1, G2, G3, G4 = (g(f'G{k}', "1'b1") for k in (1, 2, 3, 4))
        BX = inv(g('BX_i', "1'b1")) if i('BXINV', 0) else g('BX_i', "1'b1")
        BY = inv(g('BY_i', "1'b1")) if i('BYINV', 0) else g('BY_i', "1'b1")
        CE, SR, CLK = g('CE', "1'b1"), g('SR', "1'b0"), g('CLK', "1'b0")
        CIN, FXINA, FXINB = g('CIN', "1'b0"), g('FXINA', "1'b0"), g('FXINB', "1'b0")
        SHIFTIN, ALTDIG, WE1 = g('SHIFTIN', "1'b0"), g('ALTDIG', "1'b0"), g('WE1', "1'b0")
        f_ram, g_ram, f_srl, g_srl = i('F_RAM', 0), i('G_RAM', 0), i('F_SRL', 0), i('G_SRL', 0)
        dig = (SHIFTIN if g_srl else ALTDIG) if i('DIG_ALT', 1) else BY
        gmc15 = b('GMC15')
        dif = ((gmc15 if g_srl else dig) if f_srl else dig) if i('DIF_ALT', 1) else BX
        we = f"({SR} & {WE1})" if i('WE1USED', 0) else SR
        fwe = f"({we} & {BX})" if i('WE0USED', 0) else we
        gwe = f"({we} & {inv(BX)})" if i('WE0USED', 0) else we
        cells = []
        fo, go = b('F'), b('G')
        fa = f"{{{F4}, {F3}, {F2}, {F1}}}"
        ga = f"{{{G4}, {G3}, {G2}, {G1}}}"
        if f_srl:
            cells.append(Cell(f"{sl}.F", 's3_srl16', {'INIT': P['F']}, {'A': fa, 'CE': we, 'CLK': CLK, 'D': dif}, [fo, b('FMC15')], sl))
        elif f_ram:
            cells.append(Cell(f"{sl}.F", 's3_ram16', {'INIT': P['F']}, {'RA': fa, 'WA': ga, 'WE': fwe, 'CLK': CLK, 'D': dif}, [fo, b('FMC15')], sl))
        else:
            cells.append(Cell(f"{sl}.F", 's3_lut4', {'INIT': P['F']}, {'I1': F1, 'I2': F2, 'I3': F3, 'I4': F4}, [fo], sl))
        if g_srl:
            cells.append(Cell(f"{sl}.G", 's3_srl16', {'INIT': P['G']}, {'A': ga, 'CE': we, 'CLK': CLK, 'D': dig}, [go, gmc15], sl))
        elif g_ram:
            cells.append(Cell(f"{sl}.G", 's3_ram16', {'INIT': P['G']}, {'RA': ga, 'WA': ga, 'WE': gwe, 'CLK': CLK, 'D': dig}, [go, gmc15], sl))
        else:
            cells.append(Cell(f"{sl}.G", 's3_lut4', {'INIT': P['G']}, {'I1': G1, 'I2': G2, 'I3': G3, 'I4': G4}, [go], sl))
        cells.append(Cell(f"{sl}.F5", 's3_mux2', {}, {'S': BX, 'I1': fo, 'I0': go}, [b('F5')], sl))
        cells.append(Cell(f"{sl}.FX", 's3_mux2', {}, {'S': BY, 'I1': FXINA, 'I0': FXINB}, [b('FX')], sl))
        cyin = CIN if s('CYINIT', 'BX') == 'CIN' else BX
        def cy0(k, one, two, d):
            v = s(k, d)
            return {'CONST_0': "1'b0", 'CONST_1': "1'b1", 'F1': one, 'F2': two, 'G1': one, 'G2': two,
                    'PROD': f"({one} & {two})"}.get(v, d)
        cy0f = cy0('CY0F', F1, F2, BX)
        cy0g = cy0('CY0G', G1, G2, BY)
        psf = "1'b1" if i('CYSELF', 1) else fo
        psg = "1'b1" if i('CYSELG', 1) else go
        fcy, gcy = b('CYF'), b('CYG')
        cells.append(Cell(f"{sl}.CYF", 's3_muxcy', {}, {'S': psf, 'CI': cyin, 'DI': cy0f}, [fcy], sl))
        cells.append(Cell(f"{sl}.CYG", 's3_muxcy', {}, {'S': psg, 'CI': fcy, 'DI': cy0g}, [gcy], sl))
        cells.append(Cell(f"{sl}.XORF", 's3_xorcy', {}, {'LI': fo, 'CI': cyin}, [b('XORF')], sl))
        cells.append(Cell(f"{sl}.XORG", 's3_xorcy', {}, {'LI': go, 'CI': fcy}, [b('XORG')], sl))
        fxmux, gymux = s('FXMUX', 'F'), s('GYMUX', 'G')
        X = b('F5') if fxmux == 'F5' else b('XORF') if fxmux == 'FXOR' else fo
        Y = b('FX') if gymux == 'FX' else b('XORG') if gymux == 'GXOR' else go
        dx = X if s('DXMUX', 'BX') == 'X' else BX
        dy = Y if s('DYMUX', 'BY') == 'Y' else BY
        srx = SR if i('FF_SR_ENABLE', 0) else "1'b0"
        rev = BY if i('FF_REV_ENABLE', 0) else "1'b0"
        ffp = {'LATCH': i('FF_LATCH', 0), 'SYNC': i('FF_SR_SYNC', 0)}
        xq, yq = c.get('XQ') or b('XQ'), c.get('YQ') or b('YQ')
        cells.append(Cell(f"{sl}.FFX", 's3_ff', dict(INIT=i('FFX_INIT', 0), SRVAL=i('FFX_SRVAL', 0), **ffp),
                          {'D': dx, 'CE': CE, 'CLK': CLK, 'SR': srx, 'REV': rev}, [xq], sl))
        cells.append(Cell(f"{sl}.FFY", 's3_ff', dict(INIT=i('FFY_INIT', 0), SRVAL=i('FFY_SRVAL', 0), **ffp),
                          {'D': dy, 'CE': CE, 'CLK': CLK, 'SR': srx, 'REV': rev}, [yq], sl))
        for cell in cells:
            self.cells[cell.name] = cell
        # the slice's outputs onto the design's nets
        outs = {'X': X, 'Y': Y,
                'XB': b('FMC15') if s('XBMUX', 'FCY') == 'FMC15' else fcy,
                'YB': gmc15 if s('YBMUX', 'GCY') == 'GMC15' else gcy,
                'COUT': gcy, 'F5': b('F5'), 'FX': b('FX'), 'SHIFTOUT': b('FMC15'), 'DIG': dig}
        for pin, expr in outs.items():
            net = c.get(pin)
            if net and net != expr:
                self.wires[net] = expr

    def liveness(self):
        """a bel is live if its output reaches a non-slice cell"""
        self.wire_users = {}
        for net, expr in self.wires.items():
            for n in nets_of(expr):
                self.wire_users.setdefault(n, set()).add(net)
        self.cell_readers = {}
        for cl in self.cells.values():
            for n in cl.reads():
                self.cell_readers.setdefault(n, set()).add(cl.name)
        live_nets, live_cells = set(), set()
        todo = []
        for cl in self.cells.values():
            if cl.slice is None:
                live_cells.add(cl.name)
                todo.extend(cl.reads())
        todo.extend(self.ports)
        while todo:
            n = todo.pop()
            if n in live_nets:
                continue
            live_nets.add(n)
            if n in self.wires:
                todo.extend(nets_of(self.wires[n]))
            p = self.producer.get(n)
            if p and p not in live_cells:
                live_cells.add(p)
                todo.extend(self.cells[p].reads())
        self.live_cells, self.live_nets = live_cells, live_nets

    def root_driver(self, net):
        if net in self.producer:
            return self.producer[net]
        if net in self.wires:
            src = nets_of(self.wires[net])
            return self.root_driver(src[0]) if src else 'const'
        if net in self.ports:
            return 'pad'
        return None


def read_names(path):
    names = OrderedDict()
    for raw in open(path):
        line = raw.split('#', 1)[0].strip()
        if not line or line.startswith('['):
            continue
        net, new = line.split()
        names[net] = new
    return names


def read_block(path, d):
    name = re.sub(r'\.blk$', '', os.path.basename(path))
    desc, cells, names, section = '', [], OrderedDict(), None
    for raw in open(path):
        line = raw.split('#', 1)[0].strip()
        comment = raw.split('#', 1)[1].strip() if '#' in raw else ''
        if not line:
            if comment and not desc and section is None:
                desc = comment
            continue
        if line.startswith('['):
            section = line.strip('[]')
            continue
        if section == 'cells':
            cells.extend(expand_cell(line, d, path))
        elif section == 'names':
            net, new = line.split()
            names[net] = new
        else:
            sys.exit(f"{path}: line outside a section: {line}")
    common = os.path.join(os.path.dirname(os.path.abspath(path)), 'common.names')
    allnames = read_names(common) if os.path.exists(common) else OrderedDict()
    allnames.update(names)
    return name, desc, cells, allnames


def expand_cell(spec, d, path):
    if spec == '*':
        return [n for n in d.live_cells if d.cells[n].slice is not None]
    if '.' in spec:
        if spec not in d.cells:
            sys.exit(f"{path}: no bel {spec} in the design")
        return [spec]
    if 'i_' + spec in d.cells or spec in d.cells:
        return [spec if spec in d.cells else 'i_' + spec]
    bels = [f"{spec}.{b}" for b in BELS if f"{spec}.{b}" in d.live_cells]
    if not bels:
        if any(c.startswith(spec + '.') for c in d.cells):
            print(f"{path}: {spec} has no live bels, skipped", file=sys.stderr)
            return []
        sys.exit(f"{path}: {spec} is not a slice or a cell of the design")
    return bels


def fmt_params(P):
    return ('#(' + ', '.join(f'.{k}({v})' for k, v in P.items()) + ') ') if P else ''


def carve(d, name, cells, names, whole_slices=False):
    cells = [c for c in cells if c in d.live_cells]
    cellset = set(cells)
    if whole_slices:
        slices = sorted({d.cells[c].slice for c in cells if d.cells[c].slice})
        for sl in slices:
            for bl in BELS:
                bn = f"{sl}.{bl}"
                if bn in d.live_cells and bn not in cellset:
                    sys.exit(f"{name}: --slices needs whole slices, {bn} is missing")
    inside_drive, inside_read = set(), set()
    for c in cells:
        cl = d.cells[c]
        inside_drive.update(cl.outs)
        inside_read.update(cl.reads())
    # fixed wiring owned by the block: slice-output assigns over its nets
    owned = OrderedDict()
    changed = True
    while changed:
        changed = False
        for net, expr in d.wires.items():
            if net in owned or net not in d.live_nets:
                continue
            src = nets_of(expr)
            if any(n in inside_drive for n in src):
                owned[net] = expr
                inside_drive.add(net)
                changed = True
            elif not src:
                continue
        # pass-throughs (DIG from SHIFTIN/ALTDIG/BY): go with the slice's bels
    for net, expr in d.wires.items():
        if net in owned or net not in d.live_nets:
            continue
        m = re.match(r'd_(X\d+Y\d+_S\d)_', net)
        if m and any(d.cells[c].slice == m.group(1) for c in cells) and not any(n in d.producer for n in nets_of(expr)):
            owned[net] = expr
            inside_drive.add(net)
            inside_read.update(nets_of(expr))
    for expr in owned.values():
        inside_read.update(nets_of(expr))
    inputs, outputs, inouts, internal, consts = [], [], [], [], {}
    for n in sorted((inside_drive | inside_read) & d.live_nets | (inside_drive & set(d.ports))):
        if is_const(n):
            continue
        readers = set(d.cell_readers.get(n, ())) | set(d.wire_users.get(n, ()))
        outside = {r for r in readers if not (r in cellset or r in owned)}
        outside = {r for r in outside if r in d.live_cells or r in d.live_nets}
        if n in d.ports and n in inside_drive:
            inouts.append(n)
        elif n in inside_drive:
            (outputs if outside else internal).append(n)
        else:
            if d.root_driver(n) == 'const':
                consts[n] = d.wires[n]
            inputs.append(n)
    regs = [(cl.outs[0], cl.name) for c in cells for cl in [d.cells[c]] if cl.kind == 's3_ff']
    regs += [(n, cl.name) for c in cells for cl in [d.cells[c]] if cl.kind == 's3_ioi' for n in cl.outs if n.endswith('_IQ1')]
    ren = {k: v for k, v in names.items() if k in inside_drive | inside_read}
    # LUT RAM contents: "<slice>_F.m name" renames the reg of that bel (a
    # yosys rename, since the name lives inside the primitive)
    ramnames = {k: v for k, v in names.items()
                if k.endswith('.m') and k[:-2].replace('_F', '.F').replace('_G', '.G') in cellset
                and d.cells[k[:-2].replace('_F', '.F').replace('_G', '.G')].kind == 's3_ram16'}
    sub = re.compile(r'\b(' + '|'.join(re.escape(k) for k in ren) + r')\b') if ren else None
    rn = (lambda s: sub.sub(lambda m: ren[m.group(1)], s)) if sub else (lambda s: s)
    unnamed = [n for n in inputs + outputs + inouts if n not in ren]
    # named ports first, in the block file's order, then the rest
    order = {k: i for i, k in enumerate(names)}
    for lst in (inputs, outputs, inouts):
        lst.sort(key=lambda n: (order.get(n, len(order)), n))
    # names like pc[3] make a vector; a vector with any bit read outside is an
    # output as a whole (its other bits go out too)
    vec = {}
    for n, v in ren.items():
        m = re.fullmatch(r'(\w+)\[(\d+)\]', v)
        if m:
            vec.setdefault(m.group(1), {})[int(m.group(2))] = n
    for base, bits in vec.items():
        kinds = {('input' if n in inputs else 'output' if n in outputs else 'inout' if n in inouts else 'internal') for n in bits.values()}
        if 'input' in kinds and kinds - {'input'}:
            sys.exit(f"{name}: vector {base} has bits driven on both sides of the block")
        if 'output' in kinds:
            for n in bits.values():
                if n in internal:
                    internal.remove(n); outputs.append(n)
    done = set()
    def decls(kind, nets):
        res = []
        for n in nets:
            m = re.fullmatch(r'(\w+)\[(\d+)\]', ren.get(n, ''))
            if m:
                if m.group(1) in done:
                    continue
                done.add(m.group(1))
                res.append(f"{kind} [{max(vec[m.group(1)])}:{min(vec[m.group(1)])}] {m.group(1)}")
            else:
                res.append(f"{kind} {rn(n)}")
        return res
    out = [f"// {name}_ref: carved from the exported design by scripts/fpga/carve.py; do not edit",
           f"module {name}_ref ("]
    pdecls = (decls('input', inputs), decls('output', outputs), decls('inout', inouts))
    plist = pdecls[0] + pdecls[1] + pdecls[2]
    out.append('    ' + ',\n    '.join(plist))
    out.append(');')
    for n, expr in consts.items():
        out.append(f"// {rn(n)}: driven by {expr} in the design (not modeled there)")
    for n in internal:
        if whole_slices and n.startswith('b_'):
            continue  # the bel decomposition's own nets: the slice drives its outputs itself
        if n in d.decl and re.search(r'\[\d+:\d+\]', d.decl[n]):
            out.append(rn(d.decl[n]))
        else:
            out.extend(f"{x};" for x in decls('wire', [n]))
    if not whole_slices:
        for net, expr in owned.items():
            if net in internal or net in outputs:
                out.append(rn(f"assign {net} = {expr};"))
    if whole_slices:
        for sl in sorted({d.cells[c].slice for c in cells if d.cells[c].slice}):
            out.append(rn(d.inst['i_' + sl][1]))
        for c in cells:
            if d.cells[c].slice is None:
                out.append(rn(d.inst[c][1]))
    else:
        for c in cells:
            cl = d.cells[c]
            if cl.slice is None:
                out.append(rn(d.inst[c][1]))
                continue
            conns = ', '.join(f'.{k}({v})' for k, v in cl.ins.items())
            outs = ', '.join(f'.{p}({v if v in d.live_nets else ""})' for p, v in zip(OUTS[cl.kind], cl.outs))
            out.append(rn(f"{cl.kind} {fmt_params(cl.params)}{c.replace('.', '_')} ({conns}, {outs});"))
    out.append('endmodule')
    rams = [c for c in cells if d.cells[c].kind in ('s3_ram16', 's3_srl16')]
    # the contents take the readable module's own name for them, <cell>.m,
    # on both sides (a flattened instance already owns the bare cell name)
    keep = ('select -set keep ' + ' '.join(f"w:\\{v}.m" for v in ramnames.values()) + '\n') if ramnames else ''
    info = dict(inputs=pdecls[0], outputs=pdecls[1], inouts=pdecls[2],
                regs=[(r, ren.get(r), bel) for r, bel in regs], unnamed=unnamed, internal=internal, consts=consts,
                cells=cells, rams=[(c.replace('.', '_') + '.m', ramnames.get(c.replace('.', '_') + '.m')) for c in rams],
                renames='\n'.join(f"rename \\{k} \\{v}.m" for k, v in ramnames.items()) + '\n' + keep,
                gate_renames=keep)
    return '\n'.join(out) + '\n', info


OUTS = {'s3_lut4': ('O',), 's3_ram16': ('O', 'MC15'), 's3_srl16': ('O', 'MC15'), 's3_ff': ('Q',),
        's3_mux2': ('O',), 's3_muxcy': ('O',), 's3_xorcy': ('O',)}


def stub(name, desc, info):
    out = [f"// {name}: {desc}" if desc else f"// {name}", f"module {name} ("]
    plist = info['inputs'] + info['outputs'] + info['inouts']
    out.append('    ' + ',\n    '.join(plist))
    out.append(');')
    for r, nm, bel in info['regs']:
        out.append(f"    reg {nm or r};  // {bel}")
    for r, nm in info['rams']:
        out.append(f"    // LUT RAM {r} -> {nm or '(unnamed)'}")
    out.append('endmodule')
    return '\n'.join(out) + '\n'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('design')
    ap.add_argument('blocks', nargs='+')
    ap.add_argument('-o', '--out')
    ap.add_argument('--stub', action='store_true')
    ap.add_argument('--slices', action='store_true')
    ap.add_argument('--coverage', action='store_true')
    ap.add_argument('--cone', action='store_true', help='list the bels driving the given nets, back to flip-flops, RAMs and ports')
    a = ap.parse_args()
    d = Design(a.design)
    if a.cone:
        seen, ffs, stops, todo = [], [], set(), []
        for n in a.blocks:  # nets, or bels (then from their inputs)
            todo.extend(d.cells[n].reads() if n in d.cells else [n])
        while todo:
            n = todo.pop()
            if n in d.wires:
                todo.extend(nets_of(d.wires[n]))
                continue
            p = d.producer.get(n)
            if not p:
                stops.add(n)
                continue
            cl = d.cells[p]
            if p in seen or p in ffs:
                continue
            if cl.kind in ('s3_ff', 's3_ram16', 's3_srl16') or cl.slice is None:
                ffs.append(p)
                continue
            seen.append(p)
            todo.extend(cl.reads())
        print(f"{len(seen)} combinational bels:")
        for p in sorted(seen):
            print(f"  {p}")
        print(f"{len(ffs)} state cells / other cells reached:")
        for p in sorted(ffs):
            print(f"  {p}")
        print(f"{len(stops)} other nets reached: {' '.join(sorted(stops))}")
        return
    if a.coverage:
        claimed = {}
        for b in a.blocks:
            name, _, cells, _ = read_block(b, d)
            for c in cells:
                if c in claimed and claimed[c] != name:
                    sys.exit(f"{c} is in both {claimed[c]} and {name}")
                claimed[c] = name
        live = [n for n in d.cells if n in d.live_cells]
        left = [n for n in live if n not in claimed]
        kinds = {}
        for n in left:
            kinds.setdefault(d.cells[n].kind, []).append(n)
        print(f"{len(claimed)} of {len(live)} live cells in {len(a.blocks)} blocks; {len(left)} unclaimed:")
        for k, ns in sorted(kinds.items()):
            print(f"  {k}: {len(ns)}")
        for n in left:
            print(n)
        return
    if len(a.blocks) != 1:
        sys.exit('one block file (or --coverage)')
    name, desc, cells, names = read_block(a.blocks[0], d)
    text, info = carve(d, name, cells, names, a.slices)
    if a.stub:
        sys.stdout.write(stub(name, desc, info))
        return
    if a.out:
        open(a.out, 'w').write(text)
        open(re.sub(r'\.v$', '', a.out) + '.ys', 'w').write(info['renames'])
        open(re.sub(r'\.v$', '', a.out) + '_gate.ys', 'w').write(info['gate_renames'])
    else:
        sys.stdout.write(text)
    err = sys.stderr
    print(f"{name}: {len(info['cells'])} cells, {len(info['inputs'])} inputs, {len(info['outputs'])} outputs, "
          f"{len(info['inouts'])} inouts, {len(info['internal'])} internal nets, {len(info['regs'])} registers", file=err)
    if info['unnamed']:
        print("unnamed boundary nets (add to [names]):", file=err)
        for n in info['unnamed']:
            if n in info['inputs']:
                print(f"  {n:28s} <- {d.root_driver(n)}", file=err)
            else:
                rd = sorted(set(d.cell_readers.get(n, ())) | set(d.wire_users.get(n, ())))
                print(f"  {n:28s} -> {' '.join(rd)}", file=err)
    un = [(r, bel) for r, nm, bel in info['regs'] if not nm]
    if un:
        print("unnamed registers (name them in [names] so equiv can match them):", file=err)
        for r, bel in un:
            print(f"  {r:28s} {bel}", file=err)
    unr = [r for r, nm in info['rams'] if not nm]
    if unr:
        print("unnamed LUT RAM contents (name them in [names], e.g. 'X3Y1_S0_F.m stack_lo'):", file=err)
        for r in unr:
            print(f"  {r}", file=err)


if __name__ == '__main__':
    main()
