/*----------------------------------------------------------------------------/
/  Petit FatFs - FAT file system module  R0.03a
/-----------------------------------------------------------------------------/
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
/-----------------------------------------------------------------------------/
/ Reconstructed from the EZ Flash Jr stage1 binary (FW4 00:0C16-00:24E2;
/ FW5-0918 has the same code $31 bytes higher). Not byte-exact. Where the
/ binary and upstream R0.03a agree, the upstream code is kept as is.
/ The vendor accessors at the end are not part of Petit FatFs.
/----------------------------------------------------------------------------*/

#include "pff.h"        /* Petit FatFs configurations and declarations */
#include "diskio.h"     /* Declarations of low level disk I/O functions */


/*--------------------------------------------------------------------------
   Module Private Definitions
---------------------------------------------------------------------------*/

#if PF_FS_FAT32
#if PF_FS_FAT16 || PF_FS_FAT12
#define _FS_32ONLY  0
#else
#define _FS_32ONLY  1
#endif
#else
#define _FS_32ONLY  0
#endif

#define ABORT(err)  {fs->flag = 0; return err;}

/* DIR: directory scan state, 16 bytes (dj in pf_open at sp+$3A) */
typedef struct {
    WORD    index;      /* +$00 Current read/write index number */
    BYTE*   fn;         /* +$02 Pointer to the SFN (in/out) {file[8],ext[3],status[1]} */
    CLUST   sclust;     /* +$04 Table start cluster (0:Static table) */
    CLUST   clust;      /* +$08 Current cluster */
    DWORD   sect;       /* +$0C Current sector */
} DIR;

/* FAT boot sector and directory entry offsets */
#define BS_jmpBoot          0
#define BS_OEMName          3
#define BPB_BytsPerSec      11
#define BPB_SecPerClus      13
#define BPB_RsvdSecCnt      14
#define BPB_NumFATs         16
#define BPB_RootEntCnt      17
#define BPB_TotSec16        19
#define BPB_Media           21
#define BPB_FATSz16         22
#define BPB_SecPerTrk       24
#define BPB_NumHeads        26
#define BPB_HiddSec         28
#define BPB_TotSec32        32
#define BS_55AA             510

#define BS_DrvNum           36
#define BS_BootSig          38
#define BS_VolID            39
#define BS_VolLab           43
#define BS_FilSysType       54

#define BPB_FATSz32         36
#define BPB_ExtFlags        40
#define BPB_FSVer           42
#define BPB_RootClus        44
#define BPB_FSInfo          48
#define BPB_BkBootSec       50
#define BS_DrvNum32         64
#define BS_BootSig32        66
#define BS_VolID32          67
#define BS_VolLab32         71
#define BS_FilSysType32     82

#define MBR_Table           446

#define DIR_Name            0
#define DIR_Attr            11
#define DIR_NTres           12
#define DIR_CrtTime         14
#define DIR_CrtDate         16
#define DIR_FstClusHI       20
#define DIR_WrtTime         22
#define DIR_WrtDate         24
#define DIR_FstClusLO       26
#define DIR_FileSize        28


/*--------------------------------------------------------------------------
   Private Functions
---------------------------------------------------------------------------*/

static FATFS *FatFs;    /* Pointer to the file system object, $C2A8 */


/*-----------------------------------------------------------------------*/
/* Load multi-byte word in the memory                                    */
/*-----------------------------------------------------------------------*/

/* 00:0C16 */
static WORD ld_word (const BYTE* ptr)   /* Load a 2-byte little-endian word */
{
    WORD rv;

    rv = ptr[1];
    rv = rv << 8 | ptr[0];
    return rv;
}

/* 00:0C49 */
static DWORD ld_dword (const BYTE* ptr) /* Load a 4-byte little-endian word */
{
    DWORD rv;

    rv = ptr[3];
    rv = rv << 8 | ptr[2];
    rv = rv << 8 | ptr[1];
    rv = rv << 8 | ptr[0];
    return rv;
}


/*-----------------------------------------------------------------------*/
/* String functions                                                      */
/*-----------------------------------------------------------------------*/

/* 00:0D98 */
/* Fill memory block */
static void mem_set (void* dst, int val, int cnt) {
    char *d = (char*)dst;
    while (cnt--) *d++ = (char)val;
}

