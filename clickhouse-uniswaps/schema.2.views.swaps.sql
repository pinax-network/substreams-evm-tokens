-- Swaps for Uniswap V2 & V3 --
CREATE TABLE IF NOT EXISTS swaps (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   tx_hash              FixedString(66),
   tx_from              FixedString(42),
   tx_to                FixedString(42),

   -- log --
   ordinal              UInt64, -- log.ordinal

   -- call --
   caller               FixedString(42) COMMENT 'caller address', -- call.caller

   -- swaps --
   pool                 String COMMENT 'pool address', -- log.address
   sender               FixedString(42) COMMENT 'sender address',
   recipient            Nullable(FixedString(42)) COMMENT 'recipient address', -- not available in Uniswap V4
   amount0              Int256 COMMENT 'token0 amount',
   amount1              Int256 COMMENT 'token1 amount',
   price                Float64 COMMENT 'computed price for token0',
   protocol             LowCardinality(String) COMMENT 'protocol name', -- 'uniswap_v2','uniswap_v3' & 'uniswap_v4'

   INDEX idx_tx_hash       (tx_hash)         TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller        (caller)          TYPE bloom_filter GRANULARITY 4,
   INDEX idx_pool          (pool)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_sender        (sender)          TYPE bloom_filter GRANULARITY 4,
   INDEX idx_recipient     (recipient)       TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0       (amount0)         TYPE minmax GRANULARITY 4,
   INDEX idx_amount1       (amount1)         TYPE minmax GRANULARITY 4,
   INDEX idx_price         (price)           TYPE minmax GRANULARITY 4,
   INDEX idx_protocol      (protocol)        TYPE set(8) GRANULARITY 4
)
ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Swap --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v2_swap
TO swaps AS
SELECT
   -- block --
   block_num,
   block_hash,
   timestamp,

   -- ordering --
   `index`,
   global_sequence,

   -- transaction --
   tx_hash,
   tx_from,
   tx_to,

   -- call --
   caller,

   -- log --
   address as pool,
   ordinal,

   -- event --
   sender,
   `to` AS recipient,
   amount0_in - amount0_out AS amount0,
   amount1_in - amount1_out AS amount1,
   abs((amount1_in - amount1_out) / (amount0_in - amount0_out)) AS price,
   'uniswap_v2' AS protocol
FROM uniswap_v2_swap;

-- Uniswap::V3::Pool:Swap --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v3_swap
TO swaps AS
WITH
   pow(2, 96) as Q96
SELECT
   -- block --
   block_num,
   block_hash,
   timestamp,

   -- ordering --
   `index`,
   global_sequence,

   -- transaction --
   tx_hash,
   tx_from,
   tx_to,

   -- call --
   caller,

   -- log --
   address as pool,
   ordinal,

   -- event --
   sender,
   recipient,
   amount0,
   amount1,
   pow((toFloat64(sqrt_price_x96) / Q96), 2) AS price, -- https://github.com/pinax-network/substreams-evm-tokens/issues/68
   'uniswap_v3' AS protocol
FROM uniswap_v3_swap;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v4_swap
TO swaps AS
WITH
   pow(2, 96) as Q96
SELECT
   -- block --
   block_num,
   block_hash,
   timestamp,

   -- ordering --
   `index`,
   global_sequence,

   -- transaction --
   tx_hash,
   tx_from,
   tx_to,

   -- call --
   caller,

   -- log --
   ordinal,

   -- event --
   id as pool,
   sender,
   -- recipient not available in V4
   amount0,
   amount1,
   pow((toFloat64(sqrt_price_x96) / Q96), 2) AS price, -- https://github.com/pinax-network/substreams-evm-tokens/issues/68
   'uniswap_v4' AS protocol
FROM uniswap_v4_swap;