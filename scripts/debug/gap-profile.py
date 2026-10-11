#!/usr/bin/env python3
"""Report a SAMEBOY_PROFILE_GAP profile (docs/screen-timing.md).

The SameBoy stub samples bank:PC and the call stack every 256 T-cycles and,
at each joypad poll ($3A4A), writes out the samples of any gap over 1M
T-cycles: one gap per screen change. This prints each gap's time, the
functions the samples landed in (self time), and the functions anywhere on
the call stack (inclusive time).

    scripts/debug/gap-profile.py re/kernel/1.05e-0918/kernel.sym profile.txt [2,3]
"""
import bisect, collections, re, sys

TICKS_PER_MS = 4194304 / 1000


def load_symbols(path):
    names = {}
    for line in open(path):
        m = re.match(r"([0-9a-f]{2}):([0-9a-f]{4}) ([A-Za-z_]\w*)$", line.strip())
        if m:
            names.setdefault(int(m.group(1), 16), []).append((int(m.group(2), 16), m.group(3)))
    for b in names:
        names[b].sort()
    return names, {n for l in names.values() for _, n in l}


def main():
    names, top = load_symbols(sys.argv[1])
    which = [int(x) for x in sys.argv[3].split(",")] if len(sys.argv) > 3 else None

    def func(bank, addr):
        if addr >= 0x8000:
            return "(WRAM/HRAM code)"
        l = names.get(bank if addr >= 0x4000 else 0, [])
        i = bisect.bisect_right([a for a, _ in l], addr) - 1
        if i < 0:
            return f"{bank:02x}:{addr:04x}"
        n = l[i][1]
        while "_" in n and n.rsplit("_", 1)[0] in top:     # Foo_bar -> Foo
            n = n.rsplit("_", 1)[0]
        return n

    gaps = []
    for line in open(sys.argv[2]):
        parts = line.split()
        if parts[0] == "gap":
            gaps.append({"t": int(parts[1]), "self": collections.Counter(),
                         "incl": collections.Counter(), "n": 0})
        elif parts[0] == "stack":
            key, c = (parts[1], int(parts[2])) if len(parts) == 3 else ("", int(parts[1]))
            seen = set()
            for fr in filter(None, key.split("<")):
                b, a = fr.split(":")
                n = func(int(b, 16), int(a, 16))
                if n not in seen:
                    seen.add(n)
                    gaps[-1]["incl"][n] += c
            gaps[-1]["n"] += c
        else:
            b, pc = parts[0].split(":")
            # the kernel sets bank-register bits above its 10 banks
            gaps[-1]["self"][func(int(b, 16) & 0x1F, int(pc, 16))] += int(parts[1])
    for gi in which if which is not None else range(len(gaps)):
        g = gaps[gi]
        print(f"--- gap {gi}: {g['t']} T-cycles, {g['t'] / 70224:.1f} frames, {g['t'] / TICKS_PER_MS:.0f} ms")
        for title, c, total in (("self", g["self"], sum(g["self"].values())), ("inclusive", g["incl"], g["n"])):
            print(f"  {title}:")
            for n, k in c.most_common(14):
                print(f"    {100 * k / total:5.1f}%  {k * 256 / TICKS_PER_MS:6.0f} ms  {n}")


if __name__ == "__main__":
    main()
