#!/usr/bin/env python3
"""snapdiff.py snap.txt [VALUES]: nets whose value changes between snapshots,
one line per net with its value at each tag. Nets that follow a written
value bit for bit show up as a column pattern; VALUES (comma-separated hex,
one per tag) adds the matching bit when a net equals bit k of it."""
import collections, sys
v = collections.defaultdict(dict)
for line in open(sys.argv[1]):
    t, n, b = line.split()
    v[n][int(t)] = b
vals = [int(x, 16) for x in sys.argv[2].split(',')] if len(sys.argv) > 2 else None
for n, d in sorted(v.items()):
    seq = [d[t] for t in sorted(d)]
    if len(set(seq)) < 2: continue
    note = ''
    if vals and len(vals) == len(seq) and set(seq) <= {'0', '1'}:
        for k in range(8):
            if all(seq[i] == str(vals[i] >> k & 1) for i in range(len(seq))): note = f'= bit {k}'
            elif all(seq[i] != str(vals[i] >> k & 1) for i in range(len(seq))): note = f'= !bit {k}'
    print(f'{n:22} {"".join(seq)} {note}')
