/*-------------------------------------------*/
/* Integer type definitions for FatFs module */
/*-------------------------------------------*/

#ifndef _FF_INTEGER
#define _FF_INTEGER

#ifdef _WIN32	/* Development platform */

#include <windows.h>
#include <tchar.h>

#elif defined(ASM_TYPES_INCLUDE)	/* ezgb: after GBDK's types, built with
				   BYTE_IS_UNSIGNED, which gives BYTE, WORD and DWORD */
typedef short			SHORT;
typedef unsigned short	WCHAR;
typedef int				INT;
typedef unsigned int	UINT;
typedef long			LONG;

#else			/* Embedded platform */

/* This type MUST be 8-bit */
typedef unsigned char	BYTE;

/* These types MUST be 16-bit */
typedef short			SHORT;
typedef unsigned short	WORD;
typedef unsigned short	WCHAR;

/* These types MUST be 16-bit or 32-bit */
typedef int				INT;
typedef unsigned int	UINT;

/* These types MUST be 32-bit */
typedef long			LONG;
typedef unsigned long	DWORD;

#endif

#endif
