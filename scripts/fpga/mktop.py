#!/usr/bin/env python3
"""Stitch the readable blocks into a top level.

    scripts/fpga/mktop.py DESIGN.v BLOCK.blk... -o OUT.v [--suffix _ref]

Writes two modules (fw4_ by default, --prefix fw5 for FW5). fw4_logic instantiates every block and has as ports
the nets that cross between the slice logic and everything else (pads,
block RAMs, clock buffers, the DCM, the DNA port, the ICAP): the same
ports carve.py gives a block of every live slice bel, so the two can be
proved equivalent. fw4_top wraps it with those primitives, copied from
DESIGN.v as they are wired there, under the pads as ports.

Blocks connect to each other and to the primitives by the design's net
names: each block port is a design net (its [names] entry is only what
the block calls it), so no block needs to agree with another on names.
--suffix instantiates <block><suffix> instead of <block>, for a top over
the carved reference modules. Two blocks may carry the same cell (FW5
shares a few); the first drives its net and the other copy's output is
left unconnected.
"""
import sys, os, re, argparse
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import carve

ap = argparse.ArgumentParser()
ap.add_argument('design')
ap.add_argument('blocks', nargs='+')
ap.add_argument('-o', '--out', required=True)
ap.add_argument('--suffix', default='')
ap.add_argument('--prefix', default='fw4', help='module names <prefix>_logic and <prefix>_top')
ap.add_argument('--strip', help='write a yosys script renaming every block-internal net u_<block>.<net> to <net>')
args = ap.parse_args()

d = carve.Design(args.design)
whole_cells = carve.expand_cell('*', d, '*')
_, whole = carve.carve(d, 'all', whole_cells, {})
ext_in, ext_out, ext_inout = whole['in_nets'], whole['out_nets'], whole['inout_nets']

blocks = []
for path in args.blocks:
    name, desc, cells, names = carve.read_block(path, d)
    _, info = carve.carve(d, name, cells, names)
    blocks.append((name, info))

driven, spare = {}, {}
for name, info in blocks:
    for n in info['out_nets'] + info['inout_nets']:
        if n in driven:
            # two blocks carry the same cell (FW5 shares a few between
            # blocks): the first drives the net, the copy's output is left
            # on a wire of its own
            other = dict(blocks)[driven[n]]
            if d.root_driver(n) not in info['cells'] or d.root_driver(n) not in other['cells']:
                sys.exit(f"{n} is driven by both {driven[n]} and {name}")
            spare[(name, n)] = f"{n}__{name}"
            continue
        driven[n] = name
claimed = {c for _, info in blocks for c in info['cells']}
missing = [c for c in whole_cells if c not in claimed]
if missing:
    sys.exit(f"{len(missing)} live slice bels are in no block: {' '.join(missing[:5])} ...")

def port_expr(name, info):
    """connection list for one block: port name -> net expression"""
    sp = lambda n: spare.get((name, n), n)
    conns = []
    done = set()
    for n in info['in_nets'] + info['out_nets'] + info['inout_nets']:
        pname = info['ren'].get(n, n)
        m = re.fullmatch(r'(\w+)\[(\d+)\]', pname)
        if m:
            base = m.group(1)
            if base in done:
                continue
            done.add(base)
            bits = info['vec'][base]
            hi, lo = max(bits), min(bits)
            parts = [sp(bits[k]) if k in bits else "1'b0" for k in range(hi, lo - 1, -1)]
            conns.append(f".{base}({{{', '.join(parts)}}})" if len(parts) > 1 else f".{base}({parts[0]})")
        else:
            if (name, n) not in spare:      # a spare copy's output stays unconnected
                conns.append(f".{pname}({n})")
    return conns

out = [f"// {args.prefix}_top / {args.prefix}_logic: the readable blocks stitched together by scripts/fpga/mktop.py; do not edit",
       f"// blocks: {' '.join(name for name, _ in blocks)}", ""]
# ---- the logic
out.append(f"module {args.prefix}_logic (")
plist = [f"input {n}" for n in ext_in] + [f"output {n}" for n in ext_out] + [f"inout {n}" for n in ext_inout]
out.append('    ' + ',\n    '.join(plist))
out.append(');')
ext = set(ext_in) | set(ext_out) | set(ext_inout)
internal = sorted({n for _, info in blocks for n in info['in_nets'] + info['out_nets'] + info['inout_nets']} - ext)
undriven = [n for n in internal if n not in driven and not carve.is_const(n)]
if undriven:
    sys.exit(f"nets read by a block, driven by none, and not primitive-facing: {' '.join(undriven[:8])}")
vec_spares = {spare[(name, n)] for name, info in blocks for n in info['out_nets']
              if (name, n) in spare and '[' in info['ren'].get(n, n)}
for n in internal + sorted(vec_spares):
    out.append(f"wire {n};")
for name, info in blocks:
    out.append(f"{name}{args.suffix} u_{name} (" + ', '.join(port_expr(name, info)) + ");")
out.append("endmodule")
out.append("")
# ---- the top: the design's primitives around the logic
src = open(args.design).read().split('\n')
header = [l for l in src if l.startswith('module ') or l.startswith('    inout ')]
mod = header[0].replace('fpga_top', f'{args.prefix}_top')
out.append(mod)
out.append(header[1])
out.append(');')
inst_re = re.compile(r'^(s3_\w+)\b')
prims = [l for l in src if inst_re.match(l) and not l.startswith('s3_slice')]
wires = [l for l in src if l.startswith('wire ')]
text = '\n'.join(prims + wires)
used = set(re.findall(r'\b[A-Za-z_]\w*\b', text)) | ext
decl_done = set()
for l in wires:
    m = re.match(r'wire\s+(\[[^\]]+\]\s+)?(\w+)\s*(=|;)', l)
    if not m:
        out.append(l); continue
    n = m.group(2)
    if m.group(3) == '=' and n in ext_out:
        continue        # the slice logic drives this alias itself (a block owns the assign)
    if n in used or m.group(3) == '=':
        out.append(l); decl_done.add(n)
for n in sorted(ext):
    if n not in decl_done and n not in d.ports:
        out.append(f"wire {n};")
out.append(f"{args.prefix}_logic u_logic (" + ', '.join(f".{n}({n})" for n in ext_in + ext_out + ext_inout) + ");")
out.extend(prims)
out.append("endmodule")
open(args.out, 'w').write('\n'.join(out) + '\n')
if args.strip:
    with open(args.strip, 'w') as f:
        done = set()        # a cell two blocks carry: the first copy's net takes the name
        for name, info in blocks:
            for n in info['internal']:
                pname = info['ren'].get(n, n)
                if '[' not in pname and n not in done:
                    f.write(f"rename \\u_{name}.{pname} \\{n}\n")
                    done.add(n)
print(f"{len(blocks)} blocks, {len(ext_in)} inputs, {len(ext_out)} outputs, {len(ext_inout)} inouts of the logic; {len(internal)} nets between blocks; {len(prims)} primitives")
