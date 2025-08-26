use std::collections::HashMap;

use common::Address;
use substreams::scalar::BigInt;
use substreams_ethereum::{
    pb::eth::rpc::{RpcGetBalanceRequest, RpcGetBalanceRequests},
    rpc::eth_get_balance,
};

// Returns the token URI.
pub fn batch_eth_balance_of<'a>(block: u64, owners: &'a [&Address], _chunk_size: usize) -> HashMap<&'a Address, BigInt> {
    let mut results: HashMap<&Address, BigInt> = HashMap::with_capacity(owners.len());

    let mut requests = RpcGetBalanceRequests {
        requests: Vec::with_capacity(owners.len()),
    };
    for owner in owners {
        requests.requests.push(RpcGetBalanceRequest {
            address: owner.to_vec(),
            block: block.to_string(),
        });
    }
    let balances = eth_get_balance(&requests);
    for (i, owner) in owners.iter().enumerate() {
        let response = &balances.responses[i];
        if response.failed {
            continue;
        }
        results.insert(owner, BigInt::from_unsigned_bytes_be(&response.balance));
    }
    results
}
