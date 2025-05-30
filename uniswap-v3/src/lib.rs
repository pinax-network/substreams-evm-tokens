use common::{bigint_to_i32, bigint_to_uint64, logs_with_caller};
use proto::pb::evm::uniswap::v3 as uniswap;
use substreams::errors::Error;
use substreams_abis::evm::uniswap::v3::factory::events as factory;
use substreams_abis::evm::uniswap::v3::pool::events as pool;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<uniswap::Events, Error> {
    let mut events = uniswap::Events::default();

    // === Uniswap::V3 ===
    // https://github.com/Uniswap/v3-core
    // https://github.com/pinax-network/substreams-abis/tree/main/abi/evm/uniswap/v3
    for trx in block.transactions() {
        for (log, caller) in logs_with_caller(&block, trx) {
            // Uniswap::V3::Pair:Swap
            if let Some(event) = pool::Swap::match_and_decode(log) {
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

                    // -- event --
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                    sender: event.sender,
                    recipient: event.recipient,
                    liquidity: event.liquidity.to_string(),
                    sqrt_price_x96: event.sqrt_price_x96.to_string(),
                    tick: bigint_to_i32(&event.tick).unwrap_or(i32::MAX),
                });
            // Uniswap::V3::Factory:PoolCreated
            } else if let Some(event) = factory::PoolCreated::match_and_decode(log) {
                events.pool_created.push(uniswap::PoolCreated {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),
                    // -- call --
                    caller,
                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,
                    // -- event --
                    pool: event.pool,
                    token0: event.token0,
                    token1: event.token1,
                    tick_spacing: bigint_to_i32(&event.tick_spacing).unwrap_or(i32::MAX),
                    fee: bigint_to_uint64(&event.fee).unwrap_or(u64::MAX),
                });
            // Uniswap::V3::Pool:Initialize
            } else if let Some(event) = pool::Initialize::match_and_decode(log) {
                events.initialize.push(uniswap::Initialize {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    sqrt_price_x96: event.sqrt_price_x96.to_string(),
                    tick: bigint_to_i32(&event.tick).unwrap_or(i32::MAX),
                });
            // Uniswap::V3::Pool:Mint
            } else if let Some(event) = pool::Mint::match_and_decode(log) {
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
                    owner: event.owner,
                    tick_lower: bigint_to_i32(&event.tick_lower).unwrap_or(i32::MAX),
                    tick_upper: bigint_to_i32(&event.tick_upper).unwrap_or(i32::MAX),
                    amount: event.amount.to_string(),
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                });
            // Uniswap::V3::Pool:Collect
            } else if let Some(event) = pool::Collect::match_and_decode(log) {
                events.collect.push(uniswap::Collect {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    owner: event.owner,
                    recipient: event.recipient,
                    tick_lower: bigint_to_i32(&event.tick_lower).unwrap_or(i32::MAX),
                    tick_upper: bigint_to_i32(&event.tick_upper).unwrap_or(i32::MAX),
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                });
            // Uniswap::V3::Pool:Burn
            } else if let Some(event) = pool::Burn::match_and_decode(log) {
                events.burn.push(uniswap::Burn {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    owner: event.owner,
                    tick_lower: bigint_to_i32(&event.tick_lower).unwrap_or(i32::MAX),
                    tick_upper: bigint_to_i32(&event.tick_upper).unwrap_or(i32::MAX),
                    amount: event.amount.to_string(),
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                });
            // Uniswap::V3::Pool:Flash
            } else if let Some(event) = pool::Flash::match_and_decode(log) {
                events.flash.push(uniswap::Flash {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    sender: event.sender,
                    recipient: event.recipient,
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                    paid0: event.paid0.to_string(),
                    paid1: event.paid1.to_string(),
                });
            // Uniswap::V3::Pool:IncreaseObservationCardinalityNext
            } else if let Some(event) = pool::IncreaseObservationCardinalityNext::match_and_decode(log) {
                events.increase_observation_cardinality_next.push(uniswap::IncreaseObservationCardinalityNext {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    observation_cardinality_next_old: bigint_to_uint64(&event.observation_cardinality_next_old).unwrap_or(u64::MAX),
                    observation_cardinality_next_new: bigint_to_uint64(&event.observation_cardinality_next_new).unwrap_or(u64::MAX),
                });
            // Uniswap::V3::Pool:SetFeeProtocol
            } else if let Some(event) = pool::SetFeeProtocol::match_and_decode(log) {
                events.set_fee_protocol.push(uniswap::SetFeeProtocol {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    fee_protocol0_old: bigint_to_uint64(&event.fee_protocol0_old).unwrap_or(u64::MAX),
                    fee_protocol1_old: bigint_to_uint64(&event.fee_protocol1_old).unwrap_or(u64::MAX),
                    fee_protocol0_new: bigint_to_uint64(&event.fee_protocol0_new).unwrap_or(u64::MAX),
                    fee_protocol1_new: bigint_to_uint64(&event.fee_protocol1_new).unwrap_or(u64::MAX),
                });
            // Uniswap::V3::Pool:Collect
            } else if let Some(event) = pool::CollectProtocol::match_and_decode(log) {
                events.collect_protocol.push(uniswap::CollectProtocol {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    sender: event.sender,
                    recipient: event.recipient,
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                });
            }
        }
    }

    Ok(events)
}
