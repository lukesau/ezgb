#!/usr/bin/env python3
"""Port the modded kernel from one stock firmware build to another.

The mod is defined by re/<from>/kernel.gb (modded) against
re/<from>/kernel.gb.orig (stock) plus re/<from>/kernel.sym, which names every
injected block. This tool rebuilds the same mod on top of re/<to>/kernel.gb.orig:

* C blocks (REGISTRY entries with `src`) are recompiled with SDCC at the same
  address, with every --pin address translated through scripts/portmap.py.
* Hand-assembled blocks (shims, hooks) are decoded and every absolute ROM
  operand, including the 4-byte target after `call FarCallTrampoline`, is
  translated the same way. Blocks tagged `data` are copied verbatim; `code_len`
  splits a block into a relocated code head and a verbatim data tail.
* Hook sites (every other byte that differs between stock and modded) are
  translated instruction by instruction. Before writing, the tool proves the
  target kernel has the same stock instructions at the translated site (same
  bytes after translating the operands the same way); a mismatch aborts.

Nothing here is inferred from documentation: the source of truth is the bytes
of the from-version build. Run with --check against a version that already has
a modded kernel.gb to confirm the port reproduces it byte for byte (the 0731
-> 0918 port is the regression test for the tool).

Usage:
    scripts/port-mod.py <from_ver> <to_ver> [--apply] [--check] [--sym] [-v]

    scripts/port-mod.py 1.05e-0731 1.05e-0918 --check   # must report 0 diffs
    scripts/port-mod.py 1.05e-0731 1.04e --apply --sym   # write kernel.gb, kernel.sym, notes.json
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts"))
sys.path.insert(0, os.path.join(ROOT, "decomp", "tools"))
from portmap import PortMap, ABS16, FARCALL, decode, insn_len, tokens, load_stock  # noqa: E402
from sdcc_build import compile_c, parse_ihx  # noqa: E402

BANK = 0x4000
SRC = os.path.join(ROOT, "decomp", "src")

# ---------------------------------------------------------------------------
# What each injected block is. Keyed by (bank, addr) in the FROM build; the
# block length comes from that build's kernel.sym `.data` entry. Pins are the
# FROM-build addresses the C source was linked against (docs/*.md,
# scripts/inject-ezcfg.sh); the port translates them.
#   src       C file under decomp/src, recompiled per version
#   pins      {symbol: from_addr}; bank-0 addresses unless `bank` says otherwise
#   kind      'asm' (default: relocate operands), 'data' (verbatim)
#   code_len  first N bytes are code, the rest data (copied verbatim)
# ---------------------------------------------------------------------------
FATFS = {"FarCall_06_7309": 0x1926, "FarCall_06_779a": 0x1941,
         "FarCall_07_7739": 0x1963, "FarCall_03_768f": 0x19a1, "WaitVBlankFlag": 0x0688}
REGISTRY = {
    (0, 0x01e3): dict(src="browser_scroll.c", pins={"DirList": 0x0a43}),
    (0, 0x02fb): dict(src="browser_page_end.c", pins={}),
    (0, 0x0420): dict(src="fastlaunch_do_launch.c",
                      pins={"FarCallTrampoline": 0x078d, "Strrchr": 0x2c42, "LastRomRelaunch": 0x1344}),
    (0, 0x0460): dict(src="fastlaunch_hook.c",
                      pins={"ReadJoypad": 0x3a4a, "FarCallScan": 0x0400, "fastlaunch_do_launch": 0x0420}),
    (0, 0x0490): dict(src="fastlaunch_boot.c",
                      pins={"FarCallScan": 0x0400, "fastlaunch_do_launch": 0x0420,
                            "BrowserSortAllStub": 0x03d4, "ReadJoypad": 0x3a4a}),
    (0, 0x3d8c): dict(src="browser_scroll_repaint.c",
                      pins={"browser_scroll_down": 0x01e3, "FarCallDrawDetailBottom": 0x03dc,
                            "DrawString": 0x08b7, "StoreDrawParams": 0x2791, "DrawNameWithIcon": 0x3ec8}),
    (0, 0x3ec8): dict(src="browser_icons.c", pins={"DrawString": 0x08b7}),
    (2, 0x4500): dict(src="fastlaunch.c",
                      pins={"FarCallOpendir_B5": 0x4380, "FarCallReaddir_B5": 0x4396,
                            "FarCallSetPage": 0x43ac, "ezcfg": 0x4a00}),
    (2, 0x4a00): dict(src="ezcfg.c", pins={**FATFS, "DrawString": 0x08b7, "ReadJoypad": 0x3a4a}),
    (4, 0x5990): dict(src="flcfg.c",
                      pins={"FarCallEzCfg": 0x5f00, "SetFpgaPage_B4": 0x466e, "DrawString": 0x08b7,
                            "DrawRect": 0x27ba, "StoreDrawParams": 0x2791, "ReadJoypad": 0x3a4a}),
    (8, 0x746b): dict(src="browser_sort.c", pins={"DirList": 0x0a43}),
    (8, 0x7b8d): dict(src="flpick_banner.c", pins={"DrawString": 0x08b7, "StoreDrawParams": 0x2791}),
    (8, 0x7c00): dict(src="browser_hide.c", pins={}),
    # hand-assembled, with data tails
    (8, 0x7a9c): dict(code_len=0x5b),      # DrawHelpModVersion: code, then 4 strings
    (0, 0x3806): dict(kind="data"),        # FolderIconGlyphs: font tiles
}

# The 11-byte kernel-version text DrawHelpModVersion draws over the stock
# "K1.05e" (docs/help-version.md); the one string in the mod that names the base.
VERSION_TEXT = {
    "1.05e-0731": b"K1.05e-0731",
    "1.05e-0918": b"K1.05e-0918",
    "1.04e": b"K1.04e     ",
}

# Addresses portmap cannot align because the target build's instructions differ
# there, resolved by reading both disassemblies. (bank, from_addr) -> to_addr.
OVERRIDES = {
    "1.04e": {
        # DrawTimeAutosaveScreen_redraw: same entry address; 1.04e opens the
        # loop with `call WaitVBlankFlag` where 1.05e tests its time-set flag.
        (4, 0x48f5): 0x48f5,
    },
}

# Hook sites that patch code the target build does not have. (bank, from_addr)
# of the site as reported by the tool; each needs a reason.
SKIP_SITES = {
    "1.04e": {
        # DrawTimeAutosaveScreen_savRedraw: 1.05e draws one extra string here
        # (StoreDrawParams + DrawString at $592a); the mod retunes that call's
        # ink for DMG. 1.04e has no such draw, so there is nothing to retune.
        (4, 0x4e49),
    },
}

# Free WRAM the mod uses ($D780-$DBFF scratch, flags at $DBFB-$DBFF) is
# unreferenced in every build; nothing to translate. The kernel's own WRAM
# names in kernel.sym are ported by this rule: 1.05e inserted its RTC day
# tables at $D6A7, so every runtime global from $D6CC up sits 39 bytes lower
# in 1.04e (docs/PROGRESS.md: $D6CE/$D6D1 -> $D6A7/$D6AA, $D6CC/$D6CD ->
# $D6A5/$D6A6); names inside the inserted range have no 1.04e equivalent.
WRAM_SHIFT = {"1.04e": dict(keep_below=0xd6a7, shift_from=0xd6cc, delta=-0x27)}


def md5(b):
    return hashlib.md5(b).hexdigest()


def off(bank, addr):
    return bank * BANK + (addr if bank == 0 else addr - 0x4000)


def cpu(bank, o):
    o -= bank * BANK
    return o if bank == 0 else o + 0x4000


def read_sym_blocks(sym_path):
    """[(bank, addr, length, name)] for every `.data` entry in kernel.sym."""
    names, blocks = {}, []
    for line in open(sym_path, encoding="utf-8"):
        m = re.match(r"^([0-9a-f]{2}):([0-9a-f]{4}) (\S+)", line)
        if not m:
            continue
        bank, addr, tok = int(m.group(1), 16), int(m.group(2), 16), m.group(3)
        if tok.startswith(".data:"):
            length = int(tok.split(":")[1], 16)
            blocks.append((bank, addr, length, names.get((bank, addr), "?")))
        else:
            names[(bank, addr)] = tok
    return blocks


class Port:
    def __init__(self, src_ver, dst_ver, verbose=False):
        self.src_ver, self.dst_ver, self.verbose = src_ver, dst_ver, verbose
        self.src_stock = load_stock(src_ver)
        self.src_mod = open(os.path.join(ROOT, "re", src_ver, "kernel.gb"), "rb").read()
        self.dst_stock = load_stock(dst_ver)
        self.dst = bytearray(self.dst_stock)
        cache = os.path.join(tempfile.gettempdir(), "ezgb-portmap")
        self.pm = PortMap(self.src_stock, self.dst_stock, cache_dir=cache)
        self.overrides = OVERRIDES.get(dst_ver, {})
        self.log = []
        self.written = []  # (bank, addr, length, what)
        self.sym_blocks = read_sym_blocks(os.path.join(ROOT, "re", src_ver, "kernel.sym"))
        self.labels = set()
        for line in open(os.path.join(ROOT, "re", src_ver, "kernel.sym"), encoding="utf-8"):
            m = re.match(r"^([0-9a-f]{2}):([0-9a-f]{4}) (?!\.data)\S", line)
            if m:
                self.labels.add((int(m.group(1), 16), int(m.group(2), 16)))
        self._starts = {}

    # -- address translation ------------------------------------------------
    def free(self, rom, bank, addr, n=1):
        o = off(bank, addr)
        return all(b == 0xff for b in rom[o:o + n])

    def xlat(self, bank, addr, what=""):
        """Translate a ROM address of the from-build to the to-build."""
        if (bank, addr) in self.overrides:
            return self.overrides[(bank, addr)]
        b = 0 if addr < 0x4000 else bank
        if b != 0 and not 0x4000 <= addr <= 0x7fff:
            return addr
        r = self.xlat_soft(b, addr)
        if r is None:
            raise SystemExit(f"error: {b:02x}:{addr:04x} ({what}) has no equivalent in {self.dst_ver}")
        return r

    def injected(self, bank, addr):
        """True when addr is inside an injected block: filler in both stock
        builds, code in the from-build mod. Such addresses never move."""
        return (self.free(self.src_stock, bank, addr) and self.free(self.dst_stock, bank, addr)
                and not self.free(self.src_mod, bank, addr))

    def xlat_soft(self, bank, addr):
        if (bank, addr) in self.overrides:
            return self.overrides[(bank, addr)]
        if self.injected(bank, addr):
            return addr
        return self.pm.map(bank, addr)

    def relocate(self, bank, addr, data, what):
        """Translate every absolute ROM operand in a code byte string."""
        out = bytearray(data)
        for i, n in decode(data):
            op = data[i]
            if n == 7:  # call FarCallTrampoline + (lo, hi, bank, 0)
                tb = data[i + 5]
                t = data[i + 3] | data[i + 4] << 8
                if not what.endswith("stock"):
                    self.verify_target(tb, t, f"{what}+{i:02x} far-call")
                r = self.xlat(tb, t, f"{what}+{i:02x} far-call")
                out[i + 3], out[i + 4] = r & 0xff, r >> 8
                if r != t:
                    self.log.append(f"  {what}+{i:02x}: far-call {tb:02x}:{t:04x} -> {r:04x}")
            elif n == 3 and op in ABS16:
                t = data[i + 1] | data[i + 2] << 8
                if t < 0x0100 or t >= 0x8000:
                    continue  # small constant / RAM / register
                if bank == 0 and t >= 0x4000:
                    continue  # bank-0 code naming a ROMX-window register ($4000, $7Fxx)
                if op in (0x01, 0x11, 0x21, 0x31, 0x08):
                    # ld rr,nn: a pointer only when nn names something (a
                    # kernel.sym label or injected code); otherwise a constant
                    # such as a (row<<8|col) screen position.
                    b = 0 if t < 0x4000 else bank
                    if (b, t) not in self.labels and not self.injected(b, t):
                        if self.verbose and self.pm.map(b, t) not in (None, t):
                            self.log.append(f"  {what}+{i:02x}: {op:02x} {t:04x} kept as a constant")
                        continue
                if op in (0xC3, 0xCD) and not what.endswith("stock"):
                    self.verify_target(0 if t < 0x4000 else bank, t, f"{what}+{i:02x} op {op:02x}")
                r = self.xlat(bank, t, f"{what}+{i:02x} op {op:02x}")
                out[i + 1], out[i + 2] = r & 0xff, r >> 8
                if r != t:
                    self.log.append(f"  {what}+{i:02x}: {op:02x} {t:04x} -> {r:04x}")
        return bytes(out)

    # -- instruction boundaries of the from-build stock code -------------------
    def starts(self, bank):
        if bank not in self._starts:
            _, s = tokens(self.src_stock[bank * BANK:(bank + 1) * BANK])
            self._starts[bank] = sorted(s)
        return self._starts[bank]

    def boundaries(self, data, start, limit):
        b = {start}
        i = start
        while i < limit:
            i += next(decode(data, i))[1]
            b.add(i)
        return b

    # -- blocks -------------------------------------------------------------------
    def verify_target(self, bank, addr, what, n=12):
        """A translated code address must start with the same instructions."""
        if self.injected(bank, addr) or (bank, addr) in self.overrides:
            return  # overrides are resolved by hand precisely because the code differs
        t = self.xlat(bank, addr, what)
        want = self.relocate(bank, addr, self.src_stock[off(bank, addr):off(bank, addr) + n], what)
        have = self.dst_stock[off(bank, t):off(bank, t) + n]
        if not self.code_equiv(bank, want, have):
            raise SystemExit(f"error: {what}: {bank:02x}:{addr:04x} -> {t:04x} but the code there differs\n"
                             f"  from {want.hex()}\n  to   {have.hex()}")

    def code_equiv(self, bank, a, b):
        """Same instructions; a 16-bit operand may differ when it is RAM (the
        kernel's own WRAM globals move between builds) or when it is a ROM
        address whose translation is the other side's value (an unlabelled
        pointer that relocate() left alone)."""
        if len(a) != len(b):
            return False
        for i, _ in decode(a):
            n = insn_len(a, i)
            if i + n > len(a):
                break  # the window ends mid-instruction; ignore the partial one
            if a[i] != b[i]:
                return False
            if n == 3 and a[i] in ABS16:
                ta, tb = a[i + 1] | a[i + 2] << 8, b[i + 1] | b[i + 2] << 8
                if ta == tb or (ta >= 0x8000 and tb >= 0x8000):
                    continue
                if ta < 0x8000 and self.xlat_soft(0 if ta < 0x4000 else bank, ta) == tb:
                    continue
                return False
            if a[i + 1:i + n] != b[i + 1:i + n]:
                return False
        return True

    def compile_block(self, bank, addr, length, name, spec):
        c_path = os.path.join(SRC, spec["src"])
        pins = []
        for sym, a in spec.get("pins", {}).items():
            pb = 0 if a < 0x4000 else bank
            self.verify_target(pb, a, f"{name} pin {sym}")
            pins.append((sym if sym.startswith("_") else "_" + sym, self.xlat(pb, a, f"pin {sym}")))
        with tempfile.TemporaryDirectory() as wd:
            ihx, _ = compile_c(c_path, wd, pins=pins, code_origin=addr)
            compiled = parse_ihx(ihx)
        out = bytearray()
        a = addr
        while a in compiled:
            out.append(compiled[a])
            a += 1
        if len(out) != length:
            raise SystemExit(f"error: {name}: compiled {len(out)} bytes, kernel.sym says {length}")
        return bytes(out)

    def port_blocks(self):
        for bank, addr, length, name in self.sym_blocks:
            src_bytes = self.src_mod[off(bank, addr):off(bank, addr) + length]
            if not self.free(self.src_stock, bank, addr, length):
                continue  # a labelled hook site; handled with the other sites
            if not self.free(self.dst_stock, bank, addr, length):
                raise SystemExit(f"error: {name} at {bank:02x}:{addr:04x} is not free in {self.dst_ver}")
            spec = REGISTRY.get((bank, addr), {})
            what = f"{name}@{bank:02x}:{addr:04x}"
            if "src" in spec:
                out = self.compile_block(bank, addr, length, name, spec)
                how = "recompiled " + spec["src"]
            elif spec.get("kind") == "data":
                out = src_bytes
                how = "data, verbatim"
            else:
                cl = spec.get("code_len", length)
                out = self.relocate(bank, addr, src_bytes[:cl], what) + src_bytes[cl:]
                how = "relocated" + (f" (code {cl}, data {length - cl})" if cl != length else "")
                if (bank, addr) not in REGISTRY and self.verbose:
                    self.log.append(f"  note: {what} not in REGISTRY, treated as code")
            if bank == 8 and addr == 0x7a9c:
                vs, vd = VERSION_TEXT[self.src_ver], VERSION_TEXT[self.dst_ver]
                if vs not in out:
                    raise SystemExit(f"error: DrawHelpModVersion has no {vs!r} text")
                out = out.replace(vs, vd)
            self.dst[off(bank, addr):off(bank, addr) + length] = out
            self.written.append((bank, addr, length, name))
            if self.verbose:
                self.log.append(f"block {what} {length}B: {how}")

    # -- hook sites -----------------------------------------------------------
    def diff_regions(self, gap=8):
        a, b = self.src_stock, self.src_mod
        regions, i, n = [], 0, len(a)
        while i < n:
            if a[i] != b[i]:
                j = i
                while j < n and (a[j] != b[j] or any(a[k] != b[k] for k in range(j, min(n, j + gap)))):
                    j += 1
                regions.append((i, j))
                i = j
            else:
                i += 1
        return regions

    def port_sites(self):
        covered = sorted((off(b, a), off(b, a) + n) for b, a, n, _ in self.written)
        todo = []
        for r0, r1 in self.diff_regions():
            # subtract the injected blocks already written; what is left is a hook site
            cur = r0
            for c0, c1 in covered:
                if c1 <= cur or c0 >= r1:
                    continue
                if c0 > cur:
                    todo.append((cur, c0))
                cur = max(cur, c1)
            if cur < r1:
                todo.append((cur, r1))
        skip = SKIP_SITES.get(self.dst_ver, set())
        for r0, r1 in todo:
            bank = r0 // BANK
            if all(b == 0xff for b in self.src_mod[r0:r1]):
                continue  # filler between two blocks, swept up by the diff gap-join
            if all(b == 0xff for b in self.src_stock[r0:r1]):
                self.log.append(f"warning: {bank:02x}:{cpu(bank, r0):04x} {r1 - r0}B of stale bytes in free "
                                f"space, not in kernel.sym: skipped (blank them in {self.src_ver})")
                continue
            base = bank * BANK
            starts = self.starts(bank)
            # widen to instruction boundaries shared by stock and modded streams
            s = max(x for x in starts if x <= r0 - base) + base
            e = r1
            for _ in range(64):
                bs = self.boundaries(self.src_stock, s, e)
                bm = self.boundaries(self.src_mod, s, e)
                common = sorted(x for x in bs & bm if x >= r1)
                if common:
                    e = common[0]
                    break
                e += 1
            else:
                raise SystemExit(f"error: no common instruction boundary after {bank:02x}:{cpu(bank, r0):04x}")
            addr = cpu(bank, s)
            what = f"site {bank:02x}:{addr:04x}"
            if (bank, addr) in skip:
                self.log.append(f"skipped {what}: not present in {self.dst_ver} (SKIP_SITES)")
                continue
            stock = self.src_stock[s:e]
            mod = self.src_mod[s:e]
            spec = REGISTRY.get((bank, addr), {})
            t = self.xlat(bank, addr, what)
            t_end = self.xlat(bank, cpu(bank, e - 1), what + " end")
            if t_end - t != e - 1 - s:
                raise SystemExit(f"error: {what}: span straddles a code insertion in {self.dst_ver}")
            to = off(bank, t)
            if spec.get("kind") == "data":
                if self.dst_stock[to:to + len(stock)] != stock:
                    raise SystemExit(f"error: {what}: data differs in {self.dst_ver} at {bank:02x}:{t:04x}")
                new = mod
            else:
                want = self.relocate(bank, addr, stock, what + " stock")
                have = self.dst_stock[to:to + len(stock)]
                if want != have:
                    raise SystemExit(
                        f"error: {what}: {self.dst_ver} stock code differs at {bank:02x}:{t:04x}\n"
                        f"  from-stock  {stock.hex()}\n  translated  {want.hex()}\n  to-stock    {have.hex()}")
                new = self.relocate(bank, addr, mod, what)
            self.dst[to:to + len(new)] = new
            self.written.append((bank, t, len(new), f"site<-{addr:04x}"))
            if self.verbose:
                self.log.append(f"{what} -> {bank:02x}:{t:04x} ({t - addr:+d}) {len(new)}B: "
                                f"{stock.hex()} -> {new.hex()}")

    def run(self):
        self.port_blocks()
        self.port_sites()
        return bytes(self.dst)

    # -- kernel.sym / notes.json -------------------------------------------------
    def port_sym(self):
        src = os.path.join(ROOT, "re", self.src_ver, "kernel.sym")
        wram = WRAM_SHIFT.get(self.dst_ver)
        out, dropped = [], []
        for line in open(src, encoding="utf-8").read().splitlines():
            m = re.match(r"^([0-9a-f]{2}):([0-9a-f]{4}) (.*)$", line)
            if not m:
                out.append(line)
                continue
            bank, addr, rest = int(m.group(1), 16), int(m.group(2), 16), m.group(3)
            if addr >= 0x8000:  # WRAM/HRAM names
                if wram is None or addr < wram["keep_below"] or addr >= 0xe000:
                    out.append(line)
                elif addr >= wram["shift_from"]:
                    out.append(f"{bank:02x}:{addr + wram['delta']:04x} {rest}")
                else:
                    dropped.append(line)
                continue
            r = self.xlat_soft(0 if addr < 0x4000 else bank, addr)
            if r is None:
                dropped.append(line)
                continue
            out.append(f"{bank:02x}:{r:04x} {rest}")
        return "\n".join(out) + "\n", dropped

    def port_notes(self):
        src = os.path.join(ROOT, "re", self.src_ver, "notes.json")
        notes = json.load(open(src))
        kept, dropped = [], 0
        for blk in notes["blocks"]:
            bank, addr = blk["bank"], int(blk["addr"], 16)
            r = self.xlat_soft(0 if addr < 0x4000 else bank, addr)
            if r is None:
                dropped += 1
                continue
            nb = dict(blk)
            nb["addr"] = f"{r:04x}"
            kept.append(nb)
        return {"blocks": kept}, dropped


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src_ver")
    ap.add_argument("dst_ver")
    ap.add_argument("--apply", action="store_true", help="write re/<to>/kernel.gb (backing up stock to .orig)")
    ap.add_argument("--check", action="store_true", help="compare against the existing re/<to>/kernel.gb")
    ap.add_argument("--sym", action="store_true", help="with --apply: also write kernel.sym and notes.json")
    ap.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args()

    p = Port(args.src_ver, args.dst_ver, verbose=args.verbose)
    result = p.run()
    for line in p.log:
        print(line)
    nblk = sum(1 for w in p.written if not w[3].startswith("site<-"))
    nsite = len(p.written) - nblk
    print(f"{args.src_ver} -> {args.dst_ver}: {nblk} blocks, {nsite} hook sites, "
          f"{sum(w[2] for w in p.written)} bytes; result md5 {md5(result)}")

    if args.check:
        existing_path = os.path.join(ROOT, "re", args.dst_ver, "kernel.gb")
        existing = open(existing_path, "rb").read()
        diffs = [i for i in range(len(result)) if result[i] != existing[i]]
        if not diffs:
            print(f"check: identical to {existing_path}")
        else:
            print(f"check: {len(diffs)} bytes differ from {existing_path}:")
            i = 0
            while i < len(diffs):
                j = i
                while j + 1 < len(diffs) and diffs[j + 1] - diffs[j] <= 8:
                    j += 1
                a, b = diffs[i], diffs[j] + 1
                bank = a // BANK
                print(f"  {bank:02x}:{cpu(bank, a):04x} {b - a}B  ported {result[a:b].hex()[:64]}  "
                      f"existing {existing[a:b].hex()[:64]}")
                i = j + 1

    if args.apply:
        gb = os.path.join(ROOT, "re", args.dst_ver, "kernel.gb")
        orig = gb + ".orig"
        if not os.path.isfile(orig):
            cur = open(gb, "rb").read()
            if cur != p.dst_stock:
                raise SystemExit(f"error: {gb} is not the stock dump and {orig} is missing")
            shutil.copy2(gb, orig)
            print(f"backed up stock dump to {orig}")
        open(gb, "wb").write(result)
        print(f"wrote {gb}")
        if args.sym:
            text, dropped = p.port_sym()
            open(os.path.join(ROOT, "re", args.dst_ver, "kernel.sym"), "w", encoding="utf-8").write(text)
            print(f"wrote kernel.sym ({len(dropped)} entries dropped: no equivalent in {args.dst_ver})")
            for d in dropped[:40]:
                print("   ", d)
            notes, nd = p.port_notes()
            with open(os.path.join(ROOT, "re", args.dst_ver, "notes.json"), "w") as f:
                json.dump(notes, f, indent=2, ensure_ascii=False)
                f.write("\n")
            print(f"wrote notes.json ({nd} blocks dropped)")


if __name__ == "__main__":
    main()
