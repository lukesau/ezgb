#!/usr/bin/env python3
"""Annotated disassembly of a stock kernel, from the mod's names and notes.

    kernel/tools/stock-disasm.py 1.05e-0918 [--report]

kernel/<ver>/kernel.sym and notes.json describe the modded kernel. This
keeps what describes stock, runs mgbdis over the stock kernel built by
kernel/stock, adds the notes, and assembles the result, which must be the
kernel stock.sha1 lists. Output: kernel/stock/disassembly/<ver>/.

What is dropped, by comparing the stock and modded images:
  - names and blocks past the end of the stock image (the mod's banks)
  - names and blocks in what is fill in stock (the mod's injected code)
  - data blocks over stock code the mod patched (its hooks)
  - notes anchored on any of those
  - the end of a note from a line starting "Mod:"
  - names on stock code the mod changed, when they name the mod's code
    there: local names (Function_part) and the ones in MOD_NAMES
Other names on changed stock code stay: the address is a stock one.
--report lists those and the notes that mention the mod, for review.
"""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUILD = {"1.05e-0918": "build-0918", "1.04e": "build-104", "1.05e-0731": "build-0731"}
FILL = (0x00, 0xFF)
# the mod's names for code it wrote over stock code
MOD_NAMES = {"ApplyPixelSafe", "ReadJoypadLatched", "FolderIconGlyphs"}


