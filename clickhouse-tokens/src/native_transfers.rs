use common::{
    bytes_to_hex,
    clickhouse::{common_key, set_clock, set_tx_hash},
    to_global_sequence,
};
use proto::pb::evm::native;
use substreams::pb::substreams::Clock;

pub fn process_native_transfers(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: native::transfers::v1::Events) {
    let mut index = 0; // relative index for transfers
    for event in events.transfers {
        process_native_transfer("native_transfers", tables, clock, event, index);
        index += 1;
    }
    for event in events.transfers_from_fees {
        process_native_transfer("native_transfers_from_fees", tables, clock, event, index);
        index += 1;
    }
    for event in events.extended_transfers_from_block_rewards {
        process_native_transfer("native_transfers_from_block_rewards", tables, clock, event, index);
        index += 1;
    }
    for event in events.extended_transfers_from_calls {
        process_native_transfer("native_transfers_from_calls", tables, clock, event, index);
        index += 1;
    }
}

fn process_native_transfer(
    table_name: &str,
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: native::transfers::v1::Transfer,
    index: u64,
) {
    let row = tables
        .create_row(table_name, common_key(clock, index))
        // -- event --
        .set("from", bytes_to_hex(&event.from))
        .set("to", bytes_to_hex(&event.to))
        .set("value", event.value.to_string());

    // -- ordering --
    row.set("index", index);
    row.set("global_sequence", to_global_sequence(clock, index));
    set_tx_hash(event.tx_hash, row);
    set_clock(clock, row);
}
