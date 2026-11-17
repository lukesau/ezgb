#!/usr/bin/env python3
"""Layout and symbols for a kernel whose code has moved (make MOD=1).

The stock build links every source at its stock address and takes the
addresses of everything else from the stock kernel.sym. A mod build changes
the C, so code after a change moves. These two steps work that out from the
symbol files sdinc.py writes for each link (--syms-out):

  layout DIR
      DIR holds a link of the changed source at the stock addresses: only
      the sizes are right. Prints the make variables that place bank 0's
      and bank 1's pieces one after another: B0K, LSHIFT, G1-G4.

  relsym STOCK.sym STOCKDIR MODDIR OUT.sym
      STOCKDIR is the stock build and MODDIR a link of the changed source at
      the new layout. A kernel.sym name is the name of whatever source
      symbol is at its address in the stock build; OUT.sym gives each name
      that symbol's address in MODDIR. Names in RAM keep their address.
      ROM names with no source symbol (labels inside a routine) are left
      out. Every source symbol only one link defines is also written under
      its own name, bank included, which is how stock C finds a routine the
      mod adds.
"""
import glob
import os
import re
import sys

SYM = re.compile(r"\s*([0-9a-fA-F]{2}):([0-9a-fA-F]{4})\s+(\S+)")
AREA = re.compile(r"; area (\S+) ([0-9a-f]+) ([0-9a-f]+)")


def where(bank, addr):
    """(bank, addr) as kernel.sym has it. A link is given one bank, but
    bank 0's sources also have _GSINIT code in bank 1, and RAM has no bank."""
    if addr < 0x4000 or addr >= 0x8000:
        return 0, addr
    return (bank or 1), addr


def load(directory):
    """file name -> ({symbol: (bank, addr)}, {area: length})"""
    out = {}
    for path in sorted(glob.glob(os.path.join(directory, "*.sym"))):
        if os.path.basename(path) in ("kernel.sym", "kernel.in.sym"):
            continue
        syms, areas = {}, {}
        for line in open(path):
            m = AREA.match(line)
            if m:
                areas[m.group(1)] = int(m.group(3), 16)
                continue
            m = SYM.match(line)
            if m:
                syms.setdefault(m.group(3), where(int(m.group(1), 16), int(m.group(2), 16)))
        out[os.path.basename(path)] = (syms, areas)
    return out


def layout(directory):
    groups = load(directory)

    def size(name, area):
        return groups[name][1].get(area, 0)

    b0k = 0x07bc + size("b0_kernel.sym", "_CODE")
    lib = b0k + size("b0_fatfs.sym", "_CODE")
    g1 = 0x4000 + size("b1_code.sym", "_CODE")
    g2 = g1 + size("b0_kernel.sym", "_GSINIT")
    g3 = g2 + size("b0_fatfs.sym", "_GSINIT")
    g4 = g3 + size("b1_code.sym", "_GSINIT")
    print(f"B0K={b0k:04x} LSHIFT={0x20bb - lib} G1={g1:04x} G2={g2:04x} G3={g3:04x} G4={g4:04x}")


def relsym(stock_sym, stock_dir, mod_dir, out):
    stock, mod = load(stock_dir), load(mod_dir)
    at = {}                     # (bank, addr) in stock -> [(group, symbol)]
    for group, (syms, _) in stock.items():
        for name, loc in syms.items():
            at.setdefault(loc, []).append((group, name))
    lines, dropped = [], 0
    for line in open(stock_sym):
        m = SYM.match(line)
        if not m:
            continue
        bank, addr, name = int(m.group(1), 16), int(m.group(2), 16), m.group(3)
        if addr >= 0x8000:
            lines.append(f"{bank:02x}:{addr:04x} {name}")
            continue
        for group, csym in at.get((bank, addr), []):
            if csym in mod.get(group, ({},))[0]:
                b, a = mod[group][0][csym]
                lines.append(f"{b:02x}:{a:04x} {name}")
                break
        else:
            if addr == 0x4000:  # the start of a bank does not move
                lines.append(f"{bank:02x}:{addr:04x} {name}")
            dropped += 1
    owners = {}
    for group, (syms, _) in mod.items():
        for name in syms:
            owners.setdefault(name, []).append(group)
    for name, groups in sorted(owners.items()):
        if len(groups) == 1 and not name.startswith("."):
            b, a = mod[groups[0]][0][name]
            lines.append(f"{b:02x}:{a:04x} {name}")
    text = "\n".join(lines) + "\n"
    if not os.path.exists(out) or open(out).read() != text:
        open(out, "w").write(text)      # untouched when nothing moved: make's rebuild test
    print(f"{out}: {len(lines)} symbols, {dropped} stock labels inside routines left out")


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "layout":
        layout(sys.argv[2])
    elif len(sys.argv) == 6 and sys.argv[1] == "relsym":
        relsym(*sys.argv[2:])
    else:
        sys.exit(__doc__)
