use common::{
    bytes_to_hex,
    clickhouse::{log_key, set_log},
};
use proto::pb::evm::erc20;
use substreams::pb::substreams::Clock;

pub fn process_erc20_transfers(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc20::transfers::v1::Events) {
    let mut index = 0; // relative index for transfers

    // TO-DO: ⚠️ add transaction index / instruction index to have a proper ordering
    for event in events.transfers {
        process_erc20_transfer(tables, clock, event, index);
        index += 1;
    }

    index = 0; // relative index for approvals
    for event in events.approvals {
        process_erc20_approval(tables, clock, event, index);
        index += 1;
    }
}

fn process_erc20_transfer(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: erc20::transfers::v1::Transfer, index: u64) {
    let row = tables
        .create_row("transfers", log_key(clock, event.log_index))
        // -- event --
        .set("from", bytes_to_hex(&event.from))
        .set("to", bytes_to_hex(&event.to))
        .set("value", event.value.to_string());

    set_log(clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
}

fn process_erc20_approval(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: erc20::transfers::v1::Approval, index: u64) {
    let row = tables
        .create_row("approvals", log_key(clock, event.log_index))
        // -- event --
        .set("owner", bytes_to_hex(&event.owner))
        .set("spender", bytes_to_hex(&event.spender))
        .set("value", event.value.to_string());

    set_log(clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
}
