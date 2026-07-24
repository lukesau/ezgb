#!/usr/bin/env python3
"""Propagate interior Jump_/jr_ names across cross-bank FatFs clone twins.

stamp-bank-clones.py already names top-level Call_/Jump_ entry points that are
byte-identical across banks (CreateName_B3/B5/B6/B7/B9, ...). Their bodies are
identical modulo bank-local immediates, which means every interior Jump_/jr_
seam sits at the *same offset from function start* in every twin. So once one
bank's interior labels are named by hand (or by an agent reading the body),
the other banks' names are arithmetic, not re-derived reverse-engineering:

    twin_addr = twin_fn_start + (canon_label_addr - canon_fn_start)
    twin_name = f"{twin_base}_{role_suffix}"   # role_suffix copied verbatim

Each computed target is verified against the twin bank's disassembly (must
still be an auto Jump_/jr_ label at that exact address) before being proposed
or applied — if a twin's body diverges, the row is skipped, not guessed.

Usage:
  scripts/propagate-interior-clones.py [version]              # print proposals
  scripts/propagate-interior-clones.py [version] --apply      # write kernel.sym
  scripts/propagate-interior-clones.py [version] --base CreateName  # one group
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]

SUFFIX_RX = re.compile(r"^(.*)_B([0-9A-Fa-f]+)$")
AUTO_LABEL_RX = re.compile(r"^(Jump|jr)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$", re.IGNORECASE)


def load_sym(path):
    named = {}          # (bank, addr) -> name
    by_name = {}         # name -> (bank, addr)
    lines = path.read_text(encoding="utf-8").splitlines() if path.is_file() else []
    for line in lines:
        raw = line.split(";", 1)[0].strip()
        parts = raw.split()
        if len(parts) >= 2 and ":" in parts[0]:
            bank, addr = parts[0].split(":")
            key = (f"{int(bank, 16):02x}", addr.lower())
            named[key] = parts[1]
            by_name[parts[1]] = key
    return named, by_name, lines


def base_name(name):
    m = SUFFIX_RX.match(name)
    return m.group(1) if m else None


def find_clone_groups(by_name):
    """base name -> {bank: (addr, full_name)} for names shaped Base_BN."""
    groups = defaultdict(dict)
    for name, (bank, addr) in by_name.items():
        base = base_name(name)
        if base is None:
            continue
        groups[base][bank] = (addr, name)
    # Only groups with >=2 banks are actual clone twins.
    return {b: m for b, m in groups.items() if len(m) >= 2}


def load_bank_auto_labels(version, bank):
    """Set of (addr) with an auto Jump_/jr_ label still in that bank's asm."""
    path = ROOT / "re" / version / "disassembly" / f"bank_{int(bank, 16):03d}.asm"
    out = set()
    if not path.is_file():
        return out
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = AUTO_LABEL_RX.match(line.strip())
        if m:
            out.add(m.group(3).lower())
    return out


def main():
    args = sys.argv[1:]
    apply = "--apply" in args
    args = [a for a in args if a != "--apply"]
    only_base = None
    if "--base" in args:
        i = args.index("--base")
        only_base = args[i + 1]
        args = args[:i] + args[i + 2:]
    version = args[0] if args else "1.05e"

    sym_path = ROOT / "re" / version / "kernel.sym"
    named, by_name, lines = load_sym(sym_path)

    groups = find_clone_groups(by_name)
    if only_base:
        groups = {b: m for b, m in groups.items() if b == only_base}

    bank_auto_cache = {}
    proposals = []
    skipped = 0

    for base, members in sorted(groups.items()):
        # Canonical source: prefer bank 09, else lowest bank present.
        canon_bank = "09" if "09" in members else sorted(members)[0]
        canon_addr, canon_full = members[canon_bank]
        canon_start = int(canon_addr, 16)
        prefix = canon_full + "_"

        # Interior labels already named under this canonical parent.
        interior = [
            (k, n) for k, n in named.items()
            if k[0] == canon_bank and n.startswith(prefix)
        ]
        if not interior:
            continue

        for (ibank, iaddr), iname in interior:
            offset = int(iaddr, 16) - canon_start
            role = iname[len(prefix):]
            for tbank, (taddr, tfull) in members.items():
                if tbank == canon_bank:
                    continue
                twin_addr_int = int(taddr, 16) + offset
                twin_addr = f"{twin_addr_int:04x}"
                key = (tbank, twin_addr)
                if key in named:
                    continue
                if tbank not in bank_auto_cache:
                    bank_auto_cache[tbank] = load_bank_auto_labels(version, tbank)
                if twin_addr not in bank_auto_cache[tbank]:
                    skipped += 1
                    continue
                twin_name = f"{tfull}_{role}"
                if twin_name in by_name:
                    continue
                proposals.append((tbank, twin_addr, twin_name, f"{iname} +${offset:x} twin"))

    proposals.sort()
    print(f"{version}: {len(proposals)} propagated interior names ({skipped} skipped: twin body diverged)")
    for bank, addr, name, reason in proposals:
        print(f"  {bank}:{addr} {name:32} ; {reason}")

    if not apply:
        return 0

    if not proposals:
        print("applied 0 (nothing new)")
        return 0

    out = list(lines)
    while out and not out[-1].strip():
        out.pop()
    out.append("")
    out.append("; Propagated interior labels (scripts/propagate-interior-clones.py)")
    for bank, addr, name, _ in proposals:
        out.append(f"{bank}:{addr} {name}")
    out.append("")
    sym_path.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"applied {len(proposals)} sym names; run ./scripts/regen-disasm.sh {version} next")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
