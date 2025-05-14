mod transfers;
mod utils;

use common::Hash;
use proto::pb::evm::native::transfers::v1::{Events, Transfer};
use substreams::{errors::Error, scalar::BigInt};
use substreams_ethereum::pb::eth::v2::Block;
use transfers::TransferStruct;

use crate::transfers::{get_transfer_from_block_reward, get_transfer_from_call, get_transfer_from_transaction, get_transfer_from_transaction_fee};

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<Events, Error> {
    let mut events = Events::default();

    // EXTENDED
    // balance changes at block level
    for balance_change in &block.balance_changes {
        // Block Rewards as transfer
        if let Some(transfer) = get_transfer_from_block_reward(balance_change) {
            events.extended_transfers_from_block_rewards.push(to_transfer(None, transfer));
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
            events.transfers_from_fees.push(to_transfer(Some(trx.hash.clone()), transfer));
        }
        // find all transfers from transactions
        if let Some(transfer) = get_transfer_from_transaction(trx) {
            events.transfers.push(to_transfer(Some(trx.hash.clone()), transfer));
        }
        // EXTENDED
        // find all transfers from calls
        for call_view in trx.calls() {
            if let Some(transfer) = get_transfer_from_call(call_view.call) {
                events.extended_transfers_from_calls.push(to_transfer(Some(trx.hash.clone()), transfer));
            }
        }
    }
    Ok(events)
}

pub fn to_transfer(tx_hash: Option<Hash>, transfer: TransferStruct) -> Transfer {
    Transfer {
        // -- transaction --
        tx_hash,

        // -- transfer --
        from: transfer.from,
        to: transfer.to,
        value: transfer.value.to_string(),
    }
}
