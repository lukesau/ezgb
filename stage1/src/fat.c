/* Minimal read-only FAT16/FAT32: mount, find a file in the root directory,
 * turn its cluster chain into the FPGA load command. One cached sector, so
 * walking a chain costs one SD read per FAT sector, not per cluster. */
#include <string.h>
#include "fpga.h"
#include "fat.h"

#define END_OF_CHAIN 0x0FFFFFF8UL

static uint8_t buf[512];
static uint32_t buf_lba;
static uint8_t is_fat32;
static uint8_t csize_shift;     /* sectors per cluster = 1 << csize_shift */
static uint32_t fat_base;       /* first FAT sector */
static uint32_t data_base;      /* sector of cluster 2 */
static uint32_t root;           /* FAT16: first root sector, FAT32: root cluster */
static uint16_t root_sectors;   /* FAT16 only */
static uint32_t max_cluster;
static uint32_t file_cluster;
uint32_t file_size;

static uint16_t ld16(const uint8_t *p)
{
    return p[0] | (uint16_t)p[1] << 8;
}

static uint32_t ld32(const uint8_t *p)
{
    return ld16(p) | (uint32_t)ld16(p + 2) << 16;
}

static void read_sector(uint32_t lba)
{
    if (lba != buf_lba) {
        sd_read(lba, buf);
        buf_lba = lba;
    }
}

static uint32_t cluster_sector(uint32_t c)
{
    return data_base + ((c - 2) << csize_shift);
}

/* Next cluster in the chain; any end-of-chain becomes END_OF_CHAIN or more. */
static uint32_t next_cluster(uint32_t c)
{
    uint16_t i = (uint16_t)c;
    uint32_t n;

    if (is_fat32) {
        read_sector(fat_base + (c >> 7));
        return ld32(buf + (i & 0x7F) * 4) & 0x0FFFFFFF;
    }
    read_sector(fat_base + (c >> 8));
    n = ld16(buf + (i & 0xFF) * 2);
    return n >= 0xFFF8 ? END_OF_CHAIN : n;
}

static uint8_t is_boot_sector(void)
{
    return buf[510] == 0x55 && buf[511] == 0xAA &&
           (memcmp(buf + 0x36, "FAT", 3) == 0 || memcmp(buf + 0x52, "FAT", 3) == 0);
}

uint8_t fat_mount(void)
{
    uint32_t vbr = 0, fat_size, sectors, clusters;
    uint8_t spc;

    buf_lba = 0xFFFFFFFF;
    read_sector(0);
    if (!is_boot_sector()) {
        /* MBR: first partition */
        if (buf[510] != 0x55 || buf[511] != 0xAA)
            return FAT_NO_FS;
        vbr = ld32(buf + 0x1C6);
        read_sector(vbr);
        if (!is_boot_sector())
            return FAT_NO_FS;
    }
    if (ld16(buf + 0x0B) != 512)
        return FAT_NO_FS;
    spc = buf[0x0D];
    for (csize_shift = 0; spc > 1; spc >>= 1)
        csize_shift++;
    fat_size = ld16(buf + 0x16);
    if (!fat_size)
        fat_size = ld32(buf + 0x24);
    sectors = ld16(buf + 0x13);
    if (!sectors)
        sectors = ld32(buf + 0x20);
    root_sectors = ld16(buf + 0x11) >> 4;
    fat_base = vbr + ld16(buf + 0x0E);
    root = fat_base + fat_size;
    if (buf[0x10] == 2)
        root += fat_size;
    data_base = root + root_sectors;
    clusters = (sectors - (data_base - vbr)) >> csize_shift;
    if (clusters < 4085)
        return FAT_FAT12;
    max_cluster = clusters + 1;
    is_fat32 = clusters >= 65525;
    if (is_fat32)
        root = ld32(buf + 0x2C);
    return FAT_OK;
}

uint8_t fat_find(const char *name)
{
    uint32_t c = root, lba;
    uint16_t left;
    const uint8_t *e;

    if (is_fat32) {
        lba = cluster_sector(c);
        left = 1 << csize_shift;
    } else {
        lba = root;
        left = root_sectors;
    }
    for (;;) {
        read_sector(lba);
        for (e = buf; e < buf + 512; e += 32) {
            if (!e[0])
                return FAT_NOT_FOUND;
            /* skip deleted entries, long names, volume labels, directories */
            if (e[0] != 0xE5 && !(e[11] & 0x18) && !memcmp(e, name, 11)) {
                file_cluster = ld16(e + 26);
                if (is_fat32)
                    file_cluster |= (uint32_t)ld16(e + 20) << 16;
                file_size = ld32(e + 28);
                return file_size && file_cluster >= 2 ? FAT_OK : FAT_NOT_FOUND;
            }
        }
        lba++;
        if (--left)
            continue;
        if (!is_fat32)
            return FAT_NOT_FOUND;
        c = next_cluster(c);
        if (c < 2 || c > max_cluster)
            return FAT_NOT_FOUND;
        lba = cluster_sector(c);
        left = 1 << csize_shift;
    }
}

/* Same table stock stage1 builds: [0] = 0, then {start LBA, end} per
 * contiguous run where end is the running total of file sectors, the last
 * end is $FFFFFFFF and the word after it 0; [$7C] size, [$7D] 1, [$7E]
 * sectors per cluster. */
uint8_t fat_load_command(uint32_t *cmd)
{
    uint32_t c = file_cluster, n, clusters = 0;
    uint8_t i = 1;

    memset(cmd, 0, 512);
    cmd[i++] = cluster_sector(c);
    for (;;) {
        n = next_cluster(c);
        if (++clusters > max_cluster)
            return FAT_BAD_CHAIN;   /* the chain loops */
        if (n != c + 1) {
            if (n >= END_OF_CHAIN)
                break;
            if (n < 2 || n > max_cluster)
                return FAT_BAD_CHAIN;
            if (i > 0x78)
                return FAT_FRAGMENTED;
            cmd[i++] = clusters << csize_shift;
            cmd[i++] = cluster_sector(n);
        }
        c = n;
    }
    cmd[i] = 0xFFFFFFFF;
    cmd[0x7C] = file_size;
    cmd[0x7D] = 1;
    cmd[0x7E] = 1 << csize_shift;
    return FAT_OK;
}
