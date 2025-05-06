mod pb;
use crate::pb::contract::v1::Events;
use common::bytes_to_hex;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;

#[substreams::handlers::map]
pub fn db_out(events: Events) -> Result<DatabaseChanges, substreams::errors::Error> {
    let tables = events.eas_attesteds.into_iter().fold(Tables::new(), |mut tables, attestation| {
        tables
            .create_row("attestations", [("tx_hash", bytes_to_hex(&attestation.evt_tx_hash))])
            .set("tx_hash", bytes_to_hex(&attestation.evt_tx_hash))
            .set("evt_index", attestation.evt_index)
            .set("block_num", attestation.evt_block_number)
            .set("timestamp", attestation.evt_block_time.as_ref().map_or(0, |t| t.seconds))
            .set("uid", bytes_to_hex(&attestation.uid))
            .set("recipient", bytes_to_hex(&attestation.recipient))
            .set("attester", bytes_to_hex(&attestation.attester))
            .set("schema_id", bytes_to_hex(&attestation.schema_id))
            .set("data", bytes_to_hex(&attestation.data))
            .set("schema", attestation.schema)
            .set("decoded_data", attestation.decoded_data);
        tables
    });

    Ok(tables.to_database_changes())
}
