/* ============================================================================
   cc936_zh.c  -  code page 936 (GB2312 only), for the Chinese build
   ----------------------------------------------------------------------------
   Included by ffunicode.c in the LANG=zh build only, replacing ccsbcs.c (437).

   Difference from the old 1.05c cc936.c: that one split the full GBK table into
   6+6 banks (banks 22..33, 192KB), but the font only covers GB2312 (banks
   10..21), so the GBK extension half was never used. Here only the 7478 GB2312
   (key,value) pairs are kept: the tables fit in 8 banks (128KB) and the whole
   Chinese image stays at 30 banks / 480KB.

   Physical layout (filled by source/cp936_*.s with .incbin):
        bank 22  cp936_u2o_0   unicode -> oem    pairs     0..4095
        bank 23  cp936_u2o_1   unicode -> oem    pairs  4096..8191
        bank 24  cp936_u2o_2                     pairs  8192..12287
        bank 25  cp936_u2o_3                     pairs 12288..16383
        bank 26  cp936_u2o_4                     pairs 16384..20479
        bank 27  cp936_u2o_5                     pairs 20480..21792
        bank 28  cp936_o2u_0   oem -> unicode    pairs     0..4095
        bank 29  cp936_o2u_1                     pairs  4096..7477
   Each pair is 4 bytes (key first, then value, both 16-bit little endian) and
   sorted by key inside its block.

   Lookup: pick the block with the split keys, then binary search inside it. The
   split key is the first key of the second block, so one bank is mapped at a time.

   Out-of-range behaviour: the OEM->Unicode direction falls back to the 174-entry
   CP936 supplement below (dashes, box drawing, ...), which is what file names use.
   Anything still unknown returns 0 and FatFs rejects the whole name
   (create_name -> FR_INVALID_NAME), so f_open fails instead of matching the
   wrong file; the kernel reports that as an error instead of hanging.

   NOTE: the code of this file must stay in bank 0. The branches switch ROM banks
   and while they do, 0x4000-0x7FFF holds font/code-page data, never this code.
   ========================================================================== */

#include <gb/gb.h>
#include "ff.h"

/* Bank layout (8 banks, the highest is bank 29)
     22..27  u2o (Unicode -> OEM) 6 blocks, 21793 pairs, full GBK coverage
     28..29  o2u (OEM -> Unicode) 2 blocks, 7478 pairs, GB2312 only

   Why not 6 blocks on both sides: the cart's bank register has only 5 bits, so
   **banks 32 and above read back as 0xFF** (measured). Full GBK needs 34 banks.
   Names are displayed through u2o, so that side is complete; o2u is only used
   when opening a file by name and stays GB2312 - same as before, no regression. */
#define CP_O2U_BANK0    28U
#define CP_U2O_BANK0    22U
#define CP_PER_BANK     4096U       /* 16384 bytes / 4 bytes per pair */

#define CP_O2U_BANKS    2U
#define CP_U2O_BANKS    6U

/* First key of each block. Locate the last block whose key <= target, then
   binary search inside it. The last block is padded to 4096 with its last pair. */
static const UINT cp_o2u_split[CP_O2U_BANKS] = { 0xA1A1U, 0xD3FCU };
static const UINT cp_u2o_split[CP_U2O_BANKS] =
	{ 0x0000U, 0x5B32U, 0x6B32U, 0x7B32U, 0x8B32U, 0x9B32U };

/* ----------------------------------------------------------------------------
   Binary search for key inside one 16KB window, returns its value (0 if none).
   bank0 + 1 selects the second block; split is that block's first key.
   -------------------------------------------------------------------------- */
/*  key / k must be UINT (unsigned 16-bit), never WORD.
    GBDK-2020's WORD is INT16 (signed); port_types.h only restored BYTE to
    unsigned. With signed comparison 0x888B reads as -30581, so
    "0x7F58 < 0x888B" is false and the search always converges left: every
    character with a code >= 0x8000 (many common ones) fails to convert, FatFs
    aborts the LFN and the name falls back to 8.3 (xxx~1.GBC). */
/* ----------------------------------------------------------------------------
   CP936 supplement for the OEM -> Unicode direction.

   The o2u blocks only carry GB2312 (7478 pairs). CP936 maps 174 further
   non-ideograph codes - GBK/5: dashes, arrows, box drawing, kana marks, ... -
   and FatFs rejects the WHOLE name when ff_convert() returns 0 for one
   character (create_name: "if (!w) return FR_INVALID_NAME"). Hardware symptom:
   a ROM named with "\u2013" (CP936 0xA843) could not be opened at all, so the
   boot stopped at "Loading..." for ever while every other game worked.

   The 14k GBK ideographs outside GB2312 cannot be added (4 more banks; the
   cart's bank register is 5 bits and bank 32+ reads back 0xFF), but file names
   practically only carry punctuation from this set. Sorted by OEM code. */
