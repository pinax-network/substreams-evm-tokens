-- Native balance by account --
-- There can only be a single Native balance change per block for a given address  --
CREATE TABLE IF NOT EXISTS native_balance_changes  (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- event --
    address              FixedString(42),
    balance              UInt256,

    -- indexes --
    INDEX idx_block_num          (block_num)           TYPE minmax GRANULARITY 4,
    INDEX idx_timestamp          (timestamp)           TYPE minmax GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_address            (address)             TYPE bloom_filter GRANULARITY 4,
    INDEX idx_balance            (balance)             TYPE minmax GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (address, block_num);
