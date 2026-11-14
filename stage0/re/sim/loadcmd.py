#!/usr/bin/env python3
"""List a FAT32 card image, or build the stage1/kernel load command for one
file (docs/fpga-stage1.md): +0 = 0, {start LBA, running end} extents, last
end $FFFFFFFF then 0, +$1F0 size, +$1F4 1, +$1F8 sectors per cluster.
usage: loadcmd.py IMAGE                -> list the root and one level down
       loadcmd.py IMAGE /PATH OUT.hex [STEP] -> load command as 512 hex bytes;
       STEP (default: sectors per cluster) is the sectors per PicoBlaze run"""
import struct, sys

img = open(sys.argv[1], 'rb').read()
bps, spc, rsv, nfat = struct.unpack_from('<HBHB', img, 11)
spf, root = struct.unpack_from('<I', img, 36)[0], struct.unpack_from('<I', img, 44)[0]
fat0 = rsv * bps
data = rsv + nfat * spf                      # first data sector

def lba(c): return data + (c - 2) * spc
def chain(c):
    out = []
    while 2 <= c < 0x0FFFFFF7:
        out.append(c); c = struct.unpack_from('<I', img, fat0 + 4 * c)[0] & 0x0FFFFFFF
    return out
def entries(c):
    raw = b''.join(img[lba(x) * bps:(lba(x) + spc) * bps] for x in chain(c))
    lfn = ''
    for o in range(0, len(raw), 32):
        e = raw[o:o + 32]
        if e[0] == 0: break
        if e[0] == 0xE5: lfn = ''; continue
        if e[11] == 0x0F:
            part = e[1:11] + e[14:26] + e[28:32]
            lfn = part.decode('utf-16-le').split('\0')[0].rstrip('￿') + lfn; continue
        short = e[0:8].decode('latin1').rstrip() + ('.' + e[8:11].decode('latin1').rstrip() if e[8] != 32 else '')
        clus = struct.unpack_from('<H', e, 20)[0] << 16 | struct.unpack_from('<H', e, 26)[0]
        yield (lfn or short), e[11], clus, struct.unpack_from('<I', e, 28)[0]
        lfn = ''
def find(path):
    c = root
    for name in path.strip('/').split('/'):
        for n, attr, cl, size in entries(c):
            if n.lower() == name.lower(): c, hit = cl, (n, attr, cl, size); break
        else: sys.exit(f'not found: {name}')
    return hit

if len(sys.argv) == 2:
    for n, attr, cl, size in entries(root):
        if n in ('.', '..') or attr & 8: continue
        print(('%s/' % n) if attr & 0x10 else '%-40s %8d' % (n, size))
        if attr & 0x10:
            for n2, a2, c2, s2 in list(entries(cl))[:12]:
                if n2 not in ('.', '..'): print('    %-36s %8d' % (n2, s2))
    sys.exit()
n, attr, cl, size = find(sys.argv[2])
runs, cs = [], chain(cl)
for c in cs:
    if runs and c == runs[-1][1] + 1: runs[-1][1] = c
    else: runs.append([c, c])
cmd = bytearray(512); o, total = 4, 0
for i, (a, b) in enumerate(runs):
    total += (b - a + 1) * spc
    end = 0xFFFFFFFF if i == len(runs) - 1 else total
    struct.pack_into('<II', cmd, o, lba(a), end); o += 8
step = int(sys.argv[4]) if len(sys.argv) > 4 else spc
struct.pack_into('<III', cmd, 0x1F0, size, 1, step)
open(sys.argv[3], 'w').write('\n'.join('%02x' % b for b in cmd) + '\n')
print(f'{n}: {size} bytes, {len(runs)} extent(s), first LBA {lba(runs[0][0])}, {spc} sectors/cluster, step {step}')
