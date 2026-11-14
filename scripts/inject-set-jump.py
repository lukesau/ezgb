#!/usr/bin/env python3
"""LEFT/RIGHT on the SET tab jump the cursor to the page's PREV/NEXT button
(docs/fastlaunch-set-tab.md); until 2026-11-10, to the top/bottom row, as
they do in the browser.

Stock DrawTimeAutosaveScreen only uses LEFT/RIGHT to step through the date
and time fields while the time is being set (sp+$40 != 0); otherwise both
just `jp z, DrawTimeAutosaveScreen_redraw`. Those two jumps now go to:

  04:5f80  FlSetJumpTop     LEFT: cursor (sp+$3d) = $FE, which flcfg op ROWS makes the page's PREV
  04:5f90  FlSetJumpBottom  RIGHT: cursor = $FF, the page's NEXT

which end like hiliteDec/hiliteInc: mark the row changed (sp+$3e = 1) and
`jp FlSetRowsHook` (04:5948), which redraws the mod rows and the stock ones.
Every page has both buttons since 2026-11-10 (the pages go round), so
neither tests the row it is on any more.

Written against the development base (1.05e-0731); port-mod.py carries it.
Usage: scripts/inject-set-jump.py 1.05e-0731 [--apply]
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(ROOT, "kernel", "mod", "tools")
REDRAW, ROWS_HOOK = 0x48f5, 0x5948      # DrawTimeAutosaveScreen_redraw, FlSetRowsHook
TOP, BOTTOM = 0x5f80, 0x5f90


def handler(mark):
    return bytes([0xF8, 0x3D,                             # ld hl,sp+$3d
                  0x36, mark, 0x23, 0x36, 0x01,           # ld [hl],mark; inc hl; ld [hl],1
                  0xC3, ROWS_HOOK & 0xFF, ROWS_HOOK >> 8])  # jp FlSetRowsHook


def tool(*args):
    subprocess.run([sys.executable, os.path.join(TOOLS, args[0]), *args[1:]], check=True,
                   cwd=os.path.join(ROOT, "kernel", "mod"))


def main():
    if len(sys.argv) < 2 or sys.argv[1] != "1.05e-0731":
        sys.exit(__doc__)
    ver, apply = sys.argv[1], (["--apply"] if "--apply" in sys.argv[2:] else [])
    sym = open(os.path.join(ROOT, "re", "kernel", ver, "kernel.sym")).read()
    for addr, name, mark in ((TOP, "FlSetJumpTop", 0xFE), (BOTTOM, "FlSetJumpBottom", 0xFF)):
        if f"04:{addr:04x} {name}\n" not in sym:
            tool("inject_bytes.py", ver, "4", f"{addr:04x}", name, handler(mark).hex(), *apply)
    redraw = f"ca{REDRAW & 0xFF:02x}{REDRAW >> 8:02x}"
    # the not-setting-the-time exits of LEFT (inputLoopFieldDec) and RIGHT
    # (fieldDecWrapFieldInc): xor a; ld hl,sp+$40; or [hl]; jp z, ...
    tool("patch_bytes.py", ver, "4", "5174", redraw, f"ca{TOP & 0xFF:02x}{TOP >> 8:02x}", *apply)
    tool("patch_bytes.py", ver, "4", "51a5", redraw, f"ca{BOTTOM & 0xFF:02x}{BOTTOM >> 8:02x}", *apply)


if __name__ == "__main__":
    main()
