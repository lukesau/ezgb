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
  1.05e-0731) DUMP_EPI=6738; CLAMP_SITE=4e33; SEED=504e; NUM1=42ae; NUM2=45a7 ;;   # bank 1 differs per build:
  1.05e-0918) DUMP_EPI=699a; CLAMP_SITE=509e; SEED=bb50; NUM1=42ae; NUM2=45a7 ;;   # SEED = RtcWriteTimeFromDayDelta_seedC0a0, little-endian
  *) echo "unknown version $V" >&2; exit 1 ;;
esac

# 1. Drop the kernel.sym entries of the blocks being re-injected (inject.py
#    refuses to overwrite in place) and blank their old bytes to $FF so a
#    smaller re-injection leaves no stale code behind.
perl -ni -e 'print unless /^(02:4500|02:4a00|04:6600|08:7c00|00:04ae|04:5f00|04:5f10|00:0510|00:0530|00:0540|00:0556|01:7600|01:7610|01:7620|00:0588|04:5f20|04:5f30) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
def off(b,a): return a if b==0 else b*0x4000+(a-0x4000)
for b,a,n in ((2,0x4500,0x500),(2,0x4a00,0x1600),(4,0x2600+0x4000,0x600),(8,0x7c00,0x120),(0,0x0540,0x16),(0,0x0556,0x32),(1,0x7610,0x10),(1,0x7620,0x10),(0,0x0588,0x10),(4,0x5f20,0x10),(4,0x5f30,0x20)):
    rom[off(b,a):off(b,a)+n]=b'\xff'*n
open(p,'wb').write(rom)
PY

cd "$ROOT/decomp"
FATFS="--pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 --pin FarCall_07_7739=1963 --pin FarCall_03_768f=19a1 --pin WaitVBlankFlag=0688"

# 2. Bank 2: the settings module, then the scan that calls it.
python3 tools/inject.py src/ezcfg.c "$V" 2 4a00 EzCfg $FATFS --pin DrawString=08b7 --pin ReadJoypad=3a4a --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin LastRomName=7260 --pin DrawString12=7500 --apply
python3 tools/inject.py src/fastlaunch.c "$V" 2 4500 FastLaunchScan \
  --pin FarCallOpendir_B5=4380 --pin FarCallReaddir_B5=4396 --pin FarCallSetPage=43ac \
  --pin ezcfg=4a00 --apply

# 3. Bank 4: SET-tab flcfg (now a client of ezcfg) + shims.
python3 tools/inject.py src/flcfg.c "$V" 4 6600 FlCfg \
  --pin FarCallEzCfg=5f00 --pin SetFpgaPage_B4=466e --pin DrawString=08b7 \
  --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin ReadJoypad=3a4a --pin SetText=6400 --pin FarCallMenuTabs=5f70 --apply
python3 tools/inject_bytes.py "$V" 4 5f00 FarCallEzCfg cd8d07004a0200c9 --apply
python3 tools/inject_bytes.py "$V" 4 5f10 RtcSetHook   3e06eafcdbcd005fc3f548 --apply
python3 tools/patch_call.py   "$V" 4 58d3 3 04:5f10 --jp --apply

# 3b. SET tab layout (docs/fastlaunch-set-tab.md): TIME/SET slid up one row
#     (3->2), the date/time digits too (5->4, time-edit mode included), AUTO
#     SAVE and its checkbox down one (7->8) to make room for the RTC row (6),
#     and the stock "cursor == 1 is AUTO SAVE" highlight test now reads 2.
#     Row operands are the high byte of `ld hl,$RRCC`; y operands the low byte
#     of the DrawRect `ld hl` pairs. Each entry is checked against the stock
#     byte in kernel.gb.orig, so re-running from any earlier layout is safe.
SETUP="
  4757:03:02 4786:03:02 4947:03:02 495b:03:02 4e58:03:02
  4b22:05:04 4baf:05:04 4bbd:05:04 4c4e:05:04 4cdc:05:04 4cea:05:04
  4d7b:05:04 4d89:05:04 4e1a:05:04 4ecc:05:04 4ee7:05:04 4f4e:05:04
  4f69:05:04 4fd0:05:04 5041:05:04 505c:05:04 50c3:05:04 50de:05:04 5145:05:04
  4774:21:19 492e:21:19 5643:21:19
  47a4:07:08
  47b4:40:48 47b8:38:40 4978:40:48 497c:38:40 49b3:40:48 49b7:38:40
  47df:3e:46 47e3:3a:42 49de:3e:46 49e2:3a:42
  498c:01:02
