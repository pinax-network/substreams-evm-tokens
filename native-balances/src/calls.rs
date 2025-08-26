use std::collections::HashMap;

use common::Address;
use substreams::{pb::substreams::Clock, scalar::BigInt};
use substreams_ethereum::{
    pb::eth::rpc::{RpcGetBalanceRequest, RpcGetBalanceRequests},
    rpc::eth_get_balance,
};

// Returns the token URI.
pub fn batch_balance_of<'a>(clock: &Clock, owners: &'a [&Address], chunk_size: usize) -> HashMap<&'a Address, BigInt> {
    let mut results: HashMap<&Address, BigInt> = HashMap::with_capacity(owners.len());

    let mut requests = RpcGetBalanceRequests {
        requests: Vec::with_capacity(owners.len()),
    };
    for owner in owners {
        requests.requests.push(RpcGetBalanceRequest {
            address: owner.to_vec(),
            block: clock.number.to_string(),
        });
    }
    let balances = eth_get_balance(&requests);
    for (i, owner) in owners.iter().enumerate() {
        results.insert(owner, balances[i]);
    }
    results
}
