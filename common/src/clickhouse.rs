use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Row;

use crate::{bytes_to_hex, to_global_sequence, Address, Hash};

pub fn common_key(clock: &Clock, index: u64) -> [(&'static str, String); 3] {
    let seconds = clock.timestamp.as_ref().expect("clock.timestamp is required").seconds;
    [
        ("timestamp", seconds.to_string()),
        ("block_num", clock.number.to_string()),
        ("index", index.to_string()),
    ]
}

pub fn log_key(clock: &Clock, log_index: u32) -> [(&'static str, String); 4] {
    let seconds = clock.timestamp.as_ref().expect("clock.timestamp is required").seconds;
    [
        ("timestamp", seconds.to_string()),
        ("block_num", clock.number.to_string()),
        ("block_hash", format!("0x{}", &clock.id)),
        ("log_index", log_index.to_string()),
    ]
}

// Helper function to set clock data in a row
pub fn set_clock(clock: &Clock, row: &mut Row) {
    row.set("block_num", clock.number.to_string())
        .set("block_hash", format!("0x{}", &clock.id))
        .set("timestamp", clock.timestamp.as_ref().expect("missing timestamp").seconds.to_string());
}

pub fn set_log(clock: &Clock, index: u64, tx_hash: Hash, contract: Address, ordinal: u64, caller: Option<Address>, row: &mut Row) {
    set_bytes(Some(tx_hash), "tx_hash", row);
    set_bytes(Some(contract), "contract", row);
    set_bytes(caller, "caller", row);
    set_ordering(index, Some(ordinal), clock, row);
    set_clock(&clock, row);
}

pub fn set_log_v2(clock: &Clock, tx_hash: Hash, contract: Address, caller: Option<Address>, row: &mut Row) {
    set_bytes(Some(tx_hash), "tx_hash", row);
    set_bytes(Some(contract), "contract", row);
    set_bytes(caller, "caller", row);
    set_clock(&clock, row);
}

pub fn set_tx_hash(tx_hash: Option<Hash>, row: &mut Row) {
    set_bytes(tx_hash, "tx_hash", row);
}

pub fn set_caller(caller: Option<Hash>, row: &mut Row) {
    set_bytes(caller, "caller", row);
}

pub fn set_ordering(index: u64, ordinal: Option<u64>, clock: &Clock, row: &mut Row) {
    row.set("index", index)
        .set("ordinal", ordinal.unwrap_or(0))
        .set("global_sequence", to_global_sequence(clock, index));
}

pub fn set_bytes(bytes: Option<Hash>, name: &str, row: &mut Row) {
    match bytes {
        Some(data) => row.set(name, bytes_to_hex(&data)),
        None => row.set(name, "".to_string()),
    };
}
