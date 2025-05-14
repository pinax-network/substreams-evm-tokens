use common::{Address, NULL_ADDRESS};
use substreams::scalar::BigInt;
use substreams_ethereum::pb::eth::v2::{balance_change::Reason, BalanceChange, Call, CallType, TransactionTrace};

use crate::utils::{get_balances, is_failed_call, is_failed_transaction};

#[derive(Default)]
pub struct TransferStruct {
    pub from: Address,
    pub to: Address,
    pub value: BigInt,
}

pub fn get_transfer_from_block_reward(balance_change: &BalanceChange) -> Option<TransferStruct> {
    if balance_change.reason() != Reason::RewardMineBlock {
        return None;
    }

    let (old_balance, new_balance) = get_balances(balance_change);
    let value = new_balance - old_balance;
    if value.le(&BigInt::zero()) {
        return None;
    }

    Some(TransferStruct {
        from: NULL_ADDRESS.to_vec(),
        to: balance_change.address.to_vec(),
        value,
    })
}

pub fn get_transfer_from_transaction(trx: &TransactionTrace) -> Option<TransferStruct> {
    if is_failed_transaction(trx) {
        return None;
    }

    let value = BigInt::from_unsigned_bytes_be(trx.value.as_ref()?.bytes.as_ref());
    if value.le(&BigInt::zero()) {
        return None;
    }

    Some(TransferStruct {
        from: trx.from.to_vec(),
        to: trx.to.to_vec(),
        value,
    })
}

pub fn get_transfer_from_call(call: &Call) -> Option<TransferStruct> {
    if is_failed_call(call) {
        return None;
    }

    // ignore calls with no value
    let value = BigInt::from_unsigned_bytes_be(call.value.as_ref()?.bytes.as_ref());
    if value.le(&BigInt::zero()) {
        return None;
    }
    // TO-DO: Validate this assumption
    // Test: contract calls
    // https://etherscan.io/tx/0xe28a0ad59830ada1e96b1274e9f1aa9d5aa8bcf34bfe25271968962a7dbad803#internal
    // Test: single ETH transfer
    // https://etherscan.io/tx/0xdc2cd99c61de744a502fed484d73468c2f60cb2ad8dfc9e891886e9c619302ef

    // ignore top-level calls
    if call.depth == 0 {
        return None;
    }

    // Test: tornado cash (block 9194719)
    // https://etherscan.io/tx/0x3b4f42376dbb1224d59e541636cc3704cccb9572067d8f9758312d432adb86a6

    // A DELEGATECALL executes another contract's code but uses the calling contract’s storage and balance.
    // There’s no separate transfer of ETH to the contract being called.
    // The original contract’s msg.sender, msg.value, and balance remain in play,
    // so you do not see an actual value transfer in the blockchain ledger for a DELEGATECALL.

    // only `call` type calls are considered transfers
    if call.call_type() != CallType::Call {
        return None;
    }

    Some(TransferStruct {
        from: call.caller.to_vec(),
        to: call.address.to_vec(),
        value,
    })
}

pub fn get_transfer_from_transaction_fee(trx: &TransactionTrace, base_fee_per_gas: &BigInt, coinbase: &Address) -> Vec<TransferStruct> {
    let mut transfers = Vec::new();

    let gas_price = match trx.gas_price.as_ref() {
        // valid price, 20 bytes or fewer (assumption that 20 bytes is the maximum size of a gas price)
        // https://github.com/pinax-network/substreams-evm-tokens/issues/34
        Some(data) if data.bytes.len() <= 20 => BigInt::from_unsigned_bytes_be(&data.bytes),

        // `None` **or** more than 20 bytes → treat as zero
        _ => BigInt::zero(),
    };
    let gas_used = BigInt::from(trx.gas_used);
    let transaction_fee = gas_price * &gas_used;
    let burn_fee = base_fee_per_gas * &gas_used;
    let fee_paid = transaction_fee - burn_fee.clone();

    if fee_paid.gt(&BigInt::zero()) {
        transfers.push(TransferStruct {
            from: trx.from.to_vec(),
            to: coinbase.to_vec(), // producer/miner address
            value: fee_paid,
        });
    }
    if burn_fee.gt(&BigInt::zero()) {
        transfers.push(TransferStruct {
            from: trx.from.to_vec(),
            to: NULL_ADDRESS.to_vec(), // burned fee
            value: burn_fee,
        });
    }

    transfers
}
