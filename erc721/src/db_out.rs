use crate::pb::evm::erc721::events::v1::{Events, Mints, Token, Transfer};
use common::{bytes_to_hex, is_zero_address};
use std::collections::HashMap;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;

#[substreams::handlers::map]
pub fn db_out(mut events: Events, mints: Mints) -> Result<DatabaseChanges, substreams::errors::Error> {
    let mut tables = Tables::new();

    merge_metadata(&mut events.transfers, &mints.tokens);

    // Transfers
    for transfer in events.transfers {
        let row = tables.create_row(
            "erc721_transfers",
            [
                ("block_num", transfer.block_num.to_string()),
                ("tx_hash", bytes_to_hex(&transfer.tx_hash)),
                ("log_index", transfer.log_index.to_string()),
            ],
        );
        row.set("contract", bytes_to_hex(&transfer.contract))
            .set("from", bytes_to_hex(&transfer.from))
            .set("to", bytes_to_hex(&transfer.to))
            .set("token_id", &transfer.token_id)
            .set("uri", transfer.uri.as_deref().unwrap_or(""))
            .set("symbol", transfer.symbol.as_deref().unwrap_or(""))
            .set("name", transfer.name.as_deref().unwrap_or(""));
    }

    // Transactions
    for tx in events.transactions {
        let row = tables.create_row(
            "erc721_transactions",
            [("block_number", tx.block_number.to_string()), ("tx_hash", bytes_to_hex(&tx.tx_hash))],
        );
        row.set("block_timestamp", tx.block_timestamp.to_string())
            .set("block_hash", bytes_to_hex(&tx.block_hash))
            .set("nonce", tx.nonce.to_string())
            .set("position", tx.position.to_string())
            .set("from_address", bytes_to_hex(&tx.from_address))
            .set("to_address", bytes_to_hex(&tx.to_address))
            .set("value", &tx.value)
            .set("tx_fee", &tx.tx_fee)
            .set("gas_price", &tx.gas_price)
            .set("gas_limit", tx.gas_limit.to_string())
            .set("gas_used", tx.gas_used.to_string())
            .set("cumulative_gas_used", tx.cumulative_gas_used.to_string())
            .set("max_fee_per_gas", &tx.max_fee_per_gas)
            .set("max_priority_fee_per_gas", &tx.max_priority_fee_per_gas)
            .set("input", bytes_to_hex(&tx.input))
            .set("type", tx.r#type.to_string())
            .set("v", bytes_to_hex(&tx.v))
            .set("r", bytes_to_hex(&tx.r))
            .set("s", bytes_to_hex(&tx.s));
    }

    Ok(tables.to_database_changes())
}

fn merge_metadata(transfers: &mut Vec<Transfer>, tokens: &[Token]) {
    let mint_map: HashMap<(&[u8], &str), &Token> = tokens.iter().map(|token| ((token.contract.as_ref(), token.token_id.as_str()), token)).collect();

    for transfer in transfers {
        if is_zero_address(&transfer.from) {
            if let Some(token) = mint_map.get(&(transfer.contract.as_ref(), &transfer.token_id)) {
                transfer.uri = token.uri.clone();
                transfer.symbol = token.symbol.clone();
                transfer.name = token.name.clone();
            }
        }
    }
}
