#!/usr/bin/env python3
"""Pack decomp/font12/font12.txt (ASCII-art glyphs, 10 columns x 12 rows) into the two
raw tables the 12px browser reads (docs/font12.md):

  decomp/font12/font12.bin          Font12 at 02:6000, the glyph bitmaps
  decomp/font12/font12-metrics.bin  Font12Metrics at 02:6978, advances,
                                    ink widths and the class-kerning matrix

Bitmaps: one entry per glyph, in sheet order (codes 0x20-0x7F, then the five
icons 0xC0-0xC4), 24 bytes each: 12 rows of a big-endian 16-bit word whose
top bits are the row's pixels, leftmost pixel in bit 15. Text glyphs are
left-trimmed: the sheet's blank columns left of the ink are dropped so the
first ink column is always bit 15 (the renderer places the pen at the ink,
there are no side bearings). Icons are not trimmed. Nothing here is 10
pixels wide any more except the icons: a glyph's ink width is what it is.

Metrics, for a proportional layout with kerning (a variable-width font, in
ROM-hack terms; advance widths and class kerning, in font terms):

  +0    adv[101]   pen advance after the glyph: ink width + GAP, or --space
                   for the space, or --icon-adv for the icons (that is also
                   where the name field starts: col 1 of DrawString12)
  +101  w[101]     ink width, 0 for the space; a glyph fits when x + w <= 160
  +202  lcol[101]  the glyph's left kerning class (column of the matrix)
  +303  rrow[101]  u16 LE: byte offset, from the start of this table, of the
                   glyph's right kerning class row
  +505  matrix     one row per right class, ceil(L/4) bytes of 2-bit entries,
                   entry l at byte l>>2, bits (l&3)*2; the value is how many
                   pixels the pen moves back before the next glyph

The kerning is optical, from the shapes: for a pair (a, b) placed at the
nominal advance, the gap between a's rightmost ink and b's leftmost ink is
measured row by row, and b is pulled left until the smallest per-row gap
is GAP, by at most --kmax pixels (that cap keeps `'.` from stacking). A
pair whose two glyphs share no ink rows kerns by the cap. Glyphs with the
same kerning behavior on a side share a class (like OpenType class
kerning), which is what makes the matrix ~1 KB instead of 96 x 96 bytes.
Class 0 on either side means "never kerns" (space, icons, digits). The
ten digits are tabular: one fixed 7 px cell and advance each, untrimmed and
unkerned, so numbers line up in columns and do not jitter as they change.

    scripts/font12-pack.py [-i sheet] [-o bitmaps] [-m metrics]
                           [--gap 2] [--kmax 2] [--space 5] [--icon-adv 12]
"""
import argparse
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_IN = os.path.join(ROOT, "decomp", "font12", "font12.txt")
DEFAULT_OUT = os.path.join(ROOT, "decomp", "font12", "font12.bin")
DEFAULT_METRICS = os.path.join(ROOT, "decomp", "font12", "font12-metrics.bin")
ORDER = list(range(0x20, 0x80)) + [0xC0, 0xC1, 0xC2, 0xC3, 0xC4]
ICONS = range(0xC0, 0xC5)
DIGITS = set(range(0x30, 0x3A))
DIGIT_X, DIGIT_W = 1, 7       # the digits' cell in the sheet: columns 1..7
SPACE = 0x20
ROWS = 12
SHEET_W = 10


def parse(path):
    blocks = {}
    cur = None
    for line in open(path):
        line = line.rstrip("\n")
        m = re.match(r"glyph 0x([0-9A-Fa-f]{2})\b", line)
        if m:
            cur = int(m.group(1), 16)
            blocks[cur] = []
        elif cur is not None and re.fullmatch(r"[.#]{%d}" % SHEET_W, line):
            blocks[cur].append(line)
    return blocks


class Glyph:
    """One glyph's trimmed rows and the per-row ink extents the kerning uses."""

    def __init__(self, code, rows):
        self.code = code
        cols = [i for r in rows for i, ch in enumerate(r) if ch == "#"]
        lo = min(cols) if cols and code not in ICONS else 0
        self.w = (max(cols) - lo + 1) if cols else 0
        if code in DIGITS:
            # tabular figures: every digit sits in the same DIGIT_W-wide cell
            # (sheet columns DIGIT_X ..), so it is not trimmed to its ink
            # ("1" keeps its side bearings) and all ten share one advance
            lo, self.w = DIGIT_X, DIGIT_W
        self.rows = [r[lo:] + "." * lo for r in rows]
        # per row: first and last ink column, None for a blank row
        self.lp = [r.index("#") if "#" in r else None for r in self.rows]
        self.rp = [r.rindex("#") if "#" in r else None for r in self.rows]

    def kerns(self):
        # digits never kern, on either side: columns of numbers line up
        return self.code not in ICONS and self.code not in DIGITS and self.w > 0


