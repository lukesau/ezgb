//! Patch bel attribute contents (BRAM DATA etc.) in a Spartan-3A bitstream.
//!
//!     s3patch IN.bin OUT.bin --set D0X19Y5.BEL:BRAM:DATA=plane0.bin [--set ...]
//!
//! Each value file holds the attribute's logical bits, bit i = byte i/8 bit
//! i%8 (the format `s3decode --blob-dir` writes). Only frames written by a
//! plain FDRI run are patched; a frame that is reused through MFWR is
//! refused. Every CRC packet is recomputed. The output is re-parsed and must
//! differ from the input in exactly the requested bits.

use std::collections::{BTreeMap, HashMap};
use std::error::Error;
use std::path::PathBuf;

use clap::Parser;
use prjcombine_interconnect::db::{BelAttribute, BelInfo, BelKind};
use prjcombine_types::bitrect::BitRect as _;
use prjcombine_virtex2::bitstream::BitPos;
use prjcombine_virtex2::db::Database;

#[derive(Parser)]
struct Args {
    #[arg(long, default_value = "../prjcombine/databases/spartan3.zstd")]
    db: PathBuf,
    #[arg(long, default_value = "xc3s200a")]
    device: String,
    input: PathBuf,
    output: PathBuf,
    /// TILE:BELSLOT:ATTR=FILE, e.g. D0X19Y5.BEL:BRAM:DATA=plane0.bin
    #[arg(long = "set", required = true)]
    sets: Vec<String>,
}

const SYNC: [u8; 2] = [0xaa, 0x99];

struct Crc(u32);
impl Crc {
    fn update(&mut self, reg: u16, val: u16) {
        let data = (val as u32) | (reg as u32) << 16;
        self.0 <<= 1;
        if self.0 & 0x400000 != 0 {
            self.0 ^= 0x409081;
        }
        self.0 ^= data;
    }
}

fn be16(d: &[u8], p: usize) -> u16 {
    u16::from_be_bytes([d[p], d[p + 1]])
}

/// FDRI runs: (first frame index, payload byte offset, frame count) and the
/// set of frame indices written by MFWR.
fn layout(
    data: &[u8],
    far_dict: &HashMap<u32, usize>,
    frame_bytes: usize,
) -> (Vec<(usize, usize, usize)>, Vec<usize>) {
    let mut pos = data.windows(2).position(|w| w == SYNC).unwrap() + 2;
    let mut far = 0u32;
    let mut runs = vec![];
    let mut mfwr = vec![];
    while pos + 2 <= data.len() {
        let ph = be16(data, pos);
        pos += 2;
        if ph == 0x2000 {
            continue;
        }
        if ph >> 11 == 6 {
            let reg = ph >> 5 & 0x3f;
            let num = (ph & 0x1f) as usize;
            if reg == 1 && num == 2 {
                far = u32::from_be_bytes(data[pos..pos + 4].try_into().unwrap());
            }
            if reg == 0x18 {
                mfwr.push(far_dict[&far]);
            }
            pos += num * 2;
        } else if ph >> 11 == 0xa {
            let reg = ph >> 5 & 0x3f;
            let num = u32::from_be_bytes(data[pos..pos + 4].try_into().unwrap()) as usize;
            pos += 4;
            if reg == 3 {
                let frames = num * 2 / frame_bytes;
                // the last frame of a run is the pipeline frame, not stored at fi+frames-1
                runs.push((far_dict[&far], pos, frames - 1));
            }
            pos += num * 2;
        } else {
            panic!("unexpected packet header {ph:04x} at {:#x}", pos - 2);
        }
    }
    (runs, mfwr)
}

