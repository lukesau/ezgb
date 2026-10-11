/* Config flash dump for the debug screen (docs/flash-dump.md).
 *
 * Debug builds only (scripts/make-debug-build.py), in bank 5 where there is
 * room; DebugTab far-calls FlashDump on START and reads FD_RES. It needs
 * the bank 2 read patch in slot B (stage0/flash-read.psm). A Device DNA
 * command goes first and doubles as the patch check: only its "EZDN"
 * signature lets the flash reads start. On stock firmware that command is a
 * page program of $FF bytes at $07FF00, which changes no bits, but stock
 * then refuses ROM loads until the next power-on, as after any update.
 *
 * Then all 1024 sectors, one read command each, to /FLASH.BIN with one
 * whole-sector f_write per sector, and the 8 DNA bytes to /DNA.BIN.
 *
 * FD_RES: [0] result (1 OK, 2 no patch, 3 timeout, 4 SD error), [1] the
 * FatFs result for 4, [2..3] sectors written, [4..11] the DNA.
 *
 * inject.py-style: the first-defined function is the entry point.
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern void DrawString(const u8 *s, u8 len, u8 col, u8 row);        /* 00:08b7 */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
extern void WaitVBlankFlag(void);                                   /* 00:0688 */
extern u8 FarCall_06_7309(u8 *fp, const u8 *path, u8 mode);        /* f_open  00:1926 */
extern u8 FarCall_07_7739(u8 *fp, const u8 *buf, u16 btw, u16 *bw); /* f_write 00:1963 */
extern u8 FarCall_03_768f(u8 *fp);                                  /* f_close 00:19a1 */
extern u8 FlashStub(void);                                          /* FD_STUB, copied from flash_stub */

#define WIN        ((volatile u8 *)0xA000)
#define FPGA(r)    (*(volatile u8 *)(r))
#define FIL_OBJ    ((u8 *)0xCA0F)    /* kernel FIL, idle whenever we run */
#define FD_STUB    ((u8 *)0xD780)    /* the WRAM read loop, 112 bytes (mod scratch, as FNO/LFN) */
#define FD_RES     ((volatile u8 *)0xD7F0)  /* results, 12 bytes */
#define FD_DNA     (FD_RES + 4)
#define FD_BUF     ((u8 *)0xD800)    /* one sector, as CFGBUF */
#define FL_SCR     ((u8 *)0xDB00)    /* file-name bounce: FatFs wants the path in WRAM */
#define FA_CREATE  0x0A              /* FA_WRITE | FA_CREATE_ALWAYS */
#define FLASH_SECTORS 1024           /* 512 KB */
#define FIRST      2                 /* DebugTab's first row */

#define DUMP_OK      1
#define DUMP_NOPATCH 2
#define DUMP_TIMEOUT 3
#define DUMP_SD      4

static void flash_dump(void);
static void dec(u8 *out, u16 v);

void FlashDump(void) {
    flash_dump();
}

/* The read loop, run from FD_STUB because $7FD2=1 hands the pSRAM's address
 * lines A11-A13 to the config flash: nothing may fetch from the kernel
 * until it is cleared again. di, $7FD2=1, then for each chunk: wait for the
 * sequence byte at $A00E (about 0.9 s timeout), copy $A008.. (6 bytes, or
 * `last` for the final chunk) to FD_BUF, echo the sequence to $7FB0, next.
 * Then $7FD2=0. Returns E = 0, or 1 on a timeout. Assembled for $D780. */
