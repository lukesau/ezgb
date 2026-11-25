/* mod: stars and play counts (plays.c) */
#ifndef PLAYS_H
#define PLAYS_H

#define FATTR_STARRED	0x21U	/* a list record's fattrib for a starred file (a plain file is 0x20) */

void plays_load(void) __banked;				/* boot: the card's table over save RAM's */
void plays_bump(const UINT8 *name) __banked;		/* a launch */
UINT8 star_query(const UINT8 *name) __banked;
UINT8 star_toggle(const UINT8 *name) __banked;		/* 0: the table is full of stars */
UINT8 plays_sort_on(void) __banked;
void plays_sort_set(UINT8 on) __banked;
UINT8 plays_active(void) __banked;			/* bit 0: something is starred, bit 1: SORT BY PLAYS */
UINT8 plays_lookup(const UINT8 *name, UINT8 *launches) __banked;	/* bit 0: starred */

#endif
