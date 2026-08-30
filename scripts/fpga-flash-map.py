#!/usr/bin/env python3
"""Segment map of an EZ Flash Jr EN25F40 config-flash image (512 KB).

Read-only forensic helper. Coalesces the many small FF gaps inside a bitstream
(frame padding) into whole regions, so the two multiboot slots and the extra
data blobs stand out. See docs/fpga-flash-map.md.

Usage:
    scripts/fpga-flash-map.py <image.bin> [--gap N] [--min N]

    --gap  erased run shorter than this is absorbed into the surrounding
           region rather than splitting it (default 512 bytes)
    --min  don't report coalesced regions smaller than this (default 64)
"""
import argparse
import sys


def load(path):
    d = open(path, "rb").read()
    # Programmer appends 272 bytes of STATUS/CFG when that box is ticked.
    if len(d) == 524288 + 272:
        d = d[:524288]
    if len(d) != 524288:
        sys.exit("expected a 512 KiB image (got %d bytes)" % len(d))
    return d


def regions(d, gap, minsz):
    """Yield (start, end_exclusive, nbytes_nonff) coalescing FF gaps < gap."""
    out = []
    i = 0
    n = len(d)
    while i < n:
        if d[i] == 0xFF:
            i += 1
            continue
        # start of content; extend, absorbing short FF gaps
        start = i
        last_data = i
        while i < n:
            if d[i] != 0xFF:
                last_data = i
                i += 1
            else:
                j = i
                while j < n and d[j] == 0xFF:
                    j += 1
                if j - i < gap and j < n and d[j] != 0xFF:
                    i = j  # short gap: keep going
                else:
                    break
        end = last_data + 1
        nonff = sum(1 for k in range(start, end) if d[k] != 0xFF)
        if end - start >= minsz:
            out.append((start, end, nonff))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("image")
    ap.add_argument("--gap", type=int, default=512)
    ap.add_argument("--min", type=int, default=64)
    args = ap.parse_args()

    d = load(args.image)
    print("image: %s (%d bytes)" % (args.image, len(d)))
    print("coalescing FF gaps < %d bytes\n" % args.gap)
    print("  region                    size     non-FF   fill%   head")
    for start, end, nonff in regions(d, args.gap, args.min):
        head = d[start:start + 6].hex()
        print("  $%05x-$%05x  %8d  %8d  %5.1f%%   %s"
              % (start, end - 1, end - start, nonff,
                 100.0 * nonff / (end - start), head))


if __name__ == "__main__":
    main()
