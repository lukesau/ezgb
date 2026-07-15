# Decompilation progress

One entry per matched function. "Purpose" is marked unconfirmed until the calling context is
actually understood, not just the literal behavior.

| Function | Bank | 1.05e addr | 1.04e addr | Source | Purpose | Status |
|---|---|---|---|---|---|---|
| `Call_000_1a77` | 0 | `$1a77` | `$1a5e` | `decomp/src/misc.c` (`return_zero`) | Unconfirmed, called from bank_003, bank_007, bank_009, context not yet examined | Matched, both versions |
| `Call_000_2765` | 0 | `$2765` | — (WRAM targets differ in 1.04e) | `decomp/src/store_d732_d733.c` | Likely set text cursor col/row (`$D732`/`$D733`); fed by `Call_000_08b7`, advanced by `Call_000_20f4` | Matched 1.05e (SDCC 4.6 + `tools/peeps/abs_pair_store.def`) |
| `Call_000_2791` | 0 | `$2791` | — | `decomp/src/store_d734_d735_d723.c` | Store draw params `$D734`/`$D735`/`$D723`; called widely before tile/string helpers | Matched 1.05e (SDCC 4.6 + `tools/peeps/abs_triple_store.def`) |

Total matched: 3 functions, 27 bytes.

## Notes

- `Call_000_2765` / `Call_000_2791` need abs-pair / abs-triple peepholes: modern SDCC emits
  `ld de,#abs` / `(de),a` where the kernel used `ld (#abs),a` (and `(hl+)` between loads).
  Same C source; peep restores the historical shape. Pass the peep file as verify's optional
  5th arg.
