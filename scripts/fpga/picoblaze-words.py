#!/usr/bin/env python3
"""Dump a 1K x 18 BRAM (PicoBlaze KCPSM3 program) as 18-bit words.

Takes the DATA and DATAP files s3decode writes for one BRAM tile.  In x18 mode
word i is DATA bits [16i, 16i+16) plus DATAP bits [2i, 2i+2) as bits 17:16.

    picoblaze-words.py BRAM_DIR/D0X3Y25.BEL.BRAM

prints "addr: word" for every word, one per line.  No disassembly yet.
"""

import sys


def words(prefix):
    data = open(prefix + ".DATA.bin", "rb").read()
    par = open(prefix + ".DATAP.bin", "rb").read()
    for i in range(1024):
        lo = data[2 * i] | data[2 * i + 1] << 8
        hi = par[i // 4] >> (i % 4 * 2) & 3
        yield i, hi << 16 | lo


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    for addr, w in words(sys.argv[1]):
        print(f"{addr:03x}: {w:05x}")


if __name__ == "__main__":
    main()
