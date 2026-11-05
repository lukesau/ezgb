/* Daily save backup (docs/save-manager.md "Daily backup"), off unless the SET
 * tab's DAILY BACKUP is ticked (DAILYBACKUP=1 in EZGB.CFG).
 *
 * After davidesqalv's ezgb-dv fork, whose code this is (auto_backup.c), fitted
 * to this kernel: either font and every theme, and the switch in EZGB.CFG so a
 * cart without a coin cell keeps it.
 *
 * Keeps one backup of each game's save from before the day's first session.
 * Bank 12, injected at 0C:4C00. SaveStampHook (00:03aa) jumps to AutoBackupStub
 * (00:3d94) once the page-$11 stamp has passed its check; the stub far-calls
 * this, then goes on to f_mkdir("/SAVER") and BackupSavePrompt as before.
 * SAVE_PATH ($c3a5) holds "/SAVER/<base>.sav", the file the dump is about to
 * overwrite with the cart's save RAM.
 *
 * If that file exists and was last written before today (its FAT date against
 * the cart clock, which also stamps the dump), it is copied to a backup named
 * like Manage saves' and the game's other backups are deleted, so Manage saves
 * shows that one and can restore it. Later boots the same day find the file
 * written today and leave the backup alone: a save that went bad during a
 * session, and the reboots that follow, can't replace the backup before the
 * next day. Copying takes about 7 s for a 32 KB save, hence the box, in
 * BkPrompt's place: the prompt clears (0,32)-(159,107) itself. A stamp cleared
 * at the fast launch check (stage1 dumps the save itself) never gets here.
 *
 * The file work is the save manager's SaveOp (01:7670), which takes the ROM's
 * name from $c4a4; "<base>.sav" there gives the same <base>. Between here and
 * the browser nothing reads $c4a4, the scan window ($D750-$D9FF) or the
 * loader's $C0A0 buffer: the dump opens $c3a5 on the kernel FIL, and the browser
 * fills the rest itself.
 *
 *   python3 tools/inject.py src/auto_backup.c $V 12 4c00 AutoBackup \
 *       --pin RtcReadPage=1a9a --pin FarCallDrawString12=05c0 --pin DrawString=08b7 \
 *       --pin LastRomNameStub=0368 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
 *       --pin FarCallTrampoline=078d --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

extern u32 RtcReadPage(void);                       /* 00:1a9a (fat_date.c on 1.04e): get_fattime, date in the high word */
extern void LastRomNameStub(const u8 *s);           /* 00:0368 -> LastRomName */
extern void FarCallTrampoline(void);                /* 00:078d */

#define SAVE_PATH ((const u8 *)0xC3A5)      /* "/SAVER/<base>.sav" from the stamp */
#define NAME_BUF  ((u8 *)0xC4A4)            /* SaveOp's ROM name */
#define LIVE      ((const u8 *)0xD770)      /* [0] the save exists, [1..3] its date: year-1980, month, day */
#define COUNT     (*(volatile u8 *)0xD777)  /* backups listed, newest first */
#define BLEN      (*(volatile u8 *)0xD778)  /* length of <base> */
#define SAVE_SIZE (*(volatile u8 *)0xA001)  /* page $11: the stamp's save size in 8 KB banks */

#define SO_SCAN   0
#define SO_BACKUP 1
#define SO_DELETE 3
#define SO_DONE   5

#define NAME_MAX  80                        /* SaveOp skips a <base> over 60 anyway */
#define META_PAGE 0x11                      /* $4000 as the boot branch left it */

static u8 SmSaveOp(u16 opidx) __naked;
static u8 written_today(void);
static void draw_box(void);
static void text(const u8 *s, u8 row8, u8 y12);

/* The entry point stays the first function in the file. Far target of a
 * `call`ed stub, no arguments. */
void AutoBackup(void) {
    const u8 *s = SAVE_PATH + 7;
    u8 i;

    if (!BK_DAILY) return;
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
    }
    SmSaveOp((SO_DONE << 8) | META_PAGE);
}

/* Title, the game's name on a band, why, and how long: BkPrompt's geometry,
 * and no fill, since the screen under the boot log is still clear and DrawRect
 * is slow over large areas. */
static void draw_box(void) {
    static const u8 title_str[18] = {'D','a','i','l','y',' ','s','a','v','e',' ','b','a','c','k','u','p',0};
    static const u8 why_str[19]   = {'C','o','p','y',' ','o','f',' ','o','l','d','e','r',' ','s','a','v','e',0};
    static const u8 about_str[7]  = {'A','b','o','u','t',' ',0};
    static const u8 secs_str[12]  = {' ','s','e','c','o','n','d','s','.','.','.',0};
    u8 buf[24];
    u8 i, n, secs;

    /* about 1.75 s per 8 KB bank, from the stamp on page $11 */
    SmSaveOp((SO_DONE << 8) | META_PAGE);
    n = SAVE_SIZE;
    secs = n ? (u8)((((n << 3) - n) + 2) >> 2) : 2;   /* (7n + 2) / 4, no helper calls */

    StoreDrawParams(3, 0, 0);
    text(title_str, 5, 40);
    text(why_str, 9, 72);
    for (i = 0; about_str[i]; i++) buf[i] = about_str[i];
    for (n = 0; secs >= 10; n++) secs -= 10;
    if (n) buf[i++] = (u8)('0' + n);
    buf[i++] = (u8)('0' + secs);
    for (n = 0; secs_str[n]; n++) buf[i++] = secs_str[n];
    buf[i] = 0;
    text(buf, 11, 88);
    StoreDrawParams(3, 3, 0);
    if (hUiMode) DrawRect(0, 53, 159, 69, 1); else DrawRect(0, 51, 159, 67, 1);
    LR_GEO = 1;
    LastRomNameStub(SAVE_PATH + 7);
    /* last: 12px rows and the name run over the outline's right edge */
    StoreDrawParams(3, 0, 0);
    if (hUiMode) DrawRect(0, 36, 159, 103, 0); else DrawRect(0, 35, 159, 99, 0);
}

/* One row: a tile row in 8px, a pixel y from x 12 in 12px, through the stack,
 * since the renderer runs in bank 2 and can't read this bank's strings. */
static void text(const u8 *s, u8 row8, u8 y12) {
    u8 buf[24];
    u8 i;

    for (i = 0; i < 23 && s[i]; i++) buf[i] = s[i];
    buf[i] = 0;
    if (hUiMode) FarCallDrawString12(buf, 0, 1, y12);
    else DrawString(buf, i, 1, row8);
}

/* 1 when the live save's FAT date is the cart clock's today. */
static u8 written_today(void) {
    u16 date = (u16)(RtcReadPage() >> 16);

    return LIVE[1] == (u8)(date >> 9) &&
           LIVE[2] == ((u8)(date >> 5) & 0x0F) &&
           LIVE[3] == ((u8)date & 0x1F);
}

/* SaveOp, 01:7670, through a `call`ed stub, as save_mgr.c's SmSaveOpB11. */
static u8 SmSaveOp(u16 opidx) __naked {
    (void)opidx;
    __asm
	ldhl	sp, #2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	call	_FarCallTrampoline
	.dw	0x7670
	.db	1, 0
	add	sp, #2
	ret
    __endasm;
}
