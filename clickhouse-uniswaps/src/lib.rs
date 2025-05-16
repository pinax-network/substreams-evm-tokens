mod uniswap_v2;
mod uniswap_v3;
mod uniswap_v4;
use proto::pb::evm::uniswap::v2;
use proto::pb::evm::uniswap::v3;
use proto::pb::evm::uniswap::v4;
use substreams::{errors::Error, pb::substreams::Clock};
use substreams_database_change::pb::database::DatabaseChanges;

use crate::uniswap_v2::process_uniswap_v2;
use crate::uniswap_v3::process_uniswap_v3;
use crate::uniswap_v4::process_uniswap_v4;

#[substreams::handlers::map]
pub fn db_out(mut clock: Clock, uniswap_v2: v2::Events, uniswap_v3: v3::Events, uniswap_v4: v4::Events) -> Result<DatabaseChanges, Error> {
    let mut tables = substreams_database_change::tables::Tables::new();
    let mut index = 0; // relative index

    // -- Uniswap V2/V3/V4 --
    index = process_uniswap_v2(&mut tables, &clock, uniswap_v2, index);
    index = process_uniswap_v3(&mut tables, &clock, uniswap_v3, index);
    process_uniswap_v4(&mut tables, &clock, uniswap_v4, index);

    Ok(tables.to_database_changes())
}
