# FarCallTrampoline shims

Hand-assembled, not SDCC-compiled: `FarCallTrampoline`'s calling convention
embeds raw target bytes directly in the instruction stream right after the
`call` (verified by reading `FarCallTrampoline` itself, `00:078d`, not just
inferring from examples):

```
call FarCallTrampoline   ; CD 8D 07
db dest_lo, dest_hi, dest_bank, unused   ; 4 bytes, unused is read into A
                                          ; then unconditionally skipped;
                                          ; never used for anything, $00 by
                                          ; convention (matches every
                                          ; existing FarCall_XX_YYYY stub)
```

SDCC/C has no way to express this, so it's written directly as bytes via
`decomp/tools/inject_bytes.py`. `FarCallTrampoline` itself lives in bank 0
(always mapped) and explicitly saves/restores the ROM bank register, so the
shim can live in any bank; it doesn't need to be in bank 0 itself, and
callers in the *same* bank as the shim can reach it with an ordinary `call`.

Both shims follow the exact pattern of the kernel's own existing
`FarCall_06_7309` (bank 0, calls `Open_B6`): read each incoming stack arg,
re-push it in the same order the far target expects, `call
FarCallTrampoline` with the embedded target, clean up the re-pushed bytes,
`ret`. Two 2-byte pointer args in, so 4 bytes of cleanup (`add sp, $04`).

## FarCallOpendir_B5(dp, path) -> FatFs f_opendir, `05:73dd`

```asm
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call FarCallTrampoline
    db $dd, $73, $05, $00
    add sp, $04
    ret
```
Bytes: `f8042a666fe5f8042a666fe5cd8d07dd730500e804c9` (22 bytes)

## FarCallReaddir_B5(dp, fno) -> FatFs f_readdir, `05:7576`

Identical shape, only the embedded target bytes differ.

Bytes: `f8042a666fe5f8042a666fe5cd8d0776750500e804c9` (22 bytes)

## Return value

Both far-called functions leave FatFs's `FRESULT` in `E` per their own
epilogues (`Opendir_B5`/`Readdir_B5` both `ret E`), the same as every other
`FarCall_XX_YYYY` stub in this kernel. Neither shim touches `E` between the
far-call returning and the shim's own `ret`, so it passes straight through.
Confirmed this is exactly what SDCC's `--sdcccall 0` expects for an 8-bit C
return value: `decomp/src/misc.c`'s already-verified `return_zero()` compiles
to `1E 00 C9` = `LD E, $00` / `RET`: 8-bit returns go in `E`, not `A`. So a
C prototype like `unsigned char far_opendir_b5(void *dp, const char *path)`
reads the shim's result correctly with no extra glue.

---

# SET-tab fast-launch shims (docs/fastlaunch-set-tab.md)

These adapt `DrawTimeAutosaveScreen`'s hook sites and the browser's ROM-launch
path to `flcfg` (bank 4 `04:5990`). Args are pushed last-first (op via
`push af; inc sp`, then frame via `push bc`); `flcfg` returns in `E`. Hand-
assembled and dropped with `inject_bytes.py`; full hook map and stock bytes are
in `docs/fastlaunch-set-tab.md`.

## FlSetEnterHook `04:5932` (22 B)

`call`ed from the SET prologue at `04:47ef`, so SP is two below the SET frame:
the frame base is `sp+$02` and the replayed `ld hl,sp+$5c` becomes `ld hl,sp+$5e`.
Runs op 0 (ENTER: load cfg + draw the rows), then reproduces the displaced
`ld hl,sp+$5c; ld c,l; ld b,h; ld hl,$0007` before returning into the stock
`Memset` at `04:47f6`.

Bytes: `f8024d443e00f533c5cd9059e803f85e4d44210700c9`

## FlSetRowsHook `04:5948` (17 B)

`jp`ed from the hiliteDec/hiliteInc tails (`04:5404`/`04:560d`), so SP is the SET
frame. Runs op 1 (ROWS: redraw the two rows for the new cursor), then
`jp DrawTimeAutosaveScreen_redraw` (`04:48f5`).

Bytes: `f8004d443e01f533c5cd9059e803c3f548`

## FlSetADispatch `04:5959` (29 B)

