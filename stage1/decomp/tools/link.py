#!/usr/bin/env python3
"""Build stock stage1 from source, byte for byte.

Everything is source: GBDK's crt0 (gbdk/), the C (src/), SDCC 2.9.0's and
GBDK 2.96a's library modules (sdcclib/, gbdk/), and the library code no
published source has, converted from the disassembly (asm/). The C is
compiled by SDCC 2.9.0 (tools/sdcc-2.9.0, from build-sdcc29.sh), the
compiler EZ Flash used, with no options; everything is linked by sdldgb in
GBDK lcc's order, and the ROM is written from the link. When the firmware's
kernel.gb is present (local, from stage1-from-bram.py) the build is compared
with it and fails if it differs.

    tools/link.py fw4       -> build/fw4/stage1.gb
    tools/link.py fw5-0918  -> build/fw5/stage1.gb

Layout (FW4; FW5-0918's bank 0 is $31 longer from main on):

    00:0000-01E2  gbdk/crt0.s: vectors, header, startup          (_HEADER)
    00:03CD-03CF  gbdk/font.s: its mode table entry               (_HEADER, see below)
    00:0400-05BB  gbdk/crt0.s: interrupts, modes, banked_call     (_HOME)
    00:05BC-2D24  the C, then the library code                    (_CODE)
    00:2D25-39A3  GBDK font, set_data, the 8x8 font, joypad, delay (_BASE)
    01:4000-40AD  handoff_poll.c, run at $D100                    (_HANDOFF)
    01:40AE-4133  handoff.c                                       (_CODE_1)
    01:4134-4160  gsinit: main.c's initialized globals, crt0's ret
    $C0A0-$C4AB   LoadCmd, the messages, FatFs, the sector buffer, errno (_DATA)
    $C4AC-        crt0's, font.s's and drawing_isr.s's variables  (_BSS)

Two things EZ Flash's tools did that sdldgb does not: SDCC 2.9.0 writes a
banked call's bank word as 0 ("PENDING: bank support") and the build writes
the bank (BANKS); and GBDK 2.96a's linker put font.s's absolute mode-table
entry after crt0's _HEADER area, at $03CD, not at its .org ($01E9), so the
build moves those three bytes there.
"""
import os
import re
import subprocess
import sys
from pathlib import Path

DECOMP = Path(__file__).resolve().parent.parent
STAGE1 = DECOMP.parent
SRC = DECOMP / "src"
GBDK = DECOMP / "gbdk"
SDCC = STAGE1.parent / "tools" / "sdcc-2.9.0" / "bin"

FWS = {"fw4": ("4", STAGE1 / "fw4"), "fw5-0918": ("5", STAGE1 / "fw5-0918")}

# Link order, as lcc linked it: crt0, the program, then the library modules
# in the order stock has them. RAM follows it too: main.c's LoadCmd and
# messages first ($C0A0), then pff.c's FatFs, sd.c's buffer, long.s's errno;
# crt0's variables, then font.s's and drawing_isr.s's.
OBJS = ["gbdk/crt0.s",
        "src/main.c", "src/diskio.c", "src/pff.c", "src/sd.c", "src/handoff_poll.c", "src/handoff.c",
        "sdcclib/stubs.s", "asm/div.s", "sdcclib/shift.s", "gbdk/font.s", "asm/drawing_isr.s",
        "asm/long.s", "sdcclib/puts.c", "asm/long2.s",
        "gbdk/cpy_data.s", "gbdk/ibmfixed.s", "gbdk/pad.s", "gbdk/delay.s"]

HOME = 0x0400           # crt0's _HOME
CODE0 = 0x05BC          # first byte of C in bank 0: PrintLine
BANK0_END = 0x4000
HANDOFF_ROM = 0x4000
HANDOFF_RUN = 0xD100
GSINIT = 0x4134         # crt0: call $4134 (gsinit)
BRAM1_END = 0x4200      # stock pads bank 1 with $FF to $41FF, zeros after
RAM = 0xC0A0
BSS = 0xC4AC
# font.s's mode table entry: its .org ($01E9), and where GBDK 2.96a's linker
# put it, after crt0's _HEADER area ($01E4 + $01E9 = $03CD)
MODE_ENTRY = (0x01E9, 0x03CD)

# header bytes that differ per firmware (gbdk/crt0.s includes fw.s)
HEADER = {"4": {".SGB_FLAG": 0x00, ".LICENSEE": 0x00, ".CSUM_HI": 0xB3, ".CSUM_LO": 0x2E},
          "5": {".SGB_FLAG": 0x03, ".LICENSEE": 0x33, ".CSUM_HI": 0x8E, ".CSUM_LO": 0xE3}}
# addresses GBDK's linker defines, and two that global.s declares but
# nothing here uses
GLOBALS = {".STACK": 0xE000, ".refresh_OAM": 0xFF80, ".OAM": 0xC000, ".init": 0, ".reset": 0,
           "_HandoffPollRom": HANDOFF_ROM}      # HandoffPoll where it is stored
# the bank word stock has in each banked call: $FFFF for the two bank-0
# functions EZ Flash declared banked
BANKS = {"b_LoadKernel": 1, "b_disk_readp_impl": 0xFFFF, "b_DiskRead": 0xFFFF}

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


