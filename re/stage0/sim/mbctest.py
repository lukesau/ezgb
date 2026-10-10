#!/usr/bin/env python3
"""MBC tests for gb_mbc.vh.
  mbctest.py gen TYPE DIR   write u9.img/u4.img (tagged), ops.hex, meta.json
  mbctest.py check DIR      compare DIR/game.log with the MBC model
TYPE: none mbc1 mbc1m mbc2 mbc3 mbc5. Every 16 KB ROM bank starts with its
number (lo, hi) and every 8 KB page of U4 with its page number and $5A, so a
read names the physical bank it hit. ROM checks are exact; save-RAM reads
are reported as (logical bank -> U4 page) for the mapping to be read off."""
import json, os, sys

CODE = dict(none=0, mbc1=1, mbc2=2, mbc3=3, mbc5=4, mbc1m=5, mbc3rtc=0x83, mbc5mask=4, mbc5d4=4, mbc5d34=4)
ROMMASK = dict(none=0x001, mbc1=0x07F, mbc2=0x00F, mbc3=0x07F, mbc5=0x1FF, mbc1m=0x03F, mbc3rtc=0x07F, mbc5mask=0x00F, mbc5d4=0x1FF, mbc5d34=0x1FF)
RAMMASK = dict(none=0, mbc1=3, mbc2=0, mbc3=3, mbc5=0xF, mbc1m=3, mbc3rtc=3, mbc5mask=0xF, mbc5d4=0xF, mbc5d34=0xF)
BASE = dict(mbc3rtc='mbc3', mbc5mask='mbc5', mbc5d4='mbc5', mbc5d34='mbc5')
# variants: RTC flag set, small ROM mask, $7FD4 (and $7FD3) written nonzero

def rom_tag(b, o):
    return b & 0xFF if o == 0 else b >> 8 if o == 1 else (o ^ (o >> 8) ^ b) & 0xFF

def ram_tag(p, o):
    return p & 0xFF if o == 0 else 0x5A if o == 1 else (o ^ (o >> 8) ^ p ^ 0x3C) & 0xFF

class Model:
    """The cart's MBC behavior as simulated on FW4, FW5-0731 and FW5-0918
    (identical on all three): Pan Docs MBC1/3/5 except that MBC1 keeps the
    ROM upper bits and the RAM bank in separate registers ($4000 in mode 0
    writes the first, in mode 1 the second) and never banks $0000-$3FFF;
    MBC2 has a 5-bit bank register that the ROM mask doesn't cover and
    enables RAM only from $0000-$1FFF; MBC1 multicart has no RAM banking.
    Physical bank = logical & ROM mask, except MBC2."""
    def __init__(s, t):
        s.mask = ROMMASK[t]; t = BASE.get(t, t)
        s.t, s.lo, s.hi, s.mode, s.ram_en, s.ramb, s.romhi = t, 1, 0, 0, False, 0, 0
    def write(s, a, v):
        t = s.t
        if t == 'none': return
        if t == 'mbc2':
            if a < 0x2000: s.ram_en = (v & 0xF) == 0xA
            elif a < 0x4000 and a & 0x100: s.lo = (v & 0x1F) or 1
            return
        if a < 0x2000: s.ram_en = (v & 0xF) == 0xA
        elif a < 0x4000:
            if t == 'mbc5':
                if a < 0x3000: s.lo = v
                else: s.hi = v & 1
            elif t == 'mbc3': s.lo = (v & 0x7F) or 1
            elif t == 'mbc1': s.lo = (v & 0x1F) or 1
            elif t == 'mbc1m': s.lo = (v & 0x1F) or 1
        elif a < 0x6000:
            if t == 'mbc5': s.ramb = v & 0xF
            elif t == 'mbc3': s.ramb = v
            elif t == 'mbc1':
                if s.mode: s.ramb = v & 3
                else: s.romhi = v & 3
            else: s.ramb = v & 3
        elif a < 0x8000:
            if t in ('mbc1', 'mbc1m'): s.mode = v & 1
    def rom_bank(s, a):
        t = s.t
        if t == 'none': b = 0 if a < 0x4000 else 1
        elif t == 'mbc5': b = 0 if a < 0x4000 else (s.hi << 8) | s.lo
        elif t == 'mbc2': return 0 if a < 0x4000 else s.lo
        elif t == 'mbc3': b = 0 if a < 0x4000 else s.lo
        elif t == 'mbc1': b = 0 if a < 0x4000 else (s.romhi << 5) | (s.lo & 0x1F)
        else:
            sh = 5 if t == 'mbc1' else 4
            lo = s.lo & (0x1F if t == 'mbc1' else 0xF)
            b = ((s.ramb & 3) << sh if s.mode else 0) if a < 0x4000 else ((s.ramb & 3) << sh) | lo
        return b & s.mask
    def ram_bank(s):
        if s.t == 'mbc1m': return 0
        if s.t == 'mbc1': return s.ramb & 3 if s.mode else 0
        if s.t == 'mbc2': return 0
        return s.ramb

def fpga(r, v):
    return [(0x7F00, 0xE1), (0x7F10, 0xE2), (0x7F20, 0xE3), (r, v), (0x7FF0, 0xE4)]

def gen(t, d):
    os.makedirs(d, exist_ok=True)
    u9 = bytearray(8 << 20)
    for b in range(512):
        u9[b << 14:(b + 1) << 14] = bytes(rom_tag(b, o) for o in range(0x4000))
    u4 = bytearray(512 << 10)
    for p in range(64):
        u4[p << 13:(p + 1) << 13] = bytes(ram_tag(p, o) for o in range(0x2000))
    open(os.path.join(d, 'u9.img'), 'wb').write(u9)
    open(os.path.join(d, 'u4.img'), 'wb').write(u4)
    rm = ROMMASK[t]
    variant = t; t = BASE.get(t, t)
    ops = []
    W = lambda a, v: ops.append((0, a, v))
    R = lambda a: ops.append((1, a, 0))
    for a, v in (fpga(0x7FC0, 2) + fpga(0x7F37, CODE[variant]) + fpga(0x7FC4, RAMMASK[variant]) +
                 (fpga(0x7FD3, 0x03) if variant == 'mbc5d34' else []) +
                 (fpga(0x7FD4, 0x05) if variant in ('mbc5d4', 'mbc5d34') else []) +
                 fpga(0x7FC1, rm & 0xFF) + fpga(0x7FC2, rm >> 8) + fpga(0x7FC3, 0x5C)):
        W(a, v)
    for a, v in [(0x7F00, 0xE1), (0x7F10, 0xE2), (0x7F20, 0xE3), (0x7F31, 0), (0x7F32, 0), (0x7FF0, 0xE4),
                 (0x2000, 1), (0x3000, 0), (0x7F00, 0xE1), (0x7F10, 0xE2), (0x7F20, 0xE3), (0x7FE0, 0x80), (0x7FF0, 0xE4)]:
        W(a, v)
    ops.append((2, 0, 0))
    def rom_reads():
        for a in (0x0000, 0x0001, 0x1235, 0x4000, 0x4001, 0x5A5B, 0x7FFF): R(a)
    rom_reads()
    # ROM bank sweeps
    if t == 'mbc5':
        for v in (0, 1, 2, 0x55, 0xAA, 0xFF):
            W(0x2000, v); rom_reads()
        W(0x3000, 1)
        for v in (0, 0x23, 0xFF):
            W(0x2000, v); rom_reads()
        W(0x3000, 0)
    elif t == 'mbc2':
        for v in (0, 1, 5, 0xF, 0x13):
            W(0x2100, v); rom_reads()
        W(0x2000, 7); rom_reads()          # A8=0: RAM enable, bank unchanged
    if variant == 'mbc5mask':
        for x in (0x05, 0x15, 0x1F, 0xF3):
            W(0x2000, x); rom_reads()
    elif variant == 'mbc3rtc':
        # clock registers $08-$0C through the RAM window, latched by $6000 0->1
        W(0x0000, 0x0A)
        def rtc_read():
            for r_ in range(8, 13):
                W(0x4000, r_); R(0xA000)
        rtc_read()
        for _ in range(3):
            W(0x6000, 0); W(0x6000, 1); rtc_read()
            ops.append((3, 7000, 0))              # 7 ms: two RTC_TICK_NS ticks
        W(0x4000, 8); W(0xA000, 0x15); W(0x4000, 9); W(0xA000, 0x42)
        W(0x6000, 0); W(0x6000, 1); rtc_read()
        ops.append((3, 7000, 0))
        W(0x6000, 0); W(0x6000, 1); rtc_read()
        W(0x0000, 0x00)
    if variant in ('mbc5mask', 'mbc3rtc'): pass
    elif t in ('mbc1', 'mbc1m', 'mbc3', 'none'):
        for v in (0, 1, 2, 0x1F, 0x20, 0x21, 0x55, 0x7F):
            W(0x2000, v); rom_reads()
        if t in ('mbc1', 'mbc1m'):
            W(0x2000, 0x03)
            for hi in (1, 2, 3):
                W(0x4000, hi); rom_reads()
            W(0x6000, 1); rom_reads()
            W(0x4000, 2); rom_reads()
            W(0x6000, 0); W(0x4000, 0); rom_reads()
    # save RAM: reads before enabling, then per bank read, write, read back
    for a in (0xA000, 0xA001): R(a)
    W(0x0000, 0x0A)
    banks = {'mbc5': range(16), 'mbc3': range(4), 'mbc1': range(4), 'mbc1m': range(4)}.get(t, [0])
    if t in ('mbc1', 'mbc1m'): W(0x6000, 1)
    for b in banks:
        if t not in ('mbc2', 'none'): W(0x4000, b)
        for a in (0xA000, 0xA001, 0xA123, 0xBFFF): R(a)
        W(0xA010, 0xC0 | b); R(0xA010)
    if t in ('mbc1', 'mbc1m'): W(0x6000, 0)
    W(0x0000, 0x00)
    for a in (0xA000, 0xA010): R(a)
    with open(os.path.join(d, 'ops.hex'), 'w') as f:
        for k, a, v in ops: f.write('%02X%04X%02X\n' % (k, a, v))
    json.dump(dict(type=variant), open(os.path.join(d, 'meta.json'), 'w'))
    print(t, len(ops), 'ops')

