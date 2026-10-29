#!/usr/bin/env python3
"""Screenshot stage1's boot screens for the README banner.

Stage1 moves through its screens in a few frames, so this drives SameBoy's
debugger over a PTY and stops at stage1's functions (addresses from the
link map, fpga/stage1/build/stage1.map) to hold each screen for a capture:

  splash.png    first fat_mount: the wordmark, LOADING... and the version
  prompt.png    the pending-save prompt (BACK UP SAVE? B:NO A:YES), which
                waits for a key on its own
  saving.png    a later fat_write after A: SAVING...
  launch.png    fat_load_command inside game_launch: LOADING... and the
                fast-launch target's name, the last frame before LCD off

The card is a copy of <card> with FLAUNCH= set to the target, the target's
save in /SAVER, and a psram.bin holding a pending-backup stamp for it (AUTO
SAVE off, so the prompt shows).

    stage1-shots.py <card.img> <outdir> --keys <keys bin> --winid <winid bin>
"""
import argparse
import errno
import os
import pty
import re
import select
import shutil
import signal
import subprocess
import sys
import time

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
STAGE1 = os.path.join(ROOT, "fpga", "stage1", "stage1.gb")
MAP = os.path.join(ROOT, "fpga", "stage1", "build", "stage1.map")
SAMEBOY = os.environ.get("SAMEBOY", os.path.join(ROOT, "tools", "SameBoy", "build", "bin", "SDL", "sameboy"))
TARGET = "/Pokemon/Pokemon Red.gb"
SAVE = "/SAVER/Pokemon Red.sav"
KEY_A = 7                     # SameBoy default: X
SPIN = 0xDC00                 # free WRAM: stage1 data ends below $CC00, the hand-off copy sits at $D000
SAVING_HIT = 24               # fat_write calls before the SAVING... capture (frames to paint it)


def syms():
    out = {}
    for addr, name in re.findall(r"([0-9A-F]{8})\s+(_\w+)\s", open(MAP).read()):
        out[name] = int(addr, 16)
    return out


def mtools(*args):
    subprocess.run(args, check=True, stdout=subprocess.DEVNULL)


def make_card(src, wd):
    card = os.path.join(wd, "card.img")
    shutil.copy(src, card)
    cfg = os.path.join(wd, "ezgb.cfg")
    with open(cfg, "wb") as f:
        f.write(f"FLAUNCH={TARGET}\r\n".encode())
    mtools("mcopy", "-o", "-i", card, cfg, "::/EZGB.CFG")
    # any 32 KB save will do: it is only shown by name and written back
    sav = os.path.join(wd, "game.sav")
    with open(sav, "wb") as f:
        f.write(bytes((i * 7) & 0xFF for i in range(32768)))
    mtools("mcopy", "-o", "-i", card, sav, "::" + SAVE)
    ps = bytearray(256 * 1024)
    ps[:32768] = open(sav, "rb").read()
    m = 0x11 * 0x2000
    path = SAVE.encode()
    ps[m] = 0xAA                          # pending backup
    ps[m + 1] = 4                         # 4 x 8 KB
    ps[m + 0xF] = len(path)
    ps[m + 0x10:m + 0x10 + len(path)] = path
    ps[m + 0x200] = 0                     # AUTO SAVE off: ask
    ps[m + 0x201] = 0x88                  # battery canary alive
    open(os.path.join(wd, "psram.bin"), "wb").write(ps)
    return card