static const UINT cp_o2u_ext[][2] = {
/*  OEM    Unicode                                                        */
	{0xA840U, 0x02CAU}, {0xA841U, 0x02CBU}, {0xA842U, 0x02D9U}, {0xA843U, 0x2013U}, {0xA844U, 0x2015U},
	{0xA845U, 0x2025U}, {0xA846U, 0x2035U}, {0xA847U, 0x2105U}, {0xA848U, 0x2109U}, {0xA849U, 0x2196U},
	{0xA84AU, 0x2197U}, {0xA84BU, 0x2198U}, {0xA84CU, 0x2199U}, {0xA84DU, 0x2215U}, {0xA84EU, 0x221FU},
	{0xA84FU, 0x2223U}, {0xA850U, 0x2252U}, {0xA851U, 0x2266U}, {0xA852U, 0x2267U}, {0xA853U, 0x22BFU},
	{0xA854U, 0x2550U}, {0xA855U, 0x2551U}, {0xA856U, 0x2552U}, {0xA857U, 0x2553U}, {0xA858U, 0x2554U},
	{0xA859U, 0x2555U}, {0xA85AU, 0x2556U}, {0xA85BU, 0x2557U}, {0xA85CU, 0x2558U}, {0xA85DU, 0x2559U},
	{0xA85EU, 0x255AU}, {0xA85FU, 0x255BU}, {0xA860U, 0x255CU}, {0xA861U, 0x255DU}, {0xA862U, 0x255EU},
	{0xA863U, 0x255FU}, {0xA864U, 0x2560U}, {0xA865U, 0x2561U}, {0xA866U, 0x2562U}, {0xA867U, 0x2563U},
	{0xA868U, 0x2564U}, {0xA869U, 0x2565U}, {0xA86AU, 0x2566U}, {0xA86BU, 0x2567U}, {0xA86CU, 0x2568U},
	{0xA86DU, 0x2569U}, {0xA86EU, 0x256AU}, {0xA86FU, 0x256BU}, {0xA870U, 0x256CU}, {0xA871U, 0x256DU},
	{0xA872U, 0x256EU}, {0xA873U, 0x256FU}, {0xA874U, 0x2570U}, {0xA875U, 0x2571U}, {0xA876U, 0x2572U},
	{0xA877U, 0x2573U}, {0xA878U, 0x2581U}, {0xA879U, 0x2582U}, {0xA87AU, 0x2583U}, {0xA87BU, 0x2584U},
	{0xA87CU, 0x2585U}, {0xA87DU, 0x2586U}, {0xA87EU, 0x2587U}, {0xA880U, 0x2588U}, {0xA881U, 0x2589U},
	{0xA882U, 0x258AU}, {0xA883U, 0x258BU}, {0xA884U, 0x258CU}, {0xA885U, 0x258DU}, {0xA886U, 0x258EU},
	{0xA887U, 0x258FU}, {0xA888U, 0x2593U}, {0xA889U, 0x2594U}, {0xA88AU, 0x2595U}, {0xA88BU, 0x25BCU},
	{0xA88CU, 0x25BDU}, {0xA88DU, 0x25E2U}, {0xA88EU, 0x25E3U}, {0xA88FU, 0x25E4U}, {0xA890U, 0x25E5U},
	{0xA891U, 0x2609U}, {0xA892U, 0x2295U}, {0xA893U, 0x3012U}, {0xA894U, 0x301DU}, {0xA895U, 0x301EU},
	{0xA940U, 0x3021U}, {0xA941U, 0x3022U}, {0xA942U, 0x3023U}, {0xA943U, 0x3024U}, {0xA944U, 0x3025U},
	{0xA945U, 0x3026U}, {0xA946U, 0x3027U}, {0xA947U, 0x3028U}, {0xA948U, 0x3029U}, {0xA949U, 0x32A3U},
	{0xA94AU, 0x338EU}, {0xA94BU, 0x338FU}, {0xA94CU, 0x339CU}, {0xA94DU, 0x339DU}, {0xA94EU, 0x339EU},
	{0xA94FU, 0x33A1U}, {0xA950U, 0x33C4U}, {0xA951U, 0x33CEU}, {0xA952U, 0x33D1U}, {0xA953U, 0x33D2U},
	{0xA954U, 0x33D5U}, {0xA955U, 0xFE30U}, {0xA956U, 0xFFE2U}, {0xA957U, 0xFFE4U}, {0xA959U, 0x2121U},
	{0xA95AU, 0x3231U}, {0xA95CU, 0x2010U}, {0xA960U, 0x30FCU}, {0xA961U, 0x309BU}, {0xA962U, 0x309CU},
	{0xA963U, 0x30FDU}, {0xA964U, 0x30FEU}, {0xA965U, 0x3006U}, {0xA966U, 0x309DU}, {0xA967U, 0x309EU},
	{0xA968U, 0xFE49U}, {0xA969U, 0xFE4AU}, {0xA96AU, 0xFE4BU}, {0xA96BU, 0xFE4CU}, {0xA96CU, 0xFE4DU},
	{0xA96DU, 0xFE4EU}, {0xA96EU, 0xFE4FU}, {0xA96FU, 0xFE50U}, {0xA970U, 0xFE51U}, {0xA971U, 0xFE52U},
	{0xA972U, 0xFE54U}, {0xA973U, 0xFE55U}, {0xA974U, 0xFE56U}, {0xA975U, 0xFE57U}, {0xA976U, 0xFE59U},
	{0xA977U, 0xFE5AU}, {0xA978U, 0xFE5BU}, {0xA979U, 0xFE5CU}, {0xA97AU, 0xFE5DU}, {0xA97BU, 0xFE5EU},
	{0xA97CU, 0xFE5FU}, {0xA97DU, 0xFE60U}, {0xA97EU, 0xFE61U}, {0xA980U, 0xFE62U}, {0xA981U, 0xFE63U},
	{0xA982U, 0xFE64U}, {0xA983U, 0xFE65U}, {0xA984U, 0xFE66U}, {0xA985U, 0xFE68U}, {0xA986U, 0xFE69U},
	{0xA987U, 0xFE6AU}, {0xA988U, 0xFE6BU}, {0xA996U, 0x3007U}, {0xFD9CU, 0xF92CU}, {0xFD9DU, 0xF979U},
	{0xFD9EU, 0xF995U}, {0xFD9FU, 0xF9E7U}, {0xFDA0U, 0xF9F1U}, {0xFE40U, 0xFA0CU}, {0xFE41U, 0xFA0DU},
	{0xFE42U, 0xFA0EU}, {0xFE43U, 0xFA0FU}, {0xFE44U, 0xFA11U}, {0xFE45U, 0xFA13U}, {0xFE46U, 0xFA14U},
	{0xFE47U, 0xFA18U}, {0xFE48U, 0xFA1FU}, {0xFE49U, 0xFA20U}, {0xFE4AU, 0xFA21U}, {0xFE4BU, 0xFA23U},
	{0xFE4CU, 0xFA24U}, {0xFE4DU, 0xFA27U}, {0xFE4EU, 0xFA28U}, {0xFE4FU, 0xFA29U}
};

