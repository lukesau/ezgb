#!/usr/bin/env python3
"""PicoBlaze (KCPSM3, Spartan-3) disassembler with annotation merge.

Input is a 1K x 18 program, either the BRAM files s3decode writes
(PREFIX.DATA.bin + PREFIX.DATAP.bin) or a text file of "addr: word" lines
(picoblaze-words.py output).  Output is KCPSM3 assembler (.psm) syntax:

    picoblaze-dis.py fw4-decode/bram/D0X3Y25.BEL.BRAM [-a notes.txt] [-o out.psm]
    picoblaze-dis.py --check out.psm PREFIX     # reassemble and compare words

Control flow is traced from the reset vector ($000) and the interrupt vector
($3FF).  Every jump/call target gets a label; CALL targets are marked as
subroutines with their callers; words never reached are emitted as raw data.

Annotation file (one item per line, `#` comments):

    label  ADDR NAME            name the instruction at ADDR
    sub    ADDR NAME            same, for a subroutine (adds a header block)
    note   ADDR TEXT...         comment on the line at ADDR
    block  ADDR TEXT...         comment block above ADDR
    port   in|out PP NAME       name an I/O port (emitted as CONSTANT)
    const  NAME VALUE           any other named constant (not substituted)
    reg    sX NAME              NAMEREG
    ram    SS NAME              name a scratchpad byte (emitted as CONSTANT)
    entry  ADDR [NAME]          extra trace root (code no reachable path reaches)
"""

import argparse
import collections
import re
import sys

COND = {0: "Z", 1: "NZ", 2: "C", 3: "NC"}
SHIFTS = {0xE: "SR0", 0xF: "SR1", 0xA: "SRX", 0x8: "SRA", 0xC: "RR",
          0x6: "SL0", 0x7: "SL1", 0x4: "SLX", 0x0: "SLA", 0x2: "RL"}
ALU = {0x00: "LOAD", 0x0A: "AND", 0x0C: "OR", 0x0E: "XOR", 0x12: "TEST",
       0x14: "COMPARE", 0x18: "ADD", 0x1A: "ADDCY", 0x1C: "SUB", 0x1E: "SUBCY"}


