use crate::pb::evm::erc721::events::v1::Transfer;
use common::is_zero_address;
use substreams_abis::evm::token::erc721;
use substreams_ethereum::pb::eth::v2 as eth;
use substreams_ethereum::Event;

/// Helper that extracts ERC721 transfer events from a block
fn extract_erc721_events<'a, T, F>(blk: &'a eth::Block, process_event: F) -> impl Iterator<Item = T> + 'a
where
    F: Fn(u64, &[u8], u64, &[u8], erc721::events::Transfer) -> Option<T> + 'a + Copy,
{
    let block_num = blk.number;
    blk.receipts().flat_map(move |receipt| {
        let hash = &receipt.transaction.hash;
        let contract = &receipt.transaction.to;
        receipt.receipt.logs.iter().filter_map(move |log| {
            if let Some(event) = erc721::events::Transfer::match_and_decode(log) {
                process_event(block_num, hash, log.block_index as u64, contract, event)
            } else {
                None
            }
        })
    })
}

pub fn get_all<'a>(blk: &'a eth::Block) -> impl Iterator<Item = Transfer> + 'a {
    extract_erc721_events(blk, |block_num, hash, log_index, contract, event| {
        Some(Transfer {
            block_num,
            tx_hash: hash.to_vec().into(),
            log_index,
            contract: contract.to_vec().into(),
            from: event.from.to_vec().into(),
            to: event.to.to_vec().into(),
            token_id: event.token_id.to_string(),
            ..Default::default()
        })
    })
}

#[allow(dead_code)]
pub fn get_transfers<'a>(blk: &'a eth::Block) -> impl Iterator<Item = Transfer> + 'a {
    extract_erc721_events(blk, |block_num, hash, log_index, contract, event| {
        let from = &event.from;
        let to = &event.to;

        if !is_zero_address(from) && !is_zero_address(to) {
            Some(Transfer {
                block_num,
                tx_hash: hash.to_vec().into(),
                log_index,
                contract: contract.to_vec().into(),
                from: from.to_vec().into(),
                to: to.to_vec().into(),
                token_id: event.token_id.to_string(),
                ..Default::default()
            })
        } else {
            None
        }
    })
}

pub fn get_mints<'a>(blk: &'a eth::Block) -> impl Iterator<Item = Transfer> + 'a {
    extract_erc721_events(blk, |block_num, hash, log_index, contract, event| {
        let from = &event.from;
        let to = &event.to;

        if is_zero_address(from.as_ref() as &[u8]) {
            Some(Transfer {
                block_num,
                tx_hash: hash.to_vec().into(),
                log_index,
                contract: contract.to_vec().into(),
                to: to.to_vec().into(),
                token_id: event.token_id.to_string(),
                ..Default::default()
            })
        } else {
            None
        }
    })
}

#[allow(dead_code)]
pub fn get_burns<'a>(blk: &'a eth::Block) -> impl Iterator<Item = Transfer> + 'a {
    extract_erc721_events(blk, |block_num, hash, log_index, contract, event| {
        let to = &event.to;
        let from = &event.from;
        if is_zero_address(to.as_ref() as &[u8]) {
            Some(Transfer {
                block_num,
                tx_hash: hash.to_vec().into(),
                log_index,
                contract: contract.to_vec().into(),
                from: from.to_vec().into(),
                token_id: event.token_id.to_string(),
                ..Default::default()
            })
        } else {
            None
        }
    })
}
