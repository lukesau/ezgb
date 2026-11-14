#!/usr/bin/env python3
"""Regenerate the README banner (docs/banner.png): a grid of screenshots.

Every tile is one entry in SHOTS below: the console model, the card's
EZGB.CFG, stars, and the buttons to press before the capture.
LAYOUT places the tiles in rows. To show a new feature, add a Shot and put
its name in LAYOUT.

    scripts/make-showcase-banner.py [output.png]
        --only NAME[,NAME]   capture just these (with --keep, to try a shot)
        --keep DIR           leave the raw captures and scratch cards in DIR
        --captions           put each shot's caption under its tile

The card is built here from CARD, so the emulator card (sd/card.img) is
neither read nor rebuilt.

macOS only. Needs mtools, ImageMagick, swiftc, the SameBoy build with the EZ
Jr stub (scripts/setup-sameboy.sh; buttons go in through
SAMEBOY_EZFLASH_JR_PADFILE, so the window needs no focus), Screen Recording
permission for the terminal, and SDCC for stage1 (stage1/build.sh).
"""
import argparse
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass, field

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
KVER = "1.05e-0731"
MOD_KERNEL = f"{ROOT}/kernel/re/{KVER}/kernel.gb"
SAMEBOY = os.environ.get("SAMEBOY", f"{ROOT}/tools/SameBoy/build/bin/SDL/sameboy")
FONT = os.environ.get("SHOWCASE_FONT", "/System/Library/Fonts/Menlo.ttc")
CAPTION_COLOR = "#9bbc0f"
ENV = dict(os.environ, MTOOLS_SKIP_CHECK="1")

RIGHT, LEFT, UP, DOWN, A, B, SELECT, START = (1 << i for i in range(8))

# The card, in FAT directory order (the mod sorts it and hides the junk a
# Mac leaves). A trailing / is a folder. mtools turns ' [ ] and , in a long
# name into _, so the names avoid them.
CARD = [
    "Pokemon/",
    "Pokemon/Pokemon Red.gb",
    "Dr. Mario (World).gb",
    "SAVER/",
    "Tetris.gb",
    ".DS_Store",
    "Wario Land II (USA) (SGB Enhanced).gbc",
    "Zelda/",
    "Zelda/Links Awakening.gbc",
    "._Tetris.gb",
    "Pokemon Crystal (USA) (Rev 1).gbc",
    "readme.txt",
    "Super Mario Land (World).gb",
    "Metroid II.sav",
]
TETRIS = "Tetris.gb"
CRYSTAL = "Pokemon Crystal (USA) (Rev 1).gbc"


@dataclass
class Shot:
    name: str
    caption: str
    model: str = "cgb"                # SameBoy --model
    cfg: list = field(default_factory=list)     # EZGB.CFG lines
    stars: dict = field(default_factory=dict)   # file name -> (launches, starred)
    steps: list = field(default_factory=list)   # ("tap", mask) ("hold", mask, s) ("wait", s)
    stage1: str = ""                  # a stage1-shots.py capture instead


def tap(mask, n=1):
    return [("tap", mask)] * n


STARS = {TETRIS: (12, True), CRYSTAL: (30, True)}
BIG = ["UI=12"]

PINK = "COLORS=000000,FFFFFF,FF5FA0"          # DV with a pink accent (docs/dark-mode.md)
THEME_PAGE = tap(SELECT) + tap(LEFT) + tap(A) + [("wait", 2.0)]   # SET, PREV wraps to page 3

SHOTS = [
    Shot("light", "Light", cfg=BIG, stars=STARS, steps=tap(DOWN, 2)),
    Shot("dark", "Dark", cfg=BIG + ["THEME=1"], stars=STARS, steps=tap(DOWN, 3)),
    Shot("dv", "DV", cfg=["THEME=7", PINK] + BIG, stars=STARS, steps=tap(DOWN, 4)),
    Shot("themes", "Themes", cfg=["THEME=7", PINK] + BIG, steps=THEME_PAGE),
    Shot("menu", "Hold A", cfg=["THEME=6", "COLORS=1E2A44,F2D7A0,E0A040"] + BIG, stars=STARS,
         steps=tap(DOWN, 3) + [("hold", A, 1.2), ("wait", 1.0)]),
    Shot("splash", "Firmware mod", stage1="launch.png"),
]