class Debugger:
    def __init__(self, fd):
        self.fd = fd
        self.buf = b""

    def read(self, timeout):
        end = time.time() + timeout
        while time.time() < end:
            r, _, _ = select.select([self.fd], [], [], max(0, end - time.time()))
            if not r:
                continue
            try:
                data = os.read(self.fd, 65536)
            except OSError as e:
                if e.errno == errno.EIO:
                    break
                raise
            if not data:
                break
            self.buf += data
            return True
        return False

    def wait_for(self, pattern, timeout):
        rx = re.compile(pattern)
        end = time.time() + timeout
        while time.time() < end:
            m = rx.search(self.buf.decode("latin-1"))
            if m:
                self.buf = self.buf[m.end():]
                return m
            self.read(0.2)
        sys.exit(f"stage1-shots: timed out waiting for {pattern!r}; debugger said:\n"
                 + self.buf.decode("latin-1")[-800:])

    def cmd(self, line):
        os.write(self.fd, (line + "\n").encode())
        time.sleep(0.05)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("card")
    ap.add_argument("outdir")
    ap.add_argument("--keys", required=True)
    ap.add_argument("--winid", required=True)
    ap.add_argument("--model", default="dmg")
    a = ap.parse_args()
    for p in (STAGE1, MAP, SAMEBOY):
        if not os.path.isfile(p):
            sys.exit(f"stage1-shots: missing {p} (stage1/build.sh, scripts/setup-sameboy.sh)")
    s = syms()
    os.makedirs(a.outdir, exist_ok=True)
    wd = os.path.join(a.outdir, "card")
    os.makedirs(wd, exist_ok=True)
    card = make_card(a.card, wd)

    env = os.environ.copy()
    env["SAMEBOY_EZFLASH_JR_IMG"] = card
    env.setdefault("TERM", "xterm-256color")
    env.pop("SAMEBOY_EZFLASH_JR_DRY", None)
    pid, fd = pty.fork()
    if pid == 0:
        os.execve(SAMEBOY, [SAMEBOY, "--model", a.model, "-s", STAGE1], env)
    dbg = Debugger(fd)

    def window():
        for _ in range(40):
            w = subprocess.run([a.winid, str(pid)], capture_output=True, text=True).stdout.strip()
            if w:
                return w
            time.sleep(0.25)
        sys.exit("stage1-shots: SameBoy window not found")

    def shot(name, pc):
        """Stopped at pc: park the CPU on a `jr -2` in free WRAM so the LCD
        keeps showing this screen while the window repaints (a stopped
        debugger leaves the window on an older frame), capture, then break
        back in and resume at pc."""
        dbg.cmd("delete")
        dbg.cmd(f"eval [${SPIN:04x}] = $18")
        dbg.cmd(f"eval [${SPIN + 1:04x}] = $fe")
        dbg.cmd(f"eval pc = ${SPIN:04x}")
        dbg.cmd("continue")
        time.sleep(1.0)
        subprocess.run(["screencapture", "-x", "-o", "-l", window(), os.path.join(a.outdir, name)], check=True)
        print(f"  {name}")
        dbg.read(0.2)
        dbg.buf = b""
        os.kill(pid, signal.SIGINT)
        dbg.wait_for(r">", 10)
        dbg.cmd(f"eval pc = ${pc:04x}")

    def brk(sym):
        dbg.cmd(f"breakpoint ${s[sym]:04x}")

    try:
        dbg.wait_for(r">", 15)
        brk("_fat_mount")
        dbg.cmd("continue")
        dbg.wait_for(r"Breakpoint \d+:", 30)
        shot("splash.png", s["_fat_mount"])
        dbg.cmd("continue")

        time.sleep(4)                     # backup_offer draws the prompt and waits for a key
        subprocess.run(["screencapture", "-x", "-o", "-l", window(), os.path.join(a.outdir, "prompt.png")], check=True)
        print("  prompt.png")
        brk("_fat_write")
        subprocess.run([a.keys, str(pid), str(KEY_A), "1"], check=True)
        for _ in range(SAVING_HIT):
            dbg.wait_for(r"Breakpoint \d+:", 30)
            dbg.cmd("continue")
        dbg.wait_for(r"Breakpoint \d+:", 30)
        shot("saving.png", s["_fat_write"])
        brk("_fat_load_command")
        dbg.cmd("continue")
        dbg.wait_for(r"Breakpoint \d+:", 60)
        shot("launch.png", s["_fat_load_command"])
    finally:
        os.kill(pid, 9)
        os.waitpid(pid, 0)


if __name__ == "__main__":
    main()
