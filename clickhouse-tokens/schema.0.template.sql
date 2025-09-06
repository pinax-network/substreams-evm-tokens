CREATE TABLE IF NOT EXISTS TEMPLATE_RPC_CALLS (
    -- block --
    block_num            UInt32,
    block_hash           String,
    timestamp            DateTime(0, 'UTC'),

    -- rpc call --
    contract            String COMMENT 'contract being called',

    -- indexes --
    INDEX idx_block_num          (block_num)          TYPE minmax               GRANULARITY 1,
    INDEX idx_block_hash         (block_hash)         TYPE bloom_filter(0.005)  GRANULARITY 1,
    INDEX idx_timestamp          (timestamp)          TYPE minmax               GRANULARITY 1
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract)
COMMENT 'TEMPLATE for RPC calls';

CREATE TABLE IF NOT EXISTS TEMPLATE_LOGS (
    -- block --
    block_num            UInt32,
    block_hash           String,
    timestamp            DateTime(0, 'UTC'),

    -- transaction --
    tx_hash              String COMMENT 'transaction hash',

    -- call --
    contract             String COMMENT 'contract address',
    caller               String COMMENT 'address that initiated the call',

    -- log --
    log_index            UInt32 COMMENT 'log index',

    -- indexes --
    INDEX idx_block_num          (block_num)          TYPE minmax               GRANULARITY 1,
    INDEX idx_block_hash         (block_hash)         TYPE bloom_filter(0.005)  GRANULARITY 1,
    INDEX idx_timestamp          (timestamp)          TYPE minmax               GRANULARITY 1,
    INDEX idx_tx_hash            (tx_hash)            TYPE bloom_filter(0.005)  GRANULARITY 1,
    INDEX idx_caller             (caller)             TYPE bloom_filter(0.005)  GRANULARITY 1,
    INDEX idx_contract           (contract)           TYPE bloom_filter(0.005)  GRANULARITY 1,
    INDEX idx_log_index          (log_index)          TYPE minmax               GRANULARITY 1
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(timestamp)
ORDER BY (
    timestamp, block_num, block_hash, log_index
)
COMMENT 'TEMPLATE for event logs';
