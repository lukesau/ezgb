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
static uint32_t pos_cluster, pos_index;   /* file_lba's cursor */
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

/* ---- directories ---- */

static uint32_t d_cluster;      /* 0: the FAT16 root, which is not a cluster chain */
static uint32_t d_lba;
static uint16_t d_left;         /* sectors left in this cluster (or root) */
static uint16_t d_off;

static void dir_start(uint32_t c)
{
    if (!c && !is_fat32) {
        d_cluster = 0;
        d_lba = root;
        d_left = root_sectors;
    } else {
        if (!c)
            c = root;           /* ".." of a top-level directory */
        d_cluster = c;
        d_lba = cluster_sector(c);
        d_left = 1 << csize_shift;
    }
    d_off = 0;
}

/* Next 32-byte entry (valid until the next sector read), 0 past the end */
static const uint8_t *dir_next(void)
{
    if (d_off == 512) {
        d_off = 0;
        d_lba++;
        if (!--d_left) {
            if (!d_cluster)
                return 0;
            d_cluster = next_cluster(d_cluster);
            if (d_cluster < 2 || d_cluster > max_cluster)
                return 0;
            d_lba = cluster_sector(d_cluster);
            d_left = 1 << csize_shift;
        }
    }
    read_sector(d_lba);
    d_off += 32;
    return buf + d_off - 32;
}

/* ---- names: the long name when one precedes the entry, else NAME.EXT ---- */

#define LFN_MAX 255
static uint8_t name[LFN_MAX + 1];
static uint8_t lfn_valid, lfn_sum;
static const uint8_t lfn_offsets[13] = {1, 3, 5, 7, 9, 14, 16, 18, 20, 22, 24, 28, 30};

static uint8_t upper(uint8_t c)
{
    return c >= 'a' && c <= 'z' ? c - 32 : c;
}

static uint8_t short_sum(const uint8_t *e)
{
    uint8_t sum = 0, i;

    for (i = 0; i < 11; i++)
        sum = ((sum & 1) ? 0x80 : 0) + (sum >> 1) + e[i];
    return sum;
}

/* One long-name piece. They come last piece first, 13 UTF-16 units each;
 * anything outside ASCII becomes '?', which then just fails to match. */
static void lfn_piece(const uint8_t *e)
{
    uint8_t seq = e[0] & 0x1F, i;
    uint16_t at, ch;

    if (e[0] & 0x40) {
        lfn_valid = seq && seq * 13 <= LFN_MAX;
        lfn_sum = e[13];
        if (lfn_valid)
            name[seq * 13] = 0;
    }
    if (!lfn_valid || e[13] != lfn_sum || !seq)
        return;
    at = (seq - 1) * 13;
    for (i = 0; i < 13; i++) {
        ch = ld16(e + lfn_offsets[i]);
        if (!ch) {
            name[at + i] = 0;
            return;
        }
        name[at + i] = ch < 0x80 ? (uint8_t)ch : '?';
    }
}

/* Short names honor the NT case bits (byte 12: $08 lowercase name, $10
 * lowercase extension), so "ezgb.dat" reads back as FatFs gives it. */
static void entry_name(const uint8_t *e)
{
    uint8_t i, n = 0, lower = e[12] & 0x08 ? 32 : 0;

    if (lfn_valid && lfn_sum == short_sum(e))
        return;                 /* name[] already holds the long name */
    for (i = 0; i < 8 && e[i] != ' '; i++)
        name[n++] = e[i] >= 'A' && e[i] <= 'Z' ? e[i] + lower : e[i];
    if (e[8] != ' ') {
        name[n++] = '.';
        lower = e[12] & 0x10 ? 32 : 0;
        for (i = 8; i < 11 && e[i] != ' '; i++)
            name[n++] = e[i] >= 'A' && e[i] <= 'Z' ? e[i] + lower : e[i];
    }
    name[n] = 0;
}

static uint8_t name_is(const char *s, uint8_t len)
{
    uint8_t i;

    for (i = 0; i < len; i++)
        if (!name[i] || upper(name[i]) != upper(s[i]))
            return 0;
    return !name[len];
}

/* Open "/dir/sub/File Name.gb": long or 8.3 names, any case. */
uint8_t fat_open(const char *path)
{
    const uint8_t *e;
    uint8_t len, last, attr;

    dir_start(0);
    for (;;) {
        while (*path == '/')
            path++;
        for (len = 0; path[len] && path[len] != '/'; len++)
            ;
        if (!len)
            return FAT_NOT_FOUND;
        last = !path[len];
        lfn_valid = 0;
        for (;;) {
            e = dir_next();
            if (!e || !e[0])
                return FAT_NOT_FOUND;
            attr = e[11];
            if (e[0] == 0xE5) {
                lfn_valid = 0;
                continue;
            }
            if ((attr & 0x3F) == 0x0F) {
                lfn_piece(e);
                continue;
            }
            if (attr & 0x08) {  /* volume label */
                lfn_valid = 0;
                continue;
            }
            entry_name(e);
            lfn_valid = 0;
            if (name_is(path, len))
                break;
        }
        file_cluster = ld16(e + 26);
        if (is_fat32)
            file_cluster |= (uint32_t)ld16(e + 20) << 16;
        pos_cluster = file_cluster;
        pos_index = 0;
        if (last) {
            if (attr & 0x10)
                return FAT_NOT_FOUND;
            file_size = ld32(e + 28);
            return file_size && file_cluster >= 2 ? FAT_OK : FAT_NOT_FOUND;
        }
        if (!(attr & 0x10))
            return FAT_NOT_FOUND;
        dir_start(file_cluster);
        path += len;
    }
}

/* LBA of sector n of the open file, 0 past its chain. A cursor keeps the
 * last cluster reached, so reading or writing a file in order walks its
 * chain once instead of from the start for every sector. */
static uint32_t file_lba(uint32_t n)
{
    uint32_t idx = n >> csize_shift;

    if (idx < pos_index) {
        pos_cluster = file_cluster;
        pos_index = 0;
    }
    while (pos_index < idx) {
        pos_cluster = next_cluster(pos_cluster);
        if (pos_cluster < 2 || pos_cluster > max_cluster) {
            pos_cluster = file_cluster;
            pos_index = 0;
            return 0;
        }
        pos_index++;
    }
    return cluster_sector(pos_cluster) + (n & ((1 << csize_shift) - 1));
}

/* Sector n of the open file into dst (not the cache); 0 past its chain */
uint8_t fat_read(uint32_t n, uint8_t *dst)
{
    uint32_t lba = file_lba(n);

    if (!lba)
        return 0;
    sd_read(lba, dst);
    return 1;
}

/* Sector n of the open file from src, in place: the file keeps its size and
 * clusters, so no FAT or directory entry changes. 0 past its chain. */
uint8_t fat_write(uint32_t n, const uint8_t *src)
{
    uint32_t lba = file_lba(n);

    if (!lba)
        return 0;
    sd_write(lba, src);
    if (lba == buf_lba)
        buf_lba = 0xFFFFFFFF;           /* the cache is stale now */
    return 1;
}

void fat_read_first(uint8_t *dst)
{
    fat_read(0, dst);
}

/* The open file's base name as the directory has it (long name if any) */
const char *fat_name(void)
{
    return (const char *)name;
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
