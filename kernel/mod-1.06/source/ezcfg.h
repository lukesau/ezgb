/* mod: /EZGB.CFG, the settings file (ezcfg.c) */
#ifndef EZCFG_H
#define EZCFG_H

extern UINT8 cfg_dry;		/* main() sets it when the boot showed BATTERY DRY */

void console_init(void) __banked;		/* first thing in main() */
void cfg_boot(void) __banked;			/* the card is mounted */
UINT8 cfg_fastlaunch(void) __banked;		/* boot: 1 when FLAUNCH= is to be launched */
void cfg_launch(void) __banked;			/* a game is about to be loaded */
void cfg_timeset(const UINT8 *t) __banked;	/* TIME SET confirmed */
void cfg_autosave_set(UINT8 v) __banked;	/* the AUTO SAVE box changed */
UINT8 set_page2(void) __banked;			/* setpage.c, the SET tab's other pages: 1 when SELECT left them */
void cfg_backup(void) __banked;			/* a save backup was written at boot */

/* the settings, for setpage.c */
#define FLAUNCH_MAX	122U
extern UINT8 cfg_rtcsd, cfg_bootrom, cfg_theme, cfg_ui, cfg_sgb, cgb_mode, tags_hide;
extern char cfg_flaunch[FLAUNCH_MAX + 1U];
#define THEMES		6U
#define CFG_BOOTROM	0U
#define CFG_THEME	1U
#define CFG_FONT	2U
#define CFG_SGB		3U
#define CFG_OTHER	4U
void cfg_changed(UINT8 what) __banked;
UINT8 cfg_flaunch_last(void) __banked;
UINT8 sgb_record(void) __banked;
UINT8 theme_now(void) __banked;

#endif
