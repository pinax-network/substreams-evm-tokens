use common::{
    bytes_to_hex,
    clickhouse::{log_key, set_clock},
};
use proto::pb::evm::native;
use substreams::pb::substreams::Clock;

pub fn process_native_transfers(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: native::transfers::v1::Events) {
    let mut index = 0; // relative index for transfers

    // TO-DO: ⚠️ add transaction index / instruction index to have a proper ordering
    for event in events.transfers {
        process_native_transfer(tables, clock, event, index);
        index += 1;
    }
    for event in events.transfers_from_fees {
        process_native_transfer(tables, clock, event, index);
        index += 1;
    }
    for event in events.extended_transfers_from_block_rewards {
        process_native_transfer(tables, clock, event, index);
        index += 1;
    }
    for event in events.extended_transfers_from_calls {
        process_native_transfer(tables, clock, event, index);
        index += 1;
    }
}

fn process_native_transfer(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: native::transfers::v1::Transfer, index: u32) {
    let contract = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
    let row = tables
        .create_row("transfers", log_key(clock, index))
        // -- transaction --
        .set("tx_hash", bytes_to_hex(event.tx_hash()))
        // -- log --
        .set("contract", contract)
        .set("caller", bytes_to_hex(&event.from))
        .set("log_index", index)
        // -- event --
        .set("from", bytes_to_hex(&event.from))
        .set("to", bytes_to_hex(&event.to))
        .set("value", event.value.to_string());

    set_clock(clock, row);
}
