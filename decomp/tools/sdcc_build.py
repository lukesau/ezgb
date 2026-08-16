#!/usr/bin/env python3
"""Shared SDCC compile/link helpers for verify.py and inject.py.

Compiles a C file with SDCC (sm83 target, legacy stack calling convention,
--sdcccall 0) to a .rel, then links it with sdld at chosen _CODE/_DATA
origins, applying --pin/--pins style absolute-address symbol resolution for
externs that reference existing kernel functions or WRAM. Returns the linked
.ihx path so the caller can extract raw bytes.
"""
import os
import re
import subprocess
import sys

REL_SYM_RE = re.compile(r"^S\s+(\S+)\s+(Ref|Def)")


def parse_ihx(ihx_path):
    """Return {address: byte} for all data records in an Intel HEX file."""
    out = {}
    with open(ihx_path) as f:
        for line in f:
            line = line.strip()
            if not line.startswith(":"):
                continue
            count = int(line[1:3], 16)
            addr = int(line[3:7], 16)
            rectype = int(line[7:9], 16)
            if rectype != 0x00:
                continue
            data = bytes.fromhex(line[9:9 + count * 2])
            for i, b in enumerate(data):
                out[addr + i] = b
    return out


def parse_rel_symbols(rel_path):
    """Return (refs, defs) symbol sets from an asxxxx .rel file."""
    refs = set()
    defs = set()
    with open(rel_path) as f:
        for line in f:
            m = REL_SYM_RE.match(line)
            if not m:
                continue
            sym, kind = m.group(1), m.group(2)
            if kind == "Ref":
                refs.add(sym)
            else:
                defs.add(sym)
    return refs, defs


def normalize_symbol(name):
    name = name.strip()
    if not name:
        raise ValueError("empty symbol name")
    if not name.startswith("_"):
        name = "_" + name
    return name


def parse_pin(spec):
    """Parse 'sym=addr' or 'sym addr' into ('_sym', 0xaddr)."""
    spec = spec.strip()
    if not spec or spec.startswith("#"):
        return None
    if "=" in spec:
        name, addr_s = spec.split("=", 1)
    else:
        parts = spec.split()
        if len(parts) != 2:
            raise ValueError(f"pin must be SYM=ADDR or 'SYM ADDR', got: {spec!r}")
        name, addr_s = parts
    addr_s = addr_s.strip().lower().removeprefix("0x").removeprefix("$")
    return normalize_symbol(name), int(addr_s, 16)


def load_pins_file(path):
    pins = []
    with open(path) as f:
        for lineno, line in enumerate(f, 1):
            try:
                pin = parse_pin(line)
            except ValueError as e:
                print(f"error: {path}:{lineno}: {e}")
                sys.exit(1)
            if pin:
                pins.append(pin)
    return pins


def find_sdldgb():
    for name in ("sdldgb", "sdld"):
        path = subprocess.run(["which", name], capture_output=True, text=True)
        if path.returncode == 0 and path.stdout.strip():
            return path.stdout.strip()
    print("error: sdldgb/sdld not found on PATH")
    sys.exit(1)


def compile_c(c_path, workdir, peep_path=None, pins=None, explicit_pin_syms=None,
              code_origin=0x0200, data_origin=0xc000):
    """Compile C to IHX, applying only pins referenced by the object file.

    code_origin/data_origin set the _CODE/_DATA link addresses. verify.py
    uses arbitrary placeholders (0x0200/0xc000) since it only diffs bytes of
    small, self-contained functions with no internal absolute self-reference.
    inject.py MUST pass the real final ROM address for code_origin: any
    internal absolute jp/call the function makes to itself needs to be
    encoded for where the bytes will actually live, not a placeholder.
    """
    pins = pins or []
    explicit_pin_syms = explicit_pin_syms or set()
    base = os.path.join(workdir, "out")
    rel_path = base + ".rel"
    ihx_path = base + ".ihx"
    lk_path = base + ".lk"

    cmd = [
        "sdcc", "-c", "-msm83", "--sdcccall", "0", "--no-std-crt0",
        c_path, "-o", rel_path,
    ]
    if peep_path:
        cmd[5:5] = ["--peep-file", peep_path]
    result = subprocess.run(cmd, cwd=workdir, capture_output=True, text=True)
    if result.returncode != 0:
        print("SDCC compile failed:")
        print(result.stdout)
        print(result.stderr)
        sys.exit(1)
    for w in result.stderr.splitlines():
        if "warning" in w.lower():
            print(f"  (sdcc) {w}")

    refs, defs = parse_rel_symbols(rel_path)
    pin_map = {sym: addr for sym, addr in pins}
    applied = sorted((s, pin_map[s]) for s in refs if s in pin_map)

    unused_explicit = sorted(explicit_pin_syms & set(pin_map) - refs)
    for sym in unused_explicit:
        print(f"  (pin) unused --pin {sym}=${pin_map[sym]:04x} (not referenced)")

    missing = sorted(refs - set(pin_map) - defs)
    if missing:
        print("error: unresolved extern(s) need --pin / --pins:")
        for sym in missing:
            print(f"  {sym}")
        sys.exit(1)

    # sdld errors if -g names a symbol that was never referenced, so only
    # emit pins that appear as Ref in the .rel.
    with open(lk_path, "w") as f:
        f.write("-mjwx\n")
        f.write(f"-i {ihx_path}\n")
        f.write(f"-b _CODE = 0x{code_origin:04x}\n")
        f.write(f"-b _DATA = 0x{data_origin:04x}\n")
        for sym, addr in applied:
            f.write(f"-g{sym}=0x{addr:04x}\n")
        f.write(f"{rel_path}\n")
        f.write("-e\n")

    sdld = find_sdldgb()
    link = subprocess.run([sdld, "-nf", lk_path], cwd=workdir, capture_output=True, text=True)
    if link.returncode != 0 or not os.path.exists(ihx_path):
        print("sdld link failed:")
        print(link.stdout)
        print(link.stderr)
        sys.exit(1)
    for w in (link.stdout + link.stderr).splitlines():
        if "warning" in w.lower() or "error" in w.lower():
            print(f"  (sdld) {w}")

    return ihx_path, applied


def resolve_peep(peep_arg, tools_dir, repo_root):
    if not peep_arg:
        return None
    if os.path.isabs(peep_arg) and os.path.exists(peep_arg):
        return peep_arg
    for candidate in (
        peep_arg,
        os.path.join(tools_dir, peep_arg),
        os.path.join(tools_dir, "peeps", peep_arg),
        os.path.join(repo_root, peep_arg),
    ):
        if os.path.exists(candidate):
            return os.path.abspath(candidate)
    print(f"error: peep file not found: {peep_arg}")
    sys.exit(1)


def rom_offset(bank, address):
    """CPU address (bank:addr, as used throughout this repo) -> flat file
    offset into kernel.gb. Bank 0 is not bankswitched (CPU $0000-$3fff maps
    straight to file offset 0); ROMX banks map their $4000-$7fff window."""
    if bank == 0:
        return address
    return bank * 0x4000 + (address - 0x4000)


def resolve_pins_file(path, tools_dir, repo_root):
    if os.path.isabs(path) and os.path.exists(path):
        return path
    for candidate in (
        path,
        os.path.join(tools_dir, path),
        os.path.join(tools_dir, "pins", path),
        os.path.join(repo_root, path),
    ):
        if os.path.exists(candidate):
            return os.path.abspath(candidate)
    print(f"error: pins file not found: {path}")
    sys.exit(1)
