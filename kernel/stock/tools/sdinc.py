#!/usr/bin/env python3
"""Turn an sdas/SDCC source into rgbds includes at fixed ROM addresses.

The source is assembled (.s) or compiled (.c) with the SDCC toolchain,
linked by sdldgb with its areas placed where the stock kernel has them, and
each requested address range is written out as an rgbds include: the bytes as
`db`, with a `Name::` label wherever the source defines a global symbol whose
name is a valid rgbds label (no leading `.` or `_`). Gaps the source leaves
unwritten inside a range are $FF, the stock fill.

Symbols the source uses but does not define are resolved from a kernel.sym
style file (bank:addr name), so a source can call into code that is still
disassembly. -a C_NAME=KERNEL_NAME resolves one under its kernel.sym name,
-g SYM=[BANK:]ADDR one kernel.sym does not name. --syms-out FILE writes
every global the link defines (GBDK's dot names too) as kernel.sym lines,
and --defs FILE reads such a file back, so one module can link against the
symbols of another built on its own (GBDK's library modules against crt0.s).
A banked call to a --defs symbol gets the bank the file gives it.
--auto-alias resolves an undefined _NAME as kernel.sym's NAME, so new C
needs -a only where the names differ.

--sdcc29 compiles C with SDCC 2.9.0 (`$SDCC29/bin/sdcc -mgbz80`), the
compiler EZ Flash used; its output is assembled with the SDCC 4.x sdasgb.
2.9.0 writes the bank word after a banked call as `.dw 0 ; PENDING: bank
support`; sdinc fills it with the callee's bank: kernel.sym's for one
resolved with -a, else --bank N (a function of the sources themselves)
(stock has the real bank there). --bank N also labels each region with the kernel.sym entry
names (not their `_B<n>_` local labels) in bank N, so the rest of the
disassembly still links.

Several sources link in the order given, as sdld places their areas.
--area-at SRC:AREA=ADDR places one source's piece of an area apart from the
others' (stock's linker met that object elsewhere in the area): sdinc renames
the area in that object before linking. SRC is the source's file name. For
an absolute area, each `.org` lands at ADDR plus its address: stock's linker
appended the modules' _HEADER areas one after another.

Usage:
  sdinc.py <src> [<src> ...] --sym kernel.sym [-b AREA=ADDR ...] [-g SYM=ADDR ...]
           [-a SYM=NAME ...] --region START:END:OUT.inc [...] [--cflags "..."]
           [--sdcc29 --bank N]
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile


def run(cmd, cwd):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"error: {' '.join(cmd)}\n{r.stdout}{r.stderr}")
    return r


def load_syms(path):
    syms = {}
    for line in open(path):
        m = re.match(r"\s*([0-9a-fA-F]{2}):([0-9a-fA-F]{4})\s+(\S+)", line)
        if m and not m.group(3).startswith("."):
            syms.setdefault(m.group(3), int(m.group(2), 16))
    return syms


def load_bank_labels(path, bank):
    """kernel.sym entry names in one bank: addr -> [names]"""
    out = {}
    for line in open(path):
        m = re.match(r"\s*([0-9a-fA-F]{2}):([0-9a-fA-F]{4})\s+(\S+)", line)
        if (m and int(m.group(1), 16) == bank and RGBDS_LABEL.match(m.group(3))
                and not re.search(r"_B[0-9a-fA-F]+_", m.group(3))):
            out.setdefault(int(m.group(2), 16), []).append(m.group(3))
    return out


def rel_symbols(rel):
    refs, defs = set(), set()
    for line in open(rel):
        m = re.match(r"S\s+(\S+)\s+(Ref|Def)", line)
        if m:
            (refs if m.group(2) == "Ref" else defs).add(m.group(1))
    return refs, defs


def parse_ihx(path):
    out = {}
    for line in open(path):
        line = line.strip()
        if line.startswith(":") and int(line[7:9], 16) == 0:
            n, addr = int(line[1:3], 16), int(line[3:7], 16)
            for i, b in enumerate(bytes.fromhex(line[9:9 + 2 * n])):
                out[addr + i] = b
    return out


def parse_map(path):
    """Global symbol -> address from an sdld map."""
    syms = {}
    for line in open(path):
        m = re.match(r"\s+([0-9A-F]{4,8})\s+(\S+)", line)
        if m:
            syms[m.group(2)] = int(m.group(1), 16)
    return syms


RGBDS_LABEL = re.compile(r"[A-Za-z][A-Za-z0-9_]*$")


def write_inc(path, src, start, end, data, labels, extra_labels):
    by_addr = {}
    for addr, names in extra_labels.items():
        if start <= addr < end:
            by_addr.setdefault(addr, []).extend(names)
    for name, addr in labels.items():
        # l__AREA / s__AREA are sdld's area length and start symbols
        if start <= addr < end and RGBDS_LABEL.match(name) and not name.startswith(("l__", "s__")):
            if name not in by_addr.get(addr, []):
                by_addr.setdefault(addr, []).append(name)
    lines = [f"; Generated from {src} by kernel/stock/tools/sdinc.py, do not edit.",
             f"; ${start:04x}-${end:04x}"]
    run_ = []

    def flush():
        for i in range(0, len(run_), 16):
            lines.append("    db " + ", ".join(f"${b:02x}" for b in run_[i:i + 16]))
        run_.clear()

    for a in range(start, end):
        if a in by_addr:
            flush()
            lines.extend(f"{n}::" for n in sorted(by_addr[a]))
        run_.append(data.get(a, 0xFF))
    flush()
    open(path, "w").write("\n".join(lines) + "\n")


def compile_one(a, src, rel, d):
    if src.endswith(".c") and a.sdcc29:
        prefix = os.environ.get("SDCC29")
        if not prefix:
            sys.exit("error: set SDCC29 to an SDCC 2.9.0 install prefix")
        asm = rel[:-4] + ".asm"
        a.own_defs = set()
        run([os.path.join(prefix, "bin", "sdcc"), "-S", "-mgbz80", "--no-std-crt0",
             *a.cflags.split(), src, "-o", asm], d)
        text = open(asm).read()
        a.own_defs = set(re.findall(r"^\s*\.globl\s+(\w+)", text, flags=re.M)) & \
            set(re.findall(r"^(\w+)::?\s*$", text, flags=re.M))

        def bank_word(m):
            # the callee's bank: kernel.sym's for an external, else the source's
            if m[2] in a.aliases:
                return f"{m[1]}.dw {a.sym_banks[a.aliases[m[2]]]}{m[3]}"
            if m[2] in a.g_banks:
                return f"{m[1]}.dw {a.g_banks[m[2]]}{m[3]}"
            if m[2] in a.def_banks:
                return f"{m[1]}.dw {a.def_banks[m[2]]}{m[3]}"
            if a.auto_alias and m[2][1:] in a.sym_banks:
                return f"{m[1]}.dw {a.sym_banks[m[2][1:]]}{m[3]}"
            if m[2] in a.sym_banks and m[2] not in a.own_defs:
                return f"{m[1]}.dw {a.sym_banks[m[2]]}{m[3]}"
            if a.bank is None:
                sys.exit(f"error: banked call to {m[2]} needs --bank")
            return f"{m[1]}.dw {a.bank}{m[3]}"
        text = re.sub(r"(\.dw\s+(\w+)\s*\n\s*)\.dw 0(\s*; PENDING: bank support)", bank_word, text)
        open(asm, "w").write(text)
        run(["sdasgb", "-plosgff", rel, asm], d)
    elif src.endswith(".c"):
        run(["sdcc", "-c", "-msm83", "--sdcccall", "0", "--no-std-crt0",
             *a.cflags.split(), src, "-o", rel], d)
    else:
        incs = ["-I" + os.path.dirname(src)] + ["-I" + os.path.abspath(x) for x in a.I]
        run(["sdasgb", "-plosgff", *incs, rel, src], d)


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("src", nargs="+", help="sources, linked in this order")
    p.add_argument("--sym", required=True, help="kernel.sym for external symbols")
    p.add_argument("-b", action="append", default=[], help="AREA=ADDR placement")
    p.add_argument("-g", action="append", default=[], help="SYM=ADDR or SYM=BANK:ADDR extra definition")
    p.add_argument("--region", action="append", required=True, help="START:END:OUT.inc")
    p.add_argument("-a", action="append", default=[], help="SYM=NAME: resolve SYM as kernel.sym NAME")
    p.add_argument("--cflags", default="", help="extra sdcc flags for .c sources")
    p.add_argument("--sdcc29", action="store_true", help="compile C with SDCC 2.9.0 ($SDCC29)")
    p.add_argument("--bank", type=lambda v: int(v, 0), help="bank of the source (see above)")
    p.add_argument("-I", action="append", default=[], help="include directory for .s sources")
    p.add_argument("--area-at", action="append", default=[], help="SRC:AREA=ADDR (see above)")
    p.add_argument("--defs", action="append", default=[], help="kernel.sym-style file of more definitions")
    p.add_argument("--syms-out", help="write the link's global symbols here")
    p.add_argument("--undef-ok", action="store_true",
                   help="link an unresolved symbol as 0: for a link that only measures")
    p.add_argument("--no-spill", action="store_true",
                   help="fail when linked bytes run past the end of a region")
    p.add_argument("--auto-alias", action="store_true",
                   help="resolve an undefined _NAME as kernel.sym NAME")
    a = p.parse_args()

    srcs = [os.path.abspath(x) for x in a.src]
    a.aliases = dict(spec.split("=") for spec in a.a)
    a.g_banks = {n: int(v.split(":")[0], 16) for n, v in (spec.split("=") for spec in a.g) if ":" in v}
    a.sym_banks = {}
    for line in open(a.sym):
        m = re.match(r"\s*([0-9a-fA-F]{2}):([0-9a-fA-F]{4})\s+(\S+)", line)
        if m:
            a.sym_banks.setdefault(m.group(3), int(m.group(1), 16))
    a.def_banks = {}
    for path in a.defs:
        for line in open(path):
            m = re.match(r"\s*([0-9a-fA-F]{2}):[0-9a-fA-F]{4}\s+(\S+)", line)
            if m:
                a.def_banks.setdefault(m.group(2), int(m.group(1), 16))
    with tempfile.TemporaryDirectory() as d:
        rels = []
        for i, src in enumerate(srcs):
            rel = os.path.join(d, f"out{i}.rel")
            rels.append(os.path.basename(rel))
            compile_one(a, src, rel, d)
            for spec in a.area_at:
                name, rest = spec.split(":", 1)
                area, addr = rest.split("=")
                if os.path.basename(src) != name:
                    continue
                text = open(rel).read()
                new = f"{area}_{i}"
                text, n = re.subn(rf"^A {re.escape(area)} ", f"A {new} ", text, flags=re.M)
                # an absolute area's .org pieces (sdas names them AREA0, AREA1, ...):
                # placed relative to ADDR, the way a linker that appends each
                # module's piece of the area does
                def rebase(m):
                    base = int(addr, 0)  # the T lines keep the .org address
                    a.b.append(f"{new}_{m.group(1)}=0x{base:04x}")
                    return f"A {new}_{m.group(1)} size {m.group(2)} flags 0 addr 0"
                text, k = re.subn(rf"^A {re.escape(area)}(\d+) size (\w+) flags 8 addr (\w+)$", rebase,
                                  text, flags=re.M)
                if not n and not k:
                    sys.exit(f"error: --area-at {spec}: no area {area} in {name}")
                open(rel, "w").write(text)
                a.b.append(f"{new}={addr}")

        refs, defs = set(), set()
        for rel in rels:
            r_, d_ = rel_symbols(os.path.join(d, rel))
            refs |= r_
            defs |= d_
        kernel = load_syms(a.sym)
        extra = {}
        for path in a.defs:
            for line in open(path):
                m = re.match(r"\s*[0-9a-fA-F]{2}:([0-9a-fA-F]{4})\s+(\S+)", line)
                if m:
                    extra.setdefault(m.group(2), int(m.group(1), 16))
        for spec in a.g:
            n, v = spec.split("=")
            extra[n] = int(v.split(":")[-1], 16)
        for spec in a.a:
            n, v = spec.split("=")
            if v not in kernel:
                sys.exit(f"error: -a {spec}: {v} is not in {a.sym}")
            extra[n] = kernel[v]
        missing = []
        link = ["-mjwx", "-i", "out.ihx"]
        for spec in a.b:
            n, v = spec.split("=")
            link += ["-b", f"{n}={v}"]
        for sym in sorted(refs - defs):
            if sym in extra:
                link.append(f"-g{sym}=0x{extra[sym]:04x}")
            elif sym in kernel:
                link.append(f"-g{sym}=0x{kernel[sym]:04x}")
            elif a.auto_alias and sym[1:] in kernel:
                link.append(f"-g{sym}=0x{kernel[sym[1:]]:04x}")
            elif a.undef_ok:
                link.append(f"-g{sym}=0x0000")
            else:
                missing.append(sym)
        if missing:
            sys.exit("error: unresolved symbols (add them to kernel.sym or -g): "
                     + " ".join(missing))
        # a link file: sdld goes interactive when options come only on argv
        lines = ["-mjwx", "-i out.ihx"]
        lines += [f"-b {spec}" for spec in a.b]
        lines += [x for x in link if x.startswith("-g")]
        lines += rels + ["-e"]
        open(os.path.join(d, "out.lk"), "w").write("\n".join(lines) + "\n")
        r = subprocess.run(["sdldgb", "-nf", "out.lk"], cwd=d, capture_output=True,
                           text=True, stdin=subprocess.DEVNULL, timeout=60)
        if r.returncode != 0 or not os.path.exists(os.path.join(d, "out.ihx")):
            sys.exit(f"error: sdldgb\n{r.stdout}{r.stderr}")
        data = parse_ihx(os.path.join(d, "out.ihx"))
        labels = parse_map(os.path.join(d, "out.map"))

    if a.syms_out:
        bank = a.bank or 0
        with open(a.syms_out, "w") as f:
            for name, addr in sorted(labels.items(), key=lambda x: (x[1], x[0])):
                if name in defs and not name.startswith(("l__", "s__")):
                    f.write(f"{bank:02x}:{addr:04x} {name}\n")
            # each area's start and length, for a build that moves them (modlink.py)
            for name, size in sorted(labels.items()):
                if name.startswith("l_") and "s_" + name[2:] in labels:
                    f.write(f"; area {name[2:]} {labels['s_' + name[2:]]:04x} {size:04x}\n")

    rel_src = " ".join(os.path.relpath(x, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
                       for x in srcs)
    bank_labels = load_bank_labels(a.sym, a.bank) if a.bank is not None else {}
    ends = {int(spec.split(":")[1], 16) for spec in a.region}
    starts = {int(spec.split(":")[0], 16) for spec in a.region}
    for end in sorted(ends - starts):
        if a.no_spill and end in data and end % 0x4000 and end - 1 in data:
            sys.exit(f"error: {rel_src}: code runs past ${end:04x}")
    for spec in a.region:
        s, e, out = spec.split(":", 2)
        write_inc(out, rel_src, int(s, 16), int(e, 16), data, labels, bank_labels)


if __name__ == "__main__":
    main()