"
python3 - "$GB" "$ROOT/re/$V/kernel.gb.orig" "$SETUP" <<'PY'
import sys
p, orig, spec = sys.argv[1], open(sys.argv[2],'rb').read(), sys.argv[3].split()
rom = bytearray(open(p,'rb').read())
for e in spec:                                   # bank 4 is identical in 0731 and 0918
    a, x, y = e.split(':'); o = 4*0x4000 + int(a,16) - 0x4000
    assert orig[o] == int(x,16), f"04:{a} stock {orig[o]:02x}, expected {x}"
    rom[o] = int(y,16)
open(p,'wb').write(rom)
PY
# TIME's SET button box (`ld hl,$9b15`, y0 in L, at 04:4777/4931/5646): slid
# up to y 13..25 with the row; in 12px mode it is y 15..28, the 12px text row
# plus a pixel either side (docs/set-pane12.md). The three loads call
# SetBtnTopHL, which also rewrites the y1 the caller pushed just before.
perl -ni -e 'print unless /^04:5f60 /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
rom[4*0x4000+0x1f60:4*0x4000+0x1f70]=b'\xff'*16
for a in (0x4777,0x4931,0x5646):
    o=4*0x4000+a-0x4000
    assert bytes(rom[o:o+3]) in (bytes.fromhex("21159b"),bytes.fromhex("210d9b"),bytes.fromhex("cd605f")), hex(a)
    rom[o:o+3]=bytes.fromhex("cd605f")
open(p,'wb').write(rom)
PY
python3 tools/inject_bytes.py "$V" 4 5f60 SetBtnTopHL 210d9bf0fbb7c8f802361c210f9bc9 --apply   # hl=$9b0d; 12px: y1 (pushed) = $1c, hl=$9b0f
# Joypad latch race (docs/joypad-latch.md): ReadJoypadLatched (00:2746) read
# P1 with interrupts on, so the VBlank sampler could run between its P1
# select and read and leave P1 deselected: a held button read as released
# (PICK ROM dropped into the browser with A still down, which then opened the
# first folder; the stock AUTO SAVE toggle fired several times per press).
# Move the `di` ahead of the raw read (same 17 bytes).
python3 tools/patch_bytes.py "$V" 0 2746 cd163a5ff3 f3cd163a5f --apply >/dev/null
# Tab switch clear: the tab drawer (08:7169) wipes the content area from y 15
# down, which the slid-up SET button box (y 13..25) straddles, so its top two
# lines survived onto HELP. Clear from y 10 (the tab underline is y 8..9; both
# browser layouts start at y 16), in all three per-tab copies of the clear.
for a in 7222 729d 7318; do
  python3 tools/patch_bytes.py "$V" 8 "$a" 0f 0a --apply >/dev/null
