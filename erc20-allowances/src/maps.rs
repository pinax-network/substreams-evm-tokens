use std::collections::HashMap;

use crate::algorithms::{algorithm1_call::get_owner_from_erc20_balance_change, utils::is_erc20_valid_balance};
use crate::algorithms::algorithm2_child_calls::get_all_child_call_storage_changes;
use crate::algorithms::events::get_erc20_transfer;
use crate::algorithms::utils::addresses_for_storage_keys;
use common::{extend_from_address, Address, Hash};
use proto::pb::evm::tokens::balances::v1::{Algorithm, Approval, BalanceChange, Events, Transfer};
use substreams::errors::Error;
use substreams_abis::evm::token::erc20::events::Transfer as TransferAbi;
use substreams_abis::evm::token::erc20::events::Approval as ApprovalAbi;
use substreams::scalar::BigInt;
use substreams_ethereum::pb::eth::v2::{Block, Call, Log, StorageChange, TransactionTrace};
use substreams_ethereum::Event;

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<Events, Error> {
    let mut events = Events::default();
    insert_events(&block, &mut events);
    Ok(events)
}

pub fn to_transfer<'a>(trx: &'a TransactionTrace, call: &'a Call, log: &'a Log, transfer: &'a TransferAbi, algorithm: Algorithm) -> Transfer {
    Transfer {
        // -- transaction --
        transaction_id: Some(trx.hash.to_vec()),

        // -- call --
        caller: Some(call.caller.to_vec()),

        // -- ordering --
        ordinal: log.ordinal,

        // -- transfer --
        contract: log.address.to_vec(),
        from: transfer.from.to_vec(),
        to: transfer.to.to_vec(),
        value: transfer.value.to_string(),

        // -- debug --
        algorithm: algorithm.into(),
        trx_type: trx.r#type,
        call_type: call.call_type,
    }
}

pub fn to_balance_change<'a>(
    trx: &'a TransactionTrace,
    call: &'a Call,
    address: Address,
    transfer: &'a TransferAbi,
    storage_change: &'a StorageChange,
    algorithm: Algorithm,
) -> BalanceChange {
    let old_balance = BigInt::from_unsigned_bytes_be(&storage_change.old_value);
    let new_balance = BigInt::from_unsigned_bytes_be(&storage_change.new_value);

    // Yield one of two results depending on whether the storage change
    // matches the transfer's balance changes
    let algorithm = if is_erc20_valid_balance(transfer, storage_change) {
        algorithm
    } else {
        Algorithm::BalanceNotMatchTransfer
    };

    BalanceChange {
        // -- transaction
        transaction_id: Some(trx.hash.to_vec()),

        // -- call --
        caller: Some(call.caller.to_vec()),

        // -- ordering --
        ordinal: Some(storage_change.ordinal),

        // -- balance change --
        contract: storage_change.address.to_vec(),
        address,
        old_balance: Some(old_balance.to_string()),
        new_balance: new_balance.to_string(),

        // -- debug --
        algorithm: algorithm.into(),
        trx_type: Some(trx.r#type),
        call_type: Some(call.call_type),
        reason: None,
    }
}

pub fn to_approval<'a>(trx: &'a TransactionTrace, call: &'a Call, log: &'a Log, approval: &'a ApprovalAbi) -> Approval {
    Approval {
        // -- transaction --
        transaction_id: Some(trx.hash.to_vec()),

        // -- call --
        caller: Some(call.caller.to_vec()),

        // -- ordering --
        ordinal: log.ordinal,

        // -- approval --
        contract: log.address.to_vec(),
        owner: approval.owner.to_vec(),
        spender: approval.spender.to_vec(),
        value: approval.value.to_string(),

        // -- debug --
        trx_type: trx.r#type,
        call_type: call.call_type,
    }
}

pub fn insert_events<'a>(block: &'a Block, events: &mut Events) {
    // We memoize the keccak address map by call because it is expensive to compute
    // Pre-allocate HashMaps to avoid initial reallocations
    let mut keccak_address_map = HashMap::with_capacity(block.transactions().count() * 2);
    let mut last_balance_changes: HashMap<Vec<u8>, BalanceChange> = HashMap::with_capacity(block.transactions().count() * 2);

    // Iterates over successful transactions
    for trx in block.transactions() {
        // Iterates over all logs in the transaction
        // excluding those from calls that were not recorded to the chain's state.
        for (log, call_view) in trx.logs_with_calls() {
            let call = call_view.as_ref();

            // -- Approval --
            match ApprovalAbi::match_and_decode(log) {
                Some(approval) => {
                    events.approvals.push(to_approval(trx, call, log, &approval));
                }
                None => {}
            }

            // -- Transfer --
            let transfer = match get_erc20_transfer(trx, call, log) {
                Some(transfer) => transfer,
                None => continue,
            };
            events.transfers.push(to_transfer(trx, call, log, &transfer, Algorithm::Log));

            // -- Balance Changes --
            keccak_address_map.extend(addresses_for_storage_keys(call)); // memoize
            let balance_changes = iter_balance_changes_algorithms(trx, call, &transfer, &keccak_address_map);
            for (address, storage_change, algorithm) in balance_changes {
                let balance_change = to_balance_change( trx, call, address, &transfer, storage_change, algorithm);
                let key = extend_from_address(&balance_change.contract, &balance_change.address);

                // overwrite balance change if it already exists
                last_balance_changes.insert(key, balance_change);

            }
        }
    }

    // insert only the last balance change for each contract + owner per block
    events.balance_changes.extend(last_balance_changes.into_values());
}

pub fn iter_balance_changes_algorithms<'a>(
    trx: &'a TransactionTrace,
    call: &'a Call,
    transfer: &'a TransferAbi,
    keccak_address_map: &'a HashMap<Hash, Address>,
) -> impl Iterator<Item = (Address, &'a StorageChange, Algorithm)> + 'a {
    // First iterator - algorithm #1 (normal case)
    let normal_changes = call.storage_changes.iter().filter_map(move |storage_change| {
        get_owner_from_erc20_balance_change(transfer, storage_change, keccak_address_map)
            .map(|owner| (owner, storage_change, Algorithm::Call))
    });

    // Second iterator - algorithm #2 (child calls)
    let child_changes = get_all_child_call_storage_changes(call, trx).filter_map(move |storage_change| {
        get_owner_from_erc20_balance_change(transfer, storage_change, keccak_address_map)
            .map(|owner| (owner, storage_change, Algorithm::ChildCalls))
    });

    normal_changes.chain(child_changes)
}
