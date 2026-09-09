#!/usr/bin/env bash
# Stamp patches/kernel/VERSION into the HELP-tab "MOD" string
# (DrawHelpModVersion, 08:7a9c; MODSTR at 08:7aff, a fixed 10-byte field drawn
# as len $0a) of every version in patches/kernel/manifest.json. The displayed
# number equals patches/kernel/VERSION. Ends by running make-dist.sh, which
# lays out dist/mod-N.M/ with the .ips and .dat for every version.
#
# kernel-patch.py make would otherwise bump M because the stamped bytes change
# the patch content, so this restores VERSION afterward: the version string is
# part of the build it names, and re-running with the same VERSION is a no-op.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="$(tr -d '[:space:]' < "$ROOT/patches/kernel/VERSION")"
python3 - "$ROOT" "$VER" <<'PY'
import sys
root, ver = sys.argv[1], sys.argv[2]
s = ("MOD " + ver).ljust(10)[:10].encode('ascii')
assert len(s) == 10
import json
versions = sorted(json.load(open(f"{root}/patches/kernel/manifest.json")))
for v in versions:
    p = f"{root}/re/{v}/kernel.gb"
    r = bytearray(open(p, 'rb').read())
    o = 8*0x4000 + (0x7aff - 0x4000)
    if r[o:o+10] != s:
        r[o:o+10] = s; open(p, 'wb').write(r); print(f"  {v}: MODSTR -> {s!r}")
    else:
        print(f"  {v}: already '{s.decode()}'")
PY
for V in $(python3 -c "import json;print(' '.join(sorted(json.load(open('$ROOT/patches/kernel/manifest.json')))))"); do "$ROOT/scripts/regen-disasm.sh" "$V" >/dev/null 2>&1 || true; "$ROOT/scripts/build-kernel.sh" "$V" >/dev/null; done
python3 "$ROOT/scripts/kernel-patch.py" make >/dev/null
printf '%s' "$VER" > "$ROOT/patches/kernel/VERSION"   # keep the version this build names
echo "stamped 'MOD $VER' into the HELP screen (VERSION held at $VER)"
"$ROOT/scripts/make-dist.sh"
