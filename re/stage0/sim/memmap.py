#!/usr/bin/env python3
"""Work out the pSRAM address map from memcap.v's capture of a ROM load.
Assumes the k-th write is byte k of the file (checked against the data).
usage: memmap.py memcap.txt card.img FIRST_LBA"""
import sys
cap, img, lba = sys.argv[1], sys.argv[2], int(sys.argv[3])
rows = [l.split() for l in open(cap)]
data = open(img, 'rb').read()[lba * 512:]
names = ['P46', 'P53', 'P20', 'P86', 'P83', 'P50', 'P44', 'P73', 'P70', 'P71', 'P65', 'P59', 'P56',
         'P52', 'P60', 'P36', 'P37'] + ['595.Q%d' % i for i in range(7, -1, -1)]
vecs, bad = [], 0
for k, (t, a, cs, lane, q, d) in enumerate(rows):
    bits = a + cs + lane + format(int(q, 16), '08b')
    vecs.append([int(c) for c in bits])
    if int(d, 2) != data[k]:
        if bad < 5: print('write %d: data %02x, file has %02x' % (k, int(d, 2), data[k]))
        bad += 1
print('%d writes, %d data mismatches' % (len(rows), bad))
n = len(vecs)
for i, name in enumerate(names):
    col = [v[i] for v in vecs]
    if len(set(col)) == 1:
        print('%-7s constant %d' % (name, col[0])); continue
    hit = [b for b in range(26) if all(col[k] == (k >> b) & 1 for k in range(n))]
    inv = [b for b in range(26) if all(col[k] != (k >> b) & 1 for k in range(n))]
    print('%-7s %s' % (name, ('= offset bit %d' % hit[0]) if hit else ('= NOT offset bit %d' % inv[0]) if inv else 'no simple match'))
