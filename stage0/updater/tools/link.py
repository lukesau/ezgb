#!/usr/bin/env python3
"""Build the firmware updater's program from source, byte for byte.

    tools/link.py fw4|fw5-0918 [--label TEXT] [--payload SLOTB.bin [--payload SECOND.bin]] [-o OUT.gb]

The updater is a 32 KB program (banks 0 and 1) followed by the bitstream
it writes. This builds the program: build/<fw>/updater-code.gb. With
--payload it also writes the whole updater: the program, then that 149,516
byte slot B image. The stock FW5
updaters carry a second bitstream after the first, which the program
never writes; a second --payload puts one there.

Everything is source. The C (src/) is compiled by SDCC 2.9.0 as the
kernel's is (--opt-code-size, GBDK 2.96a's headers); the startup code and
the libraries are the kernel's and stage1's:

    kernel/stock/gbdk      crt0, drawing, the 8x8 font, joypad, delay
    kernel/stock/sdcclib   SDCC 2.9.0's stubs, divide, shifts, strlen
    kernel/stock/src/libasm.s   the long math
    stage1/decomp/gbdk/font.s         the text console (stage1's revision of it)
    stage1/decomp/sdcclib/puts.c      puts

EZ Flash's linker put the library objects in an order of its own, the long
math in pieces between the others. So each object's areas get names of
their own here and an address each (OBJS), and the build checks that they
tile the ROM with no gap or overlap: a link in stock's order.

The program is compared with the hash in stock.sha1, so no file of EZ
Flash's is needed. --label changes the 16-character line that names the
version, which the check then skips.
"""
import argparse
import hashlib
import os
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent           # stage0/updater
REPO = HERE.parent.parent
KERNEL = REPO / "kernel" / "stock"
S1 = REPO / "stage1" / "decomp"
SDCC = Path(os.environ.get("SDCC29", REPO / "tools" / "sdcc-2.9.0")) / "bin"

# per firmware: -DFW, the stock label, how much longer Update() is than
# FW4's (everything after it in bank 0 moves up)
FWS = {"fw4": ("4", "Update to ver:4 ", 0x00),
       "fw5-0918": ("5", "Update to ver:5 ", 0x38)}
PAYLOAD = 149516

KCFLAGS = ["--opt-code-size", "-DBYTE_IS_UNSIGNED=1", f"-I{KERNEL / 'gbdk' / 'include'}"]

# (name, source, how it is built, {area: (new name, FW4 address or None)})
# An address is where the area starts in the FW4 updater; one after
# Update() is higher by the firmware's shift. None: the area keeps its
# name and follows the previous object's in the link.
C0, LIBC = "kernel-c", "plain-c"
OBJS = [
    ("crt0", KERNEL / "gbdk" / "crt0.s", "crt0", {}),
    ("updater", HERE / "src" / "updater.c", C0, {}),
    ("flash", HERE / "src" / "flash.c", C0, {}),
    ("fpga", HERE / "src" / "fpga.c", C0, {}),
    ("font12", HERE / "src" / "font12.c", C0, {}),
    ("errno", HERE / "src" / "errno.s", "asm", {}),
    ("font", S1 / "gbdk" / "font.s", "asm",
     {"_CODE": ("_FONT_C", 0x1C99), "_BASE": ("_FONT_B", 0x29CA), "_HEADER": ("_MODE_T", 0x03CD)}),
    ("shift", KERNEL / "sdcclib" / "shift.s", "asm", {"_CODE": ("_SHIFT", 0x1CD8)}),
    ("drawing", KERNEL / "gbdk" / "drawing.s", "drawing",
     {"_VBLLCD": ("_DRAW_V", 0x1D2F), "_CODE": ("_DRAW_C", 0x1D47), "_BASE": ("_DRAW_B", 0x3606),
      "_HEADER": ("_MODE_G", 0x05B6)}),
    ("puts", S1 / "sdcclib" / "puts.c", LIBC, {"_CODE": ("_PUTS", 0x2479)}),
    ("stubs", KERNEL / "sdcclib" / "stubs.s", "asm", {"_CODE": ("_STUBS", 0x24BE)}),
    ("strlen", KERNEL / "sdcclib" / "_strlen.c", LIBC, {"_CODE": ("_STRLEN", 0x2527)}),
    ("libasm", KERNEL / "src" / "libasm.s", "libasm",
     {"_LIB5B": ("_LIB5B", 0x254C), "_LIB5D": ("_LIB5D", 0x256B), "_LIB1": ("_LIB1", 0x2703),
      "_LIB2": ("_LIB2", 0x277C), "_LIB4": ("_LIB4", 0x2947), "_LIB5": ("_LIB5", 0x2951),
      "_LIB5C": ("_LIB5C", 0x2958), "_LIB5E": ("_LIB5E", 0x29B8),
      "_LIB0": ("_LIB0", "drop"), "_LIB3": ("_LIB3", "drop")}),
    ("div", KERNEL / "sdcclib" / "div.s", "asm", {"_CODE": ("_DIV", 0x2603)}),
    ("ibmfixed", KERNEL / "gbdk" / "ibmfixed.s", "asm", {"_BASE": ("_IBM", 0x2C88)}),
    ("cpy_data", KERNEL / "gbdk" / "cpy_data.s", "asm", {"_BASE": ("_CPY", 0x3591)}),
    ("pad", KERNEL / "gbdk" / "pad.s", "asm", {"_BASE": ("_PAD", 0x35B3)}),
    ("delay", KERNEL / "gbdk" / "delay.s", "asm", {"_BASE": ("_DELAY", 0x37F7)}),
    ("init_tt", KERNEL / "gbdk" / "init_tt.s", "asm", {"_BASE": ("_INIT_TT", 0x383A)}),
    ("poll", HERE / "src" / "poll.c", C0, {"_CODE": ("_POLL", 0xD000)}),
    ("bank1", HERE / "src" / "bank1.c", C0, {"_CODE": ("_CODE_1", 0x404E)}),
]
# libasm.s's last piece (_LIB5) is five objects in the updater: where each starts
LIBASM_CUTS = [(";; long __mullong(long a, long b)", "_LIB5B"), (";; lm_divmod(rem, quot, a, b)", "_LIB5C"),
               (";; lm_mul(prod, a, b)", "_LIB5D"), (";; carry from DE[] - HL[] over B bytes", "_LIB5E")]

