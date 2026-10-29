#!/usr/bin/env python3
"""Compare the design.v and fw4_top runs of the testbench (topsim.sh), from
base/run.log and top/run.log in the current directory: the PicoBlaze's first
executions, the flash and SD card models' transactions, the GB test and the
pin report, with the time offset between the runs."""
import re, sys
a = open('base/run.log').read().splitlines()
b = open('top/run.log').read().splitlines()
def strip_time(l): return re.sub(r'^\s*\d+\s+', '', l)
def times(lines, pat): return [(int(l.split()[0]), strip_time(l)) for l in lines if re.search(pat, l) and re.match(r'\s*\d+', l)]
for label, pat in [('PicoBlaze first executions', r' new B[12] '), ('flash model', r' flash: '), ('SD card model', r' sd: '), ('GB test', r' gb: ')]:
    ta, tb = times(a, pat), times(b, pat)
    sa, sb = [x[1] for x in ta], [x[1] for x in tb]
    same = sa == sb
    print(f"{label}: {len(sa)} vs {len(sb)} lines, sequence {'identical' if same else 'DIFFERS'}")
    if not same:
        for i, (x, y) in enumerate(zip(sa, sb)):
            if x != y: print(f"  first difference at line {i}:\n    base: {x}\n    top:  {y}"); break
        else: print(f"  one is a prefix of the other")
    if ta and tb:
        dts = [y[0] - x[0] for x, y in zip(ta, tb) if x[1] == y[1]]
        if dts: print(f"  time offset top-base: first {dts[0]} ns, last {dts[-1]} ns, min {min(dts)}, max {max(dts)}")
def report(lines):
    i = next((k for k, l in enumerate(lines) if 'pin' in l.lower() and 'report' in l.lower()), None)
    return lines[i:] if i is not None else [l for l in lines[-80:] if not re.match(r'\s*\d+', l)]
ra, rb = report(a), report(b)
print(f"pin report: {'identical' if ra == rb else 'DIFFERS'} ({len(ra)} vs {len(rb)} lines)")
if ra != rb:
    import difflib
    for l in list(difflib.unified_diff(ra, rb, 'base', 'top', lineterm='', n=0))[:40]: print('  ' + l)
