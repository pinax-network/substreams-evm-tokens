use common::{bytes_to_hex, clickhouse::set_clock};
use proto::pb::evm::erc721;
use substreams::pb::substreams::Clock;

pub fn process_erc721_metadata(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc721::metadata::v1::Events) {
    // ERC721 Metadata by Tokens
    for event in events.metadata_by_tokens {
        let key = [("contract", bytes_to_hex(&event.contract)), ("token_id", event.token_id.to_string())];
        // Skip if URI is not set
        if event.uri.is_none() {
            continue; // INCLUDE for testing purposes
        }

        let row = tables
            .create_row("erc721_metadata_by_token", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("token_id", &event.token_id)
            .set("uri", event.uri());

        set_clock(&clock, row);
    }

    // ERC721 Metadata by Contract
    for event in events.metadata_by_contracts.iter() {
        let key = [("contract", bytes_to_hex(&event.contract))];
        // Skip if name and symbol and base_uri is not set
        if event.name.is_none() && event.symbol.is_none() && event.base_uri.is_none() {
            continue; // INCLUDE for testing purposes
        }

        let row = tables
            .create_row("erc721_metadata_by_contract", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("name", event.name())
            .set("symbol", event.symbol());

        set_clock(&clock, row);
    }

    // ERC721 Total Supply by Contract
    for event in events.metadata_by_contracts.iter() {
        let key = [("contract", bytes_to_hex(&event.contract))];
        // Skip if total supply is not set
        if event.total_supply.is_none() {
            continue; // INCLUDE for testing purposes
        }

        let row = tables
            .create_row("erc721_total_supply", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("total_supply", event.total_supply());

        set_clock(&clock, row);
    }

    // ERC721 Base URI by Contract
    for event in events.metadata_by_contracts {
        let key = [("contract", bytes_to_hex(&event.contract))];
        // Skip if total supply is not set
        if event.base_uri().len() == 0 {
            continue; // INCLUDE for testing purposes
        }

        let row = tables
            .create_row("erc721_base_uri", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("base_uri", event.base_uri());

        set_clock(&clock, row);
    }
}
