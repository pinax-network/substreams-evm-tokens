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
    block_num,
    timestamp,

    -- event--
    address,

    -- replace empty strings with NULLs --
    IF (name = '', Null, name) AS name,
    IF (symbol = '', Null, symbol) AS symbol
FROM erc20_metadata_changes
WHERE address IN erc20_metadata_initialize.address; -- address must already be initialized

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