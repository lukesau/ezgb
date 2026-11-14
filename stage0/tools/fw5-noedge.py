#!/usr/bin/env python3
"""FW5-0918's design.v made comparable with FW4's, for belmatch.py and
equiv.sh (fw5-prove.sh runs them):

    fw5-noedge.py FW5/design.v OUT/design.v

Every edit is exact for FW5 without its console /RESET edge, and checked:

  - the edge (prev & !cur of the debounced /RESET register) leaves every
    LUT that reads both: the new INIT is the old one with cur = prev wherever
    prev & !cur, checked not to depend on prev or cur at all (the LUT used
    them only as the edge); those pins are tied high. The four LUTs found by
    hand are checked against their expected INITs
  - the SD soft-reset LUT X23Y25_S3.G is then a buffer of its G4 register:
    its SR loads take the register, as FW4's take its soft_rst register
  - the main reset X7Y25_S1.G is then constant 0: its loads take 1'b0
  - FW4 shares one constant-0 LUT between blocks where FW5 builds several:
    every load of a LUT that is 0 on every input (not a LUT RAM, whose INIT
    is only its start) moves to one of them
  - a carry mux whose select is the constant 1 never reads DI: DI becomes
    CONST_0, so the BX/BY pin it names is no input of its block

The design proved against is therefore FW5 minus the /RESET edge; the edge
is FW5's addition on its own (docs in stage0/docs/firmware-diff.md)."""
import re, sys
PREV, CUR = 'n_X11Y16_S3_YQ', 'n_X25Y15_IOI0_IQ1'
EXPECT = {('i_X7Y25_S1', 'G'): 0x0000, ('i_X10Y16_S1', 'F'): 0x0FFF,
          ('i_X23Y25_S3', 'G'): 0xFF00, ('i_X23Y26_S3', 'G'): 0xFFAA}
src = open(sys.argv[1]).read()
done = 0
for m in list(re.finditer(r"s3_slice #\(([^;]*?)\) (i_X\d+Y\d+_S\d) \(([^;]*?)\);", src)):
    params, inst, body = m.groups()
    newp, newb, hit = params, body, []
    for lut in ('F', 'G'):
        pins = [re.search(r'\.' + lut + str(i) + r'\(([^()]*)\)', body).group(1) for i in (1, 2, 3, 4)]
        if PREV not in pins or CUR not in pins:
            continue
        assert not re.search(r'\.' + lut + r'_(RAM|SRL)\(1\)', params), (inst, lut)
        ip, ic = pins.index(PREV), pins.index(CUR)
        old = int(re.search(r'\.' + lut + r"\(16'h([0-9A-F]+)\)", params).group(1), 16)
        new = 0
        for a in range(16):
            edge = (a >> ip & 1) and not (a >> ic & 1)
            new |= (old >> ((a | 1 << ic) if edge else a) & 1) << a
        for i in (ip, ic):
            assert all((new >> a & 1) == (new >> (a ^ 1 << i) & 1) for a in range(16)), (inst, lut, i, f'{old:04X}')
        if (inst, lut) in EXPECT:
            assert new == EXPECT[(inst, lut)], (inst, lut, f'{new:04X}')
        newp = newp.replace(f".{lut}(16'h{old:04X})", f".{lut}(16'h{new:04X})")
        for i in (ip, ic):
            newb = newb.replace(f'.{lut}{i + 1}({pins[i]})', f".{lut}{i + 1}(1'b1)", 1)
        hit.append(f'{inst}.{lut}: {old:04X} -> {new:04X}')
    if hit:
        src = src.replace(m.group(0), m.group(0).replace(params, newp, 1).replace(body, newb, 1), 1)
        done += len(hit)
        print(*hit, sep='\n')
print(done, 'LUTs lose the edge;', len(re.findall(r'\b' + PREV + r'\b', src)), 'mentions of prev left')
# with the edge gone, X23Y25_S3.G = G4
m = re.search(r"s3_slice #\([^;]*?\) i_X23Y25_S3 \(([^;]*?)\);", src)
g4 = re.search(r'\.G4\(([^()]*)\)', m.group(1)).group(1)
n = src.count('.SR(n_X23Y25_S3_Y)')
sr = src.replace('.SR(n_X23Y25_S3_Y)', f'.SR({g4})')
# X7Y25_S1.G is now constant 0: its loads take 1'b0, so the blocks it resets
# do not pull /RESET's register in as an input
k = len(re.findall(r'\((n_X7Y25_S1_Y)\)', sr))
sr = re.sub(r'\.(\w+)\(n_X7Y25_S1_Y\)', lambda m: m.group(0) if m.group(1) in ('Y',) else f".{m.group(1)}(1'b0)", sr)
# FW4 shares one constant-0 net between blocks where FW5 builds several
# constant LUTs: every load of a LUT that is 0 on every input moves to one of
# them, so a block's constant input is one net in both builds.
CANON = 'n_X24Y18_S3_X'
zero = set()
for m in re.finditer(r"s3_slice #\(([^;]*?)\) (i_X\d+Y\d+_S\d) \(([^;]*?)\);", sr):
    P, inst, body = m.groups()
    for lut, out in (('F', 'X'), ('G', 'Y')):
        mux = re.search(r'\.' + ('FXMUX' if out == 'X' else 'GYMUX') + r'\("(\w+)"\)', P)
        ram = re.search(r'\.' + lut + r'_(RAM|SRL)\(1\)', P)     # LUT RAM: INIT is only its start
        if not ram and re.search(r'\.' + lut + r"\(16'h0000\)", P) and (mux is None or mux.group(1) == lut):
            o = re.search(r'\.' + out + r'\(([^()]*)\)', body).group(1)
            if o: zero.add(o)
zero.discard(CANON)
assert CANON in {re.search(r'\.X\(([^()]*)\)', m.group(3)).group(1) for m in re.finditer(r"s3_slice #\(([^;]*?)\) (i_X24Y18_S3) \(([^;]*?)\);", sr)}
OUTP = ('X', 'Y', 'XQ', 'YQ', 'XB', 'YB', 'COUT', 'F5', 'FX', 'SHIFTOUT', 'DIG', 'O')
cnt = 0
def sub(m):
    global cnt
    if m.group(1) in OUTP or m.group(2) not in zero: return m.group(0)
    cnt += 1
    return f'.{m.group(1)}({CANON})'
sr = re.sub(r'\.(\w+)\((n_\w+)\)', sub, sr)
print(f'{cnt} loads of {len(zero)} other constant-0 LUTs moved to {CANON}')
# a carry mux whose select is the constant 1 (CYSELF/CYSELG = 1) passes its
# carry-in and never reads DI: make DI the constant 0, so the BX/BY pin it
# names is not an input of the block that holds the mux
ncy = 0
def cy(m):
    global ncy
    P = m.group(1)
    for f in ('F', 'G'):
        if re.search(r'\.CYSEL' + f + r'\(1\)', P) and not re.search(r'\.CY0' + f + r'\("CONST_[01]"\)', P):
            P = re.sub(r'\.CY0' + f + r'\("\w+"\)', f'.CY0{f}("CONST_0")', P)
            ncy += 1
    return 's3_slice #(' + P + ') ' + m.group(2)
sr = re.sub(r"s3_slice #\(([^;]*?)\) (i_X\d+Y\d+_S\d \()", cy, sr)
print(f'{ncy} unused carry DI sources set to CONST_0')
open(sys.argv[2], 'w').write(sr)
print(f'{n} SR pins of n_X23Y25_S3_Y moved to {g4}, {k - 1} loads of n_X7Y25_S1_Y tied to 0')
