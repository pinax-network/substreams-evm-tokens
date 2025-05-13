use std::collections::HashMap;

use common::Address;
use substreams::{scalar::BigInt, Hex};
use substreams_abis::evm::nfts;
use substreams_ethereum::rpc::RpcBatch;

static CHUNK_SIZE: usize = 100;

pub fn batch_total_supply(contracts: Vec<Address>) -> HashMap<Address, BigInt> {
    let mut results: HashMap<Address, BigInt> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks.iter().fold(RpcBatch::new(), |batch, address| {
            batch.add(nfts::boredapeyachtclub::functions::TotalSupply {}, address.to_vec())
        });
        let responses = batch.execute().expect("failed to execute functions::TotalSupply RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            // TotalSupply
            if let Some(value) = RpcBatch::decode::<BigInt, nfts::boredapeyachtclub::functions::TotalSupply>(&responses[i]) {
                results.insert(address.to_vec(), value);
            } else {
                substreams::log::info!("Failed to decode functions::TotalSupply for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}
