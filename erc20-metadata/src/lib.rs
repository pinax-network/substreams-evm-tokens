mod calls;

use common::Address;
use proto::pb::evm::erc20::metadata::v1::{Events, MetadataByContract, TotalSupplyByContract};
use proto::pb::evm::erc20::stores::v1::Events as ERC20FirstTransfer;

use crate::calls::{batch_decimals, batch_name, batch_symbol, batch_total_supply};

#[substreams::handlers::map]
fn map_events(erc20: ERC20FirstTransfer) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    // Fetch RPC calls for tokens
    let contract_vec: Vec<Address> = erc20.first_transfer_by_contract.iter().map(|row| row.contract.clone()).collect();
    let symbols = batch_symbol(contract_vec.clone());
    let names = batch_name(contract_vec.clone());
    let decimals = batch_decimals(contract_vec.clone());
    let total_supplies = batch_total_supply(contract_vec.clone());

    // Metadata By Contract
    for contract in contract_vec {
        let decimals = match decimals.get(&contract) {
            Some(value) => Some(value),
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
        let total_supply = match total_supplies.get(&contract) {
            Some(value) => Some(value.to_string()),
            None => None,
        };
        // Metadata by Contract
        if let Some(decimals) = decimals {
            events.metadata_by_contracts.push(MetadataByContract {
                contract: contract.to_vec(),
                symbol,
                name,
                decimals: decimals.to_i32(),
            });
        }

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
