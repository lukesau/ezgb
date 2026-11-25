/* mod: Manage saves (savemgr.c) */
#ifndef SAVEMGR_H
#define SAVEMGR_H

void save_manager(const char *name) __banked;	/* name: the game's file name, in RAM */

void save_daily(const char *savepath) __banked;	/* boot, before a waiting save is written */

#endif
