//! Trace signals through a decoded Spartan-3A bitstream.
//!
//!     s3trace IN.bin --list-pins TILE            bel pins of the tiles named TILE...
//!     s3trace IN.bin --from TILE:BEL:PIN [--depth N]
//!
//! Builds the routing graph from every switch that is on (muxes, buffers,
//! passes, inverters, permanent buffers), resolving tile wires to physical
//! nodes with prjcombine, then walks back from a bel input pin to the bel
//! output that drives it. For a SLICE source it prints the LUT truth tables
//! and recurses into the LUT inputs, so the logic cone of a pin comes out as
//! a tree.

use std::collections::{BTreeMap, HashMap};
use std::error::Error;
use std::path::PathBuf;

use clap::Parser;
use prjcombine_entity::EntityBundleItemIndex;
use prjcombine_interconnect::db::{BelAttribute, BelInfo, BelInput, BelKind, IntDb, SwitchBoxItem};
use prjcombine_interconnect::grid::WireCoord;
use prjcombine_types::bitrect::{BitRect as _, PolTileBit, TileBit};
use prjcombine_virtex2::bitstream::{BitPos, Bitstream};
use prjcombine_virtex2::db::Database;

#[derive(Parser)]
struct Args {
    #[arg(long, default_value = "../prjcombine/databases/spartan3.zstd")]
    db: PathBuf,
    #[arg(long, default_value = "xc3s200a")]
    device: String,
    bitstream: PathBuf,
    /// print every bel pin of tiles whose name starts with this
    #[arg(long)]
    list_pins: Option<String>,
    /// TILE:BEL:PIN, a bel input to trace back from
    #[arg(long)]
    from: Vec<String>,
    #[arg(long, default_value_t = 3)]
    depth: usize,
}

#[derive(Clone)]
struct Edge {
    src: WireCoord,
    inv: bool,
    how: String,
}

struct Pin {
    tile: String,
    bel: String,
    pin: String,
}

struct Graph<'a> {
    db: &'a IntDb,
    driver: HashMap<WireCoord, Vec<Edge>>,
    out_pins: HashMap<WireCoord, Vec<Pin>>,
    /// (tile, bel) -> input pin name -> (node, inverted)
    in_pins: BTreeMap<(String, String), BTreeMap<String, (WireCoord, bool)>>,
    /// (tile, bel) -> attribute name -> value string
    attrs: BTreeMap<(String, String), BTreeMap<String, String>>,
}

fn pin_name(name: &str, idx: EntityBundleItemIndex) -> String {
    match idx {
        EntityBundleItemIndex::Single => name.to_string(),
        EntityBundleItemIndex::Array { index, .. } => format!("{name}[{index}]"),
    }
}

