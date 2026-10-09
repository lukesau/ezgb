#!/usr/bin/env python3
"""Convert the EZ Flash icon (left part of the marketing logo) to GB tiles.

    mkicon.py logo.png OUTDIR [--scale 0.3556] [--split 24]

Box-filters the icon down, classifies every pixel into background, top frame
grey, bottom frame light grey, orange screen, dark lip, and emits:

  icon.2bpp      tile data (2bpp, 16 bytes/tile, row-major over the icon)
  icon.map       tile indices, one byte per cell, row-major
  icon.attr      CGB attribute bytes (palette 0 = top shape, 1 = bottom shape)
  icon.inc       ICON_W/ICON_H (tiles) constants

Rows above --split (pixels, must be a multiple of 8) use palette 0, the
rest palette 1, so the top and bottom shapes can each have 4 colours.
Colour indices (one palette; DMG BGP $E4 gives the greys in brackets):
  0 screen background (white)   1 orange screen (light grey)
  2 both frames, darkened (dark grey)   3 dark lip (black)
"""

import argparse
import os
import struct
import subprocess
import sys

REF = {  # class -> reference RGB
    "light": (208, 208, 208),
    "mid": (144, 144, 144),
    "orange": (245, 165, 35),
    "dark": (64, 64, 64),
}
INDEX = {"bg": 0, "orange": 1, "light": 2, "mid": 2, "dark": 3}
GLYPH = {"bg": ".", "light": "-", "mid": "#", "orange": "o", "dark": "@"}


def load_rgba(path, workdir):
    if not os.path.exists(path):
        sys.exit(f"{path}: not found")
    tmp = os.path.join(workdir, "source.bmp")
    subprocess.run(["sips", "-s", "format", "bmp", path, "--out", tmp],
                   check=True, capture_output=True)
    d = open(tmp, "rb").read()
    os.unlink(tmp)
    off = struct.unpack_from("<I", d, 10)[0]
    w, h = struct.unpack_from("<ii", d, 18)
    if struct.unpack_from("<H", d, 28)[0] != 32:
        sys.exit("expected 32-bit BMP with alpha")
    top_down = h < 0
    h = abs(h)

    def px(x, y):
        yy = y if top_down else h - 1 - y
        o = off + yy * w * 4 + x * 4
        b, g, r, a = d[o:o + 4]
        return r, g, b, a
    return w, h, px


def classify(rgb):
    return min(REF, key=lambda k: sum((a - b) ** 2 for a, b in zip(rgb, REF[k])))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("png")
    ap.add_argument("out")
    ap.add_argument("--scale", type=float, default=24 / 67.5)
    ap.add_argument("--split", type=int, default=0,
                    help="rows above this use palette 0, the rest palette 1 (0 = one palette)")
    ap.add_argument("--no-mirror", action="store_true",
                    help="keep the raw downscale instead of mirroring the left half")
    ap.add_argument("--bg-threshold", type=float, default=0.55,
                    help="pixel is background if at least this much of it is transparent")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    w, h, px = load_rgba(args.png, args.out)

    # icon = opaque columns before the first fully transparent column
    def col_opaque(x):
        return any(px(x, y)[3] > 128 for y in range(h))
    x1 = next(x for x in range(1, w) if not col_opaque(x) and col_opaque(x - 1))
    sw, sh = x1, h
    s = args.scale
    tw, th = round(sw * s), round(sh * s)
    cols, rows = (tw + 7) // 8, (th + 7) // 8
    ox, oy = (cols * 8 - tw) // 2, 0  # centre horizontally inside the tile grid
    grid = [["bg"] * (cols * 8) for _ in range(rows * 8)]
    for ty in range(th):
        for tx in range(tw):
            area = {"bg": 0}
            y0, y1 = ty / s, (ty + 1) / s
            x0, x1b = tx / s, (tx + 1) / s
            for sy in range(int(y0), min(sh, int(y1 + 0.999))):
                for sx in range(int(x0), min(sw, int(x1b + 0.999))):
                    r, g, b, a = px(sx, sy)
                    k = "bg" if a < 128 else classify((r, g, b))
                    area[k] = area.get(k, 0) + 1
            total = sum(area.values())
            if area["bg"] >= args.bg_threshold * total:
                k = "bg"
            else:
                k = max((c for c in area if c != "bg"), key=lambda c: area[c])
            grid[oy + ty][ox + tx] = k

    if not args.no_mirror:
        # the icon is symmetric; rounding isn't, so mirror the left half
        for line in grid:
            for x in range(ox, ox + tw // 2):
                line[2 * ox + tw - 1 - x] = line[x]

    os.makedirs(args.out, exist_ok=True)
    tiles, attrs = bytearray(), bytearray()
    for r in range(rows):
        for c in range(cols):
            for y in range(8):
                lo = hi = 0
                for x in range(8):
                    i = INDEX[grid[r * 8 + y][c * 8 + x]]
                    lo |= (i & 1) << (7 - x)
                    hi |= (i >> 1) << (7 - x)
                tiles += bytes([lo, hi])
            attrs.append(1 if args.split and r * 8 >= args.split else 0)
    open(f"{args.out}/icon.2bpp", "wb").write(tiles)
    open(f"{args.out}/icon.map", "wb").write(bytes(range(rows * cols)))
    open(f"{args.out}/icon.attr", "wb").write(attrs)
    open(f"{args.out}/icon.inc", "w").write(
        f"DEF ICON_W EQU {cols}\nDEF ICON_H EQU {rows}\n")
    for y, line in enumerate(grid):
        mark = "  <- palette split" if y == args.split else ""
        print("".join(GLYPH[k] for k in line) + mark)
    print(f"{tw}x{th} px, {cols}x{rows} tiles, {len(tiles)} bytes of tile data")
    # sanity: no top-shape colours below the split, no bottom ones above
    for y, line in enumerate(grid):
        for k in line:
            if args.split and k != "bg" and ((y < args.split) != (k == "mid")):
                print(f"warning: {k} at row {y} is on the wrong side of the split")
                break


if __name__ == "__main__":
    main()