/* Binary search in the supplement (only reached when the GB2312 table misses). */
static WCHAR cp_ext_lookup (UINT key)
{
	UINT lo = 0U;
	UINT hi = (UINT)(sizeof(cp_o2u_ext) / sizeof(cp_o2u_ext[0]));
	UINT mid, k;

	while (lo < hi)
	{
		mid = (UINT)(lo + (hi - lo) / 2U);
		k = cp_o2u_ext[mid][0];
		if (k == key) return (WCHAR)cp_o2u_ext[mid][1];
		if (k < key) lo = mid + 1U;
		else         hi = mid;
	}
	return 0;
}

static WCHAR cp_lookup (UINT key, BYTE bank0, const UINT *split, BYTE banks)
{
	const WCHAR *p;
	UINT lo, hi, mid, k;
	WCHAR c = 0;
	BYTE old = _current_bank;
	BYTE blk = 0U, i;

	for (i = 0U; i < banks; i++)
		if (key >= split[i]) blk = i;

	SWITCH_ROM((BYTE)(bank0 + blk));
	p = (const WCHAR *)0x4000;      /* p[i] == *(0x4000 + i*2) */

	lo = 0U;
	hi = CP_PER_BANK;

	while (lo < hi)
	{
		mid = (UINT)(lo + (hi - lo) / 2U);
		k = p[mid * 2];             /* key is the first WCHAR of pair mid */
		if (k == key)
		{
			c = p[mid * 2 + 1U];    /* value is the second WCHAR */
			break;
		}
		if (k < key)
			lo = mid + 1U;
		else
			hi = mid;
	}

	SWITCH_ROM(old);
	return c;
}

WCHAR ff_convert (	/* Converted code, 0 means conversion error */
	WCHAR	chr,	/* Character code to be converted */
	UINT	dir		/* 0: Unicode to OEM code, 1: OEM code to Unicode */
)
{
	if (chr < 0x80)					/* ASCII passes through */
		return chr;

	if (dir)						/* OEM -> Unicode */
	{
		WCHAR c = cp_lookup(chr, CP_O2U_BANK0, cp_o2u_split, CP_O2U_BANKS);
		if (c == 0U) c = cp_ext_lookup((UINT)chr);	/* CP936 extension block */
		return c;
	}
	else							/* Unicode -> OEM */
		return cp_lookup(chr, CP_U2O_BANK0, cp_u2o_split, CP_U2O_BANKS);
}

/* ----------------------------------------------------------------------------
   Upper-case folding. ASCII only: GB2312 ideographs have no case, return as is.
   ff.c uses it to compare LFNs (line 1295) and build 8.3 names (1942/3374).
   -------------------------------------------------------------------------- */
WCHAR ff_wtoupper (	/* Returns upper converted character */
	WCHAR	chr		/* Unicode character to be upper converted */
)
{
	if (chr >= 'a' && chr <= 'z')
		return (WCHAR)(chr - ('a' - 'A'));
	return chr;
}
