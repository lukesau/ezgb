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
disassembly.

Usage:
  sdinc.py <src> --sym kernel.sym [-b AREA=ADDR ...] [-g SYM=ADDR ...]
           --region START:END:OUT.inc [...] [--cflags "..."]
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


def write_inc(path, src, start, end, data, labels):
    by_addr = {}
    for name, addr in labels.items():
        # l__AREA / s__AREA are sdld's area length and start symbols
        if start <= addr < end and RGBDS_LABEL.match(name) and not name.startswith(("l__", "s__")):
            by_addr.setdefault(addr, []).append(name)
    lines = [f"; Generated from {src} by decomp/tools/sdinc.py, do not edit.",
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


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("src")
    p.add_argument("--sym", required=True, help="kernel.sym for external symbols")
    p.add_argument("-b", action="append", default=[], help="AREA=ADDR placement")
    p.add_argument("-g", action="append", default=[], help="SYM=ADDR extra definition")
    p.add_argument("--region", action="append", required=True, help="START:END:OUT.inc")
    p.add_argument("--cflags", default="", help="extra sdcc flags for .c sources")
    a = p.parse_args()

    src = os.path.abspath(a.src)
    with tempfile.TemporaryDirectory() as d:
        rel = os.path.join(d, "out.rel")
        if src.endswith(".c"):
            run(["sdcc", "-c", "-msm83", "--sdcccall", "0", "--no-std-crt0",
                 *a.cflags.split(), src, "-o", rel], d)
        else:
            run(["sdasgb", "-plosgff", "-I" + os.path.dirname(src), rel, src], d)

        refs, defs = rel_symbols(rel)
        kernel = load_syms(a.sym)
        extra = {}
        for spec in a.g:
            n, v = spec.split("=")
            extra[n] = int(v, 16)
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
            else:
                missing.append(sym)
        if missing:
            sys.exit("error: unresolved symbols (add them to kernel.sym or -g): "
                     + " ".join(missing))
        # a link file: sdld goes interactive when options come only on argv
        lines = ["-mjwx", "-i out.ihx"]
        lines += [f"-b {spec}" for spec in a.b]
        lines += [x for x in link if x.startswith("-g")]
        lines += ["out.rel", "-e"]
        open(os.path.join(d, "out.lk"), "w").write("\n".join(lines) + "\n")
        r = subprocess.run(["sdldgb", "-nf", "out.lk"], cwd=d, capture_output=True,
                           text=True, stdin=subprocess.DEVNULL, timeout=60)
        if r.returncode != 0 or not os.path.exists(os.path.join(d, "out.ihx")):
            sys.exit(f"error: sdldgb\n{r.stdout}{r.stderr}")
        data = parse_ihx(os.path.join(d, "out.ihx"))
        labels = parse_map(os.path.join(d, "out.map"))

    rel_src = os.path.relpath(src, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    for spec in a.region:
        s, e, out = spec.split(":", 2)
        write_inc(out, rel_src, int(s, 16), int(e, 16), data, labels)


if __name__ == "__main__":
    main()
