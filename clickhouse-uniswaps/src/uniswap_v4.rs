use common::bytes_to_hex;
use proto::pb::evm::uniswap::v4::{Events, Initialize, Swap};
use substreams::pb::substreams::Clock;

use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};

pub fn process_uniswap_v4(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: Events, mut index: u64) -> u64 {
    for event in events.swap {
        process_uniswap_v4_swaps(tables, clock, event, index);
        index += 1;
    }

    for event in events.intialize {
        process_uniswap_v4_initializes(tables, clock, event, index);
        index += 1;
    }
    index
}

fn process_uniswap_v4_swaps(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Swap, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_swaps", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("amount0", event.amount0)
        .set("amount1", event.amount1)
        .set("sender", bytes_to_hex(&event.sender))
        .set("liquidity", &event.liquidity)
        .set("sqrt_price_x96", &event.sqrt_price_x96)
        .set("tick", &event.tick.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v4_initializes(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Initialize, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_initializes", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sqrt_price_x96", &event.sqrt_price_x96.to_string())
        .set("tick", &event.tick.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}
