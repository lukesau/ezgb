# FarCallTrampoline shims

Hand-assembled, not SDCC-compiled: `FarCallTrampoline`'s calling convention
embeds raw target bytes directly in the instruction stream right after the
`call` (verified by reading `FarCallTrampoline` itself, `00:078d`, not just
inferring from examples):

```
call FarCallTrampoline   ; CD 8D 07
db dest_lo, dest_hi, dest_bank, unused   ; 4 bytes, unused is read into A
                                          ; then unconditionally skipped -
                                          ; never used for anything, $00 by
                                          ; convention (matches every
                                          ; existing FarCall_XX_YYYY stub)
```

SDCC/C has no way to express this, so it's written directly as bytes via
`decomp/tools/inject_bytes.py`. `FarCallTrampoline` itself lives in bank 0
(always mapped) and explicitly saves/restores the ROM bank register, so the
shim can live in any bank - it doesn't need to be in bank 0 itself, and
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
epilogues (`Opendir_B5`/`Readdir_B5` both `ret E`) - same as every other
`FarCall_XX_YYYY` stub in this kernel. Neither shim touches `E` between the
far-call returning and the shim's own `ret`, so it passes straight through.
Confirmed this is exactly what SDCC's `--sdcccall 0` expects for an 8-bit C
return value: `decomp/src/misc.c`'s already-verified `return_zero()` compiles
to `1E 00 C9` = `LD E, $00` / `RET` - 8-bit returns go in `E`, not `A`. So a
C prototype like `unsigned char far_opendir_b5(void *dp, const char *path)`
reads the shim's result correctly with no extra glue.
