use common::bytes_to_hex;
use proto::pb::evm::erc20;
use substreams::pb::substreams::Clock;

use common::clickhouse::set_clock;

pub fn process_erc20_balances(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc20::balances::v1::Events, index: &mut u32) {
    for event in events.balances_by_account {
        process_erc20_balance_by_account(tables, clock, event, index);
    }
}

fn process_erc20_balance_by_account(
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: erc20::balances::v1::BalanceByAccount,
    index: &mut u32,
) {
    let address = bytes_to_hex(&event.account);
    let contract = bytes_to_hex(&event.contract);
    let row = tables
        .create_row("balances", [("address", address.to_string()), ("contract", contract.to_string())])
        // -- event --
        .set("contract", contract.to_string())
        .set("address", address.to_string())
        .set("balance", event.amount);

    set_clock(clock, row);
    *index += 1;
}
