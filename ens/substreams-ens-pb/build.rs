use std::io::Result;

fn main() -> Result<()> {
    // Tell Cargo to rerun this script if the protobuf file changes
    println!("cargo:rerun-if-changed=../ens.proto");

    // Use prost-build to generate Rust code from the protobuf file
    let mut config = prost_build::Config::new();
    
    // Configure the output
    config.out_dir("src/pb");
    
    // Compile the proto file
    config.compile_protos(&["../ens.proto"], &["../"])?;
    
    Ok(())
}