HOME = 0x0600
CODE0 = 0x07BC          # first byte of C in bank 0
UPDATE = 0x134D         # Update(): bank 0 after it moves with its length
BANK0_END = 0x386C      # FW4: the first $FF after the libraries
POLL_ROM, POLL_RUN = 0x4000, 0xD000
GSINIT = 0x4182         # crt0: call gsinit. Nothing is initialized, so it is crt0's ret
RAM = 0xC0A0            # _DATA: updater.c's, then errno
BSS = 0xC2B1            # crt0's variables, then font.s's and drawing.s's
DROP = 0xE000           # areas the updater does not have (strcpy, memset, memcpy)
# font.s and drawing.s each have a mode table entry, three bytes in an
# absolute _HEADER area at an .org. GBDK's linker put them after crt0's
# _HEADER area, at $03CD and $05B6; here each is an area placed there.
GLOBALS = {".STACK": 0xE000, ".refresh_OAM": 0xFF80, ".OAM": 0xC000, ".init": 0, ".reset": 0,
           "_FlashPollRom": POLL_ROM}     # FlashPoll where it is stored
# the bank word of each banked call: $FFFF for the banked functions in bank 0
BANKS = {"b_SetFpga7FC0": 0xFFFF, "b_PlotGlyph12": 0xFFFF, "b_RunFlashPoll": 1}
BANKCALL = re.compile(r"(\t\.dw\t(_\w+)\n)\t\.dw 0\s+; PENDING: bank support")
# crt0.s is the kernel's: the updater's header differs in these lines
CRT0_EDITS = [('\t.ascii\t"EZGB"\n\t.byte\t0,0,0,0,0,0,0,0,0,0,0,0', '\t.ascii\t"UPDATE"\n\t.byte\t0,0,0,0,0,0,0,0,0,0'),
              ("\t.org\t0x148\n\t.byte\t0", "\t.org\t0x148\n\t.byte\t1"),
              ("BatteryCheck", "_main")]             # what the startup code calls


def run(cmd, cwd=None, env=None):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, stdin=subprocess.DEVNULL, env=env)
    if r.returncode != 0:
        sys.exit(f"error: {' '.join(map(str, cmd))}\n{r.stdout}{r.stderr}")
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
    syms = {}
    for line in open(path):
        m = re.match(r"\s+([0-9A-F]{8})\s+(\S+)", line)
        if m:
            syms[m[2]] = int(m[1], 16)
    areas = {n[2:]: (syms[n], syms.get("l_" + n[2:], 0)) for n in syms if n.startswith("s__")}
    return syms, areas


