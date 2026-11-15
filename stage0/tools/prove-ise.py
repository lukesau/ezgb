#!/usr/bin/env python3
"""Prove an ISE build of the readable design equivalent to the stock bitstream.

    stage0/tools/prove-ise.py STOCK_EXPORT ISE_EXPORT PROJDIR

STOCK_EXPORT and ISE_EXPORT are export-netlist.sh directories (design.v)
of the stock slot B and of the ISE build; PROJDIR is the mkise.py project
(place.txt) with the build's top.xdl (xdl -ncd2xdl). Together with the
per-block proofs (readable == stock, equiv.sh and prove-top.sh) this shows
the ISE bitstream does what the readable design says.

The two netlists are matched by name. Slice flip-flops: mkise.py --place
put almost every one in its stock cell, so the export names it as stock's
does; the build's XDL says which logical register is in each cell, and
any that is elsewhere is renamed to its stock name. LUT RAM contents are
named by register on both sides (stock: the picoblaze block file; ISE:
the XDL). Block RAMs, IO tiles, the DCMs, the DNA port and the ICAP are
cut out (expose -evert), so their pins become ports on both sides and the
logic around them is compared pin for pin; their attributes are compared
separately, as text. Everything else is hidden, and yosys proves each
matched register's next state and each port equal (equiv_simple, then
equiv_induct for what is left).

Output: ISE_EXPORT/prove/ (the yosys script and log).
"""
import argparse
import pathlib
import re
import subprocess
import sys

repo = pathlib.Path(__file__).resolve().parents[2]
ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
ap.add_argument("stock", type=pathlib.Path)
ap.add_argument("ise", type=pathlib.Path)
ap.add_argument("proj", type=pathlib.Path)
ap.add_argument("--fw", default="fw4", help="default: the project's (PROJDIR/fw)")
ap.add_argument("--blocks", type=pathlib.Path, help="the block files (default the firmware's)")
ap.add_argument("--swap64", action="store_true", help="RAM64X1S: XDL .S1 holds q0/q1")
args = ap.parse_args()
out = args.ise / "prove"
out.mkdir(parents=True, exist_ok=True)
# the firmware the project was made for (mkise.py writes it), and mkise.py's
# table of where its top, modules and block files are
fwf = args.proj / "fw"
if fwf.exists():
    args.fw = fwf.read_text().strip()
FW = {"fw4": ("stage0/fw4/rtl/fw4_top.v", ["stage0/fw4/rtl"], "stage0/fw4/blocks"),
      "fw5-0918": ("stage0/fw5-0918/fw5_top.v", ["stage0/fw5-0918", "stage0/fw4/rtl"], "fpga/fw5-nx/edge/blk")}
top_rel, rtl_dirs, blk_dir = FW[args.fw]
blk_dir = args.blocks or repo / blk_dir
top_src = (repo / top_rel).read_text()
# inputs the stitched top ties to a constant and leaves unconnected (fw5-top.sh's TIES)
ties = {}
if args.fw == "fw5-0918":
    m = re.search(r'TIES="([^"]*)"', (repo / "stage0" / "tools" / "fw5-top.sh").read_text())
    for t in (m[1].split() if m else []):
        mod, pv = t.split(":")
        port, v = pv.split("=")
        ties.setdefault(mod, {})[port] = v
block_names = re.search(r"^// blocks: (.*)$", top_src, re.M)[1].split()
module_file = lambda n: next(repo / d / f"{n}.v" for d in rtl_dirs if (repo / d / f"{n}.v").exists())

# ---- slice sites -> tiles
site_tile = {}
for l in open(repo / "stage0" / "ise" / "xc3s200a-slices.txt"):
    t, site, _ = l.split()
    sx, sy = map(int, re.match(r"SLICE_X(\d+)Y(\d+)", site).groups())
    tx, ty = map(int, re.match(r"CLB_X(\d+)Y(\d+)", t).groups())
    site_tile[site] = f"X{tx}Y{ty}_S{(sx & 1) + 2 * (sy & 1)}"

