-- ERC-20 balance by account --
-- There can only be a single ERC-20 balance change per block for a given address / contract pair --
CREATE TABLE IF NOT EXISTS erc20_balance_changes  (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- event --
    contract             FixedString(42),
    address              FixedString(42),
    balance              UInt256,

    -- indexes --
    INDEX idx_block_num          (block_num)           TYPE minmax GRANULARITY 4,
    INDEX idx_timestamp          (timestamp)           TYPE minmax GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)            TYPE set(64) GRANULARITY 4,
    INDEX idx_address            (address)             TYPE bloom_filter GRANULARITY 4,
    INDEX idx_balance            (balance)             TYPE minmax GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (contract, address, block_num);
