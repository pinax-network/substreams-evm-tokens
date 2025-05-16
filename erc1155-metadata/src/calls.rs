use std::{collections::HashMap, str::FromStr};

use common::Address;
use substreams::{scalar::BigInt, Hex};
use substreams_abis::evm::token::erc1155;
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
                if name.is_empty() {
                    continue;
                }
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
                if symbol.is_empty() {
                    substreams::log::info!("Empty symbol for address={:?}", Hex::encode(address));
                    continue;
                }
                results.insert(address.to_vec(), symbol);
            } else {
                substreams::log::info!("Failed to decode erc721::functions::Symbol for address={:?}", Hex::encode(address));
            }
        }
    }
    results
}

// Returns the token URI.
pub fn batch_uri(token_ids: Vec<(Address, String)>) -> HashMap<(Address, String), String> {
    let mut results: HashMap<(Address, String), String> = HashMap::with_capacity(token_ids.len());

    for chunk in token_ids.chunks(CHUNK_SIZE) {
        let batch = chunk.iter().fold(RpcBatch::new(), |batch, (address, id)| {
            batch.add(
                erc1155::functions::Uri {
                    id: BigInt::from_str(id).unwrap(),
                },
                address.to_vec(),
            )
        });
        let responses = batch.execute().expect("failed to execute erc1155::functions::Uri batch").responses;
        for (i, (address, token_id)) in chunk.iter().enumerate() {
            if let Some(uri) = RpcBatch::decode::<String, erc1155::functions::Uri>(&responses[i]) {
                if !uri.is_empty() {
                    results.insert((address.to_vec(), token_id.to_string()), parse_uri(&uri));
                    continue;
                }
            } else {
                substreams::log::info!("Failed to decode erc1155::Uri for address={:?} token_id={:?}", Hex::encode(address), token_id);
            }
        }
    }
    results
}

pub fn parse_uri(uri: &str) -> String {
    uri.trim_end_matches('\0').to_string()
}
