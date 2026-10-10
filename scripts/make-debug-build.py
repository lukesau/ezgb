#!/usr/bin/env python3
"""Build a debug kernel: the mod build plus the debug screen (docs/debug-tab.md).

Release kernels leave the debug screen out. This takes re/kernel/<ver>/kernel.gb (the
mod build, untouched) and writes a copy with:

  bank 4      DebugTab (kernel/src/debug_tab.c), compiled for this build
  bank 0      DbgTabHook: Delay, DrawMenuTabs(3) (clear the pane, keep the
              strip), far-call DebugTab, Delay, back to the browser
  site        HELP's exit (`ld hl,$0032; push hl; call Delay; add sp,2;
              jp FileBrowserEntry`, 00:1288 in 1.05e) -> jp DbgTabHook
  HELP text   "MOD N.M" -> "MOD N.MDBG"

so SELECT on HELP opens the debug screen and SELECT there goes to the
browser. Addresses are written for 1.05e-0731 and carried to other builds
through scripts/portmap.py, the same matching port-mod.py uses; the site's
bytes are checked before anything is written.

Usage:
  scripts/make-debug-build.py <ver> [--install DIR]
    -> dist/debug/ezgb-mod-N.M-debug-for-<ver>.dat (and DIR/ezgb.dat)
"""
import argparse
import hashlib
import os
import shutil
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts"))
sys.path.insert(0, os.path.join(ROOT, "kernel", "tools"))
from portmap import PortMap, load_stock  # noqa: E402
from sdcc_build import compile_c, parse_ihx  # noqa: E402

BANK = 0x4000
REF = "1.05e-0731"
# (bank, address) in REF
ADDR = {
    "SetFpgaPage_B4": (4, 0x466e),
    "DrawString": (0, 0x08b7),
    "StoreDrawParams": (0, 0x2791),
    "ReadJoypad": (0, 0x3a4a),
    "WaitVBlankFlag": (0, 0x0688),
    "Delay": (0, 0x3a93),
    "FarCallTrampoline": (0, 0x078d),
    "FileBrowserEntry": (0, 0x0f8d),
    "DrawMenuTabs": (8, 0x7169),
    "HelpExit": (0, 0x1288),
}
MODSTR = (8, 0x7aff)
DEBUG_AT = (4, 0x7400)      # preferred; any free run in bank 4 will do
HOOK_LEN = 41


def off(bank, addr):
    return addr if bank == 0 else bank * BANK + addr - BANK


def le(v):
    return bytes((v & 0xff, v >> 8))


def free_run(rom, bank, n, prefer=None, lo=None):
    base = bank * BANK
    if prefer is not None and all(b == 0xff for b in rom[off(bank, prefer):off(bank, prefer) + n]):
        return prefer
    start = (lo if lo is not None else (0 if bank == 0 else BANK))
    run = 0
    for a in range(start, BANK if bank == 0 else 2 * BANK):
        run = run + 1 if rom[off(bank, a)] == 0xff else 0
        if run == n + 2:            # one $FF either side
            return a - n
    sys.exit(f"error: no {n}-byte free run in bank {bank}")


