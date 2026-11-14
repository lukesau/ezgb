#!/usr/bin/env python3
"""Build stock stage1 from the C and the stock disassembly, byte for byte.

The C is compiled by SDCC 2.9.0 (tools/sdcc-2.9.0, from build-sdcc29.sh),
the compiler EZ Flash used, with no options, and linked by sdldgb at the
stock addresses. What the C calls that is still assembly (the GBDK runtime,
the math helpers) is resolved from the firmware's kernel.sym. The linked
bytes are written as rgbds includes that take the place of that asm in a
copy of the disassembly, and rgbds builds the ROM, which is then compared
with the firmware's kernel.gb when that is present (local, from
stage1-from-bram.py).

    tools/link.py fw4       -> build/fw4/stage1.gb
    tools/link.py fw5-0918  -> build/fw5/stage1.gb

Regions (FW4; FW5-0918 bank 0 starts at the same $05BC and ends $31 later):

    00:05BC up to U32Mul ($2732)  main.c, diskio.c, pff.c, sd.c   (_CODE)
    01:4000-01:40AD               handoff_poll.c, run at $D100     (_HANDOFF)
    01:40AE-01:4133               handoff.c                       (_CODE_1)
    01:4134-01:415F               main.c's initialized globals    (_GSINIT)
    $C0A0-$C4A9                   RAM: LoadCmd, messages, FatFs, sector buffer

SDCC 2.9.0 writes a banked call's bank word as 0 ("PENDING: bank support");
stock has the bank, so the build writes b_<name> there and BANKS gives it.
"""
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

DECOMP = Path(__file__).resolve().parent.parent
STAGE1 = DECOMP.parent
SRC = DECOMP / "src"

FWS = {"fw4": ("4", STAGE1 / "fw4"), "fw5-0918": ("5", STAGE1 / "fw5-0918")}

# Link order: RAM is laid out in this order, so main.c's LoadCmd and messages
# come first ($C0A0, $C2A0), then pff.c's FatFs ($C2A8), then sd.c's buffer.
OBJS = ["main.c", "diskio.c", "pff.c", "sd.c", "handoff_poll.c", "handoff.c"]
SDCC = STAGE1.parent / "tools" / "sdcc-2.9.0" / "bin"

CODE0 = 0x05BC          # first byte of C in bank 0: PrintLine
HANDOFF_ROM = 0x4000
HANDOFF_RUN = 0xD100
GSINIT = 0x4134         # crt0: call $4134, which ends in crt0's _GSFINAL `ret`
BRAM1_END = 0x4200      # stock pads bank 1 with $FF to $41FF, zeros after
RAM = 0xC0A0
RAM_END = 0xC4AA        # GBDK runtime variables from here ($C4AA errno, $C4AC _cpu)

# C name -> kernel.sym name, where GBDK's name and ours differ
ALIASES = {
    "_joypad": "ReadJoypad",
    "_disable_interrupts": "DiNest",
    "_memcpy": "Memcpy",
    "_set_data": "VramCopyStack",
    "banked_call": "FarCallTrampoline",
    "__mulint": "S16Mul",
    "__divsint": "S16Div",
    "__modsint": "S16Mod",
    "__mullong": "U32Mul",
    "__divulong": "U32Div",
    "__modulong": "U32Mod",
    "__rrulong": "U32Shr",
    "__rlulong": "U32Shl",
}
# GBDK runtime variables (RAM, not in kernel.sym)
VARS = {"__cpu": 0xC4AC}
# the bank word stock has in each banked call: $FFFF for the two bank-0
# functions EZ Flash declared banked
BANKS = {"b_LoadKernel": 1, "b_disk_readp_impl": 0xFFFF, "b_DiskRead": 0xFFFF}

CFLAGS = ["-S", "-mgbz80", "--no-std-crt0", "-I", str(SRC)]
BANKCALL = re.compile(r"(\t\.dw\t(_\w+)\n)\t\.dw 0\s+; PENDING: bank support")


def run(cmd, cwd=None, env=None):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, stdin=subprocess.DEVNULL, env=env)
    out = r.stdout + r.stderr
    if r.returncode != 0:
        sys.exit(f"error: {' '.join(map(str, cmd))}\n{out}")
    # stock's source gives these too: 85 (disk_writep's unused arguments),
    # 110 (an always-true test in Petit FatFs); anything else is worth seeing
    for line in out.splitlines():
        if "warning" in line and not re.search(r"warning (85|110)\b", line):
            print(line, file=sys.stderr)
    return r


def load_syms(path):
    syms = {}
    for line in open(path):
        m = re.match(r"([0-9a-f]{2}):([0-9a-f]{4}) (\S+)$", line.strip())
        if m and not m[3].startswith("."):
            syms[m[3]] = (int(m[1], 16), int(m[2], 16))
    return syms


