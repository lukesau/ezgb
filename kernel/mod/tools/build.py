#!/usr/bin/env python3
"""Build the mod kernel: compile every source in manifest.py, link them all
in one sdldgb link, and write the ROM.

  tools/build.py [-o build]      (run from kernel/mod)

Outputs build/kernel.gb, build/kernel.sym (bank:addr name) and
build/kernel.map (sdld's map).

Sources under base/ are compiled with SDCC 2.9.0 ($SDCC29/bin/sdcc), the
rest with the current sdcc; both are assembled and linked with the current
sdasgb and sdldgb.

Banks. A source's code goes in the bank of its group: its _CODE area is
renamed _CODE_<bank> in the object and that area is placed at
<bank>:$4000 (bank 0's follows crt0's). sdldgb takes an address above $FFFF as bank and address, and
writes it at that bank's place in the ROM.

Names. A name defined in several groups (FatFs is compiled five times)
means, inside a group that defines it, that group's own. names.txt gives
the names sources use that no source defines: another name for a symbol
(`ReadJoypad = _joypad`) or an address (`_wSaveBuf = 0xc0a0`).

Calls between banks. SDCC 2.9.0 leaves the bank word after a banked call
empty; it is filled with the bank of the function called. The current SDCC
loads b_NAME, which is defined here as that bank.
"""
import argparse
import concurrent.futures
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
import manifest  # noqa: E402


def run(cmd, cwd=None, ok=False):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, stdin=subprocess.DEVNULL)
    if r.returncode != 0 and not ok:
        sys.exit(f"error: {' '.join(cmd)}\n{r.stdout}{r.stderr}")
    return r


def is_base(src):
    return src.startswith("base/")


class Obj:
    def __init__(self, g, src, out):
        self.g, self.src = g, src
        stem = g["name"] + "__" + os.path.basename(src).rsplit(".", 1)[0]
        self.asm = os.path.join(out, "obj", stem + ".asm")
        self.rel = os.path.join(out, "obj", stem + ".rel")
        self.old = src.endswith(".c") and is_base(src)


def absflags(flags):
    return [("-I" + os.path.join(ROOT, f[2:])) if f.startswith("-I") else f for f in flags.split()]


def compile_c(o, version):
    g = o.g
    if o.old:
        sdcc = os.path.join(os.environ["SDCC29"], "bin", "sdcc")
        run([sdcc, "-S", "-mgbz80", "--no-std-crt0", *absflags(g["cflags"]), *version,
             os.path.join(ROOT, o.src), "-o", o.asm])
    else:
        r = run(["sdcc", "-S", "-msm83", "--sdcccall", "0", "--no-std-crt0",
                 os.path.join(ROOT, o.src), "-o", o.asm])
        for w in r.stderr.splitlines():
            if "warning" in w and "warning 296" not in w:
                print(f"  (sdcc) {w}")
        # SDCC defines b_NAME, the bank of a __banked function, as 0 where
        # the function is: it is the bank of this group
        text = re.sub(r"^(\s*b_\w+\s*=\s*)0\s*$", lambda m: f"{m[1]}{g['bank']}",
                      open(o.asm).read(), flags=re.M)
        open(o.asm, "w").write(text)


def assemble(o, out):
    if o.src.endswith(".c"):
        run(["sdasgb", "-plosgff", o.rel, o.asm])
        if not o.old:
            # linked beside SDCC 2.9.0's objects: drop the compiler-options
            # record, and keep this compiler's empty areas apart from
            # 2.9.0's of the same name, whose flags differ
            text = open(o.rel).read()
            text = re.sub(r"^O .*\n", "", text, flags=re.M)
            text = re.sub(r"^A (\S+) size 0 flags", r"A \1_m size 0 flags", text, flags=re.M)
            open(o.rel, "w").write(text)
    else:
        src = os.path.join(ROOT, o.src)
        incs = ["-I" + os.path.dirname(src), "-I" + os.path.join(ROOT, "base/gbdk"), "-I" + out]
        run(["sdasgb", "-plosgff", *incs, o.rel, src])


def rel_syms(path):
    refs, defs = set(), set()
    for line in open(path):
        m = re.match(r"S\s+(\S+)\s+(Ref|Def)", line)
        if m:
            (refs if m[2] == "Ref" else defs).add(m[1])
    return refs, defs


