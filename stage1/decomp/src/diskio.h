/*-----------------------------------------------------------------------
/  PFF - Low level disk interface module include file    (C)ChaN, 2014
/  Read-only subset, as linked into the EZ Flash stage1.
/-----------------------------------------------------------------------*/
#ifndef _DISKIO_DEFINED
#define _DISKIO_DEFINED

#include "integer.h"

/* Status of disk functions */
typedef BYTE DSTATUS;

/* Results of disk functions */
typedef enum {
    RES_OK = 0,     /* 0: Function succeeded */
    RES_ERROR,      /* 1: Disk error */
    RES_NOTRDY,     /* 2: Not ready */
    RES_PARERR      /* 3: Invalid parameter */
} DRESULT;

#define STA_NOINIT  0x01    /* Drive not initialized */
#define STA_NODISK  0x02    /* No medium in the drive */

/* Implemented in diskio.c. No disk_writep: PF_USE_WRITE is 0. */
DSTATUS disk_initialize(void);
DRESULT disk_readp(BYTE *buff, DWORD sector, UINT offset, UINT count);

#endif
