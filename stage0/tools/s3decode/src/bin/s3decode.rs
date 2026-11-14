//! Decode a Spartan-3A bitstream into a list of configured features, using the
//! prjcombine `spartan3` database.  Prints every routing mux / buffer that is on,
//! every bel attribute whose bits are not all zero, and every set bit that no
//! database item claims.

use std::collections::{BTreeMap, HashSet};
use std::error::Error;
use std::path::PathBuf;

use clap::Parser;
use prjcombine_entity::EntityBundleItemIndex;
use prjcombine_interconnect::db::{
    BelAttribute, BelAttributeType, BelInfo, BelInput, BelKind, IntDb, SwitchBoxItem, TileClass,
};
use prjcombine_types::bitrect::{BitRect as _, PolTileBit, TileBit};
use prjcombine_types::bitvec::BitVec;
use prjcombine_virtex2::bitstream::{BitPos, BitRect, Bitstream};
use prjcombine_virtex2::db::Database;

#[derive(Parser)]
struct Args {
    /// prjcombine spartan3.zstd database
    #[arg(long, default_value = "../prjcombine/databases/spartan3.zstd")]
    db: PathBuf,
    /// device name, e.g. xc3s200a
    #[arg(long, default_value = "xc3s200a")]
    device: String,
    /// .bit file, or raw config data starting with the 0xff dummy words
    bitstream: PathBuf,
    /// also print bel attributes whose bits are all zero
    #[arg(long)]
    all: bool,
    /// blank-design bitstream; only print features that differ from it
    #[arg(long)]
    baseline: Option<PathBuf>,
    /// write large attributes (BRAM DATA/DATAP) as binary files here
    #[arg(long)]
    blob_dir: Option<PathBuf>,
}

struct Decoded {
    bs: Bitstream,
    /// tile name -> (tile class, features)
    tiles: BTreeMap<String, (String, Vec<String>)>,
    blobs: Vec<(String, Vec<u8>)>,
    claimed: HashSet<BitPos>,
}

fn decode(
    edev: &prjcombine_virtex2::expanded::ExpandedDevice,
    db: &IntDb,
    path: &PathBuf,
    all: bool,
) -> Result<Decoded, Box<dyn Error>> {
    let file = std::fs::read(path)?;
    let data = config_data(&file)?;
    let bs = edev.parse_bitstream(data, None);
    let mut claimed = HashSet::new();
    let mut tiles = BTreeMap::new();
    let mut blobs = vec![];
    for (tcrd, tile) in edev.tiles() {
        let tcls = &db.tile_classes[tile.class];
        let rects = edev.tile_bits(tcrd);
        if rects.is_empty() {
            continue;
        }
        let mut ctx = TileCtx {
            bs: &bs,
            blobs: vec![],
            rects: &rects,
            claimed: &mut claimed,
        };
        let mut out = vec![];
        decode_tile(db, tcls, &mut ctx, all, &mut out);
        let tname = tcrd.to_string(db);
        for (n, b) in ctx.blobs {
            blobs.push((format!("{tname}.{n}"), b));
        }
        tiles.insert(tname, (tcls.name.clone(), out));
    }
    Ok(Decoded { bs, tiles, blobs, claimed })
}

/// Strip the Xilinx .bit header if present and return the raw config data.
fn config_data(file: &[u8]) -> Result<&[u8], Box<dyn Error>> {
    if file.first() == Some(&0xff) {
        return Ok(file);
    }
    // header: 2-byte len + magic, 2-byte 0x0001, then tagged fields 'a'..'d'
    // (2-byte len each), then 'e' with a 4-byte len followed by the data.
    let mut pos = 2 + u16::from_be_bytes([file[0], file[1]]) as usize;
    pos += 2;
    loop {
        let tag = *file.get(pos).ok_or("truncated .bit header")?;
        pos += 1;
        if tag == b'e' {
            let len = u32::from_be_bytes(file[pos..pos + 4].try_into()?) as usize;
            pos += 4;
            return Ok(&file[pos..pos + len]);
        }
        let len = u16::from_be_bytes([file[pos], file[pos + 1]]) as usize;
        pos += 2 + len;
    }
}

