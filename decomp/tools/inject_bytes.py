#!/usr/bin/env python3
"""
Patch raw, already-assembled bytes into kernel.gb at a fixed address and
label them in kernel.sym — the non-C counterpart to inject.py, for
hand-written asm (e.g. FarCallTrampoline shims, which SDCC/C has no way to
express: the trampoline's calling convention embeds raw target bytes
directly after the `call`, not something a C extern/pin can produce).

Usage:
    inject_bytes.py <version> <bank> <address_hex> <name> <hex_bytes>
                    [--apply] [--regen]

Example (see decomp/src/shims.md for how these bytes were derived):
    inject_bytes.py 1.05e-0731 8 4772 FarCallOpendir_B5 \\
        f8042a666fe5f8042a666fe5cd8d07dd730500e804c9 --apply --regen
"""
import argparse
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sdcc_build import rom_offset  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def kernel_gb_path(version):
    return os.path.join(REPO_ROOT, "re", version, "kernel.gb")


def kernel_sym_path(version):
    return os.path.join(REPO_ROOT, "re", version, "kernel.sym")


def patch_kernel_gb(gb_path, offset, code_bytes):
    orig_path = gb_path + ".orig"
    if not os.path.exists(orig_path):
        import shutil
        shutil.copy2(gb_path, orig_path)
        print(f"backed up pristine ROM to {orig_path}")
    with open(gb_path, "rb") as f:
        rom = bytearray(f.read())
    if offset + len(code_bytes) > len(rom):
        print(f"error: patch range runs past end of {gb_path}")
        sys.exit(1)
    rom[offset:offset + len(code_bytes)] = code_bytes
    with open(gb_path, "wb") as f:
        f.write(rom)


def build_arg_parser():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("version", choices=("1.04e", "1.05e-0731", "1.05e-0918"))
    p.add_argument("bank", type=int)
    p.add_argument("address", help="hex address")
    p.add_argument("name", help="kernel.sym label")
    p.add_argument("hex_bytes", help="the bytes to write, as hex (no spaces)")
    p.add_argument("--width", type=int, default=8)
    p.add_argument("--apply", action="store_true")
    p.add_argument("--regen", action="store_true")
    return p


def main():
    args = build_arg_parser().parse_args()
    if not NAME_RE.match(args.name):
        print(f"error: {args.name!r} is not a valid asm label")
        sys.exit(1)

    address = int(args.address.lower().removeprefix("0x").removeprefix("$"), 16)
    code_bytes = bytes.fromhex(args.hex_bytes)
    bank = args.bank

    sym_path = kernel_sym_path(args.version)
    existing = open(sym_path, encoding="utf-8").read()
    key = f"{bank:02x}:{address:04x}"
    if re.search(rf"^{re.escape(key)}\s", existing, re.MULTILINE):
        print(f"error: {key} already has a kernel.sym entry")
        sys.exit(1)

    print(f"Target: {args.version} bank {bank} @ ${address:04x} as {args.name!r}")
    print(f"Bytes ({len(code_bytes)}): {code_bytes.hex()}")

    new_lines = [
        f"{key} {args.name}",
        f"{key} .data:{len(code_bytes):x}:{args.width}",
    ]
    if not args.apply:
        print("\n(dry run — pass --apply to patch kernel.gb + write kernel.sym)")
        print("\n".join(new_lines))
        return

    gb_path = kernel_gb_path(args.version)
    offset = rom_offset(bank, address)
    patch_kernel_gb(gb_path, offset, code_bytes)
    print(f"patched {gb_path} at file offset ${offset:x}")

    text = existing if existing.endswith("\n") else existing + "\n"
    text += "\n".join(new_lines) + "\n"
    with open(sym_path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"\nwrote {sym_path}:\n" + "\n".join(new_lines))

    if args.regen:
        regen = os.path.join(REPO_ROOT, "scripts", "regen-disasm.sh")
        print(f"\nrunning {regen} {args.version} ...")
        result = subprocess.run([regen, args.version], cwd=REPO_ROOT)
        if result.returncode != 0:
            print("error: regen-disasm.sh failed")
            sys.exit(1)


if __name__ == "__main__":
    main()
