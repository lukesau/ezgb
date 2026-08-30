# EZ Flash Jr FPGA config-flash map (EN25F40, 512 KB)

How the cart's SPI config flash is laid out, derived entirely by static analysis
of files we hold — no hardware was touched to produce this. The working image is
`EN25F40-repaired-v2.bin`, the intact **FW4** reconstruction (verified against
the real chip dump `EN25F40@SOP8.BIN`; see [hardware-board.md](hardware-board.md)).

Tools: [`scripts/fpga-flash-map.py`](../scripts/fpga-flash-map.py) (segment map),
[`scripts/fpga-slot-diff.py`](../scripts/fpga-slot-diff.py) (slot A/B diff and
updater-payload overlay).

## Top-level layout

```
$00000 ┌──────────────────────────────┐
       │ SLOT A                        │  bitstream $00046-$24831 (149,484 B)
       │   $00000-$00045  header       │  head: aa 99 30 a1 00 07 …
$24832 ├──────────────────────────────┤
       │   erased ($ff)                │
$30000 ├──────────────────────────────┤
       │ BLOB  $30000-$31fff (8 KB)    │  entropy 7.80 — near-random, not code
$32000 ├──────────────────────────────┤
       │   erased ($ff)                │
$40000 ├──────────────────────────────┤
       │ SLOT B                        │  bitstream $40046-$64831 (149,484 B)
       │   $40000-$40045  header       │  identical head to slot A
$64832 ├──────────────────────────────┤
       │   erased; 52 B at $70000      │  (slot A's blob has no slot-B twin)
$7FFFF └──────────────────────────────┘
```

Two multiboot slots of identical size and container format, `$40000` apart — the
classic Spartan-3A golden/active pair. The only structural asymmetry is the 8 KB
blob at `$30000`, which exists in slot A's half and has no counterpart in slot
B's.

## The two slots are the same bitstream bar 8 bytes

`fpga-slot-diff.py --slots` on the FW4 image:

```
slot A bitstream vs slot B bitstream: 8 differing bytes
  +$1982c  A=20 B=60      +$247a3  A=1e B=2d
  +$1982d  A=81 B=80      +$247a4  A=94 B=46
                          +$247a5  A=5e B=27
                          +$247c5  A=31 B=06
                          +$247c6  A=6d B=3e
                          +$247c7  A=ed B=54
```

Eight bytes in two clusters, both near the bitstream **tail** (`$24831` is the
last byte). That is where a Spartan-3A bitstream carries its CRC / final-CRC and
a mid-stream frame CRC — consistent with slots A and B being two builds of the
same design rather than a byte-for-byte copy. They are not a plain duplicate.

## What the FW4 updater writes — verified

`Update_FW4.gb` past its `$8000` GB header is a 149,516-byte payload. Overlaid on
the flash by aligning the bitstream sync word:

```
payload vs slot B: 0 / 149516 bytes differ   ← exact
payload vs slot A: 8 / 149516 bytes differ   ← the same 8 CRC bytes above
```

**The FW4 payload is slot B, byte-for-byte.** This is the verification that the
overlay method is trustworthy before applying it to the FW5 payloads: it
reproduces known chip contents exactly. Slot A is the pre-existing (older or
factory-golden) image the FW4 update did not overwrite in this capture.

The payload's own leading `$26` bytes map onto the slot's `$00000-$00025` region
(the container header before the `$46` bitstream start); the bitstream body
begins at slot `+$46`.

## The $30000 blob is not the bootstrap ROM

Entropy 7.80 bits/byte (8.0 = random). No Nintendo logo under any of the five
encodings tried for the updaters (plain / bit-reversed / inverted / nibble /
rev+inv), no `ezgb.dat` / `LOADING` / `EZ-FLASH` strings, no GB-code shape, and
it does not appear anywhere in `ezgb.dat`. It is a distinct high-entropy payload
— compressed or encrypted data, or additional FPGA data — **not** a plaintext
bootstrap ROM.

Combined with the earlier finding that the bootstrap is absent from both
updaters, and that the flash contains no plaintext logo/strings anywhere, this
leans toward **hypothesis (b)** in [hardware-board.md](hardware-board.md): the
GB-visible bootstrap is embedded in the bitstream as block-RAM initialisation,
not stored as a separate ROM image. Not yet proven — proving it needs the
bitstream format — but the "separate plaintext ROM" hypothesis (a) now has no
supporting evidence in the flash image.

