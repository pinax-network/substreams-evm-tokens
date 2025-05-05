pub mod clickhouse;
use prost_types::Timestamp;
use substreams::{hex, log, pb::substreams::Clock, scalar::BigInt, Hex};
use substreams_ethereum::pb::eth::v2::{block::DetailLevel, Block, Log, TransactionTrace};

pub type Address = Vec<u8>;
pub type Hash = Vec<u8>;
pub const NULL_ADDRESS: [u8; 20] = hex!("0000000000000000000000000000000000000000");
pub const NULL_HASH: [u8; 32] = hex!("0000000000000000000000000000000000000000000000000000000000000000");
pub const NATIVE_ADDRESS: [u8; 20] = hex!("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");

pub fn update_genesis_clock(mut clock: Clock) -> Clock {
    // only applies to the first block of the stream
    if clock.number != 0 {
        return clock;
    }
    // ETH Mainnet
    if clock.id == "d4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3" {
        clock.timestamp = Some(Timestamp { seconds: 1438269973, nanos: 0 });
        return clock;
    // Arbitrum One
    } else if clock.id == "7ee576b35482195fc49205cec9af72ce14f003b9ae69f6ba0faef4514be8b442" {
        clock.timestamp = Some(Timestamp { seconds: 1622240000, nanos: 0 });
        return clock;
    // Arbitrum Nova
    } else if clock.id == "2ad24e03026118f9b3a48626f0636e38c93660e90a6812e853a99aa8c5371561" {
        clock.timestamp = Some(Timestamp { seconds: 1656120000, nanos: 0 });
        return clock;
    // Boba
    } else if clock.id == "dcd9e6a8f9973eaa62da2874959cb152faeb4fd6929177bd6335a1a16074ef9c" {
        clock.timestamp = Some(Timestamp {
            seconds: 1635393439, // Block 1
            nanos: 0,
        });
        return clock;
    }
    clock
}

// In ClickHouse, an aggregate function like argMax can only take one expression as the "ordering" argument.
// So we typically combine (block_num, index) into a single monotonic integer.
// For example, if each of block_num and index fits in 32 bits, we can do:
// max(toUInt64(block_num) * 2^32 + index) AS version
pub fn to_global_sequence(clock: &Clock, index: u64) -> u64 {
    (clock.number << 32) + index
}

pub fn bytes_to_hex(bytes: &[u8]) -> String {
    format! {"0x{}", Hex::encode(bytes)}.to_string()
}

pub fn extend_from_address(address1: &Address, address2: &Address) -> Vec<u8> {
    // Create key with pre-allocated capacity
    let mut key = Vec::with_capacity(address1.len() + address2.len());
    key.extend_from_slice(&address1);
    key.extend_from_slice(&address2);
    key
}

pub fn to_optional_vector(vec: &Vec<u8>) -> Option<Vec<u8>> {
    if vec.len() > 0 {
        if vec.len() == 32 && vec.to_vec() == NULL_HASH {
            return None;
        }
        if vec.len() == 20 && vec.to_vec() == NULL_ADDRESS {
            return None;
        }
        Some(vec.to_vec())
    } else {
        None
    }
}

pub fn bytes32_to_string(bytes: &[u8]) -> String {
    let s = String::from_utf8_lossy(&bytes);
    s.trim_matches('\0').to_string()
}

// Used to enforce ERC-20 decimals to be between 0 and 255
pub fn bigint_to_uint8(bigint: &substreams::scalar::BigInt) -> Option<i32> {
    if bigint.lt(&BigInt::zero()) {
        log::info!("bigint_to_uint8: value is negative");
        return None;
    }
    if bigint.gt(&BigInt::from(255)) {
        log::info!("bigint_to_uint8: value is greater than 255");
        return None;
    }
    Some(bigint.to_i32())
}

pub fn bigint_to_uint64(bigint: &substreams::scalar::BigInt) -> Option<u64> {
    if bigint.lt(&BigInt::zero()) {
        log::info!("bigint_to_uint64: value is negative");
        return None;
    }
    if bigint.gt(&BigInt::from(u64::MAX)) {
        log::info!("bigint_to_uint64: value is greater than u64::MAX");
        return None;
    }
    Some(bigint.to_u64())
}

// Convert a 32-byte hash to a 20-byte address
// Edge case transaction: 0x083752500764e30f9f6b13c8a6d7d80214b907bd897937b35de78371ca85009e
pub fn bytes_to_address(bytes: &[u8]) -> Vec<u8> {
    let start = bytes.len().saturating_sub(20);
    bytes[start..].to_vec()
}

// Timestamp to date conversion
// ex: 2015-07-30T16:02:18Z => 2015-07-30
pub fn clock_to_date(clock: &Clock) -> String {
    match clock.timestamp.as_ref().expect("timestamp missing").to_string().split('T').next() {
        Some(date) => date.to_string(),
        _ => "".to_string(),
    }
}

pub fn is_zero_address<T: AsRef<[u8]>>(addr: T) -> bool {
    addr.as_ref() == NULL_ADDRESS
}

pub fn logs_with_caller<'a>(block: &'a Block, trx: &'a TransactionTrace) -> Vec<(&'a Log, Option<Address>)> {
    let mut results = vec![];

    if block.detail_level() == DetailLevel::DetaillevelExtended {
        for (log, call_view) in trx.logs_with_calls() {
            results.push((log, Some(call_view.call.caller.to_vec())));
        }
    } else {
        for log in trx.receipt().logs() {
            results.push((log.log, None));
        }
    }

    results
}
