#!/usr/bin/env python3
"""xfirst.py VCD [T0_ps]: signals that go from known to X after T0, earliest first."""
import sys
vcd = sys.argv[1]; t0 = int(sys.argv[2]) if len(sys.argv) > 2 else 0
ids, state, trans, t = {}, {}, [], 0
scope = []
for line in open(vcd):
    if line.startswith("$scope"): scope.append(line.split()[2])
    elif line.startswith("$upscope"): scope.pop()
    elif line.startswith("$var"):
        p = line.split(); ids.setdefault(p[3], []).append(".".join(scope[2:]) + "." + p[4])
    elif line.startswith("#"): t = int(line[1:])
    else:
        s = line.strip()
        if not s or s.startswith("$"): continue
        v, i = (s.split() if s[0] == "b" else (s[0], s[1:]))
        isx = "x" in v.lower()
        for n in ids.get(i, []):
            if isx and state.get(n) is False and t >= t0: trans.append((t, n))
            state[n] = isx
for tt, n in sorted(trans)[:40]: print(tt, n)
