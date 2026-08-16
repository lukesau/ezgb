#!/usr/bin/env python3
"""
Compile a single C file with SDCC (sm83 target, legacy stack calling convention)
and check whether the resulting machine code is byte-identical to a given
address in one of the real kernel ROMs.

This is the core verification loop for the matching decompilation project:
write C, run this, get a yes/no plus a byte diff if it doesn't match yet.

Usage:
    verify.py <file.c> <version:1.04e|1.05e> <bank> <address_hex>
              [--peep peep_file] [--pin SYM=ADDR ...] [--pins pins_file]

Examples:
    verify.py src/misc.c 1.05e 0 1a77
    verify.py src/store_d732_d733.c 1.05e 0 2765 --peep tools/peeps/abs_pair_store.def
    verify.py src/register_callback_slots.c 1.05e 0 062e \\
        --pin install_callback_slot=066c

Callee pins: declare `extern void foo(void);` (or the real prototype) in the C
file and pass `--pin foo=066c` (or a `--pins` file). verify compiles to a .rel,
keeps only pins that the object actually references (sdld errors on unused -g
defs), then links with `-g_foo=0x066c` so `call`/`jp` encode the kernel address.
Symbol names get a leading `_` if missing (SDCC's C name mangling).

Pins file format (one per line, `#` comments):
    install_callback_slot 066c
    lcd_off=069f
"""
import argparse
import os
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
)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))


def kernel_path(version):
    return os.path.join(REPO_ROOT, "re", version, "kernel.gb")


def rom_offset(bank, address):
    if bank == 0:
        return address
    return bank * 0x4000 + (address - 0x4000)


def resolve_peep(peep_arg):
    return _resolve_peep(peep_arg, TOOLS_DIR, REPO_ROOT)


def resolve_pins_file(path):
    return _resolve_pins_file(path, TOOLS_DIR, REPO_ROOT)


def build_arg_parser():
    p = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("c_file", help="C source to compile")
    p.add_argument("version", choices=("1.04e", "1.05e"), help="kernel version")
    p.add_argument("bank", type=int, help="ROM bank number")
    p.add_argument("address", help="address within bank (hex, e.g. 1a77 or 0x1a77)")
    p.add_argument(
        "peep_positional",
        nargs="?",
        default=None,
        help="optional peep file (legacy 5th positional arg)",
    )
    p.add_argument("--peep", dest="peep_opt", default=None, help="peephole definition file")
    p.add_argument(
        "--pin",
        action="append",
        default=[],
        metavar="SYM=ADDR",
        help="pin extern symbol to absolute addr (repeatable)",
    )
    p.add_argument(
        "--pins",
        dest="pins_file",
        default=None,
        help="file of SYM=ADDR / 'SYM ADDR' pins (one per line)",
    )
    return p


def main():
    args = build_arg_parser().parse_args()

    peep_arg = args.peep_opt or args.peep_positional
    peep_path = resolve_peep(peep_arg)

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

    # Last pin for a symbol wins if duplicated.
    pin_map = {}
    for sym, addr in pins:
        pin_map[sym] = addr
    pins = list(pin_map.items())

    bank = args.bank
    address = int(args.address.lower().removeprefix("0x").removeprefix("$"), 16)
    c_path = os.path.abspath(args.c_file)

    kpath = kernel_path(args.version)
    if not os.path.exists(kpath):
        print(f"error: {kpath} not found. This project doesn't track the firmware "
              f"binaries (see .gitignore), you need your own local copy.")
        sys.exit(1)

    with tempfile.TemporaryDirectory() as workdir:
        ihx_path, applied = compile_c(
            c_path,
            workdir,
            peep_path=peep_path,
            pins=pins,
            explicit_pin_syms=explicit_pin_syms,
        )
        compiled = parse_ihx(ihx_path)

    if not compiled:
        print("error: compiled output is empty")
        sys.exit(1)

    lo, hi = min(compiled), max(compiled)
    compiled_bytes = bytes(compiled.get(a, 0xFF) for a in range(lo, hi + 1))

    with open(kpath, "rb") as f:
        rom = f.read()

    offset = rom_offset(bank, address)
    rom_bytes = rom[offset:offset + len(compiled_bytes)]

    if applied:
        pin_s = ", ".join(f"{s}=${a:04x}" for s, a in applied)
        print(f"Pins: {pin_s}")
    print(f"Compiled: {len(compiled_bytes)} bytes -> {compiled_bytes.hex()}")
    print(f"ROM[{args.version} bank {bank} @ ${address:04x}]: {rom_bytes.hex()}")

    if compiled_bytes == rom_bytes:
        print("MATCH")
        sys.exit(0)
    else:
        print("MISMATCH")
        for i, (c, r) in enumerate(zip(compiled_bytes, rom_bytes)):
            if c != r:
                print(f"  byte {i} (${address+i:04x}): compiled={c:02x} rom={r:02x}")
        if len(compiled_bytes) != len(rom_bytes):
            print(f"  length: compiled={len(compiled_bytes)} rom_slice={len(rom_bytes)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
