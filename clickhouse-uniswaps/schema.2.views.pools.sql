-- Pools Created for Uniswap V2 & V3 --
CREATE TABLE IF NOT EXISTS pools (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   tx_hash              FixedString(66),

   -- log --
   factory              FixedString(42) COMMENT 'factory address', -- log.address

   -- event --
   pool                 String COMMENT 'pool address',
   token0               FixedString(42) COMMENT 'token0 address',
   token1               FixedString(42) COMMENT 'token1 address',
   fee                  UInt32 COMMENT 'pool fee (e.g., 3000 represents 0.30%)',
   protocol             LowCardinality(String) COMMENT 'protocol name', -- 'uniswap_v2' or 'uniswap_v3'

   -- indexes --
   INDEX idx_tx_hash              (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_factory              (factory)           TYPE set(64) GRANULARITY 4,
   INDEX idx_token0               (token0)            TYPE set(64) GRANULARITY 4,
   INDEX idx_token1               (token1)            TYPE set(64) GRANULARITY 4,
   INDEX idx_fee                  (fee)               TYPE minmax GRANULARITY 4,
   INDEX idx_protocol             (protocol)          TYPE set(8) GRANULARITY 4,
)
ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (pool, factory);

-- Uniswap::V2::Factory:PairCreated --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v2_pair_created
TO pools AS
SELECT
   block_num,
   block_hash,
   timestamp,
   global_sequence,
   tx_hash,
   address AS factory,
   pair AS pool,
   token0,
   token1,
   3000 AS fee, -- default Uniswap V2 fee
   'uniswap_v2' AS protocol
FROM uniswap_v2_pair_created;

-- Uniswap::V3::Factory:PoolCreated --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v3_pool_created
TO pools AS
SELECT
   block_num,
   block_hash,
   timestamp,
   global_sequence,
   tx_hash,
   address AS factory,
   pool,
   token0,
   token1,
   fee,
   'uniswap_v3' AS protocol
FROM uniswap_v3_pool_created;

-- Uniswap::V4::IPoolManager:Initialize --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v4_initialize
TO pools AS
SELECT
   -- block --
   block_num,
   block_hash,
   timestamp,

   -- ordering --
   global_sequence,

   -- transaction --
   tx_hash,

   -- log --
   address AS factory,

   -- event --
   id as pool,
   currency0 as token0,
   currency1 as token1,
   fee,
   'uniswap_v4' AS protocol
FROM uniswap_v4_initialize;