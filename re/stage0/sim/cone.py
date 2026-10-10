#!/usr/bin/env python3
"""cone.py DESIGN.v NET [depth] [snap.txt TAG]: print the combinational cone
driving NET down to flip-flop outputs, pads and BRAM bits. Each LUT is shown
as a sum of products over its named inputs. With a snapshot (mksnap.py) the
value of every net at that tag is printed beside it."""
import re, sys, itertools
design, root = sys.argv[1], sys.argv[2]
depth = int(sys.argv[3]) if len(sys.argv) > 3 else 6
val = {}
if len(sys.argv) > 5:
    for line in open(sys.argv[4]):
        t, n, v = line.split()
        if t == sys.argv[5]: val[n] = v

src = open(design).read()
pins = {}
inst, driver = {}, {}
for m in re.finditer(r'(s3_\w+)\s*(#\((.*?)\))?\s*(i_\w+)\s*\((.*?)\);', src, re.S):
    kind, params, name, body = m.group(1), m.group(3) or '', m.group(4), m.group(5)
    conns = {pm.group(1): pm.group(2) for pm in re.finditer(r'\.(\w+)\(([^()]*(?:\([^()]*\))?[^()]*)\)', body)}
    P = {pm.group(1): pm.group(2) for pm in re.finditer(r'\.(\w+)\(([^()]*)\)', params)}
    inst[name] = (kind, P, conns)
    for p, n in conns.items():
        if p in ('X', 'Y', 'XQ', 'YQ', 'I', 'IQ1', 'O', 'COUT', 'F5', 'FX') and n:
            driver[n] = (name, p)
    if kind == 's3_ioi':
        pins[conns['I']] = conns['PAD']
    if kind == 's3_slice':
        # outputs left unconnected still feed the slice's own flip-flops
        for p in ('X', 'Y'):
            driver.setdefault('n_' + name[2:] + '_' + p, (name, p))

def sop(tt, names):
    """prime-implicant cover of a 4-input truth table (bit i = f(I4..I1=i))"""
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
        best = max(primes, key=lambda c: len(c[1] & left))
        cover.append(best[0]); left -= best[1]
    terms = []
    for c in cover:
        lits = [('' if c[k] else '!') + names[k] for k in range(4) if c[k] is not None]
        terms.append('&'.join(lits) or '1')
    return ' | '.join(terms)

def label(n):
    n = n.strip()
    if n.startswith('~('): return '!' + label(n[2:-1])
    if n.startswith('~'): return '!' + label(n[1:])
    s = n.replace('n_', '')
    if n in pins: s += '=' + pins[n]
    if n in val: s += '[' + val[n] + ']'
    return s

seen = set()
def walk(n, d, ind):
    n = n.strip().lstrip('~').strip('()')
    if n in ("1'b0", "1'b1") or d > depth or n in seen: return
    if n not in driver: return
    name, port = driver[n]
    kind, P, c = inst[name]
    if kind != 's3_slice' or port in ('XQ', 'YQ'): return
    seen.add(n)
    if port == 'X':
        L, ins, mux = P['F'], [c['F1'], c['F2'], c['F3'], c['F4']], P.get('FXMUX', '"F"')
        if mux == '"F5"':
            print(f'{ind}{label(n)} = {label(c["BX_i"])} ? ({sop(int(P["F"][4:], 16), [label(x) for x in ins])}) : ({sop(int(P["G"][4:], 16), [label(x) for x in [c["G1"],c["G2"],c["G3"],c["G4"]]])})')
            ins += [c['G1'], c['G2'], c['G3'], c['G4'], c['BX_i']]
        else:
            print(f'{ind}{label(n)} = {sop(int(L[4:], 16), [label(x) for x in ins])}' + ('' if mux == '"F"' else f'  (FXMUX {mux}, carry not expanded)'))
    elif port == 'Y':
        L, ins, mux = P['G'], [c['G1'], c['G2'], c['G3'], c['G4']], P.get('GYMUX', '"G"')
        print(f'{ind}{label(n)} = {sop(int(L[4:], 16), [label(x) for x in ins])}' + ('' if mux == '"G"' else f'  (GYMUX {mux}, not expanded)'))
    else:
        print(f'{ind}{label(n)} = {port} of {name}'); return
    for x in ins: walk(x, d + 1, ind + '  ')

def ff(n):
    name, port = driver[n]
    kind, P, c = inst[name]
    if kind == 's3_slice':
        a = 'X' if port == 'XQ' else 'Y'
        dsrc = (P.get('D' + a + 'MUX', '"B' + a + '"')).strip('"')
        d = c['B' + a + '_i'] if dsrc.startswith('B') else n.replace(port, a)
        print(f'{label(n)}: D={label(d)} CE={label(c["CE"])} SR={label(c["SR"])} CLK={label(c["CLK"])} '
              f'latch={P.get("FF_LATCH")} rev={P.get("FF_REV_ENABLE")} srval={P.get("FF"+a+"_SRVAL")}')
        for x in (d, c['CE'], c['SR']): walk(x, 0, '  ')
    else:
        walk(n, 0, '')

if root in driver and driver[root][1] in ('XQ', 'YQ'): ff(root)
else: walk(root, 0, '')