def gen_d34(d):
    # $7FD3/$7FD4 probe: snapshot after each write (op 04) for snapdiff
    os.makedirs(d, exist_ok=True)
    ops, tag = [], 0
    def snap():
        nonlocal tag
        ops.append((4, 0, tag)); tag += 1
    snap()
    for r, v in ((0x7FD4, 0x5A), (0x7FD4, 0xA5), (0x7FD3, 0x11), (0x7FD4, 0x00), (0x7FD3, 0x00), (0x7FD4, 0x01)):
        for a, x in fpga(r, v): ops.append((0, a, x))
        snap()
    with open(os.path.join(d, 'ops.hex'), 'w') as f:
        for k, a, v in ops: f.write('%02X%04X%02X\n' % (k, a, v))

PROBES = {
    # MBC1: RAM bank in mode 0, upper bits under a 5-bit ROM mask
    'mbc1x': dict(code=1, rom=0x01F, ram=3, ops=[
        ('w', 0x0000, 0x0A), ('w', 0x6000, 0), ('w', 0x4000, 2), ('r', 0xA000), ('r', 0x4000), ('r', 0x4001), ('r', 0x0000),
        ('w', 0x2000, 0x05), ('r', 0x4000), ('w', 0x4000, 1), ('r', 0x4000), ('r', 0xA000),
        ('w', 0x6000, 1), ('r', 0xA000), ('r', 0x0000), ('r', 0x4000), ('w', 0x4000, 3), ('r', 0xA000), ('r', 0x0000), ('r', 0x4000),
        ('w', 0x6000, 0), ('r', 0xA000), ('r', 0x4000), ('w', 0x2000, 0x20), ('r', 0x4000), ('w', 0x2000, 0x00), ('r', 0x4000)]),
    # MBC2: bank register width against the mask, bank 0, A8 decode, RAM bytes
    'mbc2x': dict(code=2, rom=0x00F, ram=0, ops=[
        ('w', 0x2100, 0x1F), ('r', 0x4000), ('w', 0x2100, 0x10), ('r', 0x4000), ('w', 0x2100, 0x00), ('r', 0x4000),
        ('w', 0x3100, 0x07), ('r', 0x4000), ('w', 0x2000, 0x0A), ('r', 0xA000), ('w', 0xA001, 0x5C), ('r', 0xA001), ('r', 0xA201),
        ('w', 0x0100, 0x00), ('r', 0xA000), ('w', 0x0000, 0x00), ('r', 0xA000)]),
    # MBC5 bank 0 and the 9th bit with a 9-bit mask
    'mbc5x': dict(code=4, rom=0x1FF, ram=0xF, ops=[
        ('w', 0x2000, 0x00), ('r', 0x4000), ('w', 0x3000, 0x01), ('r', 0x4000), ('r', 0x4001), ('w', 0x3000, 0x03), ('r', 0x4001),
        ('w', 0x3000, 0x00), ('w', 0x2000, 0x80), ('r', 0x4000), ('w', 0x4000, 0x10), ('w', 0x0000, 0x0A), ('r', 0xA000)]),
    # MBC3 clock: halt bit, DL/DH writes, day overflow (3 ms ticks)
    'rtcx': dict(code=0x83, rom=0x07F, ram=3, ops=[
        ('w', 0x0000, 0x0A),
        ('w', 0x4000, 0x0C), ('w', 0xA000, 0x40),                       # DH: halt
        ('w', 0x6000, 0), ('w', 0x6000, 1), ('w', 0x4000, 0x08), ('r', 0xA000),
        ('d', 7000), ('w', 0x6000, 0), ('w', 0x6000, 1), ('r', 0xA000),
        ('w', 0x4000, 0x0C), ('w', 0xA000, 0x01),                       # DH: run, day bit 8
        ('w', 0x4000, 0x0B), ('w', 0xA000, 0xFF),                       # DL: day 511
        ('w', 0x4000, 0x0A), ('w', 0xA000, 0x17),                       # H 23
        ('w', 0x4000, 0x09), ('w', 0xA000, 0x3B),                       # M 59
        ('w', 0x4000, 0x08), ('w', 0xA000, 0x3A),                       # S 58
        ('w', 0x6000, 0), ('w', 0x6000, 1),
        ('w', 0x4000, 0x08), ('r', 0xA000), ('w', 0x4000, 0x09), ('r', 0xA000), ('w', 0x4000, 0x0A), ('r', 0xA000),
        ('w', 0x4000, 0x0B), ('r', 0xA000), ('w', 0x4000, 0x0C), ('r', 0xA000),
        ('d', 10000), ('w', 0x6000, 0), ('w', 0x6000, 1),
        ('w', 0x4000, 0x08), ('r', 0xA000), ('w', 0x4000, 0x09), ('r', 0xA000), ('w', 0x4000, 0x0A), ('r', 0xA000),
        ('w', 0x4000, 0x0B), ('r', 0xA000), ('w', 0x4000, 0x0C), ('r', 0xA000)]),
    # kernel mode (no launch): $7FC0=3 save window, $4000 = page 0..63
    'kwin': dict(nolaunch=True, ops=[('k', 0x7FC0, 3)] + [x for p_ in list(range(0, 64)) + [0x40, 0x41, 0x80, 0xFF]
             for x in (('w', 0x4000, p_), ('r', 0xA000), ('r', 0xA001), ('r', 0xBFFF))] +
             [('w', 0x4000, 0x11), ('w', 0xA123, 0x77), ('r', 0xA123), ('w', 0x4000, 0x05), ('w', 0xBFFE, 0x66)]),
}

