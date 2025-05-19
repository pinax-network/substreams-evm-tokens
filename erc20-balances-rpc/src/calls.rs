use std::collections::HashMap;

use common::Address;
use substreams::{log, scalar::BigInt, Hex};
use substreams_abis::evm::token::erc20;
use substreams_ethereum::rpc::RpcBatch;

// Returns the token URI.
pub fn batch_balance_of(contract_owners: Vec<(Address, Address)>, chunk_size: usize) -> HashMap<(Address, Address), BigInt> {
    let mut results: HashMap<(Address, Address), BigInt> = HashMap::with_capacity(contract_owners.len());

    for chunk in contract_owners.chunks(chunk_size) {
        let batch = chunk.iter().fold(RpcBatch::new(), |batch, (contract, owner)| {
            batch.add(erc20::functions::BalanceOf { account: owner.to_vec() }, contract.to_vec())
        });
        let responses = batch.execute().expect("failed to execute erc20::functions::BalanceOf batch").responses;
        for (i, (contract, owner)) in chunk.iter().enumerate() {
            if let Some(value) = RpcBatch::decode::<BigInt, erc20::functions::BalanceOf>(&responses[i]) {
                results.insert((contract.to_vec(), owner.to_vec()), value);
            } else {
                substreams::log::info!(
                    "Failed to decode erc20::BalanceOf for contract={:?} owner={:?}",
                    Hex::encode(contract),
                    Hex::encode(owner)
                );
            }
        }
    }
    log::info!(
        "\nBalances={}\nRpcBatch={}\nMissing={}",
        contract_owners.len(),
        contract_owners.chunks(chunk_size).len(),
        contract_owners.len() - results.len()
    );
    results
}
