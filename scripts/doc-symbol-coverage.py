#!/usr/bin/env python3
"""Rank table: docs / kernel.sym / call fan-in / orphans — what to label next.

This prints a **rank table only** (addr, fan-in, docs, frontier mark). It does
not include body, callers, or WRAM context. For the full lean surface humans
and agents share, use:

  scripts/map-next.sh
  scripts/label-packet.py --app --frontier-only --top 5

Cross-references for a kernel version:
  1. kernel.sym          - human names already assigned (bank:addr -> name)
  2. docs/*.md           - Call_/Jump_/jr_/Data_/Unknown_ citations
  3. disassembly/*.asm   - `call Call_BBB_AAAA` fan-in
  4. Call_ bodies        - still-auto entry points (even with 0 call sites)
  5. Jump_ seams         - only when docs cite them, or they sit after a `ret`
                           with a function prologue (real entry, not a loop head)
  6. Orphans             - unlabeled code after `ret` with a stack prologue
                           (`add sp, -$…`, `ldhl sp`, or `push`); address estimated
                           by walking from the prior label

Internal `jp Jump_…` loops are still excluded from fan-in (they inflate scores).
After high-fan-in Call_ targets are named, the worklist must keep feeding from
(5)/(6) and doc-cited Jump_ — otherwise map-next returns NO_TARGET while
thousands of Jump_/orphan symbols remain.

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
                    (doc-cited bodies and orphans still pass)
  --banks LIST    only these banks (comma hex, e.g. 00,01,04,08)
  --skip-banks LIST  drop these banks (comma hex)
  --verbose       full table even under --app

Loop tip:  scripts/map-next.sh
  Rank dump (no body):  scripts/doc-symbol-coverage.py --app --top 10
  Full dump + lib banks:  scripts/doc-symbol-coverage.py --top 25
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
JUMP_LABEL_RX = re.compile(r"^Jump_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$")
AUTO_LABEL_RX = re.compile(
    r"^(?:Call|Jump|jr|Data|Unknown)_([0-9a-fA-F]{3})_([0-9a-fA-F]{4}):\s*$"
)
ANY_LABEL_RX = re.compile(r"^([A-Za-z_][\w]*)::?\s*$")
# Absolute WRAM / FPGA — means not a pure compiler leaf.
ABS_APP_RX = re.compile(r"\$(?:[DdCc][0-9a-fA-F]{3}|7[Ff][0-9a-fA-F]{2})\b")
STACK_FRAME_RX = re.compile(r"add\s+hl,\s*sp", re.IGNORECASE)
SHIFT_RX = re.compile(r"\b(?:rr|rl|sra|sla|rrc|rlc)\s+", re.IGNORECASE)
SBC_RX = re.compile(r"\bsbc\s+", re.IGNORECASE)
DEC_LOOP_RX = re.compile(r"\bdec\s+(?:a|b)\b", re.IGNORECASE)
CODE_LINE_RX = re.compile(r"^\s*[^;\s]")
# SDCC function entry. After `ret`, `push` / `ldhl sp` also start real orphans
# (e.g. PlotBitRowXY, StrCmp). Mid-function local rets do not fall through.
PROLOGUE_RX = re.compile(
    r"^\s+(?:add\s+sp,\s*-\$|dec\s+sp|ldhl\s+sp,|ld\s+hl\s*,\s*sp|push\s+(?:af|bc|de|hl)|"
    r"ldh\s+a,\s*\[|ld\s+bc,\s*\$7f00|ld\s+c,\s*b)\b",
    re.IGNORECASE,
)
# Jump_ after ret may start with push; still accept as an entry candidate.
ENTRY_PROLOGUE_RX = re.compile(
    r"^\s+(?:add\s+sp,\s*-\$|dec\s+sp|ldhl\s+sp,|ld\s+hl\s*,\s*sp|push\s+(?:af|bc|de|hl)|"
    r"ldh\s+a,\s*\[|ld\s+bc,\s*\$7f00|ld\s+c,\s*b)\b",
    re.IGNORECASE,
)
RET_RX = re.compile(r"^\s+reti?\s*$", re.IGNORECASE)


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
    if not body:
        return False
    code = code_lines(body)
    code_text = "\n".join(code)
    if not code_text or ABS_APP_RX.search(code_text):
        return False
    # Tiny jp/ret stubs are not useful app targets; treat as skippable lib/runtime.
    if len(code) <= 2:
        return True
    if not STACK_FRAME_RX.search(code_text):
        return False
    if SHIFT_RX.search(code_text) and DEC_LOOP_RX.search(code_text):
        return True
    if SBC_RX.search(code_text) and DEC_LOOP_RX.search(code_text):
        return True
    return False


def is_padding_or_trap(body):
    """Bank fillers / RST $38 traps — not naming targets."""
    code = [ln for ln in body.splitlines() if CODE_LINE_RX.match(ln)]
    if not code:
        return True
    first = code[0].strip().lower()
    if first.startswith("rst"):
        return True
    if len(code) > 1500:
        return True
    if first in ("nop", "ld a, a") and len(code) > 64:
        return True
    return False


def insn_size(line):
    """Byte length of one rgbds-ish asm instruction, or None if unknown."""
    s = line.split(";", 1)[0].strip().lower()
    if not s:
        return 0
    if s.startswith((".", "section")):
        return None
    if s.startswith("db "):
        return len(s[3:].split(","))
    if s.startswith("dw "):
        return 2 * len(s[3:].split(","))
    if s.startswith("ds "):
        m = re.match(r"ds\s+\$?([0-9a-f]+)", s)
        return int(m.group(1), 16) if m else None
    if re.match(r"(bit|res|set|rlc|rrc|rl|rr|sla|sra|srl|swap)\s", s):
        return 2
    if s.startswith("rst "):
        return 1
    if s in ("ret", "reti", "nop", "halt", "di", "ei") or s.startswith("stop"):
        return 1
    # Conditional returns (ret nz / ret c / …) are still 1 byte.
    if re.match(r"ret\s+(nz|z|nc|c|po|pe|p|m)$", s):
        return 1
    if re.match(r"(inc|dec)\s+(a|b|c|d|e|h|l|\[hl\]|bc|de|hl|sp)$", s):
        return 1
    if re.match(r"add\s+hl,\s*(bc|de|sp|hl)$", s):
        return 1
    if re.match(r"(push|pop)\s+(af|bc|de|hl)$", s):
        return 1
    if re.match(r"(and|or|xor|cp|add|sub|adc|sbc)\s+a?\s*,?\s*(a|b|c|d|e|h|l|\[hl\])$", s):
        return 1
    if s in ("cpl", "ccf", "scf", "daa", "rrca", "rlca", "rla", "rra"):
        return 1
    if re.match(r"ld\s+(a|b|c|d|e|h|l)\s*,\s*(a|b|c|d|e|h|l|\[hl\])$", s):
        return 1
    if re.match(r"ld\s+\[hl\]\s*,\s*(a|b|c|d|e|h|l)$", s):
        return 1
    if re.match(r"ld\s+\[[bcde]{2}\]\s*,\s*a$", s):
        return 1
    if re.match(r"ld\s+a\s*,\s*\[[bcde]{2}\]$", s):
        return 1
    if s in ("ld [hli],a", "ld [hld],a", "ld a,[hli]", "ld a,[hld]", "ld sp,hl"):
        return 1
    if re.match(r"(and|or|xor|cp|add|sub|adc|sbc)\s+(?:a\s*,\s*)?\$", s):
        return 2
    if re.match(r"ld\s+(a|b|c|d|e|h|l|\[hl\])\s*,\s*\$", s):
        return 2
    if re.match(r"add\s+sp\s*,", s):
        return 2
    if re.match(r"ld\s+hl\s*,\s*sp", s):
        return 2
    if s.startswith("ldh ") or re.match(r"ld\s+\[\$ff", s):
        return 2
    if re.match(r"jr\s+", s):
        return 2
    if re.match(r"ld\s+(bc|de|hl|sp)\s*,\s*", s):
        return 3
    if re.match(r"ld\s+\[\$[0-9a-f]{4}\]\s*,\s*(a|sp)$", s):
        return 3
    if re.match(r"ld\s+a\s*,\s*\[\$[0-9a-f]{4}\]$", s):
        return 3
    if re.match(r"(jp|call)\s+", s):
        return 3
    # ld a, [wLabel] / ld [wLabel], a — absolute 16-bit (FA/EA).
    # Exclude [hl]/[hl+]/[hli]/… (those are 1-byte).
    def _is_hl_mem(operand_s):
        return bool(re.search(r"\[hl[i\+\-]?(?:d)?\]", operand_s))

    if re.match(r"ld\s+a\s*,\s*\[[^\]]+\]$", s) and not _is_hl_mem(s):
        return 3
    if re.match(r"ld\s+\[[^\]]+\]\s*,\s*a$", s) and not _is_hl_mem(s):
        return 3
    if s in ("ld [hli],a", "ld [hld],a", "ld a,[hli]", "ld a,[hld]", "ld sp,hl"):
        return 1
    if re.match(r"ld\s+\[hl[\+\-]\]\s*,\s*a$", s) or re.match(r"ld\s+a\s*,\s*\[hl[\+\-]\]$", s):
        return 1
    if re.match(r"ld\s+a\s*,\s*\[", s):
        return 1
    if re.match(r"ld\s+\[[^\]]+\]\s*,\s*a$", s):
        return 1
    if re.match(r"ld\s+(a|b|c|d|e|h|l)\s*,\s*[a-z_]", s):
        return 2
    if re.match(r"inc\s+sp$", s):
        return 1
    return None


def code_lines(body):
    return [ln for ln in body.splitlines() if CODE_LINE_RX.match(ln)]


def body_until(lines, start):
    """Exclusive end index of body starting at start (first line after label).

    Stops at the next top-level label, or at a `ret`/`reti` that is followed by
    an unlabeled SDCC prologue (orphan function boundary).
    """
    j = start
    while j < len(lines):
        if ANY_LABEL_RX.match(lines[j]) or AUTO_LABEL_RX.match(lines[j]):
            break
        if RET_RX.match(lines[j]):
            k = j + 1
            while k < len(lines) and (not lines[k].strip() or lines[k].strip().startswith(";")):
                k += 1
            if (
                k < len(lines)
                and PROLOGUE_RX.match(lines[k])
                and not ANY_LABEL_RX.match(lines[k])
                and not AUTO_LABEL_RX.match(lines[k])
            ):
                return j + 1
        j += 1
    return j


def scan_bodies_and_frontier(version, named):
    """Map Call_/Jump_ addr -> body; Call_ targets invoked from named fns."""
    bodies = {}
    call_keys = set()
    jump_keys = set()
    frontier = set()
    name_to_key = {name: key for key, name in named.items()}

    for f in glob.glob(str(ROOT / "re" / version / "disassembly" / "bank_*.asm")):
        lines = Path(f).read_text(encoding="utf-8", errors="ignore").splitlines()
        i = 0
        while i < len(lines):
            m_call = CALL_LABEL_RX.match(lines[i])
            m_jump = JUMP_LABEL_RX.match(lines[i])
            m_any = ANY_LABEL_RX.match(lines[i])
            if not m_call and not m_jump and not m_any:
                i += 1
                continue

            label_name = m_any.group(1) if m_any else None
            auto_key = None
            if m_call:
                auto_key = (f"{int(m_call.group(1), 16):02x}", m_call.group(2).lower())
                call_keys.add(auto_key)
            elif m_jump:
                auto_key = (f"{int(m_jump.group(1), 16):02x}", m_jump.group(2).lower())
                jump_keys.add(auto_key)

            j = body_until(lines, i + 1)
            body = "\n".join(lines[i + 1:j])
            if auto_key:
                bodies[auto_key] = body

            in_named = False
            if auto_key and auto_key in named:
                in_named = True
            elif label_name and label_name in name_to_key:
                in_named = True

            if in_named:
                for bank, addr in CALLSITE_RX.findall(body):
                    frontier.add((f"{int(bank, 16):02x}", addr.lower()))

            i = j

    return bodies, frontier, call_keys, jump_keys


def scan_entry_jumps(version, bodies, jump_keys, named):
    """Jump_ labels that start a new function (after ret, prologue)."""
    entries = set()
    for f in glob.glob(str(ROOT / "re" / version / "disassembly" / "bank_*.asm")):
        lines = Path(f).read_text(encoding="utf-8", errors="ignore").splitlines()
        for i, ln in enumerate(lines):
            if not RET_RX.match(ln):
                continue
            j = i + 1
            while j < len(lines) and (not lines[j].strip() or lines[j].strip().startswith(";")):
                j += 1
            if j >= len(lines):
                continue
            m = JUMP_LABEL_RX.match(lines[j])
            if not m:
                continue
            key = (f"{int(m.group(1), 16):02x}", m.group(2).lower())
            if key in named or key not in jump_keys:
                continue
            body = bodies.get(key, "")
            code = code_lines(body)
            if code and ENTRY_PROLOGUE_RX.match(code[0]):
                entries.add(key)
    return entries


def is_fallthrough_call_label(version, bank, addr_s):
    """True when Call_BBB_AAAA is a mid-function label (prior code is not ret)."""
    path = ROOT / "re" / version / "disassembly" / f"bank_{int(bank, 16):03x}.asm"
    if not path.is_file():
        return False
    label = f"Call_{int(bank, 16):03x}_{addr_s.lower()}:"
    lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    for i, ln in enumerate(lines):
        if ln.strip() != label and not ln.startswith(label):
            # also allow Call_...:: 
            if not (ln.startswith(f"Call_{int(bank, 16):03x}_{addr_s.lower()}") and ":" in ln):
                continue
        # look backward for previous code
        k = i - 1
        while k >= 0 and (not lines[k].strip() or lines[k].strip().startswith(";")):
            k -= 1
        if k < 0:
            return False
        prev = lines[k].strip()
        if RET_RX.match(lines[k]):
            return False
        # Prior label at column 0 that is a real entry is fine only if it was ret
        # before that; any prior instruction/label means fallthrough into this Call_.
        return True
    return False


def scan_orphans(version, named):
    """Unlabeled function prologues after ret; addr walked from prior auto/human label."""
    orphans = {}  # key -> body
    orphan_meta = {}  # key -> (path, start_line_idx, end_line_idx)
    name_to_key = {name: key for key, name in named.items()}

    for f in sorted(glob.glob(str(ROOT / "re" / version / "disassembly" / "bank_*.asm"))):
        path = Path(f)
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        last_key = None
        last_line = None
        i = 0
        while i < len(lines):
            m_auto = AUTO_LABEL_RX.match(lines[i])
            m_any = ANY_LABEL_RX.match(lines[i])
            if m_auto:
                last_key = (f"{int(m_auto.group(1), 16):02x}", m_auto.group(2).lower())
                last_line = i
                i += 1
                continue
            if m_any:
                name = m_any.group(1)
                last_key = name_to_key.get(name)
                last_line = i if last_key else None
                i += 1
                continue

            if RET_RX.match(lines[i]) and last_key is not None and last_line is not None:
                j = i + 1
                while j < len(lines) and (not lines[j].strip() or lines[j].strip().startswith(";")):
                    j += 1
                if j < len(lines) and PROLOGUE_RX.match(lines[j]) and not ANY_LABEL_RX.match(lines[j]) and not AUTO_LABEL_RX.match(lines[j]):
                    # Walk PC from last_key through instructions up to orphan.
                    bank, base_s = last_key
                    pc = int(base_s, 16)
                    ok = True
                    for k in range(last_line + 1, j):
                        if not lines[k].strip() or lines[k].strip().startswith(";"):
                            continue
                        if ANY_LABEL_RX.match(lines[k]) or AUTO_LABEL_RX.match(lines[k]):
                            ok = False
                            break
                        sz = insn_size(lines[k])
                        if sz is None:
                            ok = False
                            break
                        pc += sz
                    if ok:
                        end = body_until(lines, j)
                        body = "\n".join(lines[j:end])
                        key = (bank, f"{pc:04x}")
                        if (
                            not is_padding_or_trap(body)
                            and len(code_lines(body)) >= 3
                            and key not in named
                            and key not in orphans
                        ):
                            orphans[key] = body
                            orphan_meta[key] = (path, j, end)
                        # Chain: next ret after this orphan must walk from here.
                        # last_line is the line *before* the first insn (label-sized
                        # 0), so the PC walk includes the orphan body.
                        last_key = key
                        last_line = j - 1
                    i = j
                    continue
            i += 1

    return orphans, orphan_meta


def rank_candidates(
    version,
    frontier_only=False,
    include_lib=False,
    only_banks=None,
    skip_banks=None,
    show_all=False,
    skip_runtime=True,
    app_mode=True,
):
    """Return (rows, skips, extras).

    rows: list of (key, name, docs, fanin, is_frontier, is_orphan, kind)
      kind in {"call", "jump", "orphan", "doc"}
    skips: dict of filter counts
    extras: {bodies, frontier, orphans, orphan_meta, docs, fanin, named}
    """
    skip = set(skip_banks or ())
    if not include_lib and only_banks is None:
        skip |= set(LIB_BANKS)

    named = load_named(version)
    docs = scan_docs()
    fanin = scan_call_fanin(version)
    bodies, frontier, call_keys, jump_keys = scan_bodies_and_frontier(version, named)
    entry_jumps = scan_entry_jumps(version, bodies, jump_keys, named)
    orphans, orphan_meta = scan_orphans(version, named)

    # Merge orphan bodies so packet / runtime checks see them.
    for key, body in orphans.items():
        bodies.setdefault(key, body)

    keys = set(docs) | set(fanin) | set(call_keys) | set(entry_jumps) | set(orphans)

    # Per-bank sorted named ROM addrs — Jump_ strictly between two named symbols
    # is an interior branch (e.g. Jump_001_4a63 inside DateToDaysSince1970).
    named_by_bank = collections.defaultdict(list)
    for (b, a), _n in named.items():
        try:
            named_by_bank[b].append(int(a, 16))
        except ValueError:
            continue
    for b in named_by_bank:
        named_by_bank[b].sort()

    def is_interior_jump(bank, addr_s):
        addrs = named_by_bank.get(bank)
        if not addrs:
            return False
        try:
            addr = int(addr_s, 16)
        except ValueError:
            return False
        # Find rightmost named addr < candidate.
        lo = None
        for na in addrs:
            if na < addr:
                lo = na
            else:
                break
        if lo is None:
            return False
        # Interior if another named symbol exists after lo (the containing fn's
        # end is at/before the next named); candidate sits before that next.
        for na in addrs:
            if na > lo:
                return addr < na
        # No named symbol after lo — still interior to that last named function
        # (e.g. Jump_004_48f5 inside DrawTimeAutosaveScreen with nothing after).
        return True

    skips = collections.Counter()
    rows = []
    for key in keys:
        bank, addr = key
        name = named.get(key, "")
        if name and not show_all:
            continue
        if only_banks is not None and bank not in only_banks:
            skips["bank"] += 1
            continue
        if bank in skip:
            skips["lib"] += 1
            continue
        # Drop doc phantoms (Call_BBB_AAAA) and refs with no body / fan-in / orphan.
        if key not in bodies and fanin.get(key, 0) == 0 and key not in orphans:
            continue
        if frontier_only and key not in frontier and key not in docs and key not in orphans and key not in entry_jumps:
            skips["nonfrontier"] += 1
            continue

        body = bodies.get(key, orphans.get(key, ""))
        if skip_runtime and key not in docs:
            if key in bodies and is_sdcc_runtime(body):
                skips["runtime"] += 1
                continue
            if is_padding_or_trap(body):
                skips["padding"] += 1
                continue

        # Skip Jump_ epilogues (tiny/empty ret bodies), including doc-cited ones —
        # docs often name the label just before an orphan (e.g. Jump_000_0927).
        # Empty body happens when a jr_* alias sits on the next line.
        if key in jump_keys:
            code = code_lines(body)
            if not code or is_sdcc_runtime(body):
                skips["epilogue"] += 1
                continue

        # Mid-function Jump_ labels (not real entries after ret).
        if key in jump_keys and key not in entry_jumps and is_interior_jump(bank, addr):
            skips["interior"] += 1
            continue

        # Mid-function Call_ labels (mgbdis invents Call_ when data/code jp/calls
        # into the middle of a routine, e.g. Call_000_0803 inside PlotBitRowXY).
        if key in call_keys and is_fallthrough_call_label(version, bank, addr):
            skips["interior"] += 1
            continue

        # Unreferenced orphans with no doc cite, no frontier edge, and no
        # WRAM/FPGA abs touches are usually dead helpers (e.g. 00:2ac6). Called
        # FatFs/API bodies show up as Call_ instead. Keep them off the worklist
        # so naming loops are not stuck on needs_judgment dead code.
        if key in orphans and fanin.get(key, 0) == 0 and key not in docs and key not in frontier:
            body_o = orphans[key]
            has_abs_o = bool(ABS_APP_RX.search("\n".join(code_lines(body_o))))
            inherited = False
            addr_i = int(addr, 16) if isinstance(addr, str) else addr
            for delta in range(1, 8):
                prev = (bank, f"{addr_i - delta:04x}")
                if prev in docs and prev in bodies and is_sdcc_runtime(bodies[prev]):
                    inherited = True
                    break
            if not has_abs_o and not inherited:
                skips["unref_orphan"] += 1
                continue

        if key in orphans:
            kind = "orphan"
        elif key in call_keys:
            kind = "call"
        elif key in jump_keys or key in entry_jumps:
            kind = "jump"
        else:
            kind = "doc"

        dref = docs.get(key, 0)
        # Doc often cites the Jump_ epilogue label immediately before an orphan
        # function (e.g. Jump_000_0927 then unlabeled body at 00:092a). Credit
        # the orphan so map-next opens the real function.
        if key in orphans and dref == 0:
            bank, addr_s = key
            addr = int(addr_s, 16)
            for delta in range(1, 8):
                prev = (bank, f"{addr - delta:04x}")
                if prev in docs and prev in bodies and is_sdcc_runtime(bodies[prev]):
                    dref = docs[prev]
                    break

        has_abs = bool(ABS_APP_RX.search("\n".join(code_lines(body))))
        rows.append(
            (
                key,
                name,
                dref,
                fanin.get(key, 0),
                key in frontier,
                key in orphans,
                kind,
                has_abs,
            )
        )

    # Prefer: docs (known seams), frontier, orphans with WRAM/FPGA, other orphans,
    # entry jumps, fan-in, then addr. Tiny doc-cited epilogues sort below orphans
    # that inherited their docrefs.
    if app_mode or frontier_only:
        rows.sort(
            key=lambda r: (
                r[1] != "",
                -r[2],
                -int(r[4]),
                -int(r[5] and r[7]),
                -int(r[5]),
                -int(r[6] == "jump" and r[2] > 0 and not r[5]),
                -int(r[6] == "jump"),
                -r[3],
                r[0],
            )
        )
    else:
        rows.sort(key=lambda r: (r[1] != "", -r[3], -r[2], r[0]))

    extras = {
        "bodies": bodies,
        "frontier": frontier,
        "orphans": orphans,
        "orphan_meta": orphan_meta,
        "docs": docs,
        "fanin": fanin,
        "named": named,
        "call_keys": call_keys,
        "jump_keys": jump_keys,
        "entry_jumps": entry_jumps,
    }
    return rows, skips, extras


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

    version = args[0] if args else "1.05e"

    need_bodies = skip_runtime or frontier_only or app_mode
    if not need_bodies and not app_mode:
        # Legacy full dump: docs + fan-in only (no body filters).
        named = load_named(version)
        docs = scan_docs()
        fanin = scan_call_fanin(version)
        rows = []
        for key in set(docs) | set(fanin):
            name = named.get(key, "")
            if name and not show_all:
                continue
            rows.append((key, name, docs.get(key, 0), fanin.get(key, 0), False, False, "doc", False))
        rows.sort(key=lambda r: (r[1] != "", -r[3], -r[2], r[0]))
        skips = collections.Counter()
        extras = {"docs": docs, "named": named}
    else:
        rows, skips, extras = rank_candidates(
            version,
            frontier_only=frontier_only,
            include_lib=include_lib,
            only_banks=only_banks,
            skip_banks=skip_banks,
            show_all=show_all,
            skip_runtime=skip_runtime,
            app_mode=app_mode or frontier_only,
        )

    total = len(rows)
    if top is not None:
        rows = rows[:top]

    documented = set(extras.get("docs", {}))
    named = extras.get("named", load_named(version))
    doc_named = sum(1 for k in documented if k in named)

    if compact:
        parts = [f"app {version}: {total} candidates"]
        skip_parts = []
        if skips.get("lib"):
            skip_parts.append(f"{skips['lib']} lib-bank")
        if skips.get("runtime"):
            skip_parts.append(f"{skips['runtime']} runtime")
        if skips.get("padding"):
            skip_parts.append(f"{skips['padding']} padding")
        if skips.get("epilogue"):
            skip_parts.append(f"{skips['epilogue']} epilogue")
        if skips.get("interior"):
            skip_parts.append(f"{skips['interior']} interior-jump")
        if skips.get("bank"):
            skip_parts.append(f"{skips['bank']} bank-filter")
        if skips.get("nonfrontier"):
            skip_parts.append(f"{skips['nonfrontier']} non-frontier")
        if skips.get("unref_orphan"):
            skip_parts.append(f"{skips['unref_orphan']} unref-orphan")
        if skip_parts:
            parts.append(f"skipped {', '.join(skip_parts)}")
        parts.append(f"show {len(rows)}")
        print("; ".join(parts))
        print(f"{'addr':7} {'c':>3} {'d':>2}  fr")
        for (bank, addr), name, dref, fin, fr, orphan, kind, _abs in rows:
            if fr:
                mark = "F"
            elif orphan:
                mark = "O"
            elif kind == "jump":
                mark = "J"
            else:
                mark = "."
            print(f"{bank}:{addr}  {fin:>3} {dref:>2}  {mark}")
    else:
        print(f"version {version}: {len(documented)} functions referenced in docs, "
              f"{doc_named} named, {len(documented) - doc_named} still unnamed")
        if any(skips.values()):
            print(f"filters: skipped lib-bank={skips.get('lib', 0)} runtime={skips.get('runtime', 0)} "
                  f"padding={skips.get('padding', 0)} bank={skips.get('bank', 0)} "
                  f"non-frontier={skips.get('nonfrontier', 0)}; {total} candidates")
        print()
        if need_bodies or app_mode:
            print(f"{'addr':7} {'name':24} {'docrefs':>7} {'callsites':>9} {'fr':>3}")
            print("-" * 55)
            for (bank, addr), name, dref, fin, fr, orphan, kind, _abs in rows:
                if fr:
                    mark = "F"
                elif orphan:
                    mark = "O"
                elif kind == "jump":
                    mark = "J"
                else:
                    mark = ""
                print(f"{bank}:{addr}  {name or '(UNNAMED)':24} {dref:>7} {fin:>9} {mark:>3}")
        else:
            print(f"{'addr':7} {'name':24} {'docrefs':>7} {'callsites':>9}")
            print("-" * 51)
            for (bank, addr), name, dref, fin, fr, orphan, kind, _abs in rows:
                print(f"{bank}:{addr}  {name or '(UNNAMED)':24} {dref:>7} {fin:>9}")


if __name__ == "__main__":
    main()

