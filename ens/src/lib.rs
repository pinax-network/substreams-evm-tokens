// Re-export the generated protobuf types from substreams-ens-pb
pub use substreams_ens_pb::ens::v1::{
    AddrChanged,
    ContenthashChanged,
    EnsEvents,
    EnsName,
    NameChanged,
    NameRegistered,
    NameRenewed,
    NameTransferred,
    NewOwner,
    NewResolver,
    NewTtl,
    StringMessage,
    TextChanged,
    Transfer,
};

// Import modules
pub mod abi;
pub mod events;

use substreams::{store::{StoreGet, StoreNew, StoreSet}, Hex};
use substreams::prelude::{StoreGetProto, StoreSetProto};
use substreams_ethereum::{pb::eth::v2 as eth, Event};

// Contract addresses
const ENS_REGISTRY_ADDRESS: &str = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e";
const PUBLIC_RESOLVER_ADDRESS: &str = "0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63";
const PUBLIC_RESOLVER2_ADDRESS: &str = "0x4976fb03C32e5B8cfe2b6cCB31c09Ba78EBaBa41";
const REVERSE_REGISTRAR_ADDRESS: &str = "0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb";
const ETH_REGISTRAR_CONTROLLER_ADDRESS: &str = "0x253553366da8546fc250f225fe3d25d0c782303b";
const ETH_REGISTRAR_CONTROLLER_OLD_ADDRESS: &str = "0x283Af0B28c62C092C9727F1Ee09c02CA627EB7F5";
#[allow(dead_code)]
const NAME_WRAPPER_ADDRESS: &str = "0xD4416b13d2b3a9aBae7AcD5D6C2BbDBE25686401";

// Helper function to convert bytes32 to hex string
fn bytes32_to_hex(bytes: &[u8]) -> String {
    format!("0x{}", Hex(bytes))
}

// Helper function to normalize Ethereum address
fn normalize_address(address: &str) -> String {
    if address.starts_with("0x") {
        address.to_lowercase()
    } else {
        format!("0x{}", address.to_lowercase())
    }
}

// Helper function to get timestamp from block header
fn get_timestamp(block: &eth::Block) -> u64 {
    block.header.as_ref()
        .and_then(|h| h.timestamp.as_ref())
        .map(|ts| ts.seconds as u64)
        .unwrap_or(0)
}

