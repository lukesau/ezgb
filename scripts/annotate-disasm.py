#!/usr/bin/env python3
"""Inject persistent comment blocks from re/<version>/notes.json into bank_*.asm.

Comments are marked with '; [ezgb]' so re-running this script replaces prior injections
without duplicating. Safe to run after mgbdis regen (pair with re/<version>/kernel.sym
for human symbol names).

Usage:
  ./scripts/annotate-disasm.py 1.05e
  ./scripts/annotate-disasm.py 1.04e
"""

import json
import re
import sys
from pathlib import Path

MARKER = "; [ezgb]"
ROOT = Path(__file__).resolve().parents[1]


def load_notes(version):
    path = ROOT / "re" / version / "notes.json"
    if not path.is_file():
        print(f"error: missing {path}", file=sys.stderr)
        sys.exit(1)
    data = json.loads(path.read_text())
    if not data or "blocks" not in data:
        print(f"error: {path} has no blocks", file=sys.stderr)
        sys.exit(1)
    return path, data["blocks"]


def load_sym_names(version):
    """Map (bank, addr_hex) -> human label from kernel.sym, if present.

    mgbdis renames labels it finds in kernel.sym (e.g. Call_000_0de4 ->
    SdMenuMain), so notes must be matched by that human name once assigned.
    """
    names = {}
    path = ROOT / "re" / version / "kernel.sym"
    if not path.is_file():
        return names
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.split(";", 1)[0].strip()
        parts = line.split()
        if len(parts) >= 2 and ":" in parts[0]:
            bank, addr = parts[0].split(":")
            names[(int(bank, 16), addr.lower())] = parts[1]
    return names


# Matches any label definition line: "Name:" or "Name::" (exported).
LABEL_DEF_RE = re.compile(r"^([A-Za-z_][\w]*)::?$")


def make_label_matcher(bank, addr, sym_name):
    """Return a predicate matching the label def for (bank, addr).

    Accepts either the human name assigned in kernel.sym (mgbdis emits it as
    Name:: after a regen) or the raw mgbdis form *_bbb_aaaa: for still-unnamed
    addresses.
    """
    bank = int(bank)
    addr = int(addr, 16) if isinstance(addr, str) else int(addr)
    suffix = f"_{bank:03d}_{addr:04x}"

    def matches(line):
        m = LABEL_DEF_RE.match(line.rstrip())
        if not m:
            return False
        label = m.group(1)
        if sym_name and label == sym_name:
            return True
        return label.lower().endswith(suffix)

    return matches


def strip_injected(lines):
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == MARKER or line.strip().startswith(MARKER + " "):
            i += 1
            while i < len(lines) and (
                lines[i].startswith(";") or lines[i].strip() == ""
            ):
                i += 1
            continue
        out.append(line)
        i += 1
    return out


def inject_before_label(lines, matches, comment_lines):
    for i, line in enumerate(lines):
        if matches(line):
            block = [MARKER + "\n"]
            for text in comment_lines:
                block.append(f"; {text}\n")
            block.append("\n")
            return lines[:i] + block + lines[i:]
    return None


def inject_after_section(lines, comment_lines):
    for i, line in enumerate(lines):
        if line.startswith("SECTION "):
            block = ["\n", MARKER + "\n"]
            for text in comment_lines:
                block.append(f"; {text}\n")
            block.append("\n")
            return lines[: i + 1] + block + lines[i + 1 :]
    return None


def annotate_bank(path, blocks_for_bank, sym_names):
    text = path.read_text()
    lines = text.splitlines(keepends=True)
    lines = strip_injected(lines)

    missing = []
    for block in blocks_for_bank:
        bank = block["bank"]
        addr = block["addr"]
        at = block.get("at", "label")
        comment_lines = block.get("lines") or []
        if not comment_lines:
            continue

        addr_str = addr if isinstance(addr, str) else f"{addr:04x}"
        if at == "section":
            new_lines = inject_after_section(lines, comment_lines)
            if new_lines is None:
                missing.append(f"bank {bank} section (addr ${addr_str})")
            else:
                lines = new_lines
        else:
            sym_name = sym_names.get((int(bank), addr_str.lower()))
            matcher = make_label_matcher(bank, addr, sym_name)
            new_lines = inject_before_label(lines, matcher, comment_lines)
            if new_lines is None:
                missing.append(f"bank {bank} addr ${addr_str} (no label)")
            else:
                lines = new_lines

    path.write_text("".join(lines))
    return missing


def main():
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <version>", file=sys.stderr)
        print("  example: {0} 1.05e".format(sys.argv[0]), file=sys.stderr)
        sys.exit(2)

    version = sys.argv[1]
    notes_path, blocks = load_notes(version)
    sym_names = load_sym_names(version)
    disasm = ROOT / "re" / version / "disassembly"
    if not disasm.is_dir():
        print(f"error: missing {disasm}", file=sys.stderr)
        sys.exit(1)

    by_bank = {}
    for block in blocks:
        by_bank.setdefault(int(block["bank"]), []).append(block)

    all_missing = []
    for bank in sorted(by_bank):
        bank_file = disasm / f"bank_{bank:03d}.asm"
        if not bank_file.is_file():
            all_missing.append(f"bank {bank} (no {bank_file.name})")
            continue
        missing = annotate_bank(bank_file, by_bank[bank], sym_names)
        all_missing.extend(missing)
        print(f"annotated {bank_file.relative_to(ROOT)}")

    print(f"from {notes_path.relative_to(ROOT)}")
    if all_missing:
        print("warning: could not place:", file=sys.stderr)
        for m in all_missing:
            print(f"  - {m}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
