#!/usr/bin/env python3
"""Build the floorplan viewer: where each firmware's logic and wires sit on the chip.

    scripts/fpga/floorplan.py [-o fpga/floorplan/floorplan.html]

For each firmware it reads netlist.jsonl, design.v and pins.txt from fpga/<fw>/,
the block files, and the route dump from `s3trace --routes` (run here if
missing). The output is one self-contained HTML file with the design data in
it, so it belongs under the untracked fpga/ like everything else derived from
EZ Flash's bitstreams.
"""
import argparse, collections, glob, json, math, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOP = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import carve

FIRMWARES = [
    # key, title, cart image, block files
    ('fw4', 'FW4', 'fw4-updater.bin', 'stage0/blocks/*.blk'),
    ('fw5-0918', 'FW5 0918', 'fw5-0918.bin', 'fpga/fw5-all/blk/*.blk'),
]

# (subsystem, family) per block. Subsystem 3 is the neutral group.
SUBSYSTEMS = ['SD controller', 'PicoBlaze', 'Game Boy, memory, RTC', 'Clocks and reset']
FAMILIES = ['SD registers', 'SD command', 'SD data', 'PicoBlaze', 'Game Boy bus',
            'pSRAM', 'RTC', 'Clocks and reset']
BLOCKS = {
    'sd_controller_wb': (0, 0), 'sd_clock_divider': (0, 0), 'sd_crossings': (0, 0),
    'sd_fifo_filler': (0, 0), 'sd_fifos': (0, 0), 'sd_mem_path': (0, 0),
    'sd_cmd_master': (0, 1), 'sd_cmd_serial': (0, 1),
    'sd_data_master': (0, 2), 'sd_data_serial': (0, 2),
    'picoblaze': (1, 3), 'picoblaze_ports': (1, 3), 'pb_periph': (1, 3), 'pb_timer': (1, 3),
    'gb_bus': (2, 4), 'gb_data_out': (2, 4), 'gb_regs': (2, 4), 'unlock': (2, 4), 'fw5_7fxx': (2, 4),
    'psram_ctrl': (2, 5), 'p51_latch': (2, 5),
    'rtc_bridge': (2, 6), 'mbc3_clock': (2, 6),
    'clocks': (3, 7), 'soft_reset': (3, 7), 'reset_debounce': (3, 7),
}
BEL_INDEX = {'F': 0, 'G': 1, 'FFX': 2, 'FFY': 3, 'F5': 4, 'FX': 5, 'CYF': 6, 'CYG': 7, 'XORF': 8, 'XORG': 9}
BEL_NAMES = ['F', 'G', 'FFX', 'FFY', 'F5', 'FX', 'CYF', 'CYG', 'XORF', 'XORG']
PRIM = {'IOI': 10, 'BRAM': 11, 'DCM': 12, 'BUFGMUX': 13}
PRIM_OTHER = 14
# wire classes for the segments: 0 short (OMUX), 1 double, 2 hex, 3 long, 4 clock, 5 other
def wire_class(wire):
    w = wire.split('.', 1)[-1]
    if w.startswith('OMUX') or w.startswith('OUT'): return 0
    if w.startswith('DBL'): return 1
    if w.startswith('HEX'): return 2
    if w.startswith(('LH', 'LV')): return 3
    if w.startswith(('GCLK', 'HCLK', 'HROW')): return 4
    return 5
CLASS_NAMES = ['output mux', 'double', 'hex', 'long', 'clock', 'other']

TILE = re.compile(r'D0X(\d+)Y(\d+)')


def tile_xy(s):
    m = TILE.match(s)
    return int(m[1]), int(m[2])


def routes_path(key, image):
    path = f'{TOP}/fpga/floorplan/{key}.routes.jsonl'
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        subprocess.check_call([f'{TOP}/scripts/fpga/s3decode/target/release/s3trace',
                               '--db', f'{TOP}/fpga/db/spartan3.zstd', f'{TOP}/fpga/cart/{image}',
                               '--routes', path])
    return path


