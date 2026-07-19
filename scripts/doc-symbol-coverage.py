#!/usr/bin/env python3
"""Report which functions the docs describe by role but the disassembly hasn't named yet.

Cross-references three things for a kernel version:
  1. kernel.sym          - human names already assigned (bank:addr -> name)
  2. docs/*.md           - functions referenced by their mgbdis symbol
                           (Call_/Jump_/jr_/Data_/Unknown_ + bank + addr)
  3. disassembly/*.asm   - call-site fan-in (`call Call_BBB_AAAA` only)

Jump_/jr_ refs are kept for doc coverage (docs cite loop heads and seams on
purpose) but are excluded from fan-in ranking. Internal `jp Jump_…` loops
inflate scores without being good naming targets; prefer Call_ entries, and
name Jump_ only when docs or a farcall entry point make them a real seam.

The output ranks the gap: functions that are documented (or heavily called) but
still carry an auto-generated name. Naming a high-fan-in helper annotates every
call site at once, so this is a worklist for "what to label next".

Usage:
  scripts/doc-symbol-coverage.py [version] [flags]

  version         kernel version under re/ (default: 1.05e)
  --all           include already-named symbols in the table
  --top N         show only the first N rows (default: all; --app defaults to 15)
  --app           app-focused worklist (recommended for naming loops):
                    skip FatFs-linked banks 03/05/06/07/09, skip SDCC-runtime
                    bodies, rank frontier (callee of a named fn) first, compact
  --include-lib   with --app, still show lib banks (runtime skip remains)
  --skip-runtime  drop stack+ALU compiler-helper bodies (implied by --app)
  --frontier-only only show unnamed callees of already-named functions
  --banks LIST    only these banks (comma hex, e.g. 00,01,04,08)
  --skip-banks LIST  drop these banks (comma hex)
  --verbose       full table even under --app

Loop tip:  scripts/doc-symbol-coverage.py --app --top 10
"""

import re
import sys
import glob
import collections
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# FatFs-shaped code is linked per bank (near-call only). Bank 9 is canonical;
# 3/5/6/7 are mostly copies — huge unnamed mass, low app-mapping value.
LIB_BANKS = frozenset({"03", "05", "06", "07", "09"})

# Docs may cite any mgbdis auto-name, including Jump_/jr_ seams.
SYMREF_RX = re.compile(r"\b(?:Call|Jump|jr|Data|Unknown)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})\b")
# Fan-in: real call sites only (not jp/jr to Jump_ loop heads).
CALLSITE_RX = re.compile(r"\bcall\s+Call_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})\b", re.IGNORECASE)
CALL_LABEL_RX = re.compile(r"^Call_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$")
ANY_LABEL_RX = re.compile(r"^([A-Za-z_][\w]*)::?\s*$")
# Absolute WRAM / FPGA — means not a pure compiler leaf.
ABS_APP_RX = re.compile(r"\$(?:[DdCc][0-9a-fA-F]{3}|7[Ff][0-9a-fA-F]{2})\b")
STACK_FRAME_RX = re.compile(r"add\s+hl,\s*sp", re.IGNORECASE)
SHIFT_RX = re.compile(r"\b(?:rr|rl|sra|sla|rrc|rlc)\s+", re.IGNORECASE)
SBC_RX = re.compile(r"\bsbc\s+", re.IGNORECASE)
DEC_LOOP_RX = re.compile(r"\bdec\s+(?:a|b)\b", re.IGNORECASE)
CODE_LINE_RX = re.compile(r"^\s*[^;\s]")


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


def scan_call_fanin(version):
    counts = collections.Counter()
    for f in glob.glob(str(ROOT / "re" / version / "disassembly" / "bank_*.asm")):
        text = Path(f).read_text(encoding="utf-8", errors="ignore")
        for bank, addr in CALLSITE_RX.findall(text):
            counts[(f"{int(bank, 16):02x}", addr.lower())] += 1
    return counts


def parse_bank_list(arg):
    out = set()
    for part in arg.split(","):
        part = part.strip()
        if not part:
            continue
        out.add(f"{int(part, 16):02x}")
    return out


def is_sdcc_runtime(body):
    """Deterministic body fingerprint for SDCC mul/div/shift leaves."""
    if not body or ABS_APP_RX.search(body):
        return False
    code = [ln for ln in body.splitlines() if CODE_LINE_RX.match(ln)]
    if not code:
        return False
    # Tiny jp/ret stubs are not useful app targets; treat as skippable lib/runtime.
    if len(code) <= 2:
        return True
    if not STACK_FRAME_RX.search(body):
        return False
    if SHIFT_RX.search(body) and DEC_LOOP_RX.search(body):
        return True
    if SBC_RX.search(body) and DEC_LOOP_RX.search(body):
        return True
    return False


def scan_bodies_and_frontier(version, named):
    """Map Call_ addr -> body text; set of Call_ targets invoked from named fns."""
    bodies = {}
    frontier = set()
    name_to_key = {name: key for key, name in named.items()}

    for f in glob.glob(str(ROOT / "re" / version / "disassembly" / "bank_*.asm")):
        lines = Path(f).read_text(encoding="utf-8", errors="ignore").splitlines()
        i = 0
        while i < len(lines):
            m_call = CALL_LABEL_RX.match(lines[i])
            m_any = ANY_LABEL_RX.match(lines[i])
            if not m_call and not m_any:
                i += 1
                continue

            label_name = m_any.group(1) if m_any else None
            call_key = None
            if m_call:
                call_key = (f"{int(m_call.group(1), 16):02x}", m_call.group(2).lower())

            # Body runs until next top-level label.
            j = i + 1
            while j < len(lines) and not ANY_LABEL_RX.match(lines[j]) and not CALL_LABEL_RX.match(lines[j]):
                j += 1
            body = "\n".join(lines[i + 1:j])
            if call_key:
                bodies[call_key] = body

            in_named = False
            if call_key and call_key in named:
                in_named = True
            elif label_name and label_name in name_to_key:
                in_named = True

            if in_named:
                for bank, addr in CALLSITE_RX.findall(body):
                    frontier.add((f"{int(bank, 16):02x}", addr.lower()))

            i = j

    return bodies, frontier


