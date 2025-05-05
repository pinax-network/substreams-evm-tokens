use substreams_ethereum::pb::eth::v2::Block;
use proto::pb::evm::erc1155::v1::{TransferSingle, TransferBatch, ApprovalForAll, Events, Uri};
use substreams_abis::evm::token::erc1155::events as erc1155;
use substreams_ethereum::Event;

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    for trx in block.transactions() {
        for (log, call_view) in trx.logs_with_calls() {
            let call = call_view.call;

            // -- TransferSingle --
            if let Some(event) = erc1155::TransferSingle::match_and_decode(log) {
                events.transfers_single.push(TransferSingle {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: Some(call.caller.to_vec()),

                    // -- log --
                    ordinal: log.ordinal,
                    contract: log.address.to_vec(),

                    // -- event --
                    operator: event.operator.to_vec(),
                    from: event.from.to_vec(),
                    to: event.to.to_vec(),
                    id: event.id.to_string(), // uint256
                    value: event.value.to_string(), // uint256
                });
            }
            // -- TransferBatch --
            if let Some(event) = erc1155::TransferBatch::match_and_decode(log) {
                events.transfers_batch.push(TransferBatch {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: Some(call.caller.to_vec()),

                    // -- log --
                    ordinal: log.ordinal,
                    contract: log.address.to_vec(),

                    // -- event --
                    operator: event.operator.to_vec(),
                    from: event.from.to_vec(),
                    to: event.to.to_vec(),
                    ids: event.ids.iter().map(|id| id.to_string()).collect(), // uint256[]
                    values: event.values.iter().map(|value| value.to_string()).collect(), // uint256[]
                });
            }
            // -- ApprovalForAll --
            if let Some(event) = erc1155::ApprovalForAll::match_and_decode(log) {
                events.approvals_for_all.push(ApprovalForAll {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: Some(call.caller.to_vec()),

                    // -- log --
                    ordinal: log.ordinal,
                    contract: log.address.to_vec(),

                    // -- event --
                    account: event.account.to_vec(),
                    operator: event.operator.to_vec(),
                    approved: event.approved,
                });
            }

            // -- URI --
            if let Some(event) = erc1155::Uri::match_and_decode(log) {
                events.uris.push(Uri {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: Some(call.caller.to_vec()),

                    // -- log --
                    ordinal: log.ordinal,
                    contract: log.address.to_vec(),

                    // -- event --
                    value: event.value,
                    id: event.id.to_string(), // uint256
                });
            }
        }
    }

    Ok(events)
}
