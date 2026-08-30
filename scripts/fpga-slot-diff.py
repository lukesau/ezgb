#!/usr/bin/env python3
"""Compare the two FPGA slots in a flash image, or overlay an updater payload.

Read-only forensic helper for the EZ Flash Jr EN25F40 config flash. The flash
holds two multiboot slots: A at $00000, B at $40000, each a container header
followed by an ~146 KB bitstream. See docs/fpga-flash-map.md.

    scripts/fpga-slot-diff.py <image.bin> --slots
        diff slot A against slot B (bitstream span only)

    scripts/fpga-slot-diff.py <image.bin> --overlay <Update_FW*.gb> [--slot A|B]
        align the updater's payload (past its $8000 GB header) to a slot by its
        bitstream sync word and report byte mismatches -- the check that the
        payload really is what the flash holds.
"""
import argparse
import sys

SLOT_A = 0x00000
SLOT_B = 0x40000
BITSTREAM_SYNC = bytes.fromhex("aa9930a10007")
BITSTREAM_END = 0x24831  # last data byte within a slot, relative to image


def load(path):
    d = open(path, "rb").read()
    if len(d) == 524288 + 272:
        d = d[:524288]
    return d


def slot_diff(d):
    a_sync = d.find(BITSTREAM_SYNC, SLOT_A, SLOT_B)
    b_sync = d.find(BITSTREAM_SYNC, SLOT_B)
    if a_sync < 0 or b_sync < 0:
        sys.exit("bitstream sync not found in one or both slots")
    span = BITSTREAM_END - a_sync + 1
    diffs = [i for i in range(span) if d[a_sync + i] != d[b_sync + i]]
    print("slot A bitstream sync at $%05x, slot B at $%05x, span %d bytes"
          % (a_sync, b_sync, span))
    print("%d differing bytes between the two slot bitstreams:" % len(diffs))
    for off in diffs:
        print("  +$%05x  A=%02x  B=%02x" % (off, d[a_sync + off], d[b_sync + off]))
    if not diffs:
        print("  (identical)")


def overlay(d, updater_path, which):
    pay = open(updater_path, "rb").read()[0x8000:]
    ps = pay.find(BITSTREAM_SYNC)
    if ps < 0:
        sys.exit("no bitstream sync in updater payload")
    slot = SLOT_A if which == "A" else SLOT_B
    cs = d.find(BITSTREAM_SYNC, slot, slot + 0x40000)
    if cs < 0:
        sys.exit("no bitstream sync in slot %s" % which)
    delta = cs - ps
    n = min(len(pay), len(d) - delta)
    diffs = [i for i in range(n) if pay[i] != d[delta + i]]
    print("payload sync at $%05x, slot %s sync at $%05x -> overlay at chip $%05x"
          % (ps, which, cs, delta))
    print("%d / %d payload bytes differ from slot %s" % (len(diffs), n, which))
    for i in diffs[:32]:
        print("  payload+$%05x=%02x  chip$%05x=%02x"
              % (i, pay[i], delta + i, d[delta + i]))
    if len(diffs) > 32:
        print("  ... %d more" % (len(diffs) - 32))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("image")
    ap.add_argument("--slots", action="store_true")
    ap.add_argument("--overlay", metavar="UPDATER.gb")
    ap.add_argument("--slot", choices=["A", "B"], default="B")
    args = ap.parse_args()

    d = load(args.image)
    if args.slots:
        slot_diff(d)
    if args.overlay:
        overlay(d, args.overlay, args.slot)
    if not args.slots and not args.overlay:
        ap.error("give --slots and/or --overlay")


if __name__ == "__main__":
    main()
