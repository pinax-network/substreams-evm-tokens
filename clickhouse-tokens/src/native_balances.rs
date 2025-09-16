use common::bytes_to_hex;
use proto::pb::evm::native;
use substreams::pb::substreams::Clock;

use common::clickhouse::set_clock;

// ❗ ERROR in ordering is missing transaction index / instruction index
pub fn process_native_balances(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: native::balances::v1::Events) {
    // NOTE: The order of processing events is crucial to maintain accurate balance states.
    // Ethereum balance changes occur in several phases within a block and transaction:
    //
    // Ref issue: https://github.com/pinax-network/substreams-evm-tokens/issues/126
    //
    // 1. Block Rewards → miner/validator credited first.
    // 2. Tx Gas Prepayment → sender debited upfront.
    // 3. Execution Phase → calls, transfers, system calls update balances.
    // 4. Gas Refund + Miner Reward → settlement at the end of the transaction.
    // 5. RPC eth_getBalance → only observes the final post-state snapshot.
    for event in events.extended_balances_by_account_from_block_rewards {
        process_native_balance_by_account(tables, clock, event);
    }
    for event in events.extended_balances_by_account_from_gas {
        process_native_balance_by_account(tables, clock, event);
    }
    for event in events.extended_balances_by_account_from_system_calls {
        process_native_balance_by_account(tables, clock, event);
    }
    for event in events.extended_balances_by_account_from_calls {
        process_native_balance_by_account(tables, clock, event);
    }
    for event in events.balances_by_account {
        process_native_balance_by_account(tables, clock, event);
    }
}

fn process_native_balance_by_account(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, event: native::balances::v1::BalanceByAccount) {
    let address = bytes_to_hex(&event.account);
    let contract = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
    let row = tables
        .create_row("balances", [("address", address.to_string()), ("contract", contract.to_string())])
        // -- event --
        .set("contract", contract)
        .set("address", address.to_string())
        .set("balance", event.amount);

    set_clock(clock, row);
}
