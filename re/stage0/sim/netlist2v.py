#!/usr/bin/env python3
"""Turn an `s3trace --netlist` dump into structural Verilog over s3prims.v.

    netlist2v.py NETLIST.jsonl PINS.txt BRAMDIR OUTDIR

PINS.txt is `s3pins` output (package pin -> pad); BRAMDIR the
`s3decode --blob-dir` output with BRAM DATA/DATAP blobs. Writes
OUTDIR/design.v (module fpga_top, one inout port per used package pin) and
OUTDIR/<tile>.mem files for $readmemb.

Dedicated slice connections that are not in the routing graph (carry chain,
F6/F7/F8 inputs, shift-in, ALTDIG, SLICEWE1) are wired from CLB geometry as
described in prjcombine's docs/src/spartan3/clb.md.
"""
import json, os, re, sys

net, pinfile, bramdir, out = sys.argv[1:5]
os.makedirs(out, exist_ok=True)
cells = {}
for line in open(net):
    c = json.loads(line)
    cells[(c['tile'], c['bel'])] = c

pads = {}
for line in open(pinfile):
    pin, pad = line.rstrip('\n').split('\t')
    m = re.match(r'(D0X\d+Y\d+)\.IOI\[(\d)\]\.PAD$', pad)
    if m:
        pads[(m.group(1) + '.BEL', 'IOI[%s]' % m.group(2))] = pin

def wname(src):
    t, b, p = src.split(':')
    t = t.replace('D0', '').replace('.BEL', '').replace('.CLK', 'c')
    b = b.replace('SLICE', 'S').replace('[', '').replace(']', '')
    p = p.replace('[', '_').replace(']', '')
    return f"n_{t}_{b}_{p}"

used_out = set()
for c in cells.values():
    for p, (s, inv) in c['in'].items():
        if s:
            used_out.add(s)

def inp(c, pin, default):
    s, inv = c['in'].get(pin, [None, 0])
    if not s:
        return default
    w = wname(s)
    return f"~{w}" if inv else w

def bitstr(v):
    return f"16'h{int(v, 2):04X}"

lines = ['`timescale 1ns/1ps', "module fpga_top #(parameter [56:0] DNA = 57'h0) ("]
ports = sorted(set(pads[k] for k in pads if k in cells), key=lambda p: int(p[1:]))
lines.append('    ' + ', '.join(f'inout {p}' for p in ports))
lines.append(');')
decl, body = [], []

def out_wire(tile, bel, pin):
    w = wname(f"{tile}:{bel}:{pin}")
    decl.append(f"wire {w};")
    return w

# slices: all of them, so cascades are complete
clb = {}
for (t, b), c in cells.items():
    if b.startswith('SLICE'):
        m = re.match(r'D0X(\d+)Y(\d+)\.BEL', t)
        clb[(int(m.group(1)), int(m.group(2)))] = t

def sw(x, y, s, pin):
    """dedicated-net wire of slice s at CLB (x,y), or 1'b0 if there is no such CLB"""
    t = clb.get((x, y))
    if not t:
        return "1'b0"
    return f"d_X{x}Y{y}_S{s}_{pin}"

for (x, y), t in sorted(clb.items()):
    for s in range(4):
        for p in ('COUT', 'F5', 'FX', 'SHIFTOUT', 'DIG'):
            decl.append(f"wire d_X{x}Y{y}_S{s}_{p};")

