mod pb;
mod abi;

use substreams::Hex;
use substreams_ethereum::{pb::eth::v2 as eth};
use std::collections::HashMap;
use std::fmt::Write;
use substreams::prelude::StoreSetProto;

// Import the generated protobuf code
use crate::pb::v1;

// ENS Registry contract address on Ethereum mainnet
const ENS_REGISTRY_ADDRESS: &str = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e";

// Namehash for .eth
const ETH_NODE: &str = "0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae";

#[substreams::handlers::map]
fn map_events(block: eth::Block) -> Result<v1::ENSEvents, substreams::errors::Error> {
    let mut events = v1::ENSEvents {
        name_registered: Vec::new(),
        name_renewed: Vec::new(),
        name_transferred: Vec::new(),
        new_owner: Vec::new(),
        new_resolver: Vec::new(),
        new_ttl: Vec::new(),
        transfer: Vec::new(),
        addr_changed: Vec::new(),
        name_changed: Vec::new(),
        contenthash_changed: Vec::new(),
        text_changed: Vec::new(),
    };

    for log in block.logs() {
        let tx_hash = Hex(&log.receipt.transaction.hash).to_string();
        let timestamp = block.timestamp_seconds();

        // Process ENS Registry events
        if Hex(&log.address()).to_string().to_lowercase() == ENS_REGISTRY_ADDRESS.to_lowercase() {
            // In a real implementation, we would decode the events here
            // For now, we'll just add placeholder logic
            
            // Example for NewOwner event (simplified)
            if log.topics().len() >= 3 && log.topics()[0] == hex::decode("ce0457fe73731f824cc272376169235128c118b49d344817417c6d108d155e82").unwrap() {
                events.new_owner.push(v1::NewOwner {
                    node: Hex(&log.topics()[1]).to_string(),
                    label: Hex(&log.topics()[2]).to_string(),
                    owner: Hex(&log.data()).to_string(),
                    timestamp,
                    transaction_hash: tx_hash.clone(),
                });
            }
            
            // Example for Transfer event (simplified)
            if log.topics().len() >= 2 && log.topics()[0] == hex::decode("d4735d920b0f87494915f556dd9b54c8f309026070caea5c737245152564d266").unwrap() {
                events.transfer.push(v1::Transfer {
                    node: Hex(&log.topics()[1]).to_string(),
                    owner: Hex(&log.data()).to_string(),
                    timestamp,
                    transaction_hash: tx_hash.clone(),
                });
            }
            
            // Example for NewResolver event (simplified)
            if log.topics().len() >= 2 && log.topics()[0] == hex::decode("335721b01866dc23fbee8b6b2c7b1e14d6f05c28cd35a2c934239f94095602a0").unwrap() {
                events.new_resolver.push(v1::NewResolver {
                    node: Hex(&log.topics()[1]).to_string(),
                    resolver: Hex(&log.data()).to_string(),
                    timestamp,
                    transaction_hash: tx_hash.clone(),
                });
            }
        }

        // Process PublicResolver events (simplified examples)
        if log.topics().len() >= 2 {
            // Example for AddrChanged event
            if log.topics()[0] == hex::decode("65412c0b4f88a82b0e0d4a04ad1f4452dfbf25e4a4c8c8b6e5c24988a3f7a3e9").unwrap() {
                events.addr_changed.push(v1::AddrChanged {
                    node: Hex(&log.topics()[1]).to_string(),
                    addr: Hex(&log.data()).to_string(),
                    timestamp,
                    transaction_hash: tx_hash.clone(),
                });
            }
            
            // Example for NameChanged event
            if log.topics()[0] == hex::decode("b7d29e911041e8d9b843369e890bcb72c9388692ba48b65ac54e9569c9d6b957").unwrap() {
                // In a real implementation, we would decode the name from the data
                events.name_changed.push(v1::NameChanged {
                    node: Hex(&log.topics()[1]).to_string(),
                    name: "example.eth".to_string(), // Placeholder
                    timestamp,
                    transaction_hash: tx_hash.clone(),
                });
            }
        }
    }

    Ok(events)
}

