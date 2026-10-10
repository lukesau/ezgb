#!/usr/bin/env python3
"""Split a 32 KB stage1 image into the BRAM contents s3patch writes back.

Inverse of stage1-from-bram.py. $0000-$3FFF become eight 16K x 1 bit
planes, $4000-$47FF the x9 byte BRAM; $4800-$7FFF must be zero (not stored).

    stage1-to-bram.py stage1.gb OUT_DIR [--layout fw4]

Writes OUT_DIR/<tile>.DATA.bin and prints the matching s3patch --set args.
"""

import argparse
import pathlib
import sys

LAYOUTS = {
    # bit 0..7 plane BRAMs, then the byte BRAM (see re/stage0/docs/bitstream.md)
    "fw4": (["D0X19Y5", "D0X19Y21", "D0X19Y25", "D0X3Y13",
             "D0X3Y17", "D0X19Y13", "D0X19Y9", "D0X19Y29"], "D0X19Y17"),
    # FW5-0918 (Update_FW5_2021-9-18.gb), found with stage1-from-bram.py --discover
    "fw5-0918": (["D0X19Y29", "D0X19Y5", "D0X3Y25", "D0X19Y9",
                  "D0X3Y29", "D0X19Y25", "D0X3Y21", "D0X3Y9"], "D0X3Y17"),
}


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("stage1", type=pathlib.Path)
    ap.add_argument("out", type=pathlib.Path)
    ap.add_argument("--layout", default="fw4", choices=sorted(LAYOUTS))
    args = ap.parse_args()
    img = args.stage1.read_bytes()
    if len(img) != 0x8000:
        sys.exit("stage1 must be 32 KB")
    if any(img[0x4800:]):
        sys.exit("$4800-$7FFF must be zero: that range is not stored in BRAM")
    planes, byte_bram = LAYOUTS[args.layout]
    args.out.mkdir(parents=True, exist_ok=True)
    sets = []
    for bit, tile in enumerate(planes):
        out = bytearray(2048)
        for a in range(0x4000):
            if img[a] >> bit & 1:
                out[a // 8] |= 1 << (a % 8)
        (args.out / f"{tile}.DATA.bin").write_bytes(out)
        sets.append(f"--set {tile}.BEL:BRAM:DATA={args.out / f'{tile}.DATA.bin'}")
    (args.out / f"{byte_bram}.DATA.bin").write_bytes(img[0x4000:0x4800])
    sets.append(f"--set {byte_bram}.BEL:BRAM:DATA={args.out / f'{byte_bram}.DATA.bin'}")
    print(" ".join(sets))


if __name__ == "__main__":
    main()
