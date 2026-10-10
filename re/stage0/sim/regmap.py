#!/usr/bin/env python3
"""regmap.py DESIGN.v: every flip-flop clocked from the Game Boy /WR buffers
(X13Y33 BUFGMUX0/1), with the address(es) whose write enables it and the
data pin it captures. The enable cone is evaluated over the address pins it
uses; any other flip-flops in it are enumerated and reported as conditions."""
import re, sys, itertools
src = open(sys.argv[1]).read()
inst, driver, pins = {}, {}, {}
for m in re.finditer(r'(s3_\w+)\s*(#\((.*?)\))?\s*(i_\w+)\s*\((.*?)\);', src, re.S):
    kind, params, name, body = m.group(1), m.group(3) or '', m.group(4), m.group(5)
    c = {pm.group(1): pm.group(2).strip() for pm in re.finditer(r'\.(\w+)\(([^()]*(?:\([^()]*\))?[^()]*)\)', body)}
    P = {pm.group(1): pm.group(2) for pm in re.finditer(r'\.(\w+)\(([^()]*)\)', params)}
    inst[name] = (kind, P, c)
    for p, n in c.items():
        if p in ('X', 'Y', 'XQ', 'YQ', 'I', 'IQ1', 'O') and n: driver[n] = (name, p)
    if kind == 's3_ioi': pins[c['I']] = c['PAD']
    if kind == 's3_slice':
        for p in ('X', 'Y'): driver.setdefault('n_' + name[2:] + '_' + p, (name, p))
GB = {'P88': 0, 'P89': 1, 'P90': 2, 'P93': 3, 'P94': 4, 'P97': 5, 'P98': 6, 'P99': 7, 'P82': 8, 'P68': 9,
      'P39': 10, 'P21': 11, 'P4': 12, 'P5': 13, 'P6': 14, 'P7': 15}
DATA = {'P3': 0, 'P9': 1, 'P10': 2, 'P12': 3, 'P13': 4, 'P15': 5, 'P16': 6, 'P19': 7}

def leaves(n, acc):
    neg = n.startswith('~')
    n = n.lstrip('~').strip('()')
    if n in ("1'b0", "1'b1"): return
    d = driver.get(n)
    if not d or inst[d[0]][0] != 's3_slice' or d[1] in ('XQ', 'YQ'):
        acc.add(n); return
    kind, P, c = inst[d[0]]
    a = 'F' if d[1] == 'X' else 'G'
    mux = P.get('FXMUX' if a == 'F' else 'GYMUX', '"F"').strip('"')
    if mux not in ('F', 'G', 'F5'): acc.add(n); return
    ins = [c[a + str(i)] for i in range(1, 5)]
    if mux == 'F5': ins += [c['G' + str(i)] for i in range(1, 5)] + [c['BX_i']]
    for x in ins: leaves(x, acc)

def ev(n, env):
    neg = n.startswith('~')
    n2 = n.lstrip('~').strip('()')
    if n2 == "1'b0": v = 0
    elif n2 == "1'b1": v = 1
    elif n2 in env: v = env[n2]
    else:
        kind, P, c = inst[driver[n2][0]]
        a = 'F' if driver[n2][1] == 'X' else 'G'
        mux = P.get('FXMUX' if a == 'F' else 'GYMUX', '"F"').strip('"')
        def lut(L):
            t = int(P[L][4:], 16)
            i = sum(ev(c[L + str(k)], env) << (k - 1) for k in range(1, 5))
            return t >> i & 1
        v = (lut('F') if ev(c['BX_i'], env) else lut('G')) if mux == 'F5' else lut(a)
    return v ^ neg

def name(n):
    n = n.lstrip('~').strip('()')
    return pins.get(n, n.replace('n_', ''))

rows = []
for iname, (kind, P, c) in inst.items():
    if kind != 's3_slice' or c.get('CLK') not in ('n_X13Y33c_BUFGMUX0_O', 'n_X13Y33c_BUFGMUX1_O'): continue
    for a in 'XY':
        q = c.get(a + 'Q')
        if not q: continue
        dm = P.get('D' + a + 'MUX', '"B' + a + '"').strip('"')
        d = c['B' + a + '_i'] if dm.startswith('B') else 'n_' + iname[2:] + '_' + a
        dl = set(); leaves(d, dl)
        dname = ' '.join(sorted(name(x) for x in dl)) if dm != 'B' + a or name(d) not in DATA else name(d)
        ce = c['CE']; L = set(); leaves(ce, L)
        addr = sorted([x for x in L if pins.get(x) in GB], key=lambda x: GB[pins[x]])
        other = sorted(x for x in L if pins.get(x) not in GB)
        if len(other) > 10: rows.append((q, dname, 'CE too wide: ' + str(len(other)))); continue
        pats = {}
        for ov in itertools.product((0, 1), repeat=len(other)):
            env = dict(zip(other, ov))
            hit = []
            for av in itertools.product((0, 1), repeat=len(addr)):
                env.update(zip(addr, av))
                if ce in ("1'b1",) or ev(ce, env): hit.append(av)
            if hit:
                pats.setdefault(tuple(hit), []).append(ov)
        desc = []
        for hit, ovs in pats.items():
            # address pattern: bits fixed across all hits, others x
            s = ['x'] * 16
            for k, x in enumerate(addr):
                vs = {h[k] for h in hit}
                s[GB[pins[x]]] = str(vs.pop()) if len(vs) == 1 else '*'
            bits = ''.join(reversed(s))
            cond = ' | '.join('&'.join(('' if v else '!') + name(o) for o, v in zip(other, ov)) for ov in ovs) if other else ''
            desc.append(f'{bits} ({len(hit)}) when {cond}' if cond else f'{bits} ({len(hit)})')
        rows.append((q, dname, '; '.join(desc) if desc else 'never'))
for q, d, desc in sorted(rows, key=lambda r: r[2]):
    print(f'{q.replace("n_", ""):14} D={d:24} {desc[:400]}')
