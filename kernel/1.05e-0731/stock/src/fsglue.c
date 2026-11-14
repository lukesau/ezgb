/* Bank 0 entry points for the FatFs calls, each a banked_call into the
   bank that holds the function. The names are ours. */

#include "ff.h"

/* bank 5's are banked (ff.c, BANK == 5) */
DWORD clust2sect (FATFS* fs, DWORD clst) __banked;
DWORD get_fat (FATFS* fs, DWORD clst) __banked;

/* 00:1926 */
FRESULT fs_open (FIL* fp, const TCHAR* path, BYTE mode)
{
	return f_open(fp, path, mode);
}

/* 00:1941 */
FRESULT fs_read (FIL* fp, void* buff, UINT btr, UINT* br)
{
	return f_read(fp, buff, btr, br);
}

/* 00:1963 */
FRESULT fs_write (FIL* fp, const void* buff, UINT btw, UINT* bw)
{
	return f_write(fp, buff, btw, bw);
}

/* 00:1985 */
FRESULT fs_lseek (FIL* fp, DWORD ofs)
{
	return f_lseek(fp, ofs);
}

/* 00:19a1 */
FRESULT fs_close (FIL* fp)
{
	return f_close(fp);
}

/* 00:19b1 */
FRESULT fs_mkdir (const TCHAR* path)
{
	return f_mkdir(path);
}

/* 00:19c1 */
DWORD fs_clust2sect (FATFS* fs, DWORD clst)
{
	return clust2sect(fs, clst);
}

/* 00:19f5 */
DWORD fs_get_fat (FATFS* fs, DWORD clst)
{
	return get_fat(fs, clst);
}
