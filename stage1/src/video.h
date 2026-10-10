#ifndef VIDEO_H
#define VIDEO_H

#include <stdint.h>

void video_init(void);
void print_center(uint8_t row, const char *s);
void clear_row(uint8_t row);
void wait_frames(uint8_t n);
void wordmark_paint(uint8_t frames_per_step);

#endif
