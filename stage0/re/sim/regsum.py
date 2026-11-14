#!/usr/bin/env python3
"""regsum.py REGMAP.txt: regmap.py output grouped by enabling address, with
the data bits each address writes. Flip-flop names differ between builds,
so this is the form that diffs across firmwares."""
import re, sys, collections
DATA = {'P3': 0, 'P9': 1, 'P10': 2, 'P12': 3, 'P13': 4, 'P15': 5, 'P16': 6, 'P19': 7}
g = collections.defaultdict(list)
for line in open(sys.argv[1]):
    if line.startswith('#'): continue
    m = re.match(r'(\S+)\s+D=(.*?)\s+((?:[01x*]{16}|CE too wide|never).*)$', line.rstrip())
    if not m: continue
    d = m.group(2).split()
    bits = [DATA[x] for x in d if x in DATA]
    kind = f'D{bits[0]}' if len(d) == 1 and bits else ('logic(' + ','.join(f'D{b}' for b in sorted(set(bits))) + ')' if bits else 'logic')
    for part in m.group(3).split('; '):
        pat = part.split(' when ')[0].split(' (')[0]
        g[pat].append(kind)
def addr(p):
    if not re.fullmatch(r'[01x*]{16}', p): return p
    hexs = ''
    for i in range(0, 16, 4):
        nib = p[i:i + 4]
        hexs += '%X' % int(nib, 2) if set(nib) <= {'0', '1'} else ('x' if nib == 'xxxx' else '[' + nib + ']')
    return '$' + hexs
for p in sorted(g, key=lambda p: addr(p)):
    ks = sorted(g[p], key=lambda k: (len(k), k))
    c = collections.Counter(ks)
    print(f'{addr(p):22} ' + ' '.join(f'{k}' + (f'x{n}' if n > 1 else '') for k, n in sorted(c.items())))
