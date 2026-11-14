/* FatFs disk I/O layer: the sector transfers are banked functions in bank 2.
   pdrv is ignored (one drive). The SD names are ours. */

#include "diskio.h"

/* bank 2: SdRead at 4027, SdWrite at 41d5 */
DRESULT SdRead (DWORD sector, BYTE count, BYTE* buff) __banked;
DRESULT SdWrite (DWORD sector, BYTE count, const BYTE* buff) __banked;

/* 00:1a29 */
DSTATUS disk_status (BYTE pdrv)
{
	return 0;
}

/* 00:1a2c */
DSTATUS disk_initialize (BYTE pdrv)
{
	return 0;
}

/* 00:1a2f */
DRESULT disk_read (BYTE pdrv, BYTE* buff, DWORD sector, UINT count)
{
	DRESULT res;

	res = SdRead(sector, count, buff);
	return res;
}

/* 00:1a53 */
DRESULT disk_write (BYTE pdrv, const BYTE* buff, DWORD sector, UINT count)
{
	DRESULT res;

	res = SdWrite(sector, count, buff);
	return res;
}

/* 00:1a77 */
DRESULT disk_ioctl (BYTE pdrv, BYTE cmd, void* buff)
{
	return RES_OK;
}

/* 00:1a7a: select an FPGA register page ($A000 window) */
void SetFpgaPage (BYTE page)
{
	*(BYTE *)0x7F00 = 0xE1;
	*(BYTE *)0x7F10 = 0xE2;
	*(BYTE *)0x7F20 = 0xE3;
	*(BYTE *)0x7FC0 = page;
	*(BYTE *)0x7FF0 = 0xE4;
}

/* 00:1a9a: the cart RTC (page 6, BCD from $A008: second, minute, hour,
   day, weekday, month, year since 2000) packed as a FAT timestamp */
DWORD get_fattime (void)
{
	BYTE rtc[7];

	SetFpgaPage(6);
	rtc[0] = *(volatile BYTE *)0xA008;
	rtc[1] = *(volatile BYTE *)0xA009;
	rtc[2] = *(volatile BYTE *)0xA00A;
	rtc[3] = *(volatile BYTE *)0xA00B;
	rtc[4] = *(volatile BYTE *)0xA00C;
	rtc[5] = *(volatile BYTE *)0xA00D;
	rtc[6] = *(volatile BYTE *)0xA00E;
	SetFpgaPage(0);

	return ((DWORD)((rtc[6] & 0x0F) + (rtc[6] >> 4) * 10 + 20) << 25)
		| ((DWORD)((rtc[5] & 0x0F) + (rtc[5] >> 4) * 10) << 21)
		| ((DWORD)((rtc[3] & 0x0F) + ((rtc[3] & 0x3F) >> 4) * 10) << 16)
		| ((DWORD)((rtc[2] & 0x0F) + ((rtc[2] & 0x3F) >> 4) * 10) << 11)
		| ((DWORD)((rtc[1] & 0x0F) + (rtc[1] >> 4) * 10) << 5)
		| ((DWORD)((rtc[0] & 0x0F) + (rtc[0] >> 4) * 10) >> 1);
}
