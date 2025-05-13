mod abi;
mod functions;
use proto::pb::evm::erc20::metadata::v1::{Events, MetadataChanges};
use substreams::errors::Error;
use substreams_ethereum::pb::eth::v2::Block;

use functions::get_metadata;

#[substreams::handlers::map]
pub fn map_events(block: Block) -> Result<Events, Error> {
    let mut events = Events::default();

    // Extended blocks ONLY since we need to extract data from calls
    for trx in block.transactions() {
        for call_view in trx.calls() {
            let call = call_view.call;

            if let Some(result) = get_metadata(call) {
                events.metadata_changes.push(MetadataChanges {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: call.caller.to_vec(),
                    address: call.address.to_vec(),
                    begin_ordinal: call.begin_ordinal,
                    end_ordinal: call.end_ordinal,

                    // -- function --
                    name: result.name,
                    symbol: result.symbol,
                });
            }
        }
    }
    Ok(events)
}
