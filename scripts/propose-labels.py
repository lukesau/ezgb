#!/usr/bin/env python3
"""Propose (and optionally apply) mechanical kernel.sym labels.

Detects high-confidence patterns without claiming app semantics beyond the shape:

  1. IRQ callback wrappers:  ld hl,$Dxxx / jp Install|RemoveCallbackSlot
  2. FarCallTrampoline thunks: decode 4 embedded bytes after the call
  3. FPGA unlock helpers: $7F00/10/20 unlock + $7Fxx write + $7FF0 commit
  4. Cross-bank clones: delegates to stamp-bank-clones.py

Usage:
  scripts/propose-labels.py [version]              # print proposals
  scripts/propose-labels.py [version] --apply      # write kernel.sym + notes stubs
  scripts/propose-labels.py [version] --dry-run    # alias for print-only
"""

import json
import re
import sys
import subprocess
from pathlib import Path
from collections import OrderedDict

ROOT = Path(__file__).resolve().parents[1]

CALL_DEF_RX = re.compile(r"^Call_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$")
ANY_LABEL_RX = re.compile(r"^([A-Za-z_][\w]*)::?\s*$")
LD_HL_ABS_RX = re.compile(r"^\s*ld\s+hl,\s*\$([0-9a-fA-F]{4})\s*$", re.I)
JP_RX = re.compile(r"^\s*jp\s+(\w+)\s*$", re.I)
CODE_RX = re.compile(r"^\s*[^;\s]")

# Known IRQ callback list bases (1.05e) → role stem
CALLBACK_LISTS = {
    "d6d3": "VBlank",
    "d6e3": "Lcd",
    "d6f3": "Timer",
    "d703": "Serial",
    "d713": "Joypad",
}

FPGA_PORT_NAMES = {
    "7fc0": "SetFpgaPage",
    "7fd0": "SetFpga7FD0",
    "7f30": "SetFpga7F30",
    "7f36": "SetRomLoadCtrl",
}


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


def iter_functions(version):
    dis = ROOT / "re" / version / "disassembly"
    for path in sorted(dis.glob("bank_*.asm")):
        bank = f"{int(path.stem.split('_')[1], 10):02x}"
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        i = 0
        while i < len(lines):
            m = CALL_DEF_RX.match(lines[i])
            if not m:
                i += 1
                continue
            key = (f"{int(m.group(1), 16):02x}", m.group(2).lower())
            j = i + 1
            while j < len(lines) and not ANY_LABEL_RX.match(lines[j]) and not CALL_DEF_RX.match(lines[j]):
                j += 1
            body_lines = lines[i + 1:j]
            yield path, bank, key, body_lines, i
            i = j


def code_ops(body_lines):
    ops = []
    for ln in body_lines:
        raw = ln.split(";", 1)[0].rstrip()
        if CODE_RX.match(raw):
            ops.append(raw.strip())
    return ops


def code_ops_until_ret(body_lines):
    """Like code_ops but stop at the first unconditional ret (ignore trailing orphans)."""
    ops = []
    for ln in body_lines:
        raw = ln.split(";", 1)[0].rstrip()
        if not CODE_RX.match(raw):
            continue
        op = raw.strip()
        ops.append(op)
        if re.match(r"^ret\b", op, re.I):
            break
    return ops


def propose_callback_wrappers(version, named):
    out = []
    for path, bank, key, body_lines, _ in iter_functions(version):
        if key in named:
            continue
        ops = code_ops(body_lines)
        if len(ops) != 2:
            continue
        m_hl = LD_HL_ABS_RX.match(ops[0])
        m_jp = JP_RX.match(ops[1])
        if not m_hl or not m_jp:
            continue
        wram = m_hl.group(1).lower()
        target = m_jp.group(1)
        role = CALLBACK_LISTS.get(wram)
        if not role:
            continue
        if target == "InstallCallbackSlot":
            name = f"Register{role}Callback"
        elif target == "RemoveCallbackSlot":
            name = f"Remove{role}Callback"
        else:
            continue
        # Avoid colliding with an existing identical name at another addr
        if any(n == name and k != key for k, n in named.items()):
            continue
        out.append({
            "key": key,
            "name": name,
            "kind": "callback-wrapper",
            "reason": f"ld hl,${wram}; jp {target}",
            "note": [
                f"{name}: HL=${wram} (w{role}Callbacks); jp {target}.",
                "Auto-proposed by scripts/propose-labels.py.",
            ],
        })
    return out


