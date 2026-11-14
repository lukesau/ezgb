//! Encode an `s3decode` feature list (full, not --baseline) back into a
//! Spartan-3A bitstream: the inverse of s3decode.
//!
//!     s3encode FEATURES.txt OUT.bin --blob-dir DIR [--check ORIG.bin]
//!
//! Each tile item is set from its feature line the way s3decode reads it; an
//! item with no line gets its all-zero raw bits. BRAM contents come from the
//! blob files `s3decode --blob-dir` wrote. The configuration registers come
//! from the `# regs:` block. The packet framing is bitgen's, which is the
//! same for every cart image we have (one FDRI run from FAR 0, no
//! compression, CRC after the frames and again after start-up).
//! With --check, the output is compared with ORIG frame by frame and byte for
//! byte.

use std::collections::{BTreeMap, HashMap, HashSet};
use std::error::Error;
use std::path::PathBuf;

use clap::Parser;
use prjcombine_entity::EntityBundleItemIndex;
use prjcombine_interconnect::db::{
    BelAttribute, BelAttributeType, BelInfo, BelInput, BelKind, IntDb, SwitchBoxItem, TileClass,
};
use prjcombine_types::bitrect::{BitRect as _, PolTileBit, TileBit};
use prjcombine_types::bitvec::BitVec;
use prjcombine_virtex2::bitstream::{BitPos, BitRect, Bitstream, Reg};
use prjcombine_virtex2::db::Database;

#[derive(Parser)]
struct Args {
    #[arg(long, default_value = "../prjcombine/databases/spartan3.zstd")]
    db: PathBuf,
    #[arg(long, default_value = "xc3s200a")]
    device: String,
    /// s3decode output (without --baseline)
    features: PathBuf,
    output: PathBuf,
    /// the blob files s3decode --blob-dir wrote (BRAM DATA/DATAP)
    #[arg(long)]
    blob_dir: PathBuf,
    /// original bitstream to compare against
    #[arg(long)]
    check: Option<PathBuf>,
}

/// Feature lines of one tile, split for lookup: `key` is the part before
/// " <- ", " ?? " or " = ", `rest` what follows it.
struct TileLines {
    whole: HashSet<String>,
    keyed: HashMap<String, String>,
    used: HashSet<String>,
}

impl TileLines {
    fn new(lines: &[String]) -> Self {
        let mut keyed = HashMap::new();
        for l in lines {
            for sep in [" <- ", " ?? ", " = "] {
                if let Some(i) = l.find(sep) {
                    keyed.insert(l[..i].to_string(), l[i + 1..].to_string());
                    break;
                }
            }
        }
        TileLines { whole: lines.iter().cloned().collect(), keyed, used: HashSet::new() }
    }

    fn has(&mut self, line: &str) -> bool {
        if self.whole.contains(line) {
            self.used.insert(line.to_string());
            true
        } else {
            false
        }
    }

    /// The rest of the line for `key`, marking the whole line used.
    fn get(&mut self, key: &str) -> Option<String> {
        let rest = self.keyed.get(key)?.clone();
        self.used.insert(format!("{key} {rest}"));
        Some(rest)
    }
}

/// "0b0101" (msb first) -> BitVec (lsb first)
fn parse_bits(s: &str, len: usize) -> Result<BitVec, Box<dyn Error>> {
    let s = s.strip_prefix("0b").ok_or_else(|| format!("bad bits {s}"))?;
    if s.len() != len {
        return Err(format!("bits {s}: expected {len}").into());
    }
    let mut v = BitVec::new();
    for c in s.chars().rev() {
        v.push(c == '1');
    }
    Ok(v)
}

struct Enc<'a> {
    bs: &'a mut Bitstream,
    rects: &'a prjcombine_entity::EntityVec<prjcombine_types::bitrect::BitRectId, BitRect>,
}

impl Enc<'_> {
    fn set(&mut self, bit: TileBit, val: bool) {
        if !val {
            return;
        }
        let pos = self.rects[bit.rect].xlat_pos_fwd((bit.frame, bit.bit));
        match pos {
            BitPos::Main(f, b) => self.bs.frame_data.set(f * self.bs.frame_len + b, true),
            BitPos::Reg(reg, b) => *self.bs.regs.entry(reg).or_default() |= 1 << b,
            BitPos::RegPresent(_) => (),
            BitPos::Fixup(..) => panic!("fixup bit on spartan3a"),
        }
    }
    fn pol(&mut self, bit: PolTileBit, val: bool) {
        self.set(bit.bit, val ^ bit.inv);
    }
    fn vec(&mut self, bits: &[TileBit], v: &BitVec) {
        for (i, &b) in bits.iter().enumerate() {
            self.set(b, v[i]);
        }
    }
}

