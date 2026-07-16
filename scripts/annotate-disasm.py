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


def label_pattern(bank, addr):
    bank = int(bank)
    addr = int(addr, 16) if isinstance(addr, str) else int(addr)
    return re.compile(
        rf"^([A-Za-z_][\w]*_{bank:03d}_{addr:04x}):$",
        re.IGNORECASE,
    )


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


def inject_before_label(lines, pattern, comment_lines):
    for i, line in enumerate(lines):
        if pattern.match(line.rstrip()):
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


def annotate_bank(path, blocks_for_bank):
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

        if at == "section":
            new_lines = inject_after_section(lines, comment_lines)
            if new_lines is None:
                missing.append(f"bank {bank} section (addr {addr:#06x})")
            else:
                lines = new_lines
        else:
            pat = label_pattern(bank, addr)
            new_lines = inject_before_label(lines, pat, comment_lines)
            if new_lines is None:
                missing.append(f"bank {bank} addr {addr:#06x} (no label)")
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
        missing = annotate_bank(bank_file, by_bank[bank])
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
