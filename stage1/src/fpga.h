#ifndef FPGA_H
#define FPGA_H

#include <stdint.h>

void fpga_set(uint16_t reg, uint8_t value);
void sd_read(uint32_t lba, uint8_t *dst);

#endif
