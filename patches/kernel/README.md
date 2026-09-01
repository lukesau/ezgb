# Kernel patches

Standard IPS patches that turn a **stock** official `ezgb.dat` into this
repo's modded kernel (all features: sorted browser, scrolling fixes, dotfile
filter, fast launch). One patch per firmware version; `manifest.json` holds
the md5s of the expected input and output, and `VERSION` the current mod
version (`N.M`).

```bash
python3 ../../scripts/kernel-patch.py apply /path/to/ezgb.dat
```

Or use any IPS tool (Flips, Lunar IPS, an online patcher) and check the md5s
yourself. Full instructions, checksums, and why we ship patches instead of
builds: [`docs/distribution.md`](../../docs/distribution.md).

These files contain only this project's injected code - none of EZ Flash's
firmware - so they are safe to share and attach to releases.
