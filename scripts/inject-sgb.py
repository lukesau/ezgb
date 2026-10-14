#!/usr/bin/env python3
"""Inject the SGB boot unlock into re/kernel/<ver>/kernel.gb (docs/sgb-boot.md).

Assembles scripts/sgb/sgb_boot.asm (the toggle build: it sends only when the
SET tab's SGB BOOT record in pSRAM is on) with the kernel addresses it needs
taken from kernel.sym, and, through kernel/tools:

  00:0020   SgbStub (9 B): push af, map bank 4, jp SgbUnlock
  00:02c3   SgbVblTail, 00:04e1 SgbVblList: VBlank vector runs the callback
            list, then one background step
  00:05f2   SgbPadGate: joypad freeze for 4 frames after each packet
  01:7f00   SgbBootHook: starts the background count after KernelEntry
  04:7d00   SgbLaunchHook, SgbUnlock (set 1), the packet sender and the
            background steps (docs/sgb-background-send.md)
  00:0040   VBlank vector  ->  call SgbVblList / jp SgbVblTail
  00:01ba   KernelEntry's call CgbInit  ->  call SgbBootHook
  00:3a16   ReadJoypadRaw  ->  jp SgbPadGate
  04:448f   RomLoad_CopyCmdWindowPoll_B4  ->  jp SgbLaunchHook
  00:0100   nop / jp KernelEntry  ->  nop / jp SgbStub
  00:0146   SGB flag $00 -> $03, and $014B old licensee $00 -> $33: the SGB
            BIOS ignores a cart without both
  00:014d   header checksum recomputed over the new header ($014E-$014F, the
            global checksum, stays the shipped, stale value; nothing checks it)

Re-running replaces the blocks and skips bytes already set. The pre-7.0
SgbUnlock block at 01:7f00 is put back to stock first.

Usage: scripts/inject-sgb.py <ver> [--apply]
"""
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(ROOT, "kernel", "tools")
ASM = os.path.join(ROOT, "scripts", "sgb", "sgb_boot.asm")


# kernel.sym names the asm uses, passed to rgbasm as -D
KERNEL_SYMS = ["RunCallbackList", "wVBlankCallbacks", "wRomBank", "ReadJoypadRaw",
               "RomLoad_CopyCmdWindowPoll_B4", "CgbInit", "DiNest", "EiNest"]


def kernel_syms(ver):
    sym = open(os.path.join(ROOT, "re", "kernel", ver, "kernel.sym")).read()
    out = {}
    for name in KERNEL_SYMS:
        m = re.search(rf"^([0-9a-f]{{2}}):([0-9a-f]{{4}}) {name}$", sym, re.M)
        if not m:
            sys.exit(f"{name} not in {ver}/kernel.sym")
        out[name] = int(m.group(2), 16)
    return out


def assemble(syms):
    """{section: (bank, addr, bytes)}"""
    defs = [f"-D{k}=${v:04x}" for k, v in syms.items()]
    with tempfile.TemporaryDirectory() as tmp:
        obj, rom, mapf = (os.path.join(tmp, n) for n in ("s.o", "s.gb", "s.map"))
        subprocess.run(["rgbasm", *defs, "-o", obj, ASM], check=True)
        subprocess.run(["rgblink", "-p", "0xff", "-m", mapf, "-o", rom, obj], check=True)
        data = open(rom, "rb").read()
        maptxt = open(mapf).read()
    out = {}
    bank = 0
    for line in maptxt.splitlines():
        b = re.match(r"ROM(?:0|X) bank #(\d+):", line)
        if b:
            bank = int(b.group(1))
        m = re.search(r"SECTION: \$([0-9a-fA-F]+)-\$[0-9a-fA-F]+ \(\$([0-9a-fA-F]+) bytes?\) \[\"(\w+)\"\]", line)
        if m:
            start, size = int(m.group(1), 16), int(m.group(2), 16)
            off = offset(bank, start)
            out[m.group(3)] = (bank, start, data[off:off + size])
    return out


def tool(*args):
    subprocess.run([sys.executable, os.path.join(TOOLS, args[0]), *args[1:]], check=True, cwd=os.path.join(ROOT, "kernel"))


def offset(bank, addr):
    return addr if bank == 0 else bank * 0x4000 + addr - 0x4000


