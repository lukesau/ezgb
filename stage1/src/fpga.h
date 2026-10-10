#ifndef FPGA_H
#define FPGA_H

#include <stdint.h>

void fpga_set(uint16_t reg, uint8_t value);
void sd_read(uint32_t lba, uint8_t *dst);
void sd_write(uint32_t lba, const uint8_t *src);
void psram_map(uint8_t page);
void psram_unmap(void);
uint8_t buttons(void);

#endif
