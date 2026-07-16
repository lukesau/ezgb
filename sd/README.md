# Local microSD card (not tracked)

The SameBoy EZ Jr stub reads a raw disk image and presents it as the cart's SD
card. Everything in this directory stays local (see `.gitignore`).

## Layout

```
sd/
├── README.md      # this file (tracked)
├── card.img       # raw FAT image the emulator uses  ← required
└── root/          # optional folder copy of your Jr backup for editing
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
./scripts/make-sd-image.sh        # creates sd/card.img and copies sd/root/* into it
```

**Use 8.3 filenames** (e.g. `TETRIS.GB`, `PKMRED.GB`, `SAVER/PKMRED.SAV`). Spaces and
long names create VFAT LFN entries that the Jr file browser often displays as
garbage even when the files are readable.

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

1. **In-game save** → battery FRAM only (`cart_sram`). Mirrored to `sd/fram.bin`
   next to `card.img` so quitting SameBoy is a power-down.
2. **Power up** (load `kernel.gb` again) → kernel sees page `$11` flag `$AA`,
   shows **BACKUPSAVE** / `[A]OK`, and on confirm copies FRAM into `SAVER/*.SAV`
   on `card.img`.
3. While a game launched through the stub is running, SameBoy will **not** write
   a host `.sav` beside the ROM.

So: quit after saving in-game → relaunch the kernel → press A on BACKUPSAVE.
