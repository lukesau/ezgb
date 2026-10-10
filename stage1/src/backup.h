#ifndef BACKUP_H
#define BACKUP_H

#include <stdint.h>

/* SELECT at power-on: offer to copy the pending save (the kernel's page
 * $11 stamp) to its /SAVER file. buf: 512 bytes of scratch. Returns 1 when
 * the kernel should handle the backup instead (skip fast launch). */
uint8_t backup_offer(uint8_t *buf);

#endif
