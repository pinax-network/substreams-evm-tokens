use std::collections::HashMap;

use common::Address;
use substreams::{scalar::BigInt, Hex};
use substreams_abis::evm::nfts;
use substreams_abis::evm::token::erc20;
use substreams_ethereum::rpc::RpcBatch;

static CHUNK_SIZE: usize = 100;

// Returns the token collection name.
pub fn batch_name(contracts: Vec<Address>) -> HashMap<Address, String> {
    let mut results: HashMap<Address, String> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks
            .iter()
            .fold(RpcBatch::new(), |batch, address| batch.add(erc20::functions::Name {}, address.to_vec()));
        let responses = batch.execute().expect("failed to execute erc20::functions::Name RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            if let Some(name) = RpcBatch::decode::<String, erc20::functions::Name>(&responses[i]) {
                // handle empty name
                if name.is_empty() {
                    substreams::log::info!("Empty name for address={:?}", Hex::encode(address));
                } else {
                    results.insert(address.to_vec(), name);
                }
            } else {
                substreams::log::info!("Failed to decode erc20::functions::Name for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

pub fn batch_symbol(contracts: Vec<Address>) -> HashMap<Address, String> {
    let mut results: HashMap<Address, String> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks
            .iter()
            .fold(RpcBatch::new(), |batch, address| batch.add(erc20::functions::Symbol {}, address.to_vec()));
        let responses = batch.execute().expect("failed to execute erc20::functions::Symbol RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            if let Some(symbol) = RpcBatch::decode::<String, erc20::functions::Symbol>(&responses[i]) {
                // Handle empty symbol
                if symbol.is_empty() {
                    substreams::log::info!("Empty symbol for address={:?}", Hex::encode(address));
                } else {
                    results.insert(address.to_vec(), symbol);
                }
            } else {
                substreams::log::info!("Failed to decode erc20::functions::Symbol for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

pub fn batch_decimals(contracts: Vec<Address>) -> HashMap<Address, BigInt> {
    let mut results: HashMap<Address, BigInt> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks
            .iter()
            .fold(RpcBatch::new(), |batch, address| batch.add(erc20::functions::Decimals {}, address.to_vec()));
        let responses = batch.execute().expect("failed to execute erc20::functions::Symbol RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            if let Some(decimals) = RpcBatch::decode::<BigInt, erc20::functions::Decimals>(&responses[i]) {
                results.insert(address.to_vec(), decimals);
            } else {
                substreams::log::info!("Failed to decode erc20::functions::Symbol for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

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