for (x, y), t in sorted(clb.items()):
    s0 = cells[(t, 'SLICE[0]')]
    by0 = inp(s0, 'BY', "1'b1")
    for s in range(4):
        b = f'SLICE[{s}]'
        c = cells[(t, b)]
        a = c['attrs']
        P = {}
        P['F'] = bitstr(a.get('F', '1' * 16))
        P['G'] = bitstr(a.get('G', '1' * 16))
        sm = s in (0, 2)
        P['SLICEM'] = int(sm)
        if sm:
            # LUT modes (prjcombine: RAM_ENABLE turns the LUT into RAM, SHIFT_ENABLE
            # then picks shift register over dual-port RAM; SHIFT_ENABLE means
            # nothing while RAM_ENABLE is 0)
            for L in 'FG':
                r, sh = a.get(L + '_RAM_ENABLE'), a.get(L + '_SHIFT_ENABLE')
                if r == '1':
                    P[L + ('_SRL' if sh == '1' else '_RAM')] = 1
            P['DIF_ALT'] = int(a.get('DIF_MUX', 'ALT') == 'ALT')
            P['DIG_ALT'] = int(a.get('DIG_MUX', 'ALT') == 'ALT')
            P['WE0USED'] = int(a.get('SLICEWE0USED') == '1')
            P['WE1USED'] = int(s0['attrs'].get('SLICEWE1USED') == '1')
        for k in ('FXMUX', 'GYMUX', 'DXMUX', 'DYMUX', 'XBMUX', 'YBMUX', 'CYINIT', 'CY0F', 'CY0G'):
            if k in a:
                P[k] = f'"{a[k]}"'
        # In a SLICEM, DIF_MUX=BX / DIG_MUX=BY on a LUT-mode LUT goes with its
        # flip-flop taking BX / BY directly, whatever DXMUX / DYMUX decode as:
        # in FW4 these are exactly the 51 flip-flops otherwise fed by a constant
        # LUT (the wishbone-to-SD synchronizers)
        if sm:
            if a.get('DIF_MUX') == 'BX' and 'F_RAM' not in P and 'F_SRL' not in P:
                P['DXMUX'] = '"BX"'
            if a.get('DIG_MUX') == 'BY' and 'G_RAM' not in P and 'G_SRL' not in P:
                P['DYMUX'] = '"BY"'
        P['CYSELF'] = int(a.get('CYSELF', 'CONST_1') == 'CONST_1')
        P['CYSELG'] = int(a.get('CYSELG', 'CONST_1') == 'CONST_1')
        for k in ('FFX_INIT', 'FFY_INIT', 'FFX_SRVAL', 'FFY_SRVAL', 'FF_LATCH', 'FF_SR_SYNC', 'FF_REV_ENABLE'):
            if k in a:
                P[k] = int(a[k])
        # only SLICEMs have the bit (SR doubles as LUT RAM write enable there);
        # in a SLICEL, SR always acts on the flip-flops
        P['FF_SR_ENABLE'] = int(a.get('FF_SR_ENABLE', '1'))
        cin = {0: sw(x, y - 1, 2, 'COUT'), 1: sw(x, y - 1, 3, 'COUT'),
               2: sw(x, y, 0, 'COUT'), 3: sw(x, y, 1, 'COUT')}[s]
        fxa, fxb = {0: (sw(x, y, 0, 'F5'), sw(x, y, 2, 'F5')),
                    1: (sw(x, y, 1, 'F5'), sw(x, y, 3, 'F5')),
                    2: (sw(x, y, 0, 'FX'), sw(x, y, 1, 'FX')),
                    3: (sw(x, y, 2, 'FX'), sw(x, y + 1, 2, 'FX'))}[s]
        shin = sw(x, y, 2, 'SHIFTOUT') if s == 0 else "1'b0"
        altdig = sw(x, y, 2, 'DIG') if s == 0 else "1'b0"
        we1 = by0 if s == 0 else (f"~({by0})" if s == 2 else "1'b0")
        conns = {}
        for pin in ('F1', 'F2', 'F3', 'F4', 'G1', 'G2', 'G3', 'G4'):
            conns[pin] = inp(c, pin, "1'b1")
        conns['BX_i'] = inp(c, 'BX', "1'b1")
        conns['BY_i'] = inp(c, 'BY', "1'b1")
        conns['CE'] = inp(c, 'CE', "1'b1")
        conns['SR'] = inp(c, 'SR', "1'b0")
        conns['CLK'] = inp(c, 'CLK', "1'b0")
        conns.update(CIN=cin, FXINA=fxa, FXINB=fxb, SHIFTIN=shin, ALTDIG=altdig, WE1=we1)
        for pin in ('X', 'Y', 'XQ', 'YQ', 'XB', 'YB'):
            src = f"{t}:{b}:{pin}"
            conns[pin] = out_wire(t, b, pin) if src in used_out else ''
        for p in ('COUT', 'F5', 'FX', 'SHIFTOUT', 'DIG'):
            conns[p] = f"d_X{x}Y{y}_S{s}_{p}"
        params = ', '.join(f'.{k}({v})' for k, v in P.items())
        cs = ', '.join(f'.{k}({v})' for k, v in conns.items())
        body.append(f"s3_slice #({params}) i_X{x}Y{y}_S{s} ({cs});")

