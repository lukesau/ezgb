#!/usr/bin/env python3
"""Full play table eviction, run in SameBoy (docs/stars.md).

Each case writes a 254-entry /.ezgbplays to a scratch card with two ROMs,
boots the kernel, launches or stars a ROM that is not in the table, and
compares the file the kernel wrote back with what play.c should have done.

  scripts/test-play-evict.py <kernel.gb> [case ...]

Needs mtools and the SameBoy stub with SAMEBOY_EZFLASH_JR_PADFILE. MODEL=dmg
runs it as a DMG. Scratch cards go to a temp directory, or to EVICT_DIR.
With EVICT_WINID set to a swift script that prints the window id of a pid,
each step is also screenshotted there.
"""
import os, random, signal, subprocess, sys, tempfile, time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HERE = os.environ.get("EVICT_DIR") or tempfile.mkdtemp(prefix="play-evict-")
WINID = os.environ.get("EVICT_WINID")
SAMEBOY = REPO + "/tools/SameBoy/build/bin/SDL/sameboy"
ENV = dict(os.environ, MTOOLS_SKIP_CHECK="1")
RIGHT, LEFT, UP, DOWN, A, B, SELECT, START = (1 << i for i in range(8))


def name_hash(name):
    a, b = 5381, 0
    for c in name.upper().encode():
        a = (a * 33 + c) & 0xFFFF
        b = (b + a) & 0xFFFF
    return bytes([a >> 8, a & 255, b >> 8, b & 255])


AAA, BBB = name_hash("AAA.gb"), name_hash("BBB.gb")


def pack(entries):
    """entries: {hash: (launches, starred)} -> the 2048-byte file"""
    stars = sum(1 for l, s in entries.values() if s)
    out = bytearray(b"PL" + bytes([len(entries), stars]) + b"SO\x01\x00")
    for h in sorted(entries):
        l, s = entries[h]
        out += h + bytes([l & 255, l >> 8, 1 if s else 0, 0])
    return bytes(out.ljust(2048, b"\0"))


def unpack(data):
    assert data[:2] == b"PL", data[:8]
    n, stars = data[2], data[3]
    order, entries = [], {}
    for i in range(n):
        e = data[8 + 8 * i:16 + 8 * i]
        order.append(e[:4])
        entries[e[:4]] = (e[4] | e[5] << 8, bool(e[6] & 1))
    return n, stars, order, entries, data[8 + 8 * n:]


def random_hashes(rng, n):
    out = set()
    while len(out) < n:
        h = bytes(rng.randrange(256) for _ in range(4))
        if h not in (AAA, BBB):
            out.add(h)
    return sorted(out)


