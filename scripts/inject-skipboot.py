#!/usr/bin/env python3
"""Inject the skip-boot-ROM launch (issue #8) into re/kernel/<ver>/kernel.gb.

Assembles scripts/skipboot/skip_boot.asm and, through kernel/tools:

  04:6be6   SkipBootPrep: copies SkipBoot to WRAM $D1B0, points the launch
            stub's reset at it, runs the stub
  04:40f8   RomLoad_BuildAndRunPoll's call $d100  ->  call SkipBootPrep

Re-running replaces the block and skips bytes already set.

Usage: scripts/inject-skipboot.py <ver> [--apply]
"""
import importlib.util
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec = importlib.util.spec_from_file_location("inject_sgb", os.path.join(ROOT, "scripts", "inject-sgb.py"))
sgb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sgb)
sgb.ASM = os.path.join(ROOT, "scripts", "skipboot", "skip_boot.asm")

HOOK = 0x40f8                   # RomLoad_BuildAndRunPoll: call $d100


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    ver = sys.argv[1]
    apply = ["--apply"] if "--apply" in sys.argv[2:] else []
    secs = sgb.assemble({})
    bank, addr, data = secs["SkipBootPrep"]
    print(f"SkipBootPrep: {len(data)} B at {bank:02x}:{addr:04x}")
    sgb.put_block(ver, bank, addr, "SkipBootPrep", data, apply)
    rom = open(os.path.join(ROOT, "re", "kernel", ver, "kernel.gb"), "rb").read()
    new = bytes([0xcd, addr & 0xff, addr >> 8])
    if rom[sgb.offset(4, HOOK):sgb.offset(4, HOOK) + 3] != new:
        sgb.tool("patch_bytes.py", ver, "4", f"{HOOK:04x}", "cd00d1", new.hex(), *apply)


if __name__ == "__main__":
    main()