def rel_symbols(rel):
    refs, defs = set(), set()
    for line in open(rel):
        m = re.match(r"S\s+(\S+)\s+(Ref|Def)", line)
        if m:
            (refs if m[2] == "Ref" else defs).add(m[1])
    return refs, defs


def parse_ihx(path):
    out = {}
    for line in open(path):
        line = line.strip()
        if line.startswith(":") and int(line[7:9], 16) == 0:
            n, addr = int(line[1:3], 16), int(line[3:7], 16)
            for i, b in enumerate(bytes.fromhex(line[9:9 + 2 * n])):
                out[addr + i] = b
    return out


def parse_map(path):
    """Global symbols, and each area's (start, size) from sdld's s__/l__ symbols."""
    syms = {}
    for line in open(path):
        m = re.match(r"\s+([0-9A-F]{8})\s+(\S+)", line)
        if m:
            syms[m[2]] = int(m[1], 16)
    areas = {n[2:]: (syms[n], syms.get("l_" + n[2:], 0))
             for n in syms if n.startswith("s__")}
    return syms, areas


RGBDS_LABEL = re.compile(r"[A-Za-z][A-Za-z0-9_]*$")


def labels_for(syms, lo, hi, shift=0):
    """C globals in [lo, hi) as rgbds labels: _name -> name."""
    out = {}
    for name, addr in syms.items():
        if name.startswith("_") and not name.startswith("__") and lo <= addr < hi:
            label = name[1:]
            if RGBDS_LABEL.match(label):
                out.setdefault(addr + shift, []).append(label)
    return out


def write_inc(path, start, end, data, labels, fill):
    lines = [f"; Generated by stage1/decomp/tools/link.py from stage1/decomp/src, do not edit.",
             f"; ${start:04x}-${end - 1:04x}"]
    run_ = []

    def flush():
        for i in range(0, len(run_), 16):
            lines.append("    db " + ", ".join(f"${b:02x}" for b in run_[i:i + 16]))
        run_.clear()

    for a in range(start, end):
        if a in labels:
            flush()
            lines.extend(f"{n}::" for n in sorted(labels[a]))
        run_.append(data.get(a, fill(a)))
    flush()
    path.write_text("\n".join(lines) + "\n")


def splice(text, start_label, end_label, include):
    """Replace the lines from `start_label::` up to `end_label:` with an INCLUDE."""
    lines = text.splitlines(keepends=True)
    s = next(i for i, l in enumerate(lines) if l.rstrip() == f"{start_label}::")
    e = len(lines) if end_label is None else \
        next(i for i, l in enumerate(lines) if re.match(rf"{end_label}::?$", l.rstrip()))
    return "".join(lines[:s] + [f'INCLUDE "{include}"\n\n'] + lines[e:])


