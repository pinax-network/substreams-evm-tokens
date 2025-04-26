-- Pools Created for Uniswap V2 & V3 --
CREATE TABLE IF NOT EXISTS pools (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   transaction_id       FixedString(66),

   -- swaps --
   factory              FixedString(42) COMMENT 'factory address', -- log.address
   pool                 FixedString(42) COMMENT 'pool address',
   token0               FixedString(42) COMMENT 'token0 address',
   token1               FixedString(42) COMMENT 'token1 address',
   fee                  UInt32 COMMENT 'pool fee (e.g., 3000 represents 0.30%)',
   protocol             LowCardinality(String) COMMENT 'protocol name', -- 'uniswap_v2' or 'uniswap_v3'

   -- indexes --
   INDEX idx_transaction_id       (transaction_id)    TYPE bloom_filter GRANULARITY 4,
   INDEX idx_factory              (factory)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token0               (token0)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token1               (token1)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_fee                  (fee)               TYPE minmax GRANULARITY 4,
   INDEX idx_protocol             (protocol)          TYPE set(8) GRANULARITY 4,
)
ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (pool, factory);

-- Uniswap::V2::Factory:PairCreated --
CREATE MATERIALIZED VIEW IF NOT EXISTS uniswap_v2_pairs_created_mv
TO pools AS
SELECT
   block_num,
   block_hash,
   timestamp,
   global_sequence,
   transaction_id,
   address AS factory,
   pair AS pool,
   token0,
   token1,
   3000 AS fee, -- default Uniswap V2 fee
   'uniswap_v2' AS protocol
FROM uniswap_v2_pairs_created;

-- Uniswap::V3::Factory:PoolCreated --
CREATE MATERIALIZED VIEW IF NOT EXISTS uniswap_v3_pools_created_mv
TO pools AS
SELECT
   block_num,
   block_hash,
   timestamp,
   global_sequence,
   transaction_id,
   address AS factory,
   pool,
   token0,
   token1,
   fee,
   'uniswap_v3' AS protocol
FROM uniswap_v3_pools_created;