## Bitstream container

Both slots begin `aa 99 30 a1 00 07 …`. The `aa 99` echoes the Xilinx sync
prefix, but the standard Spartan-3A `aa 99 55 66` word does **not** appear
(searched normal and bit-reversed across the whole image). So the body is either
a non-standard packaging or a wrapped/transformed bitstream. Identifying the
exact format is the deep, open item; it is not required for the slot map or the
updater-write map above.

## FW5 ships two *different* bitstreams, and 0918 changes only one

The two FW5 payloads (0731 and 0918) are each 299,032 bytes — exactly 2× FW4's
149,516 — and each contains **two** bitstream sync words. Unlike the FW4 slots
(8 bytes apart), the two FW5 images are genuinely different designs. Aligning
every image by its sync word:

```
FW5-0731 img1 vs img2            59% differ    two different bitstreams
FW4      vs FW5-0731 img1/img2   64% differ    FW5 is a new design, not FW4's
FW5-0731 img2 vs FW5-0918 img2    0% differ    ← golden image, untouched
FW5-0731 img1 vs FW5-0918 img1   61% differ    ← the active image, rewritten
```

So the FW5 package is a real multiboot pair:

- **img2 = golden / fallback** — byte-identical between 0731 and 0918. Never
  rewritten by the 0918 update.
- **img1 = active / feature** — the only image that differs between 0731 and
  0918. Whatever 0918 adds (the reported SD-card fix and SGB support) is
  entirely inside img1.

This also means FW5 replaced FW4's single bitstream with a brand-new two-image
scheme; FW5's golden image differs from FW4 by 64%, so it is not a carried-over
copy.

**What updating 0731 → 0918 does to the flash, predicted:** rewrite the active
image with the new img1 bitstream; leave the golden image untouched. The one
thing this static analysis cannot pin down is which physical slot (`$00000` vs
`$40000`) holds the active vs golden image after a real FW5 write — that mapping
needs either the updater's disassembled write routine or a post-update dump
(Phase 2 / Phase 3 of
[the FPGA plan](../../.claude/plans/we-can-get-rid-swift-willow.md)).

## How the updater programs the flash — via `$7FD2`

Static disassembly of `Update_FW4.gb`'s code (banks 0–1, in `re/updater-fw4/`)
shows the flash-programming path uses the same FPGA command envelope the kernel
uses, wrapped around register **`$7FD2`**:

```asm
ld bc,$7f00 : ld a,$e1 : ld [bc],a   ; unlock
ld bc,$7f10 : ld a,$e2 : ld [bc],a   ; unlock
ld bc,$7f20 : ld a,$e3 : ld [bc],a   ; command mode
ld bc,$7fd2 : ld a,$01 : ld [bc],a   ; config-flash operation
ld bc,$7ff0 : ld a,$e4 : ld [bc],a   ; commit
```

`$7FD2` is written `$01` then `$00` in pairs (set/clear the operation bit), and
the real write loop at `$4013` **polls `$7FD2` (reads it back) until it clears**
before proceeding — the ready handshake. Parameters are staged first via
`$7F31=$00` / `$7F32=$80`.

> **This is exactly the register and sequence that bricked the cart.** The brick
> came from issuing `$7FD2=$01` *without* the poll-until-clear handshake the
> updater does at `$4013`, leaving a flash erase/program half-finished. `$7FD2`
> is the config-flash command register; never write it by hand. This
> disassembly is static only — the updater is never run
> (see [game-slot-access.md](game-slot-access.md)).

`re/updater-fw4/` holds the disassembly; the write routine is `Call_000_1252`
(bit set/clear, no wait) and the polled loop near `$4013`. The physical
slot-address setup — which decides whether a written image lands at `$00000` or
`$40000` — is staged through the parameter registers and is the one piece the
overlay + disassembly have not yet fully resolved; a post-update dump would
close it (Phase 3).

## Reproduce

```bash
scripts/fpga-flash-map.py  EN25F40-repaired-v2.bin
scripts/fpga-slot-diff.py  EN25F40-repaired-v2.bin --slots
scripts/fpga-slot-diff.py  EN25F40-repaired-v2.bin --overlay Update_FW4.gb --slot B
```
