use common::{
    bytes_to_hex,
    clickhouse::{common_key, set_log},
};
use proto::pb::evm::cryptopunks;
use substreams::pb::substreams::Clock;

pub fn process_cryptopunks(tables: &mut substreams_database_change::tables::Tables, clock: &Clock, events: cryptopunks::v1::Events) {
    let mut index = 0; // relative index for events

    // Punk Assigns
    for event in events.assigns {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("punk_assigns", key)
            .set("to", bytes_to_hex(&event.to))
            .set("punk_index", &event.punk_index);

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // Punk Transfers
    for event in events.punk_transfers {
        let key = common_key(&clock, index);
        let row = tables
            .create_row("punk_transfers", key)
            .set("from", bytes_to_hex(&event.from))
            .set("to", bytes_to_hex(&event.to))
            .set("punk_index", &event.punk_index);

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // Punk Bought
    for event in events.punk_boughts {
        let key = common_key(&clock, index);

        let row = tables
            .create_row("punk_bought", key)
            .set("from", bytes_to_hex(&event.from_address))
            .set("to", bytes_to_hex(&event.to_address))
            .set("punk_index", &event.punk_index)
            .set("value_is_null", &event.value.is_none().to_string())
            .set("value", &event.value.unwrap_or_default().to_string());

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // PunkBidEntered
    for event in events.punk_bid_entereds {
        let key = common_key(&clock, index);

        let row = tables
            .create_row("punk_bid_entered", key)
            .set("from", bytes_to_hex(&event.from_address))
            .set("punk_index", &event.punk_index)
            .set("value", &event.value.to_string());

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // PunkBidWithdrawn
    for event in events.punk_bid_withdrawns {
        let key = common_key(&clock, index);

        let row = tables
            .create_row("punk_bid_withdrawn", key)
            .set("from", bytes_to_hex(&event.from_address))
            .set("punk_index", &event.punk_index)
            .set("value", &event.value.to_string());

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }

    // PunkNoLongerForSale
    for event in events.punk_no_longer_for_sales {
        let key = common_key(&clock, index);
        let row = tables.create_row("punk_no_longer_for_sale", key).set("punk_index", &event.punk_index);

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }
    // PunkOffered
    for event in events.punk_offereds {
        let key = common_key(&clock, index);

        let row = tables
            .create_row("punk_offered", key)
            .set("to", bytes_to_hex(&event.to_address))
            .set("punk_index", &event.punk_index)
            .set("min_value", &event.min_value.to_string());

        set_log(&clock, index, event.tx_hash, event.contract, event.ordinal, event.caller, row);
        index += 1;
    }
}
