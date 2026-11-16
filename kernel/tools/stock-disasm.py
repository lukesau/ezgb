#!/usr/bin/env python3
"""Annotated disassembly of a stock kernel, from the mod's names and notes.

    kernel/tools/stock-disasm.py 1.05e-0918 [--report]

kernel/<ver>/kernel.sym and notes.json describe the modded kernel. This
keeps what describes stock, runs mgbdis over the stock kernel built by
kernel/stock, adds the notes, and assembles the result, which must be the
kernel stock.sha1 lists. Output: kernel/stock/disassembly/<ver>/, with the
names (kernel.sym) and notes (notes.json) it was made from. kernel/stock's
build takes its names from that kernel.sym, so the source and the
disassembly name every address alike.

The notes are also brought in line with the listing:
  - a note on a routine the source build defines starts with its source file
  - mgbdis's names for addresses that have since been named (Jump_009_6995)
    become those names, and "Name ($addr)" gets this kernel's address

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

# Names the mod's kernel.sym has wrong, as writing the source showed
# (kernel/stock/README.md). Local names (Old_part) follow. The long
# division and modulo were swapped, stubs and bodies.
RENAMES = {
    "S32Div": "S32Mod", "S32Mod": "S32Div", "U32Div": "U32Mod", "U32Mod": "U32Div",
    "S32DivImpl": "S32ModImpl", "S32ModImpl": "S32DivImpl",
    "U32DivImpl": "U32ModImpl", "U32ModImpl": "U32DivImpl",
    "S32DivImpl_loadQuot": "S32ModImpl_loadRem", "S32ModImpl_loadRem": "S32DivImpl_loadQuot",
    "Open_B9": "Mkdir_B9",                       # bank 9's one API call is f_mkdir
    "FormatFileSize": "WToUpper_B1",             # FatFs's ff_wtoupper
    "wFileSizeFmtLo": "wWToUpperCvt1", "wFileSizeFmtHi": "wWToUpperCvt2",
    "BuildSaverBackupPath": "SortEntries_B1",
    "PreLaunchSaveStamp": "BackupOpenSaverPath_stamp",   # a tail, not a function
    "DateToDaysSince1970": "DateToSecondsSince1970",
    "DiskRead_B2": "SdRead", "DiskWrite_B2": "SdWrite",
    # both count seconds, not days
    "RtcToDayCount": "RtcToSeconds", "RtcWriteTimeFromDayDelta": "RtcWriteTimeFromDelta",
    # named for the operation the wrong way round: each adds one field
    "RtcWriteTimeFromDayDelta_div60a": "RtcWriteTimeFromDelta_addSec",
    "RtcWriteTimeFromDayDelta_modSec": "RtcWriteTimeFromDelta_addMin",
    "RtcWriteTimeFromDayDelta_modMin": "RtcWriteTimeFromDelta_addHour",
    "RtcWriteTimeFromDayDelta_modHr": "RtcWriteTimeFromDelta_addDays",
    # ff_wtoupper's parts, named when it was taken for a size formatter
    "FormatFileSize_pickFmtHi": "WToUpper_B1_pickCvt2", "FormatFileSize_pickFmtLo": "WToUpper_B1_pickCvt1",
    "FormatFileSize_walkTable": "WToUpper_B1_nextBlock",
    "FormatFileSize_opScaleSubA": "WToUpper_B1_caseTable", "FormatFileSize_opScaleSubB": "WToUpper_B1_casePairs",
    "FormatFileSize_opSub10": "WToUpper_B1_caseSub16", "FormatFileSize_opSub20": "WToUpper_B1_caseSub32",
    "FormatFileSize_opSub30": "WToUpper_B1_caseSub48", "FormatFileSize_opSub1a": "WToUpper_B1_caseSub26",
    "FormatFileSize_opAdd8": "WToUpper_B1_caseAdd8", "FormatFileSize_opSub50": "WToUpper_B1_caseSub80",
    "FormatFileSize_opSub1c60": "WToUpper_B1_caseSub1c60", "FormatFileSize_afterOp": "WToUpper_B1_skipTable",
    "FormatFileSize_rewriteLo16": "WToUpper_B1_storeResult", "FormatFileSize_retDeHl": "WToUpper_B1_ret",
}
RENAME_RE = re.compile(r"\b(" + "|".join(sorted(RENAMES, key=len, reverse=True)) + r")(?![A-Za-z0-9])")


def renamed(text):
    return RENAME_RE.sub(lambda m: RENAMES[m.group(1)], text)


# Notes written under the wrong name, by the corrected name: the whole note,
# or (old, new) pairs to change in it.
NOTE_FIXES = {
    "S32Mod": ["S32Mod: SDCC's __modslong_rrx_s stub, jp S32ModImpl. Signed long remainder."],
    "U32Mod": ["U32Mod: SDCC's __modulong_rrx_s stub, jp U32ModImpl. Unsigned long remainder."],
    "S32Div": ["S32Div: SDCC's __divslong_rrx_s stub, jp S32DivImpl. Signed long quotient."],
    "U32Div": ["U32Div: SDCC's __divulong_rrx_s stub, jp U32DivImpl. Unsigned long quotient; U32ToAscii's digit loop."],
    "S32ModImpl": ["S32ModImpl: __modslong, the signed long remainder. A zero dividend gives 0, a zero divisor",
                   "$7fffffff; else it negates negative operands, runs U32DivEngine and gives the remainder",
                   "the dividend's sign."],
    "U32ModImpl": ["U32ModImpl: __modulong, the unsigned long remainder. A zero dividend gives 0, a zero",
                   "divisor $7fffffff; else U32DivEngine."],
    "S32DivImpl": ["S32DivImpl: __divslong, the signed long quotient. A zero dividend gives 0, a zero divisor",
                   "$7fffffff; else it negates negative operands, runs U32DivEngine and negates the quotient",
                   "when the signs differ."],
    "U32DivImpl": ["U32DivImpl: __divulong, the unsigned long quotient. A zero dividend gives 0, a zero",
                   "divisor $7fffffff; else U32DivEngine."],
    "WToUpper_B1": ["WToUpper_B1(uni): FatFs's ff_wtoupper as ffunicode.c has it from R0.12 on, banked.",
                    "Nothing calls it. Walks a compressed table: wWToUpperCvt1 below U+1000, else wWToUpperCvt2."],
    "wWToUpperCvt1": ["wWToUpperCvt1: WToUpper_B1's compressed conversion table for U+0000 to U+0FFF."],
    "wWToUpperCvt2": ["wWToUpperCvt2: WToUpper_B1's compressed conversion table for U+1000 to U+FFFF."],
    "SortEntries_B1": ["SortEntries_B1: bubble-sorts the browser's entries by name, swapping two through wSaveBuf."],
    "Mkdir_B9": [("Mkdir_B9(fp, path, mode): FatFs f_open.", "Mkdir_B9(path): FatFs f_mkdir.")],
    "DateToSecondsSince1970": [("(HL:DE), despite name.", "(HL:DE), less eight hours: the RTC holds UTC+8.")],
    "RtcToSeconds": [("Returns HL:DE day count.", "Returns the seconds in HL:DE.")],
    "RtcWriteTimeFromDelta": [
        "RtcWriteTimeFromDelta(base): delta = RtcToSeconds() - base, the seconds the game's clock has to catch up.",
        "base == 0 or delta < 0 -> RtcWriteTimeFromDelta_zeroHms zeroes the clock.",
        "RtcWriteTimeFromDelta_seedC0a0: sec, min, hour, days and control from wSaveBuf ($c0a0, one per 4 bytes); out of",
        "range -> RtcWriteTimeFromDelta_overflowZero zeroes them.",
        "RtcWriteTimeFromDelta_addSec: sec += delta % 60 (S32Mod), carrying into min.",
        "RtcWriteTimeFromDelta_addMin: delta /= 60 (S32Div); min += delta % 60, carrying into hour.",
        "RtcWriteTimeFromDelta_addHour: delta /= 60; hour += delta % 24, carrying into days.",
        "RtcWriteTimeFromDelta_addDays: delta /= 24; days += delta. Past $ff sets the day's bit 8 in the control byte,",
        "past $1ff the day carry.",
        "RtcWriteTimeFromDelta_writeFpga: write HMS/day $A018..$A01C (page $06) + mirror $A220..$A224 (page $03/$11).",
        "Returns the time now."],
    "BackupOpenSaverPath_stamp": [
        ("BackupOpenSaverPath_stamp: page", "BackupOpenSaverPath_stamp: the shared tail of BackupOpenSaverPath, not a function. Page"),
        ("ROM size@$A210\u201313", "the time now@$A210\u201313")],
    "FindVolume_B5": [("U32Div nonzero \u2192", "cluster count (U32Div by the cluster size) nonzero \u2192")],
    "Lseek_B3": [("else U32Div cluster align \u2014", "else U32Div by the cluster size:")],
}

# 1.04e has no game clock, and its notes were carried over from 1.05e with
# the clock handling still in them. Written again from the K104 source.
NOTE_FIXES_VER = {"1.04e": {
    "BackupOpenSaverPath": [
        "BackupOpenSaverPath(path): build wTmp = \"/SAVER/\" + name with the extension forced to .sav, and open it.",
        "Save size from the cart type ($d3ed): 0 -> $2000 if $d3eb == 2 else 0; 1 and 2 -> $2000; 4 -> $20000;",
        "5 -> $10000; else $8000.",
        "Opened: the size is the file's, and it is read into the save pSRAM 512 bytes at a time through wSaveBuf.",
        "Not there: the save pSRAM is filled with $FF for that size.",
        "Then BackupOpenSaverPath_stamp. 1.05e's clock handling is not in 1.04e."],
    "BackupOpenSaverPath_stamp": [
        "BackupOpenSaverPath_stamp: the shared tail of BackupOpenSaverPath, not a function. Page $11 of the save pSRAM",
        "gets the per-launch stamp: $A000=$AA backup pending, $A001=save size in 8 KB banks, $A00F=path length,",
        "$A010+=the save's path. 1.04e writes no clock stamp ($A202, $A210)."],
    "BackupSaveDump": [
        "BackupSaveDump(path, size): write the save pSRAM to wTmp (the .sav path); path is not used.",
        "Opens it for writing, creating it if needed, and returns if that fails.",
        "BackupSaveDump_writeLoop: 512 bytes at a time from the pSRAM through wSaveBuf, drawing one to three dots",
        "as it goes. Then closes the file. 1.05e's 48-byte clock footer is not in 1.04e."],
}}


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

    keep = [renamed(raw) for raw in keep]

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

    nkept = len(blocks)
    names = {}                                   # (bank, addr) -> name
    addr_of = {}
    for raw in keep:
        f = raw.split(";", 1)[0].split()
        if len(f) >= 2 and ":" in f[0] and not f[1].startswith("."):
            bank, addr = (int(x, 16) for x in f[0].split(":"))
            names.setdefault((bank, addr), f[1])
            addr_of.setdefault(f[1], addr)

    def at(m):
        a = addr_of.get(m.group(1))
        return m.group(0) if a is None else f"{m.group(1)} (${a:04x})"

    fixed = 0
    for b in blocks:
        b["lines"] = [renamed(line) for line in b["lines"]]
        if "name" in b:
            b["name"] = renamed(b["name"])
        here = names.get((b["bank"], int(b["addr"], 16)))
        fix = NOTE_FIXES_VER.get(ver, {}).get(here) or NOTE_FIXES.get(here)
        if fix and b.get("at") != "section":
            if isinstance(fix[0], tuple):
                text = "\n".join(b["lines"])
                for old, new in fix:
                    if old not in text:
                        sys.exit(f"note fix does not apply: {old}")
                    text = text.replace(old, new)
                b["lines"] = text.split("\n")
            else:
                b["lines"] = list(fix)
            fixed += 1
    for b in blocks:
        b["lines"] = [re.sub(r"\b([A-Z]\w+) \(\$[0-9a-fA-F]{4}\)", at, line) for line in b["lines"]]

    # where the source build defines each routine
    by_addr = {}
    for b in blocks:
        if b.get("at") != "section":
            by_addr.setdefault((b["bank"], int(b["addr"], 16)), b)
    sourced = 0
    for inc in sorted((ROOT / "kernel/stock" / BUILD[ver]).glob("*.inc")):
        m = re.match(r"(?:ff_)?b(\d)_|crt0_", inc.name)
        if not m:
            continue
        bank = int(m.group(1) or 0)
        text = inc.read_text().splitlines()
        srcs = [re.sub(r"^build-\w+/font\.s$", "gbdk/font.ms", x)
                for x in re.match(r"; Generated from (.*) by ", text[0]).group(1).split()]
        addr = int(re.match(r"; \$([0-9a-f]+)-", text[1]).group(1), 16)
        for line in text[2:]:
            if line.startswith("    db "):
                addr += line.count("$")
                continue
            label = line.rstrip(":")
            if names.get((bank, addr)) != label or re.search(r"_[a-z]", label):
                continue                         # routines, not the names inside them
            found = srcs
            if len(srcs) > 1:
                hit = [x for x in srcs if re.search(rf"\b_?{re.escape(label)}\b",
                                                    (ROOT / "kernel/stock" / x).read_text(errors="replace"))]
                found = hit if len(hit) == 1 else srcs
            where = "Source: " + ", ".join(f"kernel/stock/{x}" for x in found)
            b = by_addr.get((bank, addr))
            if b is None:
                b = {"bank": bank, "addr": f"{addr:04x}", "lines": []}
                by_addr[(bank, addr)] = b
                blocks.append(b)
            if where not in b["lines"]:
                b["lines"].insert(0, where)
                sourced += 1

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
    # The notes were written against 1.05e-0731 and carried to the other
    # kernels, so a reference mgbdis does not define here is a 0731 address:
    # find it there as a name plus an offset and bring that across.
    dis = work / "disassembly"
    defs = set(re.findall(r"^([A-Za-z_]\w*)::?\s*$", "".join(f.read_text() for f in dis.glob("bank_*.asm")), re.M))
    ref = {}
    for raw in (ROOT / "kernel/1.05e-0731/kernel.sym").read_text(encoding="utf-8").splitlines():
        f = raw.split(";", 1)[0].split()
        if len(f) >= 2 and ":" in f[0] and not f[1].startswith("."):
            bank, addr = (int(x, 16) for x in f[0].split(":"))
            if addr < 0x8000 and renamed(f[1]) in addr_of:
                ref.setdefault(bank, []).append((addr, renamed(f[1])))
    for v in ref.values():
        v.sort()
    stale = 0

    def carried(m):
        nonlocal stale
        bank, addr = int(m.group(2), 16), int(m.group(3), 16)
        below = [x for x in ref.get(bank, []) if x[0] <= addr]
        if below:
            here = addr_of[below[-1][1]] + addr - below[-1][0]
            new = names.get((bank, here), f"{m.group(1)}_{bank:03x}_{here:04x}")
            if new in defs:
                return new
        native = names.get((bank, addr), m.group(0))
        if native in defs:
            return native
        stale += 1
        return m.group(0)

    for b in blocks:
        b["lines"] = [re.sub(r"\b(Jump|jr|Call)_([0-9a-f]{3})_([0-9a-f]{4})\b", carried, line) for line in b["lines"]]
    (work / "notes.json").write_text(json.dumps({"blocks": blocks}, indent=1, ensure_ascii=False) + "\n")
    r = run([sys.executable, ROOT / "kernel/tools/annotate-disasm.py", str(work.relative_to(ROOT))], ok=(0, 1))
    orphans = [l for l in (r.stdout + r.stderr).splitlines() if "orphan" in l.lower() or "not found" in l.lower()]
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
        shutil.copy(work / "kernel.sym", out / "kernel.sym")
        shutil.copy(work / "notes.json", out / "notes.json")
    lines = sum(len(f.read_text().splitlines()) for f in dis.glob("bank_*.asm"))
    print(f"{ver}: {len(keep)} sym lines kept, {len(dropped)} dropped; "
          f"{nkept} of {len(notes['blocks'])} notes kept; {lines} lines; "
          f"{'assembles to stock' if same else 'DOES NOT assemble to stock'}")
    print(f"  {len(patched)} names or blocks on stock code the mod changed, "
          f"{len(modnotes)} notes mention the mod, {len(orphans)} notes not placed, "
          f"{sourced} routines given their source file, {fixed} notes corrected, {stale} references to labels not in the listing")
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
