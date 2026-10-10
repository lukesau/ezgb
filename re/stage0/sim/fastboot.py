#!/usr/bin/env python3
"""Sim-only shortcuts: copy a simulation directory's BRAM images into OUT,
patching bank 1's program and symlinking everything else.
  - delay_long ($172, LOAD s3,$14) cut to one pass: card init at ~29 ms of
    simulated time instead of ~50 ms
  - --no-license: cmd_load_rom's two license-gate RETURN NZs ($1AD, $1B0)
    become LOAD s0,s0, so ROM loads run without a modeled Device DNA
Never use the patched images for anything but simulation.
--fw picks the build: bank 1 sits on a different BRAM, and the routines at
different addresses, in each (listings in re/stage0/picoblaze/).
usage: fastboot.py [--no-license] [--fw fw4|fw5-0731|fw5-0918] SIMDIR OUT"""
import os, sys
# build: (bank-1 BRAM, delay_long's LOAD s3,$14, the two license RETURN NZs)
BUILDS = {'fw4': ('X3Y29', 0x172, 0x1AD, 0x1B0),
          'fw5-0731': ('X19Y25', 0x1C7, 0x1F8, 0x1FB),
          'fw5-0918': ('X3Y1', 0x1E1, 0x212, 0x215)}
argv = sys.argv[1:]
fw = 'fw4'
if '--fw' in argv:
    i = argv.index('--fw'); fw = argv[i + 1]; del argv[i:i + 2]
tile, a_delay, a_lic1, a_lic2 = BUILDS[fw]
args = [a for a in argv if not a.startswith('--')]
src, out = args
os.makedirs(out, exist_ok=True)
for f in os.listdir(src):
    if f.endswith('.mem') or f in ('flash.hex', 'card.img'):
        d = os.path.join(out, f)
        if not os.path.lexists(d):
            os.symlink(os.path.abspath(os.path.join(src, f)), d)
data = [l.strip() for l in open(os.path.join(src, f'D0{tile}.DATA.mem'))]
par = [l.strip() for l in open(os.path.join(src, f'D0{tile}.DATAP.mem'))]

def word(a):
    return sum(int(data[a * 16 + i]) << i for i in range(16)) | int(par[a * 2]) << 16 | int(par[a * 2 + 1]) << 17

def patch(a, old, new):
    assert word(a) == old, 'word $%03X is %05X, expected %05X' % (a, word(a), old)
    for i in range(16):
        data[a * 16 + i] = str((new >> i) & 1)
    par[a * 2], par[a * 2 + 1] = str((new >> 16) & 1), str((new >> 17) & 1)

patch(a_delay, 0x00314, 0x00301)
if '--no-license' in sys.argv:
    patch(a_lic1, 0x2B400, 0x01000)
    patch(a_lic2, 0x2B400, 0x01000)
for name, bits in ((f'D0{tile}.DATA.mem', data), (f'D0{tile}.DATAP.mem', par)):
    d = os.path.join(out, name)
    if os.path.lexists(d):
        os.remove(d)
    open(d, 'w').write('\n'.join(bits) + '\n')