fn get(bs: &Bitstream, rects: &prjcombine_entity::EntityVec<prjcombine_types::bitrect::BitRectId, prjcombine_virtex2::bitstream::BitRect>, b: TileBit) -> bool {
    let pos: BitPos = rects[b.rect].xlat_pos_fwd((b.frame, b.bit));
    bs.get_bit(pos)
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = Args::parse();
    let db = Database::from_file(&args.db)?;
    let dev = db.devices.iter().find(|d| d.name == args.device).ok_or("no such device")?;
    let edev = db.chips[dev.chip].expand_grid(&db.int);
    let data = std::fs::read(&args.bitstream)?;
    let bs = edev.parse_bitstream(&data, None);
    let idb = &db.int;
    let mut g = Graph { db: idb, driver: HashMap::new(), out_pins: HashMap::new(), in_pins: BTreeMap::new(), attrs: BTreeMap::new() };

    for (tcrd, tile) in edev.tiles() {
        let tcls = &idb.tile_classes[tile.class];
        let rects = edev.tile_bits(tcrd);
        let tname = tcrd.to_string(idb);
        let node = |tw| edev.resolve_wire(edev.tile_wire(tcrd, tw));
        let on = |b: PolTileBit| !rects.is_empty() && (get(&bs, &rects, b.bit) ^ b.inv);
        for (slot, bel) in &tcls.bels {
            let slot_name = idb.bel_slots[slot].name.clone();
            match bel {
                BelInfo::SwitchBox(sb) => {
                    for item in &sb.items {
                        let mut add = |dst, src, inv, how: String| {
                            if let (Some(d), Some(s)) = (node(dst), node(src)) {
                                g.driver.entry(d).or_default().push(Edge { src: s, inv, how });
                            }
                        };
                        match item {
                            SwitchBoxItem::Mux(m) => {
                                if m.bits.is_empty() || rects.is_empty() {
                                    continue;
                                }
                                let v: Vec<bool> = m.bits.iter().map(|&b| get(&bs, &rects, b)).collect();
                                if !v.iter().any(|&x| x) {
                                    continue;
                                }
                                for (src, pat) in &m.src {
                                    let p: Vec<bool> = pat.iter().collect();
                                    if p == v {
                                        add(m.dst, src.tw, src.inv, format!("{tname} mux {} <- {}", m.dst.to_string(idb, tcls), src.to_string(idb, tcls)));
                                    }
                                }
                            }
                            SwitchBoxItem::ProgBuf(b) if on(b.bit) => add(b.dst, b.src.tw, b.src.inv, format!("{tname} buf")),
                            SwitchBoxItem::PermaBuf(b) => add(b.dst, b.src.tw, b.src.inv, format!("{tname} permabuf")),
                            SwitchBoxItem::Pass(p) if on(p.bit) => add(p.dst, p.src, false, format!("{tname} pass")),
                            SwitchBoxItem::ProgInv(p) => {
                                let inv = on(p.bit);
                                add(p.dst, p.src, inv, format!("{tname} inv?{inv}"));
                            }
                            SwitchBoxItem::BiPass(p) if on(p.bit) => {
                                add(p.a, p.b, false, format!("{tname} bipass"));
                                add(p.b, p.a, false, format!("{tname} bipass"));
                            }
                            _ => (),
                        }
                    }
                }
                BelInfo::Bel(b) => {
                    let BelKind::Class(bcid) = idb.bel_slots[slot].kind else { continue };
                    let bcls = &idb.bel_classes[bcid];
                    for (oid, wires) in &b.outputs {
                        let (n, i) = bcls.outputs.key(oid);
                        for &tw in wires {
                            if let Some(w) = node(tw) {
                                g.out_pins.entry(w).or_default().push(Pin { tile: tname.clone(), bel: slot_name.clone(), pin: pin_name(n, i) });
                            }
                        }
                    }
                    for (iid, inp) in &b.inputs {
                        let (n, i) = bcls.inputs.key(iid);
                        let (tw, inv) = match inp {
                            BelInput::Fixed(p) => (p.tw, p.inv),
                            BelInput::Invertible(tw, bit) => (*tw, on(*bit)),
                        };
                        if let Some(w) = node(tw) {
                            g.in_pins.entry((tname.clone(), slot_name.clone())).or_default().insert(pin_name(n, i), (w, inv));
                        }
                    }
                    if !rects.is_empty() {
                        let mut am = BTreeMap::new();
                        for (aid, a) in &b.attributes {
                            let name = &bcls.attributes[aid].name;
                            if let BelAttribute::BitVec(bits) = a {
                                if bits.len() <= 64 {
                                    let s: String = bits.iter().rev().map(|&pb| if get(&bs, &rects, pb.bit) ^ pb.inv { '1' } else { '0' }).collect();
                                    am.insert(name.clone(), s);
                                }
                            }
                            if let BelAttribute::Enum(e) = a {
                                let v: Vec<bool> = e.bits.iter().map(|&b| get(&bs, &rects, b)).collect();
                                let prjcombine_interconnect::db::BelAttributeType::Enum(ecid) = bcls.attributes[aid].typ else { continue };
                                for (vid, pat) in &e.values {
                                    if pat.iter().collect::<Vec<_>>() == v {
                                        am.insert(name.clone(), idb.enum_classes[ecid].values[vid].clone());
                                    }
                                }
                            }
                        }
                        g.attrs.insert((tname.clone(), slot_name.clone()), am);
                    }
                }
                _ => (),
            }
        }
    }

    if let Some(prefix) = &args.list_pins {
        for ((t, b), pins) in &g.in_pins {
            if t.starts_with(prefix.as_str()) {
                println!("{t} {b} inputs: {}", pins.keys().cloned().collect::<Vec<_>>().join(" "));
            }
        }
        for (_, pins) in &g.out_pins {
            for p in pins {
                if p.tile.starts_with(prefix.as_str()) {
                    println!("{} {} output {}", p.tile, p.bel, p.pin);
                }
            }
        }
    }
    for f in &args.from {
        let parts: Vec<&str> = f.splitn(3, ':').collect();
        let [t, b, p] = parts[..] else { return Err("--from TILE:BEL:PIN".into()) };
        let Some(&(w, inv)) = g.in_pins.get(&(t.to_string(), b.to_string())).and_then(|m| m.get(p)) else {
            return Err(format!("no input pin {f}").into());
        };
        println!("== {f}{}", if inv { " (inverted at the pin)" } else { "" });
        trace(&g, w, 1, args.depth, &mut vec![]);
    }
    Ok(())
}

