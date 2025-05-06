use common::logs_with_caller;
use proto::pb::evm::seaport::v1 as seaport;
use proto::pb::evm::seaport::v1::Events;
use substreams_abis::evm::seaport::events;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    for trx in block.transactions() {
        for (log, caller) in logs_with_caller(&block, trx) {
            // OrderFulfilled event
            if let Some(event) = events::OrderFulfilled::match_and_decode(log) {
                events.order_fulfilled.push(seaport::OrderFulfilled {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    order_hash: event.order_hash.to_vec(),
                    offerer: event.offerer.to_vec(),
                    zone: event.zone.to_vec(),
                    recipient: event.recipient.to_vec(),
                    offer: event
                        .offer
                        .iter()
                        .map(|offer| seaport::Offer {
                            item_type: offer.0.to_u64() as u32,
                            token: offer.1.to_vec(),
                            identifier: offer.2.to_string(),
                            amount: offer.3.to_string(),
                        })
                        .collect(),
                    consideration: event
                        .consideration
                        .iter()
                        .map(|consideration| seaport::Consideration {
                            item_type: consideration.0.to_u64() as u32,
                            token: consideration.1.to_vec(),
                            identifier: consideration.2.to_string(),
                            amount: consideration.3.to_string(),
                            recipient: consideration.4.to_vec(),
                        })
                        .collect(),
                });
            }

            // OrdersMatched event
            if let Some(event) = events::OrdersMatched::match_and_decode(log) {
                events.orders_matched.push(seaport::OrdersMatched {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    order_hashes: event.order_hashes.iter().map(|order_hash| order_hash.to_vec()).collect(),
                });
            }

            // OrderCancelled event
            if let Some(event) = events::OrderCancelled::match_and_decode(log) {
                events.order_cancelled.push(seaport::OrderCancelled {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    order_hash: event.order_hash.to_vec(),
                    offerer: event.offerer.to_vec(),
                    zone: event.zone.to_vec(),
                });
            }
        }
    }
    Ok(events)
}
