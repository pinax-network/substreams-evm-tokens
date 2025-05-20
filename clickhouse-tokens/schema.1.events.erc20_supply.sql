-- ERC-20 Total Suppy changes --
-- There can only be a single ERC-20 supply change per block per contract  --
CREATE TABLE IF NOT EXISTS erc20_total_supply_changes  (
    -- block --
    block_num               UInt32,
    block_hash              FixedString(66),
    timestamp               DateTime(0, 'UTC'),

    -- event --
    contract                FixedString(42),
    total_supply            UInt256,

    -- indexes --
    INDEX idx_block_num           (block_num)             TYPE minmax GRANULARITY 4,
    INDEX idx_timestamp           (timestamp)             TYPE minmax GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract            (contract)              TYPE bloom_filter GRANULARITY 4,
    INDEX idx_total_supply        (total_supply)          TYPE minmax GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (contract, block_num);
