#!/usr/bin/env python3
"""Launch SameBoy with a preloaded debugger script (and optional auto-dump).

SameBoy has no --debugger-script flag. This drives the SDL debugger over a PTY:
  1. Start with -s (stop before first instruction)
  2. Feed breakpoints/watches from scripts/debug/*.sbd
  3. Interactive: hand the terminal back to you
     --trace: on each Breakpoint/Watchpoint, run dump-launch.sbd then continue

Examples:
  ./scripts/run-sameboy-debug.sh
  ./scripts/run-sameboy-debug.sh --trace
  ./scripts/run-sameboy-debug.sh --version 1.04e --script scripts/debug/launch.sbd
"""

import argparse
import errno
import os
import pty
import re
import select
import signal
import sys
import time


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DEFAULT_SCRIPT = os.path.join(ROOT, "scripts", "debug", "launch.sbd")
DEFAULT_DUMP = os.path.join(ROOT, "scripts", "debug", "dump-launch.sbd")

STOP_RE = re.compile(r"(Breakpoint \d+:|Watchpoint \d+:)")
PROMPT_RE = re.compile(r"(Stopped>\s*$|>\s*$)", re.M)


def read_sbd(path):
    lines = []
    with open(path) as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            lines.append(line)
    return lines


def ensure_kernel_sym(version):
    """SameBoy loads <rom>.sym next to the ROM; mgbdis emits game.sym."""
    kernel = os.path.join(ROOT, "re", version, "kernel.gb")
    sym = os.path.join(ROOT, "re", version, "kernel.sym")
    game_sym = os.path.join(ROOT, "re", version, "disassembly", "game.sym")
    if not os.path.isfile(kernel):
        sys.exit(f"error: missing {kernel} (copy ezgb.dat there)")
    if os.path.isfile(game_sym):
        if os.path.islink(sym) or os.path.isfile(sym):
            os.remove(sym)
        os.symlink(os.path.relpath(game_sym, os.path.dirname(sym)), sym)
    return kernel


def find_sameboy():
    path = os.environ.get(
        "SAMEBOY",
        os.path.join(ROOT, "tools", "SameBoy", "build", "bin", "SDL", "sameboy"),
    )
    if not os.path.isfile(path):
        sys.exit(
            f"error: SameBoy not found at {path}\n"
            "       run ./scripts/setup-sameboy.sh && "
            "cd tools/SameBoy && make CONF=debug sdl"
        )
    return path


def ensure_sd_img():
    img = os.environ.get("SAMEBOY_EZFLASH_JR_IMG")
    if img and os.path.isfile(img):
        return os.path.abspath(img)
    candidate = os.path.join(ROOT, "sd", "card.img")
    if os.path.isfile(candidate):
        return candidate
    print(
        "warning: no sd/card.img (run ./scripts/make-sd-image.sh); "
        "stub will search upward from cwd",
        file=sys.stderr,
    )
    return None


def write_cmds(fd, lines, delay=0.02):
    for line in lines:
        os.write(fd, (line + "\n").encode())
        time.sleep(delay)


