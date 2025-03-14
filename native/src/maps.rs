use common::{to_global_sequence, Address};
use proto::pb::evm::tokens::types::v1::{Algorithm, BalanceChange, Events, Transfer};
use substreams::{errors::Error, scalar::BigInt};

use substreams::pb::substreams::Clock;
use substreams_ethereum::pb::eth::v2::{BalanceChange as BalanceChangeAbi, Block, TransactionTrace};

use crate::algorithms::transfers::{get_transfer_from_call, get_transfer_from_transaction};
use crate::utils::{get_balances, is_failed_transaction, is_gas_balance_change};

#[substreams::handlers::map]
pub fn map_events(clock: Clock, block: Block) -> Result<Events, Error> {
    let mut events = Events::default();
    insert_events(&clock, &block, &mut events);
    Ok(events)
}

pub fn to_balance_change<'a>(
    clock: &Clock,
    trx: &'a TransactionTrace,
    balance_change: &'a BalanceChangeAbi,
    algorithm: Algorithm,
    index: &u64,
) -> BalanceChange {
    let (old_balance, new_balance) = get_balances(balance_change);

    BalanceChange {
        // -- transaction
        transaction_id: trx.hash.clone(),

        // -- balance change --
        contract: "native".to_string().into_bytes(),
        owner: balance_change.address.clone(),
        old_balance: old_balance.to_string(),
        new_balance: new_balance.to_string(),

        // -- ordering --
        ordinal: balance_change.ordinal,
        global_sequence: to_global_sequence(clock, index),

        // -- debug --
        algorithm: algorithm.into(),
    }
}

// add default
#[derive(Default)]
pub struct TransferStruct {
    pub from: Address,
    pub to: Address,
    pub value: BigInt,
    pub ordinal: u64,
    pub algorithm: Algorithm,
}

pub fn to_transfer<'a>(clock: &'a Clock, trx: &'a TransactionTrace, transfer: TransferStruct, index: &u64) -> Transfer {
    Transfer {
        // -- transaction --
        transaction_id: trx.hash.clone(),

        // -- ordering --
        ordinal: transfer.ordinal.into(),
        global_sequence: to_global_sequence(clock, index),

        // -- transfer --
        contract: "native".to_string().into_bytes(),
        from: transfer.from,
        to: transfer.to,
        value: transfer.value.to_string(),

        // -- debug --
        algorithm: transfer.algorithm.into(),
    }
}

pub fn insert_events<'a>(clock: &'a Clock, block: &'a Block, events: &mut Events) {
    let mut index = 0; // relative index for ordering

    // balance changes at block level
    for balance_change in &block.balance_changes {
        events.balance_changes.push(
            to_balance_change(clock, &TransactionTrace::default(), balance_change, Algorithm::Block, &index)
        );
        index += 1;
    }

    // balance changes at system call level
    for call in &block.system_calls {
        for balance_change in &call.balance_changes {
            events.balance_changes.push(
                to_balance_change(clock, &TransactionTrace::default(), balance_change, Algorithm::System, &index)
            );
            index += 1;
        }
    }

    // iterate over successful transactions
    for trx in block.transactions() {
        // find all transfers from transactions
        match get_transfer_from_transaction(trx) {
            Some(transfer) => {
                events.transfers.push(
                    to_transfer(clock, trx, transfer, &index)
                );
                index += 1;
            }
            None => {}
        }
        // find all transfers from calls
        for call_view in trx.calls() {
            match get_transfer_from_call(call_view.call) {
                Some(transfer) => {
                    events.transfers.push(
                        to_transfer(clock, trx, transfer, &index)
                    );
                    index += 1;
                }
                None => {}
            }
        }
    }

    // iterate over all transactions including failed ones
    for trx in &block.transaction_traces {
        for call_view in trx.calls() {
            // balance changes
            for balance_change in &call_view.call.balance_changes {
                let algorithm = if is_failed_transaction(trx) {
                    Algorithm::Failed
                } else if is_gas_balance_change(balance_change) {
                    Algorithm::Gas
                } else {
                    Algorithm::Call
                };

                // balance change
                events.balance_changes.push(
                    to_balance_change(clock, trx, balance_change, algorithm, &index)
                );
                index += 1;
            }
        }

    }
}