#[substreams::handlers::map]
fn map_events(block: eth::Block) -> Result<EnsEvents, substreams::errors::Error> {
    let timestamp = get_timestamp(&block);
    let mut events = EnsEvents::default();

    for trx in block.transactions() {
        let tx_hash = bytes32_to_hex(trx.hash.as_ref());

        // Process logs for each transaction
        for log in &trx.receipt.as_ref().map_or(Vec::new(), |r| r.logs.clone()) {
            let address = normalize_address(&format!("0x{}", Hex(&log.address)));

            // ENS Registry events
            if address == ENS_REGISTRY_ADDRESS.to_lowercase() {
                // NewOwner event
                if let Some(event) = events::NewOwner::match_and_decode(log) {
                    let node = event.node;
                    let label = event.label;
                    let owner = event.owner;
                    events.new_owner.push(NewOwner {
                        node: bytes32_to_hex(&node),
                        label: bytes32_to_hex(&label),
                        owner: normalize_address(&owner),
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }

                // Transfer event
                if let Some(event) = events::Transfer::match_and_decode(log) {
                    let node = event.node;
                    let owner = event.owner;
                    events.transfer.push(Transfer {
                        node: bytes32_to_hex(&node),
                        owner: normalize_address(&owner),
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }

                // NewResolver event
                if let Some(event) = events::NewResolver::match_and_decode(log) {
                    let node = event.node;
                    let resolver = event.resolver;
                    events.new_resolver.push(NewResolver {
                        node: bytes32_to_hex(&node),
                        resolver: normalize_address(&resolver),
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }

                // NewTTL event
                if let Some(event) = events::NewTTL::match_and_decode(log) {
                    let node = event.node;
                    let ttl = event.ttl;
                    events.new_ttl.push(NewTtl {
                        node: bytes32_to_hex(&node),
                        ttl,
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }
            }

            // Public Resolver events
            if address == PUBLIC_RESOLVER_ADDRESS.to_lowercase() || address == PUBLIC_RESOLVER2_ADDRESS.to_lowercase() {
                // AddrChanged event
                if let Some(event) = events::AddrChanged::match_and_decode(log) {
                    let node = event.node;
                    let addr = event.address;
                    events.addr_changed.push(AddrChanged {
                        node: bytes32_to_hex(&node),
                        address: normalize_address(&addr),
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }

                // NameChanged event
                if let Some(event) = events::NameChanged::match_and_decode(log) {
                    let node = event.node;
                    let name = event.name;
                    events.name_changed.push(NameChanged {
                        node: bytes32_to_hex(&node),
                        name,
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }

                // ContenthashChanged event
                if let Some(event) = events::ContenthashChanged::match_and_decode(log) {
                    let node = event.node;
                    let hash = event.hash;
                    events.contenthash_changed.push(ContenthashChanged {
                        node: bytes32_to_hex(&node),
                        hash: bytes32_to_hex(&hash),
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }

                // TextChanged event
                if let Some(event) = events::TextChanged::match_and_decode(log) {
                    let node = event.node;
                    let key = event.key;
                    let value = event.value;
                    events.text_changed.push(TextChanged {
                        node: bytes32_to_hex(&node),
                        key,
                        value,
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }
            }

            // ETH Registrar Controller events
            if address == ETH_REGISTRAR_CONTROLLER_ADDRESS.to_lowercase() || address == ETH_REGISTRAR_CONTROLLER_OLD_ADDRESS.to_lowercase() {
                // NameRegistered event
                if let Some(event) = events::NameRegistered::match_and_decode(log) {
                    let name = event.name;
                    let label = event.label;
                    let owner = event.owner;
                    let cost = event.cost;
                    let expires = event.expires;
                    events.name_registered.push(NameRegistered {
                        name: name.clone(),
                        label: bytes32_to_hex(&label),
                        owner: normalize_address(&owner),
                        cost,
                        expires,
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }

                // NameRenewed event
                if let Some(event) = events::NameRenewed::match_and_decode(log) {
                    let name = event.name;
                    let label = event.label;
                    let cost = event.cost;
                    let expires = event.expires;
                    events.name_renewed.push(NameRenewed {
                        name: name.clone(),
                        label: bytes32_to_hex(&label),
                        cost,
                        expires,
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }
            }

            // Reverse Registrar events
            if address == REVERSE_REGISTRAR_ADDRESS.to_lowercase() {
                // ReverseClaimed event
                if let Some(event) = events::ReverseClaimed::match_and_decode(log) {
                    let addr = event.addr;
                    let node = event.node;
                    events.name_changed.push(NameChanged {
                        node: bytes32_to_hex(&node),
                        name: format!("{}.addr.reverse", normalize_address(&addr)),
                        timestamp,
                        transaction_hash: tx_hash.clone(),
                    });
                }
            }
        }
    }

    Ok(events)
}

#[substreams::handlers::store]
fn store_ens_names(events: EnsEvents, store_get: StoreGetProto<EnsName>, store_set: StoreSetProto<EnsName>) {
    // Process name registrations
    for event in events.name_registered {
        let name = format!("{}.eth", event.name);
        let node_key = format!("name:{}", name);
        
        // Create or update ENS name record
        let ens_name = EnsName {
            node: node_key.clone(),
            label: event.label,
            name: name.clone(),
            owner: event.owner,
            created_at: event.timestamp,
            updated_at: event.timestamp,
            expiry: event.expires,
            ..Default::default()
        };
        
        store_set.set(0, node_key, &ens_name);
        
        // Also store by address for reverse lookup once we have the address
        if !ens_name.addr.is_empty() {
            let addr_key = format!("addr:{}", ens_name.addr);
            store_set.set(0, addr_key, &ens_name);
        }
    }
    
    // Process address changes
    for event in events.addr_changed {
        let node_key = format!("node:{}", event.node);
        
        if let Some(mut ens_name) = store_get.get_last(node_key.clone()) {
            // Update the address
            ens_name.addr = event.address.clone();
            ens_name.updated_at = event.timestamp;
            
            // Update the record
            store_set.set(0, node_key, &ens_name);
            
            // Also update or create the reverse mapping
            let addr_key = format!("addr:{}", event.address);
            store_set.set(0, addr_key, &ens_name);
        }
    }
    
    // Process name changes
    for event in events.name_changed {
        let node_key = format!("node:{}", event.node);
        
        if let Some(mut ens_name) = store_get.get_last(node_key.clone()) {
            // Update the name
            ens_name.name = event.name;
            ens_name.updated_at = event.timestamp;
            
            // Update the record
            store_set.set(0, node_key, &ens_name);
            
            // Also update the reverse mapping if we have an address
            if !ens_name.addr.is_empty() {
                let addr_key = format!("addr:{}", ens_name.addr);
                store_set.set(0, addr_key, &ens_name);
            }
        }
    }
    
    // Process text record changes
    for event in events.text_changed {
        let node_key = format!("node:{}", event.node);
        
        if let Some(mut ens_name) = store_get.get_last(node_key.clone()) {
            // Update the text record
            ens_name.text_records.insert(event.key, event.value);
            ens_name.updated_at = event.timestamp;
            
            // Update the record
            store_set.set(0, node_key, &ens_name);
        }
    }
    
    // Process ownership transfers
    for event in events.transfer {
        let node_key = format!("node:{}", event.node);
        
        if let Some(mut ens_name) = store_get.get_last(node_key.clone()) {
            // Update the owner
            ens_name.owner = event.owner;
            ens_name.updated_at = event.timestamp;
            
            // Update the record
            store_set.set(0, node_key, &ens_name);
        }
    }
    
    // Process new owners (subdomains)
    for event in events.new_owner {
        let parent_node_key = format!("node:{}", event.node);
        
        // If we have the parent node, we can create the subdomain
        if let Some(parent) = store_get.get_last(parent_node_key) {
            let subdomain = if parent.name.ends_with(".eth") {
                format!("{}.{}", event.label, parent.name)
            } else {
                format!("{}.{}.eth", event.label, parent.name)
            };
            
            let node_key = format!("name:{}", subdomain);
            
            // Create or update the subdomain record
            let ens_name = EnsName {
                node: node_key.clone(),
                label: event.label,
                name: subdomain,
                owner: event.owner,
                created_at: event.timestamp,
                updated_at: event.timestamp,
                ..Default::default()
            };
            
            store_set.set(0, node_key, &ens_name);
        }
    }
    
    // Process resolver changes
    for event in events.new_resolver {
        let node_key = format!("node:{}", event.node);
        
        if let Some(mut ens_name) = store_get.get_last(node_key.clone()) {
            // Update the resolver
            ens_name.resolver = event.resolver;
            ens_name.updated_at = event.timestamp;
            
            // Update the record
            store_set.set(0, node_key, &ens_name);
        }
    }
}

#[substreams::handlers::map]
fn resolve_ens_name(params: String, store: StoreGetProto<EnsName>) -> Result<StringMessage, substreams::errors::Error> {
    // Normalize the input name
    let name = if params.ends_with(".eth") {
        params
    } else {
        format!("{}.eth", params)
    };
    
    // Look up the name in the store
    let name_key = format!("name:{}", name);
    
    let result = if let Some(ens_name) = store.get_last(name_key) {
        if !ens_name.addr.is_empty() {
            ens_name.addr
        } else {
            "".to_string()
        }
    } else {
        // If we couldn't find the name or it doesn't have an address, return an empty string
        "".to_string()
    };
    
    Ok(StringMessage { value: result })
}

#[substreams::handlers::map]
fn reverse_resolve(params: String, store: StoreGetProto<EnsName>) -> Result<StringMessage, substreams::errors::Error> {
    // Normalize the input address
    let address = normalize_address(&params);
    
    // Look up the address in the store
    let addr_key = format!("addr:{}", address);
    
    let result = if let Some(ens_name) = store.get_last(addr_key) {
        ens_name.name
    } else {
        // If we couldn't find the address, return an empty string
        "".to_string()
    };
    
    Ok(StringMessage { value: result })
}
