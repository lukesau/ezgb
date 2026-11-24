#include <gb/gb.h>
#include "ezgb_hw.h"
#include <stdio.h>
#include <string.h>

#include "SD_operate.h"

#define SD_operate_BANK
#include "banks.h"


// --------------------------------------------------------------------
 
//---------------------------------------------------------------------
// --------------------------------------------------------------------

// --------------------------------------------------------------------
#define SD_CMD_TIMEOUT	0xFFFFU		/* command poll limit: prevents a hang if the FPGA never answers */
#define SD_CMD_ROUNDS	3U			/* rounds of that limit per attempt (~1.3s total) */
/* main.h's A000Address_TF. Kept local so this file does not have to pull in
   main.h (which includes ff.h) just for one constant. */
#define SD_TF_PAGE		0U

/* See SD_operate.h: field diagnostics, read by Show_error_info(). */
UINT8 sd_err_lba[3];
UINT8 sd_err_cnt;


UINT8 Read_SD_sectors(UINT32 address,UINT8 count,UINT8* SDbuffer)__banked
{
	UINT16 i;			/* 16-bit: a UINT8 counter wraps at 252+4 when count=255 -> endless loop */
	UINT8 blocks;
	UINT8 res;
	UINT16 len;
	UINT16 guard;
	UINT8  tries;
	UINT8  rounds;

	if((SDbuffer == NULL) || (count == 0U))
		return 0xFFU;

	/*
	  * Two hard limits; exceeding either corrupts memory silently:
	  *   1) buffer offset (UINT16)i << 9 - i is 16 bits, so i >= 128 wraps the shift
	  *      back to 0 and get_data/set_data overwrite data already read.
	  *   2) blocks are moved four at a time, so the caller's buffer must hold
	  *      count*512 bytes; main.c passes SD_buffer (0x200), so only 1 block works.
	  * count is capped at 4 (i <= 3, offset <= 1536, no overflow);
	  * FatFs always calls with count=1, so the cap changes nothing today.
	 */
	if(count > 4U)
		return 0xFFU;		/* block count beyond what this function and buffer can take */

	/* The status byte and the data both come out of the 0xA000 window, so the TF
	   page must really be mapped - otherwise a poll reads a file name instead of
	   0xE1, "succeeds" instantly and get_data copies SRAM text into the FatFs
	   window. Every caller wants the card here, so assert it (cached, so this is
	   a byte compare when it is already selected). */
	hw_set_page(SD_TF_PAGE);

	/* Retry a timed-out read instead of failing the whole FatFs call.
	   A card that is still busy programming a previous write, or a slow card
	   picking an isolated sector, can leave the FPGA busy flag at 0xE1 for
	   longer than the poll limit. get_fat()/move_window() turn one such timeout
	   into FR_DISK_ERR for the entire directory walk, which the UI shows as
	   "File system error! 01" even though the very same sector reads fine a
	   moment later. Two attempts, each waiting SD_CMD_ROUNDS x the poll limit,
	   controller reset in between. */
	for(tries = 0U; tries < 2U; tries++)
	{
		res = 0U;
		hw_sd_control(1);

		for(i=0;i<count;i+=4U)
		{
			blocks = (count-i>4U)?4U:(count-i);

			HW_BEGIN();
			HW_SD_ARG(0) = (address+i)&0x000000FFU;
			HW_SD_ARG(1) = ((address+i)&0x0000FF00U) >>8u;
			HW_SD_ARG(2) = ((address+i)&0x00FF0000U) >>16u;
			HW_SD_ARG(3) = ((address+i)&0xFF000000U) >>24u;
			HW_SD_BLOCKS = blocks;
			HW_END();
			hw_sd_control(3);

			/* A single UINT16 counter runs out in ~0.4s at 4.19MHz, which a slow
			   card picking an isolated sector can exceed. Wait in rounds instead
			   of widening the counter: a 32-bit decrement in this loop would make
			   every poll cost twice as much. */
			rounds = SD_CMD_ROUNDS;
			res = 0xE1U;
			while(rounds--)
			{
				guard = SD_CMD_TIMEOUT;
				while((res = hw_sd_response()) == 0xE1U)
				{
					if(--guard == 0U) { res = 0xFEU; break; }
				}
				if(res != 0xFEU)
					break;			/* card answered */
			}
			hw_sd_control(1);
			if(res == 0xFEU)
				break;				/* do not keep half of a multi-block round */

			len = (UINT16)blocks << 9;					/* bytes of this round, not of the whole request */
			get_data(SDbuffer + ((UINT16)i << 9),SD_rwAddress,len);		/* i<=3 (count<=4 above), so no overflow */
		}

		hw_sd_control(0);
		if(res != 0xFEU)
			return 0;

		/* Give the card time to finish/abort the command it never answered and
		   make sure the A000 window really maps the TF page again: the status
		   byte read by hw_sd_response() lives there too. */
		delay(100);
		hw_set_page(SD_TF_PAGE);
	}

	/* Record which sector beat us, see SD_operate.h */
	sd_err_lba[0] = (UINT8)(address & 0x000000FFU);
	sd_err_lba[1] = (UINT8)((address >> 8) & 0x000000FFU);
	sd_err_lba[2] = (UINT8)((address >> 16) & 0x000000FFU);
	if(sd_err_cnt != 0xFFU)
		sd_err_cnt++;

	return 0xFEU;
}
// --------------------------------------------------------------------
UINT8 Write_SD_sectors(UINT32 address,UINT8 count, UINT8* SDbuffer)__banked
{
	UINT16 i;
	UINT8 blocks;
	UINT8 res;
	UINT16 len;
	UINT16 guard;

	if((SDbuffer == NULL) || (count == 0U))
		return 0xFFU;

	/*
	  * Two hard limits; exceeding either corrupts memory silently:
	  *   1) buffer offset (UINT16)i << 9 - i is 16 bits, so i >= 128 wraps the shift
	  *      back to 0 and get_data/set_data overwrite data already read.
	  *   2) blocks are moved four at a time, so the caller's buffer must hold
	  *      count*512 bytes; main.c passes SD_buffer (0x200), so only 1 block works.
	  * count is capped at 4 (i <= 3, offset <= 1536, no overflow);
	  * FatFs always calls with count=1, so the cap changes nothing today.
	 */
	if(count > 4U)
		return 0xFFU;		/* block count beyond what this function and buffer can take */

	hw_set_page(SD_TF_PAGE);	/* see Read_SD_sectors */
	hw_sd_control(1);
	hw_sd_control(3);
	for(i=0;i<count;i+=4U)
	{
		blocks = (count-i>4U)?4U:(count-i);

		len = (UINT16)blocks << 9;
		set_data(SD_rwAddress,SDbuffer + ((UINT16)i << 9),len);		/* i<=3: no overflow */

		HW_BEGIN();
		HW_SD_ARG(0) = (address+i)&0x000000FFU;
		HW_SD_ARG(1) = ((address+i)&0x0000FF00U) >>8u;
		HW_SD_ARG(2) = ((address+i)&0x00FF0000U) >>16u;
		HW_SD_ARG(3) = ((address+i)&0xFF000000U) >>24u;
		HW_SD_BLOCKS = 0x80+blocks;
		HW_END();

		guard = SD_CMD_TIMEOUT;
		while((res = hw_sd_response()) == 0xE1U)
		{
			if(--guard == 0U)
			{
				hw_sd_control(0);
				return 0xFEU;		/* FPGA timeout */
			}
		}
	}
	delay(10);
	hw_sd_control(0);
	return 0;
}
// --------------------------------------------------------------------
