mod calls;
mod utils;
use proto::pb::evm::native::balances::v1::{BalanceByAccount, Events};
use std::collections::HashSet;
use substreams::errors::Error;
use substreams_ethereum::pb::eth::v2::Block;

use crate::{
    calls::batch_eth_balance_of,
    utils::{get_balances, is_failed_transaction, is_gas_balance_change, is_valid_balance_change},
};

#[substreams::handlers::map]
pub fn map_events(params: String, block: Block) -> Result<Events, Error> {
    let mut events = Events::default();
    let chunk_size = params.parse::<usize>().expect("Failed to parse chunk_size");

    // EXTENDED
    // balance changes at block level
    for balance_change in &block.balance_changes {
        // Block Rewards as balance change
        if is_valid_balance_change(balance_change) {
            let (_, new_balance) = get_balances(balance_change);
            events.extended_balances_by_account_from_block_rewards.push(BalanceByAccount {
                tx_hash: None,
                account: balance_change.address.to_vec(),
                amount: new_balance.to_string(),
            });
        }
    }

    // balance changes at system call level
    for call in &block.system_calls {
        for balance_change in &call.balance_changes {
            if is_valid_balance_change(balance_change) {
                let (_, new_balance) = get_balances(balance_change);
                events.extended_balances_by_account_from_system_calls.push(BalanceByAccount {
                    tx_hash: None,
                    account: balance_change.address.to_vec(),
                    amount: new_balance.to_string(),
                });
            }
        }
    }

    // EXTENDED
    // iterate over all transactions including failed ones
    for trx in &block.transaction_traces {
        for call_view in trx.calls() {
            for balance_change in &call_view.call.balance_changes {
                if is_valid_balance_change(balance_change) {
                    let (_, new_balance) = get_balances(balance_change);

                    // gas balance changes
                    if is_gas_balance_change(balance_change) {
                        events.extended_balances_by_account_from_gas.push(BalanceByAccount {
                            tx_hash: Some(trx.hash.to_vec()),
                            account: balance_change.address.to_vec(),
                            amount: new_balance.to_string(),
                        });
                    // non-gas successful balance changes
                    } else if !is_failed_transaction(trx) {
                        events.extended_balances_by_account_from_calls.push(BalanceByAccount {
                            tx_hash: Some(trx.hash.to_vec()),
                            account: balance_change.address.to_vec(),
                            amount: new_balance.to_string(),
                        });
                    }
                }
            }
        }
    }

    // BASE BLOCKS (NOT EXTENDED)
    // collect all unique accounts from transactions/calls/logs
    // - trx.from
    // - trx.to
    // - log.address
    // - call.address
    // - call.caller
    // - call.address_delegates_to
    let mut accounts = HashSet::new();
    for trx in &block.transaction_traces {
        accounts.insert(trx.from.to_vec());
        accounts.insert(trx.to.to_vec());

        for call_view in trx.calls() {
            let call = call_view.call;
            accounts.insert(call.address.to_vec());
            accounts.insert(call.caller.to_vec());
            if let Some(address_delegates_to) = &call.address_delegates_to {
                accounts.insert(address_delegates_to.to_vec());
            }
            for log in call.logs.iter() {
                accounts.insert(log.address.to_vec());
            }
        }
    }

    // NATIVE ETH BALANCE OF
    for (account, balance) in &batch_eth_balance_of(block.number, &accounts.iter().collect::<Vec<_>>(), chunk_size) {
        events.balances_by_account.push(BalanceByAccount {
            tx_hash: None,
            account: account.to_vec(),
            amount: balance.to_string(),
        });
    }
    Ok(events)
}
