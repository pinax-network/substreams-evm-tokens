use common::bytes_to_hex;
use proto::pb::evm::erc20;
use substreams::pb::substreams::Clock;

use common::clickhouse::set_clock;

pub fn process_erc20_supply(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc20::supply::v1::Events, index: &mut u32) {
    for event in events.total_supply_by_contracts {
        process_erc20_total_supply_by_contracts(tables, clock, event, index);
    }
}

fn process_erc20_total_supply_by_contracts(
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: erc20::supply::v1::TotalSupplyByContract,
    index: &mut u32,
) {
    let contract = bytes_to_hex(&event.contract);
    let row = tables
        .create_row("total_supply", [("contract", contract.to_string())])
        // -- event --
        .set("contract", contract.to_string())
        .set("total_supply", event.total_supply);

    set_clock(clock, row);
    *index += 1;
}
