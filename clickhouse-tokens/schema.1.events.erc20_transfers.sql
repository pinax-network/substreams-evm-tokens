-- ERC-20 transfers --
CREATE TABLE IF NOT EXISTS erc20_transfers  (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- transaction --
    tx_hash              FixedString(66),

    -- call --
    caller               FixedString(42),

    -- log --
    contract             FixedString(42),
    ordinal              UInt64, -- log.ordinal

    -- event --
    `from`               FixedString(42) COMMENT 'sender address',
    `to`                 FixedString(42) COMMENT 'recipient address',
    value                UInt256 COMMENT 'transfer value',

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)            TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)             TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)           TYPE set(64) GRANULARITY 4,
    INDEX idx_from               (`from`)             TYPE bloom_filter GRANULARITY 4,
    INDEX idx_to                 (`to`)               TYPE bloom_filter GRANULARITY 4,
    INDEX idx_value              (value)              TYPE minmax GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- ERC-20 approvals --
CREATE TABLE IF NOT EXISTS erc20_approvals  (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- transaction --
    tx_hash              FixedString(66),

    -- call --
    caller               FixedString(42),

    -- log --
    contract             FixedString(42),
    ordinal              UInt64, -- log.ordinal

    -- event --
    owner                FixedString(42),
    spender              FixedString(42),
    value                UInt256,

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)            TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)             TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)           TYPE set(64) GRANULARITY 4,
    INDEX idx_owner              (owner)              TYPE bloom_filter GRANULARITY 4,
    INDEX idx_spender            (spender)            TYPE bloom_filter GRANULARITY 4,
    INDEX idx_value              (value)              TYPE minmax GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);