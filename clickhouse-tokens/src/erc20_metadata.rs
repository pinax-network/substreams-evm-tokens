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
    let key = [("address", address.to_string())];
    let row = tables
        .create_row("erc20_metadata_initialize", key)
        .set("address", address)
        .set("decimals", event.decimals)
        .set("name", event.name.unwrap_or_default())
        .set("symbol", event.symbol.unwrap_or_default());

    set_clock(clock, row);
}

pub fn process_erc20_metadata_changes(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: erc20::metadata::v1::MetadataChanges) {
    let address = bytes_to_hex(&event.address);

    let key = [("address", address.to_string()), ("block_num", clock.number.to_string())];
    let row = tables
        .create_row("erc20_metadata_changes", key)
        .set("address", address.to_string())
        .set("name", event.name.unwrap_or_default())
        .set("symbol", event.symbol.unwrap_or_default());

    set_clock(clock, row);
}
