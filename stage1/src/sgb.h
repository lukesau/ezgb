/* SPDX-License-Identifier: AGPL-3.0-only OR Apache-2.0
 * Copyright (C) Luke Esau. Dual licensed: the repository's AGPLv3 or the
 * Apache License 2.0, at your choice (LICENSE, LICENSE-APACHE-2.0, and the
 * License section of the README). */
#ifndef SGB_H
#define SGB_H

#include <stdint.h>

uint8_t sgb_detect(void);
void sgb_unlock(void);

#endif
