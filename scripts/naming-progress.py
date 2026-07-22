#!/usr/bin/env python3
"""Naming progress for a kernel version.

Same pret unnamed.py heuristic on game.sym (auto-name ends with its address),
plus: Jump_/jr_ symbols count as named when documented in notes.json — either
cited as Jump_BBB_AAAA / jr_BBB_AAAA in a note line, or a notes block is
anchored at that bank:addr.

Usage:
  scripts/naming-progress.py [version]           # summary
  scripts/naming-progress.py [version] all       # list remaining unnamed
"""

import re
import sys
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SYMREF_RX = re.compile(r"\b(Jump|jr)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})\b")
AUTO_RX = re.compile(
    r"^(Call|Jump|jr|Data|Unknown)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4})$",
    re.IGNORECASE,
)


def load_notes_documented(version):
    """Set of (bank, addr) for Jump_/jr_ documented in notes.json."""
    path = ROOT / "re" / version / "notes.json"
    out = set()
    if not path.is_file():
        return out
    data = json.loads(path.read_text(encoding="utf-8"))
    for block in data.get("blocks", []):
        try:
            bank = f"{int(block['bank']):02x}"
        except (KeyError, TypeError, ValueError):
            continue
        addr = str(block.get("addr", "")).lower()
        if addr:
            out.add((bank, addr))
        for line in block.get("lines", []):
            for _kind, b, a in SYMREF_RX.findall(line):
                out.add((f"{int(b, 16):02x}", a.lower()))
    return out


def scan_sym(sym_path):
    """Return (total, list of (addr_field, name) for pret-unnamed symbols)."""
    total = 0
    unnamed = []
    for line in sym_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = line.split(";", 1)[0].strip()
        parts = line.split()
        if len(parts) < 2:
            continue
        total += 1
        addr_field, name = parts[0], parts[1]
        # pret unnamed.py: auto if name's last 3 chars match addr's last 3
        if name[-3:].lower() == addr_field[-3:].lower():
            unnamed.append((addr_field, name))
    return total, unnamed


def auto_key(name):
    m = AUTO_RX.match(name)
    if not m:
        return None, None
    return m.group(1), (f"{int(m.group(2), 16):02x}", m.group(3).lower())


def main():
    args = sys.argv[1:]
    version = "1.05e"
    mode = "summary"
    for a in args:
        if a in ("all", "summary"):
            mode = a
        elif re.fullmatch(r"[0-9]+\.[0-9a-zA-Z]+", a):
            version = a

    sym = ROOT / "re" / version / "disassembly" / "game.sym"
    if not sym.is_file():
        print(f"error: {sym} not found; build the disassembly first:", file=sys.stderr)
        print(f"       (cd \"{ROOT}/re/{version}/disassembly\" && make)", file=sys.stderr)
        return 1

    total, raw_unnamed = scan_sym(sym)
    documented = load_notes_documented(version)

    still = []
    notes_credited = 0
    for addr_field, name in raw_unnamed:
        kind, key = auto_key(name)
        if kind and kind.lower() in ("jump", "jr") and key in documented:
            notes_credited += 1
            continue
        still.append(name)

    raw_n = len(raw_unnamed)
    adj_n = len(still)
    raw_pct = 100.0 * (total - raw_n) / total if total else 0.0
    adj_pct = 100.0 * (total - adj_n) / total if total else 0.0

    print(
        f"Unnamed symbols: {adj_n} ({adj_pct:.2f}% complete)"
        f"  [notes-adjusted; raw mgbdis {raw_n} / {raw_pct:.2f}%;"
        f" {notes_credited} Jump_/jr_ via notes.json]"
    )

    if mode == "all":
        for sym_name in still:
            print(sym_name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