fn encode_tile(
    db: &IntDb,
    tcls: &TileClass,
    tname: &str,
    tl: &mut TileLines,
    blob_dir: &PathBuf,
    enc: &mut Enc,
) -> Result<(), Box<dyn Error>> {
    for (slot, bel) in &tcls.bels {
        let sn = &db.bel_slots[slot].name;
        match bel {
            BelInfo::SwitchBox(sb) => {
                for item in &sb.items {
                    match item {
                        SwitchBoxItem::Mux(mux) => {
                            if mux.bits.is_empty() {
                                continue;
                            }
                            let dst = mux.dst.to_string(db, tcls);
                            let Some(rest) = tl.get(&format!("{sn} mux {dst}")) else { continue };
                            let v = if let Some(src) = rest.strip_prefix("<- ") {
                                mux.src
                                    .iter()
                                    .find(|(s, _)| s.to_string(db, tcls) == src)
                                    .ok_or_else(|| format!("{tname}: no source {src} for {dst}"))?
                                    .1
                                    .clone()
                            } else {
                                parse_bits(rest.strip_prefix("?? ").unwrap(), mux.bits.len())?
                            };
                            enc.vec(&mux.bits, &v);
                        }
                        SwitchBoxItem::ProgBuf(b) => {
                            let on = tl.has(&format!(
                                "{sn} progbuf {} <- {}",
                                b.dst.to_string(db, tcls),
                                b.src.to_string(db, tcls)
                            ));
                            enc.pol(b.bit, on);
                        }
                        SwitchBoxItem::Pass(p) => {
                            let on = tl.has(&format!(
                                "{sn} pass {} <- {}",
                                p.dst.to_string(db, tcls),
                                p.src.to_string(db, tcls)
                            ));
                            enc.pol(p.bit, on);
                        }
                        SwitchBoxItem::BiPass(p) => {
                            let on = tl.has(&format!(
                                "{sn} bipass {} <-> {}",
                                p.a.to_string(db, tcls),
                                p.b.to_string(db, tcls)
                            ));
                            enc.pol(p.bit, on);
                        }
                        SwitchBoxItem::ProgInv(p) => {
                            let on = tl.has(&format!(
                                "{sn} inv {} <- ~{}",
                                p.dst.to_string(db, tcls),
                                p.src.to_string(db, tcls)
                            ));
                            enc.pol(p.bit, on);
                        }
                        SwitchBoxItem::ProgDelay(d) => {
                            if d.bits.is_empty() {
                                continue;
                            }
                            let key = format!(
                                "{sn} delay {} <- {} step",
                                d.dst.to_string(db, tcls),
                                d.src.to_string(db, tcls)
                            );
                            let Some(rest) = tl.get(&key) else { continue };
                            let v = match rest.strip_prefix("?? ") {
                                Some(bits) => parse_bits(bits, d.bits.len())?,
                                None => d.steps[rest.parse::<usize>()?].clone(),
                            };
                            enc.vec(&d.bits, &v);
                        }
                        SwitchBoxItem::Bidi(b) => {
                            let on = tl.has(&format!(
                                "{sn} bidi {} {} upstream",
                                db.conn_slots[b.conn].name,
                                b.wire.to_string(db, tcls)
                            ));
                            enc.pol(b.bit_upstream, on);
                        }
                        SwitchBoxItem::PairMux(m) => {
                            if m.bits.is_empty() {
                                continue;
                            }
                            let key = format!(
                                "{sn} pair_mux ({}, {})",
                                m.dst[0].to_string(db, tcls),
                                m.dst[1].to_string(db, tcls)
                            );
                            let Some(rest) = tl.get(&key) else { continue };
                            let name = |s: Option<prjcombine_interconnect::db::PolTileWireCoord>| {
                                s.map_or("_".to_string(), |s| s.to_string(db, tcls))
                            };
                            let v = if let Some(src) = rest.strip_prefix("<- ") {
                                m.src
                                    .iter()
                                    .find(|(s, _)| format!("({}, {})", name(s[0]), name(s[1])) == src)
                                    .ok_or_else(|| format!("{tname}: no pair source {src}"))?
                                    .1
                                    .clone()
                            } else {
                                parse_bits(rest.strip_prefix("?? ").unwrap(), m.bits.len())?
                            };
                            enc.vec(&m.bits, &v);
                        }
                        SwitchBoxItem::WireSupport(s) => {
                            let wires: Vec<_> = s.wires.iter().map(|w| w.to_string(db, tcls)).collect();
                            if tl.has(&format!("{sn} wire_support {}", wires.join(", "))) {
                                for &b in &s.bits {
                                    enc.set(b.bit, true);
                                }
                            }
                        }
                        SwitchBoxItem::PermaBuf(_) => (),
                    }
                }
            }
            BelInfo::Bel(bel) => {
                let BelKind::Class(bcid) = db.bel_slots[slot].kind else { unreachable!() };
                let bcls = &db.bel_classes[bcid];
                for (pid, inp) in &bel.inputs {
                    if let BelInput::Invertible(_, bit) = inp {
                        let (pname, idx) = bcls.inputs.key(pid);
                        let pname = match idx {
                            EntityBundleItemIndex::Single => pname.to_string(),
                            EntityBundleItemIndex::Array { index, .. } => {
                                let index = bcls.inputs[pid].indexing.phys_to_virt(index);
                                format!("{pname}[{index}]")
                            }
                        };
                        let on = tl.has(&format!("{sn} input {pname} inverted"));
                        enc.pol(*bit, on);
                    }
                }
                for (aid, attr) in &bel.attributes {
                    let bcattr = &bcls.attributes[aid];
                    let an = &bcattr.name;
                    match attr {
                        BelAttribute::BitVec(bits) => {
                            let key = format!("{sn} {an}");
                            let mut val = BitVec::repeat(false, bits.len());
                            let mut found = false;
                            if bits.len() >= 512 {
                                if tl.get(&key).is_some() {
                                    found = true;
                                    let path = blob_dir.join(format!("{tname}.{sn}.{an}.bin"));
                                    let bytes = std::fs::read(&path)
                                        .map_err(|e| format!("{}: {e}", path.display()))?;
                                    val = BitVec::from_bytes(&bytes, bits.len());
                                }
                            } else {
                                match bcattr.typ {
                                    BelAttributeType::Bool => {
                                        if let Some(rest) = tl.get(&key) {
                                            found = true;
                                            val.set(0, rest == "= 1");
                                        }
                                    }
                                    BelAttributeType::BitVecArray(width, depth) if width * depth > 64 => {
                                        for i in 0..depth {
                                            let Some(rest) = tl.get(&format!("{key}[{i}]")) else { continue };
                                            found = true;
                                            let hex = rest.strip_prefix("= ").unwrap();
                                            let bytes: Vec<u8> = (0..hex.len() / 2)
                                                .rev()
                                                .map(|j| u8::from_str_radix(&hex[2 * j..2 * j + 2], 16))
                                                .collect::<Result<_, _>>()?;
                                            let row = BitVec::from_bytes(&bytes, width);
                                            for k in 0..width {
                                                val.set(i * width + k, row[k]);
                                            }
                                        }
                                    }
                                    _ => {
                                        if let Some(rest) = tl.get(&key) {
                                            found = true;
                                            val = parse_bits(rest.strip_prefix("= ").unwrap(), bits.len())?;
                                        }
                                    }
                                }
                            }
                            // An attribute with no line has all-zero raw bits.
                            if found {
                                for (i, &b) in bits.iter().enumerate() {
                                    enc.pol(b, val[i]);
                                }
                            }
                        }
                        BelAttribute::Enum(e) => {
                            let Some(rest) = tl.get(&format!("{sn} {an}")) else { continue };
                            let v = match rest.strip_prefix("?? ") {
                                Some(bits) => parse_bits(bits, e.bits.len())?,
                                None => {
                                    let BelAttributeType::Enum(ecid) = bcattr.typ else { unreachable!() };
                                    let ecls = &db.enum_classes[ecid];
                                    let name = rest.strip_prefix("= ").unwrap();
                                    e.values
                                        .iter()
                                        .find(|(vid, _)| ecls.values[*vid] == name)
                                        .ok_or_else(|| format!("{tname}: {an} has no value {name}"))?
                                        .1
                                        .clone()
                                }
                            };
                            enc.vec(&e.bits, &v);
                        }
                    }
                }
            }
            BelInfo::TestMux(_) | BelInfo::OldTestMux | BelInfo::Legacy(_) => (),
        }
    }
    Ok(())
}

