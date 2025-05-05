use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};
use common::bytes_to_hex;
use proto::pb::evm::erc1155::v1::Events as ERC1155Events;
use proto::pb::evm::erc721::v1::Events as ERC721Events;
use substreams::pb::substreams::Clock;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;

#[substreams::handlers::map]
pub fn db_out(mut clock: Clock, erc721_events: ERC721Events, erc1155_events: ERC1155Events) -> Result<DatabaseChanges, substreams::errors::Error> {
    let mut tables = Tables::new();
    let mut index = 0; // incremental index for each event

    // Transfers
    for event in erc721_events.transfers {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc721_transfers", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("token_id", &event.token_id)
            .set("from", bytes_to_hex(&event.from))
            .set("to", bytes_to_hex(&event.to));

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // Transfers
    for event in erc1155_events.transfers_single {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc1155_transfers", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("operator", bytes_to_hex(&event.operator))
            .set("token_id", &event.id)
            .set("from", bytes_to_hex(&event.from))
            .set("to", bytes_to_hex(&event.to))
            .set("amount", &event.value);

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // for token in erc721_events.tokens {
    //     i += 1;
    //     let row = tables.create_row("nft_tokens", [("contract", bytes_to_hex(&token.contract)), ("token_id", token.token_id)]);
    //     row.set("global_sequence", to_global_sequence(&clock, i))
    //         .set("block_num", clock.number.to_string())
    //         .set("tx_hash", bytes_to_hex(&token.tx_hash))
    //         .set("evt_index", token.log_index.to_string())
    //         .set("timestamp", clock.timestamp.unwrap().seconds)
    //         .set("token_standard", TokenStandard::ERC721.to_string())
    //         .set("uri", token.uri.as_deref().unwrap_or(""))
    //         .set("symbol", token.symbol.as_deref().unwrap_or(""))
    //         .set("name", token.name.as_deref().unwrap_or(""));
    // }

    // for token in erc1155_events.tokens {
    //     i += 1;
    //     let row = tables.create_row("nft_tokens", [("contract", bytes_to_hex(&token.contract)), ("token_id", token.token_id)]);
    //     row.set("global_sequence", to_global_sequence(&clock, i))
    //         .set("block_num", clock.number.to_string())
    //         .set("tx_hash", bytes_to_hex(&token.tx_hash))
    //         .set("evt_index", token.log_index.to_string())
    //         .set("timestamp", clock.timestamp.unwrap().seconds)
    //         .set("token_standard", TokenStandard::ERC1155.to_string())
    //         .set("uri", token.uri)
    //         .set("symbol", "")
    //         .set("name", "");
    // }

    Ok(tables.to_database_changes())
}
