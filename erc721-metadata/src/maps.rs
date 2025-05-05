use std::collections::{HashMap, HashSet};

use common::{is_zero_address, Address};
use proto::pb::evm::erc721::v1::{Events as ERC721Transfers, Transfer};
use proto::pb::evm::erc721::v1::{EventsMetadata, Metadata};

use crate::calls::{batch_token_base_uri, batch_token_collection_name, batch_token_collection_symbol, batch_token_uri};

#[substreams::handlers::map]
fn map_events(erc721_transfers: ERC721Transfers) -> Result<EventsMetadata, substreams::errors::Error> {
    let mut events = EventsMetadata::default();
    let mints: Vec<Transfer> = get_mints(erc721_transfers.transfers).collect();

    // Collect unique contracts and token IDs
    let mut contracts: HashSet<Address> = HashSet::new();
    let mut contracts_by_token_id: HashSet<(Address, String)> = HashSet::new();

    for transfer in &mints {
        contracts.insert(transfer.contract.clone());
        contracts_by_token_id.insert((transfer.contract.clone(), transfer.token_id.clone()));
    }

    // Fetch RPC calls for tokens
    let contract_vec: Vec<Address> = contracts.iter().cloned().collect();
    let contract_by_token_id_vec: Vec<(Address, String)> = contracts_by_token_id.iter().cloned().collect();
    let symbols: HashMap<Address, String> = batch_token_collection_symbol(contract_vec.clone());
    let names: HashMap<Address, String> = batch_token_collection_name(contract_vec.clone());
    let base_uris: HashMap<Address, String> = batch_token_base_uri(contract_vec);
    let uris: HashMap<(Address, String), String> = batch_token_uri(contract_by_token_id_vec);

    for transfer in mints {
        let uri = match uris.get(&(transfer.contract.clone(), transfer.token_id.clone())) {
            Some(uri) => Some(uri.to_string()),
            None => None,
        };
        let symbol = match symbols.get(&transfer.contract) {
            Some(symbol) => Some(symbol.to_string()),
            None => None,
        };
        let name = match names.get(&transfer.contract) {
            Some(name) => Some(name.to_string()),
            None => None,
        };
        let base_uri = match base_uris.get(&transfer.contract) {
            Some(name) => Some(name.to_string()),
            None => None,
        };
        // Add metadata to the events
        events.metadatas.push(Metadata {
            contract: transfer.contract.to_vec(),
            token_id: transfer.token_id.to_string(),
            uri,
            symbol,
            name,
            base_uri,
        });
    }

    Ok(events)
}

pub fn get_mints<'a>(erc721_transfers: Vec<Transfer>) -> impl Iterator<Item = Transfer> + 'a {
    erc721_transfers.into_iter().filter(|transfer| !is_zero_address(transfer.from.to_vec()))
}
