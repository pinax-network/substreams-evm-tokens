use std::collections::HashMap;

use common::{bigint_to_uint8, bytes32_to_string, Address};
use substreams::{scalar::BigInt, Hex};
use substreams_abis::evm::token::erc20;
use substreams_abis::evm::tokens::sai;
use substreams_ethereum::rpc::RpcBatch;

static CHUNK_SIZE: usize = 100;

// Returns the token collection name.
pub fn batch_name(contracts: Vec<Address>) -> HashMap<Address, String> {
    let mut results: HashMap<Address, String> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks.iter().fold(RpcBatch::new(), |batch, address| {
            batch
                .add(erc20::functions::Name {}, address.to_vec())
                .add(sai::functions::Name {}, address.to_vec())
        });
        let responses = batch.execute().expect("failed to execute erc20::functions::Name RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            // erc20::Name
            if let Some(name) = RpcBatch::decode::<String, erc20::functions::Name>(&responses[i * 2]) {
                // Handle empty
                if let Some(name) = parse_string(&name) {
                    results.insert(address.to_vec(), name);
                    continue;
                } else {
                    substreams::log::info!("Empty name for address={:?}", Hex::encode(address));
                }
            } else {
                substreams::log::info!("Failed to decode erc20::functions::Name for address={:?}", Hex::encode(address));
            }

            // sai::Name
            if let Some(bytes32) = RpcBatch::decode::<[u8; 32], sai::functions::Name>(&responses[i * 2 + 1]) {
                let name = bytes32_to_string(&bytes32.to_vec());

                // Handle empty name
                if name.is_empty() {
                    substreams::log::info!("Empty name for address={:?}", Hex::encode(address));
                } else {
                    results.insert(address.to_vec(), name);
                    continue;
                }
            } else {
                substreams::log::info!("Failed to decode sai::functions::Name for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

pub fn batch_symbol(contracts: Vec<Address>) -> HashMap<Address, String> {
    let mut results: HashMap<Address, String> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks.iter().fold(RpcBatch::new(), |batch, address| {
            batch
                .add(erc20::functions::Symbol {}, address.to_vec())
                .add(sai::functions::Symbol {}, address.to_vec())
        });
        let responses = batch.execute().expect("failed to execute erc20::functions::Symbol RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            // erc20::Symbol
            if let Some(symbol) = RpcBatch::decode::<String, erc20::functions::Symbol>(&responses[i * 2]) {
                // Handle empty symbol
                if let Some(symbol) = parse_string(&symbol) {
                    results.insert(address.to_vec(), symbol);
                    continue;
                } else {
                    substreams::log::info!("Empty symbol for address={:?}", Hex::encode(address));
                }
            } else {
                substreams::log::info!("Failed to decode erc20::functions::Symbol for address={:?}", Hex::encode(address));
            }

            // sai::Symbol
            if let Some(symbol_32) = RpcBatch::decode::<[u8; 32], sai::functions::Symbol>(&responses[i * 2 + 1]) {
                let symbol = bytes32_to_string(&symbol_32.to_vec());

                // Handle empty symbol
                if let Some(symbol) = parse_string(&symbol) {
                    results.insert(address.to_vec(), symbol);
                    continue;
                } else {
                    substreams::log::info!("Empty symbol for address={:?}", Hex::encode(address));
                }
            } else {
                substreams::log::info!("Failed to decode sai::functions::Symbol for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

pub fn batch_decimals(contracts: Vec<Address>) -> HashMap<Address, i32> {
    let mut results: HashMap<Address, i32> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks
            .iter()
            .fold(RpcBatch::new(), |batch, address| batch.add(erc20::functions::Decimals {}, address.to_vec()));
        let responses = batch.execute().expect("failed to execute erc20::functions::Decimals RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            // erc20::Decimals
            if let Some(decimals) = RpcBatch::decode::<BigInt, erc20::functions::Decimals>(&responses[i]) {
                if let Some(decimals_u8) = bigint_to_uint8(&decimals) {
                    results.insert(address.to_vec(), decimals_u8);
                } else {
                    substreams::log::info!("Decimals out of range for address={:?}", Hex::encode(address));
                }
            } else {
                substreams::log::info!("Failed to decode erc20::functions::Decimals for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

pub fn parse_string(str: &str) -> Option<String> {
    let trimmed = str.trim().trim_end_matches('\0').to_string();
    if !trimmed.is_empty() {
        return Some(trimmed);
    }
    None
}
