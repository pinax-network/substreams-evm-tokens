use std::io::Write;
use std::path::Path;
use std::process::Command;
use std::{env, fs};
use substreams_ethereum::Abigen;

fn main() -> Result<(), anyhow::Error> {
    let out_dir = env::var_os("OUT_DIR").unwrap();
    let dest_path = Path::new(&out_dir).join("abi.rs");
    
    // Generate bindings for the ENS Public Resolver contract
    Abigen::new("resolver", "abi/PublicResolver.json")?
        .generate()?
        .write_to_file("src/abi/resolver.rs")?;

    // Generate bindings for the ENS Reverse Registrar contract
    Abigen::new("reverse_registrar", "abi/ReverseRegistrar.json")?
        .generate()?
        .write_to_file("src/abi/reverse_registrar.rs")?;

    // Generate bindings for the ENS Registry contract
    Abigen::new("registry", "abi/ENSRegistry.json")?
        .generate()?
        .write_to_file("src/abi/registry.rs")?;

    Ok(())
}mkdir -p ens/abi
mkdir -p ens/src/abi