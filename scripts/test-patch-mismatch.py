#!/usr/bin/env python3
"""What happens when a patch is applied to the wrong stock file.

A plain IPS patcher writes a patch's bytes over any file it is given, so the
release has to survive every mix-up (docs/distribution.md, "Wrong patch"):

  firmware  every updater patch on every other stock updater: what the
            updater would write to slot B (file $8000, 149,516 bytes, the
            write loop in docs/updater-flash-write.md) must fail its
            bitstream CRC, so the FPGA never configures from it and the
            boot tally keeps the cart on slot A. Correct and stock images
            must pass, or the check proves nothing.
  kernel    (--boot) every kernel patch on every stock kernel, booted in
            SameBoy for ~15 s: a mismatched kernel must never write the SD
            card or touch $7FD2/$7FD3 (the config-flash register), and the
            1.05e-0731 / 1.05e-0918 mixes must stop on the WRONG PATCH
            screen (kernel/src/patch_guard.c). Screenshots land in --out.

    scripts/test-patch-mismatch.py [--boot] [--out DIR]

Exit status 1 if any case fails.
"""
import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts"))
kp = __import__("kernel-patch")

UPDATERS = {"fw4": "juniorkernel-1.04e-FW4/Update_FW4.gb",
            "fw5-0731": "juniorkernel-1.05e-FW5-0731/Update_FW5_7-31.gb",
            "fw5-0918": "juniorkernel-1.05e-FW5-0918/Update_FW5_2021-9-18.gb"}
KERNELS = ["1.04e", "1.05e-0731", "1.05e-0918"]
SLOT_B = (0x8000, 0x2480C)


def be16(d, p):
    return d[p] << 8 | d[p + 1]


def crcs(d):
    """Each CRC packet of a Spartan-3A config stream: 'ok', 'BAD' or 'bypass'
    (CRC checking switched off). Mirrors s3patch's fix_crc, read-only."""
    pos = d.find(b"\xaa\x99")
    if pos < 0:
        return ["no sync"]
    pos += 2
    crc, bypass, res = 0, False, []

    def upd(c, reg, val):
        c = (c << 1) & 0xFFFFFFFF
        if c & 0x400000:
            c ^= 0x409081
        return c ^ (val | reg << 16)
    try:
        while pos + 2 <= len(d):
            ph = be16(d, pos)
            pos += 2
            if ph == 0x2000:
                continue
            if ph >> 11 == 6:
                reg, num = ph >> 5 & 0x3F, ph & 0x1F
                if reg not in (0, 9, 0x12):
                    for i in range(num):
                        crc = upd(crc, reg, be16(d, pos + i * 2))
                if reg == 0 and num == 2:
                    res.append("bypass" if bypass else
                               "ok" if int.from_bytes(d[pos:pos + 4], "big") == crc else "BAD")
                if reg == 5 and num == 1 and be16(d, pos) == 7:
                    crc = 0
                if reg == 0xA and num == 1:
                    bypass = be16(d, pos) & 0x10 != 0
                pos += num * 2
            elif ph >> 11 == 0xA:
                reg, num = ph >> 5 & 0x3F, int.from_bytes(d[pos:pos + 4], "big")
                pos += 4
                for i in range(num):
                    crc = upd(crc, reg, be16(d, pos + i * 2))
                pos += num * 2
            else:
                return res + ["unparseable"]
    except IndexError:
        return res + ["truncated"]
    return res


