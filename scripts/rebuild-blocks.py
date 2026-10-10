#!/usr/bin/env python3
"""Recompile every injected C block and bring the development kernel up to date.

The C blocks, their addresses and their pins are listed once, in
scripts/port-mod.py's REGISTRY; block names and lengths come from
re/kernel/<ver>/kernel.sym. This compiles each source at its address and compares the
result with the bytes in re/kernel/<ver>/kernel.gb:

    scripts/rebuild-blocks.py              # report; exit 1 if any block is stale
    scripts/rebuild-blocks.py --apply      # re-inject the stale ones in place

--apply runs kernel/tools/inject.py --replace for each stale block, so every
rebuild gets the same fit check (no overlap with another kernel.sym entry, new
bytes only in $FF free space) and kernel.sym length update. Run it before
porting: a C edit that was never injected is otherwise invisible until a
release is cut from the old bytes.

Only the development base (1.05e-0731) is rebuilt here; port-mod.py carries
the result to the other kernels.
"""
import argparse
import contextlib
import io
import importlib.util
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "kernel", "tools"))
from sdcc_build import compile_c, parse_ihx, rom_offset  # noqa: E402

spec = importlib.util.spec_from_file_location("port_mod", os.path.join(ROOT, "scripts", "port-mod.py"))
port_mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(port_mod)


def compile_block(src, bank, addr, pins):
    pin_list = [(s if s.startswith("_") else "_" + s, a) for s, a in pins.items()]
    with tempfile.TemporaryDirectory() as wd, contextlib.redirect_stdout(io.StringIO()):
        ihx, _ = compile_c(os.path.join(port_mod.SRC, src), wd, pins=pin_list, code_origin=addr)
        compiled = parse_ihx(ihx)
    out = bytearray()
    a = addr
    while a in compiled:
        out.append(compiled[a])
        a += 1
    return bytes(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--version", default="1.05e-0731", help="kernel to rebuild (default 1.05e-0731)")
    ap.add_argument("--apply", action="store_true", help="re-inject stale blocks with inject.py --replace")
    args = ap.parse_args()

    sym_path = os.path.join(ROOT, "re","kernel", args.version, "kernel.sym")
    rom = open(os.path.join(ROOT, "re","kernel", args.version, "kernel.gb"), "rb").read()
    blocks = {(b, a): (n, name) for b, a, n, name in port_mod.read_sym_blocks(sym_path)}

    stale = []
    for (bank, addr), entry in sorted(port_mod.REGISTRY.items()):
        if "src" not in entry:
            continue                                   # hand-assembled / data blocks
        key = f"{bank:02x}:{addr:04x}"
        if (bank, addr) not in blocks:
            sys.exit(f"error: REGISTRY block {key} ({entry['src']}) has no kernel.sym .data entry")
        length, name = blocks[(bank, addr)]
        new = compile_block(entry["src"], bank, addr, entry.get("pins", {}))
        o = rom_offset(bank, addr)
        if new == rom[o:o + length]:
            print(f"  ok     {key} {name:<26} {entry['src']} ({length} bytes)")
            continue
        print(f"  STALE  {key} {name:<26} {entry['src']} ({length} -> {len(new)} bytes)")
        stale.append((bank, addr, name, entry))

    if not stale:
        print("all C blocks match their sources")
        return
    if not args.apply:
        print(f"{len(stale)} stale block(s); rerun with --apply to re-inject")
        sys.exit(1)

    for bank, addr, name, entry in stale:
        cmd = [sys.executable, "tools/inject.py", f"src/{entry['src']}", args.version,
               str(bank), f"{addr:04x}", name, "--replace", "--apply"]
        for s, a in entry.get("pins", {}).items():
            cmd += ["--pin", f"{s}={a:04x}"]
        r = subprocess.run(cmd, cwd=os.path.join(ROOT, "kernel"), capture_output=True, text=True)
        report = [l for l in r.stdout.splitlines() if l.startswith(("Fits", "patched", "error"))]
        print(f"{name}:", *report, sep="\n  ")
        if r.returncode != 0:
            sys.exit(r.stderr.strip() or f"error: inject.py failed for {name}")
    print(f"re-injected {len(stale)} block(s) into re/{args.version}/kernel.gb")


if __name__ == "__main__":
    main()
