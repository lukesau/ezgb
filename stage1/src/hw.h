/* Game Boy and EZ Flash Jr hardware registers. */
#ifndef HW_H
#define HW_H

#include <stdint.h>

#define REG(a) (*(volatile uint8_t *)(a))

#define rLCDC REG(0xFF40)
#define rSTAT REG(0xFF41)
#define rSCY  REG(0xFF42)
#define rSCX  REG(0xFF43)
#define rLY   REG(0xFF44)
#define rBGP  REG(0xFF47)
#define rWY   REG(0xFF4A)
#define rWX   REG(0xFF4B)
#define rVBK  REG(0xFF4F)
#define rBCPS REG(0xFF68)
#define rBCPD REG(0xFF69)
#define rNR52 REG(0xFF26)
#define rIF   REG(0xFF0F)
#define rIE   REG(0xFFFF)
#define rP1   REG(0xFF00)

/* crt0 saves the boot ROM's A here ($11 on a color console) */
#define BOOT_A REG(0xFF80)

/* FPGA registers ($7Fxx, write-only, each write inside unlock/lock) */
#define FPGA_SD_MAP    0x7F30  /* $7F30: 0 off, 1 sector data at $A000, 3 read status */
#define FPGA_LOAD_MAP  0x7F36  /* $7F36: 0 off, 1 load command window, 3 load + status */
#define FPGA_SD_LBA    0x7FB0  /* $7FB0-$7FB3 sector, $7FB4 count (bit 7 = write) */
#define FPGA_SRAM_MAP  0x7FC0  /* $7FC0: what $A000 shows; stage1 uses 0 and 2 */

#define WINDOW ((volatile uint8_t *)0xA000)

/* battery-backed pSRAM: page latch at $4000 while $7FC0 = 3 */
#define PSRAM ((volatile uint8_t *)0xA000)
#define PSRAM_META 0x11                 /* the kernel's save stamp, LASTROM */
/* Page $11 $A410-$A411 = "S1": stage1 tells the kernel the user canceled
 * fast launch (START held), so the kernel doesn't fast launch either. The
 * kernel clears it (kernel/src/ezcfg.c cfg_load). Free space per
 * docs/psram-page-map.md: the kernel uses $A000-$A316 of page $11. */
#define PSRAM_SKIP_FL 0x410

/* buttons, active high */
#define BTN_A      0x01
#define BTN_B      0x02
#define BTN_SELECT 0x04
#define BTN_START  0x08

#endif
