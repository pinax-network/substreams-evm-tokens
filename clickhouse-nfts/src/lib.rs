mod enums;
mod to_json;
use crate::enums::{TokenStandard, TransferType};
use common::bytes_to_hex;
use common::clickhouse::{common_key, set_caller, set_clock, set_ordering, set_tx_hash};
use proto::pb::evm::erc1155::v1 as erc1155;
use proto::pb::evm::erc721::metadata::v1 as erc721_metadata;
use proto::pb::evm::erc721::v1 as erc721;
use proto::pb::evm::seaport::v1 as seaport;
use substreams::pb::substreams::Clock;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;
use to_json::{considerations_to_json, offers_to_json};

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
            .set("to", bytes_to_hex(&event.to))
            // to be compatible with ERC1155 table schema
            .set("operator", "".to_string())
            .set("amount", 1)
            .set("transfer_type", TransferType::Single.to_string()) // Enum8('Single' = 1, 'Batch' = 2)
            .set("token_standard", TokenStandard::ERC721.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2)

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // ERC721 Approvals
    for event in erc721.approvals {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc721_approvals", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("owner", bytes_to_hex(&event.owner))
            .set("approved", bytes_to_hex(&event.approved))
            .set("token_id", &event.token_id);

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // ERC721 Approvals For All
    for event in erc721.approvals_for_all {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc721_approvals_for_all", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("owner", bytes_to_hex(&event.owner))
            .set("operator", bytes_to_hex(&event.operator))
            .set("approved", &event.approved.to_string())
            .set("token_standard", TokenStandard::ERC721.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2);

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
            .set("token_id", &event.id)
            .set("from", bytes_to_hex(&event.from))
            .set("to", bytes_to_hex(&event.to))
            .set("amount", &event.value)
            .set("transfer_type", TransferType::Single.to_string()) // Enum8('Single' = 1, 'Batch' = 2)
            .set("token_standard", TokenStandard::ERC1155.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2)

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
                .set("token_id", id)
                .set("amount", &event.values[i])
                .set("transfer_type", TransferType::Batch.to_string()) // Enum8('Single' = 1, 'Batch' = 2)
                .set("token_standard", TokenStandard::ERC1155.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2)

            set_caller(event.caller.clone(), row);
            set_ordering(index, Some(event.ordinal), &clock, row);
            set_tx_hash(Some(event.tx_hash.clone()), row);
            set_clock(&clock, row);
            index += 1;
        });
    }

    // ERC1155 Approvals For All
    for event in erc1155.approvals_for_all {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc1155_approvals_for_all", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("owner", bytes_to_hex(&event.account))
            .set("operator", bytes_to_hex(&event.operator))
            .set("approved", &event.approved.to_string())
            .set("token_standard", TokenStandard::ERC1155.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2);

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // ERC721 Metadata by Tokens
    for event in erc721_metadata.metadata_by_tokens {
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
        index += 1;
    }

    // ERC1155 Metadata by Tokens
    for event in erc1155.uris {
        let key = [("contract", bytes_to_hex(&event.contract)), ("token_id", event.id.to_string())];
        // Skip if URI is not set
        if event.value.len() == 0 {
            continue; // INCLUDE for testing purposes
        }

        let row = tables
            .create_row("erc1155_metadata_by_token", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("token_id", &event.id)
            .set("uri", event.value);

        set_clock(&clock, row);
        index += 1;
    }

    // ERC721 Metadata by Contract
    for event in erc721_metadata.metadata_by_contracts.iter() {
        let key = [("contract", bytes_to_hex(&event.contract))];
        // Skip if name and symbol and base_uri is not set
        if event.name.is_none() && event.symbol.is_none() && event.base_uri.is_none() {
            continue; // INCLUDE for testing purposes
        }

        let row = tables
            .create_row("erc721_metadata_by_contract", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("name", event.name())
            .set("symbol", event.symbol())
            .set("base_uri", event.base_uri());

        set_clock(&clock, row);
        index += 1;
    }

    // ERC721 Total Supply by Contract
    for event in erc721_metadata.metadata_by_contracts {
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
        index += 1;
    }

    // Seaport Order Fufilled
    for event in seaport.order_fulfilled {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("seaport_order_fulfilled", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("order_hash", bytes_to_hex(&event.order_hash))
            .set("offerer", bytes_to_hex(&event.offerer))
            .set("zone", bytes_to_hex(&event.zone))
            .set("recipient", bytes_to_hex(&event.recipient))
            .set("offer_raw", offers_to_json(event.offer).to_string())
            .set("consideration_raw", considerations_to_json(event.consideration).to_string());

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // Seaport Orders Matched
    for event in seaport.orders_matched {
        let key = common_key(&clock, index);
        // convert as String
        let order_hashes_raw = event.order_hashes.iter().map(|h| bytes_to_hex(h)).collect::<Vec<String>>().join(",");
        let row = tables
            .create_row("seaport_orders_matched", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("order_hashes_raw", order_hashes_raw);

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    // Seaport Order Cancelled
    for event in seaport.order_cancelled {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("seaport_order_cancelled", key)
            .set("contract", bytes_to_hex(&event.contract))
            .set("order_hash", bytes_to_hex(&event.order_hash))
            .set("offerer", bytes_to_hex(&event.offerer))
            .set("zone", bytes_to_hex(&event.zone));

        set_caller(event.caller, row);
        set_ordering(index, Some(event.ordinal), &clock, row);
        set_tx_hash(Some(event.tx_hash), row);
        set_clock(&clock, row);
        index += 1;
    }

    Ok(tables.to_database_changes())
}