/* 00:0DD4 */
/* Compare memory block. The bytes are sign extended (char), as upstream. */
static int mem_cmp (const void* dst, const void* src, int cnt) {
    const char *d = (const char *)dst, *s = (const char *)src;
    int r = 0;
    while (cnt-- && (r = *d++ - *s++) == 0) ;
    return r;
}


/*-----------------------------------------------------------------------*/
/* FAT access - Read value of a FAT entry                                */
/*-----------------------------------------------------------------------*/

/* 00:0E4E */
static CLUST get_fat (  /* 1:IO error, Else:Cluster status */
    CLUST clst          /* Cluster# to get the link information */
)
{
    BYTE buf[4];
    FATFS *fs = FatFs;

    if (clst < 2 || clst >= fs->n_fatent) return 1;    /* Range check */

    switch (fs->fs_type) {
    /* No FS_FAT12 case: PF_FS_FAT12 is 0 */
#if PF_FS_FAT16
    case FS_FAT16 :
        if (disk_readp(buf, fs->fatbase + clst / 256, ((UINT)clst % 256) * 2, 2)) break;
        return ld_word(buf);
#endif
#if PF_FS_FAT32
    case FS_FAT32 :
        if (disk_readp(buf, fs->fatbase + clst / 128, ((UINT)clst % 128) * 4, 4)) break;
        return ld_dword(buf) & 0x0FFFFFFF;
#endif
    }

    return 1;   /* An error occurred at the disk I/O layer */
}


/*-----------------------------------------------------------------------*/
/* Get sector# from cluster# / Get cluster field from directory entry    */
/*-----------------------------------------------------------------------*/

/* 00:1046 */
/* Static in upstream; main() calls it directly, so it is global here. */
DWORD clust2sect (  /* !=0: Sector number, 0: Failed - invalid cluster# */
    CLUST clst      /* Cluster# to be converted */
)
{
    FATFS *fs = FatFs;

    clst -= 2;
    if (clst >= (fs->n_fatent - 2)) return 0;      /* Invalid cluster# */
    return (DWORD)clst * fs->csize + fs->database;
}

/* 00:114A */
static CLUST get_clust (
    BYTE* dir       /* Pointer to directory entry */
)
{
    FATFS *fs = FatFs;
    CLUST clst = 0;

    if (_FS_32ONLY || (PF_FS_FAT32 && fs->fs_type == FS_FAT32)) {
        clst = ld_word(dir+DIR_FstClusHI);
        clst <<= 16;
    }
    clst |= ld_word(dir+DIR_FstClusLO);

    return clst;
}


/*-----------------------------------------------------------------------*/
/* Directory handling - Rewind directory index                           */
/*-----------------------------------------------------------------------*/

/* 00:11FF */
static FRESULT dir_rewind (
    DIR *dj         /* Pointer to directory object */
)
{
    CLUST clst;
    FATFS *fs = FatFs;

    dj->index = 0;
    clst = dj->sclust;
    if (clst == 1 || clst >= fs->n_fatent) {    /* Check start cluster range */
        return FR_DISK_ERR;
    }
    if (PF_FS_FAT32 && !clst && (_FS_32ONLY || fs->fs_type == FS_FAT32)) {  /* Replace cluster# 0 with root cluster# if in FAT32 */
        clst = (CLUST)fs->dirbase;
    }
    dj->clust = clst;                           /* Current cluster */
    dj->sect = (_FS_32ONLY || clst) ? clust2sect(clst) : fs->dirbase;   /* Current sector */

    return FR_OK;   /* Seek succeeded */
}


/*-----------------------------------------------------------------------*/
/* Directory handling - Move directory index next                        */
/*-----------------------------------------------------------------------*/

/* 00:1365 */
static FRESULT dir_next (   /* FR_OK:Succeeded, FR_NO_FILE:End of table */
    DIR *dj                 /* Pointer to directory object */
)
{
    CLUST clst;
    WORD i;
    FATFS *fs = FatFs;

    i = dj->index + 1;
    if (!i || !dj->sect) {  /* Report EOT when index has reached 65535 */
        return FR_NO_FILE;
    }
    if (!(i % 16)) {        /* Sector changed? */
        dj->sect++;         /* Next sector */

        if (dj->clust == 0) {   /* Static table */
            if (i >= fs->n_rootdir) {   /* Report EOT when end of table */
                return FR_NO_FILE;
            }
        }
        else {                  /* Dynamic table */
            if (((i / 16) & (fs->csize - 1)) == 0) {    /* Cluster changed? */
                clst = get_fat(dj->clust);      /* Get next cluster */
                if (clst <= 1) {
                    return FR_DISK_ERR;
                }
                if (clst >= fs->n_fatent) {     /* When it reached end of dynamic table */
                    return FR_NO_FILE;          /* Report EOT */
                }
                dj->clust = clst;               /* Initialize data for new cluster */
                dj->sect = clust2sect(clst);
            }
        }
    }
    dj->index = i;

    return FR_OK;
}


