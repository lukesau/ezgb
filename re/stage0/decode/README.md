# Bitstream decodes

`s3decode` output for each firmware release: every configured tile of the
bitstream, with each bel's attributes and LUT contents, as text. Block RAM
contents are summarised (size, nonzero count, a hash) rather than dumped.
Diff two of these to see what changed between releases.

| File | Bitstream |
|---|---|
| `fw4.decode.txt` | FW4 slot B (the updater's payload) |
| `fw4-slota-vs-slotb.diff` | FW4 slot A against slot B: one BRAM differs (stage1) |
| `fw5-0918.decode.txt` | FW5, the 0918 update |
| `fw5-0731.decode.txt` | FW5, the 0731 update |
| `fw5-slota.decode.txt` | FW5's fallback image at config flash `$00000` |
| `fw5-sgb-beta.decode.txt` | FW5 SGB beta |

Regenerate with `s3decode` (flags and setup:
[../docs/toolchain.md](../docs/toolchain.md)); what the FW4 decode shows is in
[../docs/bitstream.md](../docs/bitstream.md), FW5 in [../docs/fw5.md](../docs/fw5.md).