New target of the A-with-cursor≠0 branch (`jp nz` at `04:5632`). Cursor 1 →
stock AUTO SAVE toggle (`jp $58d6`). Else op 2 (A): E=0 → `jp $48f5` (redraw),
E=1 → `jp $5912` (leave the SET screen; the bank-0 `FlSetExitHook` then enters
the browser for pick mode).

Bytes: `f83d7e3dcad658f8004d443e02f533c5cd9059e8037bb7caf548c31259`

## FlPickCommitFar `04:5976` (14 B)

No-arg far target (so the `FarCallTrampoline` sp+6 arg shift is irrelevant),
reached from the bank-0 `FlPickHook`. Pushes op 3 (PICK) and a NULL frame, calls
`flcfg`, cleans up, returns.

Bytes: `3e03f533210000e5cd9059e803c9`

## Bank-0 hooks

- `FlPickHook` `00:04c7` (26 B): at the browser ROM-launch site `00:1569`. Pick
  armed (`$DBFE`) → far-call `FlPickCommitFar` then `jp $124f` (redraw SET); else
  replay the `LoaderPrepPath` far-call and `jp $1570` (normal launch).
  Bytes: `fafedbb7280acd8d0776590400c34f12cd8d072b480100c37015`
- `FlSetExitHook` `00:04e8` (14 B): at the SET-return site `00:1263`. Pick armed
  → `jp $0f8d` (FileBrowserEntry); else replay `ld hl,sp+$0e; ld [hl],$02` and
  `jp $1267` (HELP as stock). Bytes: `fafedbb7c28d0ff80e3602c36712`
- `FlPickCancelHook` `00:04f8` (10 B): at B-at-root `00:164e`. Not armed → stock
  no-op `jp $16ab`; armed → `jp $124f` (back to SET, whose ENTER clears the flag).
  Bytes: `fafedbb7caab16c34f12`

## FlPickBanner `08:7b8d`

Injected C (`decomp/src/flpick_banner.c`), reached by `jp` from the tab-strip
tail `08:7200` (`jp $7331` → `jp $7b8d`). Draws ` PICK A ROM ` over the tab strip
while `$DBFE` is set; ends in `ret`, which returns through the tab drawer.

---

# EZGB.CFG / RTC backup shims (docs/ezgb-cfg.md)

`ezcfg` (bank 2 `02:4a00`) takes no stack argument; the op goes in WRAM `$DBFC`
(0 LOAD, 1 SAVE, 2 BACKUP, 3 RESTORE), so the same entry serves a plain bank-2
`call` and `FarCallTrampoline` alike.

## FarCallEzCfg `04:5f00` (8 B)

Near-callable from bank 4 (`flcfg.c`): `call FarCallTrampoline; db $00,$4a,$02,$00; ret`.
Bytes: `cd8d07004a0200c9`

## RtcSetHook `04:5f10` (11 B)

`jp`ed from the TIME SET confirm tail (`04:58d3`, stock `jp $48f5`). Op BACKUP,
far-call via `FarCallEzCfg`, then the displaced `jp DrawTimeAutosaveScreen_redraw`.
Bytes: `3e02eafcdbcd005fc3f548`

## RtcBootHook `00:0510` (27 B)

`jp`ed from `00:0e49` (stock: far-call `SetFpgaPage(3)`, 7 B, right after
"Micro SD initial OK!" and `$4000=$11`). The site's pushed arg byte is still on
the stack, so after op RESTORE the hook re-asserts `$4000=$11` and replays the
same far-call unchanged, then `jp $0e50` (the `add sp,$01`).
Bytes: `3e03eafcdbcd8d07004a02003e11ea0040cd8d07e7410400c3500e`

## BatteryDryHook `00:0530` (12 B)

`call`ed from `BatteryCheck_markOk` (`00:18e5`, stock `ld bc,$a201; ld a,$88; ld [bc],a`,
6 B). Sets `$DBFD=1` then performs the displaced canary write.
Bytes: `3e01eafddb0101a23e8802c9`

## RtcDumpHook `01:7600` (15 B)

`jp`ed from `BackupSaveDump_epilogueRet` (`01:6738` in 0731, `01:699a` in 0918;
stock `add sp,$0b; ret`). Pops the frame, op BACKUP, far-call, `ret`. The body
holds no version-specific address, so the same bytes serve both builds.
Bytes: `e80b3e02eafcdbcd8d07004a0200c9`
