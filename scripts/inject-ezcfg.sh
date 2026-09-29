#!/usr/bin/env bash
# Re-inject the EZGB.CFG settings module (docs/ezgb-cfg.md) and everything
# that depends on it (fast-launch scan, SET-tab flcfg, browser hide filter),
# plus the RTC backup/restore hooks and the last-ROM hooks (LASTROM= key,
# docs/last-rom.md), into one kernel version.
#
# Usage: scripts/inject-ezcfg.sh <1.05e-0731|1.05e-0918>
# Then:  scripts/port-mod.py 1.05e-0731 1.04e --apply --sym   (hook sites below
#        are 1.05e addresses; 1.04e is always a port of 0731, see DEVELOPMENT.md)
#        python3 scripts/kernel-patch.py make   (once, after all versions)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="${1:?version}"
SYM="$ROOT/re/$V/kernel.sym"
GB="$ROOT/re/$V/kernel.gb"

case "$V" in
  1.05e-0731) DUMP_EPI=6738; CLAMP_SITE=4e33; SEED=504e ;;   # bank 1 differs per build:
  1.05e-0918) DUMP_EPI=699a; CLAMP_SITE=509e; SEED=bb50 ;;   # SEED = RtcWriteTimeFromDayDelta_seedC0a0, little-endian
  *) echo "unknown version $V" >&2; exit 1 ;;
esac

# 1. Drop the kernel.sym entries of the blocks being re-injected (inject.py
#    refuses to overwrite in place) and blank their old bytes to $FF so a
#    smaller re-injection leaves no stale code behind.
perl -ni -e 'print unless /^(02:4500|02:4a00|04:5990|08:7c00|00:04ae|04:5f00|04:5f10|00:0510|00:0530|00:0540|00:0556|01:7600|01:7610|01:7620|00:0588) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
def off(b,a): return a if b==0 else b*0x4000+(a-0x4000)
for b,a,n in ((2,0x4500,0x500),(2,0x4a00,0x1600),(4,0x5990,0x4ea),(8,0x7c00,0x120),(0,0x0540,0x16),(0,0x0556,0x32),(1,0x7610,0x10),(1,0x7620,0x10),(0,0x0588,0x10)):
    rom[off(b,a):off(b,a)+n]=b'\xff'*n
open(p,'wb').write(rom)
PY

cd "$ROOT/decomp"
FATFS="--pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 --pin FarCall_07_7739=1963 --pin FarCall_03_768f=19a1 --pin WaitVBlankFlag=0688"

# 2. Bank 2: the settings module, then the scan that calls it.
python3 tools/inject.py src/ezcfg.c "$V" 2 4a00 EzCfg $FATFS --pin DrawString=08b7 --pin ReadJoypad=3a4a --pin DrawRect=27ba --pin StoreDrawParams=2791 --apply
python3 tools/inject.py src/fastlaunch.c "$V" 2 4500 FastLaunchScan \
  --pin FarCallOpendir_B5=4380 --pin FarCallReaddir_B5=4396 --pin FarCallSetPage=43ac \
  --pin ezcfg=4a00 --apply

# 3. Bank 4: SET-tab flcfg (now a client of ezcfg) + shims.
python3 tools/inject.py src/flcfg.c "$V" 4 5990 FlCfg \
  --pin FarCallEzCfg=5f00 --pin SetFpgaPage_B4=466e --pin DrawString=08b7 \
  --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin ReadJoypad=3a4a --apply
python3 tools/inject_bytes.py "$V" 4 5f00 FarCallEzCfg cd8d07004a0200c9 --apply
python3 tools/inject_bytes.py "$V" 4 5f10 RtcSetHook   3e06eafcdbcd005fc3f548 --apply
python3 tools/patch_call.py   "$V" 4 58d3 3 04:5f10 --jp --apply

# 4. Bank 8: hide filter (relocated to 7c00; it outgrew the slot before FlPickBanner).
python3 tools/inject.py src/browser_hide.c "$V" 8 7c00 BrowserHideName --apply
python3 tools/inject_bytes.py "$V" 0 04ae DirListHideNameStub 200301e4c9c5c5cd8d07007c0800e802c17bb7c2560ac3a30a --apply

