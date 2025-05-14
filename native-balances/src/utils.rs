use substreams::scalar::BigInt;
use substreams_ethereum::pb::eth::v2::{balance_change::Reason, BalanceChange, Call, TransactionTrace, TransactionTraceStatus};

pub fn is_failed_transaction(trx: &TransactionTrace) -> bool {
    let status = trx.status();
    if status == TransactionTraceStatus::Reverted || status == TransactionTraceStatus::Failed {
        return true;
    }
    false
}

pub fn _is_failed_call(call: &Call) -> bool {
    if call.state_reverted || call.status_failed || call.status_reverted {
        return true;
    }
    false
}

pub fn is_gas_balance_change(balance_change: &BalanceChange) -> bool {
    let reason = balance_change.reason();
    if reason == Reason::GasBuy || reason == Reason::GasRefund || reason == Reason::RewardTransactionFee {
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

pub fn is_valid_balance_change(balance_change: &BalanceChange) -> bool {
    // balance must have new value
    match balance_change.new_value {
        Some(ref new_value) => {
            // balance must have different old and new value
            match balance_change.old_value {
                Some(ref old_value) => {
                    if old_value == new_value {
                        return false;
                    }
                }
                None => {}
            }
        }
        None => return false,
    }
    true
}
