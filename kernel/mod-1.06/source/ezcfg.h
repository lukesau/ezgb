/* mod: /EZGB.CFG, the settings file (ezcfg.c) */
#ifndef EZCFG_H
#define EZCFG_H

extern UINT8 tab_to_sd;		/* START left the SET tab: sdlist.c goes to the SD tab */
extern UINT8 cfg_dry;		/* main() sets it when the boot showed BATTERY DRY */

void console_init(void) __banked;		/* first thing in main() */
void cfg_boot(void) __banked;			/* the card is mounted */
UINT8 cfg_fastlaunch(void) __banked;		/* boot: 1 when FLAUNCH= is to be launched */
void cfg_launch(void) __banked;			/* a game is about to be loaded */
void cfg_timeset(const UINT8 *t) __banked;	/* TIME SET confirmed */
void cfg_autosave_set(UINT8 v) __banked;	/* the AUTO SAVE box changed */
#define SET_RESUME	2U				/* set_page2's start for the last row of page 1 */
#define SET_PAGE2	3U				/* and for the first rows of pages 2 and 3 */
#define SET_PAGE3	8U
UINT8 set_page2(UINT8 start) __banked;		/* setpage.c: the cursor in the mod's SET rows */
void set_page1_rows(void) __banked;		/* setpage.c: the mod's rows of page 1 */
void cfg_backup(void) __banked;			/* a save backup was written at boot */

/* the settings, for setpage.c */
#define FLAUNCH_MAX	122U

/* What a theme does to color() (ezcfg.c, theme_apply) */
extern UINT8 acc_idx;
extern UINT8 pop_idx;

/* The cursor of the SET tab and the active tab of the 8px strip: the
   background color on the ink, which a theme turns into its accent. As
   received they were black on dark gray, which the Chinese build keeps:
   its text is drawn by its own code. */
#ifdef LANG_ZH
#define SEL_INK	BLACK
#define SEL_PAPER	DKGREY
#else
#define SEL_INK	WHITE
#define SEL_PAPER	BLACK
#endif
extern UINT8 cfg_rtcsd, cfg_bootrom, cfg_theme, cfg_ui, cfg_sgb, cgb_mode, tags_hide, cfg_daily, sgb_auto, custom_ok, cfg_can_jump;
extern char cfg_flaunch[FLAUNCH_MAX + 1U];
#define THEMES		8U
#define CFG_BOOTROM	0U
#define CFG_THEME	1U
#define CFG_FONT	2U
#define CFG_SGB		3U
#define CFG_OTHER	4U
void cfg_changed(UINT8 what) __banked;
UINT8 cfg_flaunch_last(void) __banked;
UINT8 sgb_record(void) __banked;
UINT8 theme_now(void) __banked;
extern UINT8 custom_ch[9];
void cfg_colors_changed(void) __banked;
void cfg_colors_seed(UINT8 *dst) __banked;

#endif
