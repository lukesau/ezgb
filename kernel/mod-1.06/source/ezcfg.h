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
UINT8 set_page2(void) __banked;			/* the SET tab's second page: 1 when SELECT left it */

#endif