def propose_farcall_thunks(version, named):
    """Decode FarCallTrampoline thunks from ROM bytes."""
    rom_path = ROOT / "re" / version / "kernel.gb"
    if not rom_path.is_file():
        return []
    rom = rom_path.read_bytes()
    # FarCallTrampoline is at 00:078d in 1.05e — find from sym if named
    tramp_addr = None
    for (b, a), n in named.items():
        if n == "FarCallTrampoline" and b == "00":
            tramp_addr = int(a, 16)
            break
    if tramp_addr is None:
        tramp_addr = 0x078d
    tramp_lo = tramp_addr & 0xFF
    tramp_hi = (tramp_addr >> 8) & 0xFF
    call_pat = bytes([0xCD, tramp_lo, tramp_hi])

    out = []
    for path, bank, key, body_lines, _ in iter_functions(version):
        if key in named:
            continue
        if bank != "00":
            continue
        # Bank0 CPU addr == file offset
        addr = int(key[1], 16)
        # Scan function ROM region (~64 bytes)
        chunk = rom[addr:addr + 64]
        i = chunk.find(call_pat)
        if i < 0:
            continue
        data = chunk[i + 3:i + 7]
        if len(data) < 4:
            continue
        dest = data[0] | (data[1] << 8)
        dest_bank = data[2]
        # Sanity: ROMX targets live in $4000-$7FFF; bank 0 rare for farcall
        if not (0x4000 <= dest <= 0x7FFF):
            continue
        if dest_bank == 0 or dest_bank > 0x1F:
            continue
        name = f"FarCall_{dest_bank:02X}_{dest:04x}"
        # rgbds-safe: keep hex lowercase for consistency with existing FarCall_*
        name = f"FarCall_{dest_bank:02x}_{dest:04x}"
        if any(n == name for n in named.values()):
            continue
        out.append({
            "key": key,
            "name": name,
            "kind": "farcall-thunk",
            "reason": f"FarCallTrampoline → {dest_bank:02x}:{dest:04x}",
            "note": [
                f"{name}: stack thunk via FarCallTrampoline to {dest_bank:02x}:{dest:04x}.",
                "Auto-proposed by scripts/propose-labels.py.",
            ],
        })
    return out


def propose_fpga_helpers(version, named):
    """Match unlock $7F00/10/20 + write one $7Fxx + commit $7FF0."""
    out = []
    used = set(named.values())
    unlock = [
        re.compile(r"ld\s+(?:bc|hl|de),\s*\$7f00", re.I),
        re.compile(r"ld\s+a,\s*\$e1", re.I),
        re.compile(r"ld\s+(?:bc|hl|de),\s*\$7f10", re.I),
        re.compile(r"ld\s+a,\s*\$e2", re.I),
        re.compile(r"ld\s+(?:bc|hl|de),\s*\$7f20", re.I),
        re.compile(r"ld\s+a,\s*\$e3", re.I),
    ]
    port_rx = re.compile(r"ld\s+(?:bc|hl|de),\s*\$7f([0-9a-fA-F]{2})", re.I)
    commit_rx = re.compile(r"ld\s+(?:bc|hl|de),\s*\$7ff0", re.I)

    for path, bank, key, body_lines, _ in iter_functions(version):
        if key in named:
            continue
        # Only the first basic block through ret — mgbdis often leaves the next
        # unlabeled function's bytes in the same "body" until the next Call_.
        text = "\n".join(code_ops_until_ret(body_lines))
        if not text:
            continue
        if not all(rx.search(text) for rx in unlock):
            continue
        if not commit_rx.search(text):
            continue
        ports = [m.group(1).lower() for m in port_rx.finditer(text)]
        data_ports = [p for p in ports if p not in {"00", "10", "20", "f0"}]
        if len(set(data_ports)) != 1:
            continue
        port = "7f" + data_ports[0]
        base = FPGA_PORT_NAMES.get(port) or f"SetFpga7F{data_ports[0].upper()}"
        # Always Name_BN (matches SetFpgaPage_B0 / SetFpga7F30_B2 convention)
        name = f"{base}_B{int(bank, 16)}"
        if name in used:
            continue
        used.add(name)
        out.append({
            "key": key,
            "name": name,
            "kind": "fpga-helper",
            "reason": f"FPGA unlock/commit writing ${port}",
            "note": [
                f"{name}: unlock $7F00/10/20, write stack/reg to ${port}, commit $7FF0.",
                "Auto-proposed by scripts/propose-labels.py.",
            ],
        })
    return out


