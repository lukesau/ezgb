# Decompilation progress

One entry per matched function. "Purpose" is marked unconfirmed until the calling context is
actually understood, not just the literal behavior.

| Function | Bank | 1.05e addr | 1.04e addr | Source | Purpose | Status |
|---|---|---|---|---|---|---|
| `Call_000_062e`…`0646` | 0 | `$062e`–`$064b` | `$062e`–`$064b` (list bases differ) | `decomp/src/register_callback_slots.c` | Load HL = callback-list base, `jp` installer; BC = fn ptr | Matched 1.05e (`__naked`; absolute `jp $066c`). 1.04e lists at `$D6AC`…`$D6EC` |
| `Call_000_064c` | 0 | `$064c` | `$064c` | `decomp/src/remove_callback_slot.c` | Find BC in uint16 list at HL; clear slot and compact tail | Matched, both versions (`__naked` register ABI) |
| `Jump_000_066c` | 0 | `$066c` | `$066c` | `decomp/src/install_callback_slot.c` | Walk uint16 list at HL; store BC in first free slot | Matched, both versions (`__naked` register ABI; stack-ABI C is semantically equivalent but not byte-identical) |
| `Call_000_0688` | 0 | `$0688` | `$0688` (flag `$D6A7`) | `decomp/src/wait_vblank_flag.c` | Wait (halt) until VBlank sets `$D6CE`; no-op if LCD off | Matched 1.05e (`__naked`). 1.04e uses `$D6A7` |
| `Call_000_069f` | 0 | `$069f` | `$069f` | `decomp/src/lcd_off.c` | Wait for safe LY window, clear LCDC bit 7 (LCD off); no-op if already off | Matched, both versions (SDCC 4.6 + `tools/peeps/lcd_off.def`) |
| `Call_000_1a77` | 0 | `$1a77` | `$1a5e` | `decomp/src/misc.c` (`return_zero`) | Unconfirmed, called from bank_003, bank_007, bank_009, context not yet examined | Matched, both versions |
| `Call_000_2765` | 0 | `$2765` | — (WRAM targets differ in 1.04e) | `decomp/src/store_d732_d733.c` | Likely set text cursor col/row (`$D732`/`$D733`); fed by `Call_000_08b7`, advanced by `Call_000_20f4` | Matched 1.05e (SDCC 4.6 + `tools/peeps/abs_pair_store.def`) |
| `Call_000_2791` | 0 | `$2791` | — | `decomp/src/store_d734_d735_d723.c` | Store draw params `$D734`/`$D735`/`$D723`; called widely before tile/string helpers | Matched 1.05e (SDCC 4.6 + `tools/peeps/abs_triple_store.def`) |

Total matched: 12 functions (counting 5 wrappers separately), 146 bytes.

## Notes

- `Call_000_2765` / `Call_000_2791` need abs-pair / abs-triple peepholes: modern SDCC emits
  `ld de,#abs` / `(de),a` where the kernel used `ld (#abs),a` (and `(hl+)` between loads).
  Same C source; peep restores the historical shape. Pass the peep file as verify's optional
  5th arg.
- `Call_000_069f` needs `tools/peeps/lcd_off.def`: modern SDCC uses `bit 7,a` / `sub` /
  `res 7,a` where the kernel used `add a,a` / `cp` / `and $7f`.
- `Jump_000_066c` / `Call_000_064c` / wrappers use HL+BC register ABI (boot passes
  `ld bc, handler` then `call` wrapper). `__naked` until verify can pin callees /
  express that convention in C. `$062e`–`$0676` callback-list cluster is fully matched
  on 1.05e; `Call_000_0688` (wait on `$D6CE`) sits just after and is matched too.
  Remaining unlabeled bytes at `$0677`–`$0687` are the VBlank stub that sets the flag.
