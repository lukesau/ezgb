//! Package pin map: every bonded pin of a device/package with the bel pad it
//! reaches, e.g. `s3pins --bond vq100`.
use std::error::Error;
use std::path::PathBuf;

use clap::Parser;
use prjcombine_virtex2::db::Database;

#[derive(Parser)]
struct Args {
    #[arg(long, default_value = "../prjcombine/databases/spartan3.zstd")]
    db: PathBuf,
    #[arg(long, default_value = "xc3s200a")]
    device: String,
    #[arg(long, default_value = "vq100")]
    bond: String,
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = Args::parse();
    let db = Database::from_file(&args.db)?;
    let dev = db.devices.iter().find(|d| d.name == args.device).ok_or("no such device")?;
    let names: Vec<&String> = dev.bonds.keys().collect();
    let (_, bname, &bid) = dev
        .bonds
        .iter()
        .find(|(_, n, _)| n.to_lowercase().contains(&args.bond))
        .ok_or_else(|| format!("no bond {}; have {:?}", args.bond, names))?;
    eprintln!("bond {bname}");
    for (pin, pads) in &db.bonds[bid].pins {
        let p: Vec<String> = pads.iter().map(|p| p.to_string(&db.int)).collect();
        println!("{pin}\t{}", p.join(" "));
    }
    Ok(())
}
