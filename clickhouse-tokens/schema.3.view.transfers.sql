-- latest transfers --
CREATE TABLE IF NOT EXISTS transfers (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    `index`             UInt64,
    global_sequence     UInt64,

    -- transaction --
    tx_hash		        FixedString(66),

    -- log --
    contract			FixedString(42),

    -- event --
    `from`				FixedString(42),
    `to`				FixedString(42),
    amount              UInt256,
    value               Float64,

    -- ERC20 metadata --
    decimals            UInt8,
    symbol              Nullable(String),
    name                Nullable(String),

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)              TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)             TYPE set(64) GRANULARITY 4,
    INDEX idx_from               (`from`)               TYPE bloom_filter GRANULARITY 4,
    INDEX idx_to                 (`to`)                 TYPE bloom_filter GRANULARITY 4,
    INDEX idx_value              (value)                TYPE minmax GRANULARITY 4,
    INDEX idx_amount             (amount)               TYPE minmax GRANULARITY 4,

    -- indexes (ERC20 metadata) --
    INDEX idx_decimals           (decimals)             TYPE set(18) GRANULARITY 4,
    INDEX idx_symbol             (symbol)               TYPE set(64) GRANULARITY 4,
    INDEX idx_name               (name)                 TYPE set(64) GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- insert ERC20 transfers --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_transfers
TO transfers AS
SELECT
    -- block --
    timestamp,
    block_hash,
    block_num,

    -- ordering --
    `index`,
    global_sequence,

    -- transaction --
    tx_hash,

    -- log --
    contract,

    -- event --
    `from`,
    `to`,
    value AS amount,
    value / pow(10, decimals) AS value,

    -- ERC20 metadata --
    decimals,
    symbol,
    name
FROM erc20_transfers AS t
JOIN erc20_metadata AS c ON c.address = t.contract;

-- insert Native transfers --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfers
TO transfers AS
WITH (
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
    18 AS decimals,
    'Native' AS symbol,
    'Native' AS name
)
SELECT
    -- block --
    timestamp,
    block_hash,
    block_num,

    -- ordering --
    `index`,
    global_sequence,

    -- transaction --
    tx_hash,

    -- log --
    contract,

    -- event --
    `from`,
    `to`,
    value AS amount,
    value / pow(10, decimals) AS value,

    -- ERC20 metadata --
    decimals,
    symbol,
    name
FROM native_transfers;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfers_from_block_rewards
TO transfers AS
WITH (
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
    18 AS decimals,
    'Native' AS symbol,
    'Native' AS name
)
SELECT
    -- block --
    timestamp,
    block_hash,
    block_num,

    -- ordering --
    `index`,
    global_sequence,

    -- transaction --
    tx_hash,

    -- log --
    contract,

    -- event --
    `from`,
    `to`,
    value AS amount,
    value / pow(10, decimals) AS value,

    -- ERC20 metadata --
    decimals,
    symbol,
    name
FROM native_transfers_from_block_rewards;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfers_from_calls
TO transfers AS
WITH (
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
    18 AS decimals,
    'Native' AS symbol,
    'Native' AS name
)
SELECT
    -- block --
    timestamp,
    block_hash,
    block_num,

    -- ordering --
    `index`,
    global_sequence,

    -- transaction --
    tx_hash,

    -- log --
    contract,

    -- event --
    `from`,
    `to`,
    value AS amount,
    value / pow(10, decimals) AS value,

    -- ERC20 metadata --
    decimals,
    symbol,
    name
FROM native_transfers_from_calls;