#define ST_CHUNKS 0x10
#define ST_SEQ    0x12
#define ST_LAST   0x2E
static const u8 flash_stub[112] = {
    0xF3,                               /* 00 di */
    0xCD, 0xDA, 0xD7,                   /* 01 call unlock */
    0x3E, 0x01, 0xEA, 0xD2, 0x7F,       /* 04 $7FD2 = 1 */
    0xCD, 0xEA, 0xD7,                   /* 09 call commit */
    0x21, 0x00, 0xD8,                   /* 0C ld hl, FD_BUF */
    0x06, 0x56,                         /* 0F ld b, chunks */
    0x0E, 0x01,                         /* 11 ld c, seq */
    0x11, 0x00, 0x00,                   /* 13 chunk: ld de, 0 */
    0xFA, 0x0E, 0xA0,                   /* 16 wait: ld a, [$A00E] */
    0xB9,                               /* 19 cp c */
    0x28, 0x07,                         /* 1A jr z, got */
    0x1B, 0x7A, 0xB3,                   /* 1C dec de; ld a, d; or e */
    0x20, 0xF5,                         /* 1F jr nz, wait */
    0x18, 0x2A,                         /* 21 jr timeout */
    0x11, 0x08, 0xA0,                   /* 23 got: ld de, $A008 */
    0x78, 0xFE, 0x01,                   /* 26 ld a, b; cp 1 */
    0x3E, 0x06,                         /* 29 ld a, 6 */
    0x20, 0x02,                         /* 2B jr nz, +2 */
    0x3E, 0x02,                         /* 2D ld a, last */
    0xC5, 0x47,                         /* 2F push bc; ld b, a */
    0x1A, 0x13, 0x22, 0x05,             /* 31 copy: ld a, [de]; inc de; ld [hl+], a; dec b */
    0x20, 0xFA,                         /* 35 jr nz, copy */
    0xC1,                               /* 37 pop bc */
    0xCD, 0xDA, 0xD7,                   /* 38 call unlock */
    0x79, 0xEA, 0xB0, 0x7F,             /* 3B $7FB0 = c */
    0xCD, 0xEA, 0xD7,                   /* 3F call commit */
    0x0C, 0x20, 0x01, 0x0C,             /* 42 inc c, skipping 0 */
    0x05,                               /* 46 dec b */
    0x20, 0xCA,                         /* 47 jr nz, chunk */
    0x1E, 0x00,                         /* 49 ld e, 0 */
    0x18, 0x02,                         /* 4B jr off */
    0x1E, 0x01,                         /* 4D timeout: ld e, 1 */
    0xCD, 0xDA, 0xD7,                   /* 4F off: call unlock */
    0xAF, 0xEA, 0xD2, 0x7F,             /* 52 $7FD2 = 0 */
    0xCD, 0xEA, 0xD7,                   /* 56 call commit */
    0xC9,                               /* 59 ret */
    0x3E, 0xE1, 0xEA, 0x00, 0x7F,       /* 5A unlock */
    0x3E, 0xE2, 0xEA, 0x10, 0x7F,
    0x3E, 0xE3, 0xEA, 0x20, 0x7F,
    0xC9,
    0x3E, 0xE4, 0xEA, 0xF0, 0x7F,       /* 6A commit */
    0xC9,
};

static void fpga_set(u16 reg, u8 v) {
    FPGA(0x7F00) = 0xE1;
    FPGA(0x7F10) = 0xE2;
    FPGA(0x7F20) = 0xE3;
    FPGA(reg) = v;
    FPGA(0x7FF0) = 0xE4;
}

/* One read-patch command (stage0/flash-read.psm): the table through the
 * $7F36=1 window, then the WRAM loop collects `chunks` chunks into FD_BUF.
 * Entry 0 is the stock-safe dummy ($07FF00, data $FF), entry $41 the start
 * address, entry $42 the chunk count and the first sequence number, which
 * must differ from what $A00E reads now. Returns 0, or 1 on a timeout. */
static u8 flash_cmd(u8 mode, u8 a2, u8 a1, u8 chunks, u8 last) {
    u8 seq, r;
    u16 k;

    fpga_set(0x7FC0, 6);
    seq = (u8)(WIN[0x0E] + 1);
    if (!seq) seq = 1;
    fpga_set(0x7FC0, 2);
    fpga_set(0x7F36, 1);
    WIN[0] = 0x00; WIN[1] = 0xFF; WIN[2] = 0x07; WIN[3] = mode;
    for (k = 4; k < 0x104; k++) WIN[k] = 0xFF;
    WIN[0x104] = 0; WIN[0x105] = a1; WIN[0x106] = a2; WIN[0x107] = 0;
    WIN[0x108] = chunks; WIN[0x109] = 0; WIN[0x10A] = 0; WIN[0x10B] = seq;
    fpga_set(0x7F36, 0);
    fpga_set(0x7FC0, 6);
    fpga_set(0x7FB0, 0);
    FD_STUB[ST_CHUNKS] = chunks;
    FD_STUB[ST_SEQ] = seq;
    FD_STUB[ST_LAST] = last;
    r = FlashStub();
    __asm__("ei");
    fpga_set(0x7FC0, 0);
    return r;
}

