use std::collections::{HashMap, HashSet};

use common::{is_zero_address, Address};
use proto::pb::evm::erc721::metadata::v1::{Events, MetadataByContract, MetadataByToken};
use proto::pb::evm::erc721::v1::{Events as ERC721Transfers, Transfer};
use substreams::scalar::BigInt;

use crate::calls::{batch_base_uri, batch_name, batch_symbol, batch_token_uri, batch_total_supply};

#[substreams::handlers::map]
fn map_events(erc721_transfers: ERC721Transfers) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();
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
    let symbols: HashMap<Address, String> = batch_symbol(contract_vec.clone());
    let names: HashMap<Address, String> = batch_name(contract_vec.clone());
    let base_uris: HashMap<Address, String> = batch_base_uri(contract_vec.clone());
    let total_supplies: HashMap<Address, BigInt> = batch_total_supply(contract_vec.clone());
    let uris: HashMap<(Address, String), String> = batch_token_uri(contract_by_token_id_vec);

    // Metadata By Token
    for transfer in mints {
        let uri = match uris.get(&(transfer.contract.clone(), transfer.token_id.clone())) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        events.metadata_by_tokens.push(MetadataByToken {
            contract: transfer.contract.to_vec(),
            token_id: transfer.token_id.to_string(),
            uri,
        });
    }

    // Metadata By Contract
    for contract in contract_vec {
        let symbol = match symbols.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        let name = match names.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        let base_uri = match base_uris.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        let total_supply = match total_supplies.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        // Add metadata to the events
        events.metadata_by_contracts.push(MetadataByContract {
            contract: contract.to_vec(),
            symbol,
            name,
            base_uri,
            total_supply,
        });
    }

    Ok(events)
}

pub fn get_mints<'a>(erc721_transfers: Vec<Transfer>) -> impl Iterator<Item = Transfer> + 'a {
    erc721_transfers.into_iter().filter(|transfer| !is_zero_address(transfer.from.to_vec()))
}
