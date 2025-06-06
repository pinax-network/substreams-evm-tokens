mod cryptopunks;
mod enums;
mod erc1155;
mod erc1155_metadata;
mod erc721;
mod erc721_metadata;
mod seaport;
mod to_json;

use proto::pb::evm;
use substreams::pb::substreams::Clock;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;

#[substreams::handlers::map]
pub fn db_out(
    clock: Clock,
    erc721_events: evm::erc721::v1::Events,
    erc721_metadata_events: evm::erc721::metadata::v1::Events,
    erc1155_events: evm::erc1155::v1::Events,
    erc1155_metadata_events: evm::erc1155::metadata::v1::Events,
    seaport_events: evm::seaport::v1::Events,
    erc721_cryptopunks_events: evm::erc721::v1::Events,
    cryptopunks_events: evm::cryptopunks::v1::Events,
) -> Result<DatabaseChanges, substreams::errors::Error> {
    let mut tables = Tables::new();

    // Process packages
    erc721::process_erc721(&mut tables, &clock, erc721_events);
    erc721::process_erc721(&mut tables, &clock, erc721_cryptopunks_events);
    erc721_metadata::process_erc721_metadata(&mut tables, &clock, erc721_metadata_events);
    erc1155::process_erc1155(&mut tables, &clock, erc1155_events);
    erc1155_metadata::process_erc1155_metadata(&mut tables, &clock, erc1155_metadata_events);
    seaport::process_seaport(&mut tables, &clock, seaport_events);
    cryptopunks::process_cryptopunks(&mut tables, &clock, cryptopunks_events);

    Ok(tables.to_database_changes())
}
