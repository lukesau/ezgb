; Bank $00: all from source (see README.md); each include names its sources

SECTION "ROM Bank $000", ROM0[$0]

INCLUDE "crt0_low.inc"         ; $0000-$01e3 gbdk/crt0.s
INCLUDE "b0_gbdk_header.inc"   ; $01e3-$0600 GBDK mode table jumps, $FF fill
INCLUDE "crt0_home.inc"        ; $0600-$07bc gbdk/crt0.s (_HOME)
INCLUDE "b0_kernel.inc"        ; $07bc-$1926 src/kernel.c
INCLUDE "b0_fatfs.inc"         ; $1926-$20bb src/fsglue.c, diskio.c, option/ccsbcs.c
INCLUDE "b0_rle.inc"           ; $20bb-$20e2 sdcclib/crt0_rle.s
INCLUDE "b0_lib0.inc"          ; $20e2-$20f4 src/libasm.s (strcpy)
INCLUDE "b0_gbdk_code.inc"     ; $20f4-$2826 gbdk/drawing.s
INCLUDE "b0_sdccasm.inc"       ; $2826-$29e6 sdcclib/stubs.s, div.s, shift.s
INCLUDE "b0_lib1.inc"          ; $29e6-$2a5f src/libasm.s
INCLUDE "b0_gbdk_vbl.inc"      ; $2a5f-$2a77 gbdk/drawing.s (.vbl, .lcd)
INCLUDE "b0_lib2.inc"          ; $2a77-$2c42 src/libasm.s
INCLUDE "b0_strrchr.inc"       ; $2c42-$2ca5 sdcclib/_strrchr.c
INCLUDE "b0_lib3.inc"          ; $2ca5-$2cd3 src/libasm.s (memset, memcpy)
INCLUDE "b0_strncpy.inc"       ; $2cd3-$2d4c sdcclib/_strncpy.c
INCLUDE "b0_lib4.inc"          ; $2d4c-$2d56 src/libasm.s
INCLUDE "b0_gbdk_font.inc"     ; $2d56-$2d95 gbdk/font.ms (_CODE)
INCLUDE "b0_strlen.inc"        ; $2d95-$2dba sdcclib/_strlen.c
INCLUDE "b0_lib5.inc"          ; $2dba-$2eea src/libasm.s
INCLUDE "b0_gbdk_base.inc"     ; $2eea-$4000 GBDK _BASE modules, $FF fill
