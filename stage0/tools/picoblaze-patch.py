#!/usr/bin/env python3
"""Overlay a PicoBlaze patch onto a program BRAM for s3patch.

The patch is KCPSM3 source with ADDRESS blocks (picoblaze-dis.py's
assembler; CONSTANTs and labels allowed). Only the words it assembles are
changed. A patched word that was not zero (unused) in the original must be
listed with --allow, so a patch can't overwrite live code by accident.

    picoblaze-patch.py BRAM_PREFIX PATCH.psm OUT_DIR --tile D0X3Y25 [--allow 1B7]

BRAM_PREFIX is the s3decode --blob-dir pair (PREFIX.DATA.bin +
PREFIX.DATAP.bin). Writes OUT_DIR/<tile>.DATA.bin and .DATAP.bin and prints
the matching s3patch --set args.
"""

import argparse
import importlib.util
import pathlib
import re
import sys

here = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("pbdis", here / "picoblaze-dis.py")
pbdis = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pbdis)


def patch_addrs(text):
    addrs, addr = [], 0
    for raw in text.splitlines():
        s = raw.split(";")[0].strip()
        if not s or s.startswith(("NAMEREG", "CONSTANT")):
            continue
        m = re.fullmatch(r"ADDRESS ([0-9A-F]+)", s)
        if m:
            addr = int(m[1], 16)
            continue
        if re.fullmatch(r"\w+:", s):
            continue
        addrs.append(addr)
        addr += 1
    return addrs


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("bram")
    ap.add_argument("patch", type=pathlib.Path)
    ap.add_argument("out", type=pathlib.Path)
    ap.add_argument("--tile", required=True, help="BRAM tile for the --set args, e.g. D0X3Y25")
    ap.add_argument("--allow", action="append", default=[], help="hex address of a live word the patch may replace")
    args = ap.parse_args()

    text = args.patch.read_text()
    words = pbdis.load_words(args.bram)
    new = pbdis.assemble(text)
    allow = {int(a, 16) for a in args.allow}
    addrs = patch_addrs(text)
    if len(set(addrs)) != len(addrs):
        sys.exit("patch assembles the same address twice")
    bad = [a for a in addrs if words[a] and a not in allow]
    if bad:
        sys.exit("patch overwrites live words: " + " ".join(f"{a:03X}={words[a]:05X}" for a in bad))
    for a in addrs:
        words[a] = new[a]

    data = bytearray(2048)
    par = bytearray(256)
    for i, w in enumerate(words):
        data[2 * i], data[2 * i + 1] = w & 0xFF, w >> 8 & 0xFF
        par[i // 4] |= (w >> 16 & 3) << (i % 4 * 2)
    args.out.mkdir(parents=True, exist_ok=True)
    d = args.out / f"{args.tile}.DATA.bin"
    p = args.out / f"{args.tile}.DATAP.bin"
    d.write_bytes(data)
    p.write_bytes(par)
    if addrs:
        print(f"{len(addrs)} words, {min(addrs):03X}-{max(addrs):03X}", file=sys.stderr)
    print(f"--set {args.tile}.BEL:BRAM:DATA={d} --set {args.tile}.BEL:BRAM:DATAP={p}")


if __name__ == "__main__":
    main()
