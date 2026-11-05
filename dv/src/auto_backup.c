/* ezgb-dv: keep one backup of each game's save from before the day's first
 * session. dv/build.py places it at 04:7680.
 *
 * Bank 4. SaveStampHook (00:03aa) jumps to AutoBackupStub (00:3e8d) once
 * savestamp_check has passed the page-$11 stamp; the stub far-calls this,
 * then goes on to f_mkdir("/SAVER") and BackupSavePrompt as before.
 * SAVE_PATH ($c3a5) holds "/SAVER/<base>.sav", the file the dump is about
 * to overwrite with the cart's save RAM.
 *
 * If that file exists and was last written before today (its FAT date
 * against the cart clock, RtcReadPage, which also stamps the dump), it is
 * copied to a backup named like Manage saves' own, "<base> YYYY-MM-DD
 * HH-MM.sav" (docs/save-manager.md), and the game's other backups are
 * deleted, so Manage saves shows that one and can restore it. Later boots
 * the same day find the file written today and leave the backup alone: a
 * save that went bad during a session, and the reboots that follow, can't
 * replace the backup before the next day. Copying is slow in this kernel
 * (about 7 s for a 32 KB save in SameBoy), so it happens once a day per
 * game, behind a box in the BACKUPSAVE prompt's style (bkprompt.c) that says
 * what is happening, for which game and for about how long (from the stamp's
 * save size, $A001 banks of 8 KB, at roughly 1.75 s a bank). Afterwards the
 * part below BackupSavePrompt's own, shorter box is cleared; that box clears
 * the rest itself.
 *
 *   12px  box (0,36)-(159,143); title y 40, name band y 53..69, three
 *         lines at y 72, 84, 96, rule y 123, time y 128, all from x 12
 *
 * The SET tab's DAILY BACKUP box (flcfg.c's copy) turns it off: a record on
 * pSRAM page $11 at $B108 ('B', 'K', 0, $FF); anything else, as on a fresh
 * cart, leaves it on.
 *
 * The file work is the save manager's SaveOp (01:7670, through SmSaveOp at
 * 04:6562), which takes the ROM's name from $c4a4; "<base>.sav" there gives
 * the same <base>. Between here and the browser nothing reads $c4a4, the
 * scan window ($D750-$D9FF) or the loader's $C0A0 buffer: the dump opens
 * $c3a5 on the kernel FIL, and the browser fills the rest itself.
 */

typedef unsigned char u8;
typedef unsigned int u16;
typedef unsigned long u32;

extern u8 SmSaveOp(u16 opidx);                                      /* 04:6562 -> SaveOp 01:7670 */
extern u32 RtcReadPage(void);                                       /* 00:1a9a: get_fattime, date in the high word */
extern void FarCallDrawString12(const u8 *s, u8 len, u8 col, u8 row);   /* 00:05c0 -> 02:7500 */
extern void LastRomNameStub(const u8 *s);                           /* 00:0368 -> LastRomName */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 ink, u8 paper, u8 op);               /* 00:2791 */

#define SAVE_PATH ((const u8 *)0xC3A5)      /* "/SAVER/<base>.sav" from the stamp */
#define NAME_BUF  ((u8 *)0xC4A4)            /* SaveOp's ROM name */
#define LIVE      ((const u8 *)0xD770)      /* [0] the save exists, [1..3] its date: year-1980, month, day */
#define COUNT     (*(volatile u8 *)0xD777)  /* backups listed, newest first */
#define BLEN      (*(volatile u8 *)0xD778)  /* length of <base> */
#define SAVE_SIZE (*(volatile u8 *)0xA001)  /* page $11: the stamp's save size in 8 KB banks */
#define LR_GEO    (*(volatile u8 *)0xDB3F)  /* LastRomName: 1 = the BACKUPSAVE box's name band */
#define BACKUP_REC ((const volatile u8 *)0xB108)  /* page $11: DAILY BACKUP, 'B', 'K', flag, ~flag */

#define SO_SCAN   0
#define SO_BACKUP 1
#define SO_DELETE 3
#define SO_DONE   5

#define NAME_MAX  80                        /* SaveOp skips a <base> over 60 anyway */
#define META_PAGE 0x11                      /* $4000 as the boot branch left it */
#define NAME_SHOWN 23                       /* the band's width in 6 px characters */

#define INK_BLACK 0                         /* BGP $27: 0 black, 1 green, 3 white */
#define INK_GREEN 1
#define INK_WHITE 3

static u8 switched_off(void);
static u8 written_today(void);
static void draw_box(void);
static void clear_box(void);
static void text(const u8 *s, u8 y);

/* The entry point stays the first function in the file. Far target, no
 * arguments. */
