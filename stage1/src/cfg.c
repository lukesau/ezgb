/* EZGB.CFG: key=value lines, CR/LF or LF, keys any case, spaces around key
 * and value trimmed, the first occurrence of a key wins. Same rules as the
 * kernel's parser (kernel/src/ezcfg.c parse_record), FLAUNCH only. */
#include "cfg.h"

static uint8_t is_key(const uint8_t *k, uint8_t klen)
{
    static const char want[] = "FLAUNCH";
    uint8_t i, c;

    if (klen != 7)
        return 0;
    for (i = 0; i < 7; i++) {
        c = k[i];
        if (c >= 'a' && c <= 'z')
            c -= 32;
        if (c != (uint8_t)want[i])
            return 0;
    }
    return 1;
}

uint8_t cfg_flaunch(const uint8_t *text, uint16_t n, char *path)
{
    uint16_t p = 0, s, e, eq, k;
    uint8_t len;

    while (p < n) {
        s = p;
        while (s < n && text[s] == ' ')
            s++;
        e = s;
        while (e < n && text[e] != '\r' && text[e] != '\n' && text[e])
            e++;
        p = e;
        while (p < n && (text[p] == '\r' || text[p] == '\n'))
            p++;
        if (e < n && !text[e])
            p = n;              /* NUL: last line */
        while (e > s && text[e - 1] == ' ')
            e--;
        for (eq = s; eq < e && text[eq] != '='; eq++)
            ;
        if (eq == e)
            continue;
        for (k = eq; k > s && text[k - 1] == ' '; k--)
            ;
        if (!is_key(text + s, (uint8_t)(k - s)))
            continue;
        /* first FLAUNCH= decides */
        for (s = eq + 1; s < e && text[s] == ' '; s++)
            ;
        if (s == e || text[s] == '#')
            return 0;
        len = 0;
        if (text[s] != '/')
            path[len++] = '/';
        while (s < e && len < CFG_PATH_MAX)
            path[len++] = text[s++];
        path[len] = 0;
        return 1;
    }
    return 0;
}
