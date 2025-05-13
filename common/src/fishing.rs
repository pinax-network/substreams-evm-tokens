use substreams_ethereum::pb::eth::v2::{Call, TransactionTrace};

// Ignore fishing token transfers, typically do not have any storage changes associated with them or child calls
// https://github.com/streamingfast/substreams-erc20-balance-changes/issues/18
pub fn is_fishing_transfer<'a>(trx: &'a TransactionTrace, call: &'a Call) -> bool {
    let mut count = call.storage_changes.len();
    count += count_all_child_call_storage_changes(call, trx);
    if count == 0 {
        return true;
    }
    false
}

pub fn count_all_child_call_storage_changes(original: &Call, trx: &TransactionTrace) -> usize {
    trx.calls
        .iter()
        .filter(|call| call.parent_index == original.index)
        .map(|call| call.storage_changes.len())
        .sum()
}
