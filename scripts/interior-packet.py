#!/usr/bin/env python3
"""Interior-label naming packet — phase after notes.json CF is complete.

Lists auto Jump_/jr_ labels inside a named function (D / interior-debt row), with
note hints and code snippets. Optionally applies kernel.sym entries from a file.

Usage:
  scripts/interior-packet.py [version] --app --top 5
  scripts/interior-packet.py [version] --app --addr 04:46f4
  scripts/interior-packet.py [version] --app --include-lib --top 5
  scripts/interior-packet.py [version] --apply interior-names.txt

Apply file format (one per line, # comments ok):
  04:48f5 DrawTimeAutosaveScreen_redraw
  04:4906 DrawTimeAutosaveScreen_hiliteDirty

Prefer scripts/map-interior.sh for the full loop surface.
"""

import importlib.util
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

sys.path.insert(0, str(ROOT / "scripts"))
spec = importlib.util.spec_from_file_location(
    "doc_symbol_coverage", ROOT / "scripts" / "doc-symbol-coverage.py"
)
cov = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cov)

lp_spec = importlib.util.spec_from_file_location(
    "label_packet", ROOT / "scripts" / "label-packet.py"
)
lp = importlib.util.module_from_spec(lp_spec)
lp_spec.loader.exec_module(lp)

AUTO_REF_RX = re.compile(r"\b(Jump|jr)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})\b")
AUTO_LABEL_RX = re.compile(
    r"^(Jump|jr)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$", re.I
)
SYM_LINE_RX = re.compile(
    r"^([0-9a-fA-F]{1,2}):([0-9a-fA-F]{4})\s+([A-Za-z_][\w]*)\s*(?:;.*)?$"
)
# RGBDS builtins that must not be used as label names (subset — extend if make fails).
RGBDS_RESERVED = {
    "strlen", "strcat", "strchr", "strcmp", "strcpy", "strncpy", "strrchr",
    "strstr", "strtol", "strtoul", "sizeof", "def", "end", "section", "include",
}


def parse_auto_label(label):
    m = AUTO_LABEL_RX.match(label if label.endswith(":") else label + ":")
    if not m:
        return None, None
    bank = f"{int(m.group(2), 16):02x}"
    addr = m.group(3).lower()
    return (bank, addr), m.group(1).lower()


def load_note_hints(version, bank, addr):
    """Map (bank, addr) -> hint snippet from parent notes block."""
    path = ROOT / "re" / version / "notes.json"
    if not path.is_file():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    lines = []
    for block in data.get("blocks", []):
        try:
            b = f"{int(block['bank']):02x}"
        except (KeyError, TypeError, ValueError):
            continue
        if b == bank and str(block.get("addr", "")).lower() == addr:
            lines = block.get("lines", [])
            break
    hints = {}
    for line in lines:
        for m in AUTO_REF_RX.finditer(line):
            kind, bbb, aaa = m.group(1), m.group(2), m.group(3)
            key = (f"{int(bbb, 16):02x}", aaa.lower())
            start = max(0, m.start() - 40)
            end = min(len(line), m.end() + 40)
            snippet = line[start:end].strip()
            if key not in hints or len(snippet) > len(hints[key]):
                hints[key] = snippet
    return hints


def count_asm_interior(version, bank, addr):
    path, span, lines = lp.find_body(version, bank, addr, full_named_span=True)
    if not span:
        return 0, 0, path, span, lines
    jumps, jrs = lp.list_interior_autos(lines, span[0], span[1])
    return len(jumps), len(jrs), path, span, lines


def list_unnamed_interior(version, bank, addr, code_lines=4, max_list=None):
    named = cov.load_named(version)
    parent = named.get((bank, addr), "")
    nj, njr, path, span, lines = count_asm_interior(version, bank, addr)
    if not span:
        return parent, [], path, span, nj, njr

    hints = load_note_hints(version, bank, addr)
    jumps, jrs = lp.list_interior_autos(lines, span[0], span[1])
    out = []
    for lab in jumps + jrs:
        key, kind = parse_auto_label(lab)
        if not key:
            continue
        if key in named:
            continue
        idx = None
        for i, ln in enumerate(lines):
            if ln.rstrip(":") == lab:
                idx = i
                break
        preview = []
        if idx is not None:
            for ln in lines[idx : idx + 1 + code_lines]:
                preview.append(ln.rstrip())
        out.append(
            {
                "key": key,
                "auto": lab,
                "kind": kind,
                "hint": hints.get(key, ""),
                "preview": preview,
                "sym_line": f"{key[0]}:{key[1]} {parent}_…",
            }
        )
    if max_list is not None:
        out = out[:max_list]
    return parent, out, path, span, nj, njr


