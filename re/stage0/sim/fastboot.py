#!/usr/bin/env python3
"""Sim-only shortcuts: copy a simulation directory's BRAM images into OUT,
patching bank 1's program (X3Y29) and symlinking everything else.
  - delay_long ($172, LOAD s3,$14) cut to one pass: card init at ~29 ms of
    simulated time instead of ~50 ms
  - --no-license: cmd_load_rom's two license-gate RETURN NZs ($1AD, $1B0)
    become LOAD s0,s0, so ROM loads run without a modeled Device DNA
Never use the patched images for anything but simulation.
usage: fastboot.py [--no-license] SIMDIR OUT"""
import os, sys
args = [a for a in sys.argv[1:] if not a.startswith('--')]
src, out = args
os.makedirs(out, exist_ok=True)
for f in os.listdir(src):
    if f.endswith('.mem') or f in ('flash.hex', 'card.img'):
        d = os.path.join(out, f)
        if not os.path.lexists(d):
            os.symlink(os.path.abspath(os.path.join(src, f)), d)
data = [l.strip() for l in open(os.path.join(src, 'D0X3Y29.DATA.mem'))]
par = [l.strip() for l in open(os.path.join(src, 'D0X3Y29.DATAP.mem'))]

def word(a):
    return sum(int(data[a * 16 + i]) << i for i in range(16)) | int(par[a * 2]) << 16 | int(par[a * 2 + 1]) << 17

def patch(a, old, new):
    assert word(a) == old, 'word $%03X is %05X, expected %05X' % (a, word(a), old)
    for i in range(16):
        data[a * 16 + i] = str((new >> i) & 1)
    par[a * 2], par[a * 2 + 1] = str((new >> 16) & 1), str((new >> 17) & 1)

patch(0x172, 0x00314, 0x00301)
if '--no-license' in sys.argv:
    patch(0x1AD, 0x2B400, 0x01000)
    patch(0x1B0, 0x2B400, 0x01000)
for name, bits in (('D0X3Y29.DATA.mem', data), ('D0X3Y29.DATAP.mem', par)):
    d = os.path.join(out, name)
    if os.path.lexists(d):
        os.remove(d)
    open(d, 'w').write('\n'.join(bits) + '\n')
