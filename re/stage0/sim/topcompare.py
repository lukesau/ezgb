#!/usr/bin/env python3
"""Compare the design.v and fw4_top runs of the testbench (topsim.sh), from
base/run.log and top/run.log in the current directory. With the base run
built under NO_SLICE_GSR the two logs are expected to match line for line,
timestamps included; verilator's own summary lines (walltime, speed) are
ignored. Prints the first differences otherwise, and the time offset if
the event sequence is the same but shifted."""
import re, sys, difflib
def load(path):
    return [l for l in open(path).read().splitlines() if not l.startswith('- Verilator:')]
a, b = load('base/run.log'), load('top/run.log')
if a == b:
    timed = sum(1 for l in a if re.match(r'\s*\d+\s', l))
    print(f"identical: {len(a)} lines, {timed} timed events, same timestamps")
    sys.exit(0)
print(f"DIFFERS: {len(a)} vs {len(b)} lines")
for l in list(difflib.unified_diff(a, b, 'base', 'top', lineterm='', n=0))[:40]: print('  ' + l)
# the same events on shifted times?
def strip_time(l): return re.sub(r'^\s*\d+\s+', '', l)
ta = [(int(l.split()[0]), strip_time(l)) for l in a if re.match(r'\s*\d+\s', l)]
tb = [(int(l.split()[0]), strip_time(l)) for l in b if re.match(r'\s*\d+\s', l)]
if [x[1] for x in ta] == [x[1] for x in tb]:
    dts = [y[0] - x[0] for x, y in zip(ta, tb)]
    print(f"event sequence identical; time offset top-base: first {dts[0]} ns, last {dts[-1]} ns, min {min(dts)}, max {max(dts)}")
sys.exit(1)