def rank_debt_rows(
    version,
    include_lib=False,
    only_banks=None,
    skip_banks=None,
    skip_complete=False,
):
    rows, _skips, _extras = cov.rank_candidates(
        version,
        frontier_only=False,
        include_lib=include_lib,
        only_banks=only_banks,
        skip_banks=skip_banks,
        show_all=False,
        skip_runtime=True,
        app_mode=True,
    )
    debt = []
    for key, name, dref, fin, fr, orphan, kind, _abs in rows:
        if kind != "debt":
            continue
        bank, addr = key
        nj, njr, _p, _s, _l = count_asm_interior(version, bank, addr)
        remaining = nj + njr
        if skip_complete and remaining == 0:
            continue
        debt.append((key, name, fin, dref, remaining))
    return debt


def print_worklist(version, top, include_lib, only_banks, skip_banks, skip_complete):
    debt = rank_debt_rows(
        version,
        include_lib=include_lib,
        only_banks=only_banks,
        skip_banks=skip_banks,
        skip_complete=skip_complete,
    )
    mode = "app"
    if include_lib:
        mode = "app+lib"
    if only_banks is not None:
        mode = f"banks={','.join(sorted(only_banks))}"
    show = debt[:top] if top else debt
    print(f"=== INTERIOR WORKLIST ({mode}, show {len(show)}/{len(debt)}) ===")
    if not show:
        print("  (empty — all D rows cleared in asm, or none ranked)")
        print()
        return debt
    print("addr      parent                   c   d  left sym")
    for (bank, addr), name, jumps, jrs, remaining in show:
        print(
            f"{bank}:{addr}  {name:24} {jumps:3d} {jrs:2d}  {remaining:4d}"
        )
    print("# left = auto Jump_/jr_ still in asm (regen after sym edits)")
    print()
    return debt


def pick_target(version, args, include_lib, only_banks, skip_banks, skip_complete):
    if "--addr" in args:
        i = args.index("--addr")
        raw = args[i + 1]
        bank, addr = raw.split(":")
        return f"{int(bank, 16):02x}", addr.lower()

    debt = rank_debt_rows(
        version,
        include_lib=include_lib,
        only_banks=only_banks,
        skip_banks=skip_banks,
        skip_complete=skip_complete,
    )
    if not debt:
        return None, None
    (bank, addr), _name, _j, _d, _r = debt[0]
    return bank, addr


def validate_name(name, named_values, parent):
    if not re.fullmatch(r"[A-Za-z_][\w]*", name):
        return f"invalid identifier: {name}"
    if name.lower() in RGBDS_RESERVED:
        return f"RGBDS reserved name: {name}"
    if name in named_values:
        return f"duplicate name: {name}"
    if parent and not name.startswith(parent):
        return f"warn: {name} does not start with parent {parent}"
    return None


def load_sym(path):
    named = {}
    lines = path.read_text(encoding="utf-8").splitlines() if path.is_file() else []
    for line in lines:
        raw = line.split(";", 1)[0].strip()
        parts = raw.split()
        if len(parts) >= 2 and ":" in parts[0]:
            bank, addr = parts[0].split(":")
            named[(f"{int(bank, 16):02x}", addr.lower())] = parts[1]
    return named, lines


def apply_interior_file(version, apply_path):
    sym_path = ROOT / "re" / version / "kernel.sym"
    named, sym_lines = load_sym(sym_path)
    used_names = set(named.values())

    if apply_path == "-":
        text = sys.stdin.read()
    else:
        text = Path(apply_path).read_text(encoding="utf-8")

    entries = []
    errors = []
    warnings = []
    for n, raw in enumerate(text.splitlines(), 1):
        line = raw.split(";", 1)[0].strip()
        if not line or line.startswith("#"):
            continue
        m = SYM_LINE_RX.match(line)
        if not m:
            errors.append(f"line {n}: bad format: {raw!r}")
            continue
        bank = f"{int(m.group(1), 16):02x}"
        addr = m.group(2).lower()
        name = m.group(3)
        key = (bank, addr)

        if key in named:
            if named[key] == name:
                continue
            errors.append(f"line {n}: {bank}:{addr} already {named[key]!r}")
            continue

        parent = ""
        spans = cov.named_rom_spans(named)
        for _a, _k, pname in spans.get(bank, []):
            if _a <= int(addr, 16):
                parent = pname
            else:
                break

        err = validate_name(name, used_names, parent)
        if err and err.startswith("warn:"):
            warnings.append(f"line {n}: {err}")
        elif err:
            errors.append(f"line {n}: {err}")
            continue

        entries.append((bank, addr, name, parent))
        used_names.add(name)

    if errors:
        for e in errors:
            print(e, file=sys.stderr)
        return 1
    if not entries:
        print("apply: 0 new entries")
        return 0

    while sym_lines and not sym_lines[-1].strip():
        sym_lines.pop()
    sym_lines.append("")
    sym_lines.append("; Interior labels (scripts/interior-packet.py --apply)")
    by_parent = {}
    for bank, addr, name, parent in entries:
        by_parent.setdefault(parent or "?", []).append((bank, addr, name))
    for parent in sorted(by_parent):
        sym_lines.append(f"; --- {parent} ---")
        for bank, addr, name in sorted(by_parent[parent], key=lambda x: x[1]):
            sym_lines.append(f"{bank}:{addr} {name}")
    sym_lines.append("")

    sym_path.write_text("\n".join(sym_lines) + "\n", encoding="utf-8")
    print(f"applied {len(entries)} interior sym entries to {sym_path}")
    for w in warnings:
        print(w, file=sys.stderr)
    return 0


