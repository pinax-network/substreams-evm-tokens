use proto::pb::evm::ens::v1::Events;
pub use substreams_abis::evm::ens::v1 as ens;
use substreams_ethereum::pb::eth::v2::Block;

use crate::events::{
    ens_registry::insert_ens_registry, eth_registrar_controller_base::insert_base_eth_registrar_controller,
    eth_registrar_controller_v0::insert_eth_registrar_controller_v0, eth_registrar_controller_v1::insert_eth_registrar_controller_v1,
    public_resolver_v1::insert_public_resolver_v1, reverse_registrar::insert_reverse_registrar,
};

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    for trx in block.transactions() {
        for (log, call_view) in trx.logs_with_calls() {
            let call = call_view.call;
            insert_public_resolver_v1(&mut events, trx, call, log);
            insert_ens_registry(&mut events, trx, call, log);
            insert_reverse_registrar(&mut events, trx, call, log);

            // eth_registrar_controller
            insert_eth_registrar_controller_v0(&mut events, trx, call, log);
            insert_eth_registrar_controller_v1(&mut events, trx, call, log);
            insert_base_eth_registrar_controller(&mut events, trx, call, log);
        }
    }
    Ok(events)
}