struct TileCtx<'a> {
    bs: &'a Bitstream,
    /// large bitvec attributes (BRAM contents): (name, bytes, lsb-first)
    blobs: Vec<(String, Vec<u8>)>,
    rects: &'a prjcombine_entity::EntityVec<prjcombine_types::bitrect::BitRectId, BitRect>,
    claimed: &'a mut HashSet<BitPos>,
}

impl TileCtx<'_> {
    fn pos(&self, bit: TileBit) -> BitPos {
        self.rects[bit.rect].xlat_pos_fwd((bit.frame, bit.bit))
    }

    fn raw(&mut self, bit: TileBit) -> bool {
        let pos = self.pos(bit);
        self.claimed.insert(pos);
        self.bs.get_bit(pos)
    }

    fn pol(&mut self, bit: PolTileBit) -> (bool, bool) {
        let raw = self.raw(bit.bit);
        (raw, raw ^ bit.inv)
    }

    fn vec(&mut self, bits: &[TileBit]) -> BitVec {
        let mut v = BitVec::new();
        for &b in bits {
            v.push(self.raw(b));
        }
        v
    }
}

fn bitvec_str(v: &BitVec) -> String {
    // msb first, like the database dump
    v.iter().rev().map(|b| if b { '1' } else { '0' }).collect()
}

