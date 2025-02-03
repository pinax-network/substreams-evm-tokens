use substreams::errors::Error;
use substreams_database_change::pb::database::DatabaseChanges;

// fn db_out(balances: DatabaseChanges, transfers: DatabaseChanges,supply: DatabaseChanges,contracts: DatabaseChanges) -> Result<DatabaseChanges, Error> {

#[substreams::handlers::map]
fn db_out(balances: DatabaseChanges) -> Result<DatabaseChanges, Error> {

    let array = balances.clone();
    // array.table_changes.extend(supply.table_changes);
    // array.table_changes.extend(contracts.table_changes);
    // array.table_changes.extend(transfers.table_changes);

    Ok(array)
}
