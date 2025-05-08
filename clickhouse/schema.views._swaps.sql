-- Swaps for Uniswap V2 & V3 --
CREATE TABLE IF NOT EXISTS swaps (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   ordinal              UInt64, -- log.ordinal
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   tx_hash              FixedString(66),

   -- call --
   caller               FixedString(42) COMMENT 'caller address', -- call.caller

   -- swaps --
   pool                 FixedString(42) COMMENT 'pool address', -- log.address
   sender               FixedString(42) COMMENT 'sender address',
   recipient            FixedString(42) COMMENT 'recipient address',
   amount0              Int256 COMMENT 'token0 amount',
   amount1              Int256 COMMENT 'token1 amount',
   price                Float64 COMMENT 'computed price for token0',
   protocol             LowCardinality(String) COMMENT 'protocol name', -- 'uniswap_v2' or 'uniswap_v3'

   INDEX idx_tx_hash tx_hash TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller caller TYPE bloom_filter GRANULARITY 4,
   INDEX idx_pool pool TYPE bloom_filter GRANULARITY 4,
   INDEX idx_sender sender TYPE bloom_filter GRANULARITY 4,
   INDEX idx_recipient recipient TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0 amount0 TYPE minmax GRANULARITY 4,
   INDEX idx_amount1 amount1 TYPE minmax GRANULARITY 4,
   INDEX idx_price price TYPE minmax GRANULARITY 4,
   INDEX idx_protocol protocol TYPE set(8) GRANULARITY 4
)
ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Swap --
CREATE MATERIALIZED VIEW IF NOT EXISTS uniswap_v2_swaps_mv
TO swaps AS
SELECT
   block_num,
   block_hash,
   timestamp,
   ordinal,
   `index`,
   global_sequence,
   tx_hash,
   caller,
   address as pool,
   sender,
   `to` AS recipient,
   amount0_in - amount0_out AS amount0,
   amount1_in - amount1_out AS amount1,
   abs((amount1_in - amount1_out) / (amount0_in - amount0_out)) AS price,
   'uniswap_v2' AS protocol
FROM uniswap_v2_swaps;

-- Uniswap::V3::Pool:Swap --
CREATE MATERIALIZED VIEW IF NOT EXISTS uniswap_v3_swaps_mv
TO swaps AS
SELECT
   block_num,
   block_hash,
   timestamp,
   ordinal,
   `index`,
   global_sequence,
   tx_hash,
   caller,
   address as pool,
   sender,
   recipient,
   amount0,
   amount1,
   pow(1.0001, tick) AS price,
   'uniswap_v3' AS protocol
FROM uniswap_v3_swaps;
