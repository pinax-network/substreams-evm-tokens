use std::fs::{read_dir, read_to_string, remove_file, write};
use std::io;
use std::path::Path;

fn main() -> io::Result<()> {
    // Directory where the .sql files are located
    let dir = Path::new(".");

    // Delete the old file if it exists
    let _ = remove_file("schema.sql");

    // Output file name
    let out_file = "schema.sql";

    // Start with a generated comment
    let mut combined = String::from("-- This file is generated. Do not edit.\n\n");

    // Collect all .sql files
    let mut sql_files: Vec<_> = read_dir(dir)?
        .filter_map(|entry| {
            if let Ok(entry) = entry {
                let path = entry.path();
                if path.is_file() && path.extension().and_then(|s| s.to_str()) == Some("sql") {
                    Some(path)
                } else {
                    None
                }
            } else {
                None
            }
        })
        .collect();

    // Sort to ensure consistent ordering
    sql_files.sort();

    // Read and append the contents of each .sql file
    for file in sql_files {
        let content = read_to_string(&file)?;
        combined.push_str(&content);
        combined.push_str("\n\n");
    }

    // Create or overwrite schema.sql with all combined SQL
    write(out_file, combined)?;

    Ok(())
}
