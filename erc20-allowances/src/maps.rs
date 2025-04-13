use proto::pb::evm::tokens::allowances::v1::{ApprovalEvent, Events, TransferFromFunction};
use substreams::errors::Error;
use substreams_abis::evm::token::erc20::{events::Approval, functions::TransferFrom};
use substreams_ethereum::{pb::eth::v2::Block, Event, Function};

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<Events, Error> {
    let mut events = Events::default();

    for trx in block.transactions() {
        for (log, call_view) in trx.logs_with_calls() {
            let call = call_view.as_ref();

            // -- TransferFrom --
            if let Some(func) = TransferFrom::match_and_decode(call) {
                events.transfer_from_functions.push(TransferFromFunction {
                    // -- transaction --
                    transaction_id: trx.hash.to_vec(),

                    // -- call --
                    caller: call.caller.to_vec(),

                    // -- ordering --
                    begin_ordinal: call.begin_ordinal,
                    end_ordinal: call.end_ordinal,
                    index: call.index,

                    // -- function --
                    contract: call.address.to_vec(),
                    from: func.from.to_vec(),
                    to: func.to.to_vec(),
                    value: func.amount.to_string(),
                });
            }

            // -- Approval --
            if let Some(event) = Approval::match_and_decode(log) {
                events.approvals_events.push(ApprovalEvent {
                    // -- transaction --
                    transaction_id: trx.hash.to_vec(),

                    // -- call --
                    caller: call.caller.to_vec(),

                    // -- ordering --
                    ordinal: log.ordinal,

                    // -- event --
                    contract: log.address.to_vec(),
                    owner: event.owner.to_vec(),
                    spender: event.spender.to_vec(),
                    value: event.value.to_string(),
                });
            }
        }
    }

    Ok(events)
}