fn reg_by_name(name: &str) -> Option<Reg> {
    use Reg::*;
    Some(match name {
        "Idcode" => Idcode,
        "Ctl0" => Ctl0,
        "Cor1" => Cor1,
        "Cor2" => Cor2,
        "RbCrcSw" => RbCrcSw,
        "CclkFrequency" => CclkFrequency,
        "Powerdown" => Powerdown,
        "HcOpt" => HcOpt,
        "PuGwe" => PuGwe,
        "PuGts" => PuGts,
        "SeuOpt" => SeuOpt,
        "Mode" => Mode,
        "General1" => General1,
        "General2" => General2,
        _ => return None,
    })
}

/// bitgen's packet stream around the frame data.
struct Writer {
    out: Vec<u8>,
    crc: prjcombine_virtex2::bitstream::packet_s3a::Crc,
}

impl Writer {
    fn word(&mut self, w: u16) {
        self.out.extend_from_slice(&w.to_be_bytes());
    }
    fn nop(&mut self) {
        self.word(0x2000);
    }
    fn write(&mut self, reg: u16, vals: &[u16]) {
        self.word(0x3000 | reg << 5 | vals.len() as u16);
        for &v in vals {
            self.word(v);
            if reg != 0 {
                self.crc.update(reg, v);
            }
        }
    }
    fn write32(&mut self, reg: u16, v: u32) {
        self.write(reg, &[(v >> 16) as u16, v as u16]);
    }
    fn cmd(&mut self, c: u16) {
        self.write(5, &[c]);
        if c == 7 {
            self.crc.reset();
        }
    }
    fn crc(&mut self) {
        let c = self.crc.get();
        self.write32(0, c);
    }
}

