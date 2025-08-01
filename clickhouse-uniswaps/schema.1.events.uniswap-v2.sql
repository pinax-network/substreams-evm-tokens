
-- Uniswap::V2::Pair:Swap --
CREATE TABLE IF NOT EXISTS uniswap_v2_swap (
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

   -- call --
   caller               FixedString(42) COMMENT 'caller address', -- call.caller

   -- log --
   address              FixedString(42) COMMENT 'UniswapV2Pair pair address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sender               FixedString(42) COMMENT 'UniswapV2Pair sender address',
   amount0_in           UInt256 COMMENT 'UniswapV2Pair token0 amount in',
   amount0_out          UInt256 COMMENT 'UniswapV2Pair token0 amount out',
   amount1_in           UInt256 COMMENT 'UniswapV2Pair token1 amount in',
   amount1_out          UInt256 COMMENT 'UniswapV2Pair token1 amount out',
   `to`                 FixedString(42) COMMENT 'UniswapV2Pair recipient address',

   -- indexes --
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 1
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Factory:PairCreated --
CREATE TABLE IF NOT EXISTS uniswap_v2_pair_created (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)
   global_sequence_reverse  UInt64 MATERIALIZED toUInt64(-1) - global_sequence,

   -- transaction --
   tx_hash              FixedString(66),

   -- call --
   caller               FixedString(42) COMMENT 'factory creator', -- call.caller

   -- log --
   address              FixedString(42) COMMENT 'UniswapV2Pair factory address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   token0               FixedString(42) COMMENT 'UniswapV2Pair token0 address',
   token1               FixedString(42) COMMENT 'UniswapV2Pair token1 address',
   pair                 FixedString(42) COMMENT 'UniswapV2Pair pair address',
   all_pairs_length     UInt64 COMMENT 'Total number of pairs created by factory',

   -- indexes --
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 1
)
ENGINE = ReplacingMergeTree(global_sequence_reverse) -- first event only --
ORDER BY (address, pair);

-- Uniswap::V2::Pair:Sync --
CREATE TABLE IF NOT EXISTS uniswap_v2_sync  (
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
   caller               FixedString(42) COMMENT 'caller address', -- call.caller

   -- log --
   address              FixedString(42) COMMENT 'UniswapV2Pair pair address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   reserve0             UInt256 COMMENT 'UniswapV2Pair token0 reserve',
   reserve1             UInt256 COMMENT 'UniswapV2Pair token1 reserve',

   -- indexes --
   INDEX idx_tx_hash            (tx_hash)             TYPE bloom_filter GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Mint --
CREATE TABLE IF NOT EXISTS uniswap_v2_mint (
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
   caller               FixedString(42) COMMENT 'caller address', -- call.caller

   -- log --
   address              FixedString(42) COMMENT 'pair address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sender               FixedString(42) COMMENT 'sender address',
   amount0              UInt256,
   amount1              UInt256,

   -- indexes --
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Burn --
CREATE TABLE IF NOT EXISTS uniswap_v2_burn (
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
   caller               FixedString(42) COMMENT 'caller address', -- call.caller

   -- log --
   address              FixedString(42) COMMENT 'pair address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sender               FixedString(42) COMMENT 'sender address',
   amount0              UInt256,
   amount1              UInt256,
   `to`                 FixedString(42) COMMENT 'to address',

   -- indexes --
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);
