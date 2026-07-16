#!/usr/bin/env python3
"""Report which functions the docs describe by role but the disassembly hasn't named yet.

Cross-references three things for a kernel version:
  1. kernel.sym          - human names already assigned (bank:addr -> name)
  2. docs/*.md           - functions referenced by their mgbdis symbol
                           (Call_/Jump_/jr_/Data_/Unknown_ + bank + addr)
  3. disassembly/*.asm   - call/jump fan-in (how many sites reference each label)

The output ranks the gap: functions that are documented (or heavily called) but
still carry an auto-generated name. Naming a high-fan-in helper annotates every
call site at once, so this is a worklist for "what to label next".

Usage:
  scripts/doc-symbol-coverage.py [version] [--all] [--top N]

  version   kernel version under re/ (default: 1.05e)
  --all     include already-named symbols in the table (default: unnamed only)
  --top N   show only the first N rows (default: all)
"""

import re
import sys
import glob
import collections
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SYMREF_RX = re.compile(r"\b(?:Call|Jump|jr|Data|Unknown)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})\b")
LABELREF_RX = re.compile(r"\b(?:Call|Jump|jr)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})\b")


def load_named(version):
    named = {}
    sym = ROOT / "re" / version / "kernel.sym"
    if not sym.is_file():
        return named
    for line in sym.read_text(encoding="utf-8").splitlines():
        line = line.split(";", 1)[0].strip()
        parts = line.split()
        if len(parts) >= 2 and ":" in parts[0]:
            bank, addr = parts[0].split(":")
            named[(f"{int(bank, 16):02x}", addr.lower())] = parts[1]
    return named


def scan_docs():
    counts = collections.Counter()
    for f in glob.glob(str(ROOT / "docs" / "*.md")):
        text = Path(f).read_text(encoding="utf-8", errors="ignore")
        for bank, addr in SYMREF_RX.findall(text):
            counts[(f"{int(bank, 16):02x}", addr.lower())] += 1
    return counts


def scan_fanin(version):
    counts = collections.Counter()
    for f in glob.glob(str(ROOT / "re" / version / "disassembly" / "bank_*.asm")):
        text = Path(f).read_text(encoding="utf-8", errors="ignore")
        for bank, addr in LABELREF_RX.findall(text):
            counts[(f"{int(bank, 16):02x}", addr.lower())] += 1
    return counts


def main():
    args = sys.argv[1:]
    show_all = "--all" in args
    args = [a for a in args if a != "--all"]
    top = None
    if "--top" in args:
        i = args.index("--top")
        top = int(args[i + 1])
        del args[i : i + 2]
    version = args[0] if args else "1.05e"

    named = load_named(version)
    docs = scan_docs()
    fanin = scan_fanin(version)

    # Candidate set: everything mentioned in docs, plus every called label.
    keys = set(docs) | set(fanin)
    rows = []
    for key in keys:
        name = named.get(key, "")
        if name and not show_all:
            continue
        rows.append((key, name, docs.get(key, 0), fanin.get(key, 0)))

    # Unnamed first, then by fan-in, then by doc mentions.
    rows.sort(key=lambda r: (r[1] != "", -r[3], -r[2], r[0]))
    if top is not None:
        rows = rows[:top]

    documented = set(docs)
    doc_named = sum(1 for k in documented if k in named)
    print(f"version {version}: {len(documented)} functions referenced in docs, "
          f"{doc_named} named, {len(documented) - doc_named} still unnamed")
    print()
    print(f"{'addr':7} {'name':24} {'docrefs':>7} {'callsites':>9}")
    print("-" * 51)
    for (bank, addr), name, dref, fin in rows:
        print(f"{bank}:{addr}  {name or '(UNNAMED)':24} {dref:>7} {fin:>9}")


if __name__ == "__main__":
    main()