def rel_areas(path):
    return {m[1]: (int(m[2], 16), int(m[3], 16)) for m in
            re.finditer(r"^A (\S+) size (\w+) flags (\w+)", open(path).read(), flags=re.M)}


def parse_ihx(path, size):
    rom = bytearray(b"\xff" * size)
    extra = {}
    hi = 0
    for line in open(path):
        line = line.strip()
        if not line.startswith(":"):
            continue
        n, addr, typ = int(line[1:3], 16), int(line[3:7], 16), int(line[7:9], 16)
        data = bytes.fromhex(line[9:9 + 2 * n])
        if typ == 4:
            hi = int.from_bytes(data, "big") << 16
        elif typ == 0:
            for i, b in enumerate(data):
                a = hi + addr + i
                if a < size:
                    rom[a] = b
                else:
                    extra[a] = b
    return rom, extra


def parse_map(path):
    syms = {}
    for line in open(path):
        m = re.match(r"\s+([0-9A-F]{8})\s+(\S+)", line)
        if m:
            syms[m[2]] = int(m[1], 16)
    return syms


def load_names(path):
    names = {}
    for line in open(path):
        line = line.split("#")[0].strip()
        if line:
            n, v = (x.strip() for x in line.split("="))
            names[n] = v
    return names


def main():
    p = argparse.ArgumentParser()
    p.add_argument("-o", default="build")
    p.add_argument("--unresolved", help="write the names nothing defines here and stop")
    a = p.parse_args()
    os.chdir(ROOT)
    os.environ.setdefault("SDCC29", os.path.abspath("../../tools/sdcc-2.9.0"))
    out = os.path.abspath(a.o)
    os.makedirs(os.path.join(out, "obj"), exist_ok=True)

    # generated sources: GBDK's font module from its macro file, the 12px glyph sets
    run([sys.executable, "tools/maccer.py", "base/gbdk/font.ms", os.path.join(out, "font.s")])
    pack = [sys.executable, "../tools/font12-pack.py"]
    run(pack + ["-i", "font12/font12.txt", "-o", f"{out}/font12.bin", "-m", f"{out}/font12-metrics.bin"])
    run(pack + ["-i", "font12/font12_dv.txt", "--mono", "6", "-o", f"{out}/font12_dv.bin",
                "-m", f"{out}/font12_dv-metrics.bin"])
    ver = open("../../patches/kernel/VERSION").read().strip().split(".")
    version = [f"-DMOD_MAJOR={ver[0]}", f"-DMOD_MINOR={ver[1]}"]

    objs = []
    for g in manifest.GROUPS:
        for src in g["srcs"]:
            if src.startswith("build/"):
                src = os.path.relpath(os.path.join(out, src[6:]), ROOT)
            objs.append(Obj(g, src, out))
    stems = [o.rel for o in objs]
    assert len(set(stems)) == len(stems), "two sources of a group share a name"

    def first(o):
        if o.src.endswith(".c"):
            compile_c(o, version)
        assemble(o, out)
    with concurrent.futures.ThreadPoolExecutor(os.cpu_count()) as ex:
        list(ex.map(first, objs))

    # --- names -----------------------------------------------------------
    gdefs = {}                                  # group -> its definitions
    for o in objs:
        o.refs, o.defs = rel_syms(o.rel)
        gdefs.setdefault(o.g["name"], set()).update(o.defs)
    where = {}                                  # name -> groups defining it
    for gn, ds in gdefs.items():
        for d in ds:
            where.setdefault(d, []).append(gn)
    bank_of = {g["name"]: g["bank"] for g in manifest.GROUPS}
    names = load_names("names.txt")
    absolute = {}                               # name -> address, for the link
    missing = set()

    def local(sym, gn):
        return f"{sym}__{gn}"

    def resolve(sym, gn, depth=0):
        """(name to link against, bank or None) for sym used in group gn"""
        if sym in where:
            gs = where[sym]
            if len(gs) == 1:
                return sym, bank_of[gs[0]]
            if gn in gs:
                return local(sym, gn), bank_of[gn]
            if sym in manifest.PREFER:
                return local(sym, manifest.PREFER[sym]), bank_of[manifest.PREFER[sym]]
            missing.add(f"{sym} ({gn}): in {' '.join(gs)}, add to PREFER")
            return None, None
        if sym in names and depth < 4:
            v = names[sym]
            if re.match(r"(0x[0-9a-fA-F]+|\d+)$", v):
                absolute[sym] = int(v, 0)
                return sym, None
            return resolve(v, gn, depth + 1)
        if sym.startswith("b_"):
            fn, bank = resolve("_" + sym[2:], gn, depth)
            if fn is None or bank is None:
                missing.add(f"{sym} ({gn})")
                return None, None
            new = "b_" + fn[1:]
            absolute[new] = bank
            return new, None
        missing.add(f"{sym} ({gn})")
        return None, None

    for o in objs:
        gn = o.g["name"]
        o.rename = {}
        for d in o.defs:
            if len(where[d]) > 1:
                o.rename[d] = local(d, gn)
        o.banks = {}
        for r in o.refs - o.defs:
            if where.get(r) == [manifest.RAM_CODE["group"]]:
                # the RAM routine, named from outside: its copy in the ROM
                o.rename[r] = r + "__rom"
                absolute[r + "__rom"] = manifest.RAM_CODE["at"]
                o.banks[r] = manifest.RAM_CODE["bank"]
                continue
            new, bank = resolve(r, gn)
            if new and new != r:
                o.rename[r] = new
            o.banks[r] = bank
    if a.unresolved:
        open(a.unresolved, "w").write("\n".join(sorted(missing)) + "\n")
        print(f"{len(missing)} unresolved names -> {a.unresolved}")
        return
    if missing:
        sys.exit("error: nothing defines (add to names.txt): " + " ".join(sorted(missing)))

    # --- SDCC 2.9.0's banked calls: the bank word ------------------------
    def bank_words(o):
        if not o.old:
            return
        text = open(o.asm).read()

        def word(m):
            if m[2] in o.defs:
                bank = o.g["bank"]
            else:
                bank = o.banks.get(m[2])
            if bank is None:
                sys.exit(f"error: {o.src}: banked call to {m[2]}, which has no bank")
            return f"{m[1]}.dw {bank}{m[3]}"
        new = re.sub(r"(\.dw\s+(\w+)\s*\n\s*)\.dw 0(\s*; PENDING: bank support)", word, text)
        if new != text:
            open(o.asm, "w").write(new)
            assemble(o, out)
    with concurrent.futures.ThreadPoolExecutor(os.cpu_count()) as ex:
        list(ex.map(bank_words, objs))

    # --- areas and names in the objects ----------------------------------
    ram = manifest.RAM_CODE
    base = {}                                   # area -> address
    seen = {}                                   # area -> size, for the report
    for o in objs:
        g = o.g
        gn, bank = g["name"], g["bank"]
        text = open(o.rel).read()
        ren = {}
        for area, (size, flags) in rel_areas(o.rel).items():
            if flags & 8:                       # absolute: where its .org says
                continue
            if area == "_CODE" and gn == ram["group"]:
                ren[area] = "_CODE_RAM"
            elif area == "_CODE":            # sdldgb puts an area named _CODE at 0
                ren[area] = f"_CODE_{bank}"
            elif area in ("_DATA", "_BSS"):
                ren[area] = f"{area}_{gn}"
                if size and area not in g["data"]:
                    sys.exit(f"error: {o.src} has {size} bytes of {area} and group {gn} no place for it")
                if area in g["data"]:
                    base[ren[area]] = g["data"][area]
            seen[ren.get(area, area)] = seen.get(ren.get(area, area), 0) + size
        for old, new in ren.items():
            text = re.sub(rf"^A {re.escape(old)} size", f"A {new} size", text, flags=re.M)
        for old, new in o.rename.items():
            text = re.sub(rf"^S {re.escape(old)} (Ref|Def)", rf"S {new} \1", text, flags=re.M)
        o.link = o.rel[:-4] + ".o"
        open(o.link, "w").write(text)

    # the order of the areas: an area with no address of its own follows
    # the one before it
    bank0 = ["_HOME", "_MOD0A", "_MOD0B", "_MOD0C", "_BASE", "_CODE_0", "_LIB0", "_LIB1", "_LIB2",
             "_LIB3", "_LIB4", "_LIB5", "_VBLLCD", "_LIT"]
    chains = [bank0, ["_CODE_1", "_GSINIT", "_GSINITTAIL", "_GSFINAL"]]
    chains += [[f"_CODE_{n}"] for n in range(2, manifest.BANKS)]
    chains += [["_CODE_RAM"]]
    base["_HOME"] = 0x01ed                      # after crt0's header and the mode table
    for n in range(1, manifest.BANKS):
        base[f"_CODE_{n}"] = (n << 16) | 0x4000
    base[f"_CODE_{ram['bank']}"] += ram["size"]
    base["_CODE_RAM"] = 0x7f0000 | ram["run"]   # a bank no ROM has: moved below
    placed = {x for c in chains for x in c} | set(base)
    stray = {n: s for n, s in seen.items() if s and n not in placed}
    if stray:
        sys.exit(f"error: areas with no place: {stray}")
    order = os.path.join(out, "obj", "order.s")
    open(order, "w").write("".join(f"\t.area {x}\n" for c in chains for x in c))
    run(["sdasgb", "-plosgff", order[:-2] + ".rel", order])

    lines = ["-mjwx", "-i kernel.ihx"]
    lines += [f"-b {n}=0x{v:x}" for n, v in sorted(base.items()) if n in seen or n in placed]
    lines += [f"-g {n}=0x{v:04x}" for n, v in sorted(absolute.items())]
    lines += ["obj/order.rel"] + [os.path.relpath(o.link, out) for o in objs] + ["-e"]
    open(os.path.join(out, "kernel.lk"), "w").write("\n".join(lines) + "\n")
    for f in ("kernel.ihx", "kernel.map"):
        if os.path.exists(os.path.join(out, f)):
            os.remove(os.path.join(out, f))
    r = run(["sdldgb", "-nf", "kernel.lk"], cwd=out, ok=True)
    if r.returncode != 0 or not os.path.exists(os.path.join(out, "kernel.ihx")):
        sys.exit(f"error: sdldgb\n{r.stdout}{r.stderr}")
    if r.stdout.strip() or r.stderr.strip():
        print((r.stdout + r.stderr).strip())

    # --- checks ----------------------------------------------------------
    syms = parse_map(os.path.join(out, "kernel.map"))

    def end(chain):
        e = 0
        for x in chain:
            if "s_" + x in syms:
                e = max(e, syms["s_" + x] + syms.get("l_" + x, 0))
        return e
    bad = []
    used = {}
    e = end(bank0)
    used[0] = e
    if e > 0x4000:
        bad.append(f"bank 0 is {e - 0x4000} bytes too long")
    for c in chains[1:-1]:
        n = int(c[0].split("_")[-1])
        e = end(c) & 0xffff
        used[n] = e - 0x4000
        if end(c) and e > 0x8000:
            bad.append(f"bank {n} is {e - 0x8000} bytes too long")
    if syms.get("l__CODE_RAM", 0) > ram["size"]:
        bad.append(f"the RAM routine is {syms['l__CODE_RAM']} bytes, over {ram['size']}")
    if bad:
        sys.exit("error: " + "; ".join(bad))

    # --- the ROM ---------------------------------------------------------
    size = manifest.BANKS * 0x4000
    rom, extra = parse_ihx(os.path.join(out, "kernel.ihx"), size)
    src0 = 0x7f * 0x4000 + ram["run"] - 0x4000   # where sdldgb writes bank $7f
    dst0 = ram["bank"] * 0x4000 + (ram["at"] & 0x3fff)
    for addr, b in extra.items():
        off = addr - src0
        if not 0 <= off < ram["size"]:
            sys.exit(f"error: linked bytes outside the ROM at ${addr:x}")
        rom[dst0 + off] = b
    gb = os.path.join(out, "kernel.gb")
    open(gb, "wb").write(rom)
    run(["rgbfix", "-Wno-overwrite", "-f", "hg", gb])

    with open(os.path.join(out, "kernel.sym"), "w") as f:
        rows = []
        for n, v in syms.items():
            if n.startswith(("l__", "s__", "b_")) or n in absolute and v < 0x100:
                continue
            bank = v >> 16
            if bank == 0x7f:
                continue
            rows.append((bank, v & 0xffff, n))
        for bank, addr, n in sorted(rows):
            f.write(f"{bank:02x}:{addr:04x} {n}\n")
    free = " ".join(f"{n}:{(0x4000 - u)}" for n, u in sorted(used.items()))
    print(f"{os.path.relpath(gb, ROOT)}: {manifest.BANKS} banks; bytes free by bank: {free}")


if __name__ == "__main__":
    main()
