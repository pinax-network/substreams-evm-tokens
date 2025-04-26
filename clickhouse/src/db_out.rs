use common::update_genesis_clock;
use proto::pb::evm::tokens::balances::v1::Events as EventsBalances;
use proto::pb::evm::tokens::contracts::v1::Events as EventsContracts;
use proto::pb::evm::tokens::uniswap::v2::Events as EventsPricesUniswapV2;
use proto::pb::evm::tokens::uniswap::v3::Events as EventsPricesUniswapV3;
use substreams::{errors::Error, pb::substreams::Clock};
use substreams_database_change::pb::database::DatabaseChanges;

use crate::{balances::process_balances, contracts::process_contracts, uniswap_v2, uniswap_v3};

#[substreams::handlers::map]
pub fn db_out(mut clock: Clock,
    native_balances: EventsBalances,
    native_contracts: EventsContracts,
    erc20_balances: EventsBalances,
    erc20_contracts: EventsContracts,
    erc20_contracts_rpc: EventsContracts,
    uniswap_v2: EventsPricesUniswapV2,
    uniswap_v3: EventsPricesUniswapV3
) -> Result<DatabaseChanges, Error> {
    let mut tables = substreams_database_change::tables::Tables::new();
    clock = update_genesis_clock(clock);

    // -- Balances/Transfers --
    let mut index = 0;
    index = process_balances("erc20_", &mut tables, &clock, erc20_balances, index);
    index = process_balances("native_", &mut tables, &clock, native_balances, index);

    // -- Contract Creation & Changes --
    index = process_contracts(&mut tables, &clock, native_contracts, index);
    index = process_contracts(&mut tables, &clock, erc20_contracts, index);
    index = process_contracts(&mut tables, &clock, erc20_contracts_rpc, index);

    // -- Uniswap V2/V3 --
    index = uniswap_v2::process_uniswap_v2(&mut tables, &clock, uniswap_v2, index);
    uniswap_v3::process_uniswap_v3(&mut tables, &clock, uniswap_v3, index);

    Ok(tables.to_database_changes())
}
