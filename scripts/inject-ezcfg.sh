#!/usr/bin/env bash
# Re-inject the EZGB.CFG settings module (docs/ezgb-cfg.md) and everything
# that depends on it (fast-launch scan, SET-tab flcfg, browser hide filter),
# plus the RTC backup/restore hooks, into one kernel version.
#
# Usage: scripts/inject-ezcfg.sh <1.05e-0731|1.05e-0918>
# Then:  python3 scripts/kernel-patch.py make   (once, after both versions)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="${1:?version}"
SYM="$ROOT/re/$V/kernel.sym"
GB="$ROOT/re/$V/kernel.gb"

case "$V" in
  1.05e-0731) DUMP_EPI=6738 ;;   # BackupSaveDump_epilogueRet (bank 1 differs per build)
  1.05e-0918) DUMP_EPI=699a ;;
  *) echo "unknown version $V" >&2; exit 1 ;;
esac

# 1. Drop the kernel.sym entries of the blocks being re-injected (inject.py
#    refuses to overwrite in place) and blank their old bytes to $FF so a
#    smaller re-injection leaves no stale code behind.
perl -ni -e 'print unless /^(02:4500|02:4a00|04:5990|08:7a9c|08:7c00|00:04ae|04:5f00|04:5f10|00:0510|00:0530|01:7600) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
def off(b,a): return a if b==0 else b*0x4000+(a-0x4000)
for b,a,n in ((2,0x4500,0x500),(2,0x4a00,0xa00),(4,0x5990,0x4ea),(8,0x7a9c,0xca),(8,0x7c00,0x120)):
    rom[off(b,a):off(b,a)+n]=b'\xff'*n
open(p,'wb').write(rom)
PY

cd "$ROOT/decomp"
FATFS="--pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 --pin FarCall_07_7739=1963 --pin FarCall_03_768f=19a1 --pin WaitVBlankFlag=0688"

# 2. Bank 2: the settings module, then the scan that calls it.
python3 tools/inject.py src/ezcfg.c "$V" 2 4a00 EzCfg $FATFS --apply
python3 tools/inject.py src/fastlaunch.c "$V" 2 4500 FastLaunchScan \
  --pin FarCallOpendir_B5=4380 --pin FarCallReaddir_B5=4396 --pin FarCallSetPage=43ac \
  --pin ezcfg=4a00 --apply

# 3. Bank 4: SET-tab flcfg (now a client of ezcfg) + shims.
python3 tools/inject.py src/flcfg.c "$V" 4 5990 FlCfg \
  --pin FarCallEzCfg=5f00 --pin SetFpgaPage_B4=466e --pin DrawString=08b7 \
  --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin ReadJoypad=3a4a --apply
python3 tools/inject_bytes.py "$V" 4 5f00 FarCallEzCfg cd8d07004a0200c9 --apply
python3 tools/inject_bytes.py "$V" 4 5f10 RtcSetHook   3e02eafcdbcd005fc3f548 --apply
python3 tools/patch_call.py   "$V" 4 58d3 3 04:5f10 --jp --apply

# 4. Bank 8: hide filter (relocated to 7c00; it outgrew the slot before FlPickBanner).
python3 tools/inject.py src/browser_hide.c "$V" 8 7c00 BrowserHideName --apply
python3 tools/inject_bytes.py "$V" 0 04ae DirListHideNameStub 200301e4c9c5c5cd8d07007c0800e802c17bb7c2560ac3a30a --apply

# 5. Bank 0: boot restore hook + BATTERY DRY flag hook.
python3 tools/inject_bytes.py "$V" 0 0510 RtcBootHook    3e03eafcdbcd8d07004a02003e11ea0040cd8d07e7410400c3500e --apply
python3 tools/inject_bytes.py "$V" 0 0530 BatteryDryHook 3e01eafddb0101a23e8802c9 --apply
python3 tools/patch_call.py   "$V" 0 0e49 7 00:0510 --jp --apply
python3 tools/patch_call.py   "$V" 0 18e5 6 00:0530 --apply

# 6. Bank 1: BackupSaveDump epilogue -> RTC backup.
python3 tools/inject_bytes.py "$V" 1 7600 RtcDumpHook e80b3e02eafcdbcd8d07004a0200c9 --apply
python3 tools/patch_call.py   "$V" 1 "$DUMP_EPI" 3 01:7600 --jp --apply --regen
