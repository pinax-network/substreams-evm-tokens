use common::{bytes_to_hex, to_global_sequence, Hash};
use proto::pb::{evm::tokens::balances::v1::Algorithm, sf::ethereum::r#type::v2::{balance_change::Reason, transaction_trace::Type, CallType}};
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Row;

pub fn common_key(clock: &Clock, index: u64) -> [(&'static str, String); 3] {
    let seconds = clock.timestamp.as_ref().expect("clock.timestamp is required").seconds;
    [
        ("timestamp", seconds.to_string()),
        ("block_num", clock.number.to_string()),
        ("index", index.to_string()),
    ]
}

// Helper function to set clock data in a row
pub fn set_clock(clock: &Clock, row: &mut Row) {
    row.set("block_num", clock.number.to_string())
        .set("block_hash", format!("0x{}", &clock.id))
        .set("timestamp", clock.timestamp.as_ref().expect("missing timestamp").seconds.to_string());
}


pub fn set_transaction_id(transaction_id: Option<Hash>, row: &mut Row) {
    set_bytes(transaction_id, "transaction_id", row);
}

pub fn set_caller(caller: Option<Hash>, row: &mut Row) {
    set_bytes(caller, "caller", row);
}

pub fn set_ordering(index: u64, ordinal: Option<u64>, clock: &Clock, row: &mut Row) {
    row.set("index", index)
        .set("ordinal", ordinal.unwrap_or(0))
        .set("global_sequence", to_global_sequence(clock, index));
}

pub fn set_debug(algorithm: Algorithm, trx_type: Type, call_type: CallType, reason: Option<Reason>, row: &mut Row) {
    row
        .set("algorithm", algorithm.as_str_name())
        .set("trx_type", trx_type.as_str_name())
        .set("call_type", call_type.as_str_name());
    if let Some(reason) = reason {
        row.set("reason", reason.as_str_name());
    }
}

pub fn set_bytes(bytes: Option<Hash>, name: &str, row: &mut Row) {
    match bytes {
        Some(data) => row.set(name, bytes_to_hex(&data)),
        None => row.set(name, "".to_string()),
    };
}
