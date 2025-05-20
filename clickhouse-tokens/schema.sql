-- This file is generated. Do not edit.

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


-- ERC-20 Metadata Initialize --
CREATE TABLE IF NOT EXISTS erc20_metadata_initialize (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- event --
    address              FixedString(42),
    decimals             UInt8,
    name                 Nullable(String),
    symbol               Nullable(String)
)
ENGINE = ReplacingMergeTree
ORDER BY (address);

-- ERC-20 Metadata Changes --
CREATE TABLE IF NOT EXISTS erc20_metadata_changes (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- event --
    address              FixedString(42),
    name                 Nullable(String),
    symbol               Nullable(String)
)
ENGINE = ReplacingMergeTree
ORDER BY (address, block_num);


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
   `from`               FixedString(42) COMMENT 'sender address', -- log.topics[1]
   `to`                 FixedString(42) COMMENT 'recipient address', -- log.topics[2]
   value                UInt256 COMMENT 'transfer value', -- log.data

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

-- latest ERC-20 Metadata --
CREATE TABLE IF NOT EXISTS erc20_metadata  (
   -- block --
   block_num            SimpleAggregateFunction(max, UInt32) COMMENT 'block number',
   timestamp            SimpleAggregateFunction(max, DateTime(0, 'UTC')),

   -- contract --
   address              FixedString(42) COMMENT 'ERC-20 contract address',
   decimals             SimpleAggregateFunction(anyLast, UInt8) COMMENT 'ERC-20 contract decimals (typically 18)',
   name                 SimpleAggregateFunction(anyLast, Nullable(String)) COMMENT 'ERC-20 contract name (typically 3-8 characters)',
   symbol               SimpleAggregateFunction(anyLast, Nullable(String)) COMMENT 'ERC-20 contract symbol (typically 3-4 characters)'
)
ENGINE = AggregatingMergeTree
ORDER BY address;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_metadata_initialize
TO erc20_metadata AS
SELECT
    -- block --
    block_num,
    timestamp,

    -- event--
    address,
    decimals,

    -- replace empty strings with NULLs --
    IF (name = '', Null, name) AS name,
    IF (symbol = '', Null, symbol) AS symbol
FROM erc20_metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_metadata_changes
TO erc20_metadata AS
SELECT
    -- block --
    c.block_num as block_num,
    c.timestamp as timestamp,

    -- event--
    c.address AS address,

    -- replace empty strings with NULLs --
    IF (c.name = '', Null, c.name) AS name,
    IF (c.symbol = '', Null, c.symbol) AS symbol
FROM erc20_metadata_changes AS c
JOIN erc20_metadata_initialize USING (address); -- address must already be initialized

-- one time INSERT to populate Native contract --
INSERT INTO erc20_metadata (
    -- block --
    block_num,
    timestamp,
    -- event --
    address,
    name,
    symbol,
    decimals
)
VALUES (
    0,
    toDateTime(0, 'UTC'),
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
    'Native',
    'Native',
    18
);

CREATE TABLE IF NOT EXISTS cursors
(
    id        String,
    cursor    String,
    block_num Int64,
    block_id  String
)
    ENGINE = ReplacingMergeTree()
        PRIMARY KEY (id)
        ORDER BY (id);

