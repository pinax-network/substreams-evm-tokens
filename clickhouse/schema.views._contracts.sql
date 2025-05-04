-- latest Token contracts --
CREATE TABLE IF NOT EXISTS contracts  (
   -- block --
   block_num            SimpleAggregateFunction(max, UInt32) COMMENT 'block number',
   timestamp            SimpleAggregateFunction(max, DateTime(0, 'UTC')),

   -- ordering --
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- contract --
   address              FixedString(42) COMMENT 'ERC-20 contract address',
   name                 SimpleAggregateFunction(anyLast, Nullable(String)) COMMENT 'ERC-20 contract name (typically 3-8 characters)',
   symbol               SimpleAggregateFunction(anyLast, Nullable(String)) COMMENT 'ERC-20 contract symbol (typically 3-4 characters)',
   decimals             SimpleAggregateFunction(anyLast, Nullable(UInt8)) COMMENT 'ERC-20 contract decimals (18 by default)'
)
ENGINE = AggregatingMergeTree
ORDER BY address;

CREATE MATERIALIZED VIEW IF NOT EXISTS contracts_mv
TO contracts AS
SELECT
   block_num,
   timestamp,
   global_sequence,
   address,
   -- replace empty strings with NULLs --
   IF (name = '', Null, name) AS name,
   IF (symbol = '', Null, symbol) AS symbol,
   IF (decimals = '', Null, CAST(decimals AS UInt8)) AS decimals
FROM contract_changes;

-- one time INSERT to populate Native contract --
INSERT INTO contracts (
   block_num,
   timestamp,
   global_sequence,
   address,
   name,
   symbol,
   decimals
)
VALUES (
   0,
   toDateTime(0, 'UTC'),
   0,
   '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
   'Native',
   'Native',
   18
);