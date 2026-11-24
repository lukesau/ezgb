/*-----------------------------------------------------------------------
/  PFF - Low level disk interface modlue include file    (C)ChaN, 2014
/-----------------------------------------------------------------------*/

#ifndef _SD_OPERATE
#define _SD_OPERATE

#ifdef __cplusplus
extern "C" {
#endif

#define SD_rwAddress 0xA000U

/* Diagnostics: the last LBA whose read never completed (LSB first) and how many
   block reads have failed since boot. Shown by Show_error_info() so a field
   failure can be told apart without a debugger: LBA 0 = mount, the root
   directory's own sectors = path lookup, a cluster LBA = directory scan. */
extern UINT8 sd_err_lba[3];
extern UINT8 sd_err_cnt;

extern UINT8 Read_SD_sectors(UINT32 address,UINT8 count,UINT8* SDbuffer) __banked;
extern UINT8 Write_SD_sectors(UINT32 address,UINT8 count, UINT8* SDbuffer)__banked;

extern void test_fun_in_SD(void) __banked;

#ifdef __cplusplus
}
#endif

#endif