def build(fw):
    fwnum, fwdir = FWS[fw]
    out = DECOMP / "build" / f"fw{fwnum}"
    obj = out / "obj"
    obj.mkdir(parents=True, exist_ok=True)

    if not (SDCC / "sdcc").exists():
        sys.exit(f"error: no {SDCC / 'sdcc'}: run stage1/decomp/tools/build-sdcc29.sh")
    env = dict(os.environ, PATH=f"{SDCC}:{os.environ['PATH']}")
    (obj / "fw.s").write_text(f"\tFW = {fwnum}\n" + "".join(
        f"\t{k} = 0x{v:02X}\n" for k, v in HEADER[fwnum].items()))
    rels = []
    for src in OBJS:
        rel = obj / (Path(src).stem + ".rel")
        if src.endswith(".s"):
            run(["sdasgb", "-plosgff", f"-I{GBDK}", f"-I{obj}", str(rel), str(DECOMP / src)])
        else:
            s = rel.with_suffix(".asm")
            run([str(SDCC / "sdcc"), "-S", "-mgbz80", "--no-std-crt0", f"-DFW={fwnum}",
                 f"-I{SRC}", str(DECOMP / src), "-o", str(s)], env=env)
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
        if name in GLOBALS:
            globs.append((name, GLOBALS[name]))
        elif name in BANKS:
            globs.append((name, BANKS[name]))
        else:
            missing.append(name)
    if missing:
        sys.exit("error: unresolved: " + " ".join(missing))

    def link(bases):
        lk = ["-mjwx", "-i stage1.ihx"] + [f"-b {n}=0x{v:04x}" for n, v in bases.items()]
        lk += [f"-g {n}=0x{v:04x}" for n, v in globs]
        lk += [rel.name for rel in rels] + ["-e"]
        (obj / "stage1.lk").write_text("\n".join(lk) + "\n")
        run(["sdldgb", "-nf", "stage1.lk"], cwd=obj)
        return parse_map(obj / "stage1.map")

    # pass 1 for the sizes, pass 2 with every area placed
    bases = {"_HOME": HOME, "_CODE": CODE0, "_BASE": 0x3800, "_HANDOFF": HANDOFF_RUN,
             "_CODE_1": 0x4400, "_GSINIT": GSINIT, "_GSINITTAIL": 0x4700, "_GSFINAL": 0x4700,
             "_DATA": RAM, "_BSS": BSS, "_OVERLAY": 0xC800}
    _, sizes = link(bases)
    size = lambda n: sizes.get(n, (0, 0))[1]
    bases["_BASE"] = CODE0 + size("_CODE")
    bases["_CODE_1"] = HANDOFF_ROM + size("_HANDOFF")
    bases["_GSINITTAIL"] = GSINIT + size("_GSINIT")
    bases["_GSFINAL"] = bases["_GSINITTAIL"] + size("_GSINITTAIL")
    syms, areas = link(bases)
    data = parse_ihx(obj / "stage1.ihx")
    area = lambda n: areas.get(n, (0, 0))

    problems = []

    def within(name, lo, hi):
        base, n = area(name)
        if n and not (lo <= base and base + n <= hi):
            problems.append(f"{name} ${base:04x}+${n:x} outside ${lo:04x}-${hi:04x}")

    within("_HOME", HOME, CODE0)
    within("_CODE", CODE0, BANK0_END)
    within("_BASE", CODE0, BANK0_END)
    within("_HANDOFF", HANDOFF_RUN, HANDOFF_RUN + GSINIT - HANDOFF_ROM)
    within("_CODE_1", HANDOFF_ROM, GSINIT)
    within("_GSINIT", GSINIT, BRAM1_END)
    within("_DATA", RAM, BSS)
    for name in ("_LIT", "_GSFINAL", "_OVERLAY", "_HEAP", "_DABS", "_CABS"):
        if area(name)[1]:
            problems.append(f"{name} is not empty")
    if problems:
        sys.exit("error: layout\n  " + "\n  ".join(problems))

    # HandoffPoll runs at $D100 and is stored at $4000
    for a in range(HANDOFF_RUN, HANDOFF_RUN + area("_HANDOFF")[1]):
        data[a - HANDOFF_RUN + HANDOFF_ROM] = data.pop(a)
    # font.s's mode table entry, where GBDK 2.96a's linker put it
    org, at = MODE_ENTRY
    for i in range(3):
        data[at + i] = data.pop(org + i)

    rom = bytearray(0x8000)
    for a in range(0x8000):
        rom[a] = data.pop(a, 0xFF if a < BRAM1_END else 0x00)
    stray = sorted(a for a in data if a < 0x8000)
    if stray:
        sys.exit(f"error: bytes outside the ROM image at ${stray[0]:04x}")
    gb = out / "stage1.gb"
    gb.write_bytes(rom)
    run(["rgbfix", "-f", "h", "-p", "255", str(gb)])
    with open(out / "stage1.sym", "w") as f:
        for name, a in sorted(syms.items(), key=lambda t: t[1]):
            if not name.startswith(("s__", "l__", ".__")) and a < 0x8000:
                bank = 1 if HANDOFF_ROM <= a else 0
                f.write(f"{bank:02x}:{a:04x} {name}\n")

    stock = fwdir / "kernel.gb"
    same = "" if not stock.exists() else \
        ", same as stock" if gb.read_bytes() == stock.read_bytes() else ", DIFFERS from stock"
    print(f"{gb.relative_to(STAGE1.parent)}: bank 0 ${0:04x}-${area('_BASE')[0] + area('_BASE')[1] - 1:04x}, "
          f"RAM ${RAM:04x}-${BSS + area('_BSS')[1] - 1:04x}{same}")
    return not same.startswith(", DIFFERS")


if __name__ == "__main__":
    ok = [build(fw) for fw in sys.argv[1:] or FWS]
    sys.exit(0 if all(ok) else 1)
