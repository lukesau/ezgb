#!/usr/bin/env python3
"""LEFT/RIGHT on the SET tab jump the cursor to the top/bottom row, as they
do in the browser (docs/fastlaunch-set-tab.md).

Stock DrawTimeAutosaveScreen only uses LEFT/RIGHT to step through the date
and time fields while the time is being set (sp+$40 != 0); otherwise both
just `jp z, DrawTimeAutosaveScreen_redraw`. Those two jumps now go to:

  04:5f80  FlSetJumpTop     LEFT: cursor (sp+$3d) to row 0, TIME SET
  04:5f90  FlSetJumpBottom  RIGHT: cursor to row 10 (flcfg keeps it on the page: NEXT or PREV)

which end like hiliteDec/hiliteInc: mark the row changed (sp+$3e = 1) and
`jp FlSetRowsHook` (04:5948), which redraws the mod rows and the stock ones.
Already on that row: plain redraw, as before.

Written against the development base (1.05e-0731); port-mod.py carries it.
Usage: scripts/inject-set-jump.py 1.05e-0731 [--apply]
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(ROOT, "kernel", "tools")
REDRAW, ROWS_HOOK = 0x48f5, 0x5948      # DrawTimeAutosaveScreen_redraw, FlSetRowsHook
TOP, BOTTOM, LAST_ROW = 0x5f80, 0x5f90, 10


def handler(row):
    lo, hi = REDRAW & 0xFF, REDRAW >> 8
    test = [0xB7] if row == 0 else [0xFE, row]          # or a / cp row
    return bytes([0xF8, 0x3D, 0x7E, *test, 0xCA, lo, hi,  # ld hl,sp+$3d; ld a,[hl]; test; jp z,redraw
                  0x36, row, 0x23, 0x36, 0x01,            # ld [hl],row; inc hl; ld [hl],1
                  0xC3, ROWS_HOOK & 0xFF, ROWS_HOOK >> 8])  # jp FlSetRowsHook


def tool(*args):
    subprocess.run([sys.executable, os.path.join(TOOLS, args[0]), *args[1:]], check=True,
                   cwd=os.path.join(ROOT, "kernel"))


def main():
    if len(sys.argv) < 2 or sys.argv[1] != "1.05e-0731":
        sys.exit(__doc__)
    ver, apply = sys.argv[1], (["--apply"] if "--apply" in sys.argv[2:] else [])
    sym = open(os.path.join(ROOT, "re", "kernel", ver, "kernel.sym")).read()
    for addr, name, row in ((TOP, "FlSetJumpTop", 0), (BOTTOM, "FlSetJumpBottom", LAST_ROW)):
        if f"04:{addr:04x} {name}\n" not in sym:
            tool("inject_bytes.py", ver, "4", f"{addr:04x}", name, handler(row).hex(), *apply)
    redraw = f"ca{REDRAW & 0xFF:02x}{REDRAW >> 8:02x}"
    # the not-setting-the-time exits of LEFT (inputLoopFieldDec) and RIGHT
    # (fieldDecWrapFieldInc): xor a; ld hl,sp+$40; or [hl]; jp z, ...
    tool("patch_bytes.py", ver, "4", "5174", redraw, f"ca{TOP & 0xFF:02x}{TOP >> 8:02x}", *apply)
    tool("patch_bytes.py", ver, "4", "51a5", redraw, f"ca{BOTTOM & 0xFF:02x}{BOTTOM >> 8:02x}", *apply)


if __name__ == "__main__":
    main()
