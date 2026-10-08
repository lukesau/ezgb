#!/usr/bin/env python3
"""Build the SGB variant of the current mod release (proof of concept).

Takes each re/<ver>/kernel.gb (checked against the manifest's patched_md5),
splices in scripts/sgb/sgb_boot.asm, and writes

  dist/mod-N.M-sgb/ezgb-mod-N.M-sgb-for-<ver>.dat
  dist/mod-N.M-sgb/ezgb-mod-N.M-sgb-for-<ver>.ips   (against the stock dump)

The variant always sends the SGB header packets at boot (~6.7 s on every
model); there is no setting yet. Changes on top of the mod:
  $0100        jp SgbStub ($0020) instead of jp KernelEntry
  $0020        9-byte stub: push af, map bank 1, jp SgbUnlock
  01:7f00      SgbUnlock and helpers
  $0146/$014B  SGB flag $03, old licensee $33 (both required by the SGB)
  $014D-$014F  header and global checksums recomputed
  08:7aff      HELP string "MOD N.MSGB"

Usage: scripts/make-sgb-dist.py
"""
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from importlib import import_module

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts"))
kp = import_module("kernel-patch")

ASM = os.path.join(ROOT, "scripts", "sgb", "sgb_boot.asm")
MODSTR = 8 * 0x4000 + (0x7AFF - 0x4000)


def assemble():
    """Returns {section name: (rom file offset, bytes)} and the symbol table."""
    with tempfile.TemporaryDirectory() as tmp:
        obj, rom, mapf, sym = (os.path.join(tmp, n) for n in ("s.o", "s.gb", "s.map", "s.sym"))
        subprocess.run(["rgbasm", "-o", obj, ASM], check=True)
        subprocess.run(["rgblink", "-p", "0xff", "-m", mapf, "-n", sym, "-o", rom, obj], check=True)
        data = open(rom, "rb").read()
        maptxt = open(mapf).read()
        symtxt = open(sym).read()
    sections = {}
    bank = 0
    for line in maptxt.splitlines():
        m = re.match(r"ROMX? bank #(\d+):", line.strip())
        if m:
            bank = int(m.group(1))
            continue
        m = re.search(r"SECTION: \$([0-9a-fA-F]+)-\$([0-9a-fA-F]+) \(\$([0-9a-fA-F]+) bytes?\) \[\"(\w+)\"\]", line)
        if m:
            start, size, name = int(m.group(1), 16), int(m.group(3), 16), m.group(4)
            off = start if start < 0x4000 else bank * 0x4000 + start - 0x4000
            sections[name] = (off, data[off:off + size])
    syms = {}
    for line in symtxt.splitlines():
        m = re.match(r"([0-9a-fA-F]+):([0-9a-fA-F]+) (\w+)$", line)
        if m:
            syms[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
    return sections, syms


def fix_checksums(rom):
    c = 0
    for b in rom[0x134:0x14D]:
        c = (c - b - 1) & 0xFF
    rom[0x14D] = c
    g = (sum(rom) - rom[0x14E] - rom[0x14F]) & 0xFFFF
    rom[0x14E], rom[0x14F] = g >> 8, g & 0xFF


def main():
    modver = open(os.path.join(ROOT, "patches", "kernel", "VERSION")).read().strip()
    manifest = json.load(open(os.path.join(ROOT, "patches", "kernel", "manifest.json")))
    sections, syms = assemble()
    assert syms["SgbStub"] == (0, 0x0020), syms["SgbStub"]
    label = ("MOD " + modver + "SGB").ljust(10)[:10].encode("ascii")

    out = os.path.join(ROOT, "dist", f"mod-{modver}-sgb")
    os.makedirs(out, exist_ok=True)
    rows = []
    for v, e in sorted(manifest.items()):
        rom = bytearray(open(os.path.join(ROOT, "re", v, "kernel.gb"), "rb").read())
        if hashlib.md5(rom).hexdigest() != e["patched_md5"]:
            sys.exit(f"error: re/{v}/kernel.gb is not the mod {modver} build in the manifest")
        if rom[0x100:0x104] != b"\x00\xc3\x50\x01":
            sys.exit(f"error: {v}: unexpected entry at $0100: {rom[0x100:0x104].hex()}")
        for name, (off, blob) in sections.items():
            if set(rom[off:off + len(blob)]) != {0xFF}:
                sys.exit(f"error: {v}: {name} target at file ${off:05x} is not free")
            rom[off:off + len(blob)] = blob
        rom[0x100:0x104] = b"\x00\xc3\x20\x00"
        rom[0x146] = 0x03
        rom[0x14B] = 0x33
        rom[MODSTR:MODSTR + 10] = label
        fix_checksums(rom)

        stock = open(os.path.join(ROOT, "re", v, "kernel.gb.orig"), "rb").read()
        base = f"ezgb-mod-{modver}-sgb-for-{v}"
        dat, ips = os.path.join(out, base + ".dat"), os.path.join(out, base + ".ips")
        open(dat, "wb").write(rom)
        kp.write_ips(kp.diff_runs(stock, rom), rom, ips)
        if kp.apply_ips(stock, open(ips, "rb").read()) != bytes(rom):
            sys.exit(f"error: {v}: ips does not reproduce the dat")
        print(f"{v}: {base}.dat md5 {hashlib.md5(rom).hexdigest()}")
        rows.append(f"  {v}\n    stock md5:   {e['stock_md5']}\n    patched md5: {hashlib.md5(rom).hexdigest()}")
    open(os.path.join(out, "README.txt"), "w", newline="\r\n").write(README.format(
        modver=modver, table="\n\n".join(rows)))
    for name, (off, blob) in sections.items():
        print(f"  {name}: file ${off:05x}, {len(blob)} bytes")


README = """EZ Flash Jr modded kernel, mod {modver}-SGB (test build)
=====================================================

Mod {modver} plus a Super Game Boy unlock at boot, based on nitro2k01's SGB
Enabler for kernel 1.04e (2021): https://blog.gg8.se/wordpress/2021/08/19/nitro2k01s-sgb-enabler-for-ez-flash-jr/
The Jr holds the Game Boy CPU in reset while its FPGA loads, so the SNES never
receives the cartridge header and the SGB stays on a black screen. This build
sends the header itself at power-on, with the same timing as the Enabler.

Untested on real hardware: I don't have a Super Game Boy. It has only been
checked in an emulator. A cart on FW4 firmware with the 1.04e build matches
what the Enabler was tested on and is the only setup expected to work. FW5
and the 1.05e builds are unknown, so please give them a try too.

It always sends the header, on every model, which adds about 7 seconds to
every boot on a DMG/GBC/GBA. The HELP tab shows "MOD {modver}SGB" and the
firmware version. Please report the firmware, the kernel build, which SGB
(SGB/SGB2, NTSC/PAL), whether the menu shows up, and whether games get
borders and colors after launching.

Apply the matching .ips to the stock ezgb.dat from EZ Flash's firmware package,
then copy the result to the card root as ezgb.dat:

{table}
"""


if __name__ == "__main__":
    main()