def put_block(ver, bank, addr, name, data, apply):
    """inject_bytes.py for a new block; an existing one is overwritten in
    place (the rest of a longer old block goes back to stock) and its
    kernel.sym length updated."""
    vdir = os.path.join(ROOT, "re", "kernel", ver)
    sym_path = os.path.join(vdir, "kernel.sym")
    sym = open(sym_path).read()
    key = f"{bank:02x}:{addr:04x}"
    m = re.search(rf"^{key} {name}\n{key} \.data:([0-9a-f]+):(\d+)$", sym, re.M)
    if not m:
        tool("inject_bytes.py", ver, str(bank), f"{addr:04x}", name, data.hex(), *apply)
        return
    old_len = int(m.group(1), 16)
    rom = open(os.path.join(vdir, "kernel.gb"), "rb").read()
    stock = open(os.path.join(vdir, "kernel.gb.orig"), "rb").read()
    off = offset(bank, addr)
    n = max(old_len, len(data))
    new = data + stock[off + len(data):off + n]
    if rom[off:off + n] != new:
        tool("patch_bytes.py", ver, str(bank), f"{addr:04x}", rom[off:off + n].hex(), new.hex(), *apply)
    else:
        print(f"{key} {name}: unchanged")
    if apply and old_len != len(data):
        sym = sym[:m.start(1)] + f"{len(data):x}" + sym[m.end(1):]
        open(sym_path, "w").write(sym)
        print(f"{key} {name}: kernel.sym length {old_len} -> {len(data)}")


def drop_block(ver, bank, addr, name, apply):
    """Put an injected block back to stock bytes and remove it from kernel.sym."""
    vdir = os.path.join(ROOT, "re", "kernel", ver)
    sym_path = os.path.join(vdir, "kernel.sym")
    sym = open(sym_path).read()
    key = f"{bank:02x}:{addr:04x}"
    m = re.search(rf"^{key} {name}\n{key} \.data:([0-9a-f]+):(\d+)\n", sym, re.M)
    if not m:
        return
    n = int(m.group(1), 16)
    off = offset(bank, addr)
    rom = open(os.path.join(vdir, "kernel.gb"), "rb").read()
    stock = open(os.path.join(vdir, "kernel.gb.orig"), "rb").read()
    tool("patch_bytes.py", ver, str(bank), f"{addr:04x}", rom[off:off + n].hex(), stock[off:off + n].hex(), *apply)
    if apply:
        open(sym_path, "w").write(sym[:m.start()] + sym[m.end():])
        print(f"{key} {name}: removed from kernel.sym")


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    ver = sys.argv[1]
    apply = ["--apply"] if "--apply" in sys.argv[2:] else []
    syms = kernel_syms(ver)
    secs = assemble(syms)
    names = {"SgbStub": "SgbStub", "SgbVblTail": "SgbVblTail", "SgbVblList": "SgbVblList",
             "SgbPadGate": "SgbPadGate", "SgbBootHook": "SgbBootHook", "SgbBank4": "SgbLaunchHook"}
    drop_block(ver, 1, 0x7f00, "SgbUnlock", apply)
    if not apply and "SgbUnlock" in open(os.path.join(ROOT, "re", "kernel", ver, "kernel.sym")).read():
        print("(dry run: SgbUnlock still in place, so the 01:7f00 fit check below fails)")
    for sec, name in names.items():
        bank, addr, data = secs[sec]
        put_block(ver, bank, addr, name, data, apply)

    def hook(bank, addr, old, new):
        tool("patch_bytes.py", ver, str(bank), f"{addr:04x}", old.hex(), new.hex(), *apply)

    le = lambda a: bytes([a & 0xff, a >> 8])
    tail, lst = secs["SgbVblTail"][1], secs["SgbVblList"][1]
    hook(0, 0x0040, b"\xe5\x21" + le(syms["wVBlankCallbacks"]) + b"\xc3" + le(syms["RunCallbackList"])[:1],   # 6 bytes; $0046 stays
         b"\xcd" + le(lst) + b"\xc3" + le(tail))
    hook(0, 0x01ba, b"\xcd" + le(syms["CgbInit"]), b"\xcd" + le(secs["SgbBootHook"][1]))
    hook(0, syms["ReadJoypadRaw"], b"\xc5\x3e\x20", b"\xc3" + le(secs["SgbPadGate"][1]))
    hook(4, syms["RomLoad_CopyCmdWindowPoll_B4"], b"\x3e\x01\xf5", b"\xc3" + le(secs["SgbBank4"][1]))
    tool("patch_bytes.py", ver, "0", "0100", "00c35001", "00c32000", *apply)
    tool("patch_bytes.py", ver, "0", "0146", "00", "03", *apply)
    tool("patch_bytes.py", ver, "0", "014b", "00", "33", *apply)
    rom = open(os.path.join(ROOT, "re","kernel", ver, "kernel.gb"), "rb").read()
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
