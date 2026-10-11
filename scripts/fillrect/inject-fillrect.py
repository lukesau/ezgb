#!/usr/bin/env python3
"""Inject the fast DrawRect fill into re/kernel/<ver>/kernel.gb.

Assembles scripts/fillrect/fillrect.asm and, through kernel/tools:

  02:6f40   FillRect (docs/screen-timing.md)
  00:236d   DrawRectImpl_fillScan, the per-scanline DrawLine loop, becomes
            `call FarCallTrampoline; dw FillRect; db 2, 0; jr
            DrawRectImpl_restoreColors`, the rest of its 32 bytes nop

Written against the development base (1.05e-0731); port-mod.py carries it.
Re-running replaces the block.

Usage: scripts/fillrect/inject-fillrect.py 1.05e-0731 [--apply]
"""
import importlib.util
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
spec = importlib.util.spec_from_file_location("inject_sgb", os.path.join(ROOT, "scripts", "inject-sgb.py"))
sgb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sgb)

ASM = os.path.join(ROOT, "scripts", "fillrect", "fillrect.asm")
FILL_SCAN, RESTORE, FAR_CALL, FILL = 0x236d, 0x238d, 0x078d, 0x6f40


def assemble():
    """FillRect's bytes: the linked ROM at bank 2's file offset, up to the
    section's size from the map."""
    with tempfile.TemporaryDirectory() as tmp:
        obj, rom, mapf = (os.path.join(tmp, n) for n in ("f.o", "f.gb", "f.map"))
        subprocess.run(["rgbasm", "-o", obj, ASM], check=True)
        subprocess.run(["rgblink", "-p", "0xff", "-m", mapf, "-o", rom, obj], check=True)
        data = open(rom, "rb").read()
        size = int(re.search(r"\(\$([0-9a-fA-F]+) bytes?\) \[\"FillRect\"\]", open(mapf).read()).group(1), 16)
    off = 2 * 0x4000 + FILL - 0x4000
    return data[off:off + size]


def main():
    if len(sys.argv) < 2 or sys.argv[1] != "1.05e-0731":
        sys.exit(__doc__)
    ver = sys.argv[1]
    apply = ["--apply"] if "--apply" in sys.argv[2:] else []
    code = assemble()
    sgb.put_block(ver, 2, FILL, "FillRect", code, apply)

    stub = bytes([0xCD, FAR_CALL & 0xFF, FAR_CALL >> 8, FILL & 0xFF, FILL >> 8, 2, 0])
    jr = RESTORE - (FILL_SCAN + len(stub) + 2)
    stub += bytes([0x18, jr & 0xFF])
    stub += bytes(RESTORE - FILL_SCAN - len(stub))       # nop
    rom = open(os.path.join(ROOT, "re", "kernel", ver, "kernel.gb"), "rb").read()
    stock = open(os.path.join(ROOT, "re", "kernel", ver, "kernel.gb.orig"), "rb").read()
    cur = rom[FILL_SCAN:RESTORE]
    if cur != stub:
        sgb.tool("patch_bytes.py", ver, "0", f"{FILL_SCAN:04x}", stock[FILL_SCAN:RESTORE].hex(), stub.hex(), *apply)
    else:
        print(f"00:{FILL_SCAN:04x}: already the far call")


if __name__ == "__main__":
    main()
