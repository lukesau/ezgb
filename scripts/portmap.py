#!/usr/bin/env python3
"""Map ROM addresses between two stock kernel builds.

The three known kernels (1.04e, 1.05e-0731, 1.05e-0918) are the same program
with code inserted or removed in a few places, so almost every function exists
in all of them at an address that differs only by the size of the insertions
before it. This module recovers that correspondence mechanically:

1. Linear-decode each bank of both ROMs into a token stream of opcode bytes
   (operands are ignored, so a shifted `call` operand still matches; the
   4-byte target blob after `call FarCallTrampoline` is folded into one
   token for the same reason).
2. Align the two token streams per bank with difflib. Every matched run of
   tokens covers the same number of bytes on both sides, so any byte inside
   it maps by offset.

`PortMap.map(bank, addr)` returns the target address or None when the byte
lies in code that only one build has. Callers that patch code should still
compare the bytes at both ends (see port-mod.py), since the alignment is
statistical, not proven.

Usage:
    scripts/portmap.py <from_ver> <to_ver> [--summary] [BB:AAAA ...]

    scripts/portmap.py 1.05e-0731 1.04e 00:1344 04:5990 01:42ba
    scripts/portmap.py 1.05e-0731 1.05e-0918 --summary
"""
import difflib
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK = 0x4000
FARCALL = b"\xcd\x8d\x07"  # call FarCallTrampoline (00:078d, same in all builds)

# SM83 instruction lengths. Everything not listed is 1 byte; CB-prefixed are 2.
_LEN2 = {0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x36, 0x3E,
         0x18, 0x20, 0x28, 0x30, 0x38,
         0xC6, 0xCE, 0xD6, 0xDE, 0xE6, 0xEE, 0xF6, 0xFE,
         0xE0, 0xF0, 0xE8, 0xF8, 0xCB}
_LEN3 = {0x01, 0x11, 0x21, 0x31, 0x08,
         0xC2, 0xC3, 0xCA, 0xD2, 0xDA,
         0xC4, 0xCC, 0xCD, 0xD4, 0xDC,
         0xEA, 0xFA}
# opcodes whose 16-bit operand may be a ROM address worth relocating
ABS16 = {0x01, 0x11, 0x21, 0x31, 0x08, 0xC2, 0xC3, 0xCA, 0xD2, 0xDA,
         0xC4, 0xCC, 0xCD, 0xD4, 0xDC, 0xEA, 0xFA}


def insn_len(data, i):
    """Length of the instruction at data[i]; a far-call blob counts as 7."""
    op = data[i]
    if op == 0xCD and data[i:i + 3] == FARCALL:
        return 7
    if op in _LEN3:
        return 3
    if op in _LEN2:
        return 2
    return 1


def decode(data, start=0, end=None):
    """Yield (offset, length) for a linear sweep of data[start:end]."""
    end = len(data) if end is None else end
    i = start
    while i < end:
        n = insn_len(data, i)
        if i + n > end:
            n = end - i
        yield i, n
        i += n


def tokens(data):
    toks, starts = [], []
    for i, n in decode(data):
        op = data[i]
        # fold the far-call blob into a distinct token so its target bytes
        # (which differ between builds) never desynchronise the decode
        toks.append(0x100 if n == 7 else op)
        starts.append(i)
    return toks, starts


def rom_path(ver):
    p = os.path.join(ROOT, "re", ver, "kernel.gb.orig")
    if not os.path.isfile(p):
        p = os.path.join(ROOT, "re", ver, "kernel.gb")
    return p


def load_stock(ver):
    return open(rom_path(ver), "rb").read()


def cpu_addr(bank, off):
    return off if bank == 0 else 0x4000 + off


def bank_off(bank, addr):
    return addr if bank == 0 else addr - 0x4000


class PortMap:
    def __init__(self, src, dst, cache_dir=None):
        self.src, self.dst = src, dst
        self.blocks = {}  # bank -> [(src_off, dst_off, nbytes), ...]
        key = hashlib.md5(src + dst).hexdigest()
        cache = os.path.join(cache_dir, f"portmap-{key}.json") if cache_dir else None
        if cache and os.path.isfile(cache):
            self.blocks = {int(k): [tuple(b) for b in v]
                           for k, v in json.load(open(cache)).items()}
            return
        for bank in range(len(src) // BANK):
            a = src[bank * BANK:(bank + 1) * BANK]
            b = dst[bank * BANK:(bank + 1) * BANK]
            if a == b:
                self.blocks[bank] = [(0, 0, BANK)]
                continue
            ta, sa = tokens(a)
            tb, sb = tokens(b)
            sm = difflib.SequenceMatcher(None, ta, tb, autojunk=False)
            blocks = []
            for i, j, n in sm.get_matching_blocks():
                if n == 0:
                    continue
                a0 = sa[i]
                a1 = sa[i + n] if i + n < len(sa) else len(a)
                b0 = sb[j]
                b1 = sb[j + n] if j + n < len(sb) else len(b)
                assert a1 - a0 == b1 - b0, (bank, i, j, n)
                blocks.append((a0, b0, a1 - a0))
            self.blocks[bank] = blocks
        if cache:
            os.makedirs(cache_dir, exist_ok=True)
            json.dump({str(k): v for k, v in self.blocks.items()}, open(cache, "w"))

    def map_off(self, bank, off):
        for a0, b0, n in self.blocks.get(bank, ()):
            if a0 <= off < a0 + n:
                return b0 + (off - a0)
        return None

    def map(self, bank, addr):
        """CPU address in `bank` of the src ROM -> same in dst, or None."""
        off = bank_off(bank, addr)
        if not 0 <= off < BANK:
            return None
        r = self.map_off(bank, off)
        return None if r is None else cpu_addr(bank, r)

    def block_of(self, bank, off):
        for blk in self.blocks.get(bank, ()):
            if blk[0] <= off < blk[0] + blk[2]:
                return blk
        return None

    def summary(self):
        out = []
        for bank, blocks in sorted(self.blocks.items()):
            deltas = {}
            for a0, b0, n in blocks:
                if n >= 16:
                    deltas.setdefault(b0 - a0, 0)
                    deltas[b0 - a0] += n
            desc = ", ".join(f"{d:+d}:{n}B" for d, n in sorted(deltas.items(), key=lambda x: -x[1])[:6])
            out.append(f"bank {bank}: {len(blocks)} blocks; bytes by delta {desc}")
        return "\n".join(out)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = [a for a in sys.argv[1:] if a.startswith("--")]
    if len(args) < 2:
        print(__doc__)
        sys.exit(2)
    src_ver, dst_ver = args[0], args[1]
    pm = PortMap(load_stock(src_ver), load_stock(dst_ver))
    if "--summary" in flags or len(args) == 2:
        print(pm.summary())
    for spec in args[2:]:
        bank_s, addr_s = spec.split(":")
        bank, addr = int(bank_s, 16), int(addr_s, 16)
        r = pm.map(bank, addr)
        print(f"{bank:02x}:{addr:04x} -> " + (f"{bank:02x}:{r:04x} ({r - addr:+d})" if r is not None else "unmapped"))


if __name__ == "__main__":
    main()
