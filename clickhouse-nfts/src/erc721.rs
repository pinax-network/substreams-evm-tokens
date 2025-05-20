use common::{
    bytes_to_hex,
    clickhouse::{common_key, set_log},
};
use proto::pb::evm::erc721;
use substreams::pb::substreams::Clock;

use crate::enums::{TokenStandard, TransferType};

pub fn process_erc721(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: erc721::v1::Events) {
    let mut index = 0; // relative index for events

    // ERC721 Transfers
    for event in events.transfers {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc721_transfers", key)
            .set("token_id", &event.token_id)
            .set("from", bytes_to_hex(&event.from))
            .set("to", bytes_to_hex(&event.to))
            // to be compatible with ERC1155 table schema
            .set("operator", "".to_string())
            .set("amount", 1)
            .set("transfer_type", TransferType::Single.to_string()) // Enum8('Single' = 1, 'Batch' = 2)
            .set("token_standard", TokenStandard::ERC721.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2)

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // ERC721 Approvals
    for event in events.approvals {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc721_approvals", key)
            .set("owner", bytes_to_hex(&event.owner))
            .set("approved", bytes_to_hex(&event.approved))
            .set("token_id", &event.token_id);

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // ERC721 Approvals For All
    for event in events.approvals_for_all {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("erc721_approvals_for_all", key)
            .set("owner", bytes_to_hex(&event.owner))
            .set("operator", bytes_to_hex(&event.operator))
            .set("approved", &event.approved.to_string())
            .set("token_standard", TokenStandard::ERC721.to_string()); // Enum8('ERC721' = 1, 'ERC1155' = 2);

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }
}
