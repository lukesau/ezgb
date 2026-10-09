#ifndef FAT_H
#define FAT_H

#include <stdint.h>

enum {
    FAT_OK,
    FAT_NO_FS,          /* no FAT boot sector, or not 512-byte sectors */
    FAT_FAT12,          /* too few clusters: FAT12 isn't supported */
    FAT_NOT_FOUND,
    FAT_BAD_CHAIN,      /* cluster chain leaves the volume */
    FAT_FRAGMENTED,     /* more extents than the load command holds */
};

extern uint32_t file_size;

uint8_t fat_mount(void);
/* name: 11 bytes, 8.3 directory form ("EZGB    DAT"), root directory only */
uint8_t fat_find(const char *name);
/* The FPGA load command for the file found last (128 u32, docs/fpga-stage1.md) */
uint8_t fat_load_command(uint32_t *cmd);

#endif
