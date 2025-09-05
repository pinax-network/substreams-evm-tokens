use common::bytes_to_hex;
use proto::pb::evm::native;
use substreams::pb::substreams::Clock;

use common::clickhouse::set_clock;

pub fn process_native_balances(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: native::balances::v1::Events) {
    for event in events.balances_by_account {
        process_native_balance_by_account("native_balance_changes", tables, clock, event);
    }

    for event in events.extended_balances_by_account_from_block_rewards {
        process_native_balance_by_account("native_balance_changes", tables, clock, event);
    }

    for event in events.extended_balances_by_account_from_calls {
        process_native_balance_by_account("native_balance_changes", tables, clock, event);
    }

    for event in events.extended_balances_by_account_from_gas {
        process_native_balance_by_account("native_balance_changes", tables, clock, event);
    }

    for event in events.extended_balances_by_account_from_system_calls {
        process_native_balance_by_account("native_balance_changes", tables, clock, event);
    }
}

fn process_native_balance_by_account(
    table_name: &str,
    tables: &mut substreams_database_change::tables::Tables,
    clock: &Clock,
    event: native::balances::v1::BalanceByAccount,
) {
    let address = bytes_to_hex(&event.account);
    let key = [("address", address.to_string()), ("block_num", clock.number.to_string())];
    let row = tables
        .create_row(table_name, key)
        // -- event --
        .set("address", address.to_string())
        .set("balance", event.amount);

    set_clock(clock, row);
}
