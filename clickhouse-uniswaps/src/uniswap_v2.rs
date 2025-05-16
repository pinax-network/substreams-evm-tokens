use common::bytes_to_hex;
use proto::pb::evm::uniswap::v2::{Burn, Events, Mint, PairCreated, Swap, Sync};
use substreams::pb::substreams::Clock;

use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};

pub fn process_uniswap_v2(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: Events, mut index: u64) -> u64 {
    for event in events.pair_created {
        process_uniswap_v2_pair_created(tables, clock, event, index);
        index += 1;
    }
    for event in events.swap {
        process_uniswap_v2_swap(tables, clock, event, index);
        index += 1;
    }
    for event in events.sync {
        process_uniswap_v2_sync(tables, clock, event, index);
        index += 1;
    }
    for event in events.mint {
        process_uniswap_v2_mint(tables, clock, event, index);
        index += 1;
    }
    for event in events.burn {
        process_uniswap_v2_burn(tables, clock, event, index);
        index += 1;
    }
    index
}

fn process_uniswap_v2_swap(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Swap, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v2_swap", key)
        // -- transaction --
        .set("tx_from", &bytes_to_hex(&event.tx_from))
        .set("tx_to", &bytes_to_hex(&event.tx_to))
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
        .set("amount0_in", event.amount0_in)
        .set("amount0_out", event.amount0_out)
        .set("amount1_in", event.amount1_in)
        .set("amount1_out", event.amount1_out)
        .set("sender", bytes_to_hex(&event.sender))
        .set("to", bytes_to_hex(&event.to));

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v2_sync(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Sync, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v2_sync", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("reserve0", event.reserve0.to_string())
        .set("reserve1", event.reserve1.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v2_pair_created(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: PairCreated, index: u64) {
    let key = [("address", bytes_to_hex(&event.contract)), ("pair", bytes_to_hex(&event.pair))];
    let row = tables
        .create_row("uniswap_v2_pair_created", key)
        .set("token0", bytes_to_hex(&event.token0))
        .set("token1", bytes_to_hex(&event.token1))
        .set("pair", bytes_to_hex(&event.pair))
        .set("all_pairs_length", event.all_pairs_length.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v2_mint(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Mint, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v2_mint", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sender", &bytes_to_hex(&event.sender))
        .set("amount0", event.amount0)
        .set("amount1", event.amount1);

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v2_burn(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Burn, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v2_burn", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sender", &bytes_to_hex(&event.sender))
        .set("amount0", event.amount0)
        .set("amount1", event.amount1)
        .set("to", &bytes_to_hex(&event.to));

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}