# ---- the ISE build's XDL: what is in each slice
xdl = (args.proj / "top.xdl").read_text()
ff_at, ram_at = {}, {}       # logical name -> cell (X..Y.._Sk.FFX), RAM name -> slice LUT
for m in re.finditer(r'^inst "[^"]*" "SLICE[LM]",placed \S+ (SLICE_X\d+Y\d+)\s*,\s*cfg "(.*?)"\s*;', xdl, re.M | re.S):
    cell = site_tile[m[1]]
    for ff, name in re.findall(r"\b(FF[XY]):(\S+?):#(?:FF|LATCH)", m[2]):
        ff_at[name] = f"{cell}.{ff}"
    for lut, name in re.findall(r"\b([FG]):(\S+?):#RAM", m[2]):
        ram_at[name] = f"{cell}_{lut}"

stock_cell = dict(l.split() for l in open(args.proj / "place.txt"))
gate_ren = []
moved = 0
for name, cell in stock_cell.items():
    got = ff_at.get(name)
    if got is None:
        sys.exit(f"{name}: not in a slice flip-flop of the build (IOB?)")
    if got != cell:
        moved += 1
        a, b = got.split("."), cell.split(".")
        gate_ren.append((f"n_{a[0]}_{a[1][2]}Q", f"n_{b[0]}_{b[1][2]}Q"))

# LUT RAM: stock names from the picoblaze block file, ISE names from the XDL
stock_ram = {}
for l in open(blk_dir / "picoblaze.blk"):
    m = re.match(r"(X\d+Y\d+_S\d_[FG])\.m\s+(\S+)", l)
    if m:
        stock_ram[m[2]] = m[1]


def ram_name(xst):
    m = re.fullmatch(r"u_logic/u_picoblaze/(\w+)/r(?:\.SLICEM_([FG])|/([FG])(?:\.S([01]))?)", xst)
    if not m:
        sys.exit(f"unknown LUT RAM {xst}")
    base = m[1]
    if m[2]:                                    # RAM16X1D: G the write port, F the read port
        return f"{base}.{'sx' if m[2] == 'G' else 'sy'}"
    if m[4] is None:                            # RAM32X1S: F the upper half
        return f"{base}.{'hi' if m[3] == 'F' else 'lo'}"
    lo_slice = "1" if args.swap64 else "0"      # RAM64X1S: one slice q0/q1, the other q2/q3
    q = (0 if m[4] == lo_slice else 2) + (1 if m[3] == "F" else 0)
    return f"{base}.q{q}"


gate_ram = {ram_name(x): c for x, c in ram_at.items()}
if set(gate_ram) != set(stock_ram):
    sys.exit(f"LUT RAMs differ: {sorted(set(gate_ram) ^ set(stock_ram))[:10]}")


def lut_wire(cell):
    slc, lut = cell.rsplit("_", 1)
    return f"i_{slc}.{'fm' if lut == 'F' else 'gm'}"


# ---- power-up values, which the proof does not see: each slice flip-flop's
# INIT, and each LUT RAM's initial contents, against its stock cell
def slice_params(path):
    d = {}
    for m in re.finditer(r"s3_slice #\((.*?)\) i_(X\d+Y\d+_S\d) \(", open(path).read()):
        d[m[2]] = dict(re.findall(r"\.(\w+)\(([^(),]*)\)", m[1]))
    return d


sp_gold, sp_gate = slice_params(args.stock / "design.v"), slice_params(args.ise / "design.v")
bad_init = []
for name, cell in stock_cell.items():
    gs, gff = cell.split("."); ts, tff = ff_at[name].split(".")
    a = sp_gold.get(gs, {}).get(f"{gff}_INIT", "0"); b = sp_gate.get(ts, {}).get(f"{tff}_INIT", "0")
    if a != b:
        bad_init.append(f"{name}: stock {a}, ISE {b}")
for n, c in stock_ram.items():
    gs, lut = c.rsplit("_", 1); ts, tlut = gate_ram[n].rsplit("_", 1)
    a = sp_gold.get(gs, {}).get(lut); b = sp_gate.get(ts, {}).get(tlut)
    if a != b:
        bad_init.append(f"LUT RAM {n}: stock {a}, ISE {b}")
