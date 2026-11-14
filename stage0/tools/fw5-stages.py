#!/usr/bin/env python3
"""FW5-0918's extra crossing stage, for fw5-prove.sh.

    fw5-stages.py fix FW4/design.v FW5/design.v MATCH OUT.match OUT.names
    fw5-stages.py add BLOCK.blk NAMES

FW4 carries eight registers into the SD clock domain in one stage (mode
register -> stage -> consumers); FW5 carries them in two (mode register ->
stage 1 -> stage 2 -> consumers). belmatch.py pairs those chains by their
cones, which can land a stage off. "fix" pairs each FW4 mode register with
FW5's and FW4's stage with FW5's last, writes the repaired match, and names
FW5's first stages after FW4's (<reg>_i -> <reg>_s1, soft_rst ->
soft_rst_s1) as stage0/fw5-0918/sd_crossings.v does. "add" appends those
first stages and their names to the crossings block that blkmap.py carried
(blkmap.py takes only the bels that have a partner, and these have none).
"""
import sys, os, re, collections

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import carve

# the SD clock in each build, and the registers that gained a stage
SD = {'A': 'n_X0Y17c_BUFGMUX6_O', 'B': 'n_X13Y33c_BUFGMUX1_O'}
TARGET = re.compile(r'(cmd_index|cmd_check|cmd_with_data|cmd_timeout|blksize|bus_4bit|byte_alignment)_i(\[\d+\])?$'
                    r'|soft_rst$')


def src(d, net):
    while net not in d.producer and net in d.wires and re.fullmatch(r'\w+', d.wires[net]):
        net = d.wires[net]
    return d.producer.get(net)


def plain_sd(d, side, c):
    cc = d.cells[c]
    return cc.kind == 's3_ff' and cc.ins.get('CLK') == SD[side] and cc.ins.get('CE') == "1'b1"


def fix(a_path, b_path, match, out_match, out_names):
    A, B = carve.Design(a_path), carve.Design(b_path)
    ab = {a: b for a, b in (l.split() for l in open(match)) if a != '-' and b != '-'}
    names = carve.read_block(os.path.join(here, '../../stage0/fw4/blocks/sd_crossings.blk'), A)[3]
    # FW5 chains: a plain SD stage fed by a plain SD stage fed by a mode register
    chain = {}
    for c in B.live_cells:
        if not plain_sd(B, 'B', c):
            continue
        s1 = src(B, B.cells[c].ins['D'])
        if s1 and plain_sd(B, 'B', s1):
            m = src(B, B.cells[s1].ins['D'])
            if m and B.cells[m].kind == 's3_ff' and not plain_sd(B, 'B', m):
                chain[m] = (s1, c)
    ba = {b: a for a, b in ab.items()}
    s1names, report = {}, collections.Counter()
    for net, nm in names.items():
        if not TARGET.match(nm):
            continue
        sa = A.producer.get(net)
        if not sa or not plain_sd(A, 'A', sa):
            continue
        ma = src(A, A.cells[sa].ins['D'])
        # FW5's mode register: ma's partner if it heads a chain, else the head
        # of the chain that ma's or sa's partner sits in
        mb = ab.get(ma)
        if mb not in chain:
            cand = [m for m, (s1, s2) in chain.items() if mb in (s1, s2) or ab.get(sa) in (s1, s2, m)]
            if len(cand) != 1:
                report['unresolved'] += 1
                print('unresolved', nm, ma, mb, ab.get(sa), file=sys.stderr)
                continue
            mb = cand[0]
        s1, s2 = chain[mb]
        for x in (ma, sa):
            if x in ab:
                ba.pop(ab.pop(x), None)
        for y in (mb, s1, s2):
            if y in ba:
                ab.pop(ba.pop(y), None)
        ab[ma], ab[sa], ba[mb], ba[s2] = mb, s2, ma, sa
        s1names[B.cells[s1].outs[0]] = (re.sub(r'_i(\[\d+\])?$', r'_s1\1', nm)
                                        if re.search(r'_i(\[\d+\])?$', nm) else nm + '_s1')
        report['fixed'] += 1
    print(f"{report['fixed']} crossing bits repaired, {report['unresolved']} unresolved")
    with open(out_match, 'w') as f:
        for a, b in ab.items():
            f.write(f'{a} {b}\n')
        for a in A.cells:
            if a not in ab:
                f.write(f'{a} -\n')
        for b in B.cells:
            if b not in ba:
                f.write(f'- {b}\n')
    with open(out_names, 'w') as f:
        for n, nm in s1names.items():
            f.write(f'{n} {nm}\n')


def add(blk, names_file):
    add = [l.split() for l in open(names_file) if l.strip()]
    cells, names = open(blk).read().split('[names]\n')
    cn = [re.sub(r'^n_(X\d+Y\d+_S\d)_([XY])Q$', lambda m: f'{m.group(1)}.FF{m.group(2)}', n) for n, _ in add]
    with open(blk, 'w') as f:
        f.write(cells + ''.join(c + '\n' for c in cn) + '[names]\n' + names
                + ''.join(f'{n} {nm}\n' for n, nm in add))
    print(f'{len(add)} first stages added to {os.path.basename(blk)}')


if __name__ == '__main__':
    if sys.argv[1:2] == ['fix'] and len(sys.argv) == 7:
        fix(*sys.argv[2:])
    elif sys.argv[1:2] == ['add'] and len(sys.argv) == 4:
        add(*sys.argv[2:])
    else:
        sys.exit(__doc__)
