/* FPGA register writes and SD sector reads, the way stock stage1 and the
 * kernel do them (docs/fpga-stage1.md). */
#include <string.h>
#include "hw.h"
#include "fpga.h"

static void unlock(void)
{
    REG(0x7F00) = 0xE1;
    REG(0x7F10) = 0xE2;
    REG(0x7F20) = 0xE3;
}

static void lock(void)
{
    REG(0x7FF0) = 0xE4;
}

void fpga_set(uint16_t reg, uint8_t value)
{
    unlock();
    *(volatile uint8_t *)reg = value;
    lock();
}

/* One 512-byte sector into dst. The PicoBlaze does the SD protocol; we set
 * the sector, wait while the status window reads $E1 (busy), then copy the
 * data window. No timeout, like stock. */
void sd_read(uint32_t lba, uint8_t *dst)
{
    const uint8_t *b = (const uint8_t *)&lba;

    fpga_set(FPGA_SD_MAP, 1);
    unlock();
    REG(0x7FB0) = b[0];
    REG(0x7FB1) = b[1];
    REG(0x7FB2) = b[2];
    REG(0x7FB3) = b[3];
    REG(0x7FB4) = 1;
    lock();
    fpga_set(FPGA_SD_MAP, 3);
    while (WINDOW[0] == 0xE1)
        ;
    fpga_set(FPGA_SD_MAP, 1);
    memcpy(dst, (const void *)WINDOW, 512);
    fpga_set(FPGA_SD_MAP, 0);
}

/* One 512-byte sector from src, the kernel's DiskWrite_B2 sequence: SD map
 * 1 then 3, the data into the window, sector and count | $80 (write), wait
 * while busy ($E1), a short settle (the kernel's Delay(10)), unmap. */
void sd_write(uint32_t lba, const uint8_t *src)
{
    const uint8_t *b = (const uint8_t *)&lba;
    volatile uint16_t i;

    fpga_set(FPGA_SD_MAP, 1);
    fpga_set(FPGA_SD_MAP, 3);
    memcpy((void *)WINDOW, src, 512);
    unlock();
    REG(0x7FB0) = b[0];
    REG(0x7FB1) = b[1];
    REG(0x7FB2) = b[2];
    REG(0x7FB3) = b[3];
    REG(0x7FB4) = 0x81;
    lock();
    while (WINDOW[0] == 0xE1)
        ;
    for (i = 0; i < 350; i++)           /* 34 cycles each: ~11 ms */
        ;
    fpga_set(FPGA_SD_MAP, 0);
}

void psram_map(uint8_t page)
{
    REG(0x4000) = page;
    fpga_set(FPGA_SRAM_MAP, 3);
}

void psram_unmap(void)
{
    REG(0x4000) = 0;
    fpga_set(FPGA_SRAM_MAP, 0);
}

uint8_t buttons(void)
{
    uint8_t i, keys = 0xFF;

    REG(0xFF00) = 0x10;                 /* select the button row */
    for (i = 0; i < 6; i++)
        keys = REG(0xFF00);
    REG(0xFF00) = 0x30;
    return ~keys & 0x0F;
}