fn serialize(bs: &Bitstream) -> Vec<u8> {
    let reg = |r: Reg| bs.regs.get(&r).copied().unwrap_or(0);
    let mut w = Writer { out: vec![0xff; 32], crc: Default::default() };
    w.word(0xaa99);
    w.cmd(7); // RCRC
    w.nop();
    w.write(0x0b, &[reg(Reg::Cor2) as u16]);
    w.write(0x19, &[reg(Reg::CclkFrequency) as u16]);
    w.write(0x0d, &[(bs.frame_len / 16 - 1) as u16]); // FLR
    w.write(0x0a, &[reg(Reg::Cor1) as u16]);
    w.write32(0x0e, reg(Reg::Idcode));
    w.write(0x07, &[0xffcf]); // MASK, as bitgen writes it in every cart image
    w.write(0x06, &[reg(Reg::Ctl0) as u16]);
    w.write(0x0c, &[reg(Reg::Powerdown) as u16]);
    w.write(0x10, &[reg(Reg::HcOpt) as u16]);
    w.write(0x16, &[reg(Reg::PuGwe) as u16]);
    w.write(0x17, &[reg(Reg::PuGts) as u16]);
    w.write(0x15, &[reg(Reg::Mode) as u16]);
    w.write(0x13, &[reg(Reg::General1) as u16]);
    w.write(0x14, &[reg(Reg::General2) as u16]);
    w.write(0x1a, &[reg(Reg::SeuOpt) as u16]);
    w.write32(0x1b, reg(Reg::RbCrcSw));
    w.write32(0x01, 0); // FAR
    w.cmd(1); // WCFG
    // One FDRI run: every frame in FAR order, then a zero frame to flush the
    // frame buffer.
    let fw = bs.frame_len / 16;
    let nframes = bs.frame_info.len() + 1;
    w.word(0x5060);
    let n = (nframes * fw) as u32;
    w.word((n >> 16) as u16);
    w.word(n as u16);
    for fi in 0..nframes {
        for i in 0..fw {
            let mut word = 0u16;
            if fi < bs.frame_info.len() {
                let tgt = bs.frame_len - (i + 1) * 16;
                for j in 0..16 {
                    if bs.frame_data[fi * bs.frame_len + tgt + j] {
                        word |= 1 << j;
                    }
                }
            }
            w.word(word);
            w.crc.update(3, word);
        }
    }
    w.crc();
    w.cmd(10); // GRESTORE
    w.cmd(3); // DGHIGH
    for _ in 0..4 {
        w.nop();
    }
    w.cmd(5); // START
    w.write(0x07, &[0x0085]); // MASK
    w.write(0x06, &[reg(Reg::Ctl0) as u16]);
    w.crc();
    w.cmd(13); // DESYNC
    for _ in 0..16 {
        w.nop();
    }
    w.out
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
    let idb = &db.int;

    // Parse the feature list.
    let text = std::fs::read_to_string(&args.features)?;
    let mut tiles: BTreeMap<String, Vec<String>> = BTreeMap::new();
    let mut regs_listed: BTreeMap<Reg, u32> = BTreeMap::new();
    let mut cur = None;
    for line in text.lines() {
        if let Some(rest) = line.strip_prefix("tile ") {
            let name = rest.split(' ').next().unwrap().to_string();
            tiles.entry(name.clone()).or_default();
            cur = Some(name);
        } else if let Some(f) = line.strip_prefix('\t') {
            if f.starts_with("+ ") || f.starts_with("- ") {
                return Err("feature list was made with --baseline; decode without it".into());
            }
            tiles.get_mut(cur.as_ref().ok_or("feature before any tile")?).unwrap().push(f.to_string());
        } else if let Some(r) = line.strip_prefix("#\t") {
            let (name, val) = r.split_once(" = ").ok_or("bad reg line")?;
            let reg = reg_by_name(name).ok_or_else(|| format!("unknown reg {name}"))?;
            regs_listed.insert(reg, u32::from_str_radix(val.trim_start_matches("0x"), 16)?);
        }
    }

    let mut bs = edev.empty_bitstream();
    let mut leftover = 0;
    let mut seen = HashSet::new();
    for (tcrd, tile) in edev.tiles() {
        let tcls = &idb.tile_classes[tile.class];
        let rects = edev.tile_bits(tcrd);
        if rects.is_empty() {
            continue;
        }
        let tname = tcrd.to_string(idb);
        seen.insert(tname.clone());
        let lines = tiles.get(&tname).cloned().unwrap_or_default();
        let mut tl = TileLines::new(&lines);
        let mut enc = Enc { bs: &mut bs, rects: &rects };
        encode_tile(idb, tcls, &tname, &mut tl, &args.blob_dir, &mut enc)?;
        for l in &lines {
            if !tl.used.contains(l) {
                eprintln!("unused: {tname}: {l}");
                leftover += 1;
            }
        }
    }
    for t in tiles.keys() {
        if !seen.contains(t) {
            return Err(format!("unknown tile {t}").into());
        }
    }
    if leftover > 0 {
        return Err(format!("{leftover} feature lines not encoded").into());
    }
    // Registers: the listed values, which must include every bit the GLOBAL
    // features set.
    for (reg, &v) in &bs.regs {
        let l = regs_listed.get(reg).copied().unwrap_or(0);
        if v & !l != 0 {
            return Err(format!("{reg:?}: features set {v:#x}, regs list {l:#x}").into());
        }
    }
    bs.regs = regs_listed;

    let out = serialize(&bs);
    std::fs::write(&args.output, &out)?;
    println!("{} bytes, {} frames", out.len(), bs.frame_info.len());

    if let Some(orig) = &args.check {
        let data = std::fs::read(orig)?;
        let ob = edev.parse_bitstream(&data, None);
        let diff = Bitstream::diff(&ob, &bs);
        let mut n = 0;
        for (pos, val) in &diff {
            if n < 40 {
                println!("diff {pos:?} -> {val}");
            }
            n += 1;
        }
        println!("{n} config bits differ");
        let first = data.iter().zip(&out).position(|(a, b)| a != b);
        match (first, data.len() == out.len()) {
            (None, true) => println!("byte-identical to {}", orig.display()),
            (f, _) => println!(
                "bytes differ: lengths {} / {}, first difference at {:?}",
                data.len(),
                out.len(),
                f
            ),
        }
    }
    Ok(())
}
