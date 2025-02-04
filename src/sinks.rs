use substreams::{errors::Error, pb::substreams::Clock};
use substreams_database_change::pb::database::DatabaseChanges;

use crate::{pb::erc20::types::v1::{BalanceChangeType, BalanceChanges}, utils::block_time_to_date};

#[substreams::handlers::map]
pub fn db_out(clock: Clock, balance_changes: BalanceChanges) -> Result<DatabaseChanges, Error> {
    let mut tables = substreams_database_change::tables::Tables::new();
    let block_num = clock.clone().number;
    let timestamp = clock.clone().timestamp.unwrap().seconds.to_string();
    let date = block_time_to_date(&clock.clone().timestamp.unwrap().to_string());

    // Balance Changes
    let mut balance_change_index = 0;
    for balance_change in balance_changes.balance_changes {
        if balance_change.change_type == BalanceChangeType::TypeUnknown as i32 {
            continue;
        }
        // In ClickHouse, an aggregate function like argMax can only take one expression as the “ordering” argument.
        // So we typically combine (block_num, call_index) into a single monotonic integer.
        // For example, if each of block_num and call_index fits in 32 bits, we can do:
        // max(toUInt64(block_num) * 2^32 + call_index) AS version
        let version = block_num << 32 + balance_change_index;
        tables.create_row("balance_changes", [
            ("transaction_id", (&balance_change).transaction.to_string()),
            ("index", balance_change_index.to_string())
        ])
            // block
            .set("block_num", &block_num.to_string())
            .set("timestamp", &timestamp)
            .set("date", &date)

            // transaction
            .set("transaction_id", &balance_change.transaction)
            .set("call_index", balance_change.call_index)
            .set("index", balance_change_index)
            .set("version", version.to_string())

            // balance changes
            .set("contract", &balance_change.contract)
            .set("owner", &balance_change.owner)
            .set("amount", balance_change.transfer_value)
            .set("old_balance", balance_change.old_balance)
            .set("new_balance", balance_change.new_balance);

        balance_change_index += 1;
    }

    Ok(tables.to_database_changes())
}