# 5. Bank 0: boot restore hook + BATTERY DRY flag hook.
python3 tools/inject_bytes.py "$V" 0 0510 RtcBootHook    3e03eafcdbcd8d07004a02003e11ea0040cd8d07e7410400c3500e --apply
python3 tools/inject_bytes.py "$V" 0 0530 BatteryDryHook 3e01eafddb0101a23e8802c9 --apply
python3 tools/patch_call.py   "$V" 0 0e49 7 00:0510 --jp --apply
python3 tools/patch_call.py   "$V" 0 18e5 6 00:0530 --apply
# Path-length bound check: MenuDispatchAB_dirAppend (00:140f) -> hook. Computes
# strlen(CWD $c2a6) + 1 + strlen(dirname [$c2a0]+[sp+$04]); if it would exceed
# the 255-byte path buffer (overflowing into the SAVER path $c3a5) the descent
# is a no-op (jp FileBrowserEntry), else it replays `ld hl,PathSlashStr` and
# continues. See docs/last-rom.md / path notes.
python3 tools/inject_bytes.py "$V" 0 0556 DirEnterBoundCheck 21a0c25e2356f8042a666f1906002ab728030418f921a6c20e002ab728030c18f97881380afefe300621e916c31214c38d0f --apply
python3 tools/patch_call.py   "$V" 0 140f 3 00:0556 --jp --apply
# Relaunch RTC backup: LastRomRelaunch (START overlay, also fast launch) ends in
# `jp $1570`, past the $1569 LoaderPrepPath far-call where the browser launch
# persists the path and runs op LASTSAVE. Hook it: op RELAUNCH (7) refreshes
# RTC= only, then `jp $1570` as before.
python3 tools/inject_bytes.py "$V" 0 0588 RelaunchRtcHook 3e07eafcdbcd8d07004a0200c37015 --apply
python3 tools/patch_call.py   "$V" 0 1382 3 00:0588 --jp --apply
# Last-ROM fallback: LastRomLoadRecord's `jp nc, LastRomDrawBasename` (00:12c8) ->
# hook; op LASTLOAD validates the $A300 copy, else loads LASTROM= (or shows
# "(none)" until B); EZ_RES 1 -> LastRomDrawBasename, 0 -> LastRomReturn.
python3 tools/inject_bytes.py "$V" 0 0540 LastRomFallbackHook 3e05eafcdbcd8d07004a0200fafbdbb7c2f112c38f13 --apply
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
assert rom[0x12c8:0x12cb] in (bytes.fromhex("d2f112"), bytes.fromhex("d24005")), rom[0x12c8:0x12cb].hex()
rom[0x12c8:0x12cb]=bytes.fromhex("d24005")   # jp nc, LastRomFallbackHook
open(p,'wb').write(rom)
PY

# 6. Bank 1: BackupSaveDump epilogue -> RTC backup; LastRomPersistDone tail (path assembled in $c2a6) -> LASTROM= save.
python3 tools/inject_bytes.py "$V" 1 7600 RtcDumpHook e80b3e02eafcdbcd8d07004a0200c9 --apply
python3 tools/inject_bytes.py "$V" 1 7610 LastRomSaveHook 3e04eafcdbcd8d07004a0200e804c9 --apply
python3 tools/patch_call.py   "$V" 1 48c1 3 01:7610 --jp --apply
# Negative-elapsed clamp (docs/ezgb-cfg.md): RtcWriteTimeFromDayDelta's sign test
# `bit 7,a; jp z,seedC0a0` -> hook. Elapsed < 0 (the clock went backwards since
# the .sav's launch stamp) zeroes the elapsed value at sp+$0e..$11 and seeds from
# the saved registers anyway, instead of the stock fall-through into zeroHms,
# which wiped the game's RTC (Pokemon Crystal's clock jumping to its offset).
python3 tools/inject_bytes.py "$V" 1 7620 RtcNegClampHook "cb7fca${SEED}aff80e22222277c3${SEED}" --apply
python3 tools/patch_call.py   "$V" 1 "$CLAMP_SITE" 5 01:7620 --jp --apply
python3 tools/patch_call.py   "$V" 1 "$DUMP_EPI" 3 01:7600 --jp --apply --regen
