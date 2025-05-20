use common::{
    bytes_to_hex,
    clickhouse::{common_key, set_clock, set_log},
};
use proto::pb::evm::erc1155::v1 as erc1155;
use substreams::pb::substreams::Clock;

use crate::enums::{TokenStandard, TransferType};

pub fn process_erc1155(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc1155::Events) {
    let mut index = 0; // relative index for events

    // ERC1155 Transfers Single
    for event in events.transfers_single {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc1155_transfers", key)
            .set("operator", bytes_to_hex(&event.operator))
            .set("token_id", &event.id)
            .set("from", bytes_to_hex(&event.from))
            .set("to", bytes_to_hex(&event.to))
            .set("amount", &event.value)
            .set("transfer_type", TransferType::Single.to_string()) // Enum8('Single' = 1, 'Batch' = 2)
            .set("token_standard", TokenStandard::ERC1155.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2)

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // ERC1155 Transfers Batch
    for event in events.transfers_batch {
        event.ids.iter().enumerate().for_each(|(i, id)| {
            let key = common_key(&clock, index);
            let row = tables
                .create_row("erc1155_transfers", key)
                .set("operator", bytes_to_hex(&event.operator))
                .set("from", bytes_to_hex(&event.from))
                .set("to", bytes_to_hex(&event.to))
                .set("token_id", id)
                .set("amount", &event.values[i])
                .set("transfer_type", TransferType::Batch.to_string()) // Enum8('Single' = 1, 'Batch' = 2)
                .set("token_standard", TokenStandard::ERC1155.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2)

            set_log(
                &clock,
                index,
                event.tx_hash.clone(),
                event.contract.clone(),
                event.ordinal,
                event.caller.clone(),
                row,
            );
            index += 1;
        });
    }

    // ERC1155 Approvals For All
    for event in events.approvals_for_all {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc1155_approvals_for_all", key)
            .set("owner", bytes_to_hex(&event.account))
            .set("operator", bytes_to_hex(&event.operator))
            .set("approved", &event.approved.to_string())
            .set("token_standard", TokenStandard::ERC1155.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2);

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // ERC1155 Metadata by Tokens
    for event in events.uris {
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
}
