use common::bytes_to_hex;
use proto::pb::evm::uniswap::v3::{
    Burn, Collect, CollectProtocol, Events, FeeAmountEnabled, Flash, IncreaseObservationCardinalityNext, Initialize, Mint, OwnerChanged, PoolCreated,
    SetFeeProtocol, Swap,
};
use substreams::pb::substreams::Clock;

use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};

pub fn process_uniswap_v3(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: Events, mut index: u64) -> u64 {
    // IUniswapV3Factory
    for event in events.pool_created {
        process_uniswap_v3_pool_created(tables, clock, event, index);
        index += 1;
    }
    for event in events.owner_changed {
        process_uniswap_v3_owner_changed(tables, clock, event, index);
        index += 1;
    }
    for event in events.fee_amount_enabled {
        process_uniswap_v3_fee_amount_enabled(tables, clock, event, index);
        index += 1;
    }
    // IUniswapV3Pool
    for event in events.swap {
        process_uniswap_v3_swap(tables, clock, event, index);
        index += 1;
    }
    for event in events.initialize {
        process_uniswap_v3_initialize(tables, clock, event, index);
        index += 1;
    }
    for event in events.mint {
        process_uniswap_v3_mint(tables, clock, event, index);
        index += 1;
    }
    for event in events.collect {
        process_uniswap_v3_collect(tables, clock, event, index);
        index += 1;
    }
    for event in events.burn {
        process_uniswap_v3_burn(tables, clock, event, index);
        index += 1;
    }
    for event in events.flash {
        process_uniswap_v3_flash(tables, clock, event, index);
        index += 1;
    }
    for event in events.increase_observation_cardinality_next {
        process_uniswap_v3_increase_observation_cardinality_next(tables, clock, event, index);
        index += 1;
    }
    for event in events.set_fee_protocol {
        process_uniswap_v3_set_fee_protocol(tables, clock, event, index);
        index += 1;
    }
    for event in events.collect_protocol {
        process_uniswap_v3_collect_protocol(tables, clock, event, index);
        index += 1;
    }
    index
}

fn process_uniswap_v3_swap(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Swap, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_swap", key)
        // -- transaction --
        .set("tx_from", &bytes_to_hex(&event.tx_from))
        .set("tx_to", &bytes_to_hex(&event.tx_to))
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
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

fn process_uniswap_v3_initialize(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Initialize, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_initialize", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sqrt_price_x96", &event.sqrt_price_x96.to_string())
        .set("tick", &event.tick.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_pool_created(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: PoolCreated, index: u64) {
    let key = [("address", bytes_to_hex(&event.contract)), ("pool", bytes_to_hex(&event.pool))];
    let row = tables
        .create_row("uniswap_v3_pool_created", key)
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

fn process_uniswap_v3_owner_changed(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: OwnerChanged, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_owner_changed", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("old_owner", bytes_to_hex(&event.old_owner))
        .set("new_owner", bytes_to_hex(&event.new_owner));

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_fee_amount_enabled(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: FeeAmountEnabled, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_fee_amount_enabled", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("fee", event.fee.to_string())
        .set("tick_spacing", event.tick_spacing.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_mint(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Mint, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_mint", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sender", bytes_to_hex(&event.sender))
        .set("owner", bytes_to_hex(&event.owner))
        .set("tick_lower", event.tick_lower.to_string())
        .set("tick_upper", event.tick_upper.to_string())
        .set("amount", event.amount.to_string())
        .set("amount0", event.amount0.to_string())
        .set("amount1", event.amount1.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_collect(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Collect, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_collect", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("owner", bytes_to_hex(&event.owner))
        .set("recipient", bytes_to_hex(&event.recipient))
        .set("tick_lower", event.tick_lower.to_string())
        .set("tick_upper", event.tick_upper.to_string())
        .set("amount0", event.amount0.to_string())
        .set("amount1", event.amount1.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_burn(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Burn, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_burn", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("owner", bytes_to_hex(&event.owner))
        .set("tick_lower", event.tick_lower.to_string())
        .set("tick_upper", event.tick_upper.to_string())
        .set("amount", event.amount.to_string())
        .set("amount0", event.amount0.to_string())
        .set("amount1", event.amount1.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_flash(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Flash, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_flash", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sender", bytes_to_hex(&event.sender))
        .set("recipient", bytes_to_hex(&event.recipient))
        .set("amount0", event.amount0.to_string())
        .set("amount1", event.amount1.to_string())
        .set("paid0", event.paid0.to_string())
        .set("paid1", event.paid1.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_increase_observation_cardinality_next(
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: IncreaseObservationCardinalityNext,
    index: u64,
) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_increase_observation_cardinality_next", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("observation_cardinality_next_old", event.observation_cardinality_next_old.to_string())
        .set("observation_cardinality_next_new", event.observation_cardinality_next_new.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_set_fee_protocol(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: SetFeeProtocol, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_set_fee_protocol", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("fee_protocol0_old", event.fee_protocol0_old.to_string())
        .set("fee_protocol1_old", event.fee_protocol1_old.to_string())
        .set("fee_protocol0_new", event.fee_protocol0_new.to_string())
        .set("fee_protocol1_new", event.fee_protocol1_new.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v3_collect_protocol(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: CollectProtocol, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v3_collect_protocol", key)
        .set("address", &bytes_to_hex(&event.contract))
        .set("sender", bytes_to_hex(&event.sender))
        .set("recipient", bytes_to_hex(&event.recipient))
        .set("amount0", event.amount0.to_string())
        .set("amount1", event.amount1.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}
