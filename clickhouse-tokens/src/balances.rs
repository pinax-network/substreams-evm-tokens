use common::bytes_to_hex;
use proto::pb::evm::erc20::balances::v1::{BalanceByAccount, Events};
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Row;

use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};

pub fn process_balances(prefix: &str, tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: Events, mut index: u64) -> u64 {
    // Process ERC-20 balance changes
    for event in events.balance_changes {
        process_balance_change(prefix, tables, clock, event, index);
        index += 1;
    }

    // Process ERC-20 transfers
    for event in events.transfers {
        process_transfer(prefix, tables, clock, event, index);
        index += 1;
    }
    index
}

fn process_balance_change(prefix: &str, tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: BalanceChange, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row(&format!("{}balance_changes", prefix).to_string(), key)
        .set("address", bytes_to_hex(&event.address))
        .set("contract", bytes_to_hex(&event.contract))
        .set("old_balance", event.old_balance.as_ref().unwrap_or(&"0".to_string()))
        .set("new_balance", &event.new_balance);

    set_debug(event.algorithm(), event.trx_type(), event.call_type(), Some(event.reason()), row);
    set_caller(event.caller, row);
    set_ordering(index, event.ordinal, clock, row);
    set_tx_hash(event.transaction_id, row);
    set_clock(clock, row);
}

fn process_transfer(prefix: &str, tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Transfer, index: u64) {
    let key = common_key(clock, event.ordinal);
    let row = tables
        .create_row(&format!("{}transfers", prefix).to_string(), key)
        .set("contract", bytes_to_hex(&event.contract))
        .set("from", bytes_to_hex(&event.from))
        .set("to", bytes_to_hex(&event.to))
        .set("value", &event.value);

    set_debug(event.algorithm(), event.trx_type(), event.call_type(), None, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_caller(event.caller, row);
    set_tx_hash(event.transaction_id, row);
    set_clock(clock, row);
}

pub fn set_debug(algorithm: Algorithm, trx_type: Type, call_type: CallType, reason: Option<Reason>, row: &mut Row) {
    row.set("algorithm", algorithm.as_str_name())
        .set("trx_type", trx_type.as_str_name())
        .set("call_type", call_type.as_str_name());
    if let Some(reason) = reason {
        row.set("reason", reason.as_str_name());
    }
}