/*-----------------------------------------------------------------------*/
/* Directory handling - Find an object in the directory                  */
/*-----------------------------------------------------------------------*/

/* 00:1535 */
static FRESULT dir_find (
    DIR *dj,        /* Pointer to the directory object linked to the file name */
    BYTE *dir       /* 32-byte working buffer */
)
{
    FRESULT res;
    BYTE c;

    res = dir_rewind(dj);           /* Rewind directory object */
    if (res != FR_OK) return res;

    do {
        res = disk_readp(dir, dj->sect, (dj->index % 16) * 32, 32)  /* Read an entry */
            ? FR_DISK_ERR : FR_OK;
        if (res != FR_OK) break;
        c = dir[DIR_Name];          /* First character */
        if (c == 0) { res = FR_NO_FILE; break; }    /* Reached to end of table */
        if (!(dir[DIR_Attr] & AM_VOL) && !mem_cmp(dir, dj->fn, 11)) break;  /* Is it a valid entry? */
        res = dir_next(dj);         /* Next entry */
    } while (res == FR_OK);

    return res;
}


/*-----------------------------------------------------------------------*/
/* Pick a segment and create the object name in directory form           */
/*-----------------------------------------------------------------------*/

/* 00:1642 */
/* PF_USE_LCC is 0: bytes are copied as is (no upper-case conversion, no
   DBCS test), so the path must already be in upper case. */
static FRESULT create_name (
    DIR *dj,            /* Pointer to the directory object */
    const char **path   /* Pointer to pointer to the segment in the path string */
)
{
    BYTE c, ni, si, i, *sfn;
    const char *p;

    /* Create file name in directory form */
    sfn = dj->fn;
    mem_set(sfn, ' ', 11);
    si = i = 0; ni = 8;
    p = *path;
    for (;;) {
        c = p[si++];
        if (c <= ' ' || c == '/') break;    /* Break on end of segment */
        if (c == '.' || i >= ni) {
            if (ni != 8 || c != '.') break;
            i = 8; ni = 11;
            continue;
        }
        sfn[i++] = c;                       /* Single byte code */
    }
    *path = &p[si];                         /* Return pointer to the next segment */

    sfn[11] = (c <= ' ') ? 1 : 0;           /* Set last segment flag if end of path */

    return FR_OK;
}


/*-----------------------------------------------------------------------*/
/* Follow a file path                                                    */
/*-----------------------------------------------------------------------*/

/* 00:1747 */
static FRESULT follow_path (    /* FR_OK(0): successful, !=0: error code */
    DIR *dj,            /* Directory object to return last directory and found object */
    BYTE *dir,          /* 32-byte working buffer */
    const char *path    /* Full-path string to find a file or directory */
)
{
    FRESULT res;

    while (*path == ' ') path++;        /* Strip leading spaces */
    if (*path == '/') path++;           /* Strip heading separator if exist */
    dj->sclust = 0;                     /* Set start directory (always root dir) */

    if ((BYTE)*path < ' ') {            /* Null path means the root directory */
        res = dir_rewind(dj);
        dir[0] = 0;

    } else {                            /* Follow path */
        for (;;) {
            res = create_name(dj, &path);   /* Get a segment */
            if (res != FR_OK) break;
            res = dir_find(dj, dir);        /* Find it */
            if (res != FR_OK) break;        /* Could not find the object */
            if (dj->fn[11]) break;          /* Last segment match. Function completed. */
            if (!(dir[DIR_Attr] & AM_DIR)) { /* Cannot follow path because it is a file */
                res = FR_NO_FILE; break;
            }
            dj->sclust = get_clust(dir);    /* Follow next */
        }
    }

    return res;
}


/*-----------------------------------------------------------------------*/
/* Check a sector if it is an FAT boot record                            */
/*-----------------------------------------------------------------------*/

