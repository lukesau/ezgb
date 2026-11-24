/* ====================================================================
 *  ezgb_hw.h  -  the cartridge's memory-mapped registers, in one place
 *  --------------------------------------------------------------------
 *  The EZGB cartridge exposes an FPGA register block at 0x7F00-0x7FFF.
 *  Every write must be wrapped in the unlock/commit sequence:
 *
 *      0x7F00 = 0xE1      0x7F10 = 0xE2      0x7F20 = 0xE3
 *      <register write(s)>
 *      0x7FF0 = 0xE4      -> commit
 *
 *  The 0xA000-0xBFFF window then shows the page selected in 0x7FC0:
 *      A000Address_TF / _PSRAM / _FATbuffer / _SRAM / _RTC  (see main.h)
 *
 *  0x4000 latches the PSRAM/SRAM bank used by that window. It looks like
 *  the MBC1 SRAM-bank register but on this cartridge it selects the
 *  PSRAM bank, so use HW_BANK and never the raw address.
 *
 *  Rules:
 *    - never call these from an interrupt handler: the sequence is not
 *      atomic and a page switch in the middle of a copy corrupts data;
 *    - a page switch costs several writes plus FPGA latency, so cache the
 *      current page instead of re-selecting it in a loop.
 * ==================================================================== */
#ifndef EZGB_HW_H
#define EZGB_HW_H

#include <gb/gb.h>

/* 8-bit memory-mapped register access */
#define HW_REG(addr)        (*(volatile UINT8 *)(addr))

/* ---- FPGA register block ------------------------------------------ */
#define HW_UNLOCK_1         HW_REG(0x7F00)
#define HW_UNLOCK_2         HW_REG(0x7F10)
#define HW_UNLOCK_3         HW_REG(0x7F20)
#define HW_PAGE             HW_REG(0x7FC0)      /* 0xA000 window target  */
#define HW_COMMIT           HW_REG(0x7FF0)
#define HW_SD_CTRL          HW_REG(0x7F30)      /* SD controller word    */

/* ---- FPGA register block, remaining registers ---------------------- */
/* Boot configuration: both are written 0 just before HW_RESET. */
#define HW_BOOT_MODE        HW_REG(0x7F31)
#define HW_BOOT_CFG         HW_REG(0x7F32)
/* NOR flash page (only referenced by the unused SetNORpage). */
#define HW_NOR_PAGE         HW_REG(0x7F33)
/* 16-bit PSRAM page used when the window shows PSRAM. */
#define HW_PSRAM_PAGE_LO    HW_REG(0x7F34)
#define HW_PSRAM_PAGE_HI    HW_REG(0x7F35)
/* Buffer/transfer trigger: 3 = start, 0 = idle. */
#define HW_DMA_CTRL         HW_REG(0x7F36)
/* DMG/GBC type control (SetTypesControl). */
#define HW_GB_TYPE          HW_REG(0x7F37)
/* Cartridge metadata handed to the loader. */
#define HW_ROM_BANKS_LO     HW_REG(0x7FC1)
#define HW_ROM_BANKS_HI     HW_REG(0x7FC2)
#define HW_HDR_CHECKSUM     HW_REG(0x7FC3)
#define HW_RAM_BANKS        HW_REG(0x7FC4)
/* RTC page selector (Set_RTCplus). */
#define HW_RTC_PAGE         HW_REG(0x7FD0)
/* SPI flash write-enable latch. */
#define HW_SPI_WRITE_EN     HW_REG(0x7FD1)
/* Pulse that makes the FPGA latch the settings written above. */
#define HW_UPDATE_PULSE     HW_REG(0x7FD2)
/* "GB Boy" clone compatibility flag (Set_GBboy). */
#define HW_GBBOY_MODE       HW_REG(0x7FD4)
/* Write 0x80 to reset the cartridge. */
#define HW_RESET            HW_REG(0x7FE0)

/* The window itself, as an lvalue (status/ data reads). */
#define HW_WINDOW_REG       HW_REG(HW_WINDOW)

/* unlock / commit magic values */
#define HW_MAGIC_1          0xE1U
#define HW_MAGIC_2          0xE2U
#define HW_MAGIC_3          0xE3U
#define HW_MAGIC_COMMIT     0xE4U

/* Wrap any FPGA register write in this pair:
 *     HW_BEGIN();
 *     <register writes>
 *     HW_END();
 * 27 hand-written copies of the sequence existed before; use the macros so
 * the order/timing lives in exactly one place. */
#define HW_BEGIN()          do { \
                                HW_UNLOCK_1 = HW_MAGIC_1; \
                                HW_UNLOCK_2 = HW_MAGIC_2; \
                                HW_UNLOCK_3 = HW_MAGIC_3; \
                            } while(0)
#define HW_END()            do { \
                                HW_COMMIT = HW_MAGIC_COMMIT; \
                            } while(0)

/* SD command block (see SD_operate.c) */
#define HW_SD_ARG(i)        HW_REG(0x7FB0 + (i))    /* 0..3 = LBA bytes  */
#define HW_SD_BLOCKS        HW_REG(0x7FB4)          /* block count       */
#define HW_SD_BUSY          0xE1U                   /* status "busy"     */

/* ---- data window --------------------------------------------------- */
#define HW_WINDOW           0xA000U                 /* 0xA000-0xBFFF     */
#define HW_WINDOW_SIZE      0x2000U                 /* 8 KB page         */

/* ---- PSRAM/SRAM bank latch for the window -------------------------- */
#define HW_BANK             HW_REG(0x4000)

/* ---- operations that need more than a plain store ------------------ */
/* Map the given A000Address_* page into the window. */
void  hw_set_page(UINT8 page);
/* SD controller control word: 0 = off, 1 = idle, 3 = run. */
void  hw_sd_control(UINT8 value);
/* Read the SD command status byte (HW_SD_BUSY while the FPGA is busy). */
UINT8 hw_sd_response(void);

#endif /* EZGB_HW_H */
