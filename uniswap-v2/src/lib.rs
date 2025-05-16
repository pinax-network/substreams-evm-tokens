use common::logs_with_caller;
use proto::pb::evm::uniswap::v2 as uniswap;
use substreams::errors::Error;
use substreams_abis::evm::uniswap::v2::factory::events as factory;
use substreams_abis::evm::uniswap::v2::pair::events as pair;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<uniswap::Events, Error> {
    let mut events = uniswap::Events::default();

    // === Uniswap::V2 ===
    // https://github.com/Uniswap/v2-core/blob/master/contracts/UniswapV2Pair.sol
    // https://github.com/Uniswap/v2-core/blob/master/contracts/UniswapV2Factory.sol
    for trx in block.transactions() {
        for (log, caller) in logs_with_caller(&block, trx) {
            // Uniswap::V2::Pair:Sync
            if let Some(event) = pair::Sync::match_and_decode(log) {
                events.sync.push(uniswap::Sync {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),
                    // -- call --
                    caller,
                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,
                    // -- event --
                    reserve0: event.reserve0.to_string(),
                    reserve1: event.reserve1.to_string(),
                });
            // Uniswap::V2::Pair:Swap
            } else if let Some(event) = pair::Swap::match_and_decode(log) {
                events.swap.push(uniswap::Swap {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),
                    tx_from: trx.from.to_vec(),
                    tx_to: trx.to.to_vec(),
                    // -- call --
                    caller,
                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,
                    // -- swap --
                    amount0_in: event.amount0_in.to_string(),
                    amount0_out: event.amount0_out.to_string(),
                    amount1_in: event.amount1_in.to_string(),
                    amount1_out: event.amount1_out.to_string(),
                    sender: event.sender,
                    to: event.to,
                });
            // Uniswap::V2::Factory:PairCreated
            } else if let Some(event) = factory::PairCreated::match_and_decode(log) {
                events.pair_created.push(uniswap::PairCreated {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),
                    // -- call --
                    caller,
                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,
                    // -- event --
                    pair: event.pair,
                    token0: event.token0,
                    token1: event.token1,
                    all_pairs_length: event.param3.to_u64(),
                });
            // Uniswap::V2::Pair::Mint
            } else if let Some(event) = pair::Mint::match_and_decode(log) {
                events.mint.push(uniswap::Mint {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),
                    // -- call --
                    caller,
                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,
                    // -- event --
                    sender: event.sender,
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                });
            // Uniswap::V2::Pair::Burn
            } else if let Some(event) = pair::Burn::match_and_decode(log) {
                events.burn.push(uniswap::Burn {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),
                    // -- call --
                    caller,
                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,
                    // -- event --
                    sender: event.sender,
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                    to: event.to,
                });
            }
        }
    }

    Ok(events)
}
