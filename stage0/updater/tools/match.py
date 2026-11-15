#!/usr/bin/env python3
"""Byte-compare the updater's C, compiled by SDCC 2.9.0, against a stock updater.

    stage0/updater/tools/match.py [fw4|fw5-0918] [-v] [file ...]

Each src/*.c is compiled as the kernel's C is (--opt-code-size, GBDK
2.96a's headers) and assembled with a listing, and every function in it
that updater.sym names is compared with the official updater (local,
tools/ezflashjr/official). Operands the linker fills in (calls, jumps, globals)
are masked, and so is the bank word of a banked call: SDCC 2.9.0 writes it
as 0 ("PENDING: bank support"), where stock has the real bank.

The compiler is tools/sdcc-2.9.0 (stage1/decomp/tools/build-sdcc29.sh), or
SDCC29=<prefix>.
SDCC 2.9.0 has no sdasgb; any later one assembles its output (SDASGB=<path>,
default the one on PATH). Exit status 0 when every function matches. tools/link.py
checks the whole ROM; this says which function differs.
"""
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent          # stage0/updater
REPO = HERE.parent.parent
GBDK = REPO / "kernel" / "stock" / "gbdk"
STOCK = {"fw4": ("2020-03-10_FW4_K1.04e/Update_FW4.gb", 0, "Update to ver:4 "),
         "fw5-0918": ("2021-09-18_FW5_K1.05e/Update_FW5_2021-9-18.gb", 0x38, "Update to ver:5 ")}

args = sys.argv[1:]
verbose = "-v" in args
args = [a for a in args if a != "-v"]
fw = args.pop(0) if args and args[0].startswith("fw") else "fw4"
files = args or sorted(p.stem for p in (HERE / "src").glob("*.c"))

sdcc_dir = Path(os.environ.get("SDCC29", REPO / "tools" / "sdcc-2.9.0"))
sdcc = sdcc_dir / "bin" / "sdcc"
if not sdcc.exists():
    sys.exit(f"no {sdcc}: run stage1/decomp/tools/build-sdcc29.sh or set SDCC29")
sdas = os.environ.get("SDASGB", "sdasgb")
os.environ["PATH"] = f"{sdcc_dir / 'bin'}:{os.environ['PATH']}"      # its sdcpp wrapper

rom = (REPO / "tools" / "ezflashjr" / "official" / STOCK[fw][0]).read_bytes()
sym = {}
for line in (HERE / "updater.sym").read_text().splitlines():
    m = re.match(r"([0-9a-f]{2}):([0-9a-f]{4}) ([A-Za-z]\w*)$", line)
    if m:
        # updater.sym is FW4's; FW5's Update is longer, so bank 0 after it is higher
        up = STOCK[fw][1] if m[1] == "00" and int(m[2], 16) > 0x134D else 0
        sym[m[3]] = (int(m[1], 16), int(m[2], 16) + up)


def rom_off(bank, addr):
    return addr if bank == 0 else bank * 0x4000 + addr - 0x4000


def listing(src):
    """{function: [(bytes with None for relocated, source line)]} from the asm listing"""
    with tempfile.TemporaryDirectory() as d:
        asm = os.path.join(d, "o.asm")
        open(os.path.join(d, "label.h"), "w").write(f'#define LABEL "{STOCK[fw][2]}"\n')
        r = subprocess.run([str(sdcc), "-S", "-mgbz80", "--no-std-crt0", *os.environ.get("UPD_CFLAGS", "--opt-code-size").split(),
                            f"-DFW={fw[2]}", "-DBYTE_IS_UNSIGNED=1", f"-I{d}",
                            f"-I{GBDK / 'include'}", f"-I{HERE / 'src'}", str(src), "-o", asm], capture_output=True, text=True)
        if r.returncode:
            sys.exit(r.stdout + r.stderr)
        subprocess.run([sdas, "-plosgff", os.path.join(d, "o.rel"), asm], capture_output=True, cwd=d)
        lines = open(os.path.join(d, "o.lst")).read().splitlines()
    # sdas listings: address, bytes ("21r00s00": r/s mark bytes the linker
    # fills in), optional [cycles], then the source line number at a fixed
    # column. Lines that continue the bytes of the one above have no address
    # and nothing at the line-number column. Column widths differ between sdas
    # versions, so they are read from the first line with code.
    tok = r"(?:[rs]?[0-9A-F]{2})+"
    code = re.compile(rf"^(\s+[0-9A-F]{{4,8}})(?![0-9A-F])\s?(\s*{tok}(?:\s{tok})*)(\s+(?:\[\s*\d+\]\s+)?)(\d+)\s(.*)$")
    numcol = None
    funcs, cur = {}, None
    for line in lines:
        m = code.match(line)
        if m:
            numcol = numcol or m.start(4)
            text, raw = m[5].strip(), m[2]
        elif numcol and line[:numcol].strip() and not line[numcol:].strip() \
                and re.fullmatch(rf"\s*{tok}(?:\s{tok})*\s*", line[:numcol]):
            text, raw = None, line[:numcol]               # more bytes of the line above
        else:
            lab = re.search(r"\s(_\w+)::?\s*$", line)
            if lab:
                cur = lab[1][1:]
                funcs[cur] = []
            continue
        if cur is None:
            continue
        if text and "PENDING: bank" in text:             # banked call's bank word
            raw = "xx xx"
        raw = re.sub(r"[rs][0-9A-F]{2}", " xx", raw)
        bs = [None if t == "xx" else int(t, 16) for t in raw.split()]
        if text is None and funcs[cur]:
            funcs[cur][-1][0].extend(bs)
        elif text is not None:
            funcs[cur].append((bs, text))
    return funcs


ok = True
for f in files:
    for fn, ins in listing(HERE / "src" / f"{f}.c").items():
        if fn not in sym or not ins:
            continue
        off = rom_off(*sym[fn])
        pos, bad = 0, None
        for i, (bs, _) in enumerate(ins):
            if any(v is not None and rom[off + pos + j] != v for j, v in enumerate(bs)):
                bad = i
                break
            pos += len(bs)
        total = sum(len(b) for b, _ in ins)
        if bad is None:
            print(f"{f}.c {fn}: match ({total} bytes)")
            continue
        ok = False
        print(f"{f}.c {fn}: differs at instruction {bad} of {len(ins)}")
        if verbose:
            p = 0
            for i, (bs, s) in enumerate(ins[:bad + 4]):
                if i >= bad - 4:
                    got = "".join("??" if v is None else f"{v:02x}" for v in bs)
                    want = rom[off + p:off + p + len(bs)].hex()
                    print(f"  {'>>' if i == bad else '  '} {got:10} stock {want:10} {s}")
                p += len(bs)
sys.exit(0 if ok else 1)
