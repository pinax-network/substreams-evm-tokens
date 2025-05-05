
use common::is_zero_address;
use proto::pb::evm::erc721::v1::Events as ERC721Transfers;
use proto::pb::evm::erc721::v1::{EventsMetadata, Metadata};

#[substreams::handlers::map]
fn map_events(erc721_transfers: ERC721Transfers) -> Result<EventsMetadata, substreams::errors::Error> {
    let mut events = EventsMetadata::default();

    for transfer in erc721_transfers.transfers {
        // only track mints
        if !is_zero_address(transfer.from) {
            continue;
        }
        events.metadatas.push(Metadata {
            contract: transfer.contract.to_vec(),
            token_id: transfer.token_id.to_string(),
            uri: None,
            symbol: None,
            name: None,
        });
    }

    Ok(events)
}
