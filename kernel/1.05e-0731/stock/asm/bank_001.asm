; Bank $01: all from source (see README.md)

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

; $4000-$68b6: src/bank1.c
INCLUDE "b1_code.inc"


; $68b6-$68c0: src/kernel.c (_GSINIT: gsinit, wMarqueePos)
INCLUDE "b1_kernel_init.inc"
INCLUDE "b1_ccsbcs_init.inc"

; $7096-$7390: src/bank1.c (_GSINIT)
INCLUDE "b1_init.inc"
; $7390-$8000: gbdk/crt0.s (_GSINITTAIL), $FF fill
INCLUDE "b1_gsinittail.inc"
