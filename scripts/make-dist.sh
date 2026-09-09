#!/usr/bin/env bash
# Assemble the release folder for the current mod version:
#
#   dist/mod-N.M/ezgb-mod-N.M-for-<ver>.ips   the patch (safe to publish)
#   dist/mod-N.M/ezgb-mod-N.M-for-<ver>.dat   the patched kernel (local only)
#
# for every version in patches/kernel/manifest.json, N.M being
# patches/kernel/VERSION. Each .dat is checked against the manifest's
# patched_md5 and each .ips is checked to reproduce it from the stock dump, so
# a stale re/<ver>/kernel.gb or patch fails loudly instead of shipping.
# dist/ is gitignored; the .ips files are what a GitHub release gets.
#
# scripts/stamp-mod-version.sh runs this last, after stamping and rebuilding
# every version. Usage: scripts/make-dist.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODVER="$(tr -d '[:space:]' < "$ROOT/patches/kernel/VERSION")"
OUT="$ROOT/dist/mod-$MODVER"
mkdir -p "$OUT"
for V in $(python3 -c "import json;print(' '.join(sorted(json.load(open('$ROOT/patches/kernel/manifest.json')))))"); do
  echo "$V:"
  "$ROOT/scripts/build-ezgb-dat.sh" "$V" | sed 's/^/  /'
  cp "$ROOT/patches/kernel/ezgb-$V.ips" "$OUT/ezgb-mod-$MODVER-for-$V.ips"
done
python3 - "$ROOT" "$MODVER" <<'PY'
import hashlib, json, os, sys
root, modver = sys.argv[1], sys.argv[2]
sys.path.insert(0, os.path.join(root, "scripts"))
from importlib import import_module
kp = import_module("kernel-patch")
manifest = json.load(open(os.path.join(root, "patches", "kernel", "manifest.json")))
out = os.path.join(root, "dist", f"mod-{modver}")
ok = True
for v, e in sorted(manifest.items()):
    dat = open(os.path.join(out, f"ezgb-mod-{modver}-for-{v}.dat"), "rb").read()
    stock = open(os.path.join(root, "re", v, "kernel.gb.orig"), "rb").read()
    ips = open(os.path.join(out, f"ezgb-mod-{modver}-for-{v}.ips"), "rb").read()
    d_ok = hashlib.md5(dat).hexdigest() == e["patched_md5"]
    i_ok = kp.apply_ips(stock, ips) == dat
    ok &= d_ok and i_ok
    print(f"  {v}: dat {'ok' if d_ok else 'MISMATCH vs manifest'}, ips {'ok' if i_ok else 'does not reproduce the dat'}")
if not ok:
    sys.exit("error: dist folder does not match the manifest; rerun kernel-patch.py make / stamp-mod-version.sh")
print(f"dist/mod-{modver}: {len(manifest)} versions, ips + dat each")
PY
