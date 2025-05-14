mod utils;
use proto::pb::evm::native::balances::v1::{BalanceByAccount, Events};
use substreams::errors::Error;
use substreams_ethereum::pb::eth::v2::Block;

use crate::utils::{get_balances, is_failed_transaction, is_gas_balance_change, is_valid_balance_change};

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<Events, Error> {
    let mut events = Events::default();

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
    Ok(events)
}
