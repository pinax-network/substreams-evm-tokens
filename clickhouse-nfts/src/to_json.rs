use common::bytes_to_hex;
use proto::pb::evm::seaport::v1::{Consideration, Offer};
use serde_json::json;

pub fn offers_to_json(offers: Vec<Offer>) -> serde_json::Value {
    let offers_json: Vec<serde_json::Value> = offers
        .into_iter()
        .map(|offer| {
            json!({
                "item_type": offer.item_type,
                "token": bytes_to_hex(&offer.token),
                "identifier": offer.identifier,
                "amount": offer.amount,
            })
        })
        .collect();
    json!(offers_json)
}

pub fn considerations_to_json(considerations: Vec<Consideration>) -> serde_json::Value {
    let considerations_json: Vec<serde_json::Value> = considerations
        .into_iter()
        .map(|consideration| {
            json!({
                "item_type": consideration.item_type,
                "token": bytes_to_hex(&consideration.token),
                "identifier": consideration.identifier,
                "amount": consideration.amount,
                "recipient": bytes_to_hex(&consideration.recipient),
            })
        })
        .collect();
    json!(considerations_json)
}
