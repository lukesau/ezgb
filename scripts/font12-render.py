#!/usr/bin/env python3
"""Rasterize a TrueType font into the 10x12 ASCII-art glyph sheet
(decomp/font12/font12.txt) that scripts/font12-pack.py turns into the
font12_data.h table used by decomp/src/draw12.c.

The output is meant to be hand-edited afterwards: each glyph is a 12-line
block of '.' (paper) and '#' (ink) under a `glyph 0xNN 'c'` header. Re-running
this script overwrites every ASCII glyph but keeps any block whose header has
the word `keep` (the icons, and any letter you have hand-tuned).

Needs Pillow:  python3 -m venv .venv && .venv/bin/pip install pillow

    scripts/font12-render.py [--font /System/Library/Fonts/Menlo.ttc] [--index 1]
                             [--size 14] [--baseline 9] [--bold] [-o decomp/font12/font12.txt]

Cells are 10 wide x 12 tall, icons included. The TTF baseline is placed on cell row `--baseline`
(0-based, default 9): caps occupy rows 0-9 and descenders rows 10-11, with
anything below row 11 clipped. `--bold` ORs each glyph with a copy shifted one
pixel right (a 2px stroke reads much better on a stock DMG, the baseline
every UI choice is checked against).
"""
import argparse
import os
import re
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("Pillow is required: python3 -m venv .venv && .venv/bin/pip install pillow")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_OUT = os.path.join(ROOT, "decomp", "font12", "font12.txt")
W = 10
H = 12
ICON_W = 10
CODES = list(range(0x20, 0x80)) + [0xC0, 0xC1, 0xC2, 0xC3, 0xC4]
ICON_NAMES = {0xC0: "folder", 0xC1: "gb cart", 0xC2: "gbc cart", 0xC3: "unknown file", 0xC4: "sav page"}


def header_line(code):
    if code in ICON_NAMES:
        return f"glyph 0x{code:02X} icon {ICON_NAMES[code]}"
    ch = chr(code)
    return f"glyph 0x{code:02X} '{ch}'" if code != 0x20 else "glyph 0x20 ' ' (space)"


def read_existing(path):
    """Return {code: (header, rows)} for every block already in the file."""
    blocks = {}
    if not os.path.exists(path):
        return blocks
    cur = None
    rows = []
    for line in open(path):
        line = line.rstrip("\n")
        m = re.match(r"glyph 0x([0-9A-Fa-f]{2})\b(.*)", line)
        if m:
            if cur is not None:
                blocks[cur[0]] = (cur[1], rows)
            cur = (int(m.group(1), 16), line)
            rows = []
        elif cur is not None and re.fullmatch(r"[.#]{10}", line):
            rows.append(line)
    if cur is not None:
        blocks[cur[0]] = (cur[1], rows)
    return blocks


def render(font, code, baseline, bold):
    im = Image.new("1", (40, 48), 0)
    d = ImageDraw.Draw(im)
    asc, _ = font.getmetrics()
    ox, oy = 8, 8
    d.text((ox, oy), chr(code), font=font, fill=1)
    px = im.load()
    bb = im.getbbox()
    rows = [[0] * W for _ in range(H)]
    if bb:
        # horizontal: centre the ink in the cell (1 extra px for the bold shift)
        ink_w = bb[2] - bb[0] + (1 if bold else 0)
        left = max(0, (W - ink_w) // 2)
        for y in range(H):
            sy = oy + asc - baseline - 1 + y  # cell row y <-> font pixel row
            for x in range(W):
                sx = bb[0] + (x - left)
                v = 0
                if 0 <= sy < im.height:
                    if 0 <= sx < im.width and px[sx, sy]:
                        v = 1
                    if bold and 0 <= sx - 1 < im.width and px[sx - 1, sy]:
                        v = 1
                rows[y][x] = v
    return ["".join("#" if v else "." for v in r) for r in rows]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--font", default="/System/Library/Fonts/Menlo.ttc")
    ap.add_argument("--index", type=int, default=1, help="face index inside a .ttc (Menlo: 1 = Bold)")
    ap.add_argument("--size", type=int, default=13)
    ap.add_argument("--baseline", type=int, default=9)
    ap.add_argument("--bold", action="store_true", default=False)
    ap.add_argument("--no-bold", dest="bold", action="store_false")
    ap.add_argument("-o", "--out", default=DEFAULT_OUT)
    args = ap.parse_args()

    font = ImageFont.truetype(args.font, args.size, index=args.index)
    existing = read_existing(args.out)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    out = []
    out.append("# Glyph sheet for the EZGB 12px browser (decomp/src/draw12.c).")
    out.append("# '.' = paper, '#' = ink. 12 rows per glyph, in code order: text glyphs")
    out.append("# ($20-$7F) and the icons ($C0-$C4) are all 10 columns wide (10x12 cells).")
    out.append("# Add the word `keep` to a glyph header to protect it from font12-render.py.")
    out.append(f"# Rendered from {os.path.basename(args.font)} index {args.index} size {args.size} "
               f"baseline {args.baseline}{' bold' if args.bold else ''}.")
    out.append("")
    kept = 0
    for code in CODES:
        prev = existing.get(code)
        if prev and ("keep" in prev[0] or code in ICON_NAMES) and len(prev[1]) == H:
            out.append(prev[0])
            out.extend(prev[1])
            kept += 1
        elif code in ICON_NAMES:
            out.append(header_line(code) + " keep")
            out.extend(["." * ICON_W] * H)
        else:
            out.append(header_line(code))
            out.extend(render(font, code, args.baseline, args.bold))
        out.append("")
    with open(args.out, "w") as f:
        f.write("\n".join(out))
    print(f"wrote {args.out}: {len(CODES)} glyphs ({kept} kept)")


if __name__ == "__main__":
    main()
