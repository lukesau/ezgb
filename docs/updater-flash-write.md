# How the FW4 updater writes flash (and where stage1 comes from)

Static read of `re/updater-fw4/` (the disassembled `Update_FW4.gb`), done to
answer: **how does the firmware updater write `stage1`** (the 32 KB factory
bootstrap, dumped per-FW-version by [daid/ezflashjr](https://github.com/daid/ezflashjr),
which records only that it "is somehow updated by the firmware updater, exact
mechanism currently unknown")? The motivating goal was finding whether the
4 MB Spansion parallel NOR (U4) is a writable, mostly-free nonvolatile store.

## Answer

**There is no separate stage1-write path.** The updater writes exactly one
nonvolatile target - the SPI config flash - via the `$7FD2` command protocol,
and its embedded payload is the FPGA bitstream. `stage1` is not carried in the
updater as data; it is almost certainly **BRAM-initialised inside the
bitstream**, so writing a new bitstream implicitly ships a new stage1. The
parallel NOR die is never touched.

## What the updater is

`Update_FW4.gb`, 182,284 bytes. Layout of the first 64 KB (`updater-code.gb`,
what the disassembly covers):

| Bank | Contents | Evidence |
|---|---|---|
| 0 | The updater program | entropy 6.14 b/byte, 20% `$ff` |
| 1 | Tiny tail: WRAM-stub flash routines only | **98% `$ff`** - essentially empty |
| 2+ | FPGA bitstream payload | starts `$8020` = `aa 99 30 a1 …` (bitstream sync); entropy climbs |

The payload from `$8020` is the 149 KB bitstream - proven byte-for-byte equal
to config-flash **slot B** in [fpga-flash-map.md](fpga-flash-map.md). The
updater is a **launched game**: it runs from the pSRAM game area with its
payload embedded, and **never reads the SD card** (no `$7F30`/`$7FB0`–`$7FB3`
access anywhere in banks 0–1).

## The write path (SPI config flash, `$7FD2`)

Every nonvolatile write goes through one register, `$7FD2`, inside the standard
FPGA unlock/commit envelope (`$7F00=$E1,$7F10=$E2,$7F20=$E3` … `$7FF0=$E4`).
The primitives in bank 0 / bank 1:

| Addr | Role |
|---|---|
| `00:124b` | `$7FD2=$01` - begin config-flash operation |
| `00:1271` (`Call_000_1271`) | `$7FD2=$00` - end operation |
| `00:1290` (`Call_000_1290`) | `$7F36=arg` - map the ROM-load/command window at `$A000` |
| `00:12b0` (`Call_000_12b0`) | maps window (`$7F36=1`), memcpy 0x110 bytes → `$A000`, unmaps - stages one command/data block |
| `01:4000` | `$7FD2=$01`, then read `$A000`; if nonzero `jp $d01f` (**poll-until-clear from a WRAM stub**), then `$7FD2=$00` |
| `01:4076` | copies a routine to `$d000` and `call $d000` - runs the poll loop from WRAM (the ROM window is busy during the op) |

Parameters are staged before the trigger via `$7F31=$00` / `$7F32=$80` (a
16-bit `$8000`-shaped operand), matching [fpga-flash-map.md](fpga-flash-map.md).
This is the same register and handshake documented there - and the same one
that **bricked a cart when the poll-until-clear was skipped**
([game-slot-access.md](game-slot-access.md)). The `$7FD2` target is the SPI
config flash, confirmed because the payload it writes overlays exactly onto the
external config-flash dump.

## What the updater does NOT do

- **No parallel-NOR (U4 NOR die) programming.** Zero JEDEC command sequences in
  the real code (no `$AA`→`$55`→`$A0` writes to the `$A000` window; searched
  banks 0–1). The one generic personality setter (`FpgaSetPersonality`,
  `00:153a`, `$7FC0=arg`) is **dead code** - no `call`, no `jp`, and no far-call
  trampoline blob targets it anywhere in the ROM.
- **No SD access** (self-contained payload).
- **No separate stage1 image.** `stage1/FW4/stage1.gb` (daid's dump) does not
  appear in the updater - not verbatim, nor bit-reversed, inverted, or
  nibble-swapped. FW4 and FW5 stage1 differ by 37%, tracking the 64%-different
  bitstreams.

## Why stage1 is (almost certainly) in the bitstream

Everything is consistent with stage1 living in FPGA block-RAM, initialised by
the bitstream:

- The updater carries a bitstream and writes only the config flash.
- The config-flash dump contains no contiguous stage1 under any encoding
  ([fpga-flash-map.md](fpga-flash-map.md)) - expected, because BRAM init is
  bit-interleaved across bitstream configuration frames, not stored as a ROM
  image.
- Each FW's stage1 changes in lockstep with a new bitstream.
- Updating the bitstream → new BRAM at next config load → new stage1, with **no
  extra write step**. That is precisely daid's "somehow updated, mechanism
  unknown."

Not *proven* (that needs Spartan-3A bitstream-format RE to extract the BRAM
init and match it to `stage1.gb`), but it is the only hypothesis left standing,
and it is directly testable if/when the bitstream container is cracked
([hardware-board.md](hardware-board.md), [fpga-ace.md](fpga-ace.md)).

## Consequence for "free space"

The original hope - that the updater reveals a writable, mostly-empty 4 MB
parallel NOR we could borrow - does **not** pan out from this side: the updater
never addresses that die, and there is currently **no known GB-CPU path** that
maps it. What the parallel NOR die is actually for is now an open question
(vestigial/reserved, or reachable only through an FPGA feature the GB side never
invokes). The only firmware-writable nonvolatile store the updater exposes is
the SPI config flash, and that is bitstream storage - brick-adjacent, not free
scratch. A genuinely free large nonvolatile store, if the parallel NOR is one,
would require an FPGA-side path we have not found (or a replacement design).

## Reproduce

```bash
# updater writes only $7FD2; no SD, no JEDEC-NOR, personality setter unreferenced
grep -rn '\$7fd2\|\$7fc0\|\$7fb0\|\$7f30' re/updater-fw4/disassembly/bank_00{0,1}.asm

# stage1 is not embedded in the updater (any simple encoding)
python3 - <<'PY'
s=open('tools/ezflashjr/stage1/FW4/stage1.gb','rb').read()
u=open('re/updater-fw4/updater.gb','rb').read()
n=s[0x100:0x300]
enc={'plain':n,'bitrev':bytes(int(f"{x:08b}"[::-1],2) for x in n),
     'invert':bytes(x^0xff for x in n),'nib':bytes(((x<<4)|(x>>4))&0xff for x in n)}
for k,v in enc.items(): print(k, u.find(v))
PY
```