def boot_a_addr(rom):
    """KernelEntry saves the boot A as `ld a, d; ld [nn], a` right after
    clearing HRAM; nn is $D6C9 in 1.05e and $D6A2 in 1.04e."""
    i = rom.find(b"\x7a\xea", 0x0150, 0x0200)
    if i < 0:
        sys.exit("error: KernelEntry's boot-A store not found")
    return rom[i + 2] | rom[i + 3] << 8


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("version")
    ap.add_argument("--install", metavar="DIR", help="also copy it to DIR/ezgb.dat (e.g. the SD card)")
    args = ap.parse_args()
    ver = args.version

    rom = bytearray(open(os.path.join(ROOT, "re","kernel", ver, "kernel.gb"), "rb").read())
    if ver == REF:
        a = {k: v[1] for k, v in ADDR.items()}
    else:
        pm = PortMap(load_stock(REF), load_stock(ver), cache_dir=os.path.join(tempfile.gettempdir(), "ezgb-portmap"))
        a = {}
        for k, (bank, addr) in ADDR.items():
            t = pm.map(bank, addr)
            if t is None:
                sys.exit(f"error: {k} ({bank:02x}:{addr:04x}) has no match in {ver}")
            a[k] = t

    site = off(0, a["HelpExit"])
    want = b"\x21\x32\x00\xe5\xcd" + le(a["Delay"]) + b"\xe8\x02\xc3" + le(a["FileBrowserEntry"])
    if rom[site:site + 12] != want:
        sys.exit(f"error: HELP exit at 00:{a['HelpExit']:04x} is {rom[site:site + 12].hex()}, "
                 f"expected {want.hex()} (already a debug build?)")

    # DebugTab, compiled where it will live
    pins = [("_" + k, a[k]) for k in ("SetFpgaPage_B4", "DrawString", "StoreDrawParams",
                                      "ReadJoypad", "WaitVBlankFlag")]
    pins.append(("_wBootA", boot_a_addr(rom)))
    src = os.path.join(ROOT, "kernel", "src", "debug_tab.c")
    def build(origin):
        with tempfile.TemporaryDirectory() as wd:
            ihx, _ = compile_c(src, wd, pins=pins, code_origin=origin)
            return parse_ihx(ihx)
    code = build(DEBUG_AT[1])
    size = max(code) - DEBUG_AT[1] + 1
    dbg = free_run(rom, 4, size, prefer=DEBUG_AT[1])
    if dbg != DEBUG_AT[1]:
        code = build(dbg)
    blob = bytes(code[dbg + i] for i in range(size))
    rom[off(4, dbg):off(4, dbg) + size] = blob

    # DbgTabHook in bank 0
    far = lambda target, bank: b"\xcd" + le(a["FarCallTrampoline"]) + le(target) + bytes((bank, 0))
    delay = b"\x21\x32\x00\xe5\xcd" + le(a["Delay"]) + b"\xe8\x02"
    hook = (delay + b"\x3e\x03\xf5\x33" + far(a["DrawMenuTabs"], 8) + b"\xe8\x01"
            + far(dbg, 4) + delay + b"\xc3" + le(a["FileBrowserEntry"]))
    assert len(hook) == HOOK_LEN, len(hook)
    cave = free_run(rom, 0, HOOK_LEN, prefer=0x0259, lo=0x0150)
    rom[cave:cave + HOOK_LEN] = hook
    rom[site:site + 12] = b"\xc3" + le(cave) + b"\x00" * 9

    # HELP: "MOD N.M" -> "MOD N.MDBG"
    m = off(*MODSTR)            # the same in every build (stamp-mod-version.sh)
    label = bytes(rom[m:m + 10]).rstrip()
    if not label.startswith(b"MOD "):
        sys.exit("error: no MOD string at 08:7aff")
    rom[m:m + 10] = (label + b"DBG").ljust(10)[:10]

    modver = open(os.path.join(ROOT, "patches", "kernel", "VERSION")).read().strip()
    out_dir = os.path.join(ROOT, "dist", "debug")
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, f"ezgb-mod-{modver}-debug-for-{ver}.dat")
    open(out, "wb").write(rom)
    print(f"{os.path.relpath(out, ROOT)}  md5 {hashlib.md5(rom).hexdigest()}")
    print(f"  DebugTab 04:{dbg:04x} ({size} B), DbgTabHook 00:{cave:04x}, "
          f"HELP exit 00:{a['HelpExit']:04x}, boot A at ${boot_a_addr(rom):04x}")
    if args.install:
        dst = os.path.join(args.install, "ezgb.dat")
        shutil.copyfile(out, dst)
        print(f"  installed -> {dst}")


if __name__ == "__main__":
    main()
