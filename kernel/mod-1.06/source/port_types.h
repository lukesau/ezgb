/* ====================================================================
 *  port_types.h  -  type compatibility shim (GBDK 3.0 -> GBDK-2020)
 *  --------------------------------------------------------------------
 *  GBDK-2020 (SDCC 4.5) changed the plain integer typedefs to signed:
 *
 *      asm/types.h :  typedef INT8  BYTE;    (signed char)
 *                     typedef INT16 WORD;    (signed int)
 *                     typedef INT32 DWORD;   (signed long)
 *
 *  GBDK 3.0 (SDCC 2.9), which this firmware was written against, had:
 *
 *      asm/types.h :  typedef UINT8  BYTE;   (unsigned char)
 *                     typedef UINT16 WORD;   (unsigned int)
 *                     typedef UINT32 DWORD;  (unsigned long)
 *
 *  FatFs and the legacy code base rely on the unsigned behaviour, e.g.
 *  directory entries are compared against DDEM (0xE5): with a signed BYTE
 *  the comparison is always false and deleted entries are no longer
 *  recognised (SDCC warning 94 / 126 at ff.c:1490, 1550, 1969 ...).
 *
 *  A typedef cannot be overridden, so the unsigned behaviour is restored
 *  by token substitution. This file MUST be pre-included (compiler
 *  --include) or included before any other header of a translation unit,
 *  so that <types.h> has already produced the typedefs when the macros
 *  below are defined.
 * ==================================================================== */

#ifndef EZGB_PORT_TYPES_H
#define EZGB_PORT_TYPES_H

/* Pull the toolchain typedefs in first: after this point the identifiers
   BYTE / WORD / DWORD are no longer needed as typedef names anywhere. */
#include <types.h>

/* ---- 8 bit: restore "unsigned char" semantics ---- */
#ifdef BYTE
#undef BYTE
#endif
#define BYTE    UBYTE

/* ---- 16 / 32 bit: see note in the project log ----
   Left signed on purpose: the values used by this firmware (root dir
   entries <= 512, sector numbers < 2^31) never reach the sign bit, and
   flipping them would change code that has already been validated.
   Uncomment the two blocks below to restore the exact GBDK 3.0 types.  */
/*
#ifdef WORD
#undef WORD
#endif
#define WORD    UWORD

#ifdef DWORD
#undef DWORD
#endif
#define DWORD   UDWORD
*/

#endif /* EZGB_PORT_TYPES_H */