def load_words(src):
    if src.endswith((".txt", ".hex")):
        w = [0] * 1024
        for line in open(src):
            a, v = line.split(":")
            w[int(a, 16)] = int(v, 16)
        return w
    data = open(src + ".DATA.bin", "rb").read()
    par = open(src + ".DATAP.bin", "rb").read()
    return [(par[i // 4] >> (i % 4 * 2) & 3) << 16 | data[2 * i] | data[2 * i + 1] << 8
            for i in range(1024)]


class Insn:
    def __init__(self, addr, word):
        self.addr, self.word = addr, word
        op = word >> 12
        sx, sy, kk = word >> 8 & 15, word >> 4 & 15, word & 0xFF
        cc = COND[word >> 10 & 3]
        self.flow = None      # 'jump' | 'call' | 'ret' | 'reti' | None
        self.cond = None
        self.target = None
        self.kind = None      # 'in' | 'out' | 'fetch' | 'store' for port/ram naming
        self.imm = None       # port / scratchpad / constant operand
        self.valid = True
        if op & ~1 in ALU:
            name = ALU[op & ~1]
            if op & 1:
                self.mn, self.ops = name, [f"s{sx:X}", f"s{sy:X}"]
            else:
                self.mn, self.ops, self.imm = name, [f"s{sx:X}", f"{kk:02X}"], kk
        elif op in (0x04, 0x05, 0x2C, 0x2D, 0x06, 0x07, 0x2E, 0x2F):
            self.mn = {0x04: "INPUT", 0x2C: "OUTPUT", 0x06: "FETCH", 0x2E: "STORE"}[op & ~1]
            self.kind = {"INPUT": "in", "OUTPUT": "out", "FETCH": "fetch", "STORE": "store"}[self.mn]
            if op & 1:
                self.ops = [f"s{sx:X}", f"(s{sy:X})"]
            else:
                v = kk if self.kind in ("in", "out") else kk & 0x3F
                self.ops, self.imm = [f"s{sx:X}", f"{v:02X}"], v
        elif op == 0x20 and (word & 0xF0) == 0 and (word & 0xF) in SHIFTS:
            self.mn, self.ops = SHIFTS[word & 0xF], [f"s{sx:X}"]
        elif op in (0x34, 0x35, 0x30, 0x31):
            self.flow = "jump" if op & ~1 == 0x34 else "call"
            self.mn = "JUMP" if self.flow == "jump" else "CALL"
            self.target = word & 0x3FF
            self.cond = cc if op & 1 else None
            self.ops = ([self.cond] if self.cond else []) + [f"{self.target:03X}"]
        elif op in (0x2A, 0x2B) and word & 0x3FF == 0:
            self.flow, self.mn = "ret", "RETURN"
            self.cond = cc if op & 1 else None
            self.ops = [self.cond] if self.cond else []
        elif word in (0x38000, 0x38001):
            self.flow, self.mn = "reti", "RETURNI"
            self.ops = ["ENABLE" if word & 1 else "DISABLE"]
        elif word in (0x3C000, 0x3C001):
            self.mn, self.ops = ("ENABLE" if word & 1 else "DISABLE"), ["INTERRUPT"]
        else:
            self.valid, self.mn, self.ops = False, "DATA", [f"{word:05X}"]

    def falls_through(self):
        return not (self.flow in ("jump", "ret", "reti") and self.cond is None)


def trace(insns, entries=()):
    """Return reachable set, callers of each sub, jumpers to each label."""
    reach, work = set(), [0x000, 0x3FF, *entries]
    callers, jumpers = collections.defaultdict(list), collections.defaultdict(list)
    while work:
        a = work.pop()
        while 0 <= a < 1024 and a not in reach:
            i = insns[a]
            if not i.valid:
                break
            reach.add(a)
            if i.flow == "call":
                callers[i.target].append(a)
                work.append(i.target)
            elif i.flow == "jump":
                jumpers[i.target].append(a)
                work.append(i.target)
            if not i.falls_through():
                break
            a += 1
    return reach, callers, jumpers


def load_notes(path):
    n = dict(label={}, sub=set(), note={}, block=collections.defaultdict(list),
             port={"in": {}, "out": {}}, const=[], reg={}, ram={}, entry=[])
    if not path:
        return n
    for raw in open(path):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        kw, rest = line.split(None, 1)
        if kw in ("label", "sub"):
            a, name = rest.split()
            n["label"][int(a, 16)] = name
            if kw == "sub":
                n["sub"].add(int(a, 16))
        elif kw == "note":
            a, text = rest.split(None, 1)
            n["note"][int(a, 16)] = text
        elif kw == "block":
            a, *text = rest.split(None, 1)
            n["block"][int(a, 16)].append(text[0] if text else "")
        elif kw == "port":
            d, pp, name = rest.split()
            n["port"][d][int(pp, 16)] = name
        elif kw == "const":
            name, v = rest.split()
            n["const"].append((name, int(v, 16)))
        elif kw == "reg":
            r, name = rest.split()
            n["reg"][r.lower()] = name
        elif kw == "entry":
            a, *name = rest.split()
            n["entry"].append(int(a, 16))
            if name:
                n["label"][int(a, 16)] = name[0]
        elif kw == "ram":
            ss, name = rest.split()
            n["ram"][int(ss, 16)] = name
        else:
            sys.exit(f"unknown annotation: {line}")
    return n


def disassemble(words, notes, title):
    insns = [Insn(a, w) for a, w in enumerate(words)]
    reach, callers, jumpers = trace(insns, notes["entry"])
    labels = {}
    for a in sorted(set(callers) | set(jumpers)):
        labels[a] = f"sub_{a:03X}" if a in callers else f"L_{a:03X}"
    labels[0x000] = labels.get(0x000, "reset")
    labels[0x3FF] = "int_vector"
    labels.update(notes["label"])
    subs = set(callers) | notes["sub"]
    regname = notes["reg"]

    def reg(r):
        return regname.get(r.lower(), r)

    def fmt(i):
        ops = list(i.ops)
        if i.flow in ("jump", "call"):
            ops[-1] = labels.get(i.target, ops[-1])
        elif i.kind in ("in", "out") and i.imm is not None:
            ops[1] = notes["port"][i.kind].get(i.imm, ops[1])
        elif i.kind in ("fetch", "store") and i.imm is not None:
            ops[1] = notes["ram"].get(i.imm, ops[1])
        ops = [reg(o) if re.fullmatch(r"s[0-9A-F]", o) else
               f"({reg(o[1:-1])})" if re.fullmatch(r"\(s[0-9A-F]\)", o) else o for o in ops]
        return f"{i.mn} {', '.join(ops)}" if ops else i.mn

    out = [f"; {title}", "; KCPSM3 (PicoBlaze for Spartan-3), 1K x 18",
           f"; {len(reach)} reachable instructions, {len(subs)} subroutines", ";"]
    for r, name in sorted(regname.items()):
        out.append(f"NAMEREG {r}, {name}")
    for d in ("in", "out"):
        for pp, name in sorted(notes["port"][d].items()):
            out.append(f"CONSTANT {name}, {pp:02X}   ; {d}put port")
    for ss, name in sorted(notes["ram"].items()):
        out.append(f"CONSTANT {name}, {ss:02X}   ; scratchpad")
    for name, v in notes["const"]:
        out.append(f"CONSTANT {name}, {v:02X}")
    out.append("")

    a = 0
    while a < 1024:
        i = insns[a]
        if a not in reach:
            # run of unreachable words
            b = a
            while b < 1024 and b not in reach:
                b += 1
            run = words[a:b]
            if all(w == 0 for w in run):
                out.append(f"; ${a:03X}-${b - 1:03X}: {b - a} unused (zero) words")
                out.append(f"ADDRESS {b:03X}" if b < 1024 else "")
            else:
                out.append(f"; ${a:03X}-${b - 1:03X}: unreached words, kept as data")
                out.append(f"ADDRESS {a:03X}")
                for k in range(a, b):
                    txt = Insn(k, words[k])
                    for t in notes["block"].get(k, []):
                        out.append(f"    ; {t}")
                    if k in notes["label"]:
                        out.append(f"    ; {notes['label'][k]}:")
                    line = f"    ; {k:03X}: {words[k]:05X}  {fmt(txt) if txt.valid else ''}"
                    if k in notes["note"]:
                        line = f"{line:<44}{notes['note'][k]}"
                    out.append(line)
                    out.append(f"    DATA_WORD {words[k]:05X}")
            a = b
            continue
        if a in notes["block"]:
            out.append("")
            out.extend(f"; {t}" for t in notes["block"][a])
        if a in notes["entry"]:
            out.append("")
            out.append(f"; ---- {notes['label'].get(a, f'{a:03X}')} ---- extra entry: no path from reset or interrupt reaches here")
        elif a in subs:
            out.append("")
            out.append(f"; ---- {labels[a]} ---- called from "
                       + (", ".join(f"{c:03X}" for c in sorted(callers.get(a, []))) or "nowhere"))
        if a in labels:
            out.append(f"{labels[a]}:")
        line = f"    {fmt(i):<32}; {a:03X} {i.word:05X}"
        if a in notes["note"]:
            line += f"  {notes['note'][a]}"
        out.append(line)
        a += 1
    return "\n".join(l for l in out) + "\n", insns, reach, callers


# ---- assembler for the subset we emit, to prove the listing is lossless ----

def assemble(text):
    consts, regs, labels, lines = {}, {}, {}, []
    addr = 0
    for raw in text.splitlines():
        s = raw.split(";")[0].strip()
        if not s:
            continue
        m = re.fullmatch(r"NAMEREG (s[0-9A-F]), (\w+)", s)
        if m:
            regs[m[2]] = m[1]
            continue
        m = re.fullmatch(r"CONSTANT (\w+), ([0-9A-F]+)", s)
        if m:
            consts[m[1]] = int(m[2], 16)
            continue
        m = re.fullmatch(r"ADDRESS ([0-9A-F]+)", s)
        if m:
            addr = int(m[1], 16)
            continue
        m = re.fullmatch(r"(\w+):", s)
        if m:
            labels[m[1]] = addr
            continue
        lines.append((addr, s))
        addr += 1
    words = [0] * 1024

    def r(x):
        x = regs.get(x, x)
        return int(x[1:], 16)

    def v(x):
        return consts[x] if x in consts else labels[x] if x in labels else int(x, 16)

    inv_alu = {n: o for o, n in ALU.items()}
    inv_sh = {n: c for c, n in SHIFTS.items()}
    inv_cc = {n: c for c, n in COND.items()}
    for addr, s in lines:
        mn, _, rest = s.partition(" ")
        ops = [o.strip() for o in rest.split(",")] if rest else []
        if mn == "DATA_WORD":
            w = int(ops[0], 16)
        elif mn in inv_alu:
            if ops[1] in regs or re.fullmatch(r"s[0-9A-F]", ops[1]):
                w = (inv_alu[mn] | 1) << 12 | r(ops[0]) << 8 | r(ops[1]) << 4
            else:
                w = inv_alu[mn] << 12 | r(ops[0]) << 8 | v(ops[1])
        elif mn in ("INPUT", "OUTPUT", "FETCH", "STORE"):
            base = {"INPUT": 0x04, "OUTPUT": 0x2C, "FETCH": 0x06, "STORE": 0x2E}[mn]
            if ops[1].startswith("("):
                w = (base | 1) << 12 | r(ops[0]) << 8 | r(ops[1][1:-1]) << 4
            else:
                w = base << 12 | r(ops[0]) << 8 | v(ops[1])
        elif mn in inv_sh:
            w = 0x20 << 12 | r(ops[0]) << 8 | inv_sh[mn]
        elif mn in ("JUMP", "CALL"):
            base = 0x34 if mn == "JUMP" else 0x30
            if len(ops) == 2:
                w = (base | 1) << 12 | inv_cc[ops[0]] << 10 | v(ops[1])
            else:
                w = base << 12 | v(ops[0])
        elif mn == "RETURN":
            w = (0x2B << 12 | inv_cc[ops[0]] << 10) if ops else 0x2A000
        elif mn == "RETURNI":
            w = 0x38001 if ops[0] == "ENABLE" else 0x38000
        elif mn in ("ENABLE", "DISABLE"):
            w = 0x3C001 if mn == "ENABLE" else 0x3C000
        else:
            sys.exit(f"cannot assemble: {s}")
        words[addr] = w
    return words


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("program", help="BRAM prefix or words .txt")
    ap.add_argument("-a", "--notes")
    ap.add_argument("-o", "--out")
    ap.add_argument("--check", help="reassemble this .psm and compare with program")
    ap.add_argument("--summary", action="store_true", help="print port/scratchpad/call usage")
    args = ap.parse_args()
    words = load_words(args.program)
    if args.check:
        got = assemble(open(args.check).read())
        bad = [a for a in range(1024) if got[a] != words[a]]
        print(f"reassembled {args.check}: {'identical' if not bad else f'{len(bad)} words differ'}")
        for a in bad[:10]:
            print(f"  {a:03X}: want {words[a]:05X} got {got[a]:05X}")
        sys.exit(1 if bad else 0)
    notes = load_notes(args.notes)
    text, insns, reach, callers = disassemble(words, notes, args.program.split("/")[-1])
    if args.out:
        open(args.out, "w").write(text)
    if args.summary:
        use = collections.defaultdict(list)
        for a in sorted(reach):
            i = insns[a]
            if i.kind and i.imm is not None:
                use[(i.kind, i.imm)].append(a)
            elif i.kind:
                use[(i.kind, "indirect")].append(a)
        for (k, p), addrs in sorted(use.items(), key=lambda x: (x[0][0], str(x[0][1]))):
            ps = f"{p:02X}" if isinstance(p, int) else p
            print(f"{k:5} {ps:>8}: {len(addrs):3}x  " + " ".join(f"{a:03X}" for a in addrs))
        print("subroutines:", " ".join(f"{a:03X}({len(c)})" for a, c in sorted(callers.items())))
    if not args.out and not args.summary:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
