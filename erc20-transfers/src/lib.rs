use common::logs_with_caller;
use proto::pb::evm::erc20::transfers::v1 as erc20;
use substreams::log;
use substreams_abis::evm::token::erc20::events;
use substreams_abis::evm::tokens::weth::events as weth;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::{Event, NULL_ADDRESS};

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<erc20::Events, substreams::errors::Error> {
    let mut events = erc20::Events::default();
    let mut weth_withdrawals = 0;
    let mut weth_deposits = 0;
    let mut erc20_transfers = 0;

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
                erc20_transfers += 1;
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

            // WETH9 Deposit must trigger Transfer event
            if let Some(event) = weth::Deposit::match_and_decode(log) {
                events.transfers.push(erc20::Transfer {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    from: NULL_ADDRESS.to_vec(),
                    to: event.dst.to_vec(),
                    value: event.wad.to_string(),
                });
                weth_deposits += 1;
            }

            // WETH9 Withdrawal must trigger Transfer event
            if let Some(event) = weth::Withdrawal::match_and_decode(log) {
                events.transfers.push(erc20::Transfer {
                    // -- transaction --
                    tx_hash: trx.hash.to_vec(),

                    // -- call --
                    caller: caller.clone(),

                    // -- log --
                    contract: log.address.to_vec(),
                    ordinal: log.ordinal,

                    // -- event --
                    from: event.src.to_vec(),
                    to: NULL_ADDRESS.to_vec(),
                    value: event.wad.to_string(),
                });
                weth_withdrawals += 1;
            }
        }
    }
    log::info!(
        "\nERC20 transfers={}\nWETH9 deposits={}\nWETH9 withdrawals={}",
        erc20_transfers,
        weth_deposits,
        weth_withdrawals
    );
    Ok(events)
}
