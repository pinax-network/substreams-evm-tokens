mod calls;

use std::collections::HashSet;

use common::Address;
use proto::pb::evm::erc20::supply::v1::{Events, TotalSupplyByContract};
use proto::pb::evm::erc20::transfers::v1::Events as ERC20Transfers;

use crate::calls::batch_total_supply;

#[substreams::handlers::map]
fn map_events(erc20: ERC20Transfers) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    // Collect unique contracts
    let mut contracts: HashSet<Address> = HashSet::new();
    for transfer in erc20.transfers {
        contracts.insert(transfer.contract.clone());
    }

    // Fetch RPC calls for tokens
    let total_supplies = batch_total_supply(contracts.iter().cloned().collect());

    // Metadata By Contract
    for (contract, total_supply) in total_supplies {
        events.total_supply_by_contracts.push(TotalSupplyByContract {
            contract: contract.to_vec(),
            total_supply: total_supply.to_string(),
        });
    }

    Ok(events)
}
