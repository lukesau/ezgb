#ifndef GAME_H
#define GAME_H

#include <stdint.h>

/* Launch the file fat_open() found last as a game, straight from stage1.
 * buf: 512 bytes of scratch. Returns only when it can't (the caller boots
 * the kernel, which then handles it). */
void game_launch(uint8_t *buf);

#endif
