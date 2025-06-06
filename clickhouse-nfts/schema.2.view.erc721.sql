CREATE TABLE IF NOT EXISTS erc721_owners (
    -- block --
    block_num            UInt32,
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- owners --
    contract             FixedString(42) COMMENT 'contract address',
    token_id             UInt256,
    owner                FixedString(42),

    -- indexes --
    INDEX idx_owner      (owner)    TYPE bloom_filter GRANULARITY 4
) ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (contract, token_id);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc721_owners
TO erc721_owners
AS
SELECT
    -- block --
    block_num,
    timestamp,

    -- ordering --
    global_sequence,

    -- owners --
    contract,
    token_id,
    to AS owner          -- current owner after this transfer
FROM erc721_transfers;
