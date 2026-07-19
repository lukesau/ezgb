#!/usr/bin/env python3
"""Print a compact labeling packet for the top app worklist target.

One shot of context so an agent need not re-grep the tree each tick:

  - worklist row (prefers frontier)
  - function body
  - caller sites (with -B context)
  - unnamed Call_ callees in the body
  - WRAM / $7Fxx absolute touches

Usage:
  scripts/label-packet.py [version] [--addr BANK:ADDR] [--lines N]
  scripts/label-packet.py --frontier-only --top 5
"""

import re
import sys
import glob
import collections
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Reuse coverage helpers via import by path.
sys.path.insert(0, str(ROOT / "scripts"))
import importlib.util

spec = importlib.util.spec_from_file_location(
    "doc_symbol_coverage", ROOT / "scripts" / "doc-symbol-coverage.py"
)
cov = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cov)

CALL_DEF_RX = re.compile(
    r"^(?:Call|Jump)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$"
)
ANY_LABEL_RX = re.compile(r"^([A-Za-z_][\w]*)::?\s*$")
CALL_INSN_RX = re.compile(
    r"\bcall\s+(?:Call_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})|([A-Za-z_][\w]*))\b",
    re.IGNORECASE,
)
ABS_RX = re.compile(r"\$([0-9a-fA-F]{4})\b")
NAMED_CALL_RX = re.compile(r"\bcall\s+([A-Za-z_][\w]*)\b", re.IGNORECASE)


def bank_file(version, bank):
    return ROOT / "re" / version / "disassembly" / f"bank_{int(bank, 16):03x}.asm"


def find_body(version, bank, addr):
    path = bank_file(version, bank)
    if not path.is_file():
        return None, None, []
    lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    want = (f"{int(bank, 16):03x}", addr.lower())
    start = None
    for i, ln in enumerate(lines):
        m = CALL_DEF_RX.match(ln)
        if m and m.group(1).lower() == want[0] and m.group(2).lower() == want[1]:
            start = i
            break
        # Already-named label at this addr is rare in asm; search "; = $ADDR" no.
    if start is None:
        # Try human name from sym
        named = cov.load_named(version)
        key = (f"{int(bank, 16):02x}", addr.lower())
        human = named.get(key)
        if human:
            for i, ln in enumerate(lines):
                if ln.startswith(f"{human}:") or ln.startswith(f"{human}::"):
                    start = i
                    break
    if start is None:
        return path, None, lines
    j = start + 1
    while j < len(lines) and not ANY_LABEL_RX.match(lines[j]) and not CALL_DEF_RX.match(lines[j]):
        j += 1
    return path, (start, j), lines


def find_callers(version, bank, addr, named, context=6):
    label = f"Call_{int(bank, 16):03x}_{addr.lower()}"
    human = named.get((f"{int(bank, 16):02x}", addr.lower()), "")
    patterns = [f"call {label}"]
    if human:
        patterns.append(f"call {human}")
    hits = []
    for f in sorted(glob.glob(str(ROOT / "re" / version / "disassembly" / "bank_*.asm"))):
        lines = Path(f).read_text(encoding="utf-8", errors="ignore").splitlines()
        for i, ln in enumerate(lines):
            low = ln.lower()
            if not any(p.lower() in low for p in patterns):
                continue
            lo = max(0, i - context)
            hi = min(len(lines), i + 2)
            block = "\n".join(f"{n+1:>5}|{lines[n]}" for n in range(lo, hi))
            hits.append((Path(f).name, i + 1, block))
    return hits


def pick_target(version, args):
    if "--addr" in args:
        i = args.index("--addr")
        raw = args[i + 1]
        bank, addr = raw.split(":")
        return f"{int(bank, 16):02x}", addr.lower(), "cli"

    # Prefer frontier-only worklist; fall back to plain --app.
    for frontier_only in (True, False):
        named = cov.load_named(version)
        docs = cov.scan_docs()
        fanin = cov.scan_call_fanin(version)
        bodies, frontier = cov.scan_bodies_and_frontier(version, named)
        skip_banks = set(cov.LIB_BANKS)
        rows = []
        for key in set(docs) | set(fanin):
            bank, addr = key
            if key in named:
                continue
            if bank in skip_banks:
                continue
            if key not in bodies and fanin.get(key, 0) == 0:
                continue
            if frontier_only and key not in frontier and not (key in docs and key in bodies):
                continue
            if key in bodies and cov.is_sdcc_runtime(bodies[key]) and key not in docs:
                continue
            rows.append((key, docs.get(key, 0), fanin.get(key, 0), key in frontier))
        rows.sort(key=lambda r: (-r[3], -r[2], -r[1], r[0]))
        if rows:
            (bank, addr), dref, fin, fr = rows[0]
            return bank, addr, "F" if fr else "."
    return None, None, None


