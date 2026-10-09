#!/usr/bin/env python3
"""Recursive-descent code trace of stage1 (32 KB, no MBC), for mgbdis.

    stage1-trace.py stage1.gb [--seed ADDR ...] [--report]

Follows jp/jr/call/rst from the header entry and the interrupt vectors
(plus any --seed), marks every byte reached as code, and prints:
  - call targets (function starts)
  - indirect jumps (jp hl) that need a manual --seed for their targets
  - the unreached spans, which become .data ranges in the sym file
"""
import argparse

LEN2 = {0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x36, 0x3E, 0x18, 0x20, 0x28, 0x30, 0x38,
        0xC6, 0xCE, 0xD6, 0xDE, 0xE6, 0xEE, 0xF6, 0xFE, 0xE0, 0xF0, 0xE8, 0xF8, 0x10, 0xCB}
LEN3 = {0x01, 0x11, 0x21, 0x31, 0x08, 0xC2, 0xC3, 0xCA, 0xD2, 0xDA,
        0xC4, 0xCC, 0xCD, 0xD4, 0xDC, 0xEA, 0xFA}
INVALID = {0xD3, 0xDB, 0xDD, 0xE3, 0xE4, 0xEB, 0xEC, 0xED, 0xF4, 0xFC, 0xFD}
JP = {0xC2, 0xC3, 0xCA, 0xD2, 0xDA}
CALL = {0xC4, 0xCC, 0xCD, 0xD4, 0xDC}
JR = {0x18, 0x20, 0x28, 0x30, 0x38}
END = {0xC3, 0x18, 0xC9, 0xD9, 0xE9}
# GBDK far call: call FarCallTrampoline / dw target / dw bank. Stage1 has
# no MBC, so the bank is ignored; the 4 inline bytes are data.
FARCALL = 0x058D


# header entry, interrupt vectors, and code only reached through pointers:
# the VBL/LCD/serial handlers crt0 installs, the OAM DMA stub source, the
# far-call return stub, the vblank/LCD callbacks of the console code
SEEDS = [0x100, 0x40, 0x48, 0x50, 0x58, 0x60,
         0x477, 0x4B6, 0x4C0, 0x5AE, 0x2931, 0x293C]


def oplen(op):
    return 3 if op in LEN3 else 2 if op in LEN2 else 1


def trace(rom, seeds, size=0x8000):
    code = {}          # addr -> instruction length (inline far-call args: 4)
    calls, jumps, indirect, bad = set(), set(), set(), set()
    work = list(seeds)
    while work:
        pc = work.pop()
        while 0 <= pc < size and pc not in code:
            op = rom[pc]
            if op in INVALID:
                bad.add(pc)
                break
            n = oplen(op)
            code[pc] = n
            if op in JP or op in CALL:
                t = rom[pc + 1] | rom[pc + 2] << 8
                if t < size:
                    work.append(t)
                    (calls if op in CALL else jumps).add(t)
                if op == 0xCD and t == FARCALL:
                    far = rom[pc + 3] | rom[pc + 4] << 8
                    work.append(far)
                    calls.add(far)
                    code[pc + 3] = 4
                    pc += 4
            elif op in JR:
                t = pc + 2 + (rom[pc + 1] ^ 0x80) - 0x80
                work.append(t)
                jumps.add(t)
            elif op & 0xC7 == 0xC7:  # rst
                work.append(op & 0x38)
                calls.add(op & 0x38)
            if op == 0xE9:
                indirect.add(pc)
            if op in END:
                break
            pc += n
    return code, calls, jumps, indirect, bad


def spans(code, size=0x8000):
    covered = bytearray(size)
    for a, n in code.items():
        covered[a:a + n] = b"\1" * n
    out, a = [], 0
    while a < size:
        if not covered[a]:
            b = a
            while b < size and not covered[b]:
                b += 1
            out.append((a, b - a))
            a = b
        else:
            a += 1
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rom")
    ap.add_argument("--seed", action="append", default=[], type=lambda s: int(s, 16))
    args = ap.parse_args()
    rom = open(args.rom, "rb").read()
    seeds = SEEDS + args.seed
    code, calls, jumps, indirect, bad = trace(rom, seeds)
    print(f"code bytes {sum(code.values())}, functions {len(calls)}, indirect jumps {len(indirect)}")
    print("indirect jp hl at:", " ".join(f"{a:04x}" for a in sorted(indirect)))
    print("invalid opcode reached at:", " ".join(f"{a:04x}" for a in sorted(bad)))
    for a, n in spans(code):
        if all(b == 0xFF for b in rom[a:a + n]) or all(b == 0 for b in rom[a:a + n]):
            kind = "fill"
        else:
            kind = "data"
        print(f"unreached {a:04x}-{a + n - 1:04x} {n:5d} {kind}")


if __name__ == "__main__":
    main()
