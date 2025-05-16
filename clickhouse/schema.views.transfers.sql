-- latest transfers --
CREATE TABLE IF NOT EXISTS transfers (
    -- block --
    timestamp			DateTime(0, 'UTC'),
    block_num			UInt32,

    -- ordering --
    `index`             UInt64,
    global_sequence     UInt64,

    -- transaction --
    transaction_id		FixedString(66),

    -- log --
    contract			FixedString(42),

    -- event --
    `from`				FixedString(42),
    `to`				FixedString(42),
    decimals            String,
    symbol              String,
    amount              String,
    value               UInt256,

    -- indexes --
    INDEX idx_transaction_id     (transaction_id)     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)           TYPE bloom_filter GRANULARITY 4,
    INDEX idx_from               (`from`)             TYPE bloom_filter GRANULARITY 4,
    INDEX idx_to                 (`to`)               TYPE bloom_filter GRANULARITY 4,
    INDEX idx_value              (value)              TYPE minmax GRANULARITY 4
)
ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (timestamp, block_num, `from`, `to`, `index`);

-- insert ERC20 transfers --
CREATE MATERIALIZED VIEW IF NOT EXISTS erc20_transfers_mv
TO transfers AS
SELECT
    -- block --
    timestamp,
    block_num,

    -- ordering --
    `index`,
    global_sequence,

    -- transaction --
    transaction_id,

    -- log --
    contract,

    -- event --
    `from`,
    `to`,
    decimals,
    symbol,
    toString(t.value) as amount,
    value / pow(10, decimals) AS value
FROM erc20_transfers AS t
LEFT JOIN contracts AS c ON c.address = t.contract;

-- insert Native transfers --
CREATE MATERIALIZED VIEW IF NOT EXISTS native_transfers_mv
TO transfers AS
SELECT
    -- block --
    timestamp,
    block_num,

    -- ordering --
    `index`,
    global_sequence,

    -- transaction --
    transaction_id,

    -- log --
    contract,

    -- event --
    `from`,
    `to`,
    decimals,
    symbol,
    toString(t.value) as amount,
    value / pow(10, decimals) AS value
FROM native_transfers AS t
LEFT JOIN contracts AS c ON c.address = t.contract;