/// Recompute every CRC packet in place. Returns how many were rewritten.
fn fix_crc(data: &mut [u8]) -> usize {
    let mut pos = data.windows(2).position(|w| w == SYNC).unwrap() + 2;
    let mut crc = Crc(0);
    let mut bypass = false;
    let mut fixed = 0;
    while pos + 2 <= data.len() {
        let ph = be16(data, pos);
        pos += 2;
        if ph == 0x2000 {
            continue;
        }
        if ph >> 11 == 6 {
            let reg = ph >> 5 & 0x3f;
            let num = (ph & 0x1f) as usize;
            if !matches!(reg, 0 | 9 | 0x12) {
                for i in 0..num {
                    crc.update(reg, be16(data, pos + i * 2));
                }
            }
            if reg == 0 && num == 2 && !bypass {
                let want = crc.0;
                data[pos..pos + 4].copy_from_slice(&want.to_be_bytes());
                fixed += 1;
            }
            if reg == 5 && num == 1 && be16(data, pos) == 7 {
                crc = Crc(0);
            }
            if reg == 0xa && num == 1 {
                bypass = be16(data, pos) & 0x10 != 0;
            }
            pos += num * 2;
        } else if ph >> 11 == 0xa {
            let reg = ph >> 5 & 0x3f;
            let num = u32::from_be_bytes(data[pos..pos + 4].try_into().unwrap()) as usize;
            pos += 4;
            for i in 0..num {
                crc.update(reg, be16(data, pos + i * 2));
            }
            pos += num * 2;
        } else {
            panic!("unexpected packet header {ph:04x}");
        }
    }
    fixed
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = Args::parse();
    let db = Database::from_file(&args.db)?;
    let dev = db.devices.iter().find(|d| d.name == args.device).ok_or("no such device")?;
    let edev = db.chips[dev.chip].expand_grid(&db.int);
    let input = std::fs::read(&args.input)?;
    assert_eq!(input[0], 0xff, "raw config data expected (extract-bitstreams.py output)");
    let bs = edev.parse_bitstream(&input, None);
    let frame_len = bs.frame_len;
    let frame_bytes = frame_len / 8;

    // requested bits -> wanted raw value
    let mut want: BTreeMap<(usize, usize), bool> = BTreeMap::new();
    for s in &args.sets {
        let (lhs, path) = s.split_once('=').ok_or("--set needs =")?;
        let parts: Vec<&str> = lhs.split(':').collect();
        let [tname, slot, attr] = parts[..] else { return Err("--set TILE:BELSLOT:ATTR=FILE".into()) };
        let value = std::fs::read(path)?;
        let (tcrd, tile) = edev
            .tiles()
            .find(|(t, _)| t.to_string(&db.int) == tname)
            .ok_or_else(|| format!("no tile {tname}"))?;
        let tcls = &db.int.tile_classes[tile.class];
        let rects = edev.tile_bits(tcrd);
        let (bslot, binfo) = tcls
            .bels
            .iter()
            .find(|(b, _)| db.int.bel_slots[*b].name == slot)
            .ok_or_else(|| format!("no bel {slot} in {tname}"))?;
        let BelInfo::Bel(bel) = binfo else { return Err("not a bel".into()) };
        let BelKind::Class(bcid) = db.int.bel_slots[bslot].kind else { unreachable!() };
        let bcls = &db.int.bel_classes[bcid];
        let (aid, _) = bcls
            .attributes
            .iter()
            .find(|(_, a)| a.name == attr)
            .ok_or_else(|| format!("no attribute {attr}"))?;
        let BelAttribute::BitVec(bits) = &bel.attributes[aid] else { return Err("not a bitvec attribute".into()) };
        assert_eq!(value.len() * 8, bits.len(), "{path}: wrong size for {attr}");
        for (i, pb) in bits.iter().enumerate() {
            let BitPos::Main(f, b) = rects[pb.bit.rect].xlat_pos_fwd((pb.bit.frame, pb.bit.bit)) else {
                return Err("attribute bit outside main frames".into());
            };
            let logical = value[i / 8] >> (i % 8) & 1 != 0;
            want.insert((f, b), logical ^ pb.inv);
        }
    }

    let far_dict: HashMap<u32, usize> = bs
        .frame_info
        .iter()
        .enumerate()
        .map(|(i, a)| (a.minor | a.major << 16 | a.typ << 26, i))
        .collect();
    let (runs, mfwr) = layout(&input, &far_dict, frame_bytes);
    let mut out = input.clone();
    let mut changed = 0;
    for (&(f, b), &v) in &want {
        if bs.get_bit(BitPos::Main(f, b)) == v {
            continue;
        }
        if mfwr.contains(&f) {
            return Err(format!("frame {f} is written by MFWR; refusing to patch").into());
        }
        let &(f0, off, _) = runs
            .iter()
            .find(|(f0, _, n)| f >= *f0 && f < f0 + n)
            .ok_or_else(|| format!("frame {f} not in any FDRI run"))?;
        // insert_spartan3a_frame: word i (big endian) holds bits frame_len-(i+1)*16 ..
        let word = (frame_len - 1 - b) / 16;
        let j = b - (frame_len - (word + 1) * 16);
        let byte = off + (f - f0) * frame_bytes + word * 2 + if j >= 8 { 0 } else { 1 };
        out[byte] ^= 1 << (j % 8);
        changed += 1;
    }
    let crcs = fix_crc(&mut out);

    // verify by re-parsing
    let bs2 = edev.parse_bitstream(&out, None);
    let mut diff = 0;
    for f in 0..bs.frame_info.len() {
        for b in 0..frame_len {
            let (x, y) = (bs.get_bit(BitPos::Main(f, b)), bs2.get_bit(BitPos::Main(f, b)));
            if x != y {
                diff += 1;
                assert_eq!(want.get(&(f, b)), Some(&y), "unexpected change at frame {f} bit {b}");
            }
        }
    }
    for (&(f, b), &v) in &want {
        assert_eq!(bs2.get_bit(BitPos::Main(f, b)), v, "frame {f} bit {b} not as requested");
    }
    assert_eq!(bs.regs.get(&prjcombine_virtex2::bitstream::Reg::Cor1), bs2.regs.get(&prjcombine_virtex2::bitstream::Reg::Cor1));
    std::fs::write(&args.output, &out)?;
    println!(
        "{} attribute bits requested, {changed} flipped, {diff} frame bits differ after re-parse, {crcs} CRC packets recomputed",
        want.len()
    );
    Ok(())
}
