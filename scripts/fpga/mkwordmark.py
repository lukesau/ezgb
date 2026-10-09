#!/usr/bin/env python3
"""Compose the boot-screen wordmark: EZ-FLASH with the brush "Jr." over it.

    mkwordmark.py ezflash.txt jr.txt OUT.c [--jr-at 98,2] [--rotate 15] [--pivot 8,0]
                  [--letters-x 10] [--letters-y 2] [--width 16] [--height 3] [--no-halo]
                  [--stages 4]

ezflash.txt: '#' letter pixels (rendered from Arial Bold Italic 22 pt with
no antialiasing, then cleaned up by hand). jr.txt: 'o' orange, 'O' dark
orange, '.' clear. The Jr. is turned --rotate degrees counter-clockwise
about --pivot (a point of jr.txt: the top of the J) and drawn with that
point at --jr-at (pixels, relative to the letters' top left), with a
1-pixel ring of background around its strokes where they cross the
letters, like paint over print. --letters-y leaves rows above the letters
for the part of the Jr. that rises past them.

Colour indices: 0 background, 1 orange, 2 dark orange, 3 letters. On DMG
(BGP $E4) that is white, light grey, dark grey, black.

Writes OUT.c: wordmark_tiles (2bpp tiles, deduplicated across all maps)
and wordmark_maps: --stages + 1 maps of width x height tile numbers
(row-major, 0-based into wordmark_tiles). Map 0 is the letters alone; map
i adds the Jr. pixels left of the i-th of --stages equal steps across its
width, so stepping through the maps paints it on left to right; the last
map is the whole mark. Prints a preview of it.
"""
import argparse
import math

GLYPH = ".o+#"


def load(path):
    return [l.rstrip("\n") for l in open(path) if l.strip()]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("letters")
    ap.add_argument("jr")
    ap.add_argument("out")
    ap.add_argument("--jr-at", default="98,2")
    ap.add_argument("--rotate", type=float, default=0.0, help="degrees counter-clockwise")
    ap.add_argument("--pivot", default="8,0")
    ap.add_argument("--letters-y", type=int, default=0)
    ap.add_argument("--letters-x", type=int, default=None,
                    help="letters' left edge in the canvas (default: centre the whole mark)")
    ap.add_argument("--width", type=int, default=14, help="tiles")
    ap.add_argument("--height", type=int, default=3, help="tiles")
    ap.add_argument("--no-halo", action="store_true")
    ap.add_argument("--stages", type=int, default=1, help="steps the Jr. is painted in")
    a = ap.parse_args()
    W, H = a.width * 8, a.height * 8
    letters, jr = load(a.letters), load(a.jr)
    lw = max(len(r) for r in letters)
    jx, jy = map(int, a.jr_at.split(","))
    px0, py0 = map(int, a.pivot.split(","))
    src = {(x, y): {"o": 1, "O": 2}[c]
           for y, r in enumerate(jr) for x, c in enumerate(r) if c in "oO"}
    # rotate about the pivot, nearest pixel: for each target pixel look up
    # where it came from (screen y points down, so CCW uses these signs)
    t = math.radians(a.rotate)
    cs, sn = math.cos(t), math.sin(t)
    reach = max(len(jr), max(len(r) for r in jr)) * 2
    rel = {}
    for ty in range(-reach, reach):
        for tx in range(-reach, reach):
            sx = tx * cs - ty * sn
            sy = tx * sn + ty * cs
            v = src.get((round(px0 + sx), round(py0 + sy)))
            if v:
                rel[(tx, ty)] = v
    ly = a.letters_y
    xs = [x for x, _ in rel]
    left = min(0, jx + min(xs))
    right = max(lw, jx + max(xs) + 1)
    ox = (W - (right - left)) // 2 - left if a.letters_x is None else a.letters_x
    paint = {(ox + jx + x, ly + jy + y): v for (x, y), v in rel.items()}
    if ox + left < 0 or ox + right > W or ly + len(letters) > H or             min(y for _, y in paint) < 0 or max(y for _, y in paint) >= H:
        raise SystemExit(f"does not fit in {a.width}x{a.height} tiles")
    px = [[0] * W for _ in range(H)]
    for y, r in enumerate(letters):
        for x, c in enumerate(r):
            if c == "#":
                px[ly + y][ox + x] = 3
    letters_px = [row[:] for row in px]
    jx0 = min(x for x, _ in paint)
    jx1 = max(x for x, _ in paint) + 1

    def compose(limit):
        out = [row[:] for row in letters_px]
        part = {p: v for p, v in paint.items() if p[0] < limit}
        if not a.no_halo:
            for (x, y) in part:
                for dx in (-1, 0, 1):
                    for dy in (-1, 0, 1):
                        if 0 <= x + dx < W and 0 <= y + dy < H:
                            out[y + dy][x + dx] = 0
        for (x, y), v in part.items():
            out[y][x] = v
        return out

    limits = [jx0] + [jx0 + (jx1 - jx0) * i // a.stages for i in range(1, a.stages)] + [jx1]
    frames = [compose(l) for l in limits]
    for row in frames[-1]:
        print("".join(GLYPH[v] for v in row))

    tiles, index, maps = [], {}, []
    for fpx in frames:
        tmap = []
        for ty in range(a.height):
            for tx in range(a.width):
                t = bytearray()
                for y in range(8):
                    lo = hi = 0
                    for x in range(8):
                        v = fpx[ty * 8 + y][tx * 8 + x]
                        lo |= (v & 1) << (7 - x)
                        hi |= (v >> 1) << (7 - x)
                    t += bytes([lo, hi])
                t = bytes(t)
                if t not in index:
                    index[t] = len(tiles)
                    tiles.append(t)
                tmap.append(index[t])
        maps.append(tmap)
    with open(a.out, "w") as f:
        f.write("/* generated by scripts/fpga/mkwordmark.py */\n#include <stdint.h>\n\n")
        f.write(f"const uint8_t wordmark_tile_count = {len(tiles)};\n")
        f.write(f"const uint8_t wordmark_tiles[{len(tiles) * 16}] = {{\n")
        for t in tiles:
            f.write("    " + ", ".join(f"0x{b:02X}" for b in t) + ",\n")
        f.write("};\n")
        f.write(f"const uint8_t wordmark_stages = {a.stages};\n")
        f.write(f"const uint8_t wordmark_maps[{len(maps)}][{len(maps[0])}] = {{\n")
        for tmap in maps:
            f.write("    {\n")
            for i in range(0, len(tmap), a.width):
                f.write("        " + ", ".join(str(v) for v in tmap[i:i + a.width]) + ",\n")
            f.write("    },\n")
        f.write("};\n")
    size = len(tiles) * 16 + len(maps) * len(maps[0])
    print(f"{a.width}x{a.height} tiles, {len(maps)} maps, {len(tiles)} unique tiles, {size} bytes")


if __name__ == "__main__":
    main()
