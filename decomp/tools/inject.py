#!/usr/bin/env python3
"""
Compile a C file with SDCC and inject the resulting machine code into the
disassembly build at a fixed address, as a named `.data:` block in
kernel.sym.

Unlike verify.py (which links at an arbitrary placeholder address just to
diff bytes against something that already exists), inject.py links at the
REAL final ROM address you give it. That matters: any internal absolute
jp/call the compiled function makes to itself is encoded for wherever the
linker put it, so if that isn't the real address the injected code will
silently jump to the wrong place once embedded.

The injected bytes are recorded as `bank:addr .data:LEN:WIDTH` (same
directive mgbdis uses for tables/reserved space) rather than as normal
disassembled instructions — this is opaque, C-compiled machine code, not
something meant to be hand-edited as asm here. The name you give it is a
completely ordinary kernel.sym label, so existing asm (and other injected C)
can `call` it normally.

Usage:
    inject.py <file.c> <version> <bank> <address_hex> <name>
              [--peep peep_file] [--pin SYM=ADDR ...] [--pins pins_file]
              [--apply] [--regen]

Examples:
    # Dry run: compile, show bytes, do not touch kernel.sym.
    inject.py src/fastlaunch_hook.c 1.05e 8 476b FastLaunchHook

    # Write into kernel.sym and regenerate the disassembly.
    inject.py src/fastlaunch_hook.c 1.05e 8 476b FastLaunchHook \\
        --pin DrawString=0e0e --apply --regen

Pins work exactly as in verify.py: declare `extern` in the C file, pass
`--pin name=addr` (or a `--pins` file) for every existing kernel function or
WRAM location referenced. See verify.py's docstring for the pins file format.
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sdcc_build import (  # noqa: E402
    compile_c,
    load_pins_file,
    parse_ihx,
    parse_pin,
    resolve_peep as _resolve_peep,
    resolve_pins_file as _resolve_pins_file,
    rom_offset,
)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))

NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def resolve_peep(peep_arg):
    return _resolve_peep(peep_arg, TOOLS_DIR, REPO_ROOT)


def resolve_pins_file(path):
    return _resolve_pins_file(path, TOOLS_DIR, REPO_ROOT)


def kernel_sym_path(version):
    return os.path.join(REPO_ROOT, "re", version, "kernel.sym")


def kernel_gb_path(version):
    return os.path.join(REPO_ROOT, "re", version, "kernel.gb")


def patch_kernel_gb(gb_path, offset, code_bytes):
    """Overwrite code_bytes into kernel.gb at offset, in place.

    kernel.gb is the ROM mgbdis actually disassembles — a kernel.sym label
    plus a .data: directive only changes how existing bytes are *displayed*,
    it never changes what's in the ROM. Actually injecting new behavior
    means the ROM's bytes themselves have to change here.

    kernel.gb is the user's only local copy of the firmware (gitignored,
    not re-derivable from this repo), so the first-ever patch makes a
    kernel.gb.orig backup alongside it if one doesn't already exist, so the
    pristine dump can always be restored for future decomp/verify.py work
    against the original.
    """
    orig_path = gb_path + ".orig"
    if not os.path.exists(orig_path):
        import shutil
        shutil.copy2(gb_path, orig_path)
        print(f"backed up pristine ROM to {orig_path}")

    with open(gb_path, "rb") as f:
        rom = bytearray(f.read())
    if offset + len(code_bytes) > len(rom):
        print(f"error: patch range (offset ${offset:x}, {len(code_bytes)} bytes) "
              f"runs past end of {gb_path} (${len(rom):x} bytes)")
        sys.exit(1)
    rom[offset:offset + len(code_bytes)] = code_bytes
    with open(gb_path, "wb") as f:
        f.write(rom)


def extract_code_bytes(compiled, code_origin):
    """Contiguous run of bytes starting at code_origin. Warn about anything
    the compile emitted outside that range (e.g. _DATA globals — those can't
    be injected as ROM bytes without a crt0 to copy them at boot, which this
    build doesn't have; avoid initialized statics in injected C)."""
    if code_origin not in compiled:
        print(f"error: nothing compiled at the code origin ${code_origin:04x}")
        sys.exit(1)
    out = bytearray()
    addr = code_origin
    while addr in compiled:
        out.append(compiled[addr])
        addr += 1
    stray = sorted(a for a in compiled if a < code_origin or a >= addr)
    if stray:
        lo, hi = min(stray), max(stray)
        print(f"warning: {len(stray)} byte(s) compiled outside the code range, "
              f"at ${lo:04x}..${hi:04x} (likely _DATA globals) — NOT injected. "
              f"Injected C can't rely on initialized statics; use stack locals "
              f"or explicit runtime init instead.")
    return bytes(out)


def build_arg_parser():
    p = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("c_file", help="C source to compile")
    p.add_argument("version", choices=("1.04e", "1.05e"), help="kernel version")
    p.add_argument("bank", type=int, help="ROM bank number")
    p.add_argument("address", help="target address within bank (hex, e.g. 476b or 0x476b)")
    p.add_argument("name", help="kernel.sym label for the injected function")
    p.add_argument("--peep", dest="peep_opt", default=None, help="peephole definition file")
    p.add_argument(
        "--pin", action="append", default=[], metavar="SYM=ADDR",
        help="pin extern symbol to absolute addr (repeatable)",
    )
    p.add_argument(
        "--pins", dest="pins_file", default=None,
        help="file of SYM=ADDR / 'SYM ADDR' pins (one per line)",
    )
    p.add_argument(
        "--width", type=int, default=8,
        help="bytes per .data display line in the generated asm (default 8)",
    )
    p.add_argument("--apply", action="store_true", help="write into kernel.sym (default: dry run)")
    p.add_argument("--regen", action="store_true", help="also run regen-disasm.sh after --apply")
    return p


def main():
    args = build_arg_parser().parse_args()

    if not NAME_RE.match(args.name):
        print(f"error: {args.name!r} is not a valid asm label")
        sys.exit(1)

    peep_path = resolve_peep(args.peep_opt)

    pins = []
    explicit_pin_syms = set()
    if args.pins_file:
        pins.extend(load_pins_file(resolve_pins_file(args.pins_file)))
    for spec in args.pin:
        try:
            pin = parse_pin(spec)
        except ValueError as e:
            print(f"error: --pin: {e}")
            sys.exit(1)
        if pin:
            pins.append(pin)
            explicit_pin_syms.add(pin[0])
    pin_map = {}
    for sym, addr in pins:
        pin_map[sym] = addr
    pins = list(pin_map.items())

    bank = args.bank
    address = int(args.address.lower().removeprefix("0x").removeprefix("$"), 16)
    if bank == 0:
        code_origin = address
        if not (0x0000 <= address <= 0x3fff):
            print(f"error: bank 0 address ${address:04x} outside $0000-$3fff")
            sys.exit(1)
    else:
        code_origin = address
        if not (0x4000 <= address <= 0x7fff):
            print(f"error: bank {bank} address ${address:04x} outside $4000-$7fff "
                  f"(ROMX window — this is a CPU address, not a flat file offset)")
            sys.exit(1)

    c_path = os.path.abspath(args.c_file)
    sym_path = kernel_sym_path(args.version)
    if not os.path.exists(sym_path):
        print(f"error: {sym_path} not found")
        sys.exit(1)

    with tempfile.TemporaryDirectory() as workdir:
        ihx_path, applied = compile_c(
            c_path, workdir,
            peep_path=peep_path, pins=pins, explicit_pin_syms=explicit_pin_syms,
            code_origin=code_origin,
        )
        compiled = parse_ihx(ihx_path)

    code_bytes = extract_code_bytes(compiled, code_origin)

    if applied:
        pin_s = ", ".join(f"{s}=${a:04x}" for s, a in applied)
        print(f"Pins: {pin_s}")
    print(f"Compiled: {len(code_bytes)} bytes -> {code_bytes.hex()}")
    print(f"Target: {args.version} bank {bank} @ ${address:04x} as {args.name!r}")

    existing = open(sym_path, encoding="utf-8").read()
    key = f"{bank:02x}:{address:04x}"
    if re.search(rf"^{re.escape(key)}\s", existing, re.MULTILINE):
        print(f"error: {key} already has a kernel.sym entry — pick a different address "
              f"or remove the existing one first (inject.py never overwrites in place)")
        sys.exit(1)

    new_lines = [
        f"{key} {args.name}",
        f"{key} .data:{len(code_bytes):x}:{args.width}",
    ]

    if not args.apply:
        print("\n(dry run — pass --apply to patch kernel.gb + write kernel.sym)")
        print("\n".join(new_lines))
        return

    gb_path = kernel_gb_path(args.version)
    if not os.path.exists(gb_path):
        print(f"error: {gb_path} not found")
        sys.exit(1)
    offset = rom_offset(bank, address)
    patch_kernel_gb(gb_path, offset, code_bytes)
    print(f"patched {gb_path} at file offset ${offset:x} ({len(code_bytes)} bytes)")

    text = existing
    if not text.endswith("\n"):
        text += "\n"
    text += "\n".join(new_lines) + "\n"
    with open(sym_path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"\nwrote {sym_path}:")
    print("\n".join(new_lines))

    if args.regen:
        regen = os.path.join(REPO_ROOT, "scripts", "regen-disasm.sh")
        print(f"\nrunning {regen} {args.version} ...")
        result = subprocess.run([regen, args.version], cwd=REPO_ROOT)
        if result.returncode != 0:
            print("error: regen-disasm.sh failed")
            sys.exit(1)


if __name__ == "__main__":
    main()
