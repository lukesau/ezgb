#ifndef GAME_H
#define GAME_H

#include <stdint.h>

/* Launch path (just opened with fat_open) as a game, straight from stage1.
 * buf: 512 bytes of scratch. Returns only when it can't, and the caller
 * boots the kernel, which then handles it. */
void game_launch(const char *path, uint8_t *buf);

#endif
