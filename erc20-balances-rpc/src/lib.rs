mod calls;

use std::collections::{HashMap, HashSet};

use calls::batch_balance_of;
use common::Address;
use proto::pb::evm::erc20::balances::v1::{BalanceByAccount, Events};
use proto::pb::evm::erc20::transfers::v1::Events as ERC20Transfers;
use substreams::scalar::BigInt;

#[substreams::handlers::map]
fn map_events(params: String, erc20: ERC20Transfers) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();
    let chunk_size = params.parse::<usize>().unwrap_or(25);

    // Collect unique tokens by owners
    let mut contracts_by_owner: HashSet<(Address, Address)> = HashSet::new();

    for transfer in &erc20.transfers {
        contracts_by_owner.insert((transfer.contract.to_vec(), transfer.from.to_vec()));
        contracts_by_owner.insert((transfer.contract.to_vec(), transfer.to.to_vec()));
    }

    // Fetch RPC calls for Balance Of
    let balance_ofs: HashMap<(Address, Address), BigInt> = batch_balance_of(contracts_by_owner.iter().cloned().collect(), chunk_size);

    for (contract, owner) in contracts_by_owner {
        // Balance Of
        if let Some(amount) = balance_ofs.get(&(contract.clone(), owner.clone())) {
            events.balances_by_account.push(BalanceByAccount {
                contract: contract.to_vec(),
                account: owner.to_vec(),
                amount: amount.to_string(),
            });
        };
    }
    Ok(events)
}
