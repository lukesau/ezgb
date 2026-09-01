#!/usr/bin/env python3
"""
Overwrite an existing instruction sequence in kernel.gb with `call TARGET`
(or `jp TARGET`, with --jp) + nop padding, so an injected function actually
gets executed.

This is a raw binary patch of kernel.gb, separate from inject.py (which only
places new code in free space - it doesn't wire anything to call it). The
hook function at TARGET is responsible for replicating whatever original
instruction(s) got overwritten before doing its own work, if the original
behavior needs to be preserved (it usually does) - this tool does not try to
infer or replay that for you.

`call nn` / `jp nn` are both 3 bytes. If the patched region is longer than 3
bytes, the remainder is filled with `nop` (never fewer than 3 - that would
overwrite mid-instruction and corrupt whatever follows).

--jp writes `jp` instead of `call`: use it when the overwritten instruction
was itself a tail `jp`/`ret`, so the hook inherits the original function's
stack frame and its own `ret` becomes that function's return. A hook reached
by `jp` must be stack-neutral and must end in `ret`.

Usage:
    patch_call.py <version> <bank> <address_hex> <length> <target_bank:target_addr>
                  [--jp] [--apply] [--regen]

Example (see docs/inject-smoke-test.md for the paired injection):
    patch_call.py 1.05e-0731 8 7200 3 08:746b --jp --apply --regen
"""
import argparse
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sdcc_build import rom_offset  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def kernel_gb_path(version):
    return os.path.join(REPO_ROOT, "re", version, "kernel.gb")


def parse_hex(s):
    return int(s.lower().removeprefix("0x").removeprefix("$"), 16)


def parse_bank_addr(s):
    bank_s, addr_s = s.split(":")
    return int(bank_s, 16), parse_hex(addr_s)


def build_arg_parser():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("version", choices=("1.04e", "1.05e-0731", "1.05e-0918"))
    p.add_argument("bank", type=int, help="bank of the patch site")
    p.add_argument("address", help="patch site address (hex)")
    p.add_argument("length", type=int, help="bytes to overwrite (>= 3)")
    p.add_argument("target", help="call target as bank:addr, e.g. 00:476b")
    p.add_argument("--jp", action="store_true", help="write `jp` instead of `call`")
    p.add_argument("--apply", action="store_true", help="write into kernel.gb (default: dry run)")
    p.add_argument("--regen", action="store_true", help="also run regen-disasm.sh after --apply")
    return p


def main():
    args = build_arg_parser().parse_args()

    mnemonic = "jp" if args.jp else "call"
    if args.length < 3:
        print(f"error: length {args.length} < 3 - a {mnemonic} nn is 3 bytes, can't fit")
        sys.exit(1)

    address = parse_hex(args.address)
    target_bank, target_addr = parse_bank_addr(args.target)
    # call nn always encodes an absolute CPU address (the $4000-$7fff ROMX
    # window address, same convention as everywhere else in this repo) -
    # the CPU doesn't know or care which bank that resolves to; whichever
    # bank happens to be paged in when the call executes is what runs. If
    # the call site and the target aren't in the same bank (and the target
    # isn't bank 0, which is always mapped), this needs a real bank switch
    # or FarCallTrampoline, not a bare `call` - this tool doesn't do that.
    if target_bank != 0 and target_bank != args.bank:
        print(f"error: patch site is bank {args.bank}, target is bank {target_bank} - "
              f"a bare `{mnemonic}` can't cross ROMX banks (target isn't bank 0 either). "
              f"Use FarCallTrampoline for that, this tool only does same-bank/bank-0 calls.")
        sys.exit(1)

    opcode = 0xC3 if args.jp else 0xCD
    call_bytes = bytes([opcode, target_addr & 0xFF, (target_addr >> 8) & 0xFF])
    patch_bytes = call_bytes + bytes([0x00] * (args.length - 3))

    gb_path = kernel_gb_path(args.version)
    if not os.path.exists(gb_path):
        print(f"error: {gb_path} not found")
        sys.exit(1)
    offset = rom_offset(args.bank, address)

    with open(gb_path, "rb") as f:
        rom = bytearray(f.read())
    original = bytes(rom[offset:offset + args.length])

    print(f"Patch site: {args.version} bank {args.bank} @ ${address:04x}, {args.length} bytes")
    print(f"  original: {original.hex()}")
    print(f"  new:      {patch_bytes.hex()}  ({mnemonic} ${target_addr:04x}"
          + (", nop" * (args.length - 3)) + ")")

    if not args.apply:
        print("\n(dry run - pass --apply to write into kernel.gb)")
        return

    orig_path = gb_path + ".orig"
    if not os.path.exists(orig_path):
        import shutil
        shutil.copy2(gb_path, orig_path)
        print(f"backed up pristine ROM to {orig_path}")

    rom[offset:offset + args.length] = patch_bytes
    with open(gb_path, "wb") as f:
        f.write(rom)
    print(f"patched {gb_path} at file offset ${offset:x}")

    if args.regen:
        regen = os.path.join(REPO_ROOT, "scripts", "regen-disasm.sh")
        print(f"\nrunning {regen} {args.version} ...")
        result = subprocess.run([regen, args.version], cwd=REPO_ROOT)
        if result.returncode != 0:
            print("error: regen-disasm.sh failed")
            sys.exit(1)


if __name__ == "__main__":
    main()
