/* SPDX-License-Identifier: AGPL-3.0-only OR Apache-2.0
 * Copyright (C) Luke Esau. Dual licensed: the repository's AGPLv3 or the
 * Apache License 2.0, at your choice (LICENSE, LICENSE-APACHE-2.0, and the
 * License section of the README). */
#ifndef BACKUP_H
#define BACKUP_H

#include <stdint.h>

/* Offer to copy the pending save (the kernel's page $11 stamp) to its
 * /SAVER file, without asking when AUTO SAVE is on. manual: SELECT was held,
 * so say so when there is nothing to do; otherwise (a fast-launch boot) stay
 * quiet. buf: 512 bytes of scratch. keep: the fast-launch game's save path,
 * whose stamp B leaves armed (it runs from pSRAM); B on any other save drops
 * the stamp, as the kernel's skip does. 0 keeps every stamp for the kernel.
 * Returns 1 when the kernel should handle the backup instead (skip fast
 * launch), which includes a dead battery canary: a faded save is never
 * written. */
uint8_t backup_offer(uint8_t *buf, uint8_t manual, const char *keep);

#endif
