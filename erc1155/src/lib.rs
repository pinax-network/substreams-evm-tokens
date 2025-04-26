mod db_out;
mod events;
mod pb;
mod transactions;

use pb::evm::erc1155::events::v1::{Events, Token, Transfer};
use substreams_ethereum::pb::eth::v2 as eth;

/// Extracts events events from the logs
#[substreams::handlers::map]
fn map_events(blk: eth::Block) -> Result<Events, substreams::errors::Error> {
    let transfers: Vec<Transfer> = events::get_transfers(&blk).collect();
    let tokens: Vec<Token> = events::get_tokens(&blk).collect();

    // Collect all transaction hashes involved in any ERC721 event
    let event_tx_hashes: std::collections::HashSet<Vec<u8>> = tokens.iter().map(|t| t.tx_hash.to_vec()).collect();

    let transactions = transactions::get_transactions(&blk, &event_tx_hashes);

    Ok(Events {
        transfers,
        transactions,
        tokens,
    })
}
