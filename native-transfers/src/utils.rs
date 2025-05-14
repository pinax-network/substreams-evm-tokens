use substreams::scalar::BigInt;
use substreams_ethereum::pb::eth::v2::{BalanceChange, Call, TransactionTrace, TransactionTraceStatus};

pub fn is_failed_transaction(trx: &TransactionTrace) -> bool {
    let status = trx.status();
    if status == TransactionTraceStatus::Reverted || status == TransactionTraceStatus::Failed {
        return true;
    }
    false
}

pub fn is_failed_call(call: &Call) -> bool {
    if call.state_reverted || call.status_failed || call.status_reverted {
        return true;
    }
    false
}

pub fn get_balances(balance_change: &BalanceChange) -> (BigInt, BigInt) {
    let old_balance = balance_change
        .old_value
        .as_ref()
        .map(|v| BigInt::from_unsigned_bytes_be(v.bytes.as_ref()))
        .unwrap_or_else(BigInt::zero);

    let new_balance = balance_change
        .new_value
        .as_ref()
        .map(|v| BigInt::from_unsigned_bytes_be(v.bytes.as_ref()))
        .unwrap_or_else(BigInt::zero);

    (old_balance, new_balance)
}
