# Mod version on the HELP tab

The HELP tab's version screen (`DrawFwVersionScreen`, bank 8) stock-draws
`ver: FW5 K1.05e` and `www.ezflash.cn`. `DrawHelpModVersion` extends it: it appends the kernel date to the version
(`K1.05e-0731` / `K1.05e-0918`, collapsing the stock double space to fit),
adds a `MOD <version>` line, and a two-line `github.com/ lukesau/ezgb` link, so
a card announces exactly which build it is running.

## How it hooks

`DrawFwVersionScreen_drawChrome` (`08:70e1`) draws the URL last, with
`ld hl,$0500` at `08:7130`. That instruction is repointed to
`jp DrawHelpModVersion` (`08:7a9c`, a bank-8 cave). The hook redraws the URL
itself (the three bytes it displaced), redraws `K1.05e-<date>` at row 3 col 9
(over the second stock space, shifting it left one to make room for the
suffix), draws `MOD <version>` at row 7 and the GitHub link at rows 9-10, then
`jp`s to `DrawFwVersionScreen_waitSelect` (`08:7141`). The `-<date>` suffix is
the one part that differs between the two kernels. Bank 8 is byte-identical
across 1.05e-0731 and 1.05e-0918, so the hook and its call site are the same in
both.

The version text lives in a fixed 10-byte field `MODSTR` at `08:7aff`, drawn as
`len $0a`, so updating the number never changes any code — only those bytes.

## Reproduce

The hook is `DrawString(URL)` + `DrawString(K1.05e-<date>)` + `DrawString(MOD)`
+ two `DrawString`s for the GitHub link + `jp $7141`, followed by the four
strings (`K1.05e-<date>`, the 10-byte `MODSTR`, `github.com/`, `lukesau/ezgb`).
It is injected at `08:7a9c` (bank-8 cave) with `decomp/tools/inject_bytes.py`
and wired with `patch_call.py "$V" 8 7130 3 08:7a9c --jp`. The exact bytes are
in the disassembly (`DrawHelpModVersion`); `scripts/stamp-mod-version.sh` writes
the `MODSTR` field.

## Keeping it in sync

`scripts/stamp-mod-version.sh` copies `patches/kernel/VERSION` into `MODSTR` so
the screen equals the mod version, then holds `VERSION` fixed (the stamp would
otherwise bump it, since the bytes are part of the patch). Run it as the last
step before building `ezgb.dat` for a release. Re-running with the same version
is a no-op.
