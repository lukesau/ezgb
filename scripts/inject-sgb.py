#!/usr/bin/env python3
"""Inject the SGB boot unlock into re/<ver>/kernel.gb (docs/sgb-boot.md).

Assembles scripts/sgb/sgb_boot.asm (the toggle build: it sends only when the
SET tab's SGB BOOT record in pSRAM is on) and, through decomp/tools:

  00:0020   SgbStub (9 B): push af, map bank 1, jp SgbUnlock
  01:7f00   SgbUnlock and helpers
  00:0100   nop / jp KernelEntry  ->  nop / jp SgbStub
  00:0146   SGB flag $00 -> $03, and $014B old licensee $00 -> $33: the SGB
            BIOS ignores a cart without both
  00:014d   header checksum recomputed over the new header ($014E-$014F, the
            global checksum, stays the shipped, stale value; nothing checks it)

Re-running replaces the two blocks and skips header bytes already set.

Usage: scripts/inject-sgb.py <ver> [--apply]
"""
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(ROOT, "decomp", "tools")
ASM = os.path.join(ROOT, "scripts", "sgb", "sgb_boot.asm")


def assemble():
    with tempfile.TemporaryDirectory() as tmp:
        obj, rom, mapf = (os.path.join(tmp, n) for n in ("s.o", "s.gb", "s.map"))
        subprocess.run(["rgbasm", "-o", obj, ASM], check=True)
        subprocess.run(["rgblink", "-p", "0xff", "-m", mapf, "-o", rom, obj], check=True)
        data = open(rom, "rb").read()
        maptxt = open(mapf).read()
    out = {}
    for m in re.finditer(r"SECTION: \$([0-9a-fA-F]+)-\$[0-9a-fA-F]+ \(\$([0-9a-fA-F]+) bytes?\) \[\"(\w+)\"\]", maptxt):
        start, size = int(m.group(1), 16), int(m.group(2), 16)
        off = start if start < 0x4000 else 0x4000 + start - 0x4000   # bank 1
        out[m.group(3)] = data[off:off + size]
    return out


def tool(*args):
    subprocess.run([sys.executable, os.path.join(TOOLS, args[0]), *args[1:]], check=True, cwd=os.path.join(ROOT, "decomp"))


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    ver = sys.argv[1]
    apply = ["--apply"] if "--apply" in sys.argv[2:] else []
    secs = assemble()
    tool("inject_bytes.py", ver, "0", "0020", "SgbStub", secs["SgbStub"].hex(), *apply)
    tool("inject_bytes.py", ver, "1", "7f00", "SgbUnlock", secs["SgbBank1"].hex(), *apply)
    tool("patch_bytes.py", ver, "0", "0100", "00c35001", "00c32000", *apply)
    tool("patch_bytes.py", ver, "0", "0146", "00", "03", *apply)
    tool("patch_bytes.py", ver, "0", "014b", "00", "33", *apply)
    rom = open(os.path.join(ROOT, "re", ver, "kernel.gb"), "rb").read()
    hdr = bytearray(rom[0x134:0x14D])
    hdr[0x146 - 0x134] = 0x03
    hdr[0x14B - 0x134] = 0x33
    c = 0
    for b in hdr:
        c = (c - b - 1) & 0xFF
    if rom[0x14D] != c:
        tool("patch_bytes.py", ver, "0", "014d", f"{rom[0x14D]:02x}", f"{c:02x}", *apply)


if __name__ == "__main__":
    main()
