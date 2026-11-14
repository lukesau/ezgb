#!/usr/bin/env python3
"""Byte-compare kernel C, compiled by SDCC 2.9.0, against the stock kernel.

    SDCC29=<sdcc 2.9.0 prefix> tools/match.py [-v] [-f FUNC ...] [-b BANK ...]
                                              [-D NAME[=VAL] ...] [-I DIR ...] [src.c ...]

Compiles each source (default src/dbg.c and src/ff.c, the FatFs R0.11a
copy) once per FatFs bank (3, 5, 6, 7 and 9, or the -b banks, hex) with
`sdcc -mgbz80 --opt-code-size -DBANK=<n>`, the options EZ Flash used,
assembles it with a listing, and looks for every function and data object
in that bank of the stock kernel. Operands the linker fills in (calls,
jumps, globals) are masked, and so is the bank word of a banked call (SDCC
2.9.0 writes 0 there, "PENDING: bank support").

A function matches when its whole masked byte string occurs in the bank.
A miss is compared at the function's kernel.sym address and reports how
many bytes match there; a function with no kernel.sym entry in a bank is
taken to be cut from it (blank cell). -v shows the instructions around the
first wrong byte of each miss, -f limits the table to some functions.

A `/* BB:AAAA */` comment on the line above a definition pins it to that
address (and makes the bank list the comments' banks). A .s source is
assembled as it is. Functions in _HOME (GBDK's NONBANKED) count too.

This finds the function that differs; `make` checks the whole of each bank,
masked operands included. Needs a stock ROM, by default build/kernel.gb,
which is stock whenever `make` last passed (--rom for another). SDCC 2.9.0
ships no sdcpp or sdasgb; SDCC 4.x ones work (README.md). SDASGB=<path>
picks the assembler (default $SDCC29/bin/sdasgb). Exit status 0 when every
function in the table matches.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent          # kernel/1.05e-0731/stock
FAT_BANKS = [3, 5, 6, 7, 9]


def rom_off(bank, addr):
    return addr if bank == 0 else bank * 0x4000 + addr - 0x4000


def load_syms(path):
    """bank -> sorted [(addr, name)] for the global names in kernel.sym"""
    out = {}
    for line in open(path):
        m = re.match(r"([0-9a-f]{2}):([0-9a-f]{4}) ([A-Za-z]\w*)$", line.strip())
        if m and not re.search(r"_B\d+_\w+$", m[3]):    # not the _B9_localLabels
            out.setdefault(int(m[1], 16), []).append((int(m[2], 16), m[3]))
    for v in out.values():
        v.sort()
    return out


# ff.c name -> kernel.sym name stem where CamelCase of the C name is not it
ALIASES = {"mem_cpy": "MemCpy16", "mem_set": ("MemSet8", "MemSet16"), "chk_chr": "MemChr",
           "fit_lfn": "PutLfn", "f_sync": "Fsync", "f_open": "Open",
           "dbg_out": "RetStub"}
# kernel.sym names the wrong function: bank 9 has f_mkdir (Open_B9), no
# f_open, and FsUnlink at 09:7cc0 is a mod label on stock $FF fill
BANK_ALIASES = {(9, "f_mkdir"): "Open", (9, "f_open"): None, (9, "f_unlink"): None}


def sym_addr(syms, bank, cname):
    if (bank, cname) in BANK_ALIASES:
        stems = BANK_ALIASES[(bank, cname)]
        if stems is None:
            return None
    else:
        stems = ALIASES.get(cname)
    stems = stems or "".join(w.title() for w in re.sub(r"^f_", "", cname).split("_"))
    if isinstance(stems, str):
        stems = (stems,)
    for a, n in syms.get(bank, []):
        if n in stems or n in (f"{st}_B{bank:x}" for st in stems):
            return a
    return None


def src_addrs(src):
    """{function: (bank, addr)} from a `/* BB:AAAA` comment right above a definition"""
    out = {}
    for m in re.finditer(r"^/\*\s*([0-9a-fA-F]{2}):([0-9a-fA-F]{4})\b[^\n]*\n(?:static\s*\n)?"
                         r"[A-Za-z_][\w \t\*]*?\b(\w+)\s*\(", open(src, encoding="latin-1").read(), re.M):
        out[m[3]] = (int(m[1], 16), int(m[2], 16))
    return out


def prefix_at(data, at, pat):
    k = 0
    while k < len(pat) and at + k < len(data) and (pat[k] is None or data[at + k] == pat[k]):
        k += 1
    return k


def name_at(syms, bank, addr):
    best = None
    for a, n in syms.get(bank, []):
        if a > addr:
            break
        best = (a, n)
    if not best:
        return f"{bank:02x}:{addr:04x}"
    a, n = best
    return n if a == addr else f"{n}+{addr - a:x}"


def listing(sdcc, sdas, src, cflags):
    """[(name, [(bytes with None for relocated, source line)])] in source order"""
    with tempfile.TemporaryDirectory() as d:
        asm = os.path.join(d, "o.asm")
        if str(src).endswith(".s"):                       # assembly: listing only
            shutil.copy(src, asm)
        else:
            r = subprocess.run([sdcc, "-S", "-mgbz80", "--no-std-crt0",
                                f"-I{src.parent}", *cflags, str(src), "-o", asm],
                               capture_output=True, text=True)
            if r.returncode or not os.path.exists(asm):
                sys.exit(r.stderr)
        subprocess.run([sdas, "-plosgff", f"-I{src.parent}", os.path.join(d, "o.rel"), asm],
                       capture_output=True, cwd=d)
        lines = open(os.path.join(d, "o.lst")).read().splitlines()
    # sdas listing lines: address, bytes ("DAr66r00": r marks a relocated
    # byte), optional [cycles], source line number, source. Long data runs
    # continue on lines that carry bytes only.
    tok = r"(?:[rs]?[0-9A-F]{2})+"
    code_re = re.compile(rf"^\s+[0-9A-F]{{4,8}}(?: |(?=[rs]))({tok}(?: {tok})*)\s+(?:\[[ \d]+\]\s*)?\d+\s(.*)$")
    more_re = re.compile(rf"^(\s+)({tok}(?: {tok})*)\s*$")

    def to_bytes(field, pending):
        bs = [None if t[0] in "rs" else int(t, 16) for t in re.findall(r"[rs]?[0-9A-F]{2}", field)]
        if pending:                                       # .dw 0 ; PENDING: bank support
            bs = [None] * len(bs)
        return bs

    items, cur, area = [], None, "_CODE"
    for line in lines:
        a = re.search(r"\.area\s+(\w+)", line)
        if a:
            area, cur = a[1], None
            continue
        m = code_re.match(line)
        more = not m and more_re.match(line)
        if more and len(more[1]) > 20:                    # a bare source line number
            more = None
        lab = re.search(r"\s(_\w+)::?\s*$", line)
        if lab and not m:
            name = lab[1][1:]
            if area in ("_CODE", "_HOME") and not re.search(r"_(start|end)$", name):
                cur = (name, [])
                items.append(cur)
        elif cur and m:
            cur[1].append((to_bytes(m[1], "PENDING: bank" in line), m[2].strip()))
        elif cur and more and cur[1]:
            cur[1][-1][0].extend(to_bytes(more[2], False))
    return [(n, ins) for n, ins in items if ins]


def find(bank_bytes, pat):
    """(offset of a full match or None, best prefix length, its offset)"""
    lead = []
    for v in pat:
        if v is None:
            break
        lead.append(v)
    lead = bytes(lead[:2])
    best, best_at = 0, None
    start = 0
    n = len(pat)
    while True:
        i = bank_bytes.find(lead, start) if lead else start
        if i < 0 or i + 1 > len(bank_bytes):
            break
        k = 0
        lim = min(n, len(bank_bytes) - i)
        while k < lim and (pat[k] is None or bank_bytes[i + k] == pat[k]):
            k += 1
        if k == n:
            return i, n, i
        if k > best:
            best, best_at = k, i
        start = i + 1
        if not lead and start >= len(bank_bytes):
            break
    return None, best, best_at


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("src", nargs="*", default=[str(HERE / "src" / f) for f in ("dbg.c", "ff.c")])
    p.add_argument("-b", type=lambda s: int(s, 16), action="append", help="bank (hex), repeatable")
    p.add_argument("-D", action="append", default=[], help="define for the compile")
    p.add_argument("-I", action="append", default=[], help="include directory for the compile")
    p.add_argument("--cflags", default="--opt-code-size", help="sdcc options (default %(default)s)")
    p.add_argument("-v", action="store_true")
    p.add_argument("-f", action="append", help="only this function, repeatable")
    p.add_argument("--rom", default=str(HERE / "build" / "kernel.gb"))
    a = p.parse_args()

    prefix = os.environ.get("SDCC29")
    if not prefix:
        sys.exit("set SDCC29 to an SDCC 2.9.0 install prefix")
    sdcc = str(Path(prefix) / "bin" / "sdcc")
    sdas = os.environ.get("SDASGB", str(Path(prefix) / "bin" / "sdasgb"))
    if not os.path.exists(a.rom):
        sys.exit(f"{a.rom}: missing, run make first")
    rom = open(a.rom, "rb").read()
    syms = load_syms(HERE.parent / "kernel.sym")
    banks = a.b or FAT_BANKS

    pinned = {}
    for src in a.src:
        pinned.update(src_addrs(src))
    if not a.b and pinned:
        banks = sorted({b for b, _ in pinned.values()})
    per_bank = {}
    for b in banks:
        per_bank[b] = {}
        for src in a.src:
            per_bank[b].update(listing(sdcc, sdas, Path(src).resolve(),
                                       a.cflags.split() + [f"-DBANK={b}"] + [f"-D{d}" for d in a.D]
                                       + [f"-I{i}" for i in a.I]))
    names = []
    for b in banks:
        names += [n for n in per_bank[b] if n not in names]
    if a.f:
        names = [n for n in names if n in a.f]
    width = max(len(n) for n in names)
    print(f"{'':{width}}  " + "  ".join(f"{'bank ' + format(b, 'x'):>12}" for b in banks))
    all_ok = True
    for name in names:
        cells, misses, hit = [], [], False
        for b in banks:
            ins = per_bank[b].get(name)
            if not ins:
                cells.append("")
                continue
            pat = [v for bs, _ in ins for v in bs]
            base = 0 if b == 0 else 0x4000
            data = rom[rom_off(b, base):rom_off(b, base) + 0x4000]
            sa = sym_addr(syms, b, name)
            if name in pinned:
                sa = pinned[name][1] if pinned[name][0] == b else None
                if sa is None:
                    cells.append("")
                    continue
            if sa is not None:
                at = sa - base if prefix_at(data, sa - base, pat) == len(pat) else None
            elif any(sym_addr(syms, o, name) is not None for o in FAT_BANKS):
                cells.append("")                          # named elsewhere, cut here
                continue
            else:                                         # data, unnamed helpers
                at, k, k_at = find(data, pat)
            if at is not None:
                hit = True
                cells.append(f"{base + at:04x} ok")
            else:
                if sa is not None:
                    k, k_at = prefix_at(data, sa - base, pat), sa - base
                cells.append(f"{k:>4}/{len(pat)}" if k else "-")
                if k_at is not None:
                    misses.append((b, k, base + k_at, ins))
        all_ok &= not misses
        print(f"{name:{width}}  " + "  ".join(f"{c:>12}" for c in cells))
        if a.v and not hit and misses:
            b, k, addr, ins = max(misses, key=lambda m: m[1])
            n = sum(len(bs) for bs, _ in ins)
            print(f"    best: bank {b:x} {name_at(syms, b, addr)} ({addr:04x}), wrong byte {k} of {n}")
            pos = 0
            for i, (bs, s) in enumerate(ins):
                if pos + len(bs) > k - 12 and pos < k + 12:
                    off = rom_off(b, addr) + pos
                    got = "".join("??" if v is None else f"{v:02x}" for v in bs)
                    want = rom[off:off + len(bs)].hex()
                    mark = ">>" if pos <= k < pos + len(bs) else "  "
                    print(f"      {mark} {got:10} stock {want:10} {s}")
                pos += len(bs)
    sys.exit(0 if all_ok else 1)


if __name__ == "__main__":
    main()