def offset(bank, addr):
    if addr < 0x4000:
        return addr
    if addr < 0x8000:
        return bank * 0x4000 + addr - 0x4000
    return None                                  # RAM


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    report = "--report" in sys.argv
    ver = args[0] if args else "1.05e-0918"
    src = ROOT / "kernel" / ver
    stock_path = ROOT / "kernel/stock" / BUILD[ver] / "kernel.gb"
    stock = stock_path.read_bytes()
    mod = (src / "kernel.gb").read_bytes()
    n = len(stock)
    changed = bytearray(n)
    for i in range(n):
        changed[i] = stock[i] != mod[i]

    # the mod's injected blocks: changed bytes over stock fill, joined across
    # short gaps where a mod byte happens to equal the fill
    injected = bytearray(n)
    i = 0
    while i < n:
        if changed[i] and stock[i] in FILL:
            j = i
            gap = 0
            end = i
            while j < n and stock[j] in FILL and gap <= 8:
                if changed[j]:
                    end = j + 1
                    gap = 0
                else:
                    gap += 1
                j += 1
            injected[i:end] = b"\x01" * (end - i)
            i = end
        else:
            i += 1

    keep, dropped, patched = [], set(), []
    for raw in (src / "kernel.sym").read_text(encoding="utf-8").splitlines():
        f = raw.split(";", 1)[0].split()
        if len(f) < 2 or ":" not in f[0]:
            keep.append(raw)
            continue
        bank, addr = (int(x, 16) for x in f[0].split(":"))
        off = offset(bank, addr)
        name = f[1]
        if off is None:
            keep.append(raw)
            continue
        key = (bank, f[0].split(":")[1].lower())
        if off >= n:
            dropped.add(key)
            continue
        if name.startswith("."):
            length = int(name.split(":")[1], 16)
            span = range(off, min(off + length, n))
            if any(injected[k] for k in span) or all(stock[k] in FILL for k in span) and any(changed[k] for k in span):
                dropped.add(key)
                continue
            if any(changed[k] for k in span) and name.startswith(".data") and length <= 64:
                # a hook the mod wrote over stock code, marked as data
                patched.append(("block dropped", raw))
                dropped.add(key)
                continue
            keep.append(raw)
            continue
        if injected[off]:
            dropped.add(key)
            continue
        if changed[off]:
            if name in MOD_NAMES or re.search(r"_[a-z]", name):
                patched.append(("name dropped", raw))
                dropped.add(key)
                continue
            patched.append(("name kept", raw))
        keep.append(raw)

    notes = json.loads((src / "notes.json").read_text())
    blocks, modnotes = [], []
    for b in notes["blocks"]:
        off = offset(b["bank"], int(b["addr"], 16))
        if off is not None and (off >= n or injected[off] or (b["bank"], b["addr"].lower()) in dropped):
            continue
        # a note on stock code may end with what the mod does there
        for k, line in enumerate(b["lines"]):
            if line.startswith("Mod:"):
                b = dict(b, lines=b["lines"][:k])
                break
        blocks.append(b)
        if re.search(r"\b(mod|modded|hook\w*|inject\w*|shim\w*|patched|ezgb\.cfg)\b", " ".join(b["lines"]), re.I):
            modnotes.append(b)

    work = ROOT / "local/stock-disasm" / ver
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True)
    shutil.copy(stock_path, work / "kernel.gb")
    (work / "kernel.sym").write_text("\n".join(keep) + "\n", encoding="utf-8")
    (work / "notes.json").write_text(json.dumps({"blocks": blocks}, indent=1, ensure_ascii=False) + "\n")

    def run(cmd, ok=(0,), **kw):
        r = subprocess.run(cmd, capture_output=True, text=True, **kw)
        if r.returncode not in ok:
            sys.exit(f"failed: {' '.join(map(str, cmd))}\n{(r.stdout + r.stderr)[-3000:]}")
        return r

    run([sys.executable, "-u", ROOT / "tools/mgbdis/mgbdis.py", "kernel.gb", "--overwrite"], cwd=work)
    r = run([sys.executable, ROOT / "kernel/tools/annotate-disasm.py", str(work.relative_to(ROOT))], ok=(0, 1))
    orphans = [l for l in (r.stdout + r.stderr).splitlines() if "orphan" in l.lower() or "not found" in l.lower()]
    dis = work / "disassembly"
    mk = dis / "Makefile"
    mk.write_text(mk.read_text().replace("game.gbc", "game.gb"))
    run(["make", "-C", dis])

    # rgbfix rewrites the ROM size and both checksums; stock has its own
    built = bytearray((dis / "game.gb").read_bytes()[:n])
    for k in (0x148, 0x14D, 0x14E, 0x14F):
        built[k] = stock[k]
    want = hashlib.sha1(stock).hexdigest()
    listed = dict(l.split(" *")[::-1] for l in (ROOT / "stock.sha1").read_text().splitlines())
    assert listed[stock_path.relative_to(ROOT).as_posix()] == want
    same = hashlib.sha1(built).hexdigest() == want
    if not same:
        bad = [k for k in range(n) if built[k] != stock[k]]
        print(f"MISMATCH: {len(bad)} bytes, first at {bad[0] >> 14:02x}:{bad[0]:05x}")

    out = ROOT / "kernel/stock/disassembly" / ver
    if same:
        if out.exists():
            shutil.rmtree(out)
        out.mkdir(parents=True)
        for f in sorted(dis.iterdir()):
            if f.suffix in (".asm", ".inc") or f.name == "Makefile":
                shutil.copy(f, out / f.name)
    lines = sum(len(f.read_text().splitlines()) for f in dis.glob("bank_*.asm"))
    print(f"{ver}: {len(keep)} sym lines kept, {len(dropped)} dropped; "
          f"{len(blocks)} of {len(notes['blocks'])} notes kept; {lines} lines; "
          f"{'assembles to stock' if same else 'DOES NOT assemble to stock'}")
    print(f"  {len(patched)} names or blocks on stock code the mod changed, "
          f"{len(modnotes)} notes mention the mod, {len(orphans)} notes not placed")
    if report:
        for kind, raw in patched:
            print(f"  {kind}: {raw.strip()}")
        for b in modnotes:
            print(f"  note {b['bank']:02x}:{b['addr']} {b.get('name', '')}: {' '.join(b['lines'])[:110]}")
        for o in orphans:
            print("  " + o.strip())
    return 0 if same else 1


if __name__ == "__main__":
    sys.exit(main())