def main():
    args = sys.argv[1:]
    show_all = "--all" in args
    app_mode = "--app" in args
    include_lib = "--include-lib" in args
    skip_runtime = "--skip-runtime" in args or app_mode
    frontier_only = "--frontier-only" in args
    verbose = "--verbose" in args
    compact = app_mode and not verbose

    flags = {
        "--all", "--app", "--include-lib", "--skip-runtime",
        "--frontier-only", "--verbose",
    }
    args = [a for a in args if a not in flags]

    top = 15 if app_mode else None
    only_banks = None
    skip_banks = set()

    if "--top" in args:
        i = args.index("--top")
        top = int(args[i + 1])
        del args[i:i + 2]
    if "--banks" in args:
        i = args.index("--banks")
        only_banks = parse_bank_list(args[i + 1])
        del args[i:i + 2]
    if "--skip-banks" in args:
        i = args.index("--skip-banks")
        skip_banks = parse_bank_list(args[i + 1])
        del args[i:i + 2]

    if app_mode and not include_lib and only_banks is None:
        skip_banks |= LIB_BANKS

    version = args[0] if args else "1.05e"

    named = load_named(version)
    docs = scan_docs()
    fanin = scan_call_fanin(version)
    need_bodies = skip_runtime or frontier_only or app_mode
    bodies, frontier = ({}, set())
    if need_bodies:
        bodies, frontier = scan_bodies_and_frontier(version, named)

    keys = set(docs) | set(fanin)
    rows = []
    skipped_lib = skipped_runtime = skipped_bank = skipped_nonfrontier = 0

    for key in keys:
        bank, addr = key
        name = named.get(key, "")
        if name and not show_all:
            continue
        if only_banks is not None and bank not in only_banks:
            skipped_bank += 1
            continue
        if bank in skip_banks:
            skipped_lib += 1
            continue
        # Drop doc phantoms (e.g. Call_BBB_AAAA placeholders) and dead refs.
        if need_bodies and key not in bodies and fanin.get(key, 0) == 0:
            continue
        if frontier_only and key not in frontier and not (key in docs and key in bodies):
            skipped_nonfrontier += 1
            continue
        if skip_runtime and key not in docs:
            body = bodies.get(key, "")
            # Only fingerprint still-auto Call_ targets we have a body for.
            if key in bodies and is_sdcc_runtime(body):
                skipped_runtime += 1
                continue
        rows.append((key, name, docs.get(key, 0), fanin.get(key, 0), key in frontier))

    # Unnamed first; under --app prefer frontier, then fan-in, then docs.
    if app_mode or frontier_only:
        rows.sort(key=lambda r: (r[1] != "", -r[4], -r[3], -r[2], r[0]))
    else:
        rows.sort(key=lambda r: (r[1] != "", -r[3], -r[2], r[0]))

    total = len(rows)
    if top is not None:
        rows = rows[:top]

    documented = set(docs)
    doc_named = sum(1 for k in documented if k in named)

    if compact:
        parts = [f"app {version}: {total} candidates"]
        skips = []
        if skipped_lib:
            skips.append(f"{skipped_lib} lib-bank")
        if skipped_runtime:
            skips.append(f"{skipped_runtime} runtime")
        if skipped_bank:
            skips.append(f"{skipped_bank} bank-filter")
        if skipped_nonfrontier:
            skips.append(f"{skipped_nonfrontier} non-frontier")
        if skips:
            parts.append(f"skipped {', '.join(skips)}")
        parts.append(f"show {len(rows)}")
        print("; ".join(parts))
        print(f"{'addr':7} {'c':>3} {'d':>2}  fr")
        for (bank, addr), name, dref, fin, fr in rows:
            mark = "F" if fr else "."
            print(f"{bank}:{addr}  {fin:>3} {dref:>2}  {mark}")
    else:
        print(f"version {version}: {len(documented)} functions referenced in docs, "
              f"{doc_named} named, {len(documented) - doc_named} still unnamed")
        if skipped_lib or skipped_runtime or skipped_bank or skipped_nonfrontier:
            print(f"filters: skipped lib-bank={skipped_lib} runtime={skipped_runtime} "
                  f"bank={skipped_bank} non-frontier={skipped_nonfrontier}; "
                  f"{total} candidates")
        print()
        if need_bodies:
            print(f"{'addr':7} {'name':24} {'docrefs':>7} {'callsites':>9} {'fr':>3}")
            print("-" * 55)
            for (bank, addr), name, dref, fin, fr in rows:
                mark = "F" if fr else ""
                print(f"{bank}:{addr}  {name or '(UNNAMED)':24} {dref:>7} {fin:>9} {mark:>3}")
        else:
            print(f"{'addr':7} {'name':24} {'docrefs':>7} {'callsites':>9}")
            print("-" * 51)
            for (bank, addr), name, dref, fin, fr in rows:
                print(f"{bank}:{addr}  {name or '(UNNAMED)':24} {dref:>7} {fin:>9}")


if __name__ == "__main__":
    main()
