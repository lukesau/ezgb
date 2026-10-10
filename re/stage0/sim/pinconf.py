#!/usr/bin/env python3
"""pinconf.py DESIGN.v: one line per package pin: output/tristate source
(O1, FFO1 ... or NONE), input use (I, IQ1), register options, and which
global buffer clocks its registers. Slice names are left out so the output
of two builds diffs by function."""
import re, sys
src = open(sys.argv[1]).read()
users = {}
for n in set(re.findall(r'\b(n_X\d+Y\d+_IOI\d_(?:I|IQ1))\b', src)):
    users[n] = len(re.findall(r'\b' + n + r'\b', src)) - 2
for m in re.finditer(r's3_ioi #\((.*?)\) (i_\w+) \((.*?)\);', src):
    P = dict(re.findall(r'\.(\w+)\(("?[^,()"]*"?)\)', m.group(1)))
    c = dict(re.findall(r'\.(\w+)\(([^()]*)\)', m.group(3)))
    pad = c.get('PAD')
    if not pad: continue
    def kind(x):
        x = x.strip()
        if x in ("1'b0", "1'b1", ''): return x or '-'
        inv = '~' if x.startswith('~') else ''
        if 'BUFGMUX' in x: return inv + re.sub(r'.*(X\d+Y\d+c_BUFGMUX\d).*', r'\1', x)
        if '_IOI' in x: return inv + 'pin'
        return inv + 'logic'
    mo, mt = P['MUX_O'].strip('"'), P['MUX_T'].strip('"')
    used_i = users.get(c.get('I', ''), 0) > 0
    used_iq = users.get(c.get('IQ1', ''), 0) > 0
    regs = []
    if mo.startswith('FF') or mt.startswith('FF'):
        regs.append('OTCLK1=' + kind(c['OTCLK1']))
        if '2' in mo + mt: regs.append('OTCLK2=' + kind(c['OTCLK2']))
        for k in ('FFO1_LATCH', 'FFO_SR_EN', 'FFO_REV_EN', 'FFT_SR_EN', 'FFO1_SRVAL', 'FFO_INIT'):
            if P.get(k) not in (None, '0') or k == 'FFO_INIT': regs.append(f'{k}={P.get(k)}')
    if used_iq: regs.append('ICLK1=' + kind(c['ICLK1']))
    print(f"{pad:4} O={mo:5} T={mt:5} o1={kind(c['O1']):8} t1={kind(c['T1']):8} in={'I' if used_i else '-'}{'Q' if used_iq else '-'} {' '.join(regs)}")
