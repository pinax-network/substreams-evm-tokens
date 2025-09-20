mod erc20_balances;
mod erc20_metadata;
mod erc20_supply;
mod erc20_transfers;
mod native_balances;
mod native_transfers;
use common::update_genesis_clock;
use proto::pb::evm::erc20;
use proto::pb::evm::native;
use substreams::{errors::Error, pb::substreams::Clock};
use substreams_database_change::pb::database::DatabaseChanges;

#[substreams::handlers::map]
pub fn db_out(
    mut clock: Clock,
    // Native
    native_balances: native::balances::v1::Events,
    native_transfers: native::transfers::v1::Events,

    // ERC-20
    erc20_balances_rpc: erc20::balances::v1::Events,
    erc20_transfers: erc20::transfers::v1::Events,
    erc20_supply: erc20::supply::v1::Events,
    erc20_metadata: erc20::metadata::v1::Events,
) -> Result<DatabaseChanges, Error> {
    let mut tables = substreams_database_change::tables::Tables::new();
    clock = update_genesis_clock(clock);

    // -- ERC20 Metadata --
    erc20_metadata::process_erc20_metadata(&mut tables, &clock, erc20_metadata);

    // -- ERC20 Balances --
    erc20_balances::process_erc20_balances(&mut tables, &clock, erc20_balances_rpc);

    // -- ERC20 Transfers --
    erc20_transfers::process_erc20_transfers(&mut tables, &clock, erc20_transfers);

    // -- ERC20 Total Supply --
    erc20_supply::process_erc20_supply(&mut tables, &clock, erc20_supply);

    // -- Native Balances --
    native_balances::process_native_balances(&mut tables, &clock, native_balances);

    // -- Native Transfers --
    native_transfers::process_native_transfers(&mut tables, &clock, native_transfers);

    Ok(tables.to_database_changes())
}
