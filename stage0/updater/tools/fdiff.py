#!/usr/bin/env python3
"""Instruction diff of one function: SDCC 2.9.0's output against the stock updater.

    stage0/updater/tools/fdiff.py FILE FUNCTION [fw4|fw5-0918] [-n]

Both sides are disassembled the same way. -n also hides stack offsets, to
see past a frame of another size.
"""
import difflib
import importlib.util
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
REPO = HERE.parent.parent
spec = importlib.util.spec_from_file_location("iset", REPO / "tools" / "mgbdis" / "instruction_set.py")
iset = importlib.util.module_from_spec(spec)
spec.loader.exec_module(iset)
args = [a for a in sys.argv[1:] if a != "-n"]
norm = "-n" in sys.argv
f, fn = args[0], args[1]
fw = args[2] if len(args) > 2 else "fw4"
STOCK = {"fw4": "2020-03-10_FW4_K1.04e/Update_FW4.gb", "fw5-0918": "2021-09-18_FW5_K1.05e/Update_FW5_2021-9-18.gb"}
rom = (REPO / "tools" / "ezflashjr" / "official" / STOCK[fw]).read_bytes()
shift = 0x38 if fw != "fw4" else 0


def dis(b, n):
    out, i = [], 0
    while i < n:
        op = b[i]
        if op == 0xCB:
            out.append(iset.cb_instructions[b[i + 1]]); i += 2; continue
        t = iset.instructions.get(op, f"db ${op:02x}")
        if "d16" in t or "a16" in t:
            t = t.replace("d16", "NNNN").replace("a16", "NNNN"); i += 3
        elif "d8" in t or "a8" in t:
            t = t.replace("d8", f"${b[i + 1]:02x}").replace("a8", f"$ff{b[i + 1]:02x}"); i += 2
        elif "r8" in t:
            v = b[i + 1] - (256 if b[i + 1] > 127 else 0)
            t = t.replace("pc+r8", "REL").replace("r8", "REL" if t.startswith("jr") else ("SP" if norm else f"{v:+d}")); i += 2
        else:
            i += 1
        out.append(t)
    return out


src = HERE / "src" / f"{f}.c"
asm = subprocess.run([str(HERE / "tools" / "asm.sh"), str(src), fw], capture_output=True, text=True).stdout
with tempfile.TemporaryDirectory() as d:
    open(os.path.join(d, "o.asm"), "w").write(asm)
    subprocess.run(["sdasgb", "-plosgff", "o.rel", "o.asm"], cwd=d, capture_output=True)
    lst = open(os.path.join(d, "o.lst")).read().splitlines()
tok = r"(?:[rs]?[0-9A-F]{2})+"
code = re.compile(rf"^(\s+[0-9A-F]{{4,8}})(?![0-9A-F])\s?(\s*{tok}(?:\s{tok})*)(\s+(?:\[\s*\d+\]\s+)?)(\d+)\s(.*)$")
mine, cur, numcol = bytearray(), None, None
for line in lst:
    m = code.match(line)
    if m:
        numcol = numcol or m.start(4); raw = m[2]
    elif numcol and line[:numcol].strip() and not line[numcol:].strip() and re.fullmatch(rf"\s*{tok}(?:\s{tok})*\s*", line[:numcol]):
        raw = line[:numcol]
    else:
        lab = re.search(r"\s(_\w+)::?\s*$", line)
        if lab:
            cur = lab[1][1:]
        continue
    if cur == fn:
        mine += bytes(int(t, 16) for t in re.sub(r"[rs]([0-9A-F]{2})", r" \1", raw).split())
sym = {}
for l in open(HERE / "updater.sym"):
    m = re.match(r"([0-9a-f]{2}):([0-9a-f]{4}) (\w+)", l)
    if m:
        sym[m[3]] = int(m[2], 16) + (shift if int(m[2], 16) > 0x134D and m[1] == "00" else 0)
a = dis(mine, len(mine))
b = dis(rom[sym[fn]:], len(mine) + 64)
print(f"{fn}: {len(mine)} bytes compiled")
for l in difflib.unified_diff(b, a, "stock", "ours", n=3, lineterm=""):
    print(l)