def main():
    args = sys.argv[1:]
    top = 5
    max_labels = 40
    skip_complete = "--skip-complete" in args
    include_lib, only_banks, skip_banks = lp.pick_filters(args)

    if "--top" in args:
        i = args.index("--top")
        top = int(args[i + 1])
    if "--max-labels" in args:
        i = args.index("--max-labels")
        max_labels = int(args[i + 1])

    if "--apply" in args:
        i = args.index("--apply")
        apply_path = args[i + 1]
        version = "1.05e"
        for a in args:
            if re.fullmatch(r"[0-9]+\.[0-9a-zA-Z]+", a):
                version = a
        return apply_interior_file(version, apply_path)

    cleaned = []
    i = 0
    strip = {
        "--app", "--include-lib", "--skip-complete", "--frontier-only",
    }
    while i < len(args):
        a = args[i]
        if a in strip:
            i += 1
            continue
        if a in ("--top", "--max-labels", "--banks", "--skip-banks", "--addr", "--lines"):
            i += 2
            continue
        cleaned.append(a)
        i += 1

    version = "1.05e"
    for a in cleaned:
        if re.fullmatch(r"[0-9]+\.[0-9a-zA-Z]+", a):
            version = a

    addr_mode = "--addr" in sys.argv
    if not addr_mode:
        print_worklist(
            version, top, include_lib, only_banks, skip_banks, skip_complete
        )

    bank, addr = pick_target(
        version, sys.argv, include_lib, only_banks, skip_banks, skip_complete
    )
    if not bank:
        print("NO_TARGET")
        print("interior_complete: 1")
        return 0

    parent, unnamed, path, span, total_j, total_jr = list_unnamed_interior(
        version, bank, addr, max_list=max_labels
    )
    remaining = len(unnamed)
    named = cov.load_named(version)
    sym_pending = 0
    if span:
        jumps, jrs = lp.list_interior_autos(
            path.read_text(encoding="utf-8", errors="ignore").splitlines(),
            span[0],
            span[1],
        )
        for lab in jumps + jrs:
            key, _k = parse_auto_label(lab)
            if key and key in named:
                sym_pending += 1

    print(f"TARGET {bank}:{addr}  parent={parent}")
    print(f"FILE {path}")
    print(
        f"INTERIOR asm={total_j} Jump_ + {total_jr} jr_"
        f"  unnamed={remaining}"
        f"  sym_pending_regen={sym_pending}"
    )
    print()

    hints = load_note_hints(version, bank, addr)
    if hints:
        print("=== NOTES CF (parent block) ===")
        block_path = ROOT / "re" / version / "notes.json"
        data = json.loads(block_path.read_text(encoding="utf-8"))
        for block in data.get("blocks", []):
            try:
                b = f"{int(block['bank']):02x}"
            except (KeyError, TypeError, ValueError):
                continue
            if b == bank and str(block.get("addr", "")).lower() == addr:
                for line in block.get("lines", []):
                    print(f"  {line}")
                break
        print()

    if not unnamed:
        print("=== UNNAMED INTERIOR LABELS ===")
        if sym_pending:
            print(f"  (none in asm — {sym_pending} in kernel.sym awaiting regen)")
            print("  Run: ./scripts/regen-disasm.sh", version)
        else:
            print("  (none — function interior complete)")
        print()
        print("interior_complete: 1")
        print("needs_regen: 1" if sym_pending else "needs_regen: 0")
        return 0

    print(f"=== UNNAMED INTERIOR LABELS (show {len(unnamed)}, cap --max-labels {max_labels}) ===")
    print("# Add to kernel.sym as bank:addr Name  (Name = ParentFn_role, not a top-level API)")
    for item in unnamed:
        b, a = item["key"]
        print(f"\n{b}:{a}  auto={item['auto']}  ({item['kind']})")
        if item["hint"]:
            print(f"  note: {item['hint']}")
        for ln in item["preview"]:
            print(f"    {ln}")
    if remaining > len(unnamed):
        print(f"\n  … {remaining - len(unnamed)} more unnamed (re-run after batch or raise --max-labels)")
    print()

    print("=== APPLY ===")
    print("  Write names to a file, one per line, then:")
    print(f"  python3 scripts/interior-packet.py {version} --apply names.txt")
    print(f"  ./scripts/regen-disasm.sh {version}")
    print()
    print("interior_complete: 0")
    print(f"needs_regen: 0")
    print(f"batch_remaining: {remaining}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
