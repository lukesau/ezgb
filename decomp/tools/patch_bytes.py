#!/usr/bin/env python3
"""
Change a few bytes of an existing instruction in kernel.gb, verifying what is
there first. For the one- and two-byte immediate edits (a row count, an ink
shade, a field width) that neither patch_call.py (whole call/jp retargets)
nor inject_bytes.py (new blocks in free space) covers.

Usage:
    patch_bytes.py <version> <bank> <address_hex> <expect_hex> <new_hex> [--apply]

The bytes at the address must equal <expect_hex> (or already equal <new_hex>,
in which case nothing is written and the tool says so). Both hex strings must
be the same length. Without --apply it only reports.

Example (DrawBrowserEntries' 16-row clamp, `ld a, $10` at 01:411b):
    patch_bytes.py 1.05e-0731 1 411c 10 0a --apply
"""
import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def rom_offset(bank, addr):
    if bank == 0:
        if not 0 <= addr < 0x4000:
            sys.exit(f"bank 0 address ${addr:04x} out of range")
        return addr
    if not 0x4000 <= addr < 0x8000:
        sys.exit(f"bank {bank} address ${addr:04x} must be in $4000-$7fff")
    return bank * 0x4000 + (addr - 0x4000)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("version")
    ap.add_argument("bank", type=lambda s: int(s, 0))
    ap.add_argument("address", type=lambda s: int(s, 16))
    ap.add_argument("expect")
    ap.add_argument("new")
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()

    expect = bytes.fromhex(args.expect)
    new = bytes.fromhex(args.new)
    if len(expect) != len(new) or not new:
        sys.exit("expect/new must be the same non-zero length")
    path = os.path.join(ROOT, "re", args.version, "kernel.gb")
    rom = bytearray(open(path, "rb").read())
    off = rom_offset(args.bank, args.address)
    cur = bytes(rom[off:off + len(new)])
    where = f"{args.bank:02x}:{args.address:04x}"
    if cur == new:
        print(f"{where}: already {new.hex()} (no change)")
        return
    if cur != expect:
        sys.exit(f"{where}: found {cur.hex()}, expected {expect.hex()}; refusing")
    print(f"{where}: {cur.hex()} -> {new.hex()}" + ("" if args.apply else " (dry run)"))
    if args.apply:
        rom[off:off + len(new)] = new
        with open(path, "wb") as f:
            f.write(rom)


if __name__ == "__main__":
    main()
