# Mod version on the HELP tab

The HELP tab's version screen (`DrawFwVersionScreen`, bank 8) stock-draws
`ver: FW5 K1.05e` and `www.ezflash.cn`. `DrawHelpModVersion` adds a third line,
`MOD <version>`, so a card announces which build it is running.

## How it hooks

`DrawFwVersionScreen_drawChrome` (`08:70e1`) draws the URL last, with
`ld hl,$0500` at `08:7130`. That instruction is repointed to
`jp DrawHelpModVersion` (`08:7a9c`, a bank-8 cave). The hook redraws the URL
itself (the three bytes it displaced), then draws `MOD <version>` at row 7, then
`jp`s to `DrawFwVersionScreen_waitSelect` (`08:7141`). Bank 8 is byte-identical
across 1.05e-0731 and 1.05e-0918, so the hook and its call site are the same in
both.

The version text lives in a fixed 10-byte field `MODSTR` at `08:7ac1`, drawn as
`len $0a`, so updating the number never changes any code — only those bytes.

## Reproduce

```sh
HOOK=210005e53e0ef533215a71e5cdb708e805210007e53e0af53321c17ae5cdb708e805c34171
# + the 10-byte MODSTR (ASCII, space-padded); scripts/stamp-mod-version.sh writes it
for V in 1.05e-0731 1.05e-0918; do
  python3 decomp/tools/inject_bytes.py "$V" 8 7a9c DrawHelpModVersion \
    "${HOOK}4d4f4420332e31382020" --apply           # "MOD 3.18  "
  python3 decomp/tools/patch_call.py   "$V" 8 7130 3 08:7a9c --jp --apply
done
scripts/stamp-mod-version.sh    # writes patches/kernel/VERSION into MODSTR
```

## Keeping it in sync

`scripts/stamp-mod-version.sh` copies `patches/kernel/VERSION` into `MODSTR` so
the screen equals the mod version, then holds `VERSION` fixed (the stamp would
otherwise bump it, since the bytes are part of the patch). Run it as the last
step before building `ezgb.dat` for a release. Re-running with the same version
is a no-op.
