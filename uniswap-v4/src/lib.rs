use common::logs_with_caller;
use proto::pb::evm::uniswap::v4 as uniswap;
use substreams::errors::Error;
use substreams_abis::evm::uniswap::v4::poolmanager::events as poolmanager;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<uniswap::Events, Error> {
    let mut events = uniswap::Events::default();

    // === Uniswap::V4 ===
    // https://github.com/Uniswap/v4-core/blob/main/src/interfaces/IPoolManager.sol
    // https://github.com/Uniswap/v4-core/blob/59d3ecf53afa9264a16bba0e38f4c5d2231f80bc/src/interfaces/IProtocolFees.sol
    for trx in block.transactions() {
        for (log, caller) in logs_with_caller(&block, trx) {
            // Uniswap::V4::PoolManager:Swap
            if let Some(event) = poolmanager::Swap::match_and_decode(log) {
                events.swap.push(uniswap::Swap {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),
                    // -- call --
                    caller,
                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    id: event.id.to_vec(),
                    sender: event.sender,
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                    fee: event.fee.to_string(),
                    liquidity: event.liquidity.to_string(),
                    sqrt_price_x96: event.sqrt_price_x96.to_string(),
                    tick: event.tick.into(),
                });
            // Uniswap::V4::PoolManager:Initialize
            } else if let Some(event) = poolmanager::Initialize::match_and_decode(log) {
                events.intialize.push(uniswap::Initialize {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    id: event.id.to_vec(),
                    currency0: event.currency0.to_vec(),
                    currency1: event.currency0.to_vec(),
                    fee: event.fee.to_u64(),
                    tick_spacing: event.tick_spacing.to_i32(),
                    hooks: None, // NOT IMPLEMENTED
                    sqrt_price_x96: event.sqrt_price_x96.to_string(),
                    tick: event.tick.to_i32(),
                });
            // Uniswap::V4::PoolManager:ModifyLiquidity
            } else if let Some(event) = poolmanager::ModifyLiquidity::match_and_decode(log) {
                events.modify_liquidity.push(uniswap::ModifyLiquidity {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    id: event.id.to_vec(),
                    sender: event.sender.to_vec(),
                    tick_lower: event.tick_lower.to_i32(),
                    tick_upper: event.tick_upper.to_i32(),
                    liquidity_delta: event.liquidity_delta.to_string(),
                    salt: event.salt.to_vec(),
                });
            // Uniswap::V4::PoolManager:Donate
            } else if let Some(event) = poolmanager::Donate::match_and_decode(log) {
                events.donate.push(uniswap::Donate {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    id: event.id.to_vec(),
                    sender: event.sender.to_vec(),
                    amount0: event.amount0.to_string(),
                    amount1: event.amount1.to_string(),
                });
            // Uniswap::V4::PoolManager:ProtocolFeeControllerUpdated
            } else if let Some(event) = poolmanager::ProtocolFeeControllerUpdated::match_and_decode(log) {
                events.protocol_fee_controller_updated.push(uniswap::ProtocolFeeControllerUpdated {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    protocol_fee_controller: event.protocol_fee_controller.to_vec(),
                });
            // Uniswap::V4::PoolManager:ProtocolFeeUpdated
            } else if let Some(event) = poolmanager::ProtocolFeeUpdated::match_and_decode(log) {
                events.protocol_fee_updated.push(uniswap::ProtocolFeeUpdated {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    id: event.id.to_vec(),
                    protocol_fee: event.protocol_fee.to_u64(),
                });
            }
        }
    }

    Ok(events)
}