fn decode_tile(
    db: &IntDb,
    tcls: &TileClass,
    ctx: &mut TileCtx,
    all: bool,
    out: &mut Vec<String>,
) {
    for (slot, bel) in &tcls.bels {
        let slot_name = &db.bel_slots[slot].name;
        match bel {
            BelInfo::SwitchBox(sb) => {
                for item in &sb.items {
                    match item {
                        SwitchBoxItem::Mux(mux) => {
                            if mux.bits.is_empty() {
                                continue;
                            }
                            let v = ctx.vec(&mux.bits);
                            if !v.any() || mux.bits_off.as_ref() == Some(&v) {
                                continue;
                            }
                            let dst = mux.dst.to_string(db, tcls);
                            match mux.src.iter().find(|(_, pat)| **pat == v) {
                                Some((src, _)) => out.push(format!(
                                    "{slot_name} mux {dst} <- {}",
                                    src.to_string(db, tcls)
                                )),
                                None => out.push(format!(
                                    "{slot_name} mux {dst} ?? 0b{}",
                                    bitvec_str(&v)
                                )),
                            }
                        }
                        SwitchBoxItem::ProgBuf(b) => {
                            if ctx.pol(b.bit).1 {
                                out.push(format!(
                                    "{slot_name} progbuf {} <- {}",
                                    b.dst.to_string(db, tcls),
                                    b.src.to_string(db, tcls)
                                ));
                            }
                        }
                        SwitchBoxItem::Pass(p) => {
                            if ctx.pol(p.bit).1 {
                                out.push(format!(
                                    "{slot_name} pass {} <- {}",
                                    p.dst.to_string(db, tcls),
                                    p.src.to_string(db, tcls)
                                ));
                            }
                        }
                        SwitchBoxItem::BiPass(p) => {
                            if ctx.pol(p.bit).1 {
                                out.push(format!(
                                    "{slot_name} bipass {} <-> {}",
                                    p.a.to_string(db, tcls),
                                    p.b.to_string(db, tcls)
                                ));
                            }
                        }
                        SwitchBoxItem::ProgInv(p) => {
                            if ctx.pol(p.bit).1 {
                                out.push(format!(
                                    "{slot_name} inv {} <- ~{}",
                                    p.dst.to_string(db, tcls),
                                    p.src.to_string(db, tcls)
                                ));
                            }
                        }
                        SwitchBoxItem::ProgDelay(d) => {
                            if d.bits.is_empty() {
                                continue;
                            }
                            let v = ctx.vec(&d.bits);
                            if !v.any() {
                                continue;
                            }
                            let step = d.steps.iter().position(|s| *s == v);
                            out.push(format!(
                                "{slot_name} delay {} <- {} step {}",
                                d.dst.to_string(db, tcls),
                                d.src.to_string(db, tcls),
                                step.map_or(format!("?? 0b{}", bitvec_str(&v)), |s| s.to_string())
                            ));
                        }
                        SwitchBoxItem::Bidi(b) => {
                            if ctx.pol(b.bit_upstream).1 {
                                out.push(format!(
                                    "{slot_name} bidi {} {} upstream",
                                    db.conn_slots[b.conn].name,
                                    b.wire.to_string(db, tcls)
                                ));
                            }
                        }
                        SwitchBoxItem::PairMux(m) => {
                            if m.bits.is_empty() {
                                continue;
                            }
                            let v = ctx.vec(&m.bits);
                            if !v.any() {
                                continue;
                            }
                            let name = |s: Option<prjcombine_interconnect::db::PolTileWireCoord>| {
                                s.map_or("_".to_string(), |s| s.to_string(db, tcls))
                            };
                            match m.src.iter().find(|(_, pat)| **pat == v) {
                                Some((src, _)) => out.push(format!(
                                    "{slot_name} pair_mux ({}, {}) <- ({}, {})",
                                    m.dst[0].to_string(db, tcls),
                                    m.dst[1].to_string(db, tcls),
                                    name(src[0]),
                                    name(src[1])
                                )),
                                None => out.push(format!(
                                    "{slot_name} pair_mux ({}, {}) ?? 0b{}",
                                    m.dst[0].to_string(db, tcls),
                                    m.dst[1].to_string(db, tcls),
                                    bitvec_str(&v)
                                )),
                            }
                        }
                        SwitchBoxItem::WireSupport(s) => {
                            let mut on = false;
                            for &b in &s.bits {
                                on |= ctx.pol(b).0;
                            }
                            if on {
                                let wires: Vec<_> =
                                    s.wires.iter().map(|w| w.to_string(db, tcls)).collect();
                                out.push(format!(
                                    "{slot_name} wire_support {}",
                                    wires.join(", ")
                                ));
                            }
                        }
                        SwitchBoxItem::PermaBuf(_) => (),
                    }
                }
            }
            BelInfo::Bel(bel) => {
                let BelKind::Class(bcid) = db.bel_slots[slot].kind else {
                    unreachable!()
                };
                let bcls = &db.bel_classes[bcid];
                for (pid, inp) in &bel.inputs {
                    if let BelInput::Invertible(_, bit) = inp {
                        if ctx.pol(*bit).1 {
                            let (pname, idx) = bcls.inputs.key(pid);
                            let pname = match idx {
                                EntityBundleItemIndex::Single => pname.to_string(),
                                EntityBundleItemIndex::Array { index, .. } => {
                                    let index = bcls.inputs[pid].indexing.phys_to_virt(index);
                                    format!("{pname}[{index}]")
                                }
                            };
                            out.push(format!("{slot_name} input {pname} inverted"));
                        }
                    }
                }
                for (aid, attr) in &bel.attributes {
                    let bcattr = &bcls.attributes[aid];
                    let aname = &bcattr.name;
                    match attr {
                        BelAttribute::BitVec(bits) => {
                            let mut raw_any = false;
                            let mut v = BitVec::new();
                            for &b in bits {
                                let (raw, val) = ctx.pol(b);
                                raw_any |= raw;
                                v.push(val);
                            }
                            if !raw_any && !all {
                                continue;
                            }
                            if v.len() >= 512 {
                                let bytes = v.to_bytes();
                                let nz = bytes.iter().filter(|&&b| b != 0).count();
                                out.push(format!(
                                    "{slot_name} {aname} = <{} bytes, {nz} nonzero, fnv {:016x}>",
                                    bytes.len(),
                                    bytes.iter().fold(0xcbf29ce484222325u64, |h, &b| (h ^ b as u64).wrapping_mul(0x100000001b3))
                                ));
                                ctx.blobs.push((format!("{slot_name}.{aname}"), bytes));
                                continue;
                            }
                            match bcattr.typ {
                                BelAttributeType::Bool => {
                                    out.push(format!("{slot_name} {aname} = {}", v[0] as u8))
                                }
                                BelAttributeType::BitVecArray(width, depth) if width * depth > 64 => {
                                    // BRAM init data etc: print as hex rows, msb first
                                    for i in 0..depth {
                                        let row = v.slice(i * width..(i + 1) * width);
                                        if row.any() || all {
                                            let bytes = row.to_bytes();
                                            let hex: String =
                                                bytes.iter().rev().map(|b| format!("{b:02x}")).collect();
                                            out.push(format!("{slot_name} {aname}[{i}] = {hex}"));
                                        }
                                    }
                                }
                                _ => out.push(format!(
                                    "{slot_name} {aname} = 0b{}",
                                    bitvec_str(&v)
                                )),
                            }
                        }
                        BelAttribute::Enum(e) => {
                            let v = ctx.vec(&e.bits);
                            if !v.any() && !all {
                                continue;
                            }
                            let BelAttributeType::Enum(ecid) = bcattr.typ else {
                                unreachable!()
                            };
                            let ecls = &db.enum_classes[ecid];
                            match e.values.iter().find(|(_, pat)| **pat == v) {
                                Some((vid, _)) => out.push(format!(
                                    "{slot_name} {aname} = {}",
                                    ecls.values[vid]
                                )),
                                None => out.push(format!(
                                    "{slot_name} {aname} ?? 0b{}",
                                    bitvec_str(&v)
                                )),
                            }
                        }
                    }
                }
            }
            BelInfo::TestMux(_) | BelInfo::OldTestMux | BelInfo::Legacy(_) => (),
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = Args::parse();
    let db = Database::from_file(&args.db)?;
    let dev = db
        .devices
        .iter()
        .find(|d| d.name == args.device)
        .ok_or_else(|| format!("device {} not in database", args.device))?;
    let chip = &db.chips[dev.chip];
    let edev = chip.expand_grid(&db.int);

    let dec = decode(&edev, &db.int, &args.bitstream, args.all)?;
    let base = match &args.baseline {
        Some(p) => Some(decode(&edev, &db.int, p, args.all)?),
        None => None,
    };
    let mut total_items = 0;
    for (tname, (cname, feats)) in &dec.tiles {
        let lines: Vec<String> = match &base {
            None => feats.clone(),
            Some(base) => {
                let bfeats: HashSet<&String> = base.tiles[tname].1.iter().collect();
                let feats_set: HashSet<&String> = feats.iter().collect();
                let mut l: Vec<String> = feats
                    .iter()
                    .filter(|f| !bfeats.contains(f))
                    .map(|f| format!("+ {f}"))
                    .collect();
                l.extend(
                    base.tiles[tname]
                        .1
                        .iter()
                        .filter(|f| !feats_set.contains(f))
                        .map(|f| format!("- {f}")),
                );
                l
            }
        };
        if !lines.is_empty() {
            println!("tile {tname} {cname}");
            for line in &lines {
                println!("\t{line}");
            }
            total_items += lines.len();
        }
    }
    let bs = &dec.bs;
    let claimed = &dec.claimed;
    if let Some(dir) = &args.blob_dir {
        std::fs::create_dir_all(dir)?;
        for (name, bytes) in &dec.blobs {
            std::fs::write(dir.join(format!("{name}.bin")), bytes)?;
        }
    }

    // set bits nobody claimed
    let mut unknown: BTreeMap<usize, Vec<usize>> = BTreeMap::new();
    for (frame, _) in bs.frame_info.iter().enumerate() {
        for bit in 0..bs.frame_len {
            let pos = BitPos::Main(frame, bit);
            if bs.get_bit(pos) && !claimed.contains(&pos) {
                unknown.entry(frame).or_default().push(bit);
            }
        }
    }
    let n_unknown: usize = unknown.values().map(|v| v.len()).sum();
    println!();
    println!("# regs:");
    for (reg, val) in &bs.regs {
        println!("#\t{reg:?} = {val:#06x}");
    }
    println!(
        "# {total_items} features, {} claimed bit positions, {n_unknown} set bits unclaimed",
        claimed.len()
    );
    for (frame, bits) in &unknown {
        let fi = bs.frame_info[*frame];
        println!(
            "# unclaimed frame {frame} (type {} major {} minor {}): {bits:?}",
            fi.typ, fi.major, fi.minor
        );
    }
    Ok(())
}