def drain(fd, timeout=0.05):
    chunks = []
    end = time.time() + timeout
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], max(0, end - time.time()))
        if not r:
            break
        try:
            data = os.read(fd, 65536)
        except OSError as e:
            if e.errno == errno.EIO:
                break
            raise
        if not data:
            break
        chunks.append(data)
        end = time.time() + timeout
    return b"".join(chunks)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--version", default="1.05e", help="kernel version dir under re/")
    ap.add_argument("--script", default=DEFAULT_SCRIPT, help="debugger init .sbd")
    ap.add_argument("--dump", default=DEFAULT_DUMP, help="commands to run on each stop (--trace)")
    ap.add_argument(
        "--trace",
        action="store_true",
        help="auto-dump registers/WRAM on each break/watch, then continue",
    )
    ap.add_argument(
        "--log",
        default=None,
        help="append trace output to this file (default: scripts/debug/launch-trace.log)",
    )
    ap.add_argument(
        "--max-stops",
        type=int,
        default=80,
        help="with --trace, stop auto-continue after N hits (default 80)",
    )
    args = ap.parse_args()

    sameboy = find_sameboy()
    kernel = ensure_kernel_sym(args.version)
    img = ensure_sd_img()
    init_cmds = read_sbd(args.script)
    dump_cmds = read_sbd(args.dump) if args.trace else []

    log_path = args.log
    if args.trace and not log_path:
        log_path = os.path.join(ROOT, "scripts", "debug", "launch-trace.log")

    env = os.environ.copy()
    if img:
        env["SAMEBOY_EZFLASH_JR_IMG"] = img
    # Keep a real TERM so SameBoy's console initializes; PTY supplies the tty.
    env.setdefault("TERM", "xterm-256color")

    print(f"ROM:     {kernel}")
    if img:
        print(f"SD img:  {img}")
    print(f"script:  {args.script}")
    if args.trace:
        print(f"trace:   on (dump={args.dump}, log={log_path})")
        print("Navigate the browser and press A on a .GB — stops dump automatically.")
    else:
        print("Interactive: breakpoints preloaded. A on a .GB to open.")
        print("At a stop, useful paste:  scripts/debug/dump-launch.sbd")
    print()

    log_f = open(log_path, "a") if log_path else None
    if log_f:
        log_f.write(f"\n=== {time.strftime('%Y-%m-%d %H:%M:%S')} trace start ===\n")
        log_f.flush()

    pid, fd = pty.fork()
    if pid == 0:
        os.chdir(os.path.join(ROOT, "tools", "SameBoy"))
        os.execve(sameboy, [sameboy, "-s", kernel], env)

    # Child is SameBoy; parent drives the debugger.
    buf = b""
    stops = 0
    fed_init = False
    interactive = not args.trace
    want_exit = False

    def on_sigint(_signum, _frame):
        nonlocal want_exit
        # First Ctrl+C → SIGINT SameBoy (break into debugger).
        # Second → quit the wrapper.
        if want_exit:
            raise KeyboardInterrupt
        want_exit = True
        try:
            os.kill(pid, signal.SIGINT)
        except OSError:
            pass

    signal.signal(signal.SIGINT, on_sigint)

    try:
        time.sleep(0.3)  # let SDL console thread start
        while True:
            rlist = [fd]
            if interactive and fed_init:
                rlist.append(sys.stdin.fileno())
            r, _, _ = select.select(rlist, [], [], 0.2)
            if not r and not fed_init:
                # Still waiting for first debugger prompt after -s
                chunk = drain(fd, 0.1)
                if chunk:
                    buf += chunk
                    sys.stdout.buffer.write(chunk)
                    sys.stdout.buffer.flush()
                    if log_f:
                        log_f.write(chunk.decode("utf-8", "replace"))
                if PROMPT_RE.search(buf.decode("utf-8", "replace")) or len(buf) > 200:
                    write_cmds(fd, init_cmds)
                    fed_init = True
                    buf = b""
                continue

            if fd in r:
                try:
                    data = os.read(fd, 65536)
                except OSError as e:
                    if e.errno == errno.EIO:
                        break
                    raise
                if not data:
                    break
                buf += data
                sys.stdout.buffer.write(data)
                sys.stdout.buffer.flush()
                if log_f:
                    log_f.write(data.decode("utf-8", "replace"))
                    log_f.flush()

                if not fed_init:
                    text = buf.decode("utf-8", "replace")
                    if PROMPT_RE.search(text) or b"Breakpoint" in buf or len(buf) > 200:
                        write_cmds(fd, init_cmds)
                        fed_init = True
                        buf = b""
                    continue

                if args.trace:
                    text = buf.decode("utf-8", "replace")
                    if STOP_RE.search(text) and PROMPT_RE.search(text):
                        stops += 1
                        if log_f:
                            log_f.write(f"\n--- auto dump #{stops} ---\n")
                            log_f.flush()
                        write_cmds(fd, dump_cmds)
                        # $7fe0=$80 replaces the kernel ROM — stop auto-continue
                        boot = re.search(
                            r"Watchpoint.*7fe0.*\$80|\[.*7fe0.*\].*=\s*\$80",
                            text,
                            re.I,
                        )
                        if boot:
                            print(
                                "\n[trace] $7fe0=$80 — leaving debugger stopped "
                                "(delete leftover BPs before continuing into the game)",
                                file=sys.stderr,
                            )
                            interactive = True
                            args.trace = False
                        elif stops >= args.max_stops:
                            print(
                                f"\n[trace] hit --max-stops={args.max_stops}; "
                                "leaving debugger stopped",
                                file=sys.stderr,
                            )
                            interactive = True
                            args.trace = False
                        else:
                            write_cmds(fd, ["continue"])
                        buf = b""

            if interactive and fed_init and sys.stdin.fileno() in r:
                try:
                    user = os.read(sys.stdin.fileno(), 65536)
                except OSError:
                    break
                if not user:
                    break
                os.write(fd, user)
                want_exit = False

    except KeyboardInterrupt:
        print("\n[interrupted]", file=sys.stderr)
    finally:
        try:
            os.close(fd)
        except OSError:
            pass
        try:
            os.kill(pid, signal.SIGTERM)
        except OSError:
            pass
        try:
            os.waitpid(pid, 0)
        except OSError:
            pass
        if log_f:
            log_f.write(f"=== trace end ({stops} stops) ===\n")
            log_f.close()


if __name__ == "__main__":
    main()
