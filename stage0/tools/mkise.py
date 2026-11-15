#!/usr/bin/env python3
"""Write an ISE project for the readable design: Verilog, UCF, XST script.

    stage0/tools/mkise.py OUTDIR --bram DIR [--bram DIR ...] [--fw fw4|fw5-0918]

The design is the firmware's stitched top (fw4: stage0/fw4/rtl/fw4_top.v;
fw5-0918: stage0/fw5-0918/fw5_top.v), the primitives as the bitstream has
them over the readable <prefix>_logic, and the blocks its header lists,
each from the first module directory that has it (FW5: stage0/fw5-0918,
then FW4's). The top is copied to OUTDIR/top.v with the unused DCMs and
block RAMs left out and the two clock pads marked, and compiled against
stage0/ise/s3prims_ise.v.

OUTDIR/top.ucf places every pad and block RAM where the bitstream has
them, with stage0/ise/<fw>.ucf (IO standards, pull-ups, timing) appended.
Block RAM contents are INIT_xx / INITP_xx constraints from the blobs:
<tile>.DATA.bin and <tile>.DATAP.bin (stage1-to-bram.py,
picoblaze-patch.py) or <tile>.BEL.BRAM.DATA.bin (s3decode --blob-dir). The
first --bram directory holding a tile's blob wins, so stage1 and patch
blobs go before the stock decode.

--place DESIGN.v (the exported netlist the blocks were carved from) also
puts every flip-flop a block file names in the slice and FF it has in the
bitstream: the readable design keeps the hardware's registers one for one,
so stock's placement carries over and map packs the logic around it. The
slice sites come from stage0/ise/xc3s200a-slices.txt (xdl -report);
stage0/ise/<fw>.unplace lists the flip-flops left to ISE.
"""
import argparse
import pathlib
import re
import shutil
import sys

repo = pathlib.Path(__file__).resolve().parents[2]
ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
ap.add_argument("out", type=pathlib.Path)
ap.add_argument("--bram", type=pathlib.Path, action="append", default=[])
ap.add_argument("--fw", default="fw4")
ap.add_argument("--place", type=pathlib.Path, metavar="DESIGN.v")
ap.add_argument("--blocks", type=pathlib.Path, help="the block files (default the firmware's)")
args = ap.parse_args()

FW = {"fw4": ("stage0/fw4/rtl/fw4_top.v", ["stage0/fw4/rtl"], "stage0/fw4/blocks"),
      "fw5-0918": ("stage0/fw5-0918/fw5_top.v", ["stage0/fw5-0918", "stage0/fw4/rtl"], "fpga/fw5-nx/edge/blk")}
top_rel, rtl_dirs, blk_dir = FW[args.fw]
top_v = repo / top_rel
rtl_dirs = [repo / d for d in rtl_dirs]
blk_dir = args.blocks or repo / blk_dir
src = top_v.read_text()
args.out.mkdir(parents=True, exist_ok=True)
top_name = re.search(r"^module (\w+_top)\b", src, re.M)[1]
block_names = re.search(r"^// blocks: (.*)$", src, re.M)[1].split()


def module_file(name):
    return next(d / f"{name}.v" for d in rtl_dirs if (d / f"{name}.v").exists())