#[substreams::handlers::store]
fn store_ens_names(events: v1::ENSEvents, store: StoreSetProto<v1::ENSName>) {
    // Process new resolver events
    for event in events.new_resolver {
        let node = event.node.clone();
        let resolver_address = event.resolver.clone();
        
        // Store the resolver address for the node
        let mut ens_name = get_or_create_ens_name(&store, &node);
        ens_name.resolver = resolver_address;
        ens_name.updated_at = event.timestamp;
        
        store.set(node.clone(), &ens_name);
    }

    // Process address changes
    for event in events.addr_changed {
        let node = event.node.clone();
        let addr = event.addr.clone();
        
        // Store the address for the node
        let mut ens_name = get_or_create_ens_name(&store, &node);
        ens_name.addr = addr;
        ens_name.updated_at = event.timestamp;
        
        store.set(node.clone(), &ens_name);
    }

    // Process name changes
    for event in events.name_changed {
        let node = event.node.clone();
        let name = event.name.clone();
        
        // Store the name for the node
        let mut ens_name = get_or_create_ens_name(&store, &node);
        ens_name.name = name;
        ens_name.updated_at = event.timestamp;
        
        store.set(node.clone(), &ens_name);
    }

    // Process ownership changes
    for event in events.transfer {
        let node = event.node.clone();
        let owner = event.owner.clone();
        
        // Store the owner for the node
        let mut ens_name = get_or_create_ens_name(&store, &node);
        ens_name.owner = owner;
        ens_name.updated_at = event.timestamp;
        
        store.set(node.clone(), &ens_name);
    }

    // Process new owner events (for subdomains)
    for event in events.new_owner {
        let node = event.node.clone();
        let label = event.label.clone();
        let owner = event.owner.clone();
        
        // Create the full node hash for the subdomain
        let node_bytes = hex::decode(&node[2..]).unwrap_or_default();
        let label_bytes = hex::decode(&label[2..]).unwrap_or_default();
        let mut combined = Vec::new();
        combined.extend_from_slice(&node_bytes);
        combined.extend_from_slice(&label_bytes);
        
        let hash = keccak256(&combined);
        let mut subdomain_node = String::with_capacity(66); // 0x + 64 hex chars
        write!(&mut subdomain_node, "0x").unwrap();
        for byte in hash.iter() {
            write!(&mut subdomain_node, "{:02x}", byte).unwrap();
        }
        
        // Store the owner for the subdomain
        let mut ens_name = get_or_create_ens_name(&store, &subdomain_node);
        ens_name.owner = owner;
        ens_name.label = label;
        ens_name.node = node;
        ens_name.created_at = event.timestamp;
        ens_name.updated_at = event.timestamp;
        
        store.set(subdomain_node, &ens_name);
    }
}

// Helper function to get an existing ENS name or create a new one
fn get_or_create_ens_name(store: &StoreSetProto<v1::ENSName>, node: &str) -> v1::ENSName {
    match store.get_last(node) {
        Some(ens_name) => ens_name,
        None => v1::ENSName {
            name: String::new(),
            label: String::new(),
            node: node.to_string(),
            owner: String::new(),
            resolver: String::new(),
            ttl: 0,
            expiry: 0,
            addr: String::new(),
            contenthash: String::new(),
            text_records: HashMap::new(),
            created_at: 0,
            updated_at: 0,
        }
    }
}

// Helper function to compute keccak256 hash
fn keccak256(data: &[u8]) -> [u8; 32] {
    use tiny_keccak::{Hasher, Keccak};
    let mut output = [0u8; 32];
    let mut hasher = Keccak::v256();
    hasher.update(data);
    hasher.finalize(&mut output);
    output
}

// RPC module for resolving ENS names to addresses
#[substreams::handlers::map]
fn resolve_ens_name(
    params: String,
    store: substreams::store::StoreGetProto<v1::ENSName>,
) -> Result<String, substreams::errors::Error> {
    // Parse the ENS name from the parameters
    let ens_name = params.trim();
    
    // Check if the name ends with .eth
    if !ens_name.ends_with(".eth") {
        return Err(substreams::errors::Error::Unexpected(format!("Invalid ENS name: {}", ens_name)));
    }
    
    // Compute the namehash for the ENS name
    let namehash = compute_namehash(ens_name);
    
    // Look up the ENS name in the store
    if let Some(ens_record) = store.get_last(&namehash) {
        if !ens_record.addr.is_empty() {
            return Ok(ens_record.addr);
        }
    }
    
    // If not found in the store, return an error
    Err(substreams::errors::Error::Unexpected(format!("ENS name not found: {}", ens_name)))
}

// Helper function to compute namehash for an ENS name
fn compute_namehash(name: &str) -> String {
    let mut node = [0u8; 32];
    
    if name.is_empty() {
        return format!("0x{}", hex::encode(node));
    }
    
    let labels: Vec<&str> = name.split('.').collect();
    
    for label in labels.iter().rev() {
        let mut data = node.to_vec();
        data.extend_from_slice(&keccak256(label.as_bytes()));
        node = keccak256(&data);
    }
    
    format!("0x{}", hex::encode(node))
}

// RPC module for reverse resolution (address to ENS name)
#[substreams::handlers::map]
fn reverse_resolve(
    params: String,
    store: substreams::store::StoreGetProto<v1::ENSName>,
) -> Result<String, substreams::errors::Error> {
    // Parse the Ethereum address from the parameters
    let address = params.trim();
    
    // Validate the address format
    if !address.starts_with("0x") || address.len() != 42 {
        return Err(substreams::errors::Error::Unexpected(format!("Invalid Ethereum address: {}", address)));
    }
    
    // Compute the reverse node for the address
    let reverse_node = compute_reverse_node(address);
    
    // Look up the reverse record in the store
    if let Some(ens_record) = store.get_last(&reverse_node) {
        if !ens_record.name.is_empty() {
            return Ok(ens_record.name);
        }
    }
    
    // If not found in the store, return an error
    Err(substreams::errors::Error::Unexpected(format!("No ENS name found for address: {}", address)))
}

// Helper function to compute the reverse node for an Ethereum address
fn compute_reverse_node(address: &str) -> String {
    // Remove the 0x prefix and convert to lowercase
    let addr = address[2..].to_lowercase();
    
    // Construct the reverse name (address.addr.reverse)
    let reverse_name = format!("{}.addr.reverse", addr);
    
    // Compute the namehash for the reverse name
    compute_namehash(&reverse_name)
}
