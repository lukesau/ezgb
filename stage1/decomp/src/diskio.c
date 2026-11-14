/* Stock stage1 diskio.c: the two Petit FatFs disk hooks.
 * 00:0BE6-00:0C15 on FW4, $31 higher on FW5-0918. */
#include "diskio.h"
#include "sd.h"

/* 00:0BE6: the FPGA has the card ready before stage1 runs */
DSTATUS disk_initialize(void)
{
    return 0;
}

/* 00:0BE9: always RES_OK; SD errors are not reported */
DRESULT disk_readp(BYTE *buff, DWORD sector, UINT offset, UINT count)
{
    disk_readp_impl(sector, offset, count, buff);
    return RES_OK;
}

/* 00:0C13: an unreachable second `return RES_OK`. Left out. */