# BRAMs
widths = {'_1': (1, 0), '_2': (2, 0), '_4': (4, 0), '_9': (8, 1), '_18': (16, 2), '_36': (32, 4)}
for (t, b), c in sorted(cells.items()):
    if b != 'BRAM':
        continue
    a = c['attrs']
    tt = t.replace('.BEL', '')
    wa, pa = widths.get(a.get('DATA_WIDTH_A', '_1'), (1, 0))
    wb, pb = widths.get(a.get('DATA_WIDTH_B', '_1'), (1, 0))
    files = {}
    for kind, n in (('DATA', 16384), ('DATAP', 2048)):
        blob = os.path.join(bramdir, f"{t}.BRAM.{kind}.bin")
        if os.path.exists(blob):
            d = open(blob, 'rb').read()
            fn = os.path.join(out, f"{tt}.{kind}.mem")
            with open(fn, 'w') as f:
                for i in range(n):
                    f.write('%d\n' % ((d[i // 8] >> (i % 8)) & 1))
            files[kind] = os.path.basename(fn)
    def v36(k):
        return f"36'b{a[k]}" if k in a else "36'b0"
    P = dict(WA=wa, WB=wb, PA=pa, PB=pb,
             MODEA=f'"{a.get("WRITE_MODE_A", "WRITE_FIRST")}"', MODEB=f'"{a.get("WRITE_MODE_B", "WRITE_FIRST")}"',
             INITA=v36('INIT_A'), INITB=v36('INIT_B'), SRVALA=v36('SRVAL_A'), SRVALB=v36('SRVAL_B'),
             ENA_ATTR=int(a.get('ENABLE_A', '1')), ENB_ATTR=int(a.get('ENABLE_B', '1')),
             DATAFILE=f'"{files.get("DATA", "")}"', PARFILE=f'"{files.get("DATAP", "")}"')
    conns = {}
    for port in 'AB':
        conns[f'CLK{port}'] = inp(c, f'CLK{port}', "1'b0")
        conns[f'EN{port}'] = inp(c, f'EN{port}', "1'b1")
        conns[f'RST{port}'] = inp(c, f'RST{port}', "1'b0")
        conns[f'WE{port}'] = '{' + ', '.join(inp(c, f'WE{port}[{i}]', "1'b0") for i in (3, 2, 1, 0)) + '}'
        conns[f'ADDR{port}'] = '{' + ', '.join(inp(c, f'ADDR{port}[{i}]', "1'b0") for i in range(13, -1, -1)) + '}'
        conns[f'DI{port}'] = '{' + ', '.join(inp(c, f'DI{port}[{i}]', "1'b0") for i in range(31, -1, -1)) + '}'
        conns[f'DIP{port}'] = '{' + ', '.join(inp(c, f'DIP{port}[{i}]', "1'b0") for i in (3, 2, 1, 0)) + '}'
        for o, n in ((f'DO{port}', 32), (f'DOP{port}', 4)):
            v = f"bo_{tt}_{o}"
            decl.append(f"wire [{n - 1}:0] {v};")
            conns[o] = v
            for i in range(n):
                src = f"{t}:{b}:{o}[{i}]"
                if src in used_out:
                    decl.append(f"wire {wname(src)} = {v}[{i}];")
    params = ', '.join(f'.{k}({v})' for k, v in P.items())
    body.append(f"s3_bram #({params}) i_{tt}_bram (" + ', '.join(f'.{k}({v})' for k, v in conns.items()) + ");")

# IO tiles with a package pin
for (t, b), c in sorted(cells.items()):
    if not b.startswith('IOI'):
        continue
    pin = pads.get((t, b))
    a = c['attrs']
    P = dict(MUX_O=f'"{a.get("MUX_O", "NONE")}"', MUX_T=f'"{a.get("MUX_T", "NONE")}"', MUX_FFI=f'"{a.get("MUX_FFI", "NONE")}"')
    conns = {'PAD': pin or ''}
    for p in ('O1', 'O2', 'T1', 'T2', 'OTCLK1', 'OTCLK2', 'ICLK1', 'SR', 'REV'):
        conns[p] = inp(c, p, "1'b0")
    # An output latch's gate reads inverted against the decoded bit. P51's
    # latch is the only one: its gate is OTCLK1 from the $7FD2 bit, and it
    # has to be transparent while that bit is 0 or every game-mode ROM read
    # lands 16KB off (docs/design.md, game-mode reads). The edge-triggered
    # output registers (SD CMD/DAT, the 595 latch clock) are left as decoded.
    for p, k in (('OTCLK1', 'FFO1_LATCH'), ('OTCLK2', 'FFO2_LATCH')):
        s_, inv = c['in'].get(p, [None, 0])
        if s_ and a.get(k) == '1':
            conns[p] = wname(s_) if inv else f"~{wname(s_)}"
    for p in ('OCE', 'TCE', 'ICE'):
        conns[p] = inp(c, p, "1'b1")
    for k in ('FFO_INIT', 'FFT_INIT', 'FFI1_INIT'):
        if k in a:
            P[k.replace('FFI1', 'FFI')] = int(a[k])
    # register options (latch, SR/REV, SRVAL, sync), same names as the model
    for k in ('FFO1_LATCH', 'FFO2_LATCH', 'FFT1_LATCH', 'FFT2_LATCH', 'FFI_LATCH',
              'FFO1_SRVAL', 'FFO2_SRVAL', 'FFT1_SRVAL', 'FFT2_SRVAL', 'FFI1_SRVAL',
              'FFO_SR_SYNC', 'FFT_SR_SYNC', 'FFI_SR_SYNC'):
        if k in a:
            P[k] = int(a[k])
    for f in ('FFO', 'FFT', 'FFI'):
        for e in ('SR', 'REV'):
            if f'{f}_{e}_ENABLE' in a:
                P[f'{f}_{e}_EN'] = int(a[f'{f}_{e}_ENABLE'])
    for p in ('I', 'IQ1', 'CLKPAD'):
        src = f"{t}:{b}:{p}"
        conns[p] = out_wire(t, b, p) if src in used_out else ''
    if not pin and not any(conns[p] for p in ('I', 'IQ1', 'CLKPAD')):
        continue
    params = ', '.join(f'.{k}({v})' for k, v in P.items())
    name = wname(f"{t}:{b}:x")[2:-2]
    body.append(f"s3_ioi #({params}) i_{name} (" + ', '.join(f'.{k}({v})' for k, v in conns.items()) + ");")

# clock buffers and DCMs
for (t, b), c in sorted(cells.items()):
    if 'BUFGMUX' in b:
        src = f"{t}:{b}:O"
        o = out_wire(t, b, 'O') if src in used_out else ''
        name = wname(f"{t}:{b}:x")[2:-2]
        body.append(f"s3_bufgmux i_{name} (.I0({inp(c, 'I0', chr(49) + chr(39) + 'b0')}), .I1({inp(c, 'I1', chr(49) + chr(39) + 'b0')}), .S({inp(c, 'S', chr(49) + chr(39) + 'b0')}), .O({o}));")
    if b == 'DCM' and c['in']:
        name = t.replace('D0', '').replace('.BEL', '')
        conns = {p: inp(c, p, "1'b0") for p in ('CLKIN', 'CLKFB', 'RST', 'PSCLK', 'PSEN', 'PSINCDEC')}
        for p in ('CLK0', 'CLK2X', 'CLKFX', 'LOCKED'):
            src = f"{t}:{b}:{p}"
            conns[p] = out_wire(t, b, p) if src in used_out else ''
        st = f"dcm_status_{name}"
        decl.append(f"wire [7:0] {st};")
        conns['STATUS'] = st
        for i in range(8):
            src = f"{t}:{b}:STATUS[{i}]"
            if src in used_out:
                decl.append(f"wire {wname(src)} = {st}[{i}];")
        mul = int(c['attrs'].get('S3E_CLKFX_MULTIPLY', '00000001'), 2) + 1
        body.append(f"s3_dcm #(.FX_MUL({mul})) i_{name}_dcm (" + ', '.join(f'.{k}({v})' for k, v in conns.items()) + ");")

# Device DNA (value from the testbench: defparam or -P fpga_top...)
for (t, b), c in sorted(cells.items()):
    if b == 'DNA_PORT':
        src = f"{t}:{b}:DOUT"
        o = out_wire(t, b, 'DOUT') if src in used_out else ''
        conns = {p: inp(c, p, "1'b0") for p in ('CLK', 'DIN', 'READ', 'SHIFT')}
        conns['DOUT'] = o
        body.append("s3_dna #(.DNA(DNA)) i_dna (" + ', '.join(f'.{k}({v})' for k, v in conns.items()) + ");")

# anything else that drives a used pin (ICAP): tie to 0
for s in sorted(used_out):
    w = wname(s)
    if not any(d.startswith(f"wire {w};") or d.startswith(f"wire {w} =") for d in decl):
        decl.append(f"wire {w} = 1'b0; // {s} not modeled")

lines += sorted(set(decl), key=decl.index)
lines += body
lines.append('endmodule')
open(os.path.join(out, 'design.v'), 'w').write('\n'.join(lines) + '\n')
print(f"{len(body)} instances, {len(ports)} ports")
