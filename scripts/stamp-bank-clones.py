#!/usr/bin/env python3
"""Stamp kernel.sym names for identical cross-bank function copies.

Finds Call_/named entry points whose bodies match across ≥2 banks after
normalizing bank-local immediates ($4xxx–$7xxx and Call_/Jump_/jr_ targets).

1. If any copy is already named, propagate that base name to unnamed siblings
   as Name_BN (every bank gets a suffix, including bank 9).
2. Else assign Clone_<canonBank><canonAddr>_BN on each copy — links them
   without claiming FatFs/app identity.

Usage:
  scripts/stamp-bank-clones.py [version] [--dry-run]
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]
ENTRY_RX = re.compile(r"^(?:Call|Jump)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$")
ANY_RX = re.compile(r"^([A-Za-z_][\w]*)::?\s*$")
IMM_RX = re.compile(r"\$(?:[4-7][0-9a-fA-F]{3})")
SYM_RX = re.compile(r"\b(?:Call|Jump|jr)_[0-9a-fA-F]{3}_[0-9a-fA-F]{4}\b")
SUFFIX_RX = re.compile(r"^(.*)_B([0-9A-Fa-f]+)$")


def load_sym(path):
    named = {}
    lines = path.read_text(encoding="utf-8").splitlines()
    for line in lines:
        raw = line.split(";", 1)[0].strip()
        parts = raw.split()
        if len(parts) >= 2 and ":" in parts[0]:
            bank, addr = parts[0].split(":")
            named[(f"{int(bank, 16):02x}", addr.lower())] = parts[1]
    return named, lines


def normalize(body):
    out = []
    for ln in body.splitlines():
        ln = ln.split(";", 1)[0].rstrip()
        if not ln.strip():
            continue
        ln = IMM_RX.sub("$XXXX", ln)
        ln = SYM_RX.sub("SYM", ln)
        out.append(ln.strip().lower())
    return tuple(out)


def base_name(name):
    m = SUFFIX_RX.match(name)
    return m.group(1) if m else name


def stamp_name(base, bank, named, key):
    """Always Name_BN — no unsuffixed canonical."""
    candidate = f"{base}_B{int(bank, 16)}"
    if any(n == candidate and k != key for k, n in named.items()):
        candidate = f"{base}_B{int(bank, 16)}_{key[1]}"
    return candidate


def index_banks(version, named):
    by_body = defaultdict(list)
    dis = ROOT / "re" / version / "disassembly"
    for path in sorted(dis.glob("bank_*.asm")):
        bank = f"{int(path.stem.split('_')[1], 10):02x}"
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        i = 0
        while i < len(lines):
            m_e = ENTRY_RX.match(lines[i])
            m_a = ANY_RX.match(lines[i])
            if not m_e and not m_a:
                i += 1
                continue
            if m_a and m_a.group(1).startswith(("jr_", "Jump_", "Call_")):
                if not m_e:
                    j = i + 1
                    while j < len(lines) and not ANY_RX.match(lines[j]) and not ENTRY_RX.match(lines[j]):
                        j += 1
                    i = j
                    continue

            key = None
            human = None
            kind = "Named"
            if m_e:
                key = (f"{int(m_e.group(1), 16):02x}", m_e.group(2).lower())
                human = named.get(key)
                kind = "Call" if lines[i].startswith("Call_") else "Jump"
            else:
                human = m_a.group(1)
                for k, n in named.items():
                    if n == human and k[0] == bank:
                        key = k
                        break
                if key is None:
                    j = i + 1
                    while j < len(lines) and not ANY_RX.match(lines[j]) and not ENTRY_RX.match(lines[j]):
                        j += 1
                    i = j
                    continue

            j = i + 1
            while j < len(lines) and not ANY_RX.match(lines[j]) and not ENTRY_RX.match(lines[j]):
                j += 1
            body = normalize("\n".join(lines[i + 1:j]))
            if kind == "Call" and len(body) >= 2:
                by_body[body].append((key, human, bank, len(body)))
            elif kind == "Named" and len(body) >= 2:
                by_body[body].append((key, human, bank, len(body)))
            i = j
    return by_body


def compute_stamps(named, by_body):
    stamps = {}
    for body, members in by_body.items():
        banks = {m[2] for m in members}
        if len(banks) < 2:
            continue
        named_m = [m for m in members if m[1]]
        unnamed_m = [m for m in members if not m[1]]
        if not unnamed_m:
            continue

        if named_m:
            named_m = sorted(
                named_m,
                key=lambda m: (0 if m[2] == "09" else 1, m[0]),
            )
            base = base_name(named_m[0][1])
            bases = {base_name(m[1]) for m in named_m}
            if len(bases) > 1:
                continue
            reason_prefix = f"clone of {named_m[0][1]}"
        else:
            canon = sorted(members, key=lambda m: (0 if m[2] == "09" else 1, m[0][1]))[0]
            base = f"Clone_{canon[0][0]}{canon[0][1]}"
            reason_prefix = f"unnamed multi-bank clone; canon {canon[0][0]}:{canon[0][1]}"

        for key, human, bank, blen in unnamed_m:
            merged = {**named, **{k: v[0] for k, v in stamps.items()}}
            name = stamp_name(base, bank, merged, key)
            if base.startswith("Clone_") and bank not in {"03", "05", "06", "07", "09"}:
                continue
            stamps[key] = (name, f"{reason_prefix} ({blen} ops)")
    return stamps


def apply_stamps(lines, stamps):
    existing = set()
    for line in lines:
        raw = line.split(";", 1)[0].strip()
        parts = raw.split()
        if len(parts) >= 2 and ":" in parts[0]:
            b, a = parts[0].split(":")
            existing.add((f"{int(b, 16):02x}", a.lower()))

    new_items = []
    for (bank, addr), (name, reason) in sorted(stamps.items()):
        if (bank, addr) in existing:
            continue
        new_items.append((bank, addr, name, reason))

    if not new_items:
        return lines, 0

    out = list(lines)
    while out and not out[-1].strip():
        out.pop()

    out.append("")
    out.append("; Auto-stamped cross-bank clones (scripts/stamp-bank-clones.py)")
    for bank, addr, name, reason in new_items:
        out.append(f"{bank}:{addr} {name}")
    out.append("")
    return out, len(new_items)


def main():
    args = sys.argv[1:]
    dry = "--dry-run" in args
    args = [a for a in args if a != "--dry-run"]
    version = args[0] if args else "1.05e"
    sym_path = ROOT / "re" / version / "kernel.sym"

    named, lines = load_sym(sym_path)
    by_body = index_banks(version, named)
    stamps = compute_stamps(named, by_body)

    from_named = sum(1 for _, (_, r) in stamps.items() if r.startswith("clone of"))
    from_clone = len(stamps) - from_named
    print(f"{version}: {len(stamps)} stamps "
          f"({from_named} from named sibling, {from_clone} Clone_* families)")
    for (bank, addr), (name, reason) in sorted(stamps.items()):
        print(f"  {bank}:{addr} {name}  ; {reason}")

    if dry:
        return
    new_lines, n = apply_stamps(lines, stamps)
    sym_path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
    print(f"wrote {n} names to {sym_path}")


if __name__ == "__main__":
    main()
