#!/usr/bin/env python3
"""Pull every XC3S200A bitstream out of updaters and config-flash dumps.

A Spartan-3A bitgen stream is 16 dummy words (32 x $ff) followed by the sync
word `aa 99` and `30 a1` (type-1 write to CMD).  The XC3S200A stream is always
149,516 bytes from the first dummy word, which is what s3decode wants.

    extract-bitstreams.py Update_FW4.gb EN25F40-repaired-v2.bin -o out/

writes out/<file stem>@<hex offset>.bin for each image found.
"""

import argparse
import hashlib
import pathlib

HEAD = b"\xff" * 32 + b"\xaa\x99\x30\xa1"
LENGTH = 149516  # XC3S200A


def find_images(data):
    pos = data.find(HEAD)
    while pos >= 0:
        yield pos, data[pos:pos + LENGTH]
        pos = data.find(HEAD, pos + LENGTH)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("files", nargs="+", type=pathlib.Path)
    ap.add_argument("-o", "--out", type=pathlib.Path, required=True)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    for f in args.files:
        data = f.read_bytes()
        found = False
        for pos, img in find_images(data):
            found = True
            if len(img) != LENGTH:
                print(f"{f.name}@{pos:#x}: truncated ({len(img)} bytes), skipped")
                continue
            name = args.out / f"{f.stem}@{pos:05x}.bin"
            name.write_bytes(img)
            print(f"{name.name}  sha1 {hashlib.sha1(img).hexdigest()[:12]}")
        if not found:
            print(f"{f.name}: no bitstream found")


if __name__ == "__main__":
    main()
