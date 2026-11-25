/* SPDX-License-Identifier: AGPL-3.0-only OR Apache-2.0
 * Copyright (C) Luke Esau. Dual licensed: the repository's AGPLv3 or the
 * Apache License 2.0, at your choice (LICENSE, LICENSE-APACHE-2.0, and the
 * License section of the README). */
#ifndef FPGA_H
#define FPGA_H

#include <stdint.h>

void fpga_set(uint16_t reg, uint8_t value);
void sd_read(uint32_t lba, uint8_t *dst);
void sd_write(uint32_t lba, const uint8_t *src);
void psram_map(uint8_t page);
void psram_unmap(void);
uint8_t buttons(void);
void wait_release(void);
uint8_t fw_version(void);
/* main.c: called with 1 when an SD read has been busy for ~2 s (no card,
 * or one not answering), with 0 once that read completes */
void sd_wait_notice(uint8_t waiting);

#endif