def table_min(rng):
    """one least-launched unstarred entry; decoys that a wrong test would pick"""
    hs = random_hashes(rng, 254)
    t = {h: (rng.randrange(3, 250), False) for h in hs}
    for h in rng.sample(hs, 40):
        t[h] = (t[h][0], True)
    plain = [h for h in hs if not t[h][1]]
    starred = [h for h in hs if t[h][1]]
    victim = plain[len(plain) // 2]
    t[victim] = (2, False)
    t[starred[0]] = (0, True)          # starred, never launched: must stay
    t[starred[1]] = (1, True)
    t[plain[0]] = (0x0100, False)      # low byte 0: must not read as 0
    t[plain[-1]] = (0x0201, False)     # low byte 1
    t[plain[3]] = (700, False)
    return t, victim


def table_tie(rng):
    hs = random_hashes(rng, 254)
    t = {h: (rng.randrange(5, 250), False) for h in hs}
    for h in rng.sample(hs, 30):
        t[h] = (t[h][0], True)
    plain = [h for h in hs if not t[h][1]]
    tied = [plain[2], plain[len(plain) // 2], plain[-3]]
    for h in tied:
        t[h] = (4, False)
    return t, tied


def table_all_starred(rng):
    hs = random_hashes(rng, 254)
    return {h: (rng.randrange(0, 250), True) for h in hs}


def table_one_plain(rng):
    """253 stars and one unstarred entry with a count past 255"""
    hs = random_hashes(rng, 254)
    t = {h: (rng.randrange(0, 250), True) for h in hs}
    victim = hs[200]
    t[victim] = (1000, False)
    return t, victim


class Run:
    def __init__(self, kernel, case, table, model="cgb"):
        self.dir = os.path.join(HERE, "run-" + case)
        subprocess.run(["rm", "-rf", self.dir]); os.makedirs(self.dir)
        self.img = self.dir + "/card.img"
        self.pad = self.dir + "/pad"
        self.before = pack(table)
        with open(self.img, "wb") as f:
            f.truncate(64 << 20)
        subprocess.run(["mformat", "-i", self.img, "-F", "-v", "EZJR", "::"], check=True, env=ENV)
        rom = self.dir + "/rom.bin"
        with open(rom, "wb") as f:
            f.write(bytes(32768))
        plays = self.dir + "/plays.bin"
        with open(plays, "wb") as f:
            f.write(self.before)
        for src, dst in ((rom, "AAA.gb"), (rom, "BBB.gb"), (plays, ".ezgbplays")):
            subprocess.run(["mcopy", "-i", self.img, src, "::/" + dst], check=True, env=ENV)
        with open(self.dir + "/psram.bin", "wb") as f:   # an empty cart with a live canary
            ps = bytearray(open(REPO + "/sd/psram.bin", "rb").read())
            ps[0x11 * 0x2000 + 0x300:0x11 * 0x2000 + 0x400] = bytes(256)   # no last ROM
            f.write(ps)
        self.key(0)
        env = dict(os.environ, SAMEBOY_EZFLASH_JR_IMG=self.img, SAMEBOY_EZFLASH_JR_PADFILE=self.pad)
        self.log = open(self.dir + "/sameboy.log", "w")
        self.p = subprocess.Popen([SAMEBOY, "--model", model, kernel], env=env,
                                  stdout=self.log, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL)
        self.shots = 0

    def key(self, mask):
        with open(self.pad + ".tmp", "w") as f:
            f.write("%02x\n" % mask)
        os.replace(self.pad + ".tmp", self.pad)

    def tap(self, mask, hold=0.15, after=0.6):
        self.key(mask); time.sleep(hold); self.key(0); time.sleep(after)

    def shot(self, tag):
        if not WINID:
            return
        self.shots += 1
        out = "%s/%d-%s.png" % (self.dir, self.shots, tag)
        wid = subprocess.run(["swift", WINID, str(self.p.pid)],
                             capture_output=True, text=True).stdout.strip()
        if wid:
            subprocess.run(["screencapture", "-x", "-o", "-l", wid, out])

    def finish(self):
        self.p.send_signal(signal.SIGTERM)
        try:
            self.p.wait(5)
        except subprocess.TimeoutExpired:
            self.p.kill()
        out = self.dir + "/after.bin"
        subprocess.run(["mcopy", "-n", "-i", self.img, "::/.ezgbplays", out], check=True, env=ENV)
        return open(out, "rb").read()

    def launch(self, rows_down=0):
        for _ in range(rows_down):
            self.tap(DOWN)
        self.shot("browser")
        self.tap(A, after=6)
        self.shot("launched")

    def star(self, rows_down=0):
        for _ in range(rows_down):
            self.tap(DOWN)
        self.shot("browser")
        self.key(A); time.sleep(1.2); self.key(0); time.sleep(0.8)
        self.shot("menu")
        self.tap(DOWN); self.tap(DOWN)
        self.shot("on-star")
        self.tap(A, after=5)
        self.shot("starred")


def check(tag, after, want, sort_ok=True):
    n, stars, order, got, tail = unpack(after)
    errs = []
    if n != len(want): errs.append("count %d, want %d" % (n, len(want)))
    ws = sum(1 for l, s in want.values() if s)
    if stars != ws: errs.append("stars %d, want %d" % (stars, ws))
    if order != sorted(order): errs.append("entries not sorted by hash")
    if len(set(order)) != len(order): errs.append("duplicate hash")
    gone = sorted(set(want) - set(got)); extra = sorted(set(got) - set(want))
    if gone: errs.append("missing " + ", ".join(h.hex() for h in gone))
    if extra: errs.append("unexpected " + ", ".join("%s %r" % (h.hex(), got[h]) for h in extra))
    for h in want:
        if h in got and got[h] != want[h]:
            errs.append("%s is %r, want %r" % (h.hex(), got[h], want[h]))
    if any(tail): errs.append("bytes after the table are not 0")
    print("%-14s %s" % (tag, "PASS" if not errs else "FAIL: " + "; ".join(errs)))
    return not errs


BOOT = 9


def main():
    kernel = sys.argv[1]
    model = os.environ.get("MODEL", "cgb")
    cases = sys.argv[2:] or ["launch-min", "launch-tie", "launch-allstar", "star-min", "star-allstar", "launch-oneplain"]
    ok = True
    for case in cases:
        rng = random.Random(case)
        if case == "launch-min":
            t, victim = table_min(rng)
            r = Run(kernel, case, t, model); time.sleep(BOOT); r.launch()
            want = dict(t); del want[victim]; want[AAA] = (1, False)
            ok &= check(case, r.finish(), want)
        elif case == "launch-tie":
            t, tied = table_tie(rng)
            r = Run(kernel, case, t, model); time.sleep(BOOT); r.launch()
            after = r.finish()
            got = unpack(after)[3]
            out = [h for h in tied if h not in got]
            want = dict(t); want[AAA] = (1, False)
            if len(out) == 1:
                del want[out[0]]
                print("  tie: dropped tied entry %d of %d in table order" % (tied.index(out[0]) + 1, len(tied)))
            ok &= check(case, after, want) and len(out) == 1
        elif case == "launch-allstar":
            t = table_all_starred(rng)
            r = Run(kernel, case, t, model); time.sleep(BOOT); r.launch()
            ok &= check(case, r.finish(), t)
        elif case == "star-min":
            t, victim = table_min(rng)
            r = Run(kernel, case, t, model); time.sleep(BOOT); r.star(1)
            want = dict(t); del want[victim]; want[BBB] = (0, True)
            ok &= check(case, r.finish(), want)
        elif case == "star-allstar":
            t = table_all_starred(rng)
            r = Run(kernel, case, t, model); time.sleep(BOOT); r.star(1)
            ok &= check(case, r.finish(), t)
        elif case == "launch-oneplain":
            t, victim = table_one_plain(rng)
            r = Run(kernel, case, t, model); time.sleep(BOOT); r.launch()
            want = dict(t); del want[victim]; want[AAA] = (1, False)
            ok &= check(case, r.finish(), want)
        else:
            sys.exit("unknown case " + case)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
