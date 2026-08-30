#!/usr/bin/env python3
"""Audit a FAT directory's raw on-disk layout.

Why: FAT directories never shrink. Deleting or moving files out of a folder
leaves 0xE5 tombstone slots behind, and the 0x00 terminator stays beyond the
highest slot ever used. FatFs's dir_read (DirRead_B5, bank 5) skips that whole
tombstone tail *inside one f_readdir call*, so the kernel's DirList hangs for
the entire walk the first time it reads past the last live entry — exactly the
one-time multi-second stall seen when scrolling DOWN past the visible page in
a short directory listing (docs/browser-scroll... / decomp/src/browser_scroll.c).

This script reports, for one directory on a card image or raw device:
  - cluster chain length (how big the directory file really is)
  - live entries vs 0xE5 tombstones vs LFN slots
  - the size of the dead tail after the last live entry — the slots that the
    final, end-of-directory readdir must scan in one go.

Usage:
  python3 scripts/fat-dir-audit.py sd/card.img "/"
  sudo python3 scripts/fat-dir-audit.py /dev/rdisk4 "/Other/gb complete romset"

Supports FAT16/FAT32, superfloppy or MBR-partitioned. Read-only.
"""

import struct
import sys

SECTOR = 512


def read_at(f, off, n):
    f.seek(off)
    d = f.read(n)
    if len(d) != n:
        raise IOError(f"short read at {off:#x} ({len(d)}/{n} bytes)")
    return d


def find_volume_offset(f):
    """Return byte offset of the FAT volume (0 for superfloppy)."""
    s0 = read_at(f, 0, SECTOR)
    if s0[510:512] != b"\x55\xaa":
        raise ValueError("no 0x55AA signature in sector 0")
    # A boot sector starts with a jump; bytes_per_sector must be sane.
    bps = struct.unpack_from("<H", s0, 11)[0]
    if s0[0] in (0xEB, 0xE9) and bps in (512, 1024, 2048, 4096):
        return 0
    # Otherwise treat sector 0 as an MBR and take the first FAT partition.
    FAT_TYPES = {0x01, 0x04, 0x06, 0x0B, 0x0C, 0x0E}
    for i in range(4):
        e = s0[446 + 16 * i : 446 + 16 * (i + 1)]
        ptype = e[4]
        lba = struct.unpack_from("<I", e, 8)[0]
        if ptype in FAT_TYPES and lba:
            return lba * SECTOR
    raise ValueError("sector 0 is neither a FAT boot sector nor an MBR with a FAT partition")


class Volume:
    def __init__(self, f, base):
        self.f = f
        self.base = base
        bs = read_at(f, base, SECTOR)
        (self.bytes_per_sec,) = struct.unpack_from("<H", bs, 11)
        self.sec_per_clus = bs[13]
        (self.rsvd,) = struct.unpack_from("<H", bs, 14)
        self.nfats = bs[16]
        (self.root_ent_cnt,) = struct.unpack_from("<H", bs, 17)
        (tot16,) = struct.unpack_from("<H", bs, 19)
        (self.fatsz16,) = struct.unpack_from("<H", bs, 22)
        (tot32,) = struct.unpack_from("<I", bs, 32)
        (self.fatsz32,) = struct.unpack_from("<I", bs, 36)
        (self.root_clus32,) = struct.unpack_from("<I", bs, 44)
        self.tot_sec = tot16 or tot32
        self.fatsz = self.fatsz16 or self.fatsz32
        if not (self.bytes_per_sec and self.sec_per_clus and self.fatsz and self.tot_sec):
            raise ValueError("implausible BPB — wrong offset or not FAT")

        self.root_dir_secs = (self.root_ent_cnt * 32 + self.bytes_per_sec - 1) // self.bytes_per_sec
        self.first_data_sec = self.rsvd + self.nfats * self.fatsz + self.root_dir_secs
        data_secs = self.tot_sec - self.first_data_sec
        self.n_clusters = data_secs // self.sec_per_clus
        if self.n_clusters < 4085:
            raise ValueError("FAT12 volume — not supported by this script")
        self.fat32 = self.n_clusters >= 65525
        self.fat_off = base + self.rsvd * self.bytes_per_sec

    def fat_entry(self, clus):
        if self.fat32:
            (v,) = struct.unpack_from("<I", read_at(self.f, self.fat_off + clus * 4, 4))
            return v & 0x0FFFFFFF
        (v,) = struct.unpack_from("<H", read_at(self.f, self.fat_off + clus * 2, 2))
        return v

    def is_eoc(self, v):
        return v >= (0x0FFFFFF8 if self.fat32 else 0xFFF8)

    def cluster_offset(self, clus):
        sec = self.first_data_sec + (clus - 2) * self.sec_per_clus
        return self.base + sec * self.bytes_per_sec

    def chain(self, clus, limit=1 << 20):
        out = []
        while 2 <= clus < 2 + self.n_clusters:
            out.append(clus)
            clus = self.fat_entry(clus)
            if self.is_eoc(clus) or len(out) > limit:
                break
        return out

    def read_dir_raw(self, first_clus):
        """Return (raw_bytes, n_clusters). first_clus==0 means FAT16 root."""
        if first_clus == 0 and not self.fat32:
            off = self.base + (self.rsvd + self.nfats * self.fatsz) * self.bytes_per_sec
            return read_at(self.f, off, self.root_ent_cnt * 32), 0
        if first_clus == 0:
            first_clus = self.root_clus32
        cbytes = self.sec_per_clus * self.bytes_per_sec
        chain = self.chain(first_clus)
        return b"".join(read_at(self.f, self.cluster_offset(c), cbytes) for c in chain), len(chain)


