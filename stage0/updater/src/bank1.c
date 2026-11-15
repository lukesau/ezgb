/* The updater's C in bank 1, $404E-$4181. The string functions are the
   kernel's and nothing calls them. */

#include <gb/gb.h>

void FlashPollRom (void);		/* 01:4000: FlashPoll (src/poll.c) where it is stored */

/* 01:404e */
#pragma save
#pragma noinduction
void MemCopy8_B1 (UINT8 *dst, char *src, UINT8 n)
{
	UINT8 *d;
	UINT8 *s;
	UINT8 i;

	s = src;
	d = dst;
	i = n;
	while (i--)
		*d++ = *s++;
}
#pragma restore

/* 01:408a: run FlashPoll from WRAM */
void RunFlashPoll (void) __banked
{
	MemCopy8_B1((UINT8 *)0xd000, (char *)FlashPollRom, 0xff);
	((void (*)(void))0xd000)();
}

/* 01:409f */
void CStrCat_B1 (char *dst, const char *src) __banked
{
	char *d = dst;

	while (*d)
		d++;
	while (*src)
		*d++ = *src++;
	*d = 0;
}

/* 01:40e7 */
int CStrCmp (const char *a, const char *b) __banked
{
	while (*a == *b) {
		if (!*a)
			return 0;
		a++;
		b++;
	}
	return *a - *b;
}

/* 01:4142: the last c in s, or 0 */
char *CStrChr (char *s, char c) __banked
{
	char *last = 0;

	if (!s)
		return 0;
	for (; *s; s++)
		if (*s == c)
			last = s;
	return last;
}
