# Library code with no published source

Stage1's bank 0 has library code no published library matches. It is here
as assembly, converted from the stock disassembly (`stage1/fw4`) to sdas
syntax, so the whole ROM links from source. Labels keep the disassembly's
names; the globals are the names the rest of the program links against.

| File | FW4 | What |
|---|---|---|
| `div.s` | `00:279B`-`289A` | 8- and 16-bit divide and modulo. SDCC 2.9.0's `div.s`, the same entry points, up to the unsigned 16-bit loop, which differs from every SDCC and GBDK version tried |
| `drawing_isr.s` | `00:2931`-`2948` | the VBL and LCD handlers of GBDK's `drawing.s` (`.vbl`, `.lcd`) and its two colour variables, without the rest of `drawing.s` |
| `long.s` | `00:2949`-`2BA5` | SDCC's `__divslong`, `__divulong`, `__modslong`, `__modulong`, 8x8 and 16x16 multiply, compares, `memcpy`, and `errno` |
| `long2.s` | `00:2BEB`-`2D24` | `__mullong`, the divide and multiply engines, the N-byte helpers |

`long.s` and `long2.s` are one library split by SDCC's `puts`, which the
link puts between them. Its routines work on operands of any width, given
in `b`: zero test, negate, clear, copy and subtract helpers, a
shift-and-subtract divide engine and a byte-by-byte multiply engine that
take pointers to the operands. A zero divisor sets `errno` (SDCC's, `$C4AA`)
to 33, SDCC's `EDOM`, and returns `$7FFFFFFF`.

## Where it is not from

Compared in full with relocated operands masked (2026-11-14):

- GBDK 2.96a's prebuilt `gb.lib` and `gbz80.lib`, whole modules and by
  function.
- SDCC 2.9.0's `device/lib`, the C long math compiled with no options,
  `--std-c99`, `--nostdinc` and `--opt-code-size`. SDCC sets `errno` only
  in its float functions.
- SDCC's git history: no gbz80 or z80 library assembly ever used `errno`.
  A structural search (2026-11-14) of every `.s` file in all 11,154 commits,
  January 2000 to June 2025 (every release and snapshot), by normalized
  six-instruction sequences: `long.s` and `long2.s` share at most 7 of 519
  with any of them, common byte-multiply code. Only `div.s` matches, as
  above.
- GBDK-2020 4.0 to 4.1.0 (only the 8-bit divide stubs match).
- Michael Hope's GBDK repository, every tag from 2.91 to 2.96a, and GBDK
  2.1.5, the last `lcc` release (its `fp_long.s` is register-based, a
  different design).
- Every GBDK archive on SourceForge: the prebuilt Win32 and Linux releases
  2.91 to 2.95-3, `gbdk-lib` 2.92 and 2.95, the 2.90 source, the 2.1.0 and
  2.1.5 binaries.
- z88dk: its gbz80 long division (2021) is register-based, and its `EDOM`
  is not SDCC's 33.
- GitHub code search for asm defining SDCC's `__divslong` / `__mullong` or
  storing to `_errno`: only SDCC's own libraries for other targets.

This code is rebuilt from EZ Flash's stage1 (and their kernel, which links
the same library). No published library has it, so it is probably EZ
Flash's code, written for this or carried over from their earlier products.
