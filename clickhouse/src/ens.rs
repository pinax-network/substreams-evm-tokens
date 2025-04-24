use std::collections::HashMap;
use substreams::errors::Error;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ens::EnsEvents;

// Cache to store node to name mappings during processing
struct NodeNameCache {
    node_to_name: HashMap<String, String>,
}

impl NodeNameCache {
    fn new() -> Self {
        Self {
            node_to_name: HashMap::new(),
        }
    }

    fn add_node_name(&mut self, node: &str, name: &str) {
        self.node_to_name.insert(node.to_string(), name.to_string());
    }

    fn get_name_for_node(&self, node: &str) -> Option<String> {
        self.node_to_name.get(node).cloned()
    }
}

pub fn db_out(
    block: &Block,
    events: &EnsEvents,
) -> Result<DatabaseChanges, Error> {
    let block_number = block.number;
    // Improved timestamp handling
    let timestamp = block.header.as_ref()
        .and_then(|h| h.timestamp.as_ref())
        .map(|ts| ts.seconds)
        .unwrap_or(0);
        
    let block_time = chrono::DateTime::<chrono::Utc>::from_timestamp(timestamp, 0)
        .unwrap_or_default()
        .format("%Y-%m-%d %H:%M:%S")
        .to_string();

    let mut tables = Tables::new();
    let mut cache = NodeNameCache::new();

    // Process NameRegistered events
    for event in &events.name_registered {
        // Insert into raw events table
        tables
            .create_row("ens_name_registered", format!("{}-{}", block_number, &event.transaction_hash))
            .set("block_number", block_number)
            .set("block_timestamp", block_time.clone())
            .set("transaction_hash", &event.transaction_hash)
            .set("name", &event.name)
            .set("label", &event.label)
            .set("owner", &event.owner)
            .set("cost", event.cost)
            .set("expires", event.expires);

        // Update the aggregated ens_names table
        let name = format!("{}.eth", &event.name);
        tables
            .create_row("ens_names", &name)
            .set("name", &name)
            .set("owner", &event.owner)
            .set("resolver", "") // Will be updated when resolver is set
            .set("ttl", 0) // Will be updated when TTL is set
            .set("expiry", event.expires)
            .set("created_at", block_time.clone())
            .set("updated_at", block_time.clone())
            .set("contenthash", ""); // Will be updated when contenthash is set

        // Add to our cache for future reference
        if let Some(node) = compute_namehash(&name) {
            cache.add_node_name(&node, &name);
        }
    }

    // Process TextChanged events
    for event in &events.text_changed {
        // Insert into raw events table
        tables
            .create_row("ens_text_changed", format!("{}-{}", block_number, &event.transaction_hash))
            .set("block_number", block_number)
            .set("block_timestamp", block_time.clone())
            .set("transaction_hash", &event.transaction_hash)
            .set("node", &event.node)
            .set("key", &event.key)
            .set("value", &event.value);

        // Try to find the name for this node
        if let Some(name) = cache.get_name_for_node(&event.node) {
            // Update the aggregated ens_texts table
            tables
                .create_row("ens_texts", format!("{}-{}", &name, &event.key))
                .set("name", &name)
                .set("key", &event.key)
                .set("value", &event.value)
                .set("updated_at", block_time.clone());
        }
    }

    // Process ReverseClaimed events (from name_changed events with .addr.reverse suffix)
    for event in &events.name_changed {
        if event.name.ends_with(".addr.reverse") {
            // This is a reverse claim
            let address = event.name.strip_suffix(".addr.reverse").unwrap_or("");
            
            // Insert into raw events table
            tables
                .create_row("ens_reverse_claim", format!("{}-{}", block_number, &event.transaction_hash))
                .set("block_number", block_number)
                .set("block_timestamp", block_time.clone())
                .set("transaction_hash", &event.transaction_hash)
                .set("address", address)
                .set("node", &event.node);
            
            // If we have a valid address, update the reverse resolution table
            if !address.is_empty() {
                // Look for any existing name for this address
                // In a real implementation, we would query the ENS contract
                // For now, we'll just use our cache to see if we have any address mappings
                for (node, name) in &cache.node_to_name {
                    if let Some(addr_record) = get_address_for_node(&tables, node) {
                        if addr_record.to_lowercase() == address.to_lowercase() {
                            // We found a name for this address, update the reverse mapping
                            tables
                                .create_row("ens_names_by_address", address)
                                .set("address", address)
                                .set("name", name)
                                .set("updated_at", block_time.clone());
                            break;
                        }
                    }
                }
            }
        }
    }

    // Process NameChanged events
    for event in &events.name_changed {
        // Insert into raw events table
        tables
            .create_row("ens_name_changed", format!("{}-{}", block_number, &event.transaction_hash))
            .set("block_number", block_number)
            .set("block_timestamp", block_time.clone())
            .set("transaction_hash", &event.transaction_hash)
            .set("node", &event.node)
            .set("name", &event.name);

        // Update the aggregated ens_names table if this is a name update
        if !event.name.ends_with(".addr.reverse") {
            // Add to our cache for future reference
            cache.add_node_name(&event.node, &event.name);
            
            // Check if we already have a record for this name
            let existing_name = get_name_record(&tables, &event.name);
            
            if existing_name {
                // Just update the name record
                tables
                    .create_row("ens_names", &event.name)
                    .set("updated_at", block_time.clone());
            } else {
                // Create a new name record
                tables
                    .create_row("ens_names", &event.name)
                    .set("name", &event.name)
                    .set("created_at", block_time.clone())
                    .set("updated_at", block_time.clone());
            }
        }
    }

    // Process AddrChanged events
    for event in &events.addr_changed {
        // Insert into raw events table
        tables
            .create_row("ens_addr_changed", format!("{}-{}", block_number, &event.transaction_hash))
            .set("block_number", block_number)
            .set("block_timestamp", block_time.clone())
            .set("transaction_hash", &event.transaction_hash)
            .set("node", &event.node)
            .set("address", &event.address);

        // Try to find the name for this node
        if let Some(name) = cache.get_name_for_node(&event.node) {
            // Update the aggregated ens_names table with the address
            tables
                .create_row("ens_names", &name)
                .set("name", &name)
                .set("address", &event.address)
                .set("updated_at", block_time.clone());

            // Also update the reverse mapping
            tables
                .create_row("ens_names_by_address", &event.address)
                .set("address", &event.address)
                .set("name", &name)
                .set("updated_at", block_time.clone());
        }
    }

    // Process ContenthashChanged events
    for event in &events.contenthash_changed {
        if let Some(name) = cache.get_name_for_node(&event.node) {
            // Update the aggregated ens_names table with the contenthash
            tables
                .create_row("ens_names", &name)
                .set("name", &name)
                .set("contenthash", &event.hash)
                .set("updated_at", block_time.clone());
        }
    }

    Ok(tables.to_database_changes())
}

// Helper function to compute namehash for an ENS name
// This is a simplified implementation and may not match the actual ENS namehash algorithm
fn compute_namehash(name: &str) -> Option<String> {
    // In a real implementation, this would compute the namehash according to EIP-137
    // For now, we'll just return a placeholder
    Some(format!("namehash:{}", name))
}

// Helper function to check if a name record exists
fn get_name_record(_tables: &Tables, _name: &str) -> bool {
    // In a real implementation, this would query the database
    // For now, we'll just return false
    false
}

// Helper function to get the address for a node
fn get_address_for_node(_tables: &Tables, _node: &str) -> Option<String> {
    // In a real implementation, this would query the database
    // For now, we'll just return None
    None
}
