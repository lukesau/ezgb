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
    FAT_GPT,            /* GPT partition table: only MBR (or none) is read */
};

extern uint32_t file_size;

uint8_t fat_mount(void);
/* "/dir/File Name.gb": long or 8.3 names, any case */
uint8_t fat_open(const char *path);
void fat_read_first(uint8_t *dst);
uint8_t fat_read(uint32_t sector, uint8_t *dst);
uint8_t fat_write(uint32_t sector, const uint8_t *src);
const char *fat_name(void);
/* New file "/dir/Long Name.ext" of size bytes in an existing directory,
 * opened for fat_write; when = FAT date << 16 | time */
uint8_t fat_create(const char *path, uint32_t size, uint32_t when);
/* The FPGA load command for the file found last (128 u32, docs/fpga-stage1.md) */
uint8_t fat_load_command(uint32_t *cmd);
/* The root's *.dat files, the kernels: up to max of them into list,
 * KERNEL_ENTRY bytes each (bytes 20-31 of the directory entry: cluster and
 * size, then at +12 the name in capitals cut to KERNEL_NAME characters,
 * 0-terminated), in directory order. Returns how many; kernel_default is
 * the index of EZGB.DAT, 0 when it isn't among them. fat_select(list, i)
 * then opens the i-th. */
#define KERNEL_NAME 19
#define KERNEL_ENTRY 32
extern uint8_t kernel_default;
uint8_t fat_scan_dat(uint8_t *list, uint8_t max);
void fat_select(const uint8_t *list, uint8_t i);

#endif
