use crate::pb::evm::erc721::events::v1::Transaction;
use substreams::scalar::BigInt;
use substreams_ethereum::pb::eth::v2 as eth;

pub fn get_transactions(blk: &eth::Block, event_tx_hashes: &std::collections::HashSet<Vec<u8>>) -> Vec<Transaction> {
    let block_number = blk.number;
    let block_timestamp = blk.header.as_ref().and_then(|h| h.timestamp.as_ref()).map(|t| t.seconds as u64).unwrap_or(0);
    let block_hash = blk.hash.clone();

    blk.transaction_traces
        .iter()
        .filter(|trace| event_tx_hashes.contains(&trace.hash))
        .map(|trace| Transaction {
            block_number,
            block_timestamp,
            block_hash: block_hash.clone().into(),
            tx_hash: trace.hash.clone().into(),
            nonce: trace.nonce,
            position: trace.index,
            from_address: trace.from.clone().into(),
            to_address: trace.to.clone().into(),
            gas_limit: trace.gas_limit,
            gas_used: trace.gas_used,
            v: trace.v.clone().into(),
            r: trace.r.clone().into(),
            s: trace.s.clone().into(),
            input: trace.input.clone().into(),
            r#type: trace.r#type,
            value: trace
                .value
                .as_ref()
                .map(|v| BigInt::from_unsigned_bytes_be(&v.bytes).to_string())
                .unwrap_or_else(|| "0".to_string()),
            tx_fee: trace
                .gas_price
                .as_ref()
                .map(|gp| (BigInt::from_unsigned_bytes_be(&gp.bytes) * BigInt::from(trace.gas_used)).to_string())
                .unwrap_or_else(|| "0".to_string()),
            gas_price: trace
                .gas_price
                .as_ref()
                .map(|v| BigInt::from_unsigned_bytes_be(&v.bytes).to_string())
                .unwrap_or_else(|| "0".to_string()),
            cumulative_gas_used: trace.receipt.as_ref().map(|r| r.cumulative_gas_used).unwrap_or(0),
            max_fee_per_gas: trace
                .max_fee_per_gas
                .as_ref()
                .map(|v| BigInt::from_unsigned_bytes_be(&v.bytes).to_string())
                .unwrap_or_else(|| "0".to_string()),
            max_priority_fee_per_gas: trace
                .max_priority_fee_per_gas
                .as_ref()
                .map(|v| BigInt::from_unsigned_bytes_be(&v.bytes).to_string())
                .unwrap_or_else(|| "0".to_string()),
        })
        .collect()
}
