-- Swaps for Uniswap V2, V3 & V4--
CREATE TABLE IF NOT EXISTS swaps (
   -- block --
   block_num               UInt32,
   block_hash              FixedString(66),
   timestamp               DateTime(0, 'UTC'),

   -- transaction --
   tx_hash                 FixedString(66),
   tx_from                 FixedString(42),
   tx_to                   FixedString(42),

   -- log --
   ordinal                 UInt64, -- log.ordinal
   -- TO-DO: add `log_index` (missing from Uniswap Substreams)

   -- call --
   caller                  FixedString(42), -- call.caller

   -- swaps --
   pool                    String, -- log.address or id (for Uniswap V4)
   sender                  FixedString(42),
   factory                 FixedString(42),

   -- input --
   input_amount            Int256,
   input_token             FixedString(42),
   input_decimals          UInt8,

   -- output --
   output_amount           Int256,
   output_token            FixedString(42),
   output_decimals         UInt8,

   -- computed price --
   price                   Float64 MATERIALIZED output_amount / input_amount,

   -- protocol --
   protocol                Enum( 'uniswap_v2' = 1, 'uniswap_v3' = 2, 'uniswap_v4' = 3 ),

   INDEX idx_tx_hash       (tx_hash)         TYPE bloom_filter GRANULARITY 1, -- unique tx_hash per granule
   INDEX idx_tx_from       (tx_from)         TYPE bloom_filter GRANULARITY 1, -- 5000 unique recipients per granule
   INDEX idx_tx_to         (tx_to)           TYPE set(256) GRANULARITY 1, -- 200 unique Swap Router to per granule
   INDEX idx_caller        (caller)          TYPE set(256) GRANULARITY 1, -- 200 unique callers per granule
   INDEX idx_sender        (sender)          TYPE set(256) GRANULARITY 1, -- 200 unique senders per granule
   INDEX idx_factory       (factory)         TYPE set(256) GRANULARITY 1,
   INDEX idx_input_token   (input_token)     TYPE set(256) GRANULARITY 1,
   INDEX idx_input_amount  (input_amount)    TYPE minmax GRANULARITY 1,
   INDEX idx_output_token  (output_token)    TYPE set(256) GRANULARITY 1,
   INDEX idx_output_amount (output_amount)   TYPE minmax GRANULARITY 1,

   -- TO-DO: ADD PROJECTION for timestamp/block_num --
   INDEX idx_timestamp    (timestamp)       TYPE minmax GRANULARITY 1,
   INDEX idx_block_num    (block_num)       TYPE minmax GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (
   protocol, pool, input_token, output_token, tx_to, sender, caller, tx_from,
   block_hash, ordinal
);

-- Uniswap::V2::Pair:Swap --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v2_swap
TO swaps AS
WITH
   (amount0_in - amount0_out) AS net0,
   (amount1_in - amount1_out) AS net1
SELECT
   -- block --
   s.block_num AS block_num,
   s.block_hash AS block_hash,
   s.timestamp AS timestamp,

   -- transaction --
   s.tx_hash AS tx_hash,
   s.tx_from AS tx_from,
   s.tx_to AS tx_to,

   -- call --
   caller,

   -- log --
   s.ordinal AS ordinal,

   -- event --
   s.address as pool,
   p.factory AS factory,
   sender,

   -- input --
   if (net0 > 0, net0, net1) AS input_amount,
   if (net0 > 0, p.token0, p.token1) AS input_token,
   if (net0 > 0, m0.decimals, m1.decimals) AS input_decimals,

   -- output --
   if (net0 < 0, -net0, -net1) AS output_amount,
   if (net0 < 0, p.token0, p.token1) AS output_token,
   if (net0 < 0, m0.decimals, m1.decimals) AS output_decimals,

   'uniswap_v2' AS protocol
FROM uniswap_v2_swap AS s
LEFT JOIN pools AS p ON s.address = p.pool
LEFT JOIN erc20_metadata_initialize AS m0 ON m0.address = p.token0
LEFT JOIN erc20_metadata_initialize AS m1 ON m1.address = p.token1
WHERE input_amount > 1 AND output_amount > 1;

-- Uniswap::V3::Pool:Swap --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v3_swap
TO swaps AS
SELECT
   -- block --
   s.block_num AS block_num,
   s.block_hash AS block_hash,
   s.timestamp AS timestamp,

   -- transaction --
   s.tx_hash AS tx_hash,
   s.tx_from AS tx_from,
   s.tx_to AS tx_to,

   -- call --
   caller,

   -- log --
   s.ordinal AS ordinal,

   -- event --
   s.address as pool,
   p.factory AS factory,
   sender,

   -- input --
   if (s.amount0 > 0, s.amount0, s.amount1) AS input_amount,
   if (s.amount0 > 0, p.token0, p.token1) AS input_token,
   if (s.amount0 > 0, m0.decimals, m1.decimals) AS input_decimals,

   -- output --
   if (s.amount0 < 0, -s.amount0, -s.amount1) AS output_amount,
   if (s.amount0 < 0, p.token0, p.token1) AS output_token,
   if (s.amount0 < 0, m0.decimals, m1.decimals) AS output_decimals,

   -- pow((toFloat64(sqrt_price_x96) / Q96), 2) AS price, -- https://github.com/pinax-network/substreams-evm-tokens/issues/68
   'uniswap_v3' AS protocol
FROM uniswap_v3_swap AS s
LEFT JOIN pools AS p ON s.address = p.pool
LEFT JOIN erc20_metadata_initialize AS m0 ON m0.address = p.token0
LEFT JOIN erc20_metadata_initialize AS m1 ON m1.address = p.token1
WHERE input_amount > 1 AND output_amount > 1;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_uniswap_v4_swap
TO swaps AS
SELECT
   -- block --
   s.block_num AS block_num,
   s.block_hash AS block_hash,
   s.timestamp AS timestamp,

   -- transaction --
   s.tx_hash AS tx_hash,
   s.tx_from AS tx_from,
   s.tx_to AS tx_to,

   -- call --
   caller,

   -- log --
   s.ordinal AS ordinal,

   -- event --
   id as pool,
   p.factory AS factory,
   sender,

   -- === NOTE ===
   -- Uniswap V4 inverses the input and output amounts compared to V2 and V3.
   -- This is because the swap is initiated by the recipient, not the sender.
   -- This means that the input amount is the amount the recipient is providing,
   -- and the output amount is the amount the recipient is receiving.
   --
   -- input --
   if (s.amount0 > 0, -s.amount1, -s.amount0) AS input_amount,
   if (s.amount0 > 0, p.token1, p.token0) AS input_token,
   if (s.amount0 > 0, m1.decimals, m0.decimals) AS input_decimals,

   -- output --
   if (s.amount0 < 0, s.amount1, s.amount0) AS output_amount,
   if (s.amount0 < 0, p.token1, p.token0) AS output_token,
   if (s.amount0 < 0, m1.decimals, m0.decimals) AS output_decimals,

   -- pow((toFloat64(sqrt_price_x96) / Q96), 2) AS price, -- https://github.com/pinax-network/substreams-evm-tokens/issues/68
   'uniswap_v4' AS protocol
FROM uniswap_v4_swap AS s
LEFT JOIN pools AS p ON s.id = p.pool
LEFT JOIN erc20_metadata_initialize AS m0 ON m0.address = p.token0
LEFT JOIN erc20_metadata_initialize AS m1 ON m1.address = p.token1;