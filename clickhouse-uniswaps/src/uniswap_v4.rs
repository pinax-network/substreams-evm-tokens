use common::bytes_to_hex;
use proto::pb::evm::uniswap::v4::{Events, Initialize, Swap};
use substreams::pb::substreams::Clock;

use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};

pub fn process_uniswap_v4(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: Events, mut index: u64) -> u64 {
    // IPoolManager
    for event in events.swap {
        process_uniswap_v4_swap(tables, clock, event, index);
        index += 1;
    }
    for event in events.initialize {
        process_uniswap_v4_initialize(tables, clock, event, index);
        index += 1;
    }
    for event in events.modify_liquidity {
        process_uniswap_v4_modify_liquidity(tables, clock, event, index);
        index += 1;
    }
    for event in events.donate {
        process_uniswap_v4_donate(tables, clock, event, index);
        index += 1;
    }

    // IProtocolFees
    for event in events.protocol_fee_controller_updated {
        process_uniswap_v4_protocol_fee_controller_updated(tables, clock, event, index);
        index += 1;
    }
    for event in events.protocol_fee_updated {
        process_uniswap_v4_protocol_fee_updated(tables, clock, event, index);
        index += 1;
    }
    index
}

fn process_uniswap_v4_swap(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Swap, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_swap", key)
        // -- transaction --
        .set("tx_from", &bytes_to_hex(&event.tx_from))
        .set("tx_to", &bytes_to_hex(&event.tx_to))
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
        .set("id", &bytes_to_hex(&event.id))
        .set("sender", bytes_to_hex(&event.sender))
        .set("amount0", event.amount0)
        .set("amount1", event.amount1)
        .set("sqrt_price_x96", &event.sqrt_price_x96)
        .set("liquidity", &event.liquidity)
        .set("tick", &event.tick.to_string())
        .set("fee", event.fee.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v4_initialize(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: Initialize, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_initialize", key)
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
        .set("id", &bytes_to_hex(&event.id))
        .set("currency0", bytes_to_hex(&event.currency0))
        .set("currency1", bytes_to_hex(&event.currency1))
        .set("fee", event.fee.to_string())
        .set("tick_spacing", event.tick_spacing.to_string())
        .set("sqrt_price_x96", &event.sqrt_price_x96.to_string())
        .set("tick", &event.tick.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v4_modify_liquidity(
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: proto::pb::evm::uniswap::v4::ModifyLiquidity,
    index: u64,
) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_modify_liquidity", key)
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
        .set("id", &bytes_to_hex(&event.id))
        .set("sender", bytes_to_hex(&event.sender))
        .set("tick_lower", event.tick_lower.to_string())
        .set("tick_upper", event.tick_upper.to_string())
        .set("liquidity_delta", event.liquidity_delta)
        .set("salt", bytes_to_hex(&event.salt));

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v4_donate(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: proto::pb::evm::uniswap::v4::Donate, index: u64) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_donate", key)
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
        .set("id", &bytes_to_hex(&event.id))
        .set("sender", bytes_to_hex(&event.sender))
        .set("amount0", event.amount0)
        .set("amount1", event.amount1);

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v4_protocol_fee_controller_updated(
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: proto::pb::evm::uniswap::v4::ProtocolFeeControllerUpdated,
    index: u64,
) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_protocol_fee_controller_updated", key)
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
        .set("protocol_fee_controller", bytes_to_hex(&event.protocol_fee_controller));

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}

fn process_uniswap_v4_protocol_fee_updated(
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: proto::pb::evm::uniswap::v4::ProtocolFeeUpdated,
    index: u64,
) {
    let key = common_key(clock, index);
    let row = tables
        .create_row("uniswap_v4_protocol_fee_updated", key)
        .set("address", &bytes_to_hex(&event.contract))
        // -- event --
        .set("id", &bytes_to_hex(&event.id))
        .set("protocol_fee", event.protocol_fee.to_string());

    set_caller(event.caller, row);
    set_ordering(index, Some(event.ordinal), clock, row);
    set_tx_hash(Some(event.tx_hash), row);
    set_clock(clock, row);
}