def propose_clones(version, named):
    """Run stamp-bank-clones dry-run and parse its stdout."""
    proc = subprocess.run(
        [sys.executable, str(ROOT / "scripts" / "stamp-bank-clones.py"), version, "--dry-run"],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    out = []
    for line in proc.stdout.splitlines():
        # "  03:4101 MemSet8_B3  ; clone of MemSet8 (...)"
        m = re.match(r"\s*([0-9a-fA-F]+):([0-9a-fA-F]+)\s+(\S+)\s+;\s*(.*)", line)
        if not m:
            continue
        key = (f"{int(m.group(1), 16):02x}", m.group(2).lower())
        if key in named:
            continue
        out.append({
            "key": key,
            "name": m.group(3),
            "kind": "bank-clone",
            "reason": m.group(4),
            "note": [
                f"{m.group(3)}: {m.group(4)}.",
                "Auto-proposed by scripts/propose-labels.py (stamp-bank-clones).",
            ],
        })
    return out


def merge_notes(version, proposals):
    notes_path = ROOT / "re" / version / "notes.json"
    if notes_path.is_file():
        data = json.loads(notes_path.read_text(encoding="utf-8"))
    else:
        data = {"blocks": []}
    blocks = data.setdefault("blocks", [])
    existing = set()
    for b in blocks:
        bank = b.get("bank")
        addr = str(b.get("addr", "")).lower()
        if isinstance(bank, int):
            existing.add((bank, addr))
        else:
            existing.add((int(str(bank), 16), addr))
    added = 0
    for p in proposals:
        bank, addr = p["key"]
        bnum = int(bank, 16)
        if (bnum, addr) in existing:
            continue
        blocks.append({
            "bank": bnum,
            "addr": addr,
            "lines": p["note"],
        })
        existing.add((bnum, addr))
        added += 1
    notes_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    return added


def apply_sym(lines, proposals, named):
    existing_keys = set(named)
    existing_names = set(named.values())
    new_items = []
    for p in proposals:
        if p["key"] in existing_keys:
            continue
        if p["name"] in existing_names:
            continue
        new_items.append(p)
        existing_names.add(p["name"])
        existing_keys.add(p["key"])

    if not new_items:
        return lines, []

    out = list(lines)
    while out and not out[-1].strip():
        out.pop()
    out.append("")
    out.append("; Auto-proposed mechanical labels (scripts/propose-labels.py)")
    by_kind = OrderedDict()
    for p in new_items:
        by_kind.setdefault(p["kind"], []).append(p)
    for kind, items in by_kind.items():
        out.append(f"; --- {kind} ---")
        for p in sorted(items, key=lambda x: x["key"]):
            bank, addr = p["key"]
            out.append(f"{bank}:{addr} {p['name']}")
    out.append("")
    return out, new_items


def main():
    args = sys.argv[1:]
    apply = "--apply" in args
    args = [a for a in args if a not in {"--apply", "--dry-run"}]
    version = args[0] if args else "1.05e"

    sym_path = ROOT / "re" / version / "kernel.sym"
    named, lines = load_sym(sym_path)

    proposals = []
    proposals += propose_callback_wrappers(version, named)
    proposals += propose_farcall_thunks(version, named)
    proposals += propose_fpga_helpers(version, named)
    proposed_keys = {p["key"] for p in proposals}
    used_names = set(named.values()) | {p["name"] for p in proposals}
    for p in propose_clones(version, named):
        if p["key"] in proposed_keys or p["key"] in named:
            continue
        if p["name"] in used_names:
            continue
        proposals.append(p)
        proposed_keys.add(p["key"])
        used_names.add(p["name"])

    seen = set()
    uniq = []
    for p in proposals:
        if p["key"] in seen or p["key"] in named:
            continue
        if p["name"] in named.values() or any(u["name"] == p["name"] for u in uniq):
            continue
        seen.add(p["key"])
        uniq.append(p)
    proposals = uniq

    print(f"{version}: {len(proposals)} proposals")
    for p in proposals:
        bank, addr = p["key"]
        print(f"  {bank}:{addr} {p['name']:28} [{p['kind']}] {p['reason']}")

    prop_path = ROOT / "re" / version / "label-proposals.txt"
    with prop_path.open("w", encoding="utf-8") as f:
        f.write(f"# propose-labels.py {version} — {len(proposals)} proposals\n")
        for p in proposals:
            bank, addr = p["key"]
            f.write(f"{bank}:{addr} {p['name']}  # {p['kind']}: {p['reason']}\n")
    print(f"wrote {prop_path}")

    if not apply:
        return 0

    new_lines, applied = apply_sym(lines, proposals, named)
    if applied:
        sym_path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
        n_notes = merge_notes(version, applied)
        print(f"applied {len(applied)} sym names; {n_notes} note stubs added")
    else:
        print("applied 0 (nothing new)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
