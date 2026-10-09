#!/usr/bin/env python3
"""Trace the cart label's orange brush "Jr." onto the wordmark bitmap.

    jr-trace.py cart-label.png ezflash.txt jr.txt [--scale 0.85]

The photo (fpga/bootsplash/cart-label.png, untracked) shows the label at a
slight tilt. The white EZ-FLASH letters give the tilt and the scale: their
box is mapped onto ezflash.txt (108 x 16). Every bitmap pixel is then
sampled 4x4 in the straightened photo; at least 40% orange makes it Jr.
--scale shrinks the Jr. about the top of the J (1.0 = as on the label).
Prints the --jr-at origin for mkwordmark.py.
"""
import argparse
import os
import struct
import subprocess
import tempfile

BOX = (95, 330, 276, 345)      # photo region holding the letters and the Jr.
JR_COLUMNS = 262               # letters left of this column set tilt and box
ANCHOR = (92, 4)               # top of the J, in bitmap pixels


def load(path):
    with tempfile.TemporaryDirectory() as tmp:
        bmp = os.path.join(tmp, "p.bmp")
        subprocess.run(["sips", "-s", "format", "bmp", path, "--out", bmp],
                       check=True, capture_output=True)
        d = open(bmp, "rb").read()
    off = struct.unpack_from("<I", d, 10)[0]
    w, h = struct.unpack_from("<ii", d, 18)
    bpp = struct.unpack_from("<H", d, 28)[0] // 8
    down = h < 0
    h = abs(h)
    stride = (w * bpp + 3) & ~3

    def px(x, y):
        o = off + (y if down else h - 1 - y) * stride + x * bpp
        b, g, r = d[o:o + 3]
        return r, g, b
    return px


def classify(r, g, b):
    if min(r, g, b) > 150 and max(r, g, b) - min(r, g, b) < 60:
        return "w"
    if r > 120 and r - b > 60 and b < g < r - 25:
        return "o"
    return "."


def slope(points):
    n = len(points)
    mx = sum(x for x, _ in points) / n
    my = sum(y for _, y in points) / n
    return sum((x - mx) * (y - my) for x, y in points) / sum((x - mx) ** 2 for x, _ in points)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("photo")
    ap.add_argument("letters")
    ap.add_argument("out")
    ap.add_argument("--scale", type=float, default=1.0)
    a = ap.parse_args()
    px = load(a.photo)
    x0, x1, y0, y1 = BOX
    C = {(x, y): classify(*px(x, y)) for x in range(x0, x1) for y in range(y0, y1)}

    # tilt from the flat tops of the letters
    tops = []
    for x in range(x0, JR_COLUMNS):
        ys = [y for y in range(y0, 320) if C[(x, y)] == "w"]
        if ys and min(ys) <= 290:
            tops.append((x, min(ys)))
    s = slope(tops)
    xr = x0

    def straight(x, y):
        return y - s * (x - xr)
    pts = [(x, straight(x, y)) for (x, y), c in C.items() if c == "w" and y < 316]
    lx0 = min(p[0] for p in pts)
    lx1 = max(p[0] for p in pts)
    ys = sorted(p[1] for p in pts)
    ly0, ly1 = ys[len(ys) // 200], ys[-len(ys) // 200 - 1]
    rows = [l.rstrip("\n") for l in open(a.letters)]
    sx = (lx1 - lx0 + 1) / max(len(r) for r in rows)
    sy = (ly1 - ly0 + 1) / len(rows)
    ax, ay = ANCHOR

    def orange(tx, ty):
        n = hit = 0
        for i in range(4):
            for j in range(4):
                fx = ax + (tx + (i + .5) / 4 - ax) / a.scale
                fy = ay + (ty + (j + .5) / 4 - ay) / a.scale
                x = lx0 + fx * sx
                y = ly0 + fy * sy + s * (x - xr)
                c = C.get((int(x), int(y)))
                if c:
                    n += 1
                    hit += c == "o"
        return n and hit / n >= .4
    O = {(tx, ty) for tx in range(-2, 130) for ty in range(-6, 36) if orange(tx, ty)}
    ox, oy = min(x for x, _ in O), min(y for _, y in O)
    w, h = max(x for x, _ in O) - ox + 1, max(y for _, y in O) - oy + 1
    with open(a.out, "w") as f:
        for ty in range(oy, oy + h):
            f.write("".join("o" if (tx, ty) in O else "." for tx in range(ox, ox + w)) + "\n")
    print(f"tilt {s:+.4f}, {sx:.2f} x {sy:.2f} photo px per pixel, Jr. {w}x{h}: --jr-at {ox},{oy}")


if __name__ == "__main__":
    main()