def build(key, title, image, blockglob):
    d = carve.Design(f'{TOP}/fpga/{key}/design.v')
    bel_block, block_desc, shared, name_of = {}, {}, set(), {}
    for path in sorted(glob.glob(f'{TOP}/{blockglob}')):
        if path.endswith('.sim.blk'):
            continue
        name, desc, cells, names = carve.read_block(path, d)
        block_desc[name] = desc
        for c in cells:
            if c in bel_block:
                shared.add(c)
            else:
                bel_block[c] = name
        for net, new in names.items():
            cell = d.root_driver(net)
            if cell and cell not in ('pad', 'const'):
                name_of.setdefault(cell, new)
    unknown = sorted(set(block_desc) - set(BLOCKS))
    if unknown:
        sys.exit(f'{key}: no subsystem for {unknown}')

    netlist = {}
    for line in open(f'{TOP}/fpga/{key}/netlist.jsonl'):
        r = json.loads(line)
        netlist[(r['tile'], r['bel'])] = r
    pads = {}
    for line in open(f'{TOP}/fpga/{key}/pins.txt'):
        m = re.match(r'(\S+)\s+(D0X\d+Y\d+)\.IOI\[(\d)\]\.PAD', line)
        if m:
            pads[(m[2], int(m[3]))] = m[1]

    sites, site_at = [], {}
    def site(x, y, s, b, cell):
        k = (x, y, s, b)
        if k in site_at:
            return site_at[k]
        block = bel_block.get(cell)
        tt = None
        r = netlist.get((f'D0X{x}Y{y}.BEL', f'SLICE[{s}]'))
        if b < 2 and r:
            tt = r['attrs'].get('F' if b == 0 else 'G')
        live = cell in d.live_cells
        info = None
        if b in (2, 3) and live:
            # where the flip-flop's data comes from when it stays inside the slice
            root = d.root_driver((carve.nets_of(d.cells[cell].ins.get('D', '')) or [''])[0])
            mm = re.match(rf'X{x}Y{y}_S{s}\.(\w+)$', root or '')
            # the D mux on BX or BY means the data came in on a routed pin
            routed = r and r['attrs'].get('DXMUX' if b == 2 else 'DYMUX') in ('BX', 'BY')
            info = mm[1] if mm and not routed else None
        sites.append({'x': x, 'y': y, 's': s, 'b': b, 'block': block, 'name': name_of.get(cell),
                      'tt': tt, 'live': live, 'info': info})
        site_at[k] = len(sites) - 1
        return site_at[k]

    # every live bel gets a site, so the map shows them with no route attached
    for cell in d.live_cells:
        m = re.match(r'X(\d+)Y(\d+)_S(\d)\.(\w+)$', cell)
        if m and m[4] in BEL_INDEX:
            site(int(m[1]), int(m[2]), int(m[3]), BEL_INDEX[m[4]], cell)

    SLICE_OUT_FALLBACK = {'X': 'F', 'Y': 'G', 'XQ': 'FFX', 'YQ': 'FFY'}
    def src_site(s):
        tile, bel, pin = s.split(':')
        x, y = tile_xy(tile)
        m = re.match(r'SLICE\[(\d)\]', bel)
        if m:
            sl = int(m[1])
            root = d.root_driver(f'n_X{x}Y{y}_S{sl}_{pin}')
            mm = re.match(rf'X{x}Y{y}_S{sl}\.(\w+)$', root or '')
            b = mm[1] if mm and mm[1] in BEL_INDEX else SLICE_OUT_FALLBACK.get(pin, 'F')
            return site(x, y, sl, BEL_INDEX[b], f'X{x}Y{y}_S{sl}.{b}')
        return prim_site(tile, bel, x, y)

    def sink_site(s):
        tile, bel, pin = s.split(':')
        x, y = tile_xy(tile)
        m = re.match(r'SLICE\[(\d)\]', bel)
        if m:
            sl = int(m[1])
            if pin[0] in 'FG' and pin[1:].isdigit():
                b = pin[0]
            elif pin == 'BX':
                b = 'FFX'
            elif pin == 'BY':
                b = 'FFY'
            else:
                x_live = f'X{x}Y{y}_S{sl}.FFX' in d.live_cells
                b = 'FFX' if x_live else 'FFY'
            return site(x, y, sl, BEL_INDEX[b], f'X{x}Y{y}_S{sl}.{b}')
        return prim_site(tile, bel, x, y)

    def prim_site(tile, bel, x, y):
        m = re.match(r'(\w+?)(?:\[(\d+)\])?$', bel)
        kind, idx = m[1], int(m[2] or 0)
        b = PRIM.get(kind, PRIM_OTHER)
        k = (x, y, idx, b) if b != PRIM_OTHER else (x, y, kind, b)
        if k in site_at:
            return site_at[k]
        label = f'{kind}[{m[2]}]' if m[2] else kind
        info, nm = None, None
        if b == PRIM['IOI']:
            info = pads.get((f'D0X{x}Y{y}', idx))
            nm = name_of.get(f'i_X{x}Y{y}_IOI{idx}')
        sites.append({'x': x, 'y': y, 's': idx, 'b': b, 'block': None, 'name': nm,
                      'tt': None, 'live': True, 'info': info, 'label': label})
        site_at[k] = len(sites) - 1
        return site_at[k]

    # one net per driving bel pin: the union of its sinks' paths
    nets, net_at = [], {}
    no_src = no_src_span = hops = 0
    span_max = collections.Counter()
    class_len = collections.Counter()
    for line in open(routes_path(key, image)):
        r = json.loads(line)
        if r['src'] is None:
            no_src += 1
            tiles = {tile_xy(h[0]) for h in r['hops']}
            no_src_span += len(tiles) > 1
            continue
        src = r['src']
        n = net_at.get(src)
        if n is None:
            n = {'pin': src.split(':')[2], 'site': src_site(src), 'segs': [], 'seg_at': {}, 'sinks': [], 'clock': False}
            net_at[src] = n
            nets.append(n)
        chain = list(reversed(r['hops']))   # source first
        hops += len(chain)
        path = []
        for a, b in zip(chain, chain[1:]):
            ax, ay = tile_xy(a[0])
            bx, by = tile_xy(b[0])
            cls = wire_class(a[1])
            if cls == 4:
                n['clock'] = True
            if (ax, ay) == (bx, by):
                continue
            k = (ax, ay, bx, by, a[1])
            i = n['seg_at'].get(k)
            if i is None:
                i = len(n['segs'])
                n['seg_at'][k] = i
                off = sum(map(ord, a[1].split('.', 1)[-1])) % 16
                n['segs'].append((ax, ay, bx, by, cls, off))
                span = math.hypot(bx - ax, by - ay)
                class_len[cls] += span
                span_max[cls] = max(span_max[cls], max(abs(bx - ax), abs(by - ay)))
            path.append(i)
        if any(wire_class(h[1]) == 4 for h in chain):
            n['clock'] = True
        n['sinks'].append((sink_site(r['sink']), r['sink'].split(':')[2], path))

    # block RAMs and pads are not in any block file; a RAM takes the block it talks to most
    talk = collections.defaultdict(collections.Counter)
    for n in nets:
        for s, _, _ in n['sinks']:
            a, b = sites[n['site']], sites[s]
            if a['block'] and b['b'] >= 10:
                talk[s][a['block']] += 1
            if b['block'] and a['b'] >= 10:
                talk[n['site']][b['block']] += 1
    bram_init = {os.path.basename(p)[2:].split('.')[0] for p in glob.glob(f'{TOP}/fpga/{key}/D0X*.DATA.mem')}
    for i, s in enumerate(sites):
        if s['b'] == PRIM['BRAM']:
            c = talk.get(i)
            if c:
                s['block'] = c.most_common(1)[0][0]
                s['inferred'] = True
            s['info'] = 'initialized contents' if f"X{s['x']}Y{s['y']}" in bram_init else 'no initial contents, runtime RAM'

    # counterpart key: the same named register in the same block
    keyed = collections.Counter((s['block'], s['name']) for s in sites if s['name'] and s['block'])

    block_names = sorted(set(block_desc), key=lambda n: (BLOCKS[n][1], n))
    stats = {}
    for n in block_names:
        pts = [(s['x'], s['y']) for s in sites if s['block'] == n and s['b'] < 10]
        if not pts:
            continue
        cx = sum(p[0] for p in pts) / len(pts)
        cy = sum(p[1] for p in pts) / len(pts)
        stats[n] = {
            'luts': sum(1 for s in sites if s['block'] == n and s['b'] < 2),
            'ffs': sum(1 for s in sites if s['block'] == n and s['b'] in (2, 3)),
            'cells': len(pts),
            'cx': round(cx, 2), 'cy': round(cy, 2),
            'bbox': [min(p[0] for p in pts), min(p[1] for p in pts), max(p[0] for p in pts), max(p[1] for p in pts)],
            'spread': round(sum(math.hypot(p[0] - cx, p[1] - cy) for p in pts) / len(pts), 2),
            'wire': 0.0,
        }
    for n in nets:
        b = sites[n['site']]['block']
        if b in stats and not n['clock']:
            stats[b]['wire'] += sum(math.hypot(s[2] - s[0], s[3] - s[1]) for s in n['segs'])
    for s in stats.values():
        s['wire'] = round(s['wire'])

    index = {n: i for i, n in enumerate(block_names)}
    out_sites = []
    for s in sites:
        unique = s['name'] and s['block'] and keyed[(s['block'], s['name'])] == 1
        out_sites.append([s['x'], s['y'], s['s'], s['b'], index.get(s['block'], -1), s['name'], s['tt'],
                          1 if s['live'] else 0, s.get('label'), s['info'],
                          1 if s.get('inferred') else 0, 1 if unique else 0])
    pins = sorted({p for n in nets for _, p, _ in n['sinks']})
    pin_index = {p: i for i, p in enumerate(pins)}
    out_nets = []
    for n in nets:
        g = [v for seg in n['segs'] for v in seg]
        k = [[s, pin_index[p], path] for s, p, path in n['sinks']]
        out_nets.append({'s': n['site'], 'p': n['pin'], 'c': 1 if n['clock'] else 0, 'g': g, 'k': k})

    live = set(d.live_cells)
    labeled = sum(1 for c in live if c in bel_block)
    summary = {
        'key': key, 'title': title,
        'live': len(live), 'labeled': labeled, 'multi': len(shared),
        'slices': len({(s['x'], s['y'], s['s']) for s in sites if s['b'] < 10 and s['live']}),
        'luts': sum(1 for s in sites if s['b'] < 2 and s['live']),
        'ffs': sum(1 for s in sites if s['b'] in (2, 3) and s['live']),
        'switches': hops, 'nets': len(nets),
        'segments': sum(len(n['segs']) for n in nets),
        'wire': {CLASS_NAMES[c]: round(v) for c, v in sorted(class_len.items())},
    }
    print(f'{key}: {summary}')
    print(f'{key}: longest straight span in tiles per wire class:',
          {CLASS_NAMES[c]: v for c, v in sorted(span_max.items())},
          f'| pins with no driver {no_src}, of which spanning tiles {no_src_span}')
    return {'summary': summary, 'blocks': block_names, 'desc': {n: block_desc[n] for n in block_names},
            'stats': stats, 'sites': out_sites, 'nets': out_nets, 'pins': pins}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-o', '--out', default=f'{TOP}/fpga/floorplan/floorplan.html')
    args = ap.parse_args()
    clb = sorted({tile_xy(json.loads(l)['tile']) for l in open(f'{TOP}/fpga/fw4/netlist.jsonl') if '"bel": "SLICE' in l})
    data = {
        'firmwares': [build(*f) for f in FIRMWARES],
        'clb': clb,
        'subsystems': SUBSYSTEMS, 'families': FAMILIES,
        'blockGroups': BLOCKS, 'bels': BEL_NAMES,
    }
    template = open(f'{HERE}/floorplan.template.html').read()
    payload = json.dumps(data, separators=(',', ':')).replace('</', '<\\/')
    html = template.replace('/*DATA*/null', payload)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    open(args.out, 'w').write(html)
    print(f'{args.out}: {len(html) / 1e6:.1f} MB')


if __name__ == '__main__':
    main()