done
# SET cursor rows 0..5 (0 TIME, 1 RTC, 2 AUTO SAVE, 3 FAST LAUNCH, 4 PICK ROM, 5 UI)
python3 tools/patch_bytes.py "$V" 4 5605 04 05 --apply >/dev/null
# A on the SET tab: FlSetADispatch moved from 04:5959 (full, and its row test
# `dec a` could only match 1) to 04:5f30: row 2 -> stock AUTO SAVE toggle
# ($58d6), any other row -> flcfg op A; E=0 redraw ($48f5), E=1 leave ($5912).
perl -ni -e 'print unless /^04:(5959|5632) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read()); o=4*0x4000+0x5959-0x4000
rom[o:o+0x1d]=b'\xff'*0x1d
open(p,'wb').write(rom)
PY
python3 tools/inject_bytes.py "$V" 4 5f30 FlSetADispatch f83d7efe02cad658f8004d443e02f533c5cd0066e8037bb7caf5483dca1259e86ac3f446 --apply
python3 tools/inject_bytes.py "$V" 4 5632 FlSetAHookSite c2305f --apply
# Frame counter for the SET-tab name marquee: VBlankPadLatch (00:05cf, the
# joypad latch's VBlank callback, docs/joypad-latch.md) gains
# `ldh a,[$fa]; inc a; ldh [$fa],a` before its `pop bc; ret`, so hFrame
# ($fffa) counts every VBlank. 30 -> 35 bytes, still clear of $0600.
perl -ni -e 'print unless /^00:05cf /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
old=bytes.fromhex("f040f610e0403e48e045c5cd163a47f0fc2fa04f78e0fcf0fdb1e0fdc1c9")
assert rom[0x5cf:0x5cf+30]==old or rom[0x5cf:0x5cf+23]==old[:23], rom[0x5cf:0x5f4].hex()
rom[0x5cf:0x600]=b'\xff'*(0x600-0x5cf)
open(p,'wb').write(rom)
PY
python3 tools/inject_bytes.py "$V" 0 05cf VBlankPadLatch f040f610e0403e48e045c5cd163a47f0fc2fa04f78e0fcf0fdb1e0fdf0fa3ce0fac1c9 --apply
# SET input loop's ReadJoypad (04:5162) -> SetLoopTickHook: flcfg op 5 (name
# marquee tick), then jp ReadJoypad so E reaches the loop as before.
python3 tools/inject_bytes.py "$V" 4 5f20 SetLoopTickHook 3e05f533010000c5cd0066e803c34a3a --apply
python3 tools/patch_call.py   "$V" 4 5162 3 04:5f20 --apply

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
# Overlay layout (docs/last-rom.md "Overlay layout"): the stock text cells
# repainted parts of the boxes drawn before them, leaving bracket-like border
# stubs. LastRomOverlay's far call (00:129e) now targets LastRomBox (one box,
# labels inside it), the basename is drawn at column 1, 18 chars (was column
# 0, 20) through LastRomNameStub -> LastRomName, and both follow hUiMode
# (8px: DrawString; 12px: DrawString12, pixel-y rows). The box carries a
# title line and rules between its three rows and the two labels, and
# LastRomInputLoop's `call ReadJoypad` (00:1330) goes through LastRomTickStub,
# which runs LastRomName's marquee tick (s = 0) first. ezcfg only pins
# LastRomName's address, so the order against step 2 does not matter.
perl -ni -e 'print unless /^(02:4800|02:7260|00:0368|00:0370) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
for o,n in ((2*0x4000+0x0800,0x200),(2*0x4000+0x3260,0x260),(0x0368,0x13)):
    rom[o:o+n]=b'\xff'*n
open(p,'wb').write(rom)
PY
# 12px tab strip (docs/tab-strip12.md): DrawMenuTabs (08:7169) starts with
# `jp TabStripHook`, which in 12px mode far-calls TabStrip12 instead of the
# stock drawer; the entry number's two DrawString calls in bank 1 go through
# TabNum12 (12px: pixel x 124, FarCallDrawString12).
perl -ni -e 'print unless /^(02:5e00|08:7b20|00:0380) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
for o,n in ((2*0x4000+0x1e00,0x200),(8*0x4000+0x3b20,0x20),(0x0380,13)):
    rom[o:o+n]=b'\xff'*n
open(p,'wb').write(rom)
PY
python3 tools/inject.py src/tabstrip12.c "$V" 2 5e00 TabStrip12 --pin DrawString12=7500 --pin Fit12=7100 --pin DrawRect=27ba --pin StoreDrawParams=2791 --apply
python3 tools/inject_bytes.py "$V" 8 7b20 TabStripHook f0fbb72006210000c36c71f8067ef533cd8d07005e020033f8067eb7c0c38d7b --apply
python3 tools/inject_bytes.py "$V" 0 0380 TabNum12 f0fbb7cab708f805367cc3c005 --apply
python3 tools/patch_bytes.py "$V" 8 7169 210000 c3207b --apply >/dev/null
python3 tools/patch_bytes.py "$V" 1 "$NUM1" cdb708 cd8003 --apply >/dev/null   # NUM1/NUM2: the entry number's
python3 tools/patch_bytes.py "$V" 1 "$NUM2" cdb708 cd8003 --apply >/dev/null   # `call DrawString` (bank 1, per build)
# BACKUPSAVE prompt (docs/modal-prompts.md): BkPrompt (bank 4) draws the box,
# the options and "Saving..." for the stock BackupSavePrompt, whose draw
# sequences become far calls (ops 0, 1) or stub calls (op 2 BkSavingStub,
# op 3 BkSpinStub for BackupSaveDump's spinner); its joypad poll runs the
# name marquee through LastRomTickStub. Bank 1 differs per build, so the
# sites are found by their stock bytes.
perl -ni -e 'print unless /^(04:6000|00:0390|00:039d) /' "$SYM"
python3 - "$GB" "$ROOT/re/$V/kernel.gb.orig" <<'PY'
import re, sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read()); orig=open(sys.argv[2],'rb').read()
rom[4*0x4000+0x2000:4*0x4000+0x2800]=b'\xff'*0x800
rom[0x0390:0x03aa]=b'\xff'*0x1a
b1=orig[0x4000:0x8000]
f=b1.index(bytes.fromhex("f5f5f5f5210200e53e03f533cd9127e803216c01e5"))+0x4000   # BackupSavePrompt (stock ink 3 on 2)
def put(a, old, new):
    old=bytes.fromhex(old); new=bytes.fromhex(new)
    assert orig[a:a+len(old)]==old, hex(a)
    rom[a:a+len(new)]=new