for x in bad_init[:20]:
    print("power-up value differs:", x)
print(f"power-up values: {len(stock_cell) + len(stock_ram) - len(bad_init)} of {len(stock_cell) + len(stock_ram)} match")

# ---- primitive attributes, compared as text
CUT = ("s3_ioi", "s3_bram", "s3_dcm", "s3_dna", "s3_icap")


def prims(path):
    d = {}
    for l in open(path):
        m = re.match(r"(s3_\w+) (#\((.*?)\) )?(i_\w+) \(", l)
        if m and m[1] in CUT:
            p = re.sub(r'\.(DATAFILE|PARFILE)\("[^"]*"\)', "", m[3] or "")
            d[m[4]] = (m[1], p)
    return d


ps, pi = prims(args.stock / "design.v"), prims(args.ise / "design.v")
bad = [k for k in sorted(set(ps) | set(pi)) if ps.get(k) != pi.get(k)]
for k in bad:
    print(f"attributes differ: {k}\n  stock {ps.get(k)}\n  ise   {pi.get(k)}")

# ---- the readable modules' reachable-state invariants, bound to stock's
# register nets. equiv.sh proves them true of stock (its third pass); here
# they let the signals that depend on them (a register file indexed by a
# counter that never leaves its range) be proved by temporal induction.
# Only modules whose invariants read nothing but their own registers.
inv_v, inv_inst = [], []
KW = {"always", "begin", "end", "if", "else", "assume", "assert", "case", "endcase", "default", "signed"}
stock_src = (args.stock / "design.v").read_text()
stock_wires = set(re.findall(r"^wire (\w+);", stock_src, re.M))
stock_mux = {m[2]: dict(re.findall(r"\.(FXMUX|GYMUX)\(\"(\w+)\"\)", m[1]))
             for m in re.finditer(r"s3_slice #\((.*?)\) i_(X\d+Y\d+_S\d) \(", stock_src)}


def lut_net(b):
    """b_<slice>_F/G, a LUT's output: the slice's X/Y net when that passes it."""
    m = re.fullmatch(r"b_(X\d+Y\d+_S\d)_([FG])", b)
    if not m:
        return None
    mux = stock_mux.get(m[1], {})
    if m[2] == "F" and mux.get("FXMUX", "F") == "F":
        return f"n_{m[1]}_X"
    if m[2] == "G" and mux.get("GYMUX", "G") == "G":
        return f"n_{m[1]}_Y"
    return None


def vnum(t):
    """A Verilog literal or plain number as an int."""
    m = re.fullmatch(r"(\d*)'([bdh])([0-9a-fA-F_]+)", t)
    if m:
        return int(m[3].replace("_", ""), {"b": 2, "d": 10, "h": 16}[m[2]])
    return int(t)


def width(spec, params):
    if not spec:
        return None
    e = spec.strip("[] ")
    hi, lo = e.split(":")
    ev = lambda x: eval(re.sub(r"\b[A-Za-z_]\w*\b", lambda m: str(params[m[0]]), x))
    return ev(hi), ev(lo)


