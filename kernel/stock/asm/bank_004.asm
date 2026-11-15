; Bank $04: all from source (see README.md)

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

RomLoad_InitiatePoll::
INCLUDE "b4_wram.inc"          ; $4000-$40ab src/bank4_wram.c, linked for $D100
INCLUDE "b4_code.inc"          ; $40ab-$8000 src/bank4.c, then $FF fill
