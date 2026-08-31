#!/usr/bin/env python3
"""Make or apply IPS patches for the modded EZ Flash Jr kernel.

The repo never distributes EZ Flash's firmware; what it CAN distribute is the
difference between the stock kernel and the modded one — which is exactly the
injected code this project wrote. That difference ships as a standard IPS
patch in patches/kernel/, so end users can apply it with this script or with
any ordinary IPS tool (Flips, Lunar IPS, an online ROM patcher).

patches/kernel/manifest.json records the md5 of the stock base and of the
expected result for each firmware version, so both sides of the patch are
verified — a patch applied to the wrong base silently produces garbage, and
IPS itself carries no checksums.

patches/kernel/VERSION holds the mod version ("N.M"). Regenerating the
patches bumps M automatically when any patch's content changed; N is bumped
by hand when a feature lands (edit the file — the next content-changing
regen then produces N.1, N.2, ...).

Usage:
  # Maintainer: regenerate all patches after changing injections
  #   diffs re/<ver>/kernel.gb.orig (stock) -> re/<ver>/kernel.gb (modded)
  scripts/kernel-patch.py make

  # User: patch an official ezgb.dat (version auto-detected by md5)
  scripts/kernel-patch.py apply ~/Downloads/ezgb.dat -o /Volumes/EZGB/ezgb.dat
"""
import argparse
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PATCH_DIR = os.path.join(ROOT, "patches", "kernel")
MANIFEST = os.path.join(PATCH_DIR, "manifest.json")
VERSION_FILE = os.path.join(PATCH_DIR, "VERSION")

# IPS record layout: 3-byte offset, 2-byte size, then `size` bytes.
# size 0 means RLE: 2-byte run length, 1 byte to repeat.
IPS_HEADER = b"PATCH"
IPS_FOOTER = b"EOF"
# A record whose offset spells "EOF" would end the patch early; writers must
# start such a record one byte earlier. (Unreachable for this 160KB ROM, but
# the format demands it.)
EOF_OFFSET = 0x454F46
MAX_RECORD = 0xFFFF
# Join diff runs separated by up to this many equal bytes. 0 = exact diffs
# only: a couple more records, but the patch then contains not a single byte
# of the stock firmware — only code this project wrote.
JOIN_GAP = 0


def md5(data):
    return hashlib.md5(data).hexdigest()


def load_manifest():
    if not os.path.isfile(MANIFEST):
        return {}
    with open(MANIFEST) as f:
        return json.load(f)


def read_mod_version():
    if not os.path.isfile(VERSION_FILE):
        return None
    raw = open(VERSION_FILE).read().strip()
    n, _, m = raw.partition(".")
    if not (n.isdigit() and m.isdigit()):
        sys.exit(f"error: {VERSION_FILE} must contain N.M, got {raw!r}")
    return int(n), int(m)


def write_mod_version(n, m):
    with open(VERSION_FILE, "w") as f:
        f.write(f"{n}.{m}\n")


def diff_runs(old, new):
    """[(offset, length)] of differing runs, nearby runs joined."""
    runs = []
    i, n = 0, len(old)
    while i < n:
        if old[i] == new[i]:
            i += 1
            continue
        start = i
        while i < n and old[i] != new[i]:
            i += 1
        prev_end = runs[-1][0] + runs[-1][1] if runs else None
        if runs and start - prev_end <= JOIN_GAP:
            runs[-1] = (runs[-1][0], i - runs[-1][0])
        else:
            runs.append((start, i - start))
    return runs


def write_ips(runs, new, path):
    with open(path, "wb") as f:
        f.write(IPS_HEADER)
        for offset, length in runs:
            if offset == EOF_OFFSET:
                offset -= 1
                length += 1
            while length > 0:
                chunk = min(length, MAX_RECORD)
                f.write(offset.to_bytes(3, "big"))
                f.write(chunk.to_bytes(2, "big"))
                f.write(new[offset:offset + chunk])
                offset += chunk
                length -= chunk
        f.write(IPS_FOOTER)


def apply_ips(base, patch):
    if patch[:5] != IPS_HEADER:
        sys.exit("error: not an IPS file (missing PATCH header)")
    out = bytearray(base)
    pos = 5
    while True:
        if patch[pos:pos + 3] == IPS_FOOTER and pos + 3 >= len(patch):
            break
        offset = int.from_bytes(patch[pos:pos + 3], "big")
        size = int.from_bytes(patch[pos + 3:pos + 5], "big")
        pos += 5
        if size == 0:  # RLE record
            run = int.from_bytes(patch[pos:pos + 2], "big")
            data = patch[pos + 2:pos + 3] * run
            pos += 3
        else:
            data = patch[pos:pos + size]
            pos += size
        end = offset + len(data)
        if end > len(out):
            out.extend(b"\x00" * (end - len(out)))
        out[offset:end] = data
    return bytes(out)