# the top: one instance per line after the wire declarations
lines = src.split("\n")
start = next(i for i, l in enumerate(lines) if l.startswith(f"module {top_name}"))
kept, pads, brams = [], [], []
for i, l in enumerate(lines):
    if re.match(r"\w+ u_\w+ \(", l):
        # a block file can give two nets one name (FW5's two copies of a
        # register); yosys takes the connection twice, XST refuses it.
        # Keep the first: the proof against stock checks the choice
        seen = set()
        def first(m):
            if m[1] in seen:
                return ""
            seen.add(m[1])
            return m[0]
        l = re.sub(r",?\s*\.(\w+)\((?:[^()]|\([^()]*\))*\)", first, l)
        l = re.sub(r"\(\s*,\s*", "(", l)
    if i > start:
        if l.startswith("s3_dcm ") and ".CLKIN(1'b0)" in l:
            continue
        if l.startswith("s3_bram ") and ".CLKA(1'b0)" in l and ".CLKB(1'b0)" in l:
            continue
        if l.startswith("s3_bufgmux "):
            # a mux whose select is tied passes one input: make it a BUFG so
            # timing analysis doesn't time the other clock through it
            if re.search(r"\.O\(\)", l):
                continue
            m = re.search(r"\.S\(1'b([01])\)", l)
            if m:
                i = re.search(rf"\.I{m[1]}\(([^()]*)\)", l)[1]
                l = re.sub(r"\(\.I0\(.*\.O\(", f"(.I({i}), .O(", l.replace("s3_bufgmux ", "s3_bufg ", 1))
        if l.startswith("s3_ioi "):
            m = re.search(r"\.PAD\((P\d+)\)", l)
            mo = re.search(r'\.MUX_O\("(\w+)"\)', l)[1]
            clk = re.search(r"\.CLKPAD\((n_\w+)\)", l)
            if clk and re.search(r"\b" + clk[1] + r"\b", "\n".join(lines[start + 1:i] + lines[i + 1:])):
                l = l.replace("s3_ioi #(", "s3_ioi #(.CLOCK_PAD(1), ", 1)
            pads.append((m[1], mo))
        if l.startswith("s3_bram "):
            brams.append(re.search(r"\) i_(D0X\d+Y\d+)_bram \(", l)[1])
    kept.append(l)
(args.out / "top.v").write_text("\n".join(kept))

# block RAM sites: two columns, X3 and X19, eight RAMs each, one per 4 rows
def site(tile):
    x, y = map(int, re.match(r"D0X(\d+)Y(\d+)", tile).groups())
    return f"RAMB16_X{ {3: 0, 19: 1}[x] }Y{(y - 1) // 4}"


def blob(tile, kind):
    for d in args.bram:
        for name in (f"{tile}.{kind}.bin", f"{tile}.BEL.BRAM.{kind}.bin"):
            if (d / name).exists():
                return (d / name).read_bytes()
    return None


ucf = [f"# written by stage0/tools/mkise.py from {top_v.relative_to(repo)}"]
for p, mo in sorted(pads, key=lambda x: int(x[0][1:])):
    ucf.append(f'NET "{p}" LOC = "{p}";')
# clock buffers and the DCM where the bitstream has them, so an export of
# the result names their nets as stock's does. Left and right muxes k are
# sites Y = k + 2; bottom and top k = 0..3 are X2Y1, X2Y0, X1Y1, X1Y0 (top Y + 10)
def bufg_site(tile, k):
    if tile == "X0Y17":
        return f"BUFGMUX_X0Y{k + 2}"
    if tile == "X25Y17":
        return f"BUFGMUX_X3Y{k + 2}"
    x, y = [(2, 1), (2, 0), (1, 1), (1, 0)][k]
    return f"BUFGMUX_X{x}Y{y + (10 if tile == 'X13Y33' else 0)}"


for l in kept:
    m = re.match(r"s3_bufg(?:mux)? (i_(X\d+Y\d+)c_BUFGMUX(\d)) ", l)
    if m:
        ucf.append(f'INST "{m[1]}/b" LOC = "{bufg_site(m[2], int(m[3]))}";')
    m = re.match(r"s3_dcm .*?\) (i_X(\d+)Y(\d+)_dcm) ", l)
    if m:
        ucf.append(f'INST "{m[1]}/dcm" LOC = "DCM_X{int(m[2]) - 12}Y{0 if m[3] == "1" else 1}";')
missing = []
for t in sorted(brams):
    inst = f"i_{t}_bram/ram"
    ucf.append(f'INST "{inst}" LOC = "{site(t)}";')
    data, par = blob(t, "DATA"), blob(t, "DATAP")
    if data is None:
        missing.append(t)
        continue
    assert len(data) == 2048, (t, len(data))
    for k in range(64):
        ucf.append(f'INST "{inst}" INIT_{k:02X} = {int.from_bytes(data[32 * k:32 * k + 32], "little"):064X};')
    if par is not None:
        assert len(par) == 256, (t, len(par))
        for k in range(8):
            ucf.append(f'INST "{inst}" INITP_{k:02X} = {int.from_bytes(par[32 * k:32 * k + 32], "little"):064X};')