/* 00:1882 */
static BYTE check_fs (  /* 0:The FAT boot record, 1:Valid boot record but not an FAT, 2:Not a boot record, 3:Error */
    BYTE *buf,  /* Working buffer */
    DWORD sect  /* Sector# (lba) to check if it is an FAT boot record or not */
)
{
    if (disk_readp(buf, sect, 510, 2)) {    /* Read the boot record */
        return 3;
    }
    if (ld_word(buf) != 0xAA55) {           /* Check record signature */
        return 2;
    }

    if (!_FS_32ONLY && !disk_readp(buf, sect, BS_FilSysType, 2) && ld_word(buf) == 0x4146) {   /* Check FAT12/16 */
        return 0;
    }
    if (PF_FS_FAT32 && !disk_readp(buf, sect, BS_FilSysType32, 2) && ld_word(buf) == 0x4146) {  /* Check FAT32 */
        return 0;
    }
    return 1;
}


/*--------------------------------------------------------------------------
   Public Functions
--------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------*/
/* Mount/Unmount a Logical Drive                                         */
/*-----------------------------------------------------------------------*/

/* 00:195B */
FRESULT pf_mount (
    FATFS *fs       /* Pointer to new file system object */
)
{
    BYTE fmt, buf[36];
    DWORD bsect, fsize, tsect, mclst;

    FatFs = 0;

    if (disk_initialize() & STA_NOINIT) {   /* Check if the drive is ready or not */
        return FR_NOT_READY;
    }

    /* Search FAT partition on the drive */
    bsect = 0;
    fmt = check_fs(buf, bsect);             /* Check sector 0 as an SFD format */
    if (fmt == 1) {                         /* Not an FAT boot record, it may be FDISK format */
        /* Check a partition listed in top of the partition table */
        if (disk_readp(buf, bsect, MBR_Table, 16)) {    /* 1st partition entry */
            fmt = 3;
        } else {
            if (buf[4]) {                   /* Is the partition existing? */
                bsect = ld_dword(&buf[8]);  /* Partition offset in LBA */
                fmt = check_fs(buf, bsect); /* Check the partition */
            }
        }
    }
    if (fmt == 3) return FR_DISK_ERR;
    if (fmt) return FR_NO_FILESYSTEM;       /* No valid FAT partition is found */

    /* Initialize the file system object */
    if (disk_readp(buf, bsect, 13, sizeof (buf))) return FR_DISK_ERR;

    fsize = ld_word(buf+BPB_FATSz16-13);                /* Number of sectors per FAT */
    if (!fsize) fsize = ld_dword(buf+BPB_FATSz32-13);

    fsize *= buf[BPB_NumFATs-13];                       /* Number of sectors in FAT area */
    fs->fatbase = bsect + ld_word(buf+BPB_RsvdSecCnt-13); /* FAT start sector (lba) */
    fs->csize = buf[BPB_SecPerClus-13];                 /* Number of sectors per cluster */
    fs->n_rootdir = ld_word(buf+BPB_RootEntCnt-13);     /* Number of root directory entries */
    tsect = ld_word(buf+BPB_TotSec16-13);               /* Number of sectors on the file system */
    if (!tsect) tsect = ld_dword(buf+BPB_TotSec32-13);
    /* The division calls 00:273E, which kernel.sym labels U32Mod. Its
       result is the quotient (local +4 of the shared divide engine), so
       it is a plain unsigned divide, as upstream. */
    mclst = (tsect                          /* Last cluster# + 1 */
        - ld_word(buf+BPB_RsvdSecCnt-13) - fsize - fs->n_rootdir / 16
        ) / fs->csize + 2;
    fs->n_fatent = (CLUST)mclst;

    fmt = 0;                            /* Determine the FAT sub type */
    /* No FAT12 test (mclst < 0xFF7): PF_FS_FAT12 is 0 */
    if (PF_FS_FAT16 && mclst >= 0xFF8 && mclst < 0xFFF7) fmt = FS_FAT16;
    if (PF_FS_FAT32 && mclst >= 0xFFF7) fmt = FS_FAT32;
    if (!fmt) return FR_NO_FILESYSTEM;
    fs->fs_type = fmt;

    if (_FS_32ONLY || (PF_FS_FAT32 && fmt == FS_FAT32)) {
        fs->dirbase = ld_dword(buf+(BPB_RootClus-13));  /* Root directory start cluster */
    } else {
        fs->dirbase = fs->fatbase + fsize;              /* Root directory start sector (lba) */
    }
    fs->database = fs->fatbase + fsize + fs->n_rootdir / 16;    /* Data start sector (lba) */

    fs->flag = 0;
    FatFs = fs;

    return FR_OK;
}


