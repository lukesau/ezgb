#!/usr/bin/env python3
"""Find nets in snap.txt that equal a bit of the bank written before each
snapshot (gb_bank.vh's list), straight or inverted."""
import collections, sys
banks = [0x01, 0x02, 0x03, 0x05, 0x0A, 0x15, 0x2C, 0x53]
v = collections.defaultdict(dict)
for line in open(sys.argv[1] if len(sys.argv) > 1 else 'snap.txt'):
    t, n, b = line.split()
    v[n][int(t)] = b
for n, d in sorted(v.items()):
    if len(d) != len(banks) or not set(d.values()) <= {'0', '1'}: continue
    for k in range(8):
        if all(d[i] == str((banks[i] >> k) & 1) for i in range(len(banks))): print(f'{n} = bank bit {k}')
        elif all(d[i] != str((banks[i] >> k) & 1) for i in range(len(banks))): print(f'{n} = NOT bank bit {k}')
