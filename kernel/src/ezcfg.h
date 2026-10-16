/* ezcfg's interface (ezcfg.c, docs/ezgb-cfg.md): the op byte its callers
 * set before a call and the WRAM state it loads from /EZGB.CFG. Include
 * after types.h. */

#define EZ_OP     (*(volatile u8 *)0xDBFC)  /* op for the next ezcfg call */
#define OP_LOAD     0
#define OP_SAVE     1
#define OP_BACKUP   2
#define OP_RESTORE  3
#define OP_LASTSAVE 4              /* launch: record the launch path as LASTROM= */
#define OP_LASTLOAD 5              /* START overlay: validate $A300 copy, else fall back to LASTROM= */
#define OP_TIMESET  6              /* SET-tab TIME SET confirm: the new time replaces RTC= outright */
#define OP_RELAUNCH 7              /* START-overlay relaunch / fast launch: RTC backup only */
#define OP_SAVECHK  8              /* boot: validate the BACKUPSAVE stamp's path before the prompt */
#define OP_AUTOSAVE 9              /* SET tab AUTO SAVE toggle: $A200 -> AUTOSAVE= */

#define CFG_LOADED (*(volatile u8 *)0xDBF9) /* 1 once cfg_load has run this boot (fast-launch scan reuses it) */

/* FLAUNCH= */
#define FL_EN     (*(volatile u8 *)0xDA80)
#define FL_PLEN   (*(volatile u8 *)0xDA81)
#define FL_PATH   ((u8 *)0xDA82)     /* stored path, NUL-terminated, <= PATH_MAX */
#define PATH_MAX  120
#define FL_SCR    ((u8 *)0xDB00)     /* file-name bounce, 16: FatFs wants the path in WRAM */

/* RTC= and RTCSD= */
#define RTC_OFF   (*(volatile u8 *)0xDB3A)  /* RTCSD=0 ("RTC: NO SD" on the SET tab): no RTC
                                               * reads, backups or prompt; stays valid in WRAM
                                               * after any load, so hooks can skip the card */
#define RTC_BK    ((u8 *)0xDB40)     /* the RTC= backup, 7 BCD bytes in register order */
#define RTC_VALID (*(volatile u8 *)0xDB47)

#define S1_SGB    (*(volatile u8 *)0xDBF8)  /* 1 when our stage1 handles the SGB (flcfg.c shows SGB BOOT as AUTO) */