def firmware():
    ok = True
    print("firmware: slot B written by each patched updater")
    stock = {k: open(os.path.join(ROOT, v), "rb").read() for k, v in UPDATERS.items()}
    patches = {fw: open(os.path.join(ROOT, kp.UPDATER_DIR, f"ezgb-updater-{fw}.ips"), "rb").read()
               for fw in kp.UPDATER_STOCK}
    for u, s in stock.items():
        r = crcs(s[SLOT_B[0]:SLOT_B[0] + SLOT_B[1]])
        good = r and all(x == "ok" for x in r)
        ok &= good
        print(f"  stock {u:9s}                    CRCs {' '.join(r):12s} {'pass' if good else 'FAIL (expected valid)'}")
    for p, ips in patches.items():
        for u, s in stock.items():
            r = crcs(kp.apply_ips(s, ips)[SLOT_B[0]:SLOT_B[0] + SLOT_B[1]])
            right = os.path.join(ROOT, kp.UPDATER_STOCK[p]) == os.path.join(ROOT, UPDATERS[u])
            good = (all(x == "ok" for x in r) if right else
                    "ok" not in r and "bypass" not in r)
            ok &= good
            what = "its own updater" if right else "the wrong updater"
            print(f"  {p:8s} patch on {u:9s} ({what:17s}) CRCs {' '.join(r):12s} {'pass' if good else 'FAIL'}")
    return ok


def kernels(out):
    ok = True
    print("kernel: every patch on every stock kernel, booted in SameBoy")
    sameboy = os.environ.get("SAMEBOY", os.path.join(ROOT, "tools", "SameBoy", "build", "bin", "SDL", "sameboy"))
    winid = os.path.join(out, "winid")
    subprocess.run(["swiftc", "-O", os.path.join(ROOT, "scripts", "showcase", "winid.swift"), "-o", winid], check=True)
    stock = {v: open(os.path.join(ROOT, "re", "kernel", v, "kernel.gb.orig"), "rb").read() for v in KERNELS}
    for base in KERNELS:
        for p in KERNELS:
            tag = f"{p}-on-{base}"
            d = os.path.join(out, tag)
            os.makedirs(d, exist_ok=True)
            dat = os.path.join(d, "ezgb.dat")
            open(dat, "wb").write(kp.apply_ips(stock[base], open(os.path.join(kp.PATCH_DIR, f"ezgb-{p}.ips"), "rb").read()))
            card = os.path.join(d, "card.img")
            shutil.copy(os.path.join(ROOT, "sd", "card.img"), card)
            subprocess.run(["mcopy", "-o", "-i", card, dat, "::ezgb.dat"], check=True)
            before = hashlib.md5(open(card, "rb").read()).hexdigest()
            env = dict(os.environ, SAMEBOY_EZFLASH_JR_IMG=card, SAMEBOY_EZFLASH_JR_LOG="1")
            env.pop("SAMEBOY_EZFLASH_JR_DRY", None)
            with open(os.path.join(d, "log"), "w") as log:
                pr = subprocess.Popen([sameboy, "--model", "dmg", dat], env=env, stdout=log, stderr=log)
                time.sleep(14)
                w = subprocess.run([winid, str(pr.pid)], capture_output=True, text=True).stdout.strip()
                if w:
                    subprocess.run(["screencapture", "-x", "-o", "-l", w, os.path.join(d, "shot.png")])
                pr.terminate()
                pr.wait()
            text = open(os.path.join(d, "log"), errors="replace").read()
            flash = len(re.findall(r"commit last=\$7fd[23]", text, re.I))
            writes = len(re.findall(r"SD: WRITE", text))
            changed = hashlib.md5(open(card, "rb").read()).hexdigest() != before
            good = not flash and not writes and not changed
            ok &= good
            note = "" if p == base else "  (screenshot: expect WRONG PATCH for 0731/0918, blank for a 1.04e mix)"
            print(f"  {tag:26s} flash commits {flash}  SD writes {writes}  card changed {changed}  "
                  f"{'pass' if good else 'FAIL'}{note}")
    return ok


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--boot", action="store_true", help="also boot every kernel mix in SameBoy")
    ap.add_argument("--out", help="where the kernel runs go (default: a temp dir)")
    a = ap.parse_args()
    ok = firmware()
    if a.boot:
        out = a.out or tempfile.mkdtemp(prefix="ezgb-mismatch-")
        ok &= kernels(out)
        print(f"kernel runs and screenshots: {out}")
    print("all cases pass" if ok else "FAILURES above")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