fn trace(g: &Graph, mut w: WireCoord, level: usize, depth: usize, seen: &mut Vec<WireCoord>) {
    let pad = "  ".repeat(level);
    let mut hops = 0;
    let mut inv = false;
    loop {
        if let Some(pins) = g.out_pins.get(&w) {
            for p in pins {
                let a = g.attrs.get(&(p.tile.clone(), p.bel.clone()));
                println!("{pad}<- {} {} {} ({hops} hops{})", p.tile, p.bel, p.pin, if inv { ", inverted" } else { "" });
                if p.bel.starts_with("SLICE") && level < depth {
                    if seen.contains(&w) {
                        println!("{pad}   (loop)");
                        continue;
                    }
                    seen.push(w);
                    if let Some(a) = a {
                        let lut = if p.pin.starts_with('X') || p.pin == "F5" { "F" } else { "G" };
                        if let Some(v) = a.get(lut) {
                            println!("{pad}   LUT {lut} = {v}");
                        }
                        for k in ["DXMUX", "DYMUX", "FXMUX", "GYMUX", "XBMUX", "YBMUX"] {
                            if let Some(v) = a.get(k) {
                                print!("{pad}   {k}={v} ");
                            }
                        }
                        println!();
                        let ins = &g.in_pins[&(p.tile.clone(), p.bel.clone())];
                        let prefix = if lut == "F" { "F" } else { "G" };
                        let mut names: Vec<&String> = ins.keys().filter(|k| (k.len() == 2 && k.starts_with(prefix))).collect();
                        if p.pin.ends_with('Q') {
                            names = ins.keys().filter(|k| ["BX", "BY", "CLK", "CE", "SR"].contains(&k.as_str()) || (k.len() == 2 && k.starts_with(prefix))).collect();
                        }
                        for n in names {
                            let (iw, iinv) = ins[n];
                            println!("{pad}   {n}{}:", if iinv { " (inv)" } else { "" });
                            trace(g, iw, level + 2, depth, seen);
                        }
                    }
                    seen.pop();
                }
            }
            return;
        }
        match g.driver.get(&w) {
            Some(edges) if edges.len() == 1 => {
                inv ^= edges[0].inv;
                w = edges[0].src;
                hops += 1;
                if hops > 200 {
                    println!("{pad}?? routing loop");
                    return;
                }
            }
            Some(edges) => {
                println!("{pad}?? {} drivers: {}", edges.len(), edges.iter().map(|e| e.how.clone()).collect::<Vec<_>>().join(" | "));
                return;
            }
            None => {
                println!("{pad}?? undriven ({hops} hops) {}", w.to_string(g.db));
                return;
            }
        }
    }
}
