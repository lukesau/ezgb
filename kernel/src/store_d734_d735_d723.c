/* Call_000_2791 @ 1.05e $2791.
 * Writes three stack bytes to $D734, $D735, $D723. Widely used before tile/
 * string draw helpers (alongside Call_000_2765 for $D732/$D733). Exact role of
 * this triad not fully named yet. */

void store_d734_d735_d723(unsigned char a, unsigned char b, unsigned char c) {
    *((unsigned char *)0xd734) = a;
    *((unsigned char *)0xd735) = b;
    *((unsigned char *)0xd723) = c;
}