def gen_probe(name, d):
    os.makedirs(d, exist_ok=True)
    P = PROBES[name]
    ops = []
    for a, v in ([] if P.get('nolaunch') else fpga(0x7FC0, 2) + fpga(0x7F37, P['code']) + fpga(0x7FC4, P['ram']) +
                 fpga(0x7FC1, P['rom'] & 0xFF) + fpga(0x7FC2, P['rom'] >> 8) + fpga(0x7FC3, 0x5C)):
        ops.append((0, a, v))
    for a, v in [] if P.get('nolaunch') else [(0x7F00, 0xE1), (0x7F10, 0xE2), (0x7F20, 0xE3), (0x7F31, 0), (0x7F32, 0), (0x7FF0, 0xE4),
                 (0x2000, 1), (0x3000, 0), (0x7F00, 0xE1), (0x7F10, 0xE2), (0x7F20, 0xE3), (0x7FE0, 0x80), (0x7FF0, 0xE4)]:
        ops.append((0, a, v))
    if not P.get('nolaunch'): ops.append((2, 0, 0))
    for o in P['ops']:
        if o[0] == 'k':
            for a, v in fpga(o[1], o[2]): ops.append((0, a, v))
            continue
        ops.append((0, o[1], o[2]) if o[0] == 'w' else (3, o[1], 0) if o[0] == 'd' else (1, o[1], 0))
    with open(os.path.join(d, 'ops.hex'), 'w') as f:
        for k, a, v in ops: f.write('%02X%04X%02X\n' % (k, a, v))
    json.dump(dict(type=name, probe=True, nolaunch=bool(P.get('nolaunch'))), open(os.path.join(d, 'meta.json'), 'w'))

