use std::{collections::HashMap, str::FromStr};

use common::Address;
use substreams::{scalar::BigInt, Hex};
use substreams_abis::evm::nfts;
use substreams_abis::evm::token::erc721;
use substreams_ethereum::rpc::RpcBatch;

static CHUNK_SIZE: usize = 100;

// Returns the token collection name.
pub fn batch_name(contracts: Vec<Address>) -> HashMap<Address, String> {
    let mut results: HashMap<Address, String> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE) {
        let batch = chunks
            .iter()
            .fold(RpcBatch::new(), |batch, address| batch.add(erc721::functions::Name {}, address.to_vec()));
        let responses = batch.execute().expect("failed to execute erc721::functions::Name RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            if let Some(name) = RpcBatch::decode::<String, erc721::functions::Name>(&responses[i]) {
                results.insert(address.to_vec(), name);
            } else {
                substreams::log::info!("Failed to decode erc721::functions::Name for address={:?}", Hex::encode(address));
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
            .fold(RpcBatch::new(), |batch, address| batch.add(erc721::functions::Symbol {}, address.to_vec()));
        let responses = batch.execute().expect("failed to execute erc721::functions::Symbol RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            if let Some(symbol) = RpcBatch::decode::<String, erc721::functions::Symbol>(&responses[i]) {
                results.insert(address.to_vec(), symbol);
            } else {
                substreams::log::info!("Failed to decode erc721::functions::Symbol for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

// Returns the token URI.
pub fn batch_token_uri(token_ids: Vec<(Address, String)>) -> HashMap<(Address, String), String> {
    let mut results: HashMap<(Address, String), String> = HashMap::with_capacity(token_ids.len());

    for chunk in token_ids.chunks(CHUNK_SIZE) {
        let batch = chunk.iter().fold(RpcBatch::new(), |batch, (address, id)| {
            batch.add(
                erc721::functions::TokenUri {
                    token_id: BigInt::from_str(id).unwrap(),
                },
                address.to_vec(),
            )
        });
        let responses = batch.execute().expect("failed to execute erc721::functions::TokenUri batch").responses;
        for (i, (address, token_id)) in chunk.iter().enumerate() {
            if let Some(uri) = RpcBatch::decode::<String, erc721::functions::TokenUri>(&responses[i]) {
                if !uri.is_empty() {
                    results.insert((address.to_vec(), token_id.to_string()), parse_uri(&uri));
                }
            } else {
                substreams::log::info!("Failed to decode TokenUri for address={:?} token_id={:?}", Hex::encode(address), token_id);
            }
        }
    }
    results
}

// Returns the token collection name.
pub fn batch_base_uri(contracts: Vec<Address>) -> HashMap<Address, String> {
    let mut results: HashMap<Address, String> = HashMap::new();
    for chunks in contracts.chunks(CHUNK_SIZE / 2) {
        let batch = chunks.iter().fold(RpcBatch::new(), |batch, address| {
            batch
                .add(nfts::boredapeyachtclub::functions::BaseUri {}, address.to_vec())
                .add(nfts::pudgypenguins::functions::BaseTokenUri {}, address.to_vec())
        });
        let responses = batch.execute().expect("failed to execute functions::BaseUri RpcBatch").responses;
        for (i, address) in chunks.iter().enumerate() {
            // baseUri
            if let Some(value) = RpcBatch::decode::<String, nfts::boredapeyachtclub::functions::BaseUri>(&responses[i * 2]) {
                if !value.is_empty() {
                    results.insert(address.to_vec(), parse_uri(&value));
                }
            } else {
                substreams::log::info!("Failed to decode functions::BaseUri for address={:?}", Hex::encode(address));
            }
            // baseTokenUri
            if let Some(value) = RpcBatch::decode::<String, nfts::pudgypenguins::functions::BaseTokenUri>(&responses[i * 2 + 1]) {
                if !value.is_empty() {
                    results.insert(address.to_vec(), parse_uri(&value));
                }
            } else {
                substreams::log::info!("Failed to decode functions::BaseTokenUri for address={:?}", Hex::encode(address));
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

pub fn parse_uri(uri: &str) -> String {
    uri.trim_end_matches('\0').to_string()
}
