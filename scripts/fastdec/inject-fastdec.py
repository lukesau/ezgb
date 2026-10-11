#!/usr/bin/env python3
"""Inject the fast decimal path for bank 4's U32ToAscii.

Assembles scripts/fastdec/u32dec.asm and, through kernel/tools:

  04:7c00   U32ToAsciiFast
  04:44f7   U32ToAscii's `add sp, -$34; ld hl, sp+$13` becomes
            `jp U32ToAsciiFast; nop` (the slow path runs them and jumps back)

Written against the development base (1.05e-0731); port-mod.py carries it.
Usage: scripts/fastdec/inject-fastdec.py 1.05e-0731 [--apply]
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

ASM = os.path.join(ROOT, "scripts", "fastdec", "u32dec.asm")
BANK, FAST, ENTRY = 4, 0x7c00, 0x44f7


def assemble():
    with tempfile.TemporaryDirectory() as tmp:
        obj, rom, mapf = (os.path.join(tmp, n) for n in ("f.o", "f.gb", "f.map"))
        subprocess.run(["rgbasm", "-o", obj, ASM], check=True)
        subprocess.run(["rgblink", "-p", "0xff", "-m", mapf, "-o", rom, obj], check=True)
        data = open(rom, "rb").read()
        size = int(re.search(r"\(\$([0-9a-fA-F]+) bytes?\) \[\"U32ToAsciiFast\"\]", open(mapf).read()).group(1), 16)
    off = BANK * 0x4000 + FAST - 0x4000
    return data[off:off + size]


def main():
    if len(sys.argv) < 2 or sys.argv[1] != "1.05e-0731":
        sys.exit(__doc__)
    ver = sys.argv[1]
    apply = ["--apply"] if "--apply" in sys.argv[2:] else []
    sgb.put_block(ver, BANK, FAST, "U32ToAsciiFast", assemble(), apply)
    sgb.tool("patch_bytes.py", ver, str(BANK), f"{ENTRY:04x}", "e8ccf813",
             f"c3{FAST & 0xFF:02x}{FAST >> 8:02x}00", *apply)


if __name__ == "__main__":
    main()
