/* The GBDK 2.x runtime that stock stage1 links, as C prototypes.
 *
 * These stay assembly (the disassemblies in ../../fw4 and ../../fw5-0918).
 * Names are GBDK's; the comment gives the name and FW4 address that
 * kernel.sym uses. FW5-0918 has the same code $31 bytes higher. */
#ifndef GB_H
#define GB_H

typedef unsigned char  UBYTE;
typedef signed char    BYTE_S;
typedef unsigned int   UWORD;
typedef signed int     WORD_S;
typedef unsigned long  UDWORD;

/* the boot ROM's A, saved by crt0 ($11 on a color console). GBDK's _cpu. */
extern UBYTE _cpu;                       /* $C4AC */

#define J_A      0x10
#define J_B      0x20
#define J_SELECT 0x40
#define J_START  0x80

void  puts(const char *s);               /* puts, 00:2BA6; prints s, then a newline */
void  putchar(char c);                   /* putchar, 00:28F2 */
void  delay(UWORD ms);                   /* delay, 00:399B */
UBYTE joypad(void);                      /* 00:3952 */
void  disable_interrupts(void);          /* DiNest, 00:04FD */
void *memcpy(void *dst, const void *src, UWORD n);       /* Memcpy, 00:2B8D */
/* copy that waits for STAT before each VRAM byte; stage1 uses it for plain
 * copies too (the SD window, the load command, the hand-off) */
void  set_data(void *dst, const void *src, UWORD n);     /* VramCopyStack, 00:2FF2 */

/* GBDK 2.x called these through banked_call (FarCallTrampoline, 00:058D):
 * `call`, then the address and the bank inline. Bank-0 functions declared
 * banked get bank $FFFF, which selects ROM bank $FF for the call; bank 0
 * code runs the same either way. */
#define BANKED __banked

#endif
