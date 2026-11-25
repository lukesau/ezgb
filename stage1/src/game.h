/* SPDX-License-Identifier: AGPL-3.0-only OR Apache-2.0
 * Copyright (C) Luke Esau. Dual licensed: the repository's AGPLv3 or the
 * Apache License 2.0, at your choice (LICENSE, LICENSE-APACHE-2.0, and the
 * License section of the README). */
#ifndef GAME_H
#define GAME_H

#include <stdint.h>

/* Launch path (just opened with fat_open) as a game, straight from stage1.
 * buf: 512 bytes of scratch. Returns only when it can't, and the caller
 * boots the kernel, which then handles it. */
void game_launch(const char *path, uint8_t *buf);

/* The /SAVER path of the file just opened with fat_open, as game_launch
 * makes it; 0 when it isn't a .gb/.gbc. Valid until the next game_launch. */
const char *game_save_path(void);

#endif
