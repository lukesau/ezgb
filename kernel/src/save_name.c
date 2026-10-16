/* Save manager: is a /SAVER file this ROM's save, or one of its backups?
 * (docs/save-manager.md)
 *
 * Bank 4, injected at 04:73a0, after ManageSaves; far target of the SoMatch
 * stub (01:7d50) that SaveOp's scan calls (save_ops.c). A block of its own
 * because SaveOp does not fit bank 1's free run with it. FarCallTrampoline
 * puts the first real argument at sp+6: two pad parameters.
 *
 *   <base>.sav                          1
 *   <base> YYYY-MM-DD HH-MM.sav         2, the time in e (year - 1980, month,
 *   <base> YYYY-MM-DD HH-MM (n).sav       day, hour, minute, n; n = 1 without
 *                                         a counter, else 2..250)
 *   anything else                       0
 *
 * <base> (BLEN characters of the ROM's name at $c4a4) and .sav match in any
 * case; the time fields must be in range, so "Tetris DX.sav" is not a
 * backup of Tetris.gb.
 *
 *   python3 tools/inject.py src/save_name.c $V 4 73a0 SaveNameMatch --apply
 */

#include "types.h"

#define NAME_BUF  ((const u8 *)0xC4A4)
#define BLEN      (*(volatile u8 *)0xD778)

static u8 digits(const u8 *p, u8 n, u16 *v);
static u8 lower(u8 c);

/* Where each time field sits in " YYYY-MM-DD HH-MM", the separator before
 * it, and its range (the year as year - 1980). */
static const u8 f_pos[5] = {1, 6, 9, 12, 15};
static const u8 f_sep[5] = {' ', '-', '-', ' ', '-'};
static const u8 f_lo[5]  = {0, 1, 1, 0, 0};
static const u8 f_hi[5]  = {127, 12, 31, 23, 59};

/* The entry point stays the first function in the file. */
u8 SaveNameMatch(u16 far_pad_af, u16 far_pad_ret, const u8 *name, u8 *e) {
    u16 v;
    u8 i, n;
    const u8 *p;

    (void)far_pad_af;
    (void)far_pad_ret;
    for (i = 0; i < BLEN; i++) if (lower(name[i]) != lower(NAME_BUF[i])) return 0;
    p = name + BLEN;
    if (p[0] != '.') {
        for (i = 0; i < 5; i++) {
            n = f_pos[i];
            if (p[n - 1] != f_sep[i] || !digits(p + n, i ? 2 : 4, &v)) return 0;
            if (i == 0) {
                if (v < 1980) return 0;
                v -= 1980;
            }
            if (v < f_lo[i] || v > f_hi[i]) return 0;
            e[i] = (u8)v;
        }
        p += 17;
        e[5] = 1;
        if (p[0] == ' ' && p[1] == '(') {
            for (n = 0; p[2 + n] >= '0' && p[2 + n] <= '9'; n++) {}
            if (n == 0 || n > 3 || p[2 + n] != ')' || !digits(p + 2, n, &v) || v < 2 || v > 250) return 0;
            e[5] = (u8)v;
            p += 3 + n;
        }
    }
    if (p[0] != '.' || lower(p[1]) != 's' || lower(p[2]) != 'a' || lower(p[3]) != 'v' || p[4]) return 0;
    return p == name + BLEN ? 1 : 2;
}

/* n decimal digits at p into v; 0 if any is not a digit. */
static u8 digits(const u8 *p, u8 n, u16 *v) {
    u16 x = 0;

    while (n--) {
        if (*p < '0' || *p > '9') return 0;
        x = (x << 3) + (x << 1) + (u8)(*p++ - '0');
    }
    *v = x;
    return 1;
}

static u8 lower(u8 c) {
    return (c >= 'A' && c <= 'Z') ? (u8)(c + 32) : c;
}
