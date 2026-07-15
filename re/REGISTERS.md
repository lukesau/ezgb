# EZ Flash Jr kernel — hardware register map (hypothesis)

Derived from static analysis of `re/1.05e/disassembly` (kernel v1.05e) and cross-referenced
against the public EZ Flash Omega (GBA) kernel source (`tools/omega-de-kernel`), which uses the
same unlock/command/commit design for its own custom FPGA registers, just at different
addresses (GBA has a 32-bit address bus, Jr has the stock GB 16-bit bus).

## Unlock / commit handshake

Every access to the custom FPGA control registers is wrapped in the same 3-write unlock
followed by a 1-write commit, all in the $7f00-$7fff I/O window (which is unused/open bus on a
stock MBC1 cart — EZ Flash's FPGA decodes it):

```
ld bc, $7f00 \ ld a, $e1 \ ld [bc], a     ; unlock 1
ld bc, $7f10 \ ld a, $e2 \ ld [bc], a     ; unlock 2
ld bc, $7f20 \ ld a, $e3 \ ld [bc], a     ; unlock 3
    ... one or more command-register writes here ...
ld bc, $7ff0 \ ld a, $e4 \ ld [bc], a     ; commit
```

Found 29 occurrences of the unlock triple and 29 of the commit in kernel v1.05e — always
paired 1:1, confirming this is a single reusable pattern (likely originally a C macro/inline
helper, since it's inlined at every call site rather than being a shared subroutine).

Compare to Omega's `SetSDControl()` in `source/Ezcard_OP.c`:
```c
*(u16*)0x9fe0000 = 0xd200;
*(u16*)0x8000000 = 0x1500;
*(u16*)0x8020000 = 0xd200;
*(u16*)0x8040000 = 0x1500;
*(u16*)0x9400000 = control;   // the command value
*(u16*)0x9fc0000 = 0x1500;    // latch
```
Same shape: two magic constants written to fixed ports, the real command value written to a
third port, then a final "latch" write. Different constants/addresses because the FPGA register
maps differ per product, but the same underlying design.

## Registers written between unlock and commit (kernel v1.05e)

| Port | Value(s) seen | Occurrences | Hypothesis | Evidence |
|---|---|---|---|---|
| `$7fb0`-`$7fb4` | dynamic (stack values) | bank_002, several | **SD sector address (24-bit) + block count + trigger** | Written as a sequential run of bytes right before/after calls that look like they assemble a 32-bit LBA; matches Omega's `Read_SD_sectors`/`Write_SD_sectors` writing address-low, address-high, and block count to 3 separate ports before triggering |
| `$7fc0`-`$7fc4` | dynamic (single byte, stack value) | bank_000, bank_001, bank_004 (several distinct call sites) | **ROM/RAM bank-select family** (SetRompage / SetRampage / SetPSRampage analogues) — one port per bank-select target | Always a single byte write per call, called from many different sites, consistent with a bank-switch helper invoked all over the kernel |
| `$7fd0`, `$7fd2`, `$7fd4` | `$00`/`$01` (boolean-ish) | bank_004, bank_008 (paired enable/disable call sites) | **Peripheral enable/disable toggle** (RTC status / LED control candidates) | `$7fd2` appears as both `=$00` and `=$01` at different call sites in bank_008, back-to-back functions — classic enable()/disable() pair shape |
| `$7f31`, `$7f32` | `$00`,`$00` (always together) | bank_004 (x2) | **16-bit mode/flag register**, written as two halves | Always written as a pair in the same unlock/commit block |
| `$7f36` | `$00` or `$03` | bank_004 (x1 each), bank_008 (dynamic) | **Enable/mode select** (0=off, 3=on/mode3?) | Two adjacent functions in bank_004 write `$00` then `$03` to the same port — enable/disable pair again |
| `$7f37` | dynamic (stack value) | bank_004 | unidentified single-byte control | only one call site seen so far |
| `$7fe0` | `$80` (constant) | bank_004 (x2 identical call sites) | **Flash write-enable / erase-setup style command** | `$80` is the classic first byte of a JEDEC flash erase/unlock sequence; always the same fixed value here, never dynamic |

## Confidence and next steps

This is all **static hypothesis**, not confirmed behavior. The strongest next step is dynamic
tracing (SameBoy debugger with a watchpoint on writes to `$7f00-$7fff`) to see, for each of
these ports, what SD card / flash chip activity or menu behavior happens immediately after —
that will convert these guesses into verified facts. See `re/1.05e/disassembly` for the full
labeled source; the call sites are listed above by bank so they're quick to jump to.
