#!/usr/bin/env python3
"""Sim-only shortcut: copy a simulation directory's BRAM images into OUT with
bank 1's delay_long ($172, LOAD s3,$14) cut to one pass, symlinking the rest.
Card init then finishes at ~29 ms of simulated time instead of ~50 ms.
Never use the patched image for anything but simulation.
usage: fastboot.py SIMDIR OUT"""
import os, sys
src, out = sys.argv[1:3]
os.makedirs(out, exist_ok=True)
for f in os.listdir(src):
    if f.endswith('.mem') or f in ('flash.hex', 'card.img'):
        d = os.path.join(out, f)
        if not os.path.lexists(d):
            os.symlink(os.path.abspath(os.path.join(src, f)), d)
bits = [l.strip() for l in open(os.path.join(src, 'D0X3Y29.DATA.mem'))]
word = lambda a: sum(int(bits[a * 16 + i]) << i for i in range(16))
assert word(0x172) == 0x0314, 'delay_long not where expected'
for i in range(16):
    bits[0x172 * 16 + i] = str((0x0301 >> i) & 1)
d = os.path.join(out, 'D0X3Y29.DATA.mem')
os.remove(d)
open(d, 'w').write('\n'.join(bits) + '\n')
