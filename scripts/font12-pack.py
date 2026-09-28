#!/usr/bin/env python3
"""Pack decomp/font12/font12.txt (12x12 ASCII-art glyphs) into the raw
table decomp/font12/font12.bin that decomp/src/draw12.c reads at 02:6000
(label Font12), and print the inject_bytes.py command that places it.

Table layout: one entry per glyph, in sheet order (codes 0x20-0x7F, then the
five icons 0xC0-0xC4), 24 bytes each: 12 rows of a big-endian 16-bit word
whose top 12 bits are the row's pixels, leftmost pixel in bit 15. The low
nibble is always zero; the blitter masks it off. A second copy of the whole
table follows with every row shifted right by 4 bits (FONT12_SH4 in
draw12.c), used by the pair blitter for the right-hand cell of a pair.

    scripts/font12-pack.py [-i decomp/font12/font12.txt] [-o decomp/font12/font12.bin]
"""
import argparse
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_IN = os.path.join(ROOT, "decomp", "font12", "font12.txt")
DEFAULT_OUT = os.path.join(ROOT, "decomp", "font12", "font12.bin")
ORDER = list(range(0x20, 0x80)) + [0xC0, 0xC1, 0xC2, 0xC3, 0xC4]


def parse(path):
    blocks = {}
    cur = None
    for line in open(path):
        line = line.rstrip("\n")
        m = re.match(r"glyph 0x([0-9A-Fa-f]{2})\b", line)
        if m:
            cur = int(m.group(1), 16)
            blocks[cur] = []
        elif cur is not None and re.fullmatch(r"[.#]{12}", line):
            blocks[cur].append(line)
    return blocks


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", "--input", default=DEFAULT_IN)
    ap.add_argument("-o", "--out", default=DEFAULT_OUT)
    args = ap.parse_args()
    blocks = parse(args.input)
    data = bytearray()
    for code in ORDER:
        rows = blocks.get(code)
        if rows is None or len(rows) != 12:
            raise SystemExit(f"glyph 0x{code:02X}: expected 12 rows, found {0 if rows is None else len(rows)}")
        for r in rows:
            v = 0
            for i, ch in enumerate(r):
                if ch == "#":
                    v |= 1 << (15 - i)
            data += bytes((v >> 8, v & 0xFF))
    # Second table: every row shifted right by 4 (the glyph as it sits in the
    # right-hand tile of an odd cell), so the pair blitter composes the
    # shared middle tile with one AND and one OR per row.
    shifted = bytearray()
    for i in range(0, len(data), 2):
        v = ((data[i] << 8) | data[i + 1]) >> 4
        shifted += bytes((v >> 8, v & 0xFF))
    with open(args.out, "wb") as f:
        f.write(data + shifted)
    print(f"wrote {args.out}: {len(ORDER)} glyphs, {len(data)} bytes + {len(shifted)} shifted")
    print("place it with (from decomp/, --replace if already injected):")
    print(f"  python3 tools/inject_bytes.py $V 2 6000 Font12 $(xxd -p {os.path.relpath(args.out, os.path.join(ROOT, 'decomp'))} | tr -d '\\n') --apply")


if __name__ == "__main__":
    main()
