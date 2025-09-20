use common::{bytes_to_hex, clickhouse::set_clock};
use proto::pb::evm::erc20;
use substreams::pb::substreams::Clock;

pub fn process_erc20_metadata(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc20::metadata::v1::Events) {
    for event in events.metadata_initialize {
        process_erc20_metadata_initialize(tables, &clock, event);
    }
    for event in events.metadata_changes {
        process_erc20_metadata_changes(tables, &clock, event);
    }
}

pub fn process_erc20_metadata_initialize(
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: erc20::metadata::v1::MetadataInitialize,
) {
    let address = bytes_to_hex(&event.address);
    let row = tables
        .create_row("metadata_initialize", [("contract", address.to_string())])
        .set("contract", address)
        .set("decimals", event.decimals)
        .set("name", event.name.unwrap_or_default())
        .set("symbol", event.symbol.unwrap_or_default());

    set_clock(clock, row);
}

pub fn process_erc20_metadata_changes(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: erc20::metadata::v1::MetadataChanges) {
    let address = bytes_to_hex(&event.address);
    let row = tables
        .create_row("metadata_changes", [("contract", address.to_string())])
        .set("contract", address.to_string())
        .set("name", event.name.unwrap_or_default())
        .set("symbol", event.symbol.unwrap_or_default());

    set_clock(clock, row);
}
