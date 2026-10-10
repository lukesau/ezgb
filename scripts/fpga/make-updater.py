#!/usr/bin/env python3
"""Build an EZ Flash Jr FW4 updater carrying a different slot B bitstream.

    make-updater.py Update_FW4.gb slotB.bin Update_FW4-new.gb [--label "Update: CGB test"]

Update_FW4.gb is a launched game: it writes its payload (file offset $8000,
one 149,516-byte XC3S200A stream) to config flash $040000 page by page via
the FPGA's flash-update command, with no checksum, read-back or version gate
(docs/fpga-cgb.md). So a new updater is the stock file with the payload
swapped. Only slot B is written; slot A and the per-chip license record at
$030000 are untouched. The label replaces the 16-byte "Update to ver:4 "
line so the build can't be mistaken for the stock updater. The updater code
itself is not modified.
"""

import argparse
import pathlib
import sys

PAYLOAD = 0x8000
LENGTH = 149516
LABEL_AT = 0x11D2
STOCK_LABEL = b"Update to ver:4 "


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("stock", type=pathlib.Path)
    ap.add_argument("slot_b", type=pathlib.Path)
    ap.add_argument("out", type=pathlib.Path)
    ap.add_argument("--label", default="Update: custom  ")
    args = ap.parse_args()
    src = args.stock.read_bytes()
    new = args.slot_b.read_bytes()
    if len(src) != PAYLOAD + LENGTH or src[LABEL_AT:LABEL_AT + 16] != STOCK_LABEL:
        sys.exit("not the stock Update_FW4.gb")
    if len(new) != LENGTH or new[:32] != b"\xff" * 32 or new[32:36] != b"\xaa\x99\x30\xa1":
        sys.exit("slot B image must be a raw 149,516-byte XC3S200A stream")
    label = args.label.encode("ascii")
    if len(label) > 16:
        sys.exit("label is at most 16 characters")
    out = bytearray(src)
    out[PAYLOAD:] = new
    out[LABEL_AT:LABEL_AT + 16] = label.ljust(16)
    total = (sum(out) - out[0x14E] - out[0x14F]) & 0xFFFF
    out[0x14E:0x150] = total.to_bytes(2, "big")
    args.out.write_bytes(out)
    print(f"{args.out}: payload replaced, label {label.decode()!r}")


if __name__ == "__main__":
    main()
