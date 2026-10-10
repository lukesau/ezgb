#!/usr/bin/env python3
"""Rebuild the cart's 32 KB stage1 bootstrap from s3decode --blob-dir output.

FW4 layout (proven 2026-10-08, see re/stage0/docs/bitstream.md):
  $0000-$3FFF  8 BRAMs in x1 mode, one data bit each (16K x 1 bit planes)
  $4000-$47FF  1 BRAM in x9 mode, bytes in address order
  $4800-$7FFF  not stored, reads as $00

    stage1-from-bram.py BRAM_DIR -o stage1.gb [--ref stage1.gb]

With --ref and --discover, the plane/byte BRAMs are found by matching the
reference instead of using the FW4 table (for other firmware revisions).
"""

import argparse
import pathlib
import sys

FW4_PLANES = ["D0X19Y5", "D0X19Y21", "D0X19Y25", "D0X3Y13",
              "D0X3Y17", "D0X19Y13", "D0X19Y9", "D0X19Y29"]
FW4_BYTES = "D0X19Y17"


def load(dirpath):
    return {p.name.split(".")[0]: p.read_bytes()
            for p in pathlib.Path(dirpath).glob("*.BEL.BRAM.DATA.bin")}


def plane_of(ref, bit):
    out = bytearray(2048)
    for a in range(0x4000):
        if ref[a] >> bit & 1:
            out[a // 8] |= 1 << (a % 8)
    return bytes(out)


def discover(brams, ref):
    planes = []
    for bit in range(8):
        want = plane_of(ref, bit)
        hit = [n for n, b in brams.items() if b == want]
        if not hit:
            sys.exit(f"no BRAM holds bit {bit} of $0000-$3FFF")
        planes.append(hit[0])
    hit = [n for n, b in brams.items() if b == ref[0x4000:0x4800]]
    if not hit:
        sys.exit("no BRAM holds $4000-$47FF")
    return planes, hit[0]


def rebuild(brams, planes, byte_bram):
    out = bytearray(0x8000)
    for bit, name in enumerate(planes):
        b = brams[name]
        for a in range(0x4000):
            if b[a // 8] >> (a % 8) & 1:
                out[a] |= 1 << bit
    out[0x4000:0x4800] = brams[byte_bram]
    return bytes(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("bram_dir")
    ap.add_argument("-o", "--out", type=pathlib.Path)
    ap.add_argument("--ref", type=pathlib.Path, help="known stage1.gb to compare against")
    ap.add_argument("--discover", action="store_true",
                    help="find the BRAMs by matching --ref instead of using the FW4 table")
    args = ap.parse_args()
    brams = load(args.bram_dir)
    ref = args.ref.read_bytes() if args.ref else None
    if args.discover:
        if ref is None:
            sys.exit("--discover needs --ref")
        planes, byte_bram = discover(brams, ref)
        print("planes (bit 0..7):", " ".join(planes))
        print("bytes $4000-$47FF:", byte_bram)
    else:
        planes, byte_bram = FW4_PLANES, FW4_BYTES
    img = rebuild(brams, planes, byte_bram)
    if args.out:
        args.out.write_bytes(img)
    if ref is not None:
        same = img == ref
        print("matches reference:", same)
        sys.exit(0 if same else 1)


if __name__ == "__main__":
    main()
