use anyhow::Result;

fn main() -> Result<(), anyhow::Error> {
    println!("cargo:rerun-if-changed=abi/ENSRegistry.json");
    println!("cargo:rerun-if-changed=abi/PublicResolver.json");
    println!("cargo:rerun-if-changed=abi/ReverseRegistrar.json");
    println!("cargo:rerun-if-changed=abi/EthRegistrarController.json");
    println!("cargo:rerun-if-changed=abi/EthRegistrarControllerOld.json");
    println!("cargo:rerun-if-changed=abi/NameWrapper.json");
    println!("cargo:rerun-if-changed=abi/PublicResolver2.json");
    println!("cargo:rerun-if-changed=ens.proto");

    // Create the output directory if it doesn't exist
    std::fs::create_dir_all("src/abi")?;

    // Create a mod.rs file if it doesn't exist
    let mod_path = "src/abi/mod.rs";
    if !std::path::Path::new(mod_path).exists() {
        let mod_content = "// This module contains references to ENS ABIs\n\n\
                          // Note: The ABIs are included for reference but not used for code generation\n\
                          // due to compatibility issues with the abigen tool.\n\
                          // The following ABIs are available in the abi/ directory:\n\
                          // - ENSRegistry.json\n\
                          // - PublicResolver.json\n\
                          // - PublicResolver2.json\n\
                          // - ReverseRegistrar.json\n\
                          // - EthRegistrarController.json\n\
                          // - EthRegistrarControllerOld.json\n\
                          // - NameWrapper.json\n";
        
        std::fs::write(mod_path, mod_content)?;
    }

    Ok(())
}