def make_one(version):
    """Regenerate one version's IPS + manifest entry; True if the IPS changed."""
    ver_dir = os.path.join(ROOT, "re", version)
    stock_path = os.path.join(ver_dir, "kernel.gb.orig")
    modded_path = os.path.join(ver_dir, "kernel.gb")
    for p, what in ((stock_path, "stock dump"), (modded_path, "modded build")):
        if not os.path.isfile(p):
            sys.exit(f"error: missing {p} ({what})")
    stock = open(stock_path, "rb").read()
    modded = open(modded_path, "rb").read()
    if len(stock) != len(modded):
        sys.exit(f"error: size mismatch: stock {len(stock)}, modded {len(modded)}")
    if stock == modded:
        sys.exit("error: kernel.gb is identical to kernel.gb.orig — nothing to patch")

    runs = diff_runs(stock, modded)
    os.makedirs(PATCH_DIR, exist_ok=True)
    patch_name = f"ezgb-{version}.ips"
    patch_path = os.path.join(PATCH_DIR, patch_name)
    old_ips = open(patch_path, "rb").read() if os.path.isfile(patch_path) else None
    write_ips(runs, modded, patch_path)
    new_ips = open(patch_path, "rb").read()

    # Round-trip before publishing the manifest entry.
    result = apply_ips(stock, new_ips)
    if result != modded:
        os.remove(patch_path)
        sys.exit("error: round-trip failed — patch did not reproduce kernel.gb")

    manifest = load_manifest()
    manifest[version] = {
        "patch": patch_name,
        "stock_md5": md5(stock),
        "patched_md5": md5(modded),
        "size": len(stock),
    }
    with open(MANIFEST, "w") as f:
        json.dump(manifest, f, indent=2, sort_keys=True)
        f.write("\n")
    total = sum(l for _, l in runs)
    print(f"wrote {os.path.relpath(patch_path, ROOT)}: {len(runs)} records, "
          f"{total} patched bytes")
    print(f"  stock   md5 {md5(stock)}")
    print(f"  patched md5 {md5(modded)}")
    return new_ips != old_ips


def cmd_make(args):
    versions = args.versions or sorted(load_manifest())
    if not versions:
        sys.exit(f"error: no versions given and no manifest at {MANIFEST}")
    changed = False
    for version in versions:
        changed |= make_one(version)

    ver = read_mod_version()
    if ver is None:
        write_mod_version(1, 0)
        print("mod version 1.0 (initialized "
              f"{os.path.relpath(VERSION_FILE, ROOT)})")
    elif changed:
        n, m = ver[0], ver[1] + 1
        write_mod_version(n, m)
        print(f"mod version {ver[0]}.{ver[1]} -> {n}.{m} (patch content changed)")
    else:
        print(f"mod version {ver[0]}.{ver[1]} (patch content unchanged, no bump)")


def cmd_apply(args):
    base = open(args.base, "rb").read()
    manifest = load_manifest()
    if not manifest:
        sys.exit(f"error: no manifest at {MANIFEST}")

    base_md5 = md5(base)
    if args.version:
        if args.version not in manifest:
            sys.exit(f"error: unknown version {args.version!r}; manifest has: "
                     + ", ".join(sorted(manifest)))
        version = args.version
    else:
        matches = [v for v, e in manifest.items() if e["stock_md5"] == base_md5]
        already = [v for v, e in manifest.items() if e["patched_md5"] == base_md5]
        if already:
            sys.exit(f"error: {args.base} is already the patched {already[0]} kernel")
        if not matches:
            known = "\n".join(f"  {e['stock_md5']}  {v} (stock)"
                              for v, e in sorted(manifest.items()))
            sys.exit(f"error: {args.base} (md5 {base_md5}) is not a known stock "
                     f"kernel.\nExpected one of:\n{known}\n"
                     "Use the ezgb.dat from the official EZ Flash firmware package.")
        version = matches[0]
    entry = manifest[version]

    if base_md5 == entry["patched_md5"]:
        sys.exit(f"error: {args.base} is already the patched {version} kernel")
    if base_md5 != entry["stock_md5"]:
        sys.exit(f"error: md5 mismatch for {version}\n"
                 f"  expected stock {entry['stock_md5']}\n"
                 f"  got            {base_md5}\n"
                 "Use the ezgb.dat from the official EZ Flash firmware package.")

    patch_path = os.path.join(PATCH_DIR, entry["patch"])
    result = apply_ips(base, open(patch_path, "rb").read())
    if md5(result) != entry["patched_md5"]:
        sys.exit("error: patched output failed md5 verification — "
                 "the patch and manifest disagree; regenerate the patch")

    out = args.output or os.path.join(os.path.dirname(os.path.abspath(args.base)),
                                      "ezgb-patched.dat")
    with open(out, "wb") as f:
        f.write(result)
    print(f"{version}: patched OK -> {out}")
    print(f"  md5 {md5(result)}")
    print("Rename to ezgb.dat on the card root to install.")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    mk = sub.add_parser("make", help="diff kernel.gb.orig -> kernel.gb into an IPS")
    mk.add_argument("versions", nargs="*",
                    help="version dirs under re/, e.g. 1.05e-0731 "
                         "(default: every version in the manifest)")
    mk.set_defaults(func=cmd_make)

    app = sub.add_parser("apply", help="apply the IPS to a stock ezgb.dat")
    app.add_argument("base", help="stock ezgb.dat from the official firmware package")
    app.add_argument("-v", "--version", default=None,
                     help="force a version (default: auto-detect by md5)")
    app.add_argument("-o", "--output", default=None,
                     help="output path (default: ezgb-patched.dat beside the input)")
    app.set_defaults(func=cmd_apply)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