def main():
    args = sys.argv[1:]
    body_lines = 50
    if "--lines" in args:
        i = args.index("--lines")
        body_lines = int(args[i + 1])
        del args[i:i + 2]
    # swallow coverage-style flags we accept for docs
    for flag in ("--frontier-only", "--app"):
        if flag in args:
            args = [a for a in args if a != flag]
    top = None
    if "--top" in args:
        i = args.index("--top")
        top = int(args[i + 1])  # unused; pick always uses row 1
        del args[i:i + 2]
        _ = top
    version = "1.05e"
    skip_next = False
    for i, a in enumerate(args):
        if skip_next:
            skip_next = False
            continue
        if a in ("--addr", "--lines", "--top"):
            skip_next = True
            continue
        if a.startswith("--"):
            continue
        if re.fullmatch(r"[0-9]+\.[0-9a-zA-Z]+", a):
            version = a

    named = cov.load_named(version)
    bank, addr, mark = pick_target(version, args)
    if not bank:
        print("NO_TARGET")
        print("needs_judgment: 0")
        return 0

    key = (bank, addr)
    human = named.get(key, "")
    path, span, lines = find_body(version, bank, addr)
    print(f"TARGET {bank}:{addr}  mark={mark}  name={human or '(UNNAMED)'}")
    print(f"FILE {path}")
    print()

    body_text = ""
    if span:
        start, end = span
        chunk = lines[start:min(end, start + 1 + body_lines)]
        body_text = "\n".join(chunk)
        print(f"=== BODY ({start + 1}-{start + len(chunk)}) ===")
        for n, ln in enumerate(chunk, start=start + 1):
            print(f"{n:>5}|{ln}")
        if end - start - 1 > body_lines:
            print(f"     |… truncated ({end - start - 1 - body_lines} more lines)")
        print()
    else:
        print("=== BODY (not found) ===\n")

    # Unnamed callees
    print("=== UNNAMED CALLEES ===")
    seen = set()
    for m in CALL_INSN_RX.finditer(body_text):
        if m.group(1):
            cb, ca = f"{int(m.group(1), 16):02x}", m.group(2).lower()
            ck = (cb, ca)
            if ck in named or ck in seen:
                continue
            seen.add(ck)
            print(f"  {cb}:{ca}  Call_{int(cb, 16):03x}_{ca}")
        elif m.group(3):
            # named symbol call — skip
            pass
    if not seen:
        print("  (none)")
    print()

    # Abs touches
    print("=== ABS TOUCHES (WRAM / FPGA / interesting) ===")
    abs_hits = collections.Counter()
    for m in ABS_RX.finditer(body_text):
        v = int(m.group(1), 16)
        if v >= 0xC000 or (0x7F00 <= v <= 0x7FFF) or (0xA000 <= v <= 0xBFFF):
            abs_hits[f"${m.group(1).lower()}"] += 1
    if abs_hits:
        for a, n in abs_hits.most_common():
            # resolve wram name if any
            wname = ""
            if a.startswith("$d") or a.startswith("$c"):
                wkey = ("00", a[1:])
                wname = named.get(wkey, "")
            extra = f"  ({wname})" if wname else ""
            print(f"  {a} x{n}{extra}")
    else:
        print("  (none)")
    print()

    print("=== CALLERS ===")
    callers = find_callers(version, bank, addr, named, context=6)
    if not callers:
        print("  (none found)")
    else:
        for fname, line, block in callers[:8]:
            print(f"--- {fname}:{line} ---")
            print(block)
            print()
        if len(callers) > 8:
            print(f"  … {len(callers) - 8} more caller sites")
    print()

    # Judgment hint for cron/agent split
    code_lines = [ln for ln in body_text.splitlines() if cov.CODE_LINE_RX.match(ln.split("|", 1)[-1])]
    needs = 1
    reasons = []
    if abs_hits:
        reasons.append("abs-touches")
    if len(code_lines) > 25:
        reasons.append("large-body")
    if seen:
        reasons.append("unnamed-callees")
    # Tiny pure ALU / known wrapper shapes → low judgment
    if not abs_hits and len(code_lines) <= 8 and not seen:
        needs = 0
        reasons = ["mechanical-candidate"]
    print(f"needs_judgment: {needs}")
    print(f"judgment_reasons: {','.join(reasons) or 'none'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
