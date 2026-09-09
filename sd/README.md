# Local microSD card (not tracked)

The SameBoy EZ Jr stub reads a raw disk image and presents it as the cart's SD
card. Everything in this directory stays local (see `.gitignore`).

## Layout

```
sd/
├── README.md      # this file (tracked)
├── ORDER          # top-level FAT entry order for the build (tracked)
├── card.img       # raw FAT image the emulator uses  ← required
└── root/          # folder copy of the card contents, edited then built
```

## Option A: dump your physical card

```sh
# macOS: find the SD device carefully (diskutil list), then:
diskutil unmountDisk /dev/diskN
sudo dd if=/dev/rdiskN of=sd/card.img bs=1m
```

## Option B: folder backup + build a fresh image

If you copied files into `sd/root/`:

```sh
./scripts/make-sd-image.sh        # creates sd/card.img from sd/root/ (needs mtools)
```

It builds the FAT with **mtools** (`brew install mtools`), so no macOS junk is
injected and the on-card directory-entry order is deterministic: top-level
entries are written in the order listed in `sd/ORDER` (rest appended sorted).
The stock browser lists that raw order while the mod sorts, so `sd/ORDER` is
what the stock-vs-mod README banner plays off (`scripts/make-showcase-banner.sh`).

The stock browser garbles VFAT long names (spaces / >8.3), so prefer 8.3 names
(`TETRIS.GB`, `SAVER/PKMRED.SAV`) if you care about the stock view; the **modded**
kernel resolves long names correctly, so the showcase card uses a few on purpose
(`Wario Land.gb`, `Advance Game.gba`).

You can also skip `root/` and mount the image to add files:

```sh
./scripts/mount-sd-image.sh       # attaches sd/card.img under /Volumes/EZJR (or similar)
# copy .gb/.gbc into the volume, then eject in Finder
```

## Running SameBoy against it

```sh
export SAMEBOY_EZFLASH_JR_IMG="$PWD/sd/card.img"   # optional if cwd walk finds it
./scripts/setup-sameboy.sh
cd tools/SameBoy && make CONF=debug sdl
./build/bin/SDL/sameboy ../../re/1.05e/kernel.gb
```

If `SAMEBOY_EZFLASH_JR_IMG` is unset, the stub walks up from the process cwd
looking for `sd/card.img`.

## Saves (Jr-like power cycle)

Matches the physical cart:

1. **In-game save** → PSRAM only (`cart_sram`; battery-backed, so a dead coin cell
   loses it). Mirrored to `sd/psram.bin` next to `card.img` so quitting SameBoy is a
   power-down. SD writes are written through to `card.img` immediately.
2. **Power up** (load `kernel.gb` again) → kernel sees page `$11` flag `$AA`,
   shows **BACKUPSAVE** / `[A]OK`, and on confirm copies PSRAM into `SAVER/*.SAV`
   on `card.img`.
3. While a game launched through the stub is running, SameBoy will **not** write
   a host `.sav` beside the ROM.

So: quit after saving in-game → relaunch the kernel → press A on BACKUPSAVE.
