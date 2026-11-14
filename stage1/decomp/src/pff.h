/*---------------------------------------------------------------------------/
/  Petit FatFs - FAT file system module include file  R0.03a
/----------------------------------------------------------------------------/
/
/ Copyright (C) 2019, ChaN, all right reserved.
/
/ Petit FatFs module is an open source software. Redistribution and use of
/ Petit FatFs in source and binary forms, with or without modification, are
/ permitted provided that the following condition is met:
/
/ 1. Redistributions of source code must retain the above copyright notice,
/    this condition and the following disclaimer.
/
/ This software is provided by the copyright holder and contributors "AS IS"
/ and any warranties related to this software are DISCLAIMED.
/ The copyright owner or contributors be NOT LIABLE for any damages caused
/ by use of this software.
/----------------------------------------------------------------------------/
/ Trimmed to the read-only configuration found in the EZ Flash stage1, plus
/ the vendor accessors appended to pff.c.
/----------------------------------------------------------------------------*/
#ifndef PF_DEFINED
#define PF_DEFINED 8088    /* Revision ID */

#include "integer.h"
#include "pffconf.h"

#if PF_DEFINED != PF_CONF_DEFINED
#error Wrong configuration file (pffconf.h).
#endif

#if PF_FS_FAT32
#define CLUST   DWORD
#else
#define CLUST   WORD
#endif

/* File system object structure, 42 bytes */
typedef struct {
    BYTE    fs_type;    /* +$00 FAT sub type */
    BYTE    flag;       /* +$01 File status flags */
    BYTE    csize;      /* +$02 Number of sectors per cluster */
    BYTE    pad1;       /* +$03 */
    WORD    n_rootdir;  /* +$04 Number of root directory entries (0 on FAT32) */
    CLUST   n_fatent;   /* +$06 Number of FAT entries (= number of clusters + 2) */
    DWORD   fatbase;    /* +$0A FAT start sector */
    DWORD   dirbase;    /* +$0E Root directory start sector (cluster on FAT32) */
    DWORD   database;   /* +$12 Data start sector */
    DWORD   fptr;       /* +$16 File R/W pointer */
    DWORD   fsize;      /* +$1A File size */
    CLUST   org_clust;  /* +$1E File start cluster */
    CLUST   curr_clust; /* +$22 File current cluster */
    DWORD   dsect;      /* +$26 File current data sector */
} FATFS;

/* File function return code (FRESULT) */
typedef enum {
    FR_OK = 0,          /* 0 */
    FR_DISK_ERR,        /* 1 */
    FR_NOT_READY,       /* 2 */
    FR_NO_FILE,         /* 3 */
    FR_NOT_OPENED,      /* 4 */
    FR_NOT_ENABLED,     /* 5 */
    FR_NO_FILESYSTEM    /* 6 */
} FRESULT;

/* Petit FatFs module application interface */
FRESULT pf_mount(FATFS *fs);                         /* Mount/Unmount a logical drive */
FRESULT pf_open(const char *path);                   /* Open a file */
#if PF_USE_READ
FRESULT pf_read(void *buff, UINT btr, UINT *br);     /* Read data from the open file */
#endif

/* Static in upstream pff.c. Not static here because main() calls it. */
DWORD clust2sect(CLUST clst);

/* Vendor accessors appended to pff.c (FW4 00:243D-00:24E2) */
DWORD FsFileSize(void);              /* FatFs->fsize */
BYTE  FsType(void);                  /* FatFs->fs_type */
DWORD FsFileCluster(void);           /* FatFs->org_clust */
DWORD FsNextCluster(DWORD clst);     /* get_fat(clst) */
BYTE  FsClusterSectors(void);        /* FatFs->csize */

/* Flag and offset definitions */

#define FA_OPENED   0x01
#define FA_WPRT     0x02
#define FA__WIP     0x40

/* FAT sub type (FATFS.fs_type) */
#define FS_FAT12    1
#define FS_FAT16    2
#define FS_FAT32    3

/* File attribute bits for directory entry */
#define AM_RDO  0x01    /* Read only */
#define AM_HID  0x02    /* Hidden */
#define AM_SYS  0x04    /* System */
#define AM_VOL  0x08    /* Volume label */
#define AM_LFN  0x0F    /* LFN entry */
#define AM_DIR  0x10    /* Directory */
#define AM_ARC  0x20    /* Archive */
#define AM_MASK 0x3F    /* Mask of defined bits */

#endif /* PF_DEFINED */
