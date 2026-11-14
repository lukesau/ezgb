#!/usr/bin/env python3
"""fanout.py DESIGN.v NET [NET...]: every cell input a net reaches, with the
cell's kind, port and (for slices) the outputs that port can affect."""
import re, sys
src = open(sys.argv[1]).read()
cells = []
for m in re.finditer(r'(s3_\w+)\s*(?:#\(.*?\))?\s*(i_\w+)\s*\((.*?)\);', src, re.S):
    c = {pm.group(1): pm.group(2) for pm in re.finditer(r'\.(\w+)\(([^()]*(?:\([^()]*\))?[^()]*)\)', m.group(3))}
    cells.append((m.group(1), m.group(2), c))
pins = {c['I']: c['PAD'] for k, n, c in cells if k == 's3_ioi' and c.get('I')}
for net in sys.argv[2:]:
    print(net)
    for kind, name, c in cells:
        for p, v in c.items():
            if re.search(r'\b' + net + r'\b', v) and p not in ('X', 'Y', 'XQ', 'YQ', 'I', 'IQ1', 'O'):
                outs = ''
                if kind == 's3_slice':
                    if p[0] == 'F' and p[1:].isdigit(): outs = 'X/XQ'
                    elif p[0] == 'G' and p[1:].isdigit(): outs = 'Y/YQ'
                    elif p == 'BX_i': outs = 'XQ (or F5)'
                    elif p == 'BY_i': outs = 'YQ'
                    else: outs = 'FFs'
                elif kind == 's3_ioi': outs = 'pad ' + c.get('PAD', '')
                print(f'  {name:14} {kind:10} .{p:6} {"~" if v.startswith("~") else ""} -> {outs}')
