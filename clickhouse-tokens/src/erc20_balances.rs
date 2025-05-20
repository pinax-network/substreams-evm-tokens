use common::bytes_to_hex;
use proto::pb::evm::erc20;
use substreams::pb::substreams::Clock;

use common::clickhouse::set_clock;

pub fn process_erc20_balances(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc20::balances::v1::Events) {
    for event in events.balances_by_account {
        process_erc20_balance_by_account(tables, clock, event);
    }
}

fn process_erc20_balance_by_account(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: erc20::balances::v1::BalanceByAccount) {
    let address = bytes_to_hex(&event.account);
    let contract = bytes_to_hex(&event.contract);
    let key = [
        ("contract", contract.to_string()),
        ("address", address.to_string()),
        ("block_num", clock.number.to_string()),
    ];
    let row = tables
        .create_row("erc20_balance_changes", key)
        // -- event --
        .set("contract", contract.to_string())
        .set("address", address.to_string())
        .set("balance", event.amount);

    set_clock(clock, row);
}