/*-----------------------------------------------------------------------*/
/* Open or Create a File                                                 */
/*-----------------------------------------------------------------------*/

/* 00:1EEE */
FRESULT pf_open (
    const char *path    /* Pointer to the file name */
)
{
    FRESULT res;
    DIR dj;
    BYTE sp[12], dir[32];
    FATFS *fs = FatFs;


    if (!fs) return FR_NOT_ENABLED;     /* Check file system */

    fs->flag = 0;
    dj.fn = sp;
    res = follow_path(&dj, dir, path);  /* Follow the file path */
    if (res != FR_OK) return res;       /* Follow failed */
    if (!dir[0] || (dir[DIR_Attr] & AM_DIR)) return FR_NO_FILE; /* It is a directory */

    fs->org_clust = get_clust(dir);         /* File start cluster */
    fs->fsize = ld_dword(dir+DIR_FileSize); /* File size */
    fs->fptr = 0;                           /* File pointer */
    fs->flag = FA_OPENED;

    return FR_OK;
}


/*-----------------------------------------------------------------------*/
/* Read File                                                             */
/*-----------------------------------------------------------------------*/
#if PF_USE_READ

/* 00:2018 */
/* Linked but never called by stage1. */
FRESULT pf_read (
    void* buff,     /* Pointer to the read buffer (NULL:Forward data to the stream)*/
    UINT btr,       /* Number of bytes to read */
    UINT* br        /* Pointer to number of bytes read */
)
{
    DRESULT dr;
    CLUST clst;
    DWORD sect, remain;
    UINT rcnt;
    BYTE cs, *rbuff = buff;
    FATFS *fs = FatFs;


    *br = 0;
    if (!fs) return FR_NOT_ENABLED;     /* Check file system */
    if (!(fs->flag & FA_OPENED)) return FR_NOT_OPENED;  /* Check if opened */

    remain = fs->fsize - fs->fptr;
    if (btr > remain) btr = (UINT)remain;   /* Truncate btr by remaining bytes */

    while (btr) {                           /* Repeat until all data transferred */
        if ((fs->fptr % 512) == 0) {        /* On the sector boundary? */
            cs = (BYTE)(fs->fptr / 512 & (fs->csize - 1));  /* Sector offset in the cluster */
            if (!cs) {                      /* On the cluster boundary? */
                if (fs->fptr == 0) {        /* On the top of the file? */
                    clst = fs->org_clust;
                } else {
                    clst = get_fat(fs->curr_clust);
                }
                if (clst <= 1) ABORT(FR_DISK_ERR);
                fs->curr_clust = clst;      /* Update current cluster */
            }
            sect = clust2sect(fs->curr_clust);  /* Get current sector */
            if (!sect) ABORT(FR_DISK_ERR);
            fs->dsect = sect + cs;
        }
        rcnt = 512 - (UINT)fs->fptr % 512;  /* Get partial sector data from sector buffer */
        if (rcnt > btr) rcnt = btr;
        dr = disk_readp(rbuff, fs->dsect, (UINT)fs->fptr % 512, rcnt);
        if (dr) ABORT(FR_DISK_ERR);
        fs->fptr += rcnt;                   /* Advances file read pointer */
        btr -= rcnt; *br += rcnt;           /* Update read counter */
        if (rbuff) rbuff += rcnt;           /* Advances the data pointer if destination is memory */
    }

    return FR_OK;
}
#endif

/* PF_USE_WRITE, PF_USE_LSEEK and PF_USE_DIR are 0: pf_write, pf_lseek,
   pf_opendir and pf_readdir are not in the binary. */


/*--------------------------------------------------------------------------
   Vendor accessors (not part of Petit FatFs). None of them checks FatFs.
--------------------------------------------------------------------------*/

/* 00:243D */
DWORD FsFileSize(void)
{
    return FatFs->fsize;
}

/* 00:246B */
BYTE FsType(void)
{
    return FatFs->fs_type;
}

/* 00:247A */
DWORD FsFileCluster(void)
{
    return FatFs->org_clust;
}

/* 00:24A8 */
/* Next cluster in the chain: 1 on error, >= n_fatent at the end */
DWORD FsNextCluster(DWORD clst)
{
    return get_fat(clst);
}

/* 00:24D2 */
BYTE FsClusterSectors(void)
{
    return FatFs->csize;
}
