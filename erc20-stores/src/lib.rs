use proto::pb::evm::erc20::stores::v1::{Events, FirstTransferByContract};
use proto::pb::evm::erc20::transfers::v1::Events as ERC20Transfers;
use std::collections::HashSet;
use substreams::scalar::BigInt;
use substreams::store::{DeltaBigInt, Deltas};
use substreams::store::{StoreAdd, StoreAddBigInt, StoreNew};
use substreams::Hex;

#[substreams::handlers::map]
fn map_events(store_erc20_transfers: Deltas<DeltaBigInt>) -> Result<Events, substreams::errors::Error> {
    let mut events = Events::default();

    for delta in store_erc20_transfers.deltas {
        // only include first transfer
        if delta.old_value != BigInt::zero() {
            continue;
        }
        if let Ok(contract) = Hex::decode(&delta.key) {
            events.first_transfer_by_contract.push(FirstTransferByContract { contract });
        }
    }
    Ok(events)
}

#[substreams::handlers::store]
pub fn store_erc20_transfers(erc20_transfers: ERC20Transfers, store: StoreAddBigInt) {
    // Collect unique token contracts
    let mut transfers: HashSet<Vec<u8>> = HashSet::new();
    for transfer in &erc20_transfers.transfers {
        transfers.insert(transfer.contract.clone());
    }

    // flag token contracts with transfers in store
    for address in transfers {
        store.add(0, Hex::encode(address), BigInt::one());
    }
}