/* f_write `len` bytes, after f_open (FA_CREATE) of `name` when `open`. len is
 * <= 255 or 512, the two sizes the kernel's FatFs copies correctly
 * (docs/ezgb-cfg.md). Returns the FatFs result, $FF on a short write. */
static u8 sd_write(const u8 *name, const u8 *buf, u16 len, u8 open) {
    u16 bw;
    u8 r;
    WaitVBlankFlag();
    fpga_set(0x7FC0, 0);
    if (open) {
        u8 i = 0;
        while ((FL_SCR[i] = name[i]) != 0) i++;
        r = FarCall_06_7309(FIL_OBJ, FL_SCR, FA_CREATE);
        if (r) return r;
    }
    r = FarCall_07_7739(FIL_OBJ, buf, len, &bw);
    if (!r && bw != len) r = 0xFF;
    return r;
}

static void sd_close(void) {
    WaitVBlankFlag();
    FarCall_03_768f(FIL_OBJ);
}

static void flash_dump(void) {
    static const u8 t_busy[17] = {'D','U','M','P','I','N','G',' ','F','L','A','S','H',' ',' ',' ',0};
    static const u8 n_dna[9] = {'/','D','N','A','.','B','I','N',0};
    static const u8 n_flash[11] = {'/','F','L','A','S','H','.','B','I','N',0};
    u8 i, r, prog[4];
    u16 s;

    StoreDrawParams(3, 0, 0);
    DrawString(t_busy, 16, 0, FIRST);
    for (i = 0; i < sizeof flash_stub; i++) FD_STUB[i] = flash_stub[i];
    FD_RES[2] = FD_RES[3] = 0;

    if (flash_cmd('D', 0, 0, 2, 6) || FD_BUF[8] != 'E' || FD_BUF[9] != 'Z' ||
        FD_BUF[10] != 'D' || FD_BUF[11] != 'N') {
        FD_RES[0] = DUMP_NOPATCH;
        return;
    }
    for (i = 0; i < 8; i++) FD_DNA[i] = FD_BUF[i];
    r = sd_write(n_dna, FD_DNA, 8, 1);
    sd_close();
    if (r) { FD_RES[0] = DUMP_SD; FD_RES[1] = r; return; }

    for (s = 0; s < FLASH_SECTORS; s++) {
        /* sector s at s * 512: 85 chunks of 6 and one of 2 */
        if (flash_cmd('R', (u8)(s >> 7), (u8)(s << 1), 86, 2)) {
            if (s) sd_close();
            FD_RES[0] = DUMP_TIMEOUT;
            return;
        }
        r = sd_write(n_flash, FD_BUF, 512, s == 0);
        if (r) {
            if (s || r == 0xFF) sd_close();
            FD_RES[0] = DUMP_SD;
            FD_RES[1] = r;
            return;
        }
        FD_RES[2] = (u8)(s + 1); FD_RES[3] = (u8)((s + 1) >> 8);
        if ((s & 31) == 31) {
            for (i = 0; i < 4; i++) prog[i] = ' ';
            dec(prog, (u16)((s + 1) >> 1));   /* KB */
            DrawString(prog, 4, 14, FIRST);
        }
    }
    sd_close();
    FD_RES[0] = DUMP_OK;
}


/* v in decimal, left-aligned, by subtraction (no divide in this build). */
static void dec(u8 *out, u16 v) {
    static const u16 pow10[4] = {1000, 100, 10, 1};
    u8 i, d, lead = 1;
    for (i = 0; i < 4; i++) {
        for (d = 0; v >= pow10[i]; d++) v -= pow10[i];
        if (d || !lead || i == 3) {
            *out++ = (u8)('0' + d);
            lead = 0;
        }
    }
}
