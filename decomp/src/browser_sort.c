/* Sorted file browser: directories first, then files, each group in
 * case-insensitive name order.
 *
 * The stock kernel lists entries in raw FAT directory order (readdir order),
 * so a reorganized card shows folders scrambled. EZ Flash's own Omega DE
 * kernel solves this by enumerating the whole directory up front and sorting
 * (Sort_folder/Sort_file in omega-de-kernel ezkernelnew.c — bubble sort +
 * strcmp over two arrays, folders drawn before files). The Jr kernel never
 * got that. This is the same ordering, restructured for the Jr's hardware:
 * entries are not in a flat RAM array but in 255-byte PSRAM records behind
 * the banked $A000 window, and an O(n^2) record bubble sort would take
 * minutes on the SM83. So: sort compact keys, then move each record once.
 *
 * Hooked in place of the single `call DirList` in FileBrowserEntry
 * (00:102f) via an 8-byte FarCallTrampoline stub at 00:03d4 — see
 * browser_sort_shims.md. Runs from a bank 8 code cave.
 *
 * Phases:
 *  1. Enumerate the whole directory: loop DirList (streams 16 records per
 *     call) until the end-of-directory latch $c5a4 sets. The scroll and
 *     RIGHT-page paths already honour that latch, so they never re-enter
 *     DirList afterwards and all downstream count checks use the true total.
 *  2. Build one 16-byte key per entry in a scratch PSRAM bank:
 *       [0]    class: 0 directory, 1 file  (record attr $10 vs $20)
 *       [1-13] first 13 name chars, uppercased, NUL-padded
 *       [14-15] original record index, little-endian
 *  3. Heapsort the keys. Compare = memcmp of bytes 0-13, so dirs sort ahead
 *     of files for free; equal prefixes fall back to a full caseless name
 *     compare of the records themselves (via the $c4a4 bounce buffer).
 *  4. Apply the permutation with a cycle walk: each record is copied exactly
 *     once (name up to its NUL plus the attr byte, chunked through a stack
 *     buffer because source and destination live in different banks). Key
 *     byte 0 is dead after sorting and becomes the visited mark.
 *
 * Memory:
 *  - Records: PSRAM page $03, bank $12 + (idx >> 5) at $4000, record at
 *    $A000 + 255 * (idx & $1f), NUL-terminated name at +0 (ApplyBasename),
 *    attr at +$fe. Nothing else lives in a record (the browser's number
 *    field is base+sel+1, not a stored size).
 *  - Scratch keys: same page, bank $ff — records would only reach it past
 *    entry 7584, beyond EZ Flash's stated 7000-file cap, and sorting is
 *    skipped long before that anyway (MAX_SORT). The SameBoy stub masks
 *    banks to 6 bits ($ff -> $3f), still clear of records below 1440
 *    entries, so emulator tests hold too.
 *  - Bounce: $c4a4, the 255-byte FatFs LFN buffer, idle once enumeration is
 *    done (next touched when the browser re-enters and rewires it).
 *
 * Caps: directories over MAX_SORT entries are left unsorted (a partial sort
 * would mislead). Enumeration stops at MAX_ENUM and forces the latch so no
 * later DirList call can push record banks toward the save pages — the
 * stock kernel would happily wrap $4000 past $ff on a pathological
 * directory; we refuse earlier.
 *
 * Cost: entering a directory now pays full enumeration (SD-bound, the cost
 * that used to hide in the first scroll past the last page) plus the sort —
 * key build and heapsort are linear-ish and cheap, the permutation moves
 * each name once. Omega pays the same enumeration price on the GBA.
 */

typedef unsigned char u8;
typedef unsigned int u16;

/* Streams the next batch of up to 16 entries into the PSRAM records and
 * advances the count; sets the $c5a4 latch when readdir comes up empty. */
extern void DirList(void);

#define ENTRY_COUNT (*(volatile u16 *)0xc2a2)
#define END_OF_DIR (*(volatile u8 *)0xc5a4)
#define RAM_BANK (*(volatile u8 *)0x4000)
#define WIN ((volatile u8 *)0xa000)
#define BOUNCE ((u8 *)0xc4a4) /* FatFs LFN buffer; idle after enumeration */

#define REC_BANK_BASE 0x12
#define SCRATCH_BANK 0xff
#define ATTR_OFS 254
#define NAME_END 253 /* name bytes 0..252, guard NUL at 253 */
#define PREFIX_LEN 13
#define ATTR_DIR 0x10
#define MAX_SORT 512  /* 512 * 16-byte keys = exactly one 8KB scratch bank */
#define MAX_ENUM 4096

