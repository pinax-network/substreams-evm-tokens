mod calls;

use common::Address;
use proto::pb::evm::erc20::metadata::v1::{Events, MetadataInitialize};
use proto::pb::evm::erc20::stores::v1::Events as ERC20FirstTransfer;

use crate::calls::{batch_decimals, batch_name, batch_symbol};

#[substreams::handlers::map]
fn map_events(erc20: ERC20FirstTransfer) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    // Fetch RPC calls for tokens
    let contract_vec: Vec<Address> = erc20.first_transfer_by_contract.iter().map(|row| row.contract.clone()).collect();
    let symbols = batch_symbol(contract_vec.clone());
    let names = batch_name(contract_vec.clone());
    let decimals = batch_decimals(contract_vec.clone());

    // Metadata By Contract
    for contract in contract_vec {
        let decimals = match decimals.get(&contract) {
            Some(value) => Some(value.clone()),
            None => None,
        };
        let symbol = match symbols.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        let name = match names.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        // Metadata by Contract
        // decimals is REQUIRED
        if let Some(decimals) = decimals {
            events.metadata_initialize.push(MetadataInitialize {
                address: contract.to_vec(),
                decimals, // decimals is REQUIRED for initialization
                symbol,
                name,
            });
        }
    }

    Ok(events)
}
