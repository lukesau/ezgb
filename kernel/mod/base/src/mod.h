/* What base/ uses of the mod.s sources (../../src, ../../asm). Include
   after the GBDK headers. */


/* the highlight: black on white (the accent in a theme that has one) */
#define HI_INK		0
#define HI_PAPER	3

/* mod WRAM and HRAM (kernel/mod/src/vars.h, ezcfg.h). Their addresses are
   ../../names.txt: a symbol costs this compiler far less code
   than a constant address does. */
extern volatile UINT8 hUiMode;		/* $FFFB: 1 = the 12px browser */
extern volatile UINT8 hPadPrev;		/* $FFF5: the browser's previous joypad() */
extern volatile UINT8 hPad;		/* $FFF6: and its latest */
extern volatile UINT8 hPadHeld;		/* $FFF7: buttons ignored until released */
extern volatile UINT8 wEzOp;		/* $DBFC: op of the next ezcfg() */
extern volatile UINT8 wEzRes;		/* $DBFB: its result */
extern volatile UINT8 wBatteryDry;	/* $DBFD */
extern volatile UINT8 wFlPick;		/* $DBFE: the SET tab's PICK ROM is armed */
extern volatile UINT8 wFlBooted;	/* $DBFF: the fast-launch check has run */
extern volatile UINT8 wSetBack;		/* $DC1C: START left the SET tab */
extern volatile UINT8 wSetPage;		/* $DBEE: the SET tab's page */
extern UINT8 wSetRow;			/* $DC32: the SET tab's cursor row */
extern UINT8 wSetDirty;			/* $DC33: and its redraw flag, the byte after */
#define UI_ROWS		(hUiMode ? 10 : 16)	/* browser rows */

/* bank 0 */
UINT8 PadWait (void);				/* joypad() after the next VBlank */
UINT8 LastRomTickStub (void);			/* joypad(), and a step of the name marquee */

UINT8 BrowserPoll (void);			/* the browser loop's wait and joypad() */

/* bank 4, for bank4.c */
void SkipBootPrep (void);
void SgbLaunchPrep (void);
void SetText (char *s, UINT8 len, UINT8 col, UINT8 row);
UINT8 flcfg (UINT8 *st, UINT8 op);		/* st = &wSetRow */
void SetCommit (void);

/* other banks */
void DrawNameWithIcon (char *s, UINT8 len, UINT8 x, UINT8 y) __banked;	/* a browser row */
void TabNum12 (char *s, UINT8 len, UINT8 x, UINT8 y) __banked;	/* the position, right of the tabs */
void LastRomName (char *s) __banked;		/* a name in its band, scrolling */
void DrawString12 (char *s, UINT8 len, UINT8 x, UINT8 y) __banked;	/* 12px text */
UINT16 TagLen (char *s) __banked;		/* strlen without the name's tags */
void BrowserMove (UINT8 keys) __banked;		/* a direction key in the browser */
UINT8 BrowserPick (UINT8 slot) __banked;
UINT8 browser_hide_name (char *name) __banked;	/* 1 = not listed */
void browser_sort_all (void) __banked;
void fastlaunch_scan (void) __banked;		/* the path to launch into wLabelBuf */
void AutoBackup (void) __banked;
void LastRomBox (void) __banked;		/* the START overlay's box */
UINT8 RomMenu (UINT8 *slot) __banked;		/* slot = &wBrowser.ofs */
void FlPickCommit (void) __banked;
void TagCat (char *buf, const char *gap) __banked;
UINT8 Fit12 (char *s, UINT8 len, UINT8 col, char *xs) __banked;
void MsgBox (UINT8 which) __banked;		/* a message box, kernel/mod/src/msgbox.c */
void ezcfg (void) __banked;			/* EZGB.CFG and the RTC backup, by wEzOp */
void Bump (void) __banked;			/* play count of the game being launched */
void PlaySync (void) __banked;
void BkPrompt (UINT8 op, UINT8 size) __banked;	/* the BACKUPSAVE box's drawing */

#define menu_joypad	PadWait