for blk in block_names:
    src = re.sub(r"//.*", "", module_file(blk).read_text())
    m = re.search(r"`ifdef FORMAL(.*?)`endif", src, re.S)
    if not m:
        continue
    body = m[1]
    params, plines = {}, re.findall(r"\blocalparam\b[^;]*;", src)
    for pl in plines:
        for n, v in re.findall(r"(\w+)\s*=\s*([\w']+)", pl):
            params[n] = vnum(v)
    decl = {}       # name -> (kind, (hi, lo) or None, signed, wire expr)
    for kind, sg, spec, names in re.findall(r"\b(output\s+reg|reg|input|output|wire)\s+(signed\s+)?(\[[^\]]*\])?\s*([^;)]*?)(?=;|\)\s*;|,\s*(?:input|output|inout)\b|$)", src, re.M):
        for part in re.split(r",(?![^{]*})", names):
            nm, _, expr = part.partition("=")
            nm = nm.strip()
            if re.fullmatch(r"\w+", nm):
                decl.setdefault(nm, (kind, width(spec, params), bool(sg), expr.strip() if kind == "wire" else ""))
    labels = set(re.findall(r"\b(\w+)\s*:\s*assume", body))
    want = set(re.findall(r"\b[A-Za-z_]\w*\b", body)) - KW - set(params) - labels
    want = {i for i in want if not re.fullmatch(r"[bdh][0-9a-fA-F]+", i)}
    wires, todo = [], list(want)
    while todo:
        i = todo.pop()
        if i in decl and decl[i][0] == "wire" and decl[i][3]:
            if i not in wires:
                wires.append(i)
                ids = set(re.findall(r"\b[A-Za-z_]\w*\b", decl[i][3])) - set(params)
                ids = {x for x in ids if not re.fullmatch(r"[bdh][0-9a-fA-F]+", x)}
                todo += [x for x in ids if x not in want]
                want |= ids
    # nets for registers (their stock cells) and inputs (as fw4_top wires them)
    inst = re.search(rf"^{blk} u_{blk} \((.*)\);$", top_src, re.M)[1]
    wiring = {p: [f"1'b{v}"] for p, v in ties.get(blk, {}).items()}
    for port, conn in re.findall(r"\.(\w+)\(([^()]*)\)", inst):
        bits = [b.strip() for b in conn.strip("{}").split(",")]
        wiring[port] = bits
    # an assumption that names a net the stock netlist doesn't have (a LUT
    # output inside a slice) is left out: fewer assumptions can only make
    # the proof harder, never wrong
    def bindable(i):
        if i in wires:
            return True
        if i not in decl or decl[i][0] == "wire":
            return False
        bits = wiring.get(i)
        if decl[i][0] in ("reg", "output reg") or decl[i][0].startswith("output") and decl[i][0] != "output":
            return True
        if bits is None:
            return False
        for b in bits:
            b = lut_net(b) if b.startswith("b_") else b
            if b is None or not (b in stock_wires or re.fullmatch(r"~?1'b[01]", b)):
                return False
        return True
    dropped = []
    for i in sorted(want):
        if not bindable(i):
            pat = re.compile(rf"^[ \t]*(\w+:\s*)?assume\s*\(.*\b{i}\b.*\);[ \t]*$", re.M)
            if pat.search(body):
                dropped += [x.strip() for x in pat.findall(body)] or [i]
                body = pat.sub("", body)
    if dropped:
        want = set(re.findall(r"\b[A-Za-z_]\w*\b", body)) - KW - set(params) - set(re.findall(r"\b(\w+)\s*:\s*assume", body))
        want = {i for i in want if not re.fullmatch(r"[bdh][0-9a-fA-F]+", i)}
        for w in list(wires):
            ids = {x for x in re.findall(r"\b[A-Za-z_]\w*\b", decl[w][3]) if not re.fullmatch(r"[bdh][0-9a-fA-F]+", x)} - set(params)
            want |= ids if w in want else set()
        print(f"invariants of {blk}: an assumption on a net the stock netlist lacks left out")
    ports, conns, ok = [], [], True
    for i in sorted(want - set(wires)):
        if i not in decl or decl[i][0] == "wire":
            ok = False
            break
        kind, w, sg, _ = decl[i]
        if kind.startswith("output") and kind != "output":
            kind = "reg"
        if kind == "output":
            kind = "input"          # a plain output: its net, as the top wires it
        nets = []
        for k in (range(w[0], w[1] - 1, -1) if w else [None]):
            if kind == "reg":
                c = stock_cell.get(f"u_logic/u_{blk}/{i}" + (f"_{k}" if w else ""))
                net = None if c is None else f"n_{c.split('.')[0]}_{c.split('.')[1][2]}Q"
            else:
                bits = wiring.get(i)
                net = None if bits is None else bits[len(bits) - 1 - (k - w[1])] if w else bits[0]
            if net is not None and net.startswith("b_"):
                net = lut_net(net)
            if net is None or not (net in stock_wires or re.fullmatch(r"~?1'b[01]", net)):
                ok = False
                break
            nets.append(net)
        if not ok:
            break
        ports.append(f"input {'signed ' if sg else ''}{f'[{w[0]}:{w[1]}] ' if w else ''}{i}")
        conns.append(f".{i}({{{', '.join(nets)}}})")
    if not ok:
        print(f"invariants of {blk} not bound: {i} is not a register or a net of the stock netlist")
        continue
    wdecl = [f"    wire {'signed ' if decl[x][2] else ''}{f'[{decl[x][1][0]}:{decl[x][1][1]}] ' if decl[x][1] else ''}{x} = {decl[x][3]};" for x in reversed(wires)]
    inv_v.append(f"module inv_{blk} ({', '.join(ports)});\n" + "\n".join(plines) + "\n" + "\n".join(wdecl) + body + "endmodule\n")
    inv_inst.append(f"inv_{blk} u_inv_{blk} ({', '.join(conns)});")
