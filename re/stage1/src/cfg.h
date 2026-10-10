#ifndef CFG_H
#define CFG_H

#include <stdint.h>

#define CFG_PATH_MAX 120        /* the kernel's PATH_MAX for FLAUNCH= */

/* FLAUNCH= from EZGB.CFG text (n bytes): 1 and the path ('/'-prefixed) in
 * path[CFG_PATH_MAX + 1] when fast launch is on with a target, else 0
 * (no key, disabled with '#', or empty = the kernel's lone-ROM rule). */
uint8_t cfg_flaunch(const uint8_t *text, uint16_t n, char *path);

#endif