put(f+0x04, "210200e53e03f533cd9127e803216c01e521257de5", "f80e7ef5333e00f533cd8d0700600400e802181b00")  # box + title -> op 0
put(f+0x89, "210200e53e03f533cd9127e80321", "3e01f533cd8d0700600400331843")                            # frames + labels -> op 1
put(f+0x4c, "cdb708", "cd9d03")                                                                      # "Saving..." (auto)
put(f+0xf4, "cdb708", "cd9d03")                                                                      # "Saving..." (after A)
put(f+0xda, "cd4a3a", "cd7003")                                                                      # joypad poll -> marquee tick
spin=[m.start()+0x4000+12 for m in re.finditer(bytes.fromhex("210b0ae53e03f53321")+b"..\xe5\xcd\xb7\x08", b1, re.S)]
assert len(spin)==3, spin
for a in spin: put(a, "cdb708", "cd9003")                                                            # BackupSaveDump spinner
open(p,'wb').write(rom)
PY
python3 tools/inject.py src/bkprompt.c "$V" 4 6000 BkPrompt --pin FarCallDrawString12=05c0 --pin LastRomNameStub=0368 \
  --pin DrawString=08b7 --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin hUiMode=fffb --apply
python3 tools/inject_bytes.py "$V" 0 0390 BkSpinStub   3e03f533cd8d070060040033c9 --apply
python3 tools/inject_bytes.py "$V" 0 039d BkSavingStub 3e02f533cd8d070060040033c9 --apply
# Save-stamp check (docs/modal-prompts.md "Garbage stamp"): BackupBranchEntry's
# `push bc; ld a,$00; push af; inc sp` (00:0f1c, before its SetFpgaPage far
# call) -> SaveStampHook: op SAVECHK validates the stamp's path in $c3a5;
# EZ_RES 0 -> BackupBranchEntry_seedSlashPath (the browser, no prompt), else
# the displaced pushes and back to the far call.
perl -ni -e 'print unless /^00:03aa /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
rom[0x03aa:0x03c7]=b'\xff'*0x1d
assert rom[0x0f1c:0x0f21] in (bytes.fromhex("c53e00f533"), bytes.fromhex("c3aa030000")), rom[0x0f1c:0x0f21].hex()
rom[0x0f1c:0x0f21]=bytes.fromhex("c3aa030000")   # jp SaveStampHook; nop; nop
open(p,'wb').write(rom)
PY
python3 tools/inject_bytes.py "$V" 0 03aa SaveStampHook c53e08eafcdbcd8d07004a0200c1fafbdbb7ca5b0fc53e00f533c3210f --apply
# 12px SET pane (docs/set-pane12.md): every `call DrawString` of the stock
# SET screen goes to SetText (8px: DrawString; 12px: the field's x span, drawn
# clipped). flcfg's rows use it too, and its UI toggle redraws the strip
# through FarCallMenuTabs and re-enters the screen (FlSetADispatch, code 2).
perl -ni -e 'print unless /^(04:6400|04:5f70) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read()); B=4*0x4000-0x4000
rom[B+0x6400:B+0x6600]=b'\xff'*0x200
rom[B+0x5f70:B+0x5f7e]=b'\xff'*14
for a in (0x4761,0x4790,0x47ae,0x4951,0x4965,0x4b29,0x4bb6,0x4bc7,0x4c55,0x4ce3,0x4cf4,0x4d82,0x4d93,
          0x4e21,0x4e62,0x4ed3,0x4ef1,0x4f55,0x4f73,0x4fd7,0x5048,0x5066,0x50ca,0x50e8,0x514c):
    assert bytes(rom[B+a:B+a+3]) in (b"\xcd\xb7\x08", b"\xcd\x00\x64"), hex(a)
    rom[B+a:B+a+3]=b"\xcd\x00\x64"
