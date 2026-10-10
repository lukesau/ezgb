# The firmware updaters

`Update_FW4.gb` is the Game Boy program, launched from the kernel, that
writes a new slot B bitstream to the cart's config flash. Its disassembly
is in [fw4/](fw4/) (`kernel.sym` names, generated `disassembly/`); the
updater binaries themselves are EZ Flash's and stay local. How it writes
the flash, and how our own updaters are built from it:
[docs/updater-flash-write.md](../../docs/updater-flash-write.md).