# registers stock duplicates: the same D net, enable, clock, set/reset and
# power-up value, so always equal (equal at power-up, and the same next
# value from the same inputs). The induction needs that stated where the two
# builds read different copies (FW5's two port EF copies, load_busy_2x)
groups = {}
for m in re.finditer(r"s3_slice #\((.*?)\) i_(X\d+Y\d+_S\d) \((.*?)\);", stock_src):
    P = dict(re.findall(r"\.(\w+)\(([^(),]*)\)", m[1])); B = dict(re.findall(r"\.(\w+)\(([^()]*)\)", m[3]))
    common = tuple(P.get(k) for k in ("FF_LATCH", "FF_SR_SYNC", "FF_SR_ENABLE", "FF_REV_ENABLE")) + tuple(B.get(k) for k in ("CE", "SR", "CLK"))
    for ff, pin, mux in (("X", "BX_i", "DXMUX"), ("Y", "BY_i", "DYMUX")):
        q = B.get(f"{ff}Q")
        if q and P.get(mux) == f'"B{ff}"' and B.get(pin):
            key = (B[pin], P.get(f"FF{ff}_INIT"), P.get(f"FF{ff}_SRVAL")) + common
            groups.setdefault(key, []).append(q)
dups = [g for g in groups.values() if len(g) > 1]
if dups:
    inv_v.append("module inv_dups (" + ", ".join(f"input d{k}_{j}" for k, g in enumerate(dups) for j in range(len(g))) + ");\n"
                 "    always @* begin\n" + "".join(f"        assume (d{k}_0 == d{k}_{j});\n" for k, g in enumerate(dups) for j in range(1, len(g)))
                 + "    end\nendmodule\n")
    inv_inst.append("inv_dups u_inv_dups (" + ", ".join(f".d{k}_{j}({q})" for k, g in enumerate(dups) for j, q in enumerate(g)) + ");")
    print(f"duplicate registers in stock: {sum(len(g) for g in dups)} in {len(dups)} groups, assumed equal")
print("invariants bound:", ", ".join(x.split()[0][4:] for x in inv_inst) or "none")
(out / "inv.v").write_text("\n".join(inv_v))
gold_v = (args.stock / "design.v").read_text()
i = gold_v.index("\nendmodule", gold_v.index("module fpga_top"))
(out / "gold.v").write_text(gold_v[:i] + "\n" + "\n".join(inv_inst) + gold_v[i:])

# ---- yosys
lib = (repo / "stage0" / "lib" / "s3prims_synth.v").read_text()
lib = re.sub(r"\nmodule s3_(iff|ioi)\b.*?\nendmodule\n", "\n", lib, flags=re.S)
# the LUT contents keep their names through flattening, for the RAM renames
lib = lib.replace("    reg [15:0] fm = F, gm = G;", "    (* keep *) reg [15:0] fm = F;\n    (* keep *) reg [15:0] gm = G;")
assert "(* keep *) reg [15:0] fm" in lib
lib += """
(* blackbox *)
module s3_ioi #(parameter MUX_O = "NONE", MUX_T = "NONE", MUX_FFI = "NONE",
                parameter FFO_INIT = 1, FFT_INIT = 1, FFI_INIT = 1,
                parameter FFO1_LATCH = 0, FFO2_LATCH = 0, FFT1_LATCH = 0, FFT2_LATCH = 0, FFI_LATCH = 0,
                parameter FFO_SR_EN = 0, FFO_REV_EN = 0, FFO_SR_SYNC = 0, FFO1_SRVAL = 1, FFO2_SRVAL = 1,
                parameter FFT_SR_EN = 0, FFT_REV_EN = 0, FFT_SR_SYNC = 0, FFT1_SRVAL = 1, FFT2_SRVAL = 1,
                parameter FFI_SR_EN = 0, FFI_REV_EN = 0, FFI_SR_SYNC = 0, FFI1_SRVAL = 1) (
    input PAD, input O1, O2, T1, T2, OTCLK1, OTCLK2, ICLK1, OCE, TCE, ICE, SR, REV,
    output I, IQ1, CLKPAD
);
endmodule
"""
(out / "prims.v").write_text(lib)


