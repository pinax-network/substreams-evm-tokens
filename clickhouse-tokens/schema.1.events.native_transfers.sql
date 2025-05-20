-- Native transfers --
CREATE TABLE IF NOT EXISTS native_transfers  (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- transaction --
    tx_hash              FixedString(66),

    -- event --
    `from`               FixedString(42) COMMENT 'sender address', -- log.topics[1]
    `to`                 FixedString(42) COMMENT 'recipient address', -- log.topics[2]
    value                UInt256 COMMENT 'transfer value', -- log.data

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)            TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_from               (`from`)             TYPE bloom_filter GRANULARITY 4,
    INDEX idx_to                 (`to`)               TYPE bloom_filter GRANULARITY 4,
    INDEX idx_value              (value)              TYPE minmax GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS native_transfers_from_fees AS native_transfers
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS native_transfers_from_block_rewards AS native_transfers
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS native_transfers_from_calls AS native_transfers
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);