def kern(a, b, gap, kmax):
    """Pixels b moves left when it follows a (0..kmax)."""
    if not (a.kerns() and b.kerns()):
        return 0
    closest = None
    for r in range(ROWS):
        if a.rp[r] is None or b.lp[r] is None:
            continue
        v = a.rp[r] - b.lp[r]          # how far a's ink reaches past b's ink start, at nominal x = 0
        closest = v if closest is None else max(closest, v)
    if closest is None:
        return kmax
    needed = closest + 1 + gap          # advance that leaves exactly `gap` at the closest row
    return max(0, min(kmax, a.w + gap - needed))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-i", "--input", default=DEFAULT_IN)
    ap.add_argument("-o", "--out", default=DEFAULT_OUT)
    ap.add_argument("-m", "--metrics", default=DEFAULT_METRICS)
    ap.add_argument("--gap", type=int, default=2, help="pixels between the closest ink of neighbors (default 2)")
    ap.add_argument("--kmax", type=int, default=2, help="largest kern, 0..3 (default 2)")
    ap.add_argument("--space", type=int, default=5, help="advance of the space (default 5)")
    ap.add_argument("--icon-adv", type=int, default=12, help="advance of an icon = start of the name field (default 12)")
    args = ap.parse_args()
    if not 0 <= args.kmax <= 3:
        raise SystemExit("--kmax must be 0..3 (2-bit matrix entries)")
    blocks = parse(args.input)
    glyphs = []
    for code in ORDER:
        rows = blocks.get(code)
        if rows is None or len(rows) != ROWS:
            raise SystemExit(f"glyph 0x{code:02X}: expected {ROWS} rows, found {0 if rows is None else len(rows)}")
        glyphs.append(Glyph(code, rows))
    widest = max(g.w for g in glyphs if g.code not in ICONS)
    if widest > 9:
        raise SystemExit(f"a text glyph is {widest} px wide; at most 9 fit a 16-bit row at every shift")

    # bitmaps
    data = bytearray()
    for g in glyphs:
        for r in g.rows:
            v = 0
            for i, ch in enumerate(r):
                if ch == "#":
                    v |= 1 << (15 - i)
            data += bytes((v >> 8, v & 0xFF))
    with open(args.out, "wb") as f:
        f.write(data)
    print(f"wrote {args.out}: {len(glyphs)} glyphs, {len(data)} bytes, widest text glyph {widest} px")

    # advances and widths
    adv = []
    for g in glyphs:
        if g.code in ICONS:
            adv.append(args.icon_adv)
        elif g.code == SPACE:
            adv.append(args.space)
        else:
            adv.append(g.w + args.gap)

    # kerning classes: a glyph's right class is its row of the pair matrix,
    # its left class the column; identical rows/columns share a class, and
    # the all-zero row/column is class 0.
    n = len(glyphs)
    matrix = [[kern(glyphs[a], glyphs[b], args.gap, args.kmax) for b in range(n)] for a in range(n)]
    zero = tuple([0] * n)
    rclasses = {zero: 0}
    lclasses = {zero: 0}
    rrow_of = []
    lcol_of = []
    for a in range(n):
        key = tuple(matrix[a])
        rrow_of.append(rclasses.setdefault(key, len(rclasses)))
    for b in range(n):
        key = tuple(matrix[a][b] for a in range(n))
        lcol_of.append(lclasses.setdefault(key, len(lclasses)))
    R, L = len(rclasses), len(lclasses)
    stride = (L + 3) // 4
    # class table: rows indexed by right class, columns by left class; a
    # representative glyph of each class supplies the values
    rep_a = {cls: a for a, cls in enumerate(rrow_of)}
    rep_b = {cls: b for b, cls in enumerate(lcol_of)}
    rows_out = bytearray()
    for rc in range(R):
        row = bytearray(stride)
        for lc in range(L):
            v = matrix[rep_a[rc]][rep_b[lc]] if rc and lc else 0
            row[lc >> 2] |= v << ((lc & 3) * 2)
        rows_out += row
    header = 101 * 3 + 101 * 2
    metrics = bytearray()
    metrics += bytes(adv)
    metrics += bytes(g.w for g in glyphs)
    metrics += bytes(lcol_of)
    for rc in rrow_of:
        off = header + rc * stride
        metrics += bytes((off & 0xFF, off >> 8))
    metrics += rows_out
    assert len(metrics) == header + R * stride
    with open(args.metrics, "wb") as f:
        f.write(metrics)
    kerned = sum(1 for a in range(n) for b in range(n) if matrix[a][b])
    print(f"wrote {args.metrics}: {len(metrics)} bytes; {R} right x {L} left classes, "
          f"{kerned} kerned pairs, gap {args.gap}, kmax {args.kmax}, space {args.space}, icon {args.icon_adv}")
    print("place both with scripts/inject-font12.sh")


if __name__ == "__main__":
    main()
