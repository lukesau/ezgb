#!/usr/bin/env python3
"""Seed pairs for belmatch.py from two builds' Game Boy register maps.

    regseed.py A.regmap.txt B.regmap.txt > seed.txt

The register maps (stage0/re/sim/regmap.py, stage0/re/maps/*.regmap.txt)
give each flip-flop the /WR clocks drive its data pin and enabling address.
FW4 decodes $7Fxx with A15 in the clock and FW5 with A15 in the enable, so
the decodes differ and belmatch.py's structural passes can't pair those
registers. A register that takes one data pin as it is, at one address,
is the same register in both builds: this pairs those, by address (A15
ignored) and data pin, when the pair is unique on both sides.
"""
import sys, re
from collections import defaultdict

LINE = re.compile(r'^(X\d+Y\d+_S\d)_([XY])Q\s+D=(P\d+)\s+([01x*]{16}) \(1\) when')


def load(path):
    regs = defaultdict(list)
    for line in open(path):
        m = LINE.match(line)
        if m:
            slc, xy, pin, addr = m.groups()
            regs[('x' + addr[1:], pin)].append(f'{slc}.FF{xy}')
    return regs


a, b = load(sys.argv[1]), load(sys.argv[2])
print('# FW4 -> FW5 Game Boy registers paired by address and data pin (regseed.py)')
for key in sorted(a):
    if len(a[key]) == 1 and len(b.get(key, ())) == 1:
        print(a[key][0], b[key][0], '#', key[0], key[1])
