use common::{
    bytes_to_hex,
    clickhouse::{common_key, set_log},
};
use proto::pb::evm::seaport;
use substreams::pb::substreams::Clock;

use crate::to_json::{considerations_to_json, offers_to_json};

pub fn process_seaport(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: seaport::v1::Events) {
    let mut index = 0; // relative index for events

    // Seaport Order Fufilled
    for event in events.order_fulfilled {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("seaport_order_fulfilled", key)
            .set("order_hash", bytes_to_hex(&event.order_hash))
            .set("offerer", bytes_to_hex(&event.offerer))
            .set("zone", bytes_to_hex(&event.zone))
            .set("recipient", bytes_to_hex(&event.recipient))
            .set("offer_raw", offers_to_json(event.offer).to_string())
            .set("consideration_raw", considerations_to_json(event.consideration).to_string());

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // Seaport Orders Matched
    for event in events.orders_matched {
        let key = common_key(&clock, index);
        // convert as String
        let order_hashes_raw = event.order_hashes.iter().map(|h| bytes_to_hex(h)).collect::<Vec<String>>().join(",");
        let row = tables.create_row("seaport_orders_matched", key).set("order_hashes_raw", order_hashes_raw);

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // Seaport Order Cancelled
    for event in events.order_cancelled {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("seaport_order_cancelled", key)
            .set("order_hash", bytes_to_hex(&event.order_hash))
            .set("offerer", bytes_to_hex(&event.offerer))
            .set("zone", bytes_to_hex(&event.zone));

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }
}
