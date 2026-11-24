/*-----------------------------------------------------------------------*/
/* Low level disk I/O module skeleton for FatFs     (C)ChaN, 2014        */
/*-----------------------------------------------------------------------*/
/* If a working storage control module is available, it should be        */
/* attached to the FatFs via a glue function rather than modifying it.   */
/* This is an example of glue functions to attach various exsisting      */
/* storage control modules to the FatFs module with a defined API.       */
/*-----------------------------------------------------------------------*/

#include "diskio.h"		/* FatFs lower layer API */
#include "ezgb_hw.h"
//#include "usbdisk.h"	/* Example: Header file of existing USB MSD control module */
//#include "atadrive.h"	/* Example: Header file of existing ATA harddisk control module */
//#include "sdcard.h"		/* Example: Header file of existing MMC/SDC contorl module */
#include "SD_operate.h"
#include "main.h"
#include "RTC.h"

/* Definitions of physical drive number for each drive */
#define ATA		0	/* Example: Map ATA harddisk to physical drive 0 */
#define MMC		1	/* Example: Map MMC/SD card to physical drive 1 */
#define USB		2	/* Example: Map USB MSD to physical drive 2 */


/*-----------------------------------------------------------------------*/
/* Get Drive Status                                                      */
/*-----------------------------------------------------------------------*/

DSTATUS disk_status (
	BYTE pdrv		/* Physical drive nmuber to identify the drive */
)
{
	/*DSTATUS stat;
	int result;

	switch (pdrv) {
	case ATA :
		result = ATA_disk_status();

		// translate the reslut code here

		return stat;

	case MMC :
		result = MMC_disk_status();

		// translate the reslut code here

		return stat;

	case USB :
		result = USB_disk_status();

		// translate the reslut code here

		return stat;
	}
	return STA_NOINIT;*/
	return RES_OK;
}



/*-----------------------------------------------------------------------*/
/* Inidialize a Drive                                                    */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (
	BYTE pdrv				/* Physical drive nmuber to identify the drive */
)
{
	/*DSTATUS stat;
	int result;

	switch (pdrv) {
	case ATA :
		result = ATA_disk_initialize();

		// translate the reslut code here

		return stat;

	case MMC :
		result = MMC_disk_initialize();

		// translate the reslut code here

		return stat;

	case USB :
		result = USB_disk_initialize();

		// translate the reslut code here

		return stat;
	}
	return STA_NOINIT;*/
	return RES_OK;
}



/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/

DRESULT disk_read (
	BYTE pdrv,		/* Physical drive nmuber to identify the drive */
	BYTE *buff,		/* Data buffer to store read data */
	DWORD sector,	/* Sector address in LBA */
	UINT count		/* Number of sectors to read */
)
{
	/*DRESULT res;
	int result;

	switch (pdrv) {
	case ATA :
		// translate the arguments here

		result = ATA_disk_read(buff, sector, count);

		// translate the reslut code here

		return res;

	case MMC :
		// translate the arguments here

		result = MMC_disk_read(buff, sector, count);

		// translate the reslut code here

		return res;

	case USB :
		// translate the arguments here

		result = USB_disk_read(buff, sector, count);

		// translate the reslut code here

		return res;
	}

	return RES_PARERR;*/
	DRESULT res;
	res = Read_SD_sectors(sector, count, buff);
	return res;
}



/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/

#if _USE_WRITE
DRESULT disk_write (
	BYTE pdrv,			/* Physical drive nmuber to identify the drive */
	const BYTE *buff,	/* Data to be written */
	DWORD sector,		/* Sector address in LBA */
	UINT count			/* Number of sectors to write */
)
{
	/*DRESULT res;
	int result;

	switch (pdrv) {
	case ATA :
		// translate the arguments here

		result = ATA_disk_write(buff, sector, count);

		// translate the reslut code here

		return res;

	case MMC :
		// translate the arguments here

		result = MMC_disk_write(buff, sector, count);

		// translate the reslut code here

		return res;

	case USB :
		// translate the arguments here

		result = USB_disk_write(buff, sector, count);

		// translate the reslut code here

		return res;
	}

	return RES_PARERR;*/
	DRESULT res;
	res = Write_SD_sectors(sector, count, buff);
	return res;
}
#endif


/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

#if _USE_IOCTL
DRESULT disk_ioctl (
	BYTE pdrv,		/* Physical drive nmuber (0..) */
	BYTE cmd,		/* Control code */
	void *buff		/* Buffer to send/receive control data */
)
{
	/*DRESULT res;
	int result;

	switch (pdrv) {
	case ATA :

		// Process of the command for the ATA drive

		return res;

	case MMC :

		// Process of the command for the MMC/SD card

		return res;

	case USB :

		// Process of the command the USB drive

		return res;
	}

	return RES_PARERR;*/
	return RES_OK;
}
#endif

#define UNBCD(x) (((x) & 0xF) + (((x) >> 4) * 10))
// --------------------------------------------------------------------
	
DWORD get_fattime (void)
{
		UINT8 datetime[7];
		hw_set_page(A000Address_RTC);//read RTC	OS mode	
		datetime[_SEC] = *((volatile UINT8 *)(Base_RTCbuffer+8));//Seconds_re
		datetime[_MIN] = *((volatile UINT8 *)(Base_RTCbuffer+9));//Minutes_re
		datetime[_HOUR] = *((volatile UINT8 *)(Base_RTCbuffer+0xA));//Hours_re
		datetime[_DAY] = *((volatile UINT8 *)(Base_RTCbuffer+0xB));//Days_re
		datetime[_WKD] = *((volatile UINT8 *)(Base_RTCbuffer+0xC));//Weekdays_re
		datetime[_MONTH] = *((volatile UINT8 *)(Base_RTCbuffer+0xD));//Century_months_re
		datetime[_YEAR] = *((volatile UINT8 *)(Base_RTCbuffer+0xE));//Years_re					
		hw_set_page(A000Address_TF);		
		/* Mask the high bits first, as RTC.c does when displaying the time:
		        sec  bit7 = CH (clock halt); 0x80 becomes 80 via UNBCD and 80>>1 = 40 > 29
		        min  normally 0-59; a bad value <<5 overflows into the hour field
		        month bit7 = century; 0x91 becomes 91 via UNBCD and <<21 overflows the year
		   Without the mask, new/updated save files get wrong timestamps (no data loss,
		   but time-ordered listings look wrong). */
		return ((DWORD)(UNBCD(datetime[_YEAR]  & 0x7F)+20) << 25
		      | (DWORD)UNBCD(datetime[_MONTH] & 0x1F) << 21
		      | (DWORD)UNBCD(datetime[_DAY]   & 0x3F) << 16
		      | (DWORD)UNBCD(datetime[_HOUR]  & 0x3F) << 11
		      | (DWORD)UNBCD(datetime[_MIN]   & 0x7F) <<  5
		      | (DWORD)(UNBCD(datetime[_SEC]  & 0x7F) >> 1));
}