def sfn_to_str(e):
    name = e[0:8].decode("ascii", "replace").rstrip()
    ext = e[8:11].decode("ascii", "replace").rstrip()
    return f"{name}.{ext}" if ext else name


def lfn_part(e):
    chars = struct.unpack("<5H", e[1:11]) + struct.unpack("<6H", e[14:26]) + struct.unpack("<2H", e[28:32])
    out = []
    for c in chars:
        if c in (0x0000, 0xFFFF):
            break
        out.append(chr(c))
    return "".join(out)


def iter_dir(raw):
    """Yield (slot_index, kind, entry_bytes, long_name_or_None).

    kind: 'live', 'lfn', 'tomb', 'vol', 'end' (terminator; iteration stops after).
    """
    pending = {}
    for i in range(0, len(raw) // 32):
        e = raw[i * 32 : i * 32 + 32]
        b0 = e[0]
        attr = e[11]
        if b0 == 0x00:
            yield i, "end", e, None
            return
        if b0 == 0xE5:
            pending.clear()
            yield i, "tomb", e, None
        elif attr & 0x0F == 0x0F:
            pending[b0 & 0x3F] = lfn_part(e)
            yield i, "lfn", e, None
        elif attr & 0x08:
            pending.clear()
            yield i, "vol", e, None
        else:
            lname = None
            if pending:
                lname = "".join(pending[k] for k in sorted(pending))
                pending.clear()
            yield i, "live", e, lname


def entry_first_cluster(e):
    (hi,) = struct.unpack_from("<H", e, 20)
    (lo,) = struct.unpack_from("<H", e, 26)
    return (hi << 16) | lo


def resolve_path(vol, path):
    """Walk path components from the root; return first cluster of the dir."""
    clus = 0
    for comp in [c for c in path.split("/") if c]:
        raw, _ = vol.read_dir_raw(clus)
        for _, kind, e, lname in iter_dir(raw):
            if kind != "live" or not e[11] & 0x10:
                continue
            if comp.lower() in (sfn_to_str(e).lower(), (lname or "").lower()):
                clus = entry_first_cluster(e)
                break
        else:
            raise SystemExit(f"error: directory component not found: {comp!r}")
    return clus


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip())
    img, path = sys.argv[1], sys.argv[2]
    with open(img, "rb") as f:
        base = find_volume_offset(f)
        vol = Volume(f, base)
        kind = "FAT32" if vol.fat32 else "FAT16"
        print(f"{img}: {kind}, volume at {base:#x}, {vol.bytes_per_sec} B/sec, "
              f"{vol.sec_per_clus} sec/clus, {vol.n_clusters} clusters")

        clus = resolve_path(vol, path)
        raw, nclus = vol.read_dir_raw(clus)
        where = f"{nclus} cluster(s), {len(raw)} bytes" if nclus else f"fixed root region, {len(raw)} bytes"
        print(f"dir {path!r}: {where} = {len(raw) // 32} raw 32-byte slots")

        counts = {"live": 0, "lfn": 0, "tomb": 0, "vol": 0}
        last_live = -1
        term = None
        names = []
        for i, k, e, lname in iter_dir(raw):
            if k == "end":
                term = i
                break
            counts[k] += 1
            if k == "live":
                last_live = i
                names.append(lname or sfn_to_str(e))

        print(f"live entries : {counts['live']}" + (f"  (first few: {', '.join(names[:8])}…)" if names else ""))
        print(f"LFN slots    : {counts['lfn']}")
        print(f"tombstones   : {counts['tomb']}  (0xE5 deleted slots)")
        if term is not None:
            print(f"terminator   : slot {term} of {len(raw) // 32}")
            tail = term - last_live - 1
        else:
            print("terminator   : none — directory clusters are fully occupied")
            tail = (len(raw) // 32) - last_live - 1
        secs = (tail * 32 + vol.bytes_per_sec - 1) // vol.bytes_per_sec
        print(f"dead tail    : {tail} slots after the last live entry "
              f"(~{secs} sectors the final end-of-dir readdir must scan in one call)")


if __name__ == "__main__":
    main()