LAYOUT = [
    ["light", "dark", "dv"],
    ["themes", "menu", "splash"],
]


def run(*args, **kw):
    return subprocess.run(args, check=True, env=ENV, stdout=subprocess.DEVNULL, **kw)


def name_hash(name):
    """play.c's file name hash (docs/stars.md)"""
    a, b = 5381, 0
    for c in name.upper().encode():
        a = (a * 33 + c) & 0xFFFF
        b = (b + a) & 0xFFFF
    return bytes([a >> 8, a & 255, b >> 8, b & 255])


def plays_file(stars):
    rows = sorted((name_hash(n), l, s) for n, (l, s) in stars.items())
    out = bytearray(b"PL" + bytes([len(rows), sum(1 for r in rows if r[2])]) + b"SO\x00\x00")
    for h, l, s in rows:
        out += h + bytes([l & 255, l >> 8, 1 if s else 0, 0])
    return bytes(out.ljust(2048, b"\0"))


def build_card(path, wd):
    with open(path, "wb") as f:
        f.truncate(64 << 20)
    run("mformat", "-i", path, "-F", "-v", "EZJR", "::")
    rom = os.path.join(wd, "rom.bin")
    with open(rom, "wb") as f:
        f.write(bytes(32768))
    for entry in CARD:
        if entry.endswith("/"):
            run("mmd", "-i", path, "::/" + entry.rstrip("/"))
        else:
            run("mcopy", "-i", path, rom, "::/" + entry)


def put(card, wd, name, data):
    tmp = os.path.join(wd, "put.bin")
    with open(tmp, "wb") as f:
        f.write(data)
    run("mcopy", "-o", "-i", card, tmp, "::/" + name)


def psram():
    """an empty cart with a live battery (the canary at page $11 $A201)"""
    ps = bytearray(256 * 1024)
    ps[0x11 * 0x2000 + 0x201] = 0x88
    return bytes(ps)