placed, place = 0, []
if args.place:
    sys.path.insert(0, str(repo / "stage0" / "tools"))
    import carve
    d = carve.Design(str(args.place))
    sx = {}
    for l in open(repo / "stage0" / "ise" / "xc3s200a-slices.txt"):
        t, site, _ = l.split()
        x = int(re.match(r"CLB_X(\d+)Y", t)[1])
        sxx = int(re.match(r"SLICE_X(\d+)Y", site)[1])
        sx[x] = min(sx.get(x, sxx), sxx)
    unplace = set()
    up = repo / "stage0" / "ise" / f"{args.fw}.unplace"
    if up.exists():
        unplace = {l.split("#")[0].strip() for l in open(up)} - {""}
    ucf.append("\n# stock flip-flop placement (--place)")
    for name in block_names:
        blk = blk_dir / f"{name}.blk"
        name, _, cells, names = carve.read_block(str(blk), d)
        cells = set(cells)
        # a block file may name an output port where the register behind it
        # is "assign port = reg": place the register
        body = re.sub(r"//.*", "", module_file(name).read_text())
        alias = {}
        for a in re.findall(r"\bassign\b(.*?);", body, re.S):
            for part in a.split(","):
                m = re.fullmatch(r"\s*(\w+)\s*=\s*(\w+)\s*", part)
                if m:
                    alias[m[1]] = m[2]
        for net, new in names.items():
            m = re.fullmatch(r"n_X(\d+)Y(\d+)_S(\d)_([XY])Q", net)
            if not m:
                continue
            x, y, k, xy = int(m[1]), int(m[2]), int(m[3]), m[4]
            if f"X{x}Y{y}_S{k}.FF{xy}" not in cells:
                continue
            site_x, site_y = sx[x] + (k & 1), 2 * (y - 1) + (k >> 1)
            base = re.match(r"\w+", new)[0]
            new = alias.get(base, base) + new[len(base):]
            inst = f"u_logic/u_{name}/" + re.sub(r"\[(\d+)\]", r"_\1", new)
            place.append(f"{inst} X{x}Y{y}_S{k}.FF{xy}")
            if inst in unplace:
                continue
            ucf.append(f'INST "{inst}" LOC = "SLICE_X{site_x}Y{site_y}" | BEL = "FF{xy}";')
            placed += 1
if args.place:
    # the PicoBlaze's LUT RAMs in their stock slices too: the picoblaze block
    # file names each RAM cell (X7Y26_S0_G.m regs0.sx); a RAM64X1S takes two
    # slices and is placed by its lower one
    rams = {}
    for l in open(blk_dir / "picoblaze.blk"):
        m = re.match(r"X(\d+)Y(\d+)_S(\d)_[FG]\.m\s+(\w+)\.", l)
        if m:
            x, y, k = int(m[1]), int(m[2]), int(m[3])
            rams.setdefault(m[4], set()).add((sx[x] + (k & 1), 2 * (y - 1) + (k >> 1)))
    for base, sites in sorted(rams.items()):
        site_x, site_y = min(sites, key=lambda t: (t[1], t[0]))
        ucf.append(f'INST "u_logic/u_picoblaze/{base}/r" LOC = "SLICE_X{site_x}Y{site_y}";')
if place:
    # every named flip-flop's stock cell, for prove-ise.py
    (args.out / "place.txt").write_text("\n".join(place) + "\n")
hand = repo / "stage0" / "ise" / f"{args.fw}.ucf"
ucf.append(f"\n# {hand.relative_to(repo)}")
ucf.append(hand.read_text())
(args.out / "top.ucf").write_text("\n".join(ucf) + "\n")

srcs = []
for n in block_names:
    shutil.copy(module_file(n), args.out / f"{n}.v")
    srcs.append(f"{n}.v")
shutil.copy(repo / "stage0" / "ise" / "s3prims_ise.v", args.out / "s3prims_ise.v")
(args.out / "top.prj").write_text("".join(f"verilog work {n}\n" for n in srcs + ["s3prims_ise.v", "top.v"]))
(args.out / "top.name").write_text(top_name + "\n")      # the top module, for build-ise.sh
(args.out / "fw").write_text(args.fw + "\n")
# map options the firmware needs (FW5: the placer cost table that meets hold)
mopt = repo / "stage0" / "ise" / f"{args.fw}.map"
(args.out / "map.opts").write_text(mopt.read_text().split("#")[0].strip() + "\n" if mopt.exists() else "\n")
print(f"{args.out}: {len(pads)} pads, {len(brams)} block RAMs, {placed} flip-flops placed" + (f", no contents for {' '.join(missing)}" if missing else ""))