open(p,'wb').write(rom)
PY
python3 tools/inject.py src/settext.c "$V" 4 6400 SetText --pin FarCallDrawString12=05c0 --pin DrawString=08b7 --pin hUiMode=fffb --pin hClip12=fff9 --apply
python3 tools/inject_bytes.py "$V" 4 5f70 FarCallMenuTabs f8027ef533cd8d076971080033c9 --apply
# 12px Reading / Loading / Error file boxes (docs/tab-strip12.md "Status
# boxes"): each stock drawer starts with `jp MsgHook<n>`; 12px calls MsgBox12.
perl -ni -e 'print unless /^(08:7e80|08:7e10|08:7e24|08:7e38) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read()); B=8*0x4000-0x4000
rom[B+0x7e10:B+0x7f80]=b'\xff'*0x170
for a,t in ((0x7344,"c3107e"),(0x737f,"c3247e"),(0x73ba,"c3387e")):
    assert bytes(rom[B+a:B+a+3]) in (bytes.fromhex("210300"), bytes.fromhex("210200"), bytes.fromhex(t)), hex(a)
    rom[B+a:B+a+3]=bytes.fromhex(t)
open(p,'wb').write(rom)
PY
python3 tools/inject.py src/msgbox12.c "$V" 8 7e80 MsgBox12 --pin FarCallDrawString12=05c0 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
  --pin hClip12=fff9 --pin ReadingStr=7374 --pin LoadingStr=73af --pin ErrorFileStr=73ea --apply
python3 tools/inject_bytes.py "$V" 8 7e10 MsgHookReading f0fbb72006210300c347733e00f533cd807e33c9 --apply
python3 tools/inject_bytes.py "$V" 8 7e24 MsgHookLoading f0fbb72006210300c382733e01f533cd807e33c9 --apply
python3 tools/inject_bytes.py "$V" 8 7e38 MsgHookError   f0fbb72006210300c3bd733e02f533cd807e33c9 --apply
# 12px HELP pane (docs/tab-strip12.md): DrawFwVersionScreen_drawChrome
# (08:70e1) starts with `jp HelpHook`; 12px calls Help12 with the stock
# version buffer, then jumps to the stock wait loop.
perl -ni -e 'print unless /^(08:7d00|08:7b40) /' "$SYM"
python3 - "$GB" <<'PY'
import sys
p=sys.argv[1]; rom=bytearray(open(p,'rb').read())
for o,n in ((8*0x4000+0x3d00,0x200),(8*0x4000+0x3b40,0x15)):
    rom[o:o+n]=b'\xff'*n
open(p,'wb').write(rom)
PY
python3 tools/inject.py src/help12.c "$V" 8 7d00 Help12 --pin FarCallDrawString12=05c0 --pin StoreDrawParams=2791 \
  --pin HelpUrlStr=715a --pin HelpKStr=7af4 --pin HelpModStr=7aff --pin HelpGitStr=7b09 --apply
python3 tools/inject_bytes.py "$V" 8 7b40 HelpHook f0fbb72006210000c3e470f80ce5cd007de1c34171 --apply
python3 tools/patch_bytes.py "$V" 8 70e1 210000 c3407b --apply >/dev/null
OVL="--pin DrawString12=7500 --pin DrawString=08b7 --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin hUiMode=fffb"
python3 tools/inject.py src/lastrom_box.c  "$V" 2 4800 LastRomBox  $OVL --apply
python3 tools/inject.py src/lastrom_name.c "$V" 2 7260 LastRomName $OVL --pin Fit12=7100 --apply
python3 tools/inject_bytes.py "$V" 0 0368 LastRomNameStub cd8d0760720200c9 --apply
python3 tools/inject_bytes.py "$V" 0 0370 LastRomTickStub 210000e5cd6803e1c34a3a --apply   # push s=0; call stub; pop; jp ReadJoypad
python3 tools/patch_bytes.py "$V" 0 12a1 f5730800 00480200 --apply >/dev/null   # far target 08:73f5 -> 02:4800
python3 tools/patch_bytes.py "$V" 0 131d 21000fe53e14 21010fe53e12 --apply >/dev/null
python3 tools/patch_bytes.py "$V" 0 132b cdb708 cd6803 --apply >/dev/null       # call DrawString -> LastRomNameStub
python3 tools/patch_bytes.py "$V" 0 1330 cd4a3a cd7003 --apply >/dev/null       # call ReadJoypad -> LastRomTickStub

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
