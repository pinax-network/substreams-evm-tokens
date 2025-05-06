use common::bytes_to_hex;
use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};
use proto::pb::evm::erc1155::v1 as erc1155;
use proto::pb::evm::erc721::metadata::v1 as erc721_metadata;
use proto::pb::evm::erc721::v1 as erc721;
use proto::pb::evm::seaport::v1 as seaport;
use substreams::pb::substreams::Clock;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;

#[substreams::handlers::map]
pub fn db_out(
    mut clock: Clock,
    erc721: erc721::Events,
    erc721_metadata: erc721_metadata::Events,
    erc1155: erc1155::Events,
    seaport: seaport::Events,
) -> Result<DatabaseChanges, substreams::errors::Error> {
    let mut tables = Tables::new();
    let mut index = 0; // incremental index for each event

    // ERC721 Transfers
    for event in erc721.transfers {
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

    // ERC1155 Transfers Single
    for event in erc1155.transfers_single {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc1155_transfers", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("operator", bytes_to_hex(&event.operator))
            .set("id", &event.id)
            .set("from", bytes_to_hex(&event.from))
            .set("to", bytes_to_hex(&event.to))
            .set("value", &event.value);

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // ERC1155 Transfers Batch
    for event in erc1155.transfers_batch {
        event.ids.iter().enumerate().for_each(|(i, id)| {
            let key = common_key(&clock, index);
            let row = tables
                .create_row("erc1155_transfers", key)
                .set("contract", bytes_to_hex(&event.contract))
                .set("operator", bytes_to_hex(&event.operator))
                .set("from", bytes_to_hex(&event.from))
                .set("to", bytes_to_hex(&event.to))
                .set("id", id)
                .set("value", &event.values[i]);

            set_caller(event.caller.clone(), row);
            set_ordering(index, Some(event.ordinal), &clock, row);
            set_tx_hash(Some(event.tx_hash.clone()), row);
            set_clock(&clock, row);
            index += 1;
        });
    }

    // ERC721 Metadata by Tokens
    for event in erc721_metadata.metadata_by_tokens {
        let key = common_key(&clock, index);

        let row = tables
            .create_row("erc721_metadata_by_token", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("token_id", &event.token_id)
            .set("uri", event.uri());

        set_clock(&clock, row);
        index += 1;
    }

    // ERC721 Metadata by Contract
    for event in erc721_metadata.metadata_by_contracts {
        let key = common_key(&clock, index);

        let row = tables
            .create_row("erc721_metadata_by_contract", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("name", event.name())
            .set("symbol", event.symbol())
            .set("total_supply", event.total_supply())
            .set("base_uri", event.base_uri());

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
