#!/usr/bin/env python3
"""whyx.py DESIGN.v VCD SIGNAL TIME_ps [depth]: walk back from an X.

SIGNAL is a top-level net (n_X2Y28_S3_XQ, d_X1Y25_S0_COUT, ...). At each
step: find the instance driving the net, list its input ports that are X
just before TIME (for a clocked output: at the last clock edge), and recurse
into the nets connected to those ports.
"""
import re, sys, bisect
design, vcd, sig, t0 = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
depth = int(sys.argv[5]) if len(sys.argv) > 5 else 8

# instance -> {port: expr}, net -> (instance, port)
inst, driver = {}, {}
for m in re.finditer(r'(s3_\w+)\s*(#\(.*?\))?\s*(i_\w+)\s*\((.*?)\);', open(design).read(), re.S):
    name, conns = m.group(3), {}
    for pm in re.finditer(r'\.(\w+)\(([^()]*(?:\([^()]*\))?[^()]*)\)', m.group(4)):
        conns[pm.group(1)] = pm.group(2)
    inst[name] = (m.group(1), conns)
    outs = {'s3_slice': ['X','Y','XQ','YQ','XB','YB','COUT','F5','FX','SHIFTOUT','DIG'],
            's3_bram': ['DOA','DOB','DOPA','DOPB'], 's3_ioi': ['I','IQ1','CLKPAD'],
            's3_bufgmux': ['O'], 's3_dcm': ['CLK0','CLK2X','CLKFX','LOCKED','STATUS']}.get(m.group(1), [])
    for p in outs:
        if conns.get(p):
            driver[conns[p]] = (name, p)
# BRAM bit nets: wire n_..._DOA_3 = bo_..._DOA[3];
for m in re.finditer(r'wire (n_\w+) = (bo_\w+)\[(\d+)\];', open(design).read()):
    driver[m.group(1)] = driver.get(m.group(2), (None, None))

# VCD: changes per signal path (scope.name)
ids, ch, t = {}, {}, 0
scope = []
for line in open(vcd):
    if line.startswith('$scope'): scope.append(line.split()[2])
    elif line.startswith('$upscope'): scope.pop()
    elif line.startswith('$var'):
        p = line.split(); ids.setdefault(p[3], []).append('.'.join(scope[2:] + [p[4]]))
    elif line.startswith('#'): t = int(line[1:])
    else:
        s = line.strip()
        if not s or s.startswith('$'): continue
        v, i = (s.split() if s[0] == 'b' else (s[0], s[1:]))
        for n in ids.get(i, []):
            ch.setdefault(n, ([], []))
            ch[n][0].append(t); ch[n][1].append(v)
def val(path, t):
    c = ch.get(path)
    if not c: return '?'
    k = bisect.bisect_right(c[0], t) - 1
    return c[1][k] if k >= 0 else '?'
def isx(v): return 'x' in v.lower() or 'z' in v.lower()
def nets(expr):
    return re.findall(r'\b([nd]_\w+|bo_\w+)', expr)

seen = set()
def walk(net, t, d):
    pad = '  ' * d
    if net in seen or d > depth:
        return
    seen.add(net)
    drv = driver.get(net)
    if not drv or not drv[0]:
        print(f"{pad}{net}: no driver found"); return
    name, port = drv
    kind, conns = inst[name]
    xs = []
    for p, e in conns.items():
        if p in ('X','Y','XQ','YQ','XB','YB','COUT','F5','FX','SHIFTOUT','DIG','DOA','DOB','DOPA','DOPB','I','IQ1','CLKPAD','O','CLK0','CLK2X','CLKFX','LOCKED','STATUS','PAD'):
            continue
        v = val(f"{name}.{p}", t - 1)
        if isx(v):
            xs.append((p, e, v))
    print(f"{pad}{net} <- {name}.{port} ({kind}) X inputs at {t - 1}: " + (', '.join(f"{p}={v}" for p, e, v in xs) or 'none'))
    for p, e, v in xs:
        for n in nets(e):
            if n != net:
                walk(n, t, d + 1)
walk(sig, t0, 0)
