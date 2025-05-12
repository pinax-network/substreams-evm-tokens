use std::collections::{HashMap, HashSet};

use common::{is_zero_address, Address};
use proto::pb::evm::erc20::metadata::v1::{Events, MetadataByContract, TotalSupplyByContract};
use proto::pb::evm::erc20::v1::{Events as ERC20Transfers, Transfer};
use substreams::scalar::BigInt;

use crate::calls::{batch_name, batch_symbol, batch_total_supply};

#[substreams::handlers::map]
fn map_events(erc20_transfers: ERC20Transfers) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();
    let mints: Vec<Transfer> = get_mints(erc20_transfers.transfers).collect();

    // Collect unique token contracts
    let mut contracts: HashSet<Address> = HashSet::new();

    for transfer in &mints {
        contracts.insert(transfer.contract.clone());
    }

    // Fetch RPC calls for tokens
    let contract_vec: Vec<Address> = contracts.iter().cloned().collect();
    let symbols: HashMap<Address, String> = batch_symbol(contract_vec.clone());
    let names: HashMap<Address, String> = batch_name(contract_vec.clone());
    let total_supplies: HashMap<Address, BigInt> = batch_total_supply(contract_vec.clone());

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
        let total_supply = match total_supplies.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        // Metadata by Contract
        events.metadata_by_contracts.push(MetadataByContract {
            contract: contract.to_vec(),
            symbol,
            name,
            decimals: None,
        });

        // Total supply By Contract
        if let Some(total_supply) = total_supply {
            events.total_supply_by_contracts.push(TotalSupplyByContract {
                contract: contract.to_vec(),
                total_supply: total_supply.to_string(),
            });
        }
    }

    Ok(events)
}

pub fn get_mints<'a>(erc721_transfers: Vec<Transfer>) -> impl Iterator<Item = Transfer> + 'a {
    erc721_transfers.into_iter().filter(|transfer| !is_zero_address(transfer.from.to_vec()))
}
