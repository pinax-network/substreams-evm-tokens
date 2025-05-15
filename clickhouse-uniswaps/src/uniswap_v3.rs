use common::bytes_to_hex;
use proto::pb::evm::uniswap::v3::{Events, Initialize, PoolCreated, Swap};
use substreams::pb::substreams::Clock;

use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};

pub fn process_uniswap_v3(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: Events, mut index: u64) -> u64 {
    for event in events.swap {
        process_uniswap_v3_swaps(tables, clock, event, index);
        index += 1;
    }

    for event in events.intialize {
        process_uniswap_v3_initializes(tables, clock, event, index);
        index += 1;
    }

    for event in events.pool_created {
        process_uniswap_v3_pools_created(tables, clock, event, index);
        index += 1;
    }
    index
}

fn process_uniswap_v3_swaps(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Swap, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_swaps", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("amount0", event.amount0)
        .set("amount1", event.amount1)
        .set("sender", bytes_to_hex(&event.sender))
        .set("recipient", bytes_to_hex(&event.recipient))
        .set("liquidity", &event.liquidity)
        .set("sqrt_price_x96", &event.sqrt_price_x96)
        .set("tick", &event.tick.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_initializes(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Initialize, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_initializes", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sqrt_price_x96", &event.sqrt_price_x96.to_string())
        .set("tick", &event.tick.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_pools_created(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: PoolCreated, index: u64) {
    let key = [("address", bytes_to_hex(&event.contract)), ("pool", bytes_to_hex(&event.pool))];
    let row = tables
        .create_row("uniswap_v3_pools_created", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("token0", bytes_to_hex(&event.token0))
        .set("token1", bytes_to_hex(&event.token1))
        .set("pool", bytes_to_hex(&event.pool))
        .set("tick_spacing", event.tick_spacing.to_string())
        .set("fee", event.fee.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}
