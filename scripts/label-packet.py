#!/usr/bin/env python3
"""Print a compact labeling packet for the top app worklist target.

One shot of context so a human or agent need not re-grep the tree each tick:

  - ranked worklist rows (when --top N; prefers frontier)
  - function body for row 1 (or --addr)
  - caller sites (with -B context)
  - unnamed Call_ callees in the body
  - WRAM / $7Fxx absolute touches

Usage:
  scripts/label-packet.py [version] [--addr BANK:ADDR] [--lines N]
  scripts/label-packet.py [version] --app --frontier-only --top 5
    # prints up to N ranked candidates, then full packet for #1
  scripts/label-packet.py [version] --app --include-lib --top 5
  scripts/label-packet.py [version] --app --banks 09 --top 5

  --include-lib   do not skip FatFs banks 03/05/06/07/09
  --banks LIST    only these banks (comma hex)
  --skip-banks LIST  extra banks to drop

Prefer scripts/map-next.sh for the full human lean surface (progress + proposals
+ this packet).
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
JUMP_ONLY_RX = re.compile(r"^Jump_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$")
JR_DEF_RX = re.compile(r"^jr_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$")
ANY_LABEL_RX = re.compile(r"^([A-Za-z_][\w]*)::?\s*$")
CALL_INSN_RX = re.compile(
    r"\bcall\s+(?:Call_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})|([A-Za-z_][\w]*))\b",
    re.IGNORECASE,
)
ABS_RX = re.compile(r"\$([0-9a-fA-F]{4})\b")
NAMED_CALL_RX = re.compile(r"\bcall\s+([A-Za-z_][\w]*)\b", re.IGNORECASE)


def bank_file(version, bank):
    return ROOT / "re" / version / "disassembly" / f"bank_{int(bank, 16):03x}.asm"


def find_body(version, bank, addr, full_named_span=False):
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
    named = cov.load_named(version)
    key = (f"{int(bank, 16):02x}", addr.lower())
    human = named.get(key)
    if start is None and human:
        for i, ln in enumerate(lines):
            if ln.startswith(f"{human}:") or ln.startswith(f"{human}::"):
                start = i
                break
    if start is None:
        # Orphan (no Call_/Jump_/human label): address walked from prior label.
        _orphans, orphan_meta = cov.scan_orphans(version, named)
        meta = orphan_meta.get(key)
        if meta:
            opath, ostart, oend = meta
            olines = opath.read_text(encoding="utf-8", errors="ignore").splitlines()
            return opath, (ostart, oend), olines
        return path, None, lines

    # Interior-debt packets: same span rules as scan_interior_debt — through
    # mid-function Jump_/jr_, stop at next named symbol or function-ending ret.
    if full_named_span and human:
        named_names = {
            n
            for (b, a), n in named.items()
            if b == f"{int(bank, 16):02x}" and cov.is_rom_code_symbol(n, a)
        }
        j = start + 1
        while j < len(lines):
            m = ANY_LABEL_RX.match(lines[j])
            if m and m.group(1) in named_names and m.group(1) != human:
                break
            if re.match(r"^\s+reti?\s*$", lines[j], re.I):
                k = j + 1
                while k < len(lines) and (
                    not lines[k].strip() or lines[k].strip().startswith(";")
                ):
                    k += 1
                if k >= len(lines):
                    j += 1
                    break
                if JUMP_ONLY_RX.match(lines[k]):
                    code_i = k + 1
                    while code_i < len(lines) and (
                        not lines[code_i].strip()
                        or lines[code_i].strip().startswith(";")
                    ):
                        code_i += 1
                    if code_i < len(lines) and cov.ENTRY_PROLOGUE_RX.match(lines[code_i]):
                        j += 1
                        break
                    j = k
                    continue
                j += 1
                break
            j += 1
        return path, (start, j), lines

    j = start + 1
    while j < len(lines):
        if ANY_LABEL_RX.match(lines[j]) or CALL_DEF_RX.match(lines[j]):
            break
        # Match coverage body_until: stop before unlabeled orphan prologue.
        if re.match(r"^\s+reti?\s*$", lines[j], re.I):
            k = j + 1
            while k < len(lines) and (not lines[k].strip() or lines[k].strip().startswith(";")):
                k += 1
            if k < len(lines) and re.match(r"^\s+add\s+sp,\s*-\$", lines[k], re.I):
                j += 1
                break
        j += 1
    return path, (start, j), lines


def list_interior_autos(lines, start, end):
    """Return (jumps, jrs) label strings inside [start, end)."""
    jumps = []
    jrs = []
    for ln in lines[start:end]:
        if JUMP_ONLY_RX.match(ln):
            jumps.append(ln.rstrip(":"))
        elif JR_DEF_RX.match(ln):
            jrs.append(ln.rstrip(":"))
    return jumps, jrs


def find_callers(version, bank, addr, named, context=6):
    label = f"Call_{int(bank, 16):03x}_{addr.lower()}"
    jump = f"Jump_{int(bank, 16):03x}_{addr.lower()}"
    human = named.get((f"{int(bank, 16):02x}", addr.lower()), "")
    patterns = [f"call {label}", f"jp {jump}", f"jp z, {jump}", f"jp nz, {jump}"]
    if human:
        patterns.append(f"call {human}")
        patterns.append(f"jp {human}")
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


def rank_rows(version, frontier_only=False, include_lib=False, only_banks=None, skip_banks=None):
    """Return ranked unnamed rows: (key, docs, fanin, is_frontier)."""
    rows, _skips, _extras = cov.rank_candidates(
        version,
        frontier_only=frontier_only,
        include_lib=include_lib,
        only_banks=only_banks,
        skip_banks=skip_banks,
        show_all=False,
        skip_runtime=True,
        app_mode=True,
    )
    out = []
    for key, _name, dref, fin, fr, orphan, kind, _abs in rows:
        out.append((key, dref, fin, fr, orphan, kind))
    return out


def pick_filters(args):
    """Parse --include-lib / --banks / --skip-banks; return (include_lib, only, skip)."""
    include_lib = "--include-lib" in args
    only_banks = None
    skip_banks = set()
    if "--banks" in args:
        i = args.index("--banks")
        only_banks = cov.parse_bank_list(args[i + 1])
    if "--skip-banks" in args:
        i = args.index("--skip-banks")
        skip_banks = cov.parse_bank_list(args[i + 1])
    return include_lib, only_banks, skip_banks


def pick_target(version, args, include_lib=False, only_banks=None, skip_banks=None):
    if "--addr" in args:
        i = args.index("--addr")
        raw = args[i + 1]
        bank, addr = raw.split(":")
        return f"{int(bank, 16):02x}", addr.lower(), "cli"

    # Prefer frontier-only worklist; fall back to plain ranking.
    for frontier_only in (True, False):
        rows = rank_rows(
            version,
            frontier_only=frontier_only,
            include_lib=include_lib,
            only_banks=only_banks,
            skip_banks=skip_banks,
        )
        if rows:
            (bank, addr), _dref, _fin, fr, orphan, kind = rows[0]
            if fr:
                mark = "F"
            elif orphan:
                mark = "O"
            elif kind == "debt":
                mark = "D"
            elif kind == "jump":
                mark = "J"
            else:
                mark = "."
            return bank, addr, mark
    return None, None, None


def print_picker(version, top, frontier_prefer=True, include_lib=False, only_banks=None, skip_banks=None):
    """Print compact ranked candidates. Returns rows used (may be empty)."""
    mode = "app"
    if include_lib:
        mode = "app+lib"
    if only_banks is not None:
        mode = f"banks={','.join(sorted(only_banks))}"

    if frontier_prefer:
        rows = rank_rows(
            version,
            frontier_only=True,
            include_lib=include_lib,
            only_banks=only_banks,
            skip_banks=skip_banks,
        )
        if rows:
            mode = f"frontier/{mode}"
        else:
            rows = rank_rows(
                version,
                frontier_only=False,
                include_lib=include_lib,
                only_banks=only_banks,
                skip_banks=skip_banks,
            )
    else:
        rows = rank_rows(
            version,
            frontier_only=False,
            include_lib=include_lib,
            only_banks=only_banks,
            skip_banks=skip_banks,
        )

    show = rows[:top] if top else rows
    print(f"=== WORKLIST ({mode}, show {len(show)}/{len(rows)}) ===")
    if not show:
        print("  (empty)")
        print()
        return rows
    print("addr      c  d  fr")
    for (bank, addr), dref, fin, fr, orphan, kind in show:
        if kind == "debt":
            mark = "D"
        elif fr:
            mark = "F"
        elif orphan:
            mark = "O"
        elif kind == "jump":
            mark = "J"
        else:
            mark = "."
        print(f"{bank}:{addr}  {fin:3d}  {dref:2d}  {mark}")
    if any(r[5] == "debt" for r in show):
        print("# D = interior debt on named fn (c=Jump_ count, d=jr_ count)")
    print()
    return rows


def main():
    args = sys.argv[1:]
    body_lines = 50
    if "--lines" in args:
        i = args.index("--lines")
        body_lines = int(args[i + 1])
        del args[i:i + 2]
    top = None
    if "--top" in args:
        i = args.index("--top")
        top = int(args[i + 1])
        del args[i:i + 2]

    include_lib, only_banks, skip_banks = pick_filters(args)

    # swallow coverage-style flags (values already parsed)
    strip = {"--frontier-only", "--app", "--include-lib"}
    cleaned = []
    i = 0
    while i < len(args):
        a = args[i]
        if a in strip:
            i += 1
            continue
        if a in ("--banks", "--skip-banks"):
            i += 2
            continue
        cleaned.append(a)
        i += 1
    args = cleaned

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
    addr_mode = "--addr" in args

    if top is not None and not addr_mode:
        print_picker(
            version,
            top,
            frontier_prefer=True,
            include_lib=include_lib,
            only_banks=only_banks,
            skip_banks=skip_banks,
        )

    bank, addr, mark = pick_target(
        version,
        args,
        include_lib=include_lib,
        only_banks=only_banks,
        skip_banks=skip_banks,
    )
    if not bank:
        print("NO_TARGET")
        print("needs_judgment: 0")
        return 0

    key = (bank, addr)
    human = named.get(key, "")
    is_debt = mark == "D"
    path, span, lines = find_body(version, bank, addr, full_named_span=is_debt)
    print(f"TARGET {bank}:{addr}  mark={mark}  name={human or '(UNNAMED)'}")
    print(f"FILE {path}")
    print()

    body_text = ""
    if span:
        start, end = span
        if is_debt:
            jumps, jrs = list_interior_autos(lines, start, end)
            print(f"=== INTERIOR AUTO LABELS (Jump_={len(jumps)} jr_={len(jrs)}) ===")
            for lab in jumps[:40]:
                print(f"  {lab}")
            if len(jumps) > 40:
                print(f"  … {len(jumps) - 40} more Jump_")
            for lab in jrs[:20]:
                print(f"  {lab}")
            if len(jrs) > 20:
                print(f"  … {len(jrs) - 20} more jr_")
            if not jumps and not jrs:
                print("  (none)")
            print()
            print(
                "Interior debt: CF notes should exist in notes.json. "
                "Name labels via kernel.sym — see ./scripts/map-interior.sh"
            )
            print()

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

    # Abs touches — for debt, scan the full named span, not just the truncated body.
    abs_source = body_text
    if is_debt and span:
        abs_source = "\n".join(lines[span[0]:span[1]])
    print("=== ABS TOUCHES (WRAM / FPGA / interesting) ===")
    abs_hits = collections.Counter()
    for m in ABS_RX.finditer(abs_source):
        v = int(m.group(1), 16)
        if v >= 0xC000 or (0x7F00 <= v <= 0x7FFF) or (0xA000 <= v <= 0xBFFF):
            abs_hits[f"${m.group(1).lower()}"] += 1
    if abs_hits:
        for a, n in abs_hits.most_common(20):
            wname = ""
            if a.startswith("$d") or a.startswith("$c"):
                wkey = ("00", a[1:])
                wname = named.get(wkey, "")
            extra = f"  ({wname})" if wname else ""
            print(f"  {a} x{n}{extra}")
        if len(abs_hits) > 20:
            print(f"  … {len(abs_hits) - 20} more")
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
    if is_debt:
        reasons.append("interior-debt")
    if abs_hits:
        reasons.append("abs-touches")
    if len(code_lines) > 25:
        reasons.append("large-body")
    if seen:
        reasons.append("unnamed-callees")
    # Tiny pure ALU / known wrapper shapes → low judgment
    if not is_debt and not abs_hits and len(code_lines) <= 8 and not seen:
        needs = 0
        reasons = ["mechanical-candidate"]
    print(f"needs_judgment: {needs}")
    print(f"judgment_reasons: {','.join(reasons) or 'none'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
