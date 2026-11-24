/* ====================================================================
 *  ezgb_hw.c  -  cartridge hardware primitives
 *  --------------------------------------------------------------------
 *  Lives in bank 0 (no #pragma bank), so every module can call it with a
 *  plain direct call: 0x0000-0x3FFF is always mapped.
 *
 *  Before this file existed the same three functions were copy-pasted in
 *  Bank_fun.c / GBcard_OP.c / Help.c / RTC.c / diskio.c (five identical
 *  copies) and SD_operate.c had its own control/status pair.
 * ==================================================================== */

#include <gb/gb.h>
#include "ezgb_hw.h"

/* Map an A000Address_* page into the 0xA000-0xBFFF window.
   Always writes: the SD layer re-asserts the TF page before every sector
   transfer, and a remembered "current page" would happily skip a write the
   FPGA dropped. Five register writes are nothing next to one block read. */
void hw_set_page(UINT8 page)
{
	HW_BEGIN();
	HW_PAGE = page;
	HW_END();
}

/* SD controller control word. */
void hw_sd_control(UINT8 value)
{
	HW_BEGIN();
	HW_SD_CTRL = value;
	HW_END();
}

/* SD command status byte, read through the window. */
UINT8 hw_sd_response(void)
{
	return HW_REG(HW_WINDOW);
}

/* end of file */