def build(fw):
    fwnum, fwdir = FWS[fw]
    out = DECOMP / "build" / f"fw{fwnum}"
    obj = out / "obj"
    asm = out / "asm"
    obj.mkdir(parents=True, exist_ok=True)
    sym = load_syms(fwdir / "kernel.sym")
    code0_end = sym["U32Mul"][1]

    if not (SDCC / "sdcc").exists():
        sys.exit(f"error: no {SDCC / 'sdcc'}: run stage1/decomp/tools/build-sdcc29.sh")
    env = dict(os.environ, PATH=f"{SDCC}:{os.environ['PATH']}")
    rels = []
    for src in OBJS:
        s = obj / (Path(src).stem + ".asm")
        rel = s.with_suffix(".rel")
        run([str(SDCC / "sdcc"), *CFLAGS, f"-DFW={fwnum}", str(SRC / src), "-o", str(s)], env=env)
        s.write_text(BANKCALL.sub(r"\1\t.dw\tb\2", s.read_text()))
        run(["sdasgb", "-plosgff", str(rel), str(s)])
        rels.append(rel)

    refs, defs = set(), set()
    for rel in rels:
        r, d = rel_symbols(rel)
        refs |= r
        defs |= d
    globs, missing = [], []
    for name in sorted(refs - defs):
        if name.startswith(("s__", "l__")):
            continue                        # sdld's area symbols
        if name in VARS:
            globs.append((name, VARS[name]))
        elif name in BANKS:
            globs.append((name, BANKS[name]))
        elif name == "_HandoffPollRom":       # HandoffPoll where it is stored
            globs.append((name, HANDOFF_ROM))
        else:
            base = name.removesuffix("_rrx_s")  # 2.9.0's stack-argument helpers
            target = ALIASES.get(base, base[1:] if base.startswith("_") else base)
            if target in sym:
                globs.append((name, sym[target][1]))
            else:
                missing.append(name)
    if missing:
        sys.exit("error: unresolved (add to kernel.sym or ALIASES): " + " ".join(missing))

    def link(bases):
        lk = ["-mjwx", "-i stage1.ihx"] + [f"-b {n}=0x{v:04x}" for n, v in bases.items()]
        lk += [f"-g {n}=0x{v:04x}" for n, v in globs]
        lk += [rel.name for rel in rels] + ["-e"]
        (obj / "stage1.lk").write_text("\n".join(lk) + "\n")
        run(["sdldgb", "-nf", "stage1.lk"], cwd=obj)
        return parse_map(obj / "stage1.map")

    # pass 1 for the sizes, pass 2 with every area placed
    bases = {"_CODE": CODE0, "_HOME": 0x3000, "_HANDOFF": HANDOFF_RUN,
             "_CODE_1": 0x4400, "_GSINIT": GSINIT, "_GSFINAL": 0x4700, "_DATA": RAM,
             "_OVERLAY": 0xC800}
    _, sizes = link(bases)
    size = lambda n: sizes.get(n, (0, 0))[1]
    bases["_HOME"] = CODE0 + size("_CODE")
    bases["_CODE_1"] = HANDOFF_ROM + size("_HANDOFF")
    bases["_GSFINAL"] = GSINIT + size("_GSINIT")
    syms, areas = link(bases)
    data = parse_ihx(obj / "stage1.ihx")

    def area(name):
        return areas.get(name, (0, 0))

    # _CODE_1, _DATA etc. follow the placed areas in link order: check where
    # everything landed against what stock leaves free.
    problems = []

    def within(name, lo, hi):
        base, size = area(name)
        if size and not (lo <= base and base + size <= hi):
            problems.append(f"{name} ${base:04x}+${size:x} outside ${lo:04x}-${hi:04x}")

    within("_CODE", CODE0, code0_end)
    within("_HOME", CODE0, code0_end)
    within("_HANDOFF", HANDOFF_RUN, HANDOFF_RUN + GSINIT - HANDOFF_ROM)
    within("_CODE_1", HANDOFF_ROM, GSINIT)
    within("_GSINIT", GSINIT, BRAM1_END)
    within("_DATA", RAM, RAM_END)
    for name in ("_HOME", "_GSFINAL", "_OVERLAY", "_DABS", "_CABS"):
        if area(name)[1]:
            problems.append(f"{name} is not empty")
    if problems:
        sys.exit("error: layout\n  " + "\n  ".join(problems))

    # HandoffPoll runs at $D100 and is stored at $4000
    for a in range(HANDOFF_RUN, HANDOFF_RUN + area("_HANDOFF")[1]):
        data[a - HANDOFF_RUN + HANDOFF_ROM] = data.pop(a)
    data[GSINIT + area("_GSINIT")[1]] = 0xC9      # crt0's _GSFINAL: ret

    if asm.exists():
        shutil.rmtree(asm)
    shutil.copytree(fwdir / "disassembly", asm,
                    ignore=shutil.ignore_patterns("game.*", "Makefile"))
    shutil.copy(fwdir / "disassembly" / "game.asm", asm / "game.asm")

    lab0 = labels_for(syms, CODE0, code0_end)
    write_inc(asm / "c_bank0.inc", CODE0, code0_end, data, lab0, lambda a: 0xFF)
    lab1 = labels_for(syms, HANDOFF_ROM, 0x8000)
    lab1.setdefault(HANDOFF_ROM, []).append("HandoffPoll")
    lab1.setdefault(GSINIT, []).append("InitMessages")
    write_inc(asm / "c_bank1.inc", HANDOFF_ROM, 0x8000, data, lab1,
              lambda a: 0xFF if a < BRAM1_END else 0x00)

    b0 = asm / "bank_000.asm"
    b0.write_text(splice(b0.read_text(), "PrintLine", "U32Mul", "c_bank0.inc"))
    b1 = asm / "bank_001.asm"
    b1.write_text(splice(b1.read_text(), "HandoffPoll", None, "c_bank1.inc"))

    gb = out / "stage1.gb"
    run(["rgbasm", "-I", str(asm), "-o", str(out / "game.o"), str(asm / "game.asm")])
    run(["rgblink", "-n", str(out / "stage1.sym"), "-m", str(out / "stage1.map"),
         "-o", str(gb), str(out / "game.o")])
    run(["rgbfix", "-f", "h", "-p", "255", str(gb)])

    used0 = area("_CODE")[1]
    stock = fwdir / "kernel.gb"
    same = "" if not stock.exists() else \
        ", same as stock" if gb.read_bytes() == stock.read_bytes() else ", DIFFERS from stock"
    print(f"{gb.relative_to(STAGE1.parent)}: bank 0 C ${CODE0:04x}-${CODE0 + used0 - 1:04x} "
          f"({used0} of {code0_end - CODE0} bytes), RAM ${RAM:04x}-${RAM + area('_DATA')[1] - 1:04x}{same}")
    return not same.startswith(", DIFFERS")


if __name__ == "__main__":
    ok = [build(fw) for fw in sys.argv[1:] or FWS]
    sys.exit(0 if all(ok) else 1)
