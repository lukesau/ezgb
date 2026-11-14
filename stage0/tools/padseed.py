#!/usr/bin/env python3
"""Seed pairs for belmatch.py from the pads two builds drive.

    padseed.py A/design.v B/design.v > seed.txt

The pins are the same in both builds, so the LUT that drives a pad's
output or tristate in one build is the one that drives it in the other,
however its logic changed (FW5 rewrote the pSRAM strobes and selects).
This pairs those LUTs, when a LUT drives the pin on both sides and each
LUT drives no pin the other does not.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import carve
from belmatch import simple


def lut(d, net):
    for _ in range(8):
        if net in d.producer:
            c = d.producer[net]
            return c if d.cells[c].kind == 's3_lut4' else None
        s = simple(d.wires.get(net, ''))
        if not s:
            return None
        net = s[0]
    return None


def drivers(d):
    out = {}
    for n, c in d.cells.items():
        if 'IOI' in n:
            for pin in ('O1', 'T1'):
                s = simple(c.ins.get(pin, ''))
                if s:
                    out[(n, pin)] = lut(d, s[0])
    return out


a, b = (drivers(carve.Design(p)) for p in sys.argv[1:3])
pairs = {}
for key, la in a.items():
    lb = b.get(key)
    if la and lb:
        pairs.setdefault(la, set()).add(lb)
back = {}
for la, lbs in pairs.items():
    for lb in lbs:
        back.setdefault(lb, set()).add(la)
print('# FW4 -> FW5 pad driver LUTs, paired by the pin they drive (padseed.py)')
for la, lbs in sorted(pairs.items()):
    if len(lbs) == 1:
        lb = next(iter(lbs))
        if len(back[lb]) == 1:
            print(la, lb)
