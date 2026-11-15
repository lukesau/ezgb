; Bank $02: all from source (see README.md)

SECTION "ROM Bank $002", ROMX[$4000], BANK[$2]

INCLUDE "b2_code.inc"          ; $4000-$8000 src/bank2.c, then $FF fill
