/* Minimal FAT16/FAT32: mount, find a file by path, turn its cluster chain
 * into the FPGA load command, write a file in place, and create one (for a
 * save backup). One cached sector, so walking a chain costs one SD read per
 * FAT sector, not per cluster. */
#include <string.h>
#include "fpga.h"
#include "fat.h"

#define END_OF_CHAIN 0x0FFFFFF8UL

static uint8_t buf[512];
static uint32_t buf_lba;
static uint8_t is_fat32;
static uint8_t dirty;           /* the cached sector changed: 1 directory, 2 FAT */
static uint8_t num_fats;
static uint32_t fat_sectors;    /* per FAT */
static uint32_t fsinfo;         /* FAT32 FSInfo sector, 0 on FAT16 */
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

/* Write the cached sector back if it changed; a FAT sector to every FAT */
static void flush(void)
{
    if (dirty) {
        sd_write(buf_lba, buf);
        if (dirty == 2 && num_fats > 1)
            sd_write(buf_lba + fat_sectors, buf);
        dirty = 0;
    }
}

static void read_sector(uint32_t lba)
{
    if (lba != buf_lba) {
        flush();
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
    dirty = 0;
    read_sector(0);
    if (!is_boot_sector()) {
        /* MBR: first partition */
        if (buf[510] != 0x55 || buf[511] != 0xAA)
            return FAT_NO_FS;
        if (buf[0x1C2] == 0xEE)
            return FAT_GPT;     /* the protective entry a GPT disk puts here */
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
    num_fats = buf[0x10];
    fat_sectors = fat_size;
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
    fsinfo = 0;
    if (is_fat32) {
        root = ld32(buf + 0x2C);
        fsinfo = vbr + ld16(buf + 0x30);
    }
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

/* Find the first n characters of "/dir/sub/name": the entry's attributes,
 * or $FF when it isn't there. file_cluster and file_size are the entry's. */
static uint8_t lookup(const char *path, uint8_t n)
{
    const uint8_t *e;
    uint8_t len, attr;

    dir_start(0);
    for (;;) {
        while (n && *path == '/') {
            path++;
            n--;
        }
        for (len = 0; len < n && path[len] != '/'; len++)
            ;
        if (!len)
            return 0xFF;
        lfn_valid = 0;
        for (;;) {
            e = dir_next();
            if (!e || !e[0])
                return 0xFF;
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
        file_size = ld32(e + 28);
        if (len == n)
            return attr;
        if (!(attr & 0x10))
            return 0xFF;
        dir_start(file_cluster);
        path += len;
        n -= len;
    }
}

/* Open "/dir/sub/File Name.gb": long or 8.3 names, any case. */
uint8_t fat_open(const char *path)
{
    uint8_t attr = lookup(path, strlen(path));

    if (attr == 0xFF || attr & 0x10)
        return FAT_NOT_FOUND;
    return file_size && file_cluster >= 2 ? FAT_OK : FAT_NOT_FOUND;
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

/* ---- creating a file ---- */

static void st16(uint8_t *p, uint16_t v)
{
    p[0] = (uint8_t)v;
    p[1] = v >> 8;
}

static void st32(uint8_t *p, uint32_t v)
{
    st16(p, (uint16_t)v);
    st16(p + 2, (uint16_t)(v >> 16));
}

static void fat_set(uint32_t c, uint32_t v)
{
    uint16_t i = (uint16_t)c;

    if (is_fat32) {
        read_sector(fat_base + (c >> 7));
        i = (i & 0x7F) * 4;
        st32(buf + i, (ld32(buf + i) & 0xF0000000) | v);
    } else {
        read_sector(fat_base + (c >> 8));
        st16(buf + (i & 0xFF) * 2, (uint16_t)v);
    }
    dirty = 2;
}

/* The short name FatFs would give a long one: up to 6 legal characters of
 * the name, ~1 (the digit at sfn[*tail]), up to 3 of the extension */
static void make_sfn(uint8_t *sfn, const char *s, uint8_t len, uint8_t *tail)
{
    uint8_t i, n = 0, dot = len, c;

    memset(sfn, ' ', 11);
    for (i = 0; i < len; i++)
        if (s[i] == '.')
            dot = i;
    for (i = 0; i < len; i++) {
        c = upper(s[i]);
        if (c == ' ' || (c == '.' && i != dot))
            continue;
        if (i == dot) {
            n = 8;
            continue;
        }
        if (!((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || strchr("$%'-_@~`!(){}^#&", c)))
            c = '_';
        if (i < dot ? n < 6 : n < 11)
            sfn[n++] = c;
        if (i < dot)
            *tail = n;
    }
    if (dot == len)
        *tail = n;
    if (!*tail)
        sfn[(*tail)++] = '_';
    sfn[*tail] = '~';
    sfn[++*tail] = '1';
}

/* Create "/dir/Long Name.sav" in an existing directory: a long name and a
 * unique short one, size bytes of clusters chained in every FAT, and the
 * file opened so fat_write fills it (its clusters hold whatever they held).
 * when: FAT date << 16 | time. Fails, changing nothing, when the name is
 * taken, isn't plain ASCII, or the directory or the card is full; the
 * directory isn't grown. */
uint8_t fat_create(const char *path, uint32_t size, uint32_t when)
{
    const char *base = strrchr(path, '/') + 1;
    uint8_t blen = strlen(base), need, tail = 0, k, end = 0, sfn[11], sum, *e;
    uint16_t idx = 0, run = 0, start = 0xFFFF, used = 0, pos, ch;
    uint32_t dir = 0, n, c, prev, got;

    for (k = 0; k < blen; k++)
        if (base[k] < 0x20 || base[k] >= 0x7F || strchr("\"*:<>?|", base[k]))
            return FAT_NOT_FOUND;
    if (!blen || blen > 250)
        return FAT_NOT_FOUND;
    if (base - path > 1) {
        k = lookup(path, base - 1 - path);
        if (k == 0xFF || !(k & 0x10))
            return FAT_NOT_FOUND;
        dir = file_cluster;
    }
    make_sfn(sfn, base, blen, &tail);
    need = (blen + 12) / 13 + 1;

    /* one pass: the name isn't there, which ~digits are taken, and the
     * first run of need free entries */
    dir_start(dir);
    lfn_valid = 0;
    while ((e = (uint8_t *)dir_next())) {
        if (end || !e[0] || e[0] == 0xE5) {
            if (!e[0])
                end = 1;            /* nothing in use from here on */
            if (++run >= need && start == 0xFFFF)
                start = idx + 1 - need;
            if (end && start != 0xFFFF)
                break;
            lfn_valid = 0;
        } else {
            run = 0;
            if ((e[11] & 0x3F) == 0x0F) {
                lfn_piece(e);
            } else {
                if (!memcmp(e, sfn, tail) && e[tail] >= '1' && e[tail] <= '9' &&
                    !memcmp(e + tail + 1, sfn + tail + 1, 10 - tail))
                    used |= 1 << (e[tail] - '1');
                if (!(e[11] & 0x08)) {
                    entry_name(e);
                    if (name_is(base, blen))
                        return FAT_NOT_FOUND;
                }
                lfn_valid = 0;
            }
        }
        idx++;
    }
    for (k = 0; k < 9 && used >> k & 1; k++)
        ;
    if (k == 9 || start == 0xFFFF)
        return FAT_NOT_FOUND;
    sfn[tail] = '1' + k;

    /* clusters: count first, so a full card changes nothing */
    n = (size + (512UL << csize_shift) - 1) >> (9 + csize_shift);
    for (got = 0, c = 2; c <= max_cluster && got < n; c++)
        if (!next_cluster(c))
            got++;
    if (!n || got < n)
        return FAT_NOT_FOUND;
    file_cluster = prev = 0;
    for (got = 0, c = 2; got < n; c++) {
        if (next_cluster(c))
            continue;
        if (prev)
            fat_set(prev, c);
        else
            file_cluster = c;
        prev = c;
        got++;
    }
    fat_set(prev, is_fat32 ? 0x0FFFFFFF : 0xFFFF);
    flush();
    if (fsinfo) {
        read_sector(fsinfo);
        c = ld32(buf + 0x1E8);
        if (ld32(buf) == 0x41615252 && c != 0xFFFFFFFF) {
            st32(buf + 0x1E8, c < n ? 0xFFFFFFFF : c - n);    /* free count */
            dirty = 1;
            flush();
        }
    }

    /* the entries: long name pieces last first, then the short entry */
    sum = short_sum(sfn);
    dir_start(dir);
    for (idx = 0; idx < start; idx++)
        dir_next();
    for (k = need - 1;; k--) {
        e = (uint8_t *)dir_next();
        memset(e, 0, 32);
        dirty = 1;
        if (!k)
            break;
        e[0] = k | (k == need - 1 ? 0x40 : 0);
        e[11] = 0x0F;
        e[13] = sum;
        for (idx = 0; idx < 13; idx++) {
            pos = (k - 1) * 13 + idx;
            ch = pos < blen ? (uint8_t)base[pos] : pos == blen ? 0 : 0xFFFF;
            st16(e + lfn_offsets[idx], ch);
        }
    }                               /* read_sector writes each sector as dir_next leaves it */
    memcpy(e, sfn, 11);
    e[11] = 0x20;
    st32(e + 14, when);
    st16(e + 18, (uint16_t)(when >> 16));
    st32(e + 22, when);
    st16(e + 20, (uint16_t)(file_cluster >> 16));
    st16(e + 26, (uint16_t)file_cluster);
    st32(e + 28, size);
    flush();

    pos_cluster = file_cluster;
    pos_index = 0;
    file_size = size;
    return FAT_OK;
}
