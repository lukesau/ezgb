/* EZGB.CFG: key=value lines, CR/LF or LF, keys any case, spaces around key
 * and value trimmed. Same rules as the kernel's parser (kernel/src/ezcfg.c
 * parse_record), FLAUNCH and BOOTROM only. The first FLAUNCH= decides. */
#include "cfg.h"

uint8_t cfg_boot_reset;

static uint8_t is_key(const uint8_t *k, uint8_t klen, const char *want)
{
    uint8_t c;

    while (klen--) {
        c = *k++;
        if (c >= 'a' && c <= 'z')
            c -= 32;
        if (c != (uint8_t)*want++)
            return 0;
    }
    return !*want;
}

uint8_t cfg_flaunch(const uint8_t *t, uint16_t n, char *path)
{
    const uint8_t *end = t + n, *s, *e, *eq, *k;
    uint8_t len, seen = 0, ok = 0;

    cfg_boot_reset = 0;
    while (t < end) {
        s = t;
        while (s < end && *s == ' ')
            s++;
        e = s;
        while (e < end && *e != '\r' && *e != '\n' && *e)
            e++;
        t = e;
        while (t < end && (*t == '\r' || *t == '\n'))
            t++;
        if (e < end && !*e)
            t = end;            /* NUL: last line */
        while (e > s && e[-1] == ' ')
            e--;
        for (eq = s; eq < e && *eq != '='; eq++)
            ;
        if (eq == e)
            continue;
        for (k = eq; k > s && k[-1] == ' '; k--)
            ;
        len = (uint8_t)(k - s);
        for (eq++; eq < e && *eq == ' '; eq++)
            ;
        if (is_key(s, len, "BOOTROM")) {
            cfg_boot_reset = eq < e && *eq == '1';
        } else if (!seen && is_key(s, len, "FLAUNCH")) {
            seen = 1;
            if (eq == e || *eq == '#')
                continue;
            len = 0;
            if (*eq != '/')
                path[len++] = '/';
            while (eq < e && len < CFG_PATH_MAX)
                path[len++] = *eq++;
            path[len] = 0;
            ok = 1;
        }
    }
    return ok;
}
