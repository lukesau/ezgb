; Bank $08: all from source (see README.md)

SECTION "ROM Bank $008", ROMX[$4000], BANK[$8]

INCLUDE "b8_code.inc"          ; $4000-$8000 src/bank8.c, then $FF fill