def side(design, ren, ram, inv=False):
    s = [f"read_verilog -sv {out / 'prims.v'}"] + ([f"read_verilog -sv -formal {out / 'inv.v'}"] if inv else [])
    s += [f"read_verilog -sv {design}",
         "hierarchy -top fpga_top", "proc", "flatten", "opt_clean",
         "expose -evert " + " ".join(f"t:{c}" for c in CUT), "async2sync", "opt_clean"]
    s += ["cd fpga_top"] + [f"rename {a} {b}__moved" for a, b in ren] + [f"rename {b}__moved {b}" for a, b in ren]
    s += [f"rename {lut_wire(c)} ram__{n.replace('.', '__')}" for n, c in sorted(ram.items())] + ["cd .."]
    s += ["select -set keep w:n_*_XQ w:n_*_YQ w:ram__* x:*", "rename -hide w:* @keep %d", "opt_clean"]
    return s


ys = side(out / "gold.v", [], stock_ram, inv=True) + ["rename -top gold", "design -stash gold"]
ys += side(args.ise / "design.v", gate_ren, gate_ram) + ["rename -top gate", "design -stash gate"]
ys += ["design -copy-from gold -as gold gold", "design -copy-from gate -as gate gate",
       "equiv_make gold gate equiv", "hierarchy -top equiv", "opt_clean",
       "equiv_simple -seq 4", "equiv_induct -seq 4"]
(out / "prove.ys").write_text("\n".join(ys + ["equiv_status"]) + "\n")
print(f"{len(stock_cell)} flip-flops ({moved} not in their stock cell), {len(gate_ram)} LUT RAM cells")
log = out / "prove.log"
r = subprocess.run(["yosys", "-q", "-l", str(log), "-s", str(out / "prove.ys")])
if r.returncode:
    sys.exit(f"setup failed: see {log}")
left = re.findall(r"^\s+Unproven \$equiv \S+: (\S+) (\S+)$", log.read_text(), re.M)
total = re.search(r"Found (\d+) \$equiv cells", log.read_text())
print(f"structural: {int(total[1]) - len(left)} of {total[1]} signals proven, {len(left)} left")
if left:
    # the rest by temporal induction with the invariants in force
    # the pins and the registers separately: together the induction need not
    # close within the steps where each does on its own
    groups = [g for g in ([p for p in left if "IOI" in p[0]], [p for p in left if "IOI" not in p[0]]) if g]
    for k, grp in enumerate(groups):
        proves = " ".join(f"-prove {a} {b}" for a, b in grp)
        steps = 16 if "IOI" in grp[0][0] else 8
        (out / f"induct{k}.ys").write_text("\n".join(ys + ["equiv_remove", "opt_clean",
            f"sat -verify -tempinduct -set-assumes -seq 1 -maxsteps {steps} {proves} equiv"]) + "\n")
        r = subprocess.run(["yosys", "-q", "-l", str(out / f"induct{k}.log"), "-s", str(out / f"induct{k}.ys")])
        if r.returncode:
            sys.exit(f"NOT proven: {len(grp)} signals, see {out / f'induct{k}.log'}")
    print(f"induction: the other {len(left)} proven under the invariants")
if bad or bad_init:
    sys.exit(f"{len(bad)} primitives differ in attributes, {len(bad_init)} power-up values differ")
print("equivalent to stock: every matched register and port")
