/* SPDX-License-Identifier: AGPL-3.0-only OR Apache-2.0
 * Copyright (C) Luke Esau. Dual licensed: the repository's AGPLv3 or the
 * Apache License 2.0, at your choice (LICENSE, LICENSE-APACHE-2.0, and the
 * License section of the README). */
#ifndef CFG_H
#define CFG_H

#include <stdint.h>

#define CFG_PATH_MAX 120        /* the kernel's PATH_MAX for FLAUNCH= */

/* FLAUNCH= from EZGB.CFG text (n bytes): 1 and the path ('/'-prefixed) in
 * path[CFG_PATH_MAX + 1] when fast launch is on with a target, else 0
 * (no key, disabled with '#', or empty = the kernel's lone-ROM rule). */
uint8_t cfg_flaunch(const uint8_t *text, uint16_t n, char *path);

/* Set by cfg_flaunch: 1 for BOOTROM=1, every launch resets */
extern uint8_t cfg_boot_reset;

#endif
