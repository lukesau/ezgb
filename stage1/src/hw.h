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

/* crt0 saves the boot ROM's A here ($11 on a colour console) */
#define BOOT_A REG(0xFF80)

/* FPGA registers ($7Fxx, write-only, each write inside unlock/lock) */
#define FPGA_SD_MAP    0x7F30  /* $7F30: 0 off, 1 sector data at $A000, 3 read status */
#define FPGA_LOAD_MAP  0x7F36  /* $7F36: 0 off, 1 load command window, 3 load + status */
#define FPGA_SD_LBA    0x7FB0  /* $7FB0-$7FB3 sector, $7FB4 count (bit 7 = write) */
#define FPGA_SRAM_MAP  0x7FC0  /* $7FC0: what $A000 shows; stage1 uses 0 and 2 */

#define WINDOW ((volatile uint8_t *)0xA000)

#endif
