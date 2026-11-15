#!/usr/bin/env python3
"""Compare a build's generated includes with a stock kernel, region by region.

    tools/incdiff.py [--rom ROM] [-v] BUILD_DIR [inc ...]

`make` only says whether the whole ROM matches. This reads each sdinc.py
include in BUILD_DIR (its `; $START-$END` line, its `db` bytes and `Name::`
labels), compares the bytes with the same range of ROM (default the 1.04e
stock kernel) and prints, per include, how many bytes differ and the first
one: its address, the label it falls under, and with -v the bytes around
it. The bank comes from the file name (b<N>_, ff_b<N>, crt0_*).
"""
import argparse
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent


def bank_of(name):
    m = re.match(r"(?:b|ff_b)([0-9a-f])_?", name)
    if m:
        return int(m[1], 16)
    if name.startswith("crt0_low") or name.startswith("crt0_home"):
        return 0
    if name.startswith("b1_gsinittail"):
        return 1
    return None


def read_inc(path):
    lines = path.read_text().splitlines()
    m = re.match(r";\s*\$([0-9a-f]+)-\$([0-9a-f]+)", lines[1])
    start, end = int(m[1], 16), int(m[2], 16)
    data, labels = [], []
    for ln in lines[2:]:
        ln = ln.split(";")[0].strip()
        if ln.endswith("::"):
            labels.append((start + len(data), ln[:-2]))
        elif ln.startswith("db "):
            data += [int(x.strip().lstrip("$"), 16) for x in ln[3:].split(",")]
    return start, end, data, labels


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    p.add_argument("build")
    p.add_argument("incs", nargs="*")
    p.add_argument("--rom", default=str(HERE.parent.parent / "1.04e" / "kernel.gb.orig"))
    p.add_argument("-v", action="store_true")
    a = p.parse_args()
    rom = open(a.rom, "rb").read()
    incs = [Path(a.build) / i for i in a.incs] if a.incs else sorted(Path(a.build).glob("*.inc"))
    for inc in incs:
        bank = bank_of(inc.name)
        if bank is None:
            continue
        start, end, data, labels = read_inc(inc)
        base = start if bank == 0 or start >= 0x8000 else bank * 0x4000 + start - 0x4000
        if start >= 0x8000:                     # linked for WRAM, placed elsewhere
            print(f"{inc.name:24} {bank:02x}:{start:04x}  (WRAM-linked, skipped)")
            continue
        stock = rom[base:base + len(data)]
        diff = [i for i in range(len(data)) if data[i] != stock[i]]
        if not diff:
            print(f"{inc.name:24} {bank:02x}:{start:04x}-{end:04x}  ok")
            continue
        i = diff[0]
        lab = max((l for l in labels if l[0] <= start + i), default=(start, "?"))
        print(f"{inc.name:24} {bank:02x}:{start:04x}-{end:04x}  {len(diff)} bytes differ, "
              f"first {bank:02x}:{start + i:04x} ({lab[1]}+{start + i - lab[0]:#x})")
        if a.v:
            lo = max(0, i - 8)
            print("   ours ", " ".join(f"{x:02x}" for x in data[lo:i + 24]))
            print("   stock", " ".join(f"{x:02x}" for x in stock[lo:i + 24]))


if __name__ == "__main__":
    main()