static volatile u8 *rec_map(u16 idx);
static volatile u8 *key_map(u16 p);
static u8 upcase(u8 c);
static signed char cmp_full(u16 a, u16 b);
static signed char key_cmp(u16 p, u16 q);
static void key_swap(u16 p, u16 q);
static void sift_down(u16 root, u16 n);
static void build_keys(u16 n);
static u8 rec_to_bounce(u16 idx);
static void bounce_to_rec(u16 idx, u8 attr);
static void rec_copy(u16 dst, u16 src);
static void apply_perm(u16 n);
static void fpga_sram_page(void);

void browser_sort_all(void) {
    u16 n;
    u16 i;
    u16 end;

    while (!END_OF_DIR) {
        DirList();
        if (ENTRY_COUNT >= MAX_ENUM) {
            END_OF_DIR = 1;
            break;
        }
    }

    n = ENTRY_COUNT;
    if (n >= 2 && n <= MAX_SORT) {
        fpga_sram_page();
        build_keys(n);
        for (i = n >> 1; i > 0; i--) {
            sift_down(i - 1, n);
        }
        for (end = n; end > 1;) {
            end--;
            key_swap(0, end);
            sift_down(0, end);
        }
        apply_perm(n);
    }

    /* Leave the record window in a known state: page $03, records 0..31
     * mapped. The redraw farcalls re-select it anyway; this also lets a
     * debugger breakpoint right after the hook read sorted records at
     * $A000 + 255*k directly. */
    fpga_sram_page();
    RAM_BANK = REC_BANK_BASE;
}

/* SetFpgaPageAlt_B4 (04:41e7) inlined: unlock, $7FC0 = page 3 (cart SRAM /
 * PSRAM window), commit. Direct $7Fxx stores from banked code are exactly
 * what the stock bank 2/4 helpers do. */
static void fpga_sram_page(void) {
    *(volatile u8 *)0x7f00 = 0xe1;
    *(volatile u8 *)0x7f10 = 0xe2;
    *(volatile u8 *)0x7f20 = 0xe3;
    *(volatile u8 *)0x7fc0 = 0x03;
    *(volatile u8 *)0x7ff0 = 0xe4;
}

static volatile u8 *rec_map(u16 idx) {
    u16 slot = idx & 31;
    RAM_BANK = (u8)(REC_BANK_BASE + (u8)(idx >> 5));
    return WIN + ((slot << 8) - slot); /* slot * 255, no __mulint */
}

static volatile u8 *key_map(u16 p) {
    RAM_BANK = SCRATCH_BANK;
    return WIN + (p << 4);
}

static u8 upcase(u8 c) {
    return (c >= 'a' && c <= 'z') ? (u8)(c - 32) : c;
}

/* Full caseless name compare of two records, for keys whose 13-char
 * prefixes tie. Copies b's name to the bounce buffer first because the
 * records live in different banks of the same window. */
static signed char cmp_full(u16 a, u16 b) {
    volatile u8 *r;
    u8 *t = BOUNCE;
    u16 i;
    u8 ca;
    u8 cb;

    r = rec_map(b);
    for (i = 0; i < NAME_END; i++) {
        ca = r[i];
        t[i] = ca;
        if (!ca) {
            break;
        }
    }
    t[NAME_END] = 0;

    r = rec_map(a);
    for (i = 0;; i++) {
        ca = upcase(r[i]);
        cb = upcase(t[i]);
        if (ca != cb) {
            return (ca < cb) ? -1 : 1;
        }
        if (!ca || i >= NAME_END) {
            return 0;
        }
    }
}

static signed char key_cmp(u16 p, u16 q) {
    volatile u8 *kp;
    volatile u8 *kq;
    u16 ia;
    u16 ib;
    u8 j;
    u8 a;
    u8 b;

    RAM_BANK = SCRATCH_BANK;
    kp = WIN + (p << 4);
    kq = WIN + (q << 4);
    for (j = 0; j < 1 + PREFIX_LEN; j++) {
        a = kp[j];
        b = kq[j];
        if (a != b) {
            return (a < b) ? -1 : 1;
        }
    }
    ia = (u16)kp[14] | ((u16)kp[15] << 8);
    ib = (u16)kq[14] | ((u16)kq[15] << 8);
    return cmp_full(ia, ib);
}

