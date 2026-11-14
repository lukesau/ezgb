/*---------------------------------------------------------------------------/
/  Petit FatFs - Configuration file
/  Settings found in the EZ Flash stage1 binary (FW4 00:0C16-00:24E2).
/  R0.03a names; the older R0.03 names are in the comments.
/---------------------------------------------------------------------------*/
#ifndef PF_CONF_DEFINED
#define PF_CONF_DEFINED 8088    /* Revision ID */

/* Function configurations */

#define PF_USE_READ     1   /* _USE_READ: pf_read is linked (never called) */
#define PF_USE_DIR      0   /* _USE_DIR: no pf_opendir/pf_readdir/get_fileinfo */
#define PF_USE_LSEEK    0   /* _USE_LSEEK: no pf_lseek */
#define PF_USE_WRITE    0   /* _USE_WRITE: no pf_write, no disk_writep */

#define PF_FS_FAT12     0   /* _FS_FAT12: no case 1 in get_fat, no 0xFF7 test in pf_mount */
#define PF_FS_FAT16     1   /* _FS_FAT16: get_fat case 2, check_fs offset 54 */
#define PF_FS_FAT32     1   /* _FS_FAT32: get_fat case 3, check_fs offset 82, RootClus */

/* Locale and namespace configurations */

#define PF_USE_LCC      0   /* _USE_LCC: create_name copies bytes as is, no
                            /  case conversion, no DBCS test, no table */
#define PF_CODE_PAGE    437 /* Not used when PF_USE_LCC is 0 */

/* R0.03a has no _WORD_ACCESS option. ld_word/ld_dword read byte by byte,
/  which is what R0.03 did with _WORD_ACCESS 0. Petit FatFs has no
/  _FS_RPATH: follow_path always starts at the root directory. */

#endif
