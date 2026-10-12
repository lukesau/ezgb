#!/usr/bin/env bash
# Assemble the release folder for the current mod version:
#
#   dist/mod-N.M/ezgb-mod-N.M-for-<ver>.ips   the patch (safe to publish)
#   dist/mod-N.M/ezgb-mod-N.M-for-<ver>.dat   the patched kernel (local only)
#   dist/mod-N.M/README.txt                   patching instructions for the
#                                             release page, rendered from
#                                             patches/kernel/release-README.txt
#                                             with the version and md5 table
#
# for every version in patches/kernel/manifest.json, N.M being
# patches/kernel/VERSION. Each .dat is checked against the manifest's
# patched_md5 and each .ips is checked to reproduce it from the stock dump, so
# a stale re/kernel/<ver>/kernel.gb or patch fails loudly instead of shipping.
# dist/ is gitignored; the .ips files are what a GitHub release gets.
#
# scripts/stamp-mod-version.sh runs this last, after stamping and rebuilding
# every version. Usage: scripts/make-dist.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODVER="$(tr -d '[:space:]' < "$ROOT/patches/kernel/VERSION")"
OUT="$ROOT/dist/mod-$MODVER"
mkdir -p "$OUT"
rm -f "$OUT"/ezgb-firmware-*.ips          # rewritten below from patches/updater/
for V in $(python3 -c "import json;print(' '.join(sorted(json.load(open('$ROOT/patches/kernel/manifest.json')))))"); do
  echo "$V:"
  "$ROOT/scripts/build-ezgb-dat.sh" "$V" | sed 's/^/  /'
  cp "$ROOT/patches/kernel/ezgb-$V.ips" "$OUT/ezgb-mod-$MODVER-for-$V.ips"
done
python3 - "$ROOT" "$MODVER" <<'PY'
import hashlib, json, os, sys
root, modver = sys.argv[1], sys.argv[2]
PATCHER_URL = "https://lukesau.github.io/ezgb/patcher/"   # where dist/patcher/index.html is hosted
sys.path.insert(0, os.path.join(root, "scripts"))
from importlib import import_module
kp = import_module("kernel-patch")
manifest = json.load(open(os.path.join(root, "patches", "kernel", "manifest.json")))
out = os.path.join(root, "dist", f"mod-{modver}")
ok = True
for v, e in sorted(manifest.items()):
    dat = open(os.path.join(out, f"ezgb-mod-{modver}-for-{v}.dat"), "rb").read()
    stock = open(os.path.join(root, "re","kernel", v, "kernel.gb.orig"), "rb").read()
    ips = open(os.path.join(out, f"ezgb-mod-{modver}-for-{v}.ips"), "rb").read()
    d_ok = hashlib.md5(dat).hexdigest() == e["patched_md5"]
    i_ok = kp.apply_ips(stock, ips) == dat
    ok &= d_ok and i_ok
    print(f"  {v}: dat {'ok' if d_ok else 'MISMATCH vs manifest'}, ips {'ok' if i_ok else 'does not reproduce the dat'}")
# Firmware updater patches: each must turn EZ Flash's stock updater into the
# manifest's patched md5, and all must carry the current stage1 version.
# Copied as ezgb-firmware-mod-F-for-<fw>.ips (since mod 6.9 / firmware 1.9;
# the patcher page stays the recommended route, it refuses wrong bases).
fwname = {"fw4": "Update_FW4.gb (juniorkernel-1.04e-FW4)",
          "fw5-0918": "Update_FW5_2021-9-18.gb (juniorkernel-1.05e-FW5-0918)"}
fwrows = []
fwver = open(os.path.join(root, "stage1", "VERSION")).read().split()[1]
updaters = json.load(open(os.path.join(root, "patches", "updater", "manifest.json")))
for fw, e in sorted(updaters.items()):
    ips = open(os.path.join(root, "patches", "updater", e["patch"]), "rb").read()
    stock = open(os.path.join(root, kp.UPDATER_STOCK[fw]), "rb").read()
    u_ok = (hashlib.md5(stock).hexdigest() == e["stock_md5"] and e["stage1"] == fwver
            and hashlib.md5(kp.apply_ips(stock, ips)).hexdigest() == e["patched_md5"])
    ok &= u_ok
    name = f"ezgb-firmware-mod-{fwver}-for-{fw}.ips"
    open(os.path.join(out, name), "wb").write(ips)
    print(f"  {fw}: firmware mod {e['stage1']} {'ok' if u_ok else 'MISMATCH (stale patch or stage1 version)'}")
    fwrows += [f"  {name}", f"    for {fwname.get(fw, fw)}", f"    stock md5:    {e['stock_md5']}",
               f"    stock sha1:   {hashlib.sha1(stock).hexdigest()}", f"    patched md5:  {e['patched_md5']}", ""]
if not ok:
    sys.exit("error: dist folder does not match the manifest; rerun kernel-patch.py make / stamp-mod-version.sh")
pkg = {"1.04e": "juniorkernel-1.04e-FW4", "1.05e-0731": "juniorkernel-1.05e-FW5-0731", "1.05e-0918": "juniorkernel-1.05e-FW5-0918"}
tmpl = open(os.path.join(root, "patches", "kernel", "release-README.txt")).read()
rows = []
for v, e in sorted(manifest.items()):
    stock = open(os.path.join(root, "re", "kernel", v, "kernel.gb.orig"), "rb").read()
    rows += [f"  {v}  ({pkg.get(v, '?')})", f"    stock md5:   {e['stock_md5']}",
             f"    stock sha1:  {hashlib.sha1(stock).hexdigest()}", f"    modded md5:  {e['patched_md5']}", ""]
readme = (tmpl.replace("{MODVER}", modver).replace("{FWVER}", fwver).replace("{PATCHER_URL}", PATCHER_URL)
          .replace("{TABLE}", "\n".join(rows).rstrip("\n"))
          .replace("{FWTABLE}", "\n".join(fwrows).rstrip("\n")))
open(os.path.join(out, "README.txt"), "w", newline="\r\n").write(readme)
print(f"dist/mod-{modver}: {len(manifest)} kernels (ips + dat), {len(updaters)} firmware patches, README.txt")
PY
