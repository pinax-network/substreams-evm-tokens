use common::logs_with_caller;
use proto::pb::evm::erc721::v1::{Approval, ApprovalForAll, Events, Transfer};
use substreams_abis::evm::token::erc721::events as erc721;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    for trx in block.transactions() {
        for (log, caller) in logs_with_caller(&block, trx) {
            // -- Transfer --
            if let Some(event) = erc721::Transfer::match_and_decode(log) {
                events.transfers.push(Transfer {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    ordinal: log.ordinal,
                    contract: log.address.to_vec(),

                    // -- event --
                    from: event.from.to_vec(),
                    to: event.to.to_vec(),
                    token_id: event.token_id.to_string(),
                });
            }

            // -- Approval --
            if let Some(event) = erc721::Approval::match_and_decode(log) {
                events.approvals.push(Approval {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    ordinal: log.ordinal,
                    contract: log.address.to_vec(),

                    // -- event --
                    owner: event.owner.to_vec(),
                    approved: event.approved.to_vec(),
                    token_id: event.token_id.to_string(),
                });
            }

            // -- ApprovalForAll --
            if let Some(event) = erc721::ApprovalForAll::match_and_decode(log) {
                events.approvals_for_all.push(ApprovalForAll {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller,

                    // -- log --
                    ordinal: log.ordinal,
                    contract: log.address.to_vec(),

                    // -- event --
                    owner: event.owner.to_vec(),
                    operator: event.operator.to_vec(),
                    approved: event.approved,
                });
            }
        }
    }

    Ok(events)
}