static void key_swap(u16 p, u16 q) {
    volatile u8 *kp;
    volatile u8 *kq;
    u8 j;
    u8 t;

    RAM_BANK = SCRATCH_BANK;
    kp = WIN + (p << 4);
    kq = WIN + (q << 4);
    for (j = 0; j < 16; j++) {
        t = kp[j];
        kp[j] = kq[j];
        kq[j] = t;
    }
}

static void sift_down(u16 root, u16 n) {
    u16 child;

    for (;;) {
        child = (root << 1) + 1;
        if (child >= n) {
            return;
        }
        if (child + 1 < n && key_cmp(child, child + 1) < 0) {
            child++;
        }
        if (key_cmp(root, child) >= 0) {
            return;
        }
        key_swap(root, child);
        root = child;
    }
}

static void build_keys(u16 n) {
    u16 i;
    u8 kb[16];
    u8 j;
    u8 c;
    volatile u8 *p;

    for (i = 0; i < n; i++) {
        p = rec_map(i);
        kb[0] = (p[ATTR_OFS] == ATTR_DIR) ? 0 : 1;
        for (j = 0; j < PREFIX_LEN; j++) {
            kb[1 + j] = 0;
        }
        for (j = 0; j < PREFIX_LEN; j++) {
            c = p[j];
            if (!c) {
                break;
            }
            kb[1 + j] = upcase(c);
        }
        kb[14] = (u8)i;
        kb[15] = (u8)(i >> 8);
        p = key_map(i);
        for (j = 0; j < 16; j++) {
            p[j] = kb[j];
        }
    }
}

static u8 rec_to_bounce(u16 idx) {
    volatile u8 *r = rec_map(idx);
    u8 *t = BOUNCE;
    u16 i;
    u8 c;

    for (i = 0; i < NAME_END; i++) {
        c = r[i];
        t[i] = c;
        if (!c) {
            break;
        }
    }
    t[NAME_END] = 0;
    return r[ATTR_OFS];
}

static void bounce_to_rec(u16 idx, u8 attr) {
    volatile u8 *r = rec_map(idx);
    u8 *t = BOUNCE;
    u16 i;
    u8 c;

    for (i = 0; i < NAME_END; i++) {
        c = t[i];
        r[i] = c;
        if (!c) {
            break;
        }
    }
    r[NAME_END] = 0;
    r[ATTR_OFS] = attr;
}

/* Copy record src -> dst (name through its NUL, then attr), 32 bytes at a
 * time through a stack buffer since the two records are in different banks
 * of the same $A000 window. */
static void rec_copy(u16 dst, u16 src) {
    u8 buf[32];
    u16 off = 0;
    u8 len;
    u8 i;
    u8 c;
    u8 attr;
    u8 done = 0;
    volatile u8 *p;

    p = rec_map(src);
    attr = p[ATTR_OFS];
    while (!done) {
        len = 32;
        if (off + len > NAME_END) {
            len = (u8)(NAME_END - off);
            done = 1;
        }
        p = rec_map(src) + off;
        i = 0;
        while (i < len) {
            c = p[i];
            buf[i] = c;
            i++;
            if (!c) {
                done = 1;
                break;
            }
        }
        p = rec_map(dst) + off;
        len = i;
        for (i = 0; i < len; i++) {
            p[i] = buf[i];
        }
        off += len;
    }
    p = rec_map(dst);
    p[NAME_END] = 0;
    p[ATTR_OFS] = attr;
}

/* key[p].idx after sorting names the record that belongs at position p.
 * Walk each cycle once, moving every record exactly one time; key byte 0 is
 * the visited mark (its class value is dead once sorting is done). */
static void apply_perm(u16 n) {
    u16 start;
    u16 pos;
    u16 src;
    volatile u8 *k;
    u8 attr;

    for (start = 0; start < n; start++) {
        key_map(start)[0] = 0;
    }
    for (start = 0; start < n; start++) {
        k = key_map(start);
        if (k[0]) {
            continue;
        }
        attr = rec_to_bounce(start);
        pos = start;
        for (;;) {
            k = key_map(pos);
            k[0] = 1;
            src = (u16)k[14] | ((u16)k[15] << 8);
            if (src == start) {
                bounce_to_rec(pos, attr);
                break;
            }
            rec_copy(pos, src);
            pos = src;
        }
    }
}
