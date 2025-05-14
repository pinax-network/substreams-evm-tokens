use common::logs_with_caller;
use proto::pb::evm::erc20::transfers::v1 as erc20;
use substreams_abis::evm::token::erc20::events;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<erc20::Events, substreams::errors::Error> {
    let mut events = erc20::Events::default();

    for trx in block.transactions() {
        for (log, caller) in logs_with_caller(&block, trx) {
            // Transfer event
            if let Some(event) = events::Transfer::match_and_decode(log) {
                events.transfers.push(erc20::Transfer {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    from: event.from.to_vec(),
                    to: event.to.to_vec(),
                    value: event.value.to_string(),
                });
            }

            // Approval event
            if let Some(event) = events::Approval::match_and_decode(log) {
                events.approvals.push(erc20::Approval {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    owner: event.owner.to_vec(),
                    spender: event.spender.to_vec(),
                    value: event.value.to_string(),
                });
            }
        }
    }
    Ok(events)
}
