use std::process::Command;
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=../abi/ENSRegistry.json");
    println!("cargo:rerun-if-changed=../abi/PublicResolver.json");
    println!("cargo:rerun-if-changed=../abi/ReverseRegistrar.json");
    println!("cargo:rerun-if-changed=../ens.proto");

    // Generate Rust code from ABI files
    generate_abi_code("ENSRegistry", "../abi/ENSRegistry.json", "registry");
    generate_abi_code("PublicResolver", "../abi/PublicResolver.json", "resolver");
    generate_abi_code("ReverseRegistrar", "../abi/ReverseRegistrar.json", "reverse_registrar");
    
    // Compile proto files using prost-build
    compile_protos();
}

fn generate_abi_code(contract_name: &str, abi_path: &str, module_name: &str) {
    println!("Generating Rust code for {}", contract_name);
    
    // Create the output directory if it doesn't exist
    std::fs::create_dir_all("src/abi").unwrap();
    
    // Generate the Rust code using substreams-ethereum-abigen
    let output = Command::new("substreams")
        .args(&[
            "protogen",
            "--exclude-paths=sf/substreams,google",
            &format!("--output-file=src/abi/{}.rs", module_name),
            abi_path,
        ])
        .output()
        .expect(&format!("Failed to generate Rust code for {}", contract_name));
    
    if !output.status.success() {
        panic!(
            "Failed to generate Rust code for {}: {}",
            contract_name,
            String::from_utf8_lossy(&output.stderr)
        );
    }
    
    // Create a mod.rs file if it doesn't exist
    let mod_path = "src/abi/mod.rs";
    if !std::path::Path::new(mod_path).exists() {
        let mut mod_content = String::new();
        mod_content.push_str("// Generated code - do not modify\n\n");
        mod_content.push_str("pub mod registry;\n");
        mod_content.push_str("pub mod resolver;\n");
        mod_content.push_str("pub mod reverse_registrar;\n");
        
        std::fs::write(mod_path, mod_content).unwrap();
    }
}

fn compile_protos() {
    println!("Compiling proto files...");
    
    // Create the output directory if it doesn't exist
    std::fs::create_dir_all("src/pb/ens").unwrap();
    
    // Path to the proto file
    let proto_file = Path::new("../ens.proto");
    
    // Compile the proto file
    prost_build::compile_protos(&[proto_file], &[Path::new("..")]).expect("Failed to compile proto files");
    
    println!("Proto compilation complete");
}