void AutoBackup(void) {
    const u8 *s = SAVE_PATH + 7;
    u8 i;

    if (switched_off()) return;
    for (i = 0; s[i] && i < NAME_MAX; i++) NAME_BUF[i] = s[i];
    NAME_BUF[i] = 0;
    SmSaveOp(SO_SCAN << 8);
    if (LIVE[0] && !written_today()) {
        draw_box();
        /* the new backup is named after the newest save, so it lists first */
        if (SmSaveOp(SO_BACKUP << 8)) {
            for (i = 0; i < 64; i++) {
                SmSaveOp(SO_SCAN << 8);
                if (COUNT <= 1) break;
                SmSaveOp((SO_DELETE << 8) | (u8)(COUNT - 1));
            }
        }
        clear_box();
    }
    SmSaveOp((SO_DONE << 8) | META_PAGE);
}

/* The box: title, the game's name on the green band, why, and how long. */
static void draw_box(void) {
    static const u8 title_str[18] = {'D','a','i','l','y',' ','s','a','v','e',' ','b','a','c','k','u','p',0};
    static const u8 why1_str[22]  = {'K','e','e','p','i','n','g',' ','a',' ','c','o','p','y',' ','o','f',' ','t','h','e',0};
    static const u8 why2_str[24]  = {'s','a','v','e',' ','f','r','o','m',' ','b','e','f','o','r','e',' ',
                                     't','o','d','a','y','.',0};
    static const u8 why3_str[17]  = {'R','u','n','s',' ','o','n','c','e',' ','a',' ','d','a','y','.',0};
    static const u8 about_str[7]  = {'A','b','o','u','t',' ',0};
    static const u8 secs_str[12]  = {' ','s','e','c','o','n','d','s','.','.','.',0};
    u8 buf[NAME_SHOWN + 1];
    u8 i, n, secs;

    /* about 1.75 s per 8 KB bank, from the stamp on page $11 */
    SmSaveOp((SO_DONE << 8) | META_PAGE);
    n = SAVE_SIZE;
    secs = n ? (u8)((((n << 3) - n) + 2) >> 2) : 2;   /* (7n + 2) / 4, no helper calls */

    /* the screen under the boot log is still black, so no fill: DrawRect is
     * slow over large areas (filling the box cost about 6 s in SameBoy) */
    text(title_str, 40);
    text(why1_str, 72);
    text(why2_str, 84);
    text(why3_str, 96);
    for (i = 0; about_str[i]; i++) buf[i] = about_str[i];
    for (n = 0; secs >= 10; n++) secs -= 10;
    if (n) buf[i++] = (u8)('0' + n);
    buf[i++] = (u8)('0' + secs);
    for (n = 0; secs_str[n]; n++) buf[i++] = secs_str[n];
    buf[i] = 0;
    text(buf, 128);
    StoreDrawParams(INK_GREEN, INK_GREEN, 0);
    DrawRect(1, 123, 158, 123, 1);
    DrawRect(1, 53, 158, 69, 1);
    for (i = 0; i < BLEN && i < NAME_SHOWN; i++) buf[i] = NAME_BUF[i];
    buf[i] = 0;
    LR_GEO = 1;
    LastRomNameStub(buf);
    /* last: 12px rows and the name run over the outline's right edge */
    StoreDrawParams(INK_WHITE, INK_BLACK, 0);
    DrawRect(0, 36, 159, 143, 0);
}

/* Black below the BACKUPSAVE box, which clears (0,32)-(159,107) itself. */
static void clear_box(void) {
    StoreDrawParams(INK_BLACK, INK_BLACK, 0);
    DrawRect(0, 104, 159, 143, 1);
    StoreDrawParams(INK_WHITE, INK_BLACK, 0);
}

/* One 12px row from x 12. The renderer runs in bank 2 and can't read this
 * bank's strings, so the row goes through the stack. */
static void text(const u8 *s, u8 y) {
    u8 buf[24];
    u8 i;

    for (i = 0; i < 23 && s[i]; i++) buf[i] = s[i];
    buf[i] = 0;
    StoreDrawParams(INK_WHITE, INK_BLACK, 0);
    FarCallDrawString12(buf, 0, 1, y);
}

/* 1 when DAILY BACKUP is unticked. Leaves page $11 in the window, as
 * AutoBackup's own exit does. */
static u8 switched_off(void) {
    SmSaveOp((SO_DONE << 8) | META_PAGE);
    return BACKUP_REC[0] == 'B' && BACKUP_REC[1] == 'K' && BACKUP_REC[2] == 0 && BACKUP_REC[3] == 0xFF;
}

/* 1 when the live save's FAT date is the cart clock's today. */
static u8 written_today(void) {
    u16 date = (u16)(RtcReadPage() >> 16);

    return LIVE[1] == (u8)(date >> 9) &&
           LIVE[2] == ((u8)(date >> 5) & 0x0F) &&
           LIVE[3] == ((u8)date & 0x1F);
}
