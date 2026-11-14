#!/usr/bin/env python3
"""Port FW4 stage1 names and notes to FW5-0918.

FW5-0918's stage1 is FW4's with one function added in front of main() and
17 bytes more in main(): bank 0 from $07F1 on sits $31 higher, bank 1 is
unchanged. The header also changes: SGB flag $03 and old licensee $33 (so
a Super Game Boy enables its features), and the checksums. Every other byte
that differs is an address moved by $31 (checked by --check). So FW4's kernel.sym and notes.json carry over with
that shift, plus the FW5-only names below.

    stage1/tools/stage1-port-sym.py --check    # verify the layout claim on the binaries
    stage1/tools/stage1-port-sym.py            # write fw5-0918/kernel.sym and notes.json
    stage1/tools/stage1-regen.sh fw5-0918      # then regenerate and compare

Needs both kernel.gb files (local, from stage1-from-bram.py) only for --check.
"""
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
FW4, FW5 = HERE / "fw4", HERE / "fw5-0918"

SPLIT = 0x07F1      # FW4 main; FW5 has FpgaSetBootCpu here
SHIFT = 0x31
BANK0_END = 0x4000

FW5_ONLY_SYMS = [(0, 0x07F1, "FpgaSetBootCpu")]
FW5_ONLY_NOTES = [{
    "bank": 0, "addr": "07f1",
    "lines": [
        "FW5 only. FpgaSetBootCpu(a): FPGA register $7FD3 = a. main() passes the boot ROM's A",
        "(_cpu, $C4AC) after the delay, half of the fast-load key (stage0/docs/firmware-diff.md).",
        "main() also turns sound off first (NR52 = 0). The rest differs from FW4 only in the header",
        "(SGB flag $03, old licensee $33) and addresses (stage1/tools/stage1-port-sym.py --check).",
    ],
}]


def port(bank, addr):
    if bank == 0 and addr == SPLIT:
        return SPLIT + 0x20        # main itself, after FpgaSetBootCpu
    if bank == 0 and SPLIT <= addr < BANK0_END:
        return addr + SHIFT
    return addr


def check():
    a = (FW4 / "kernel.gb").read_bytes()
    b = (FW5 / "kernel.gb").read_bytes()
    word = lambda x, i: x[i] | x[i + 1] << 8
    bad = []
    # header: SGB flag, old licensee, checksums; crt0's call to main
    expected = {0x0146: (0x00, 0x03), 0x014B: (0x00, 0x33)}
    for i, (x, y) in expected.items():
        if (a[i], b[i]) != (x, y):
            bad.append(i)
    skip = set(expected) | {0x014D, 0x014E, 0x014F}
    if word(b, 0x01DD) != SPLIT + 0x20 or word(a, 0x01DD) != SPLIT:
        bad.append(0x01DD)
    skip |= {0x01DD, 0x01DE}
    # bank 0 below main and bank 1: same bytes; bank 0 after main: shifted
    main_end4 = 0x083C          # main's first local label; FW5 adds 17 bytes before it
    spans = [(0, SPLIT, 0), (main_end4, BANK0_END - SHIFT, SHIFT), (0x4000, 0x8000, 0)]
    for lo, hi, d in spans:
        i = lo
        while i < hi:
            if a[i] == b[i + d] or i in skip:
                i += 1
                continue
            for j in (i - 1, i):
                if word(b, j + d) - word(a, j) == SHIFT and SPLIT <= word(a, j) < BANK0_END:
                    i = j + 2
                    break
            else:
                bad.append(i)
                i += 1
    # the FpgaSetBootCpu body is FpgaSetMode's with $7FD3 for $7FC0
    if b[0x07F1:0x0811] != a[0x073B:0x075B].replace(b"\xc0\x7f", b"\xd3\x7f"):
        bad.append(0x07F1)
    for x in bad:
        print(f"differs: FW4 {x:04x}")
    print("layout holds" if not bad else f"{len(bad)} unexplained differences")
    return not bad


def write():
    out = []
    for line in (FW4 / "kernel.sym").read_text().splitlines():
        m = re.match(r"([0-9a-f]{2}):([0-9a-f]{4}) (\S+)$", line)
        if not m:
            continue
        bank, addr, name = int(m[1], 16), int(m[2], 16), m[3]
        out.append((bank, port(bank, addr), name))
    out += FW5_ONLY_SYMS
    out.sort(key=lambda t: (t[2].startswith("."), t[0], t[1]))
    head = [
        "; stage1 (FW5 0918 bootstrap, BRAM contents) symbols for mgbdis.",
        "; Generated from ../fw4/kernel.sym by stage1/tools/stage1-port-sym.py: edit FW4's",
        "; and rerun. Regenerate: stage1/tools/stage1-regen.sh fw5-0918   (stage1/stock.md)",
        "",
    ]
    body = [f"{b:02x}:{a:04x} {n}" for b, a, n in out]
    (FW5 / "kernel.sym").write_text("\n".join(head + body) + "\n")

    notes = json.loads((FW4 / "notes.json").read_text())
    for blk in notes["blocks"]:
        blk["addr"] = f"{port(blk['bank'], int(blk['addr'], 16)):04x}"
    notes["blocks"] += FW5_ONLY_NOTES
    notes["blocks"].sort(key=lambda b: (b["bank"], int(b["addr"], 16)))
    (FW5 / "notes.json").write_text(json.dumps(notes, indent=2) + "\n")
    print(f"wrote {FW5 / 'kernel.sym'} ({len(out)} names) and notes.json")


if __name__ == "__main__":
    if "--check" in sys.argv:
        sys.exit(0 if check() else 1)
    write()
