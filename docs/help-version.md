# The HELP tab

Stock draws `ver: FW5 K1.05e` and `www.ezflash.cn` on the HELP tab
(`DrawFwVersionScreen`, bank 8). The mod makes the screen say exactly which
build is running:

```
FW5  K1.05e-0731
www.ezflash.cn
MOD N.M
github.com/lukesau/
ezgb
```

The kernel text is `K1.05e-0731` or `K1.05e-0918` on the two 1.05e builds,
which stock cannot tell apart, and plain `K1.04e` on the FW4 kernel.
Addresses are 1.05e-0731's.

## The hooks

`DrawFwVersionScreen` builds `FW<n>  K1.05e` in a stack buffer and then
draws. The draw half (`DrawFwVersionScreen_drawChrome`, `08:70e1`) starts
with `jp HelpHook` (`08:7b40`):

- In 8px mode the hook replays the displaced load and the stock code runs
  on. Its last draw, `ld hl,$0500` at `08:7130`, is `jp DrawHelpModVersion`
  (`08:7a9c`), which redraws the URL, draws the kernel text with its date
  over the stock one, adds the `MOD` line and the two-line link, and jumps
  to the stock wait loop (`08:7141`).
- In 12px mode the hook calls `Help12`
  ([help12.c](../kernel/mod/src/help12.c), `08:7d00`) with that buffer and
  jumps to the same wait loop. `Help12` draws the five lines from x 4 at
  y 24, 44, 64, 84 and 96, from the same bank-8 strings, copying each to
  the stack first because the 12px engine is in another bank. The 8px
  pane's `ver:` label is dropped there.

## The version text

The mod version is a fixed 10-byte field, `MODSTR` at `08:7aff`, so
changing the number never changes any code. `scripts/stamp-mod-version.sh`
copies `patches/kernel/VERSION` into it for every kernel
([DEVELOPMENT.md](DEVELOPMENT.md#releases)).

The kernel text is the one string that differs between the three builds. It
is `VERSION_TEXT` in `scripts/port-mod.py`, which the port writes into each.