def rename_areas(text, areas):
    for old, (new, _) in areas.items():
        if old == "_HEADER":                    # the mode table entry: no longer absolute
            text, n = re.subn(r"\.area\s+_HEADER\s*\(ABS\)\s*\n\s*\.org[^\n]*\n", f".area\t{new}\n", text)
            if n != 1:
                sys.exit(f"error: no absolute _HEADER area to move to {new}")
            continue
        text, n = re.subn(rf"(\.area\s+){old}\b", rf"\g<1>{new}", text)
        if not n and old == "_CODE":            # a source with no .area is all _CODE
            text = f"\t.area\t{new}\n" + text
    return text


def build(fw, label=None, payload=None, outpath=None):
    fwnum, stock_label, shift = FWS[fw]
    label = stock_label if label is None else label
    if len(label.encode("ascii")) > 16:
        sys.exit("error: the label is at most 16 characters")
    out = HERE / "build" / fw
    obj = out / "obj"
    obj.mkdir(parents=True, exist_ok=True)
    if not (SDCC / "sdcc").exists():
        sys.exit(f"error: no {SDCC / 'sdcc'}: run stage1/decomp/tools/build-sdcc29.sh")
    env = dict(os.environ, PATH=f"{SDCC}:{os.environ['PATH']}")
    (obj / "label.h").write_text(f'#define LABEL "{label.ljust(16)}"\n')

    place = {}                      # area -> address
    rels = []
    for name, src, kind, areas in OBJS:
        rel = obj / f"{name}.rel"
        s = obj / f"{name}.s"
        if kind in (C0, LIBC):
            flags = KCFLAGS + [f"-DFW={fwnum}", f"-I{obj}", f"-I{HERE / 'src'}"] if kind == C0 else []
            run([str(SDCC / "sdcc"), "-S", "-mgbz80", "--no-std-crt0", *flags, str(src), "-o", str(s)], env=env)
            text = BANKCALL.sub(r"\1\t.dw\tb\2", s.read_text())
        else:
            text = src.read_text()
            if kind == "crt0":
                for a, b in CRT0_EDITS:
                    if a not in text:
                        sys.exit(f"error: {src} has no {a!r}")
                    text = text.replace(a, b)
            if kind == "drawing":
                # the kernel's drawing.s has its two colour variables last
                # in _BSS; the updater's, like GBDK 2.96a's and stage1's,
                # has them first
                m = re.search(r"\t;; ezgb: stock has fg_colour.*?\.bg_colour::\s*\n\t\.ds\t1\n", text, re.S)
                head = "\t.area\t_BSS\n"
                if not m or head not in text:
                    sys.exit(f"error: {src}: no colour variables to move")
                colours = re.sub(r"^\t;; ezgb:.*\n", "", m[0])
                text = (text[:m.start()] + text[m.end():]).replace(head, head + colours, 1)
            if kind == "libasm":
                for mark, area in LIBASM_CUTS:
                    if mark not in text:
                        sys.exit(f"error: {src} has no {mark!r}")
                    text = text.replace(mark, f"\t.area\t{area}\n{mark}")
        s.write_text(rename_areas(text, areas))
        run(["sdasgb", "-plosgff", f"-I{src.parent}", f"-I{KERNEL / 'gbdk'}", str(rel), str(s)])
        rels.append(rel)
        for new, addr in areas.values():
            place[new] = DROP if addr == "drop" else addr + (shift if UPDATE < addr < 0x4000 else 0)

    refs, defs = set(), set()
    for rel in rels:
        r, d = rel_symbols(rel)
        refs |= r
        defs |= d
    globs, missing = [], []
    for name in sorted(refs - defs):
        if name.startswith(("s__", "l__")):
            continue
        if name in GLOBALS:
            globs.append((name, GLOBALS[name]))
        elif name in BANKS:
            globs.append((name, BANKS[name]))
        else:
            missing.append(name)
    if missing:
        sys.exit("error: unresolved: " + " ".join(missing))

    bases = dict(place)
    bases.update({"_HOME": HOME, "_CODE": CODE0, "_GSINIT": GSINIT, "_GSINITTAIL": GSINIT, "_GSFINAL": GSINIT + 1,
                  "_DATA": RAM, "_BSS": BSS, "_BASE": DROP + 0x800, "_LIT": DROP + 0x800, "_OVERLAY": DROP + 0x900,
                  "_LIB0": DROP, "_LIB3": DROP + 0x100})
    lk = ["-mjwx", "-i updater.ihx"] + [f"-b {n}=0x{v:04x}" for n, v in bases.items()]
    lk += [f"-g {n}=0x{v:04x}" for n, v in globs]
    lk += [rel.name for rel in rels] + ["-e"]
    (obj / "updater.lk").write_text("\n".join(lk) + "\n")
    run(["sdldgb", "-nf", "updater.lk"], cwd=obj)
    syms, areas = parse_map(obj / "updater.map")
    data = parse_ihx(obj / "updater.ihx")

    # the areas of bank 0 from the C on, and of bank 1, must tile
    def tiles(names, start, what):
        spans = sorted((areas[n][0], areas[n][0] + areas[n][1], n) for n in names if areas.get(n, (0, 0))[1])
        at = start
        for lo, hi, n in spans:
            if lo != at:
                sys.exit(f"error: {what}: {n} is at ${lo:04x}, the area before it ends at ${at:04x}")
            at = hi
        return at

    rom0 = ["_CODE"] + [n for n, v in place.items() if isinstance(v, int) and CODE0 <= v < 0x4000]
    end0 = tiles(rom0, CODE0, "bank 0")
    end1 = tiles(["_CODE_1"], 0x404E, "bank 1")
    if areas["_POLL"][1] != 0x404E - POLL_ROM or end1 != GSINIT:
        sys.exit(f"error: bank 1: FlashPoll is ${areas['_POLL'][1]:x} bytes, the C ends at ${end1:04x}")
    for n in ("_BASE", "_LIT", "_OVERLAY", "_GSINIT", "_GSFINAL", "_HEAP"):
        if areas.get(n, (0, 0))[1]:
            sys.exit(f"error: {n} is not empty")

    # FlashPoll runs at $D000 and is stored at $4000
    for a in range(POLL_RUN, POLL_RUN + areas["_POLL"][1]):
        data[a - POLL_RUN + POLL_ROM] = data.pop(a)
    rom = bytearray(data.pop(a, 0xFF) for a in range(0x8000))
    stray = sorted(a for a in data if a < DROP)
    if stray:
        sys.exit(f"error: bytes outside the ROM image at ${stray[0]:04x}")

    # The header checksum, and the global checksum as EZ Flash's tools left
    # it: in both stock updaters it is the sum of the 32 KB program plus
    # $7F70, whatever follows. It is not the sum of the file, and nothing
    # checks it.
    c = 0
    for v in rom[0x134:0x14D]:
        c = (c - v - 1) & 0xFF
    rom[0x14D] = c
    rom[0x14E:0x150] = b"\0\0"
    rom[0x14E:0x150] = ((sum(rom) + 0x7F70) & 0xFFFF).to_bytes(2, "big")
    code = out / "updater-code.gb"
    code.write_bytes(rom)
    with open(out / "updater.sym", "w") as f:
        for name, a in sorted(syms.items(), key=lambda t: t[1]):
            if not name.startswith(("s__", "l__", ".__")) and a < 0x8000:
                f.write(f"{1 if a >= 0x4000 else 0:02x}:{a:04x} {name}\n")
    want = dict(l.split(" *")[::-1] for l in (REPO / "stock.sha1").read_text().splitlines()).get(
        code.relative_to(REPO).as_posix())
    got = hashlib.sha1(rom).hexdigest()
    same = "" if label != stock_label else ", same as stock" if got == want else f", DIFFERS from stock (sha1 {got})"
    print(f"{code.relative_to(REPO)}: bank 0 to ${end0 - 1:04x}{same}")
    if payload:
        full = bytearray(rom)
        for f in payload:
            bits = Path(f).read_bytes()
            if len(bits) != PAYLOAD or bits[32:36] != b"\xaa\x99\x30\xa1":
                sys.exit(f"error: {f} is not a raw 149,516-byte XC3S200A stream")
            full += bits
        dest = Path(outpath) if outpath else out / "updater.gb"
        dest.write_bytes(full)
        print(f"{dest}: {len(full)} bytes")
    return "DIFFERS" not in same


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("fw", nargs="*", default=list(FWS))
    ap.add_argument("--label")
    ap.add_argument("--payload", action="append", help="slot B image; a second one follows it, unwritten, as in the FW5 updaters")
    ap.add_argument("-o", "--out")
    a = ap.parse_args()
    ok = [build(fw, a.label, a.payload, a.out) for fw in a.fw]
    sys.exit(0 if all(ok) else 1)
