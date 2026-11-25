/* SPDX-License-Identifier: AGPL-3.0-only OR Apache-2.0
 * Copyright (C) Luke Esau. Dual licensed: the repository's AGPLv3 or the
 * Apache License 2.0, at your choice (LICENSE, LICENSE-APACHE-2.0, and the
 * License section of the README). */
#ifndef VIDEO_H
#define VIDEO_H

#include <stdint.h>

void video_init(void);
void print_at(uint8_t row, uint8_t col, const char *s);
void print_center(uint8_t row, const char *s);
void clear_row(uint8_t row);
void wait_frames(uint8_t n);
void wordmark_paint(uint8_t frames_per_step);

#endif
