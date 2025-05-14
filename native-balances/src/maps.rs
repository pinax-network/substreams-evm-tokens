use common::{to_optional_vector, Address, NATIVE_ADDRESS};
use proto::pb::evm::tokens::balances::v1::{Algorithm, BalanceChange, Events, Transfer};
use substreams::{errors::Error, scalar::BigInt};
use substreams_ethereum::pb::eth::v2::{BalanceChange as BalanceChangeAbi, Block, Call, TransactionTrace};

use crate::algorithms::transfers::{get_transfer_from_block_reward, get_transfer_from_call, get_transfer_from_transaction, get_transfer_from_transaction_fee};
use crate::utils::{get_balances, is_failed_transaction, is_gas_balance_change, is_valid_balance_change};

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<Events, Error> {
    // Pre-allocate vectors to avoid reallocations
    let transaction_count = block.transactions().count();
    let mut events = Events {
        transfers: Vec::with_capacity(transaction_count * 2),
        balance_changes: Vec::with_capacity(transaction_count * 4),
    };
    insert_events(&block, &mut events);
    Ok(events)
}

pub fn to_balance_change<'a>(trx: &'a TransactionTrace, call: &'a Call, balance_change: &'a BalanceChangeAbi, algorithm: Algorithm) -> BalanceChange {
    let (old_balance, new_balance) = get_balances(balance_change);

    BalanceChange {
        // -- transaction --
        transaction_id: to_optional_vector(&trx.hash),

        // -- call --
        caller: to_optional_vector(&call.caller),

        // -- ordering --
        ordinal: Some(balance_change.ordinal),

        // -- balance change --
        contract: NATIVE_ADDRESS.to_vec(),
        address: balance_change.address.to_vec(),
        old_balance: Some(old_balance.to_string()),
        new_balance: new_balance.to_string(),

        // -- debug --
        algorithm: algorithm.into(),
        reason: Some(balance_change.reason),
        trx_type: Some(trx.r#type),
        call_type: Some(call.call_type),
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

pub fn to_transfer<'a>(trx: &'a TransactionTrace, call: &'a Call, transfer: TransferStruct) -> Transfer {
    Transfer {
        // -- transaction --
        transaction_id: to_optional_vector(&trx.hash),

        // -- call --
        caller: to_optional_vector(&call.caller),

        // -- ordering --
        ordinal: transfer.ordinal,

        // -- transfer --
        contract: NATIVE_ADDRESS.to_vec(),
        from: transfer.from,
        to: transfer.to,
        value: transfer.value.to_string(),

        // -- debug --
        algorithm: transfer.algorithm.into(),
        trx_type: trx.r#type,
        call_type: call.call_type,
    }
}

pub fn insert_events<'a>(block: &'a Block, events: &mut Events) {
    // Pre-allocate a default TransactionTrace to avoid creating it multiple times
    let default_trace = TransactionTrace::default();
    let default_call = Call::default();

    // EXTENDED
    // balance changes at block level
    for balance_change in &block.balance_changes {
        // Block Rewards as transfer
        if let Some(transfer) = get_transfer_from_block_reward(balance_change) {
            events.transfers.push(to_transfer(&default_trace, &default_call, transfer));
        }

        // Block Rewards as balance change
        if is_valid_balance_change(balance_change) {
            events
                .balance_changes
                .push(to_balance_change(&default_trace, &default_call, balance_change, Algorithm::BlockReward));
        }
    }

    // balance changes at system call level
    for call in &block.system_calls {
        for balance_change in &call.balance_changes {
            if is_valid_balance_change(balance_change) {
                events
                    .balance_changes
                    .push(to_balance_change(&default_trace, call, balance_change, Algorithm::System));
            }
        }
    }

    // to compute the burned portion of transaction fee
    let header = block.header.clone().expect("header is required");
    let base_fee_per_gas = match header.base_fee_per_gas {
        Some(base_fee_per_gas) => BigInt::from_unsigned_bytes_be(&base_fee_per_gas.bytes),
        None => BigInt::zero(),
    };

    // iterate over successful transactions
    for trx in block.transactions() {
        // transaction fee
        for transfer in get_transfer_from_transaction_fee(trx, &base_fee_per_gas, &header.coinbase) {
            events.transfers.push(to_transfer(trx, &default_call, transfer));
        }
        // find all transfers from transactions
        if let Some(transfer) = get_transfer_from_transaction(trx) {
            events.transfers.push(to_transfer(trx, &default_call, transfer));
        }
        // EXTENDED
        // find all transfers from calls
        for call_view in trx.calls() {
            if let Some(transfer) = get_transfer_from_call(call_view.call) {
                events.transfers.push(to_transfer(trx, call_view.call, transfer));
            }
        }
    }

    // EXTENDED
    // iterate over all transactions including failed ones
    for trx in &block.transaction_traces {
        for call_view in trx.calls() {
            // balance changes
            for balance_change in &call_view.call.balance_changes {
                let is_failed = is_failed_transaction(trx);

                // failed transactions with gas balance changes are still considered as valid balance changes
                let algorithm = if is_failed && is_gas_balance_change(balance_change) {
                    Algorithm::Gas
                // skip failed transactions
                } else if is_failed {
                    continue;
                // valid balance change
                } else {
                    Algorithm::Call
                };

                // balance change
                if is_valid_balance_change(balance_change) {
                    events.balance_changes.push(to_balance_change(trx, call_view.call, balance_change, algorithm));
                }
            }
        }
    }
}
