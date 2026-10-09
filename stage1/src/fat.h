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
/* "/dir/File Name.gb": long or 8.3 names, any case */
uint8_t fat_open(const char *path);
void fat_read_first(uint8_t *dst);
uint8_t fat_read(uint32_t sector, uint8_t *dst);
uint8_t fat_write(uint32_t sector, const uint8_t *src);
const char *fat_name(void);
/* The FPGA load command for the file found last (128 u32, docs/fpga-stage1.md) */
uint8_t fat_load_command(uint32_t *cmd);

#endif