def probe_report(d):
    # each read named by what it hit: ROM bank (from the tag) or U4 page
    started = json.load(open(os.path.join(d, 'meta.json'))).get('nolaunch', False)
    for line in open(os.path.join(d, 'game.log')):
        p = line.split()
        if not p: continue
        if p[0] == 'X': started = True; continue
        if not started or p[0] not in ('W', 'R') or len(p) < 3: continue
        a, v = int(p[1], 16), int(p[2], 16)
        if p[0] == 'W': print(f'  W ${a:04x}={v:02x}'); continue
        if json.load(open(os.path.join(d, 'meta.json')))['type'].startswith('rtc'):
            print(f'  R ${a:04x} = {v:02x}'); continue
        o = a & 0x3FFF
        if a < 0x8000:
            banks = [b for b in range(512) if rom_tag(b, o) == v]
            what = 'bank ' + '/'.join(f'{b:#x}' for b in banks[:2]) if banks else 'no bank'
        else:
            o = a & 0x1FFF
            pages = [q for q in range(64) if ram_tag(q, o) == v]
            what = ('U4 page ' + '/'.join(str(q) for q in pages[:3])) if pages else 'not a U4 tag'
        print(f'  R ${a:04x} = {v:02x}  {what}')

def check(d):
    if json.load(open(os.path.join(d, 'meta.json'))).get('probe'): return probe_report(d)
    t = json.load(open(os.path.join(d, 'meta.json')))['type']
    m = Model(t)
    started, bad, n, ram = False, 0, 0, []
    for line in open(os.path.join(d, 'game.log')):
        p = line.split()
        if not p: continue
        if p[0] == 'X': started = True; continue
        if p[0] not in ('W', 'R') or len(p) < 3: continue
        a, v = int(p[1], 16), int(p[2], 16)
        if not started: continue
        if p[0] == 'W': m.write(a, v); continue
        if a < 0x8000:
            b = m.rom_bank(a); want = rom_tag(b, a & 0x3FFF); n += 1
            if v != want:
                bad += 1
                got = [x for x in range(512) if rom_tag(x, a & 0x3FFF) == v]
                print(f'ROM ${a:04x} = {v:02x}, want {want:02x} (bank {b:#x}); matches banks {[hex(x) for x in got[:6]]}')
        else:
            ram.append((m.ram_en, m.ram_bank(), a, v))
            if m.t == 'mbc3' and m.ram_bank() >= 8: print(f'  RTC reg {m.ram_bank():#x} = {v:02x}')
    print(f'{t}: {n} ROM reads, {bad} wrong')
    for en, b, a, v in ram:
        note = ''
        if a & 0x1FFF == 0: note = f'U4 page {v}?' if True else ''
        print(f'  RAM en={int(en)} bank={b:2} ${a:04x} = {v:02x} {note}')
    out = os.path.join(d, 'u4.out')
    if os.path.exists(out):
        u4o, u4i = open(out, 'rb').read(), open(os.path.join(d, 'u4.img'), 'rb').read()
        diff = [(i, u4i[i], u4o[i]) for i in range(len(u4i)) if u4i[i] != u4o[i]]
        print(f'  U4 changed at {len(diff)} bytes:', ', '.join(f'{i:#07x} (page {i >> 13}+{i & 0x1FFF:#x}) {o:02x}->{n_:02x}' for i, o, n_ in diff[:24]))

if __name__ == '__main__':
    if sys.argv[1] == 'gen' and sys.argv[2] == 'd34': gen_d34(sys.argv[3])
    elif sys.argv[1] == 'gen' and sys.argv[2] in PROBES: gen_probe(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == 'gen': gen(sys.argv[2], sys.argv[3])
    else: check(sys.argv[2])