class Emu:
    def __init__(self, shot, base_card, wd, winid):
        self.wd, self.winid = wd, winid
        os.makedirs(wd, exist_ok=True)
        self.card = os.path.join(wd, "card.img")
        shutil.copy(base_card, self.card)
        if shot.cfg:
            put(self.card, wd, "EZGB.CFG", "".join(l + "\r\n" for l in shot.cfg).encode())
        if shot.stars:
            put(self.card, wd, ".ezgbplays", plays_file(shot.stars))
        with open(os.path.join(wd, "psram.bin"), "wb") as f:
            f.write(psram())
        self.pad = os.path.join(wd, "pad")
        self.key(0)
        env = dict(os.environ, SAMEBOY_EZFLASH_JR_IMG=self.card, SAMEBOY_EZFLASH_JR_PADFILE=self.pad)
        env.pop("SAMEBOY_EZFLASH_JR_DRY", None)
        self.p = subprocess.Popen([SAMEBOY, "--model", shot.model, MOD_KERNEL], env=env, stdin=subprocess.DEVNULL,
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def key(self, mask):
        with open(self.pad + ".tmp", "w") as f:
            f.write("%02x\n" % mask)
        os.replace(self.pad + ".tmp", self.pad)

    def step(self, s):
        if s[0] == "tap":
            self.key(s[1]); time.sleep(0.15); self.key(0); time.sleep(0.6)
        elif s[0] == "hold":
            self.key(s[1]); time.sleep(s[2]); self.key(0)
        else:
            time.sleep(s[1])

    def capture(self, out):
        for _ in range(40):
            wid = subprocess.run([self.winid, str(self.p.pid)], capture_output=True, text=True).stdout.strip()
            if wid:
                break
            time.sleep(0.25)
        else:
            sys.exit("error: SameBoy window not found")
        subprocess.run(["screencapture", "-x", "-o", "-l", wid, out], check=True)

    def close(self):
        self.p.send_signal(signal.SIGTERM)
        try:
            self.p.wait(5)
        except subprocess.TimeoutExpired:
            self.p.kill()


def size(png):
    out = subprocess.run(["magick", "identify", "-format", "%w %h", png], capture_output=True, text=True, check=True)
    return [int(v) for v in out.stdout.split()]


def crop(src, dst):
    """Drop the SDL title bar: the 160x144 screen fills the window's width
    and sits at its bottom."""
    w, h = size(src)
    gh = w * 144 // 160
    run("magick", src, "-crop", f"{w}x{gh}+0+{h - gh}", "+repage", dst)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("out", nargs="?", default=f"{ROOT}/docs/banner.png")
    ap.add_argument("--only")
    ap.add_argument("--keep")
    ap.add_argument("--captions", action="store_true")
    a = ap.parse_args()

    for tool in ("magick", "mformat", "swiftc"):
        if not shutil.which(tool):
            sys.exit(f"error: {tool} not found")
    for p in (SAMEBOY, MOD_KERNEL):
        if not os.path.isfile(p):
            sys.exit(f"error: missing {p}")

    tmp = a.keep or tempfile.mkdtemp(prefix="ezgb-banner-")
    os.makedirs(tmp, exist_ok=True)
    try:
        winid = os.path.join(tmp, "winid")
        run("swiftc", "-O", f"{ROOT}/scripts/showcase/winid.swift", "-o", winid)
        card = os.path.join(tmp, "card.img")
        build_card(card, tmp)

        by_name = {s.name: s for s in SHOTS}
        want = a.only.split(",") if a.only else [n for row in LAYOUT for n in row]
        tiles = {}
        if any(by_name[n].stage1 for n in want):
            print("capturing stage1...")
            subprocess.run([f"{ROOT}/stage1/build.sh"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run([sys.executable, f"{ROOT}/scripts/showcase/stage1-shots.py", card,
                            os.path.join(tmp, "stage1"), "--winid", winid, "--model", "cgb", "--dark"], check=True)
        for n in want:
            shot = by_name[n]
            raw = os.path.join(tmp, f"raw-{n}.png")
            if shot.stage1:
                shutil.copy(os.path.join(tmp, "stage1", shot.stage1), raw)
            else:
                print(f"capturing {n}...")
                emu = Emu(shot, card, os.path.join(tmp, "run-" + n), winid)
                try:
                    time.sleep(8)                 # boot and the first browser paint
                    for s in shot.steps:
                        emu.step(s)
                    time.sleep(0.5)
                    emu.capture(raw)
                finally:
                    emu.close()
            tiles[n] = os.path.join(tmp, f"tile-{n}.png")
            crop(raw, tiles[n])
        if a.only:
            print("captures in", tmp)
            return

        w, h = size(tiles[LAYOUT[0][0]])
        gut = 12
        rows = []
        for i, row in enumerate(LAYOUT):
            parts = []
            for n in row:
                cell = os.path.join(tmp, f"cell-{n}.png")
                if not a.captions:
                    shutil.copy(tiles[n], cell)
                else:
                    cap = os.path.join(tmp, f"cap-{n}.png")
                    run("magick", "-size", f"{w}x40", "xc:black", "-font", FONT, "-pointsize", str(w * 22 // 320),
                        "-fill", CAPTION_COLOR, "-gravity", "Center", "-annotate", "+0+0", by_name[n].caption, cap)
                    run("magick", tiles[n], cap, "-append", cell)
                parts.append(cell)
            out = os.path.join(tmp, f"row-{i}.png")
            cmd = ["magick"]
            for j, c in enumerate(parts):
                if j:
                    cmd += ["-size", f"{gut}x{h}", "xc:black"]
                cmd.append(c)
            run(*cmd, "-background", "black", "+append", out)
            rows.append(out)
        cmd = ["magick"]
        for j, r in enumerate(rows):
            if j:
                cmd += ["-size", f"{w}x{gut}", "xc:black"]
            cmd.append(r)
        run(*cmd, "-background", "black", "-append", "-bordercolor", "black", "-border", "16x16", a.out)
        print("wrote %s (%dx%d)" % (a.out, *size(a.out)))
    finally:
        if not a.keep:
            shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
