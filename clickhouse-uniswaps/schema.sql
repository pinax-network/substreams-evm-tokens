-- This file is generated. Do not edit.

-- Minimal ERC-20 contracts --
CREATE TABLE IF NOT EXISTS erc20_contracts (
   address        FixedString(42),
   decimals       UInt8
)
ENGINE = ReplacingMergeTree
ORDER BY (address);

-- Uniswap::V2::Factory:PairCreated --
CREATE TABLE IF NOT EXISTS uniswap_v2_pairs_created (
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
   INDEX idx_block_num        (block_num)          TYPE minmax GRANULARITY 4,
   INDEX idx_timestamp        (timestamp)          TYPE minmax GRANULARITY 4,
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token0           (token0)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token1           (token1)             TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (address, pair);

-- Uniswap::V2::Pair:Sync --
CREATE TABLE IF NOT EXISTS uniswap_v2_syncs  (
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
   INDEX idx_tx_hash            (tx_hash)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller             (caller)              TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address            (address)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_reserve0_minmax    (reserve0)            TYPE minmax       GRANULARITY 4,
   INDEX idx_reserve1_minmax    (reserve1)            TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Swap --
CREATE TABLE IF NOT EXISTS uniswap_v2_swaps (
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
   sender               FixedString(42) COMMENT 'UniswapV2Pair sender address',
   amount0_in           UInt256 COMMENT 'UniswapV2Pair token0 amount in',
   amount0_out          UInt256 COMMENT 'UniswapV2Pair token0 amount out',
   amount1_in           UInt256 COMMENT 'UniswapV2Pair token1 amount in',
   amount1_out          UInt256 COMMENT 'UniswapV2Pair token1 amount out',
   `to`                 FixedString(42) COMMENT 'UniswapV2Pair recipient address',

   -- indexes --
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller           (caller)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address          (address)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_sender           (sender)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_to               (`to`)               TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0_in       (amount0_in)         TYPE minmax       GRANULARITY 4,
   INDEX idx_amount0_out      (amount0_out)        TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1_in       (amount1_in)         TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1_out      (amount1_out)        TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Mint --
CREATE TABLE IF NOT EXISTS uniswap_v2_mints (
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
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller           (caller)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address          (address)            TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sender           (sender)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0          (amount0)            TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1          (amount1)            TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Mint --
CREATE TABLE IF NOT EXISTS uniswap_v2_mints (
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
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller           (caller)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address          (address)            TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sender           (sender)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0          (amount0)            TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1          (amount1)            TYPE minmax       GRANULARITY 4,
   INDEX idx_to               (`to`)               TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);


-- Uniswap::V3::Pool:Swap --
CREATE TABLE IF NOT EXISTS uniswap_v3_swaps (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sender               FixedString(42) COMMENT 'UniswapV3Pool sender address',
   recipient            FixedString(42) COMMENT 'UniswapV3Pool recipient address',
   amount0              Int256 COMMENT 'UniswapV3Pool token0 amount',
   amount1              Int256 COMMENT 'UniswapV3Pool token1 amount',
   sqrt_price_x96       UInt256 COMMENT 'UniswapV3Pool sqrt price x96',
   tick                 Int32 COMMENT 'UniswapV3Pool tick',
   liquidity            UInt128 COMMENT 'UniswapV3Pool liquidity',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sender            (sender)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_recipient         (recipient)         TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4,
   INDEX idx_sqrt_price_x96    (sqrt_price_x96)    TYPE minmax       GRANULARITY 4,
   INDEX idx_tick              (tick)              TYPE minmax       GRANULARITY 4,
   INDEX idx_liquidity         (liquidity)         TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:Initialize --
CREATE TABLE IF NOT EXISTS uniswap_v3_initializes (
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
   caller               FixedString(42) COMMENT 'caller address', -- call.caller

   -- log --
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sqrt_price_x96       UInt256 COMMENT 'UniswapV3Pool sqrt price x96',
   tick                 Int32 COMMENT 'UniswapV3Pool tick',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sqrt_price_x96    (sqrt_price_x96)    TYPE minmax          GRANULARITY 4,
   INDEX idx_tick              (tick)              TYPE minmax          GRANULARITY 4,
)
ENGINE = ReplacingMergeTree(global_sequence_reverse) -- first event only --
ORDER BY (address);

-- Uniswap::V3::Factory:PoolCreated --
CREATE TABLE IF NOT EXISTS uniswap_v3_pools_created (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool factory address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   token0               FixedString(42) COMMENT 'UniswapV3Pool token0 address',
   token1               FixedString(42) COMMENT 'UniswapV3Pool token1 address',
   pool                 FixedString(42) COMMENT 'UniswapV3Pool pool address',
   tick_spacing         Int32 COMMENT 'UniswapV3Pool tick spacing (e.g., 60)',
   fee                  UInt32 COMMENT 'UniswapV3Pool fee (e.g., 3000 represents 0.30%)',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_token0            (token0)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token1            (token1)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_tick_spacing      (tick_spacing)      TYPE minmax       GRANULARITY 4,
   INDEX idx_fee               (fee)               TYPE minmax       GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
ORDER BY (address, pool);

-- Uniswap::V3::Pool:Mint --
CREATE TABLE IF NOT EXISTS uniswap_v3_mints (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sender               FixedString(42) COMMENT 'The address that minted the liquidity',
   owner                FixedString(42) COMMENT 'The owner of the position and recipient of any minted liquidity',
   tick_lower           Int32 COMMENT 'The lower tick of the position',
   tick_upper           Int32 COMMENT 'The upper tick of the position',
   amount               UInt128 COMMENT 'The amount of liquidity minted to the position range',
   amount0              UInt256 COMMENT 'How much token0 was required for the minted liquidity',
   amount1              UInt256 COMMENT 'How much token1 was required for the minted liquidity',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sender            (sender)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_owner             (owner)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_tick_lower        (tick_lower)        TYPE minmax       GRANULARITY 4,
   INDEX idx_tick_upper        (tick_upper)        TYPE minmax       GRANULARITY 4,
   INDEX idx_amount            (amount)            TYPE minmax       GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:Collect --
CREATE TABLE IF NOT EXISTS uniswap_v3_collects (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   owner                FixedString(42) COMMENT 'The owner of the position for which fees are collected',
   recipient            FixedString(42) COMMENT 'The recipient of the collected fees',
   tick_lower           Int32 COMMENT 'The lower tick of the position',
   tick_upper           Int32 COMMENT 'The upper tick of the position',
   amount0              UInt128 COMMENT 'The amount of token0 collected from the position',
   amount1              UInt128 COMMENT 'The amount of token1 collected from the position',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_owner             (owner)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_recipient         (recipient)         TYPE bloom_filter GRANULARITY 4,
   INDEX idx_tick_lower        (tick_lower)        TYPE minmax       GRANULARITY 4,
   INDEX idx_tick_upper        (tick_upper)        TYPE minmax       GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:Burn --
CREATE TABLE IF NOT EXISTS uniswap_v3_burns (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   owner                FixedString(42) COMMENT 'The owner of the position',
   tick_lower           Int32 COMMENT 'The lower tick of the position',
   tick_upper           Int32 COMMENT 'The upper tick of the position',
   amount               UInt128 COMMENT 'The amount of liquidity burned from the position',
   amount0              UInt256 COMMENT 'How much token0 was removed from the position',
   amount1              UInt256 COMMENT 'How much token1 was removed from the position',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_owner             (owner)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_tick_lower        (tick_lower)        TYPE minmax       GRANULARITY 4,
   INDEX idx_tick_upper        (tick_upper)        TYPE minmax       GRANULARITY 4,
   INDEX idx_amount            (amount)            TYPE minmax       GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:Flash --
CREATE TABLE IF NOT EXISTS uniswap_v3_flashes (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal
   -- event --
   sender               FixedString(42) COMMENT 'The address that initiated the flash',
   recipient            FixedString(42) COMMENT 'The address that received the flash',
   amount0              UInt256 COMMENT 'The amount of token0 received in the flash',
   amount1              UInt256 COMMENT 'The amount of token1 received in the flash',
   paid0                UInt256 COMMENT 'The amount of token0 paid back to the pool',
   paid1                UInt256 COMMENT 'The amount of token1 paid back to the pool',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sender            (sender)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_recipient         (recipient)         TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4,
   INDEX idx_paid0             (paid0)             TYPE minmax       GRANULARITY 4,
   INDEX idx_paid1             (paid1)             TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:IncreaseObservationCardinalityNext --
CREATE TABLE IF NOT EXISTS uniswap_v3_increase_observation_cardinality_nexts (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   observation_cardinality_next_old  UInt16 COMMENT 'The previous value of the next observation cardinality',
   observation_cardinality_next_new  UInt16 COMMENT 'The updated value of the next observation cardinality',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_observation_cardinality_next_old  (observation_cardinality_next_old)  TYPE minmax       GRANULARITY 4,
   INDEX idx_observation_cardinality_next_new  (observation_cardinality_next_new)  TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:SetFeeProtocol --
CREATE TABLE IF NOT EXISTS uniswap_v3_set_fee_protocols (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   fee_protocol0_old     UInt8 COMMENT 'The previous fee protocol for token0',
   fee_protocol1_old     UInt8 COMMENT 'The previous fee protocol for token1',
   fee_protocol0_new     UInt8 COMMENT 'The updated fee protocol for token0',
   fee_protocol1_new     UInt8 COMMENT 'The updated fee protocol for token1'

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_fee_protocol0_old  (fee_protocol0_old) TYPE minmax       GRANULARITY 4,
   INDEX idx_fee_protocol1_old  (fee_protocol1_old) TYPE minmax       GRANULARITY 4,
   INDEX idx_fee_protocol0_new  (fee_protocol0_new) TYPE minmax       GRANULARITY 4,
   INDEX idx_fee_protocol1_new  (fee_protocol1_new) TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:CollectProtocol --
CREATE TABLE IF NOT EXISTS uniswap_v3_collect_protocols (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sender               FixedString(42) COMMENT 'The address that initiated the collect protocol',
   recipient            FixedString(42) COMMENT 'The address that received the collected protocol fees',
   amount0              UInt128 COMMENT 'The amount of token0 collected from the protocol fees',
   amount1              UInt128 COMMENT 'The amount of token1 collected from the protocol fees',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,
   -- indexes (event) --
   INDEX idx_sender            (sender)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_recipient         (recipient)         TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Factory:OwnerChanged --
-- Emitted when the owner of the factory is changed --
CREATE TABLE IF NOT EXISTS uniswap_v3_owner_changed (
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
   address              FixedString(42) COMMENT 'UniswapV3Factory factory address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   old_owner            FixedString(42) COMMENT 'The owner before the owner was changed',
   new_owner            FixedString(42) COMMENT 'The owner after the owner was changed',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_old_owner         (old_owner)         TYPE bloom_filter GRANULARITY 4,
   INDEX idx_new_owner         (new_owner)         TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Factory:FeeAmountEnabled --
-- Emitted when a new fee amount is enabled for pool creation via the factory --
CREATE TABLE IF NOT EXISTS uniswap_v3_fee_amount_enabled (
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
   address              FixedString(42) COMMENT 'UniswapV3Factory factory address', -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   fee                  UInt32 COMMENT 'The fee amount that was enabled for pool creation',
   tick_spacing         Int32 COMMENT 'The tick spacing that was enabled for pool creation',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_ordinal           (ordinal)           TYPE minmax       GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_fee               (fee)               TYPE minmax       GRANULARITY 4,
   INDEX idx_tick_spacing      (tick_spacing)      TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);


-- Uniswap::V4::IPoolManager:Swap --
-- Emitted for swaps between currency0 and currency1 --
CREATE TABLE IF NOT EXISTS uniswap_v4_swap (
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
   caller               FixedString(42), -- call.caller

   -- log --
   ordinal              UInt64, -- log.ordinal
   address              FixedString(42), -- log.address

   -- events --
   id                   FixedString(42) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   sender               FixedString(42) COMMENT 'The address that initiated the swap call, and that received the callback',
   amount0              Int256 COMMENT 'The delta of the currency0 balance of the pool',
   amount1              Int256 COMMENT 'The delta of the currency1 balance of the pool',
   sqrt_price_x96       UInt256 COMMENT 'The sqrt(price) of the pool after the swap, as a Q64.96',
   liquidity            UInt128 COMMENT 'The liquidity of the pool after the swap',
   tick                 Int32 COMMENT 'The log base 1.0001 of the price of the pool after the swap',
   fee                  Int256 COMMENT 'The swap fee in hundredths of a bip',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_id                (id)                TYPE bloom_filter GRANULARITY 4,
   INDEX idx_sender            (sender)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4,
   INDEX idx_sqrt_price_x96    (sqrt_price_x96)    TYPE minmax       GRANULARITY 4,
   INDEX idx_tick              (tick)              TYPE minmax       GRANULARITY 4,
   INDEX idx_liquidity         (liquidity)         TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::IPoolManager:Initialize --
CREATE TABLE IF NOT EXISTS uniswap_v4_initialize (
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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   id                   FixedString(42) COMMENT 'The abi encoded hash of the pool key struct for the new pool',
   currency0            FixedString(42) COMMENT 'The first currency of the pool by address sort order',
   currency1            FixedString(42) COMMENT 'The second currency of the pool by address sort order',
   fee                  UInt64 COMMENT 'The fee collected upon every swap in the pool, denominated in hundredths of a bip',
   tick_spacing         Int32 COMMENT 'The minimum number of ticks between initialized ticks',
   sqrt_price_x96       UInt256 COMMENT 'The price of the pool on initialization',
   tick                 Int32 COMMENT 'The initial tick of the pool corresponding to the initialized price',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter    GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_id                (id)                TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_currency0         (currency0)         TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_currency1         (currency1)         TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_fee               (fee)               TYPE minmax          GRANULARITY 4,
   INDEX idx_tick_spacing      (tick_spacing)      TYPE minmax          GRANULARITY 4,
   INDEX idx_sqrt_price_x96    (sqrt_price_x96)    TYPE minmax          GRANULARITY 4,
   INDEX idx_tick              (tick)              TYPE minmax          GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);


-- Uniswap::V3::IPoolManager:ModifyLiquidity --
-- Emitted when a liquidity position is modified --
CREATE TABLE IF NOT EXISTS uniswap_v4_modify_liquidity (
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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   id                   FixedString(42) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   sender               FixedString(42) COMMENT 'The address that modified the pool',
   tick_lower           Int32 COMMENT 'The lower tick of the position',
   tick_upper           Int32 COMMENT 'The upper tick of the position',
   liquidity_delta      Int128 COMMENT 'The amount of liquidity that was added or removed',
   salt                 FixedString(66) COMMENT 'The extra data to make positions unique'
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::IPoolManager:Donate --
-- Emitted for donations --
CREATE TABLE IF NOT EXISTS uniswap_v4_donate (
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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   id                   FixedString(42) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   sender               FixedString(42) COMMENT 'The address that modified the pool',
   amount0              UInt256 COMMENT 'The amount of currency0 that was donated',
   amount1              UInt256 COMMENT 'The amount of currency1 that was donated',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter    GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_id                (id)                TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_sender            (sender)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax          GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax          GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::IPoolManager:ProtocolFeeControllerUpdated --
-- Emitted when the protocol fee controller address is updated in setProtocolFeeController. --
CREATE TABLE IF NOT EXISTS uniswap_v4_protocol_fee_controller_update (
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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   protocol_fee_controller FixedString(42) COMMENT 'The address of the protocol fee controller',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter    GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_protocol_fee_controller (protocol_fee_controller) TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::IPoolManager:ProtocolFeeUpdated --
-- Emitted when the protocol fee is updated in setProtocolFee. --
CREATE TABLE IF NOT EXISTS uniswap_v4_protocol_fee_updated (
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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   id                   FixedString(42) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   protocol_fee         UInt32 COMMENT 'The protocol fee in hundredths of a bip',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter    GRANULARITY 4,
   -- indexes (event) --
   INDEX idx_id                (id)                TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_protocol_fee      (protocol_fee)      TYPE minmax          GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- latest balances by owner/contract --
CREATE TABLE IF NOT EXISTS balances AS erc20_balance_changes
ENGINE = ReplacingMergeTree(global_sequence)
PRIMARY KEY (address, contract)
ORDER BY (address, contract);

-- insert ERC20 balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS erc20_balances_mv
TO balances AS
SELECT * FROM erc20_balance_changes
WHERE algorithm != 'ALGORITHM_BALANCE_NOT_MATCH_TRANSFER'; -- not implemented yet

-- insert Native balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS native_balances_mv
TO balances AS
SELECT * FROM native_balance_changes;

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS balances_by_contract AS balances
ENGINE = ReplacingMergeTree(global_sequence)
PRIMARY KEY (contract, address)
ORDER BY (contract, address);

CREATE MATERIALIZED VIEW IF NOT EXISTS balances_by_contract_mv
TO balances_by_contract AS
SELECT * FROM balances;


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

   -- swaps --
   factory              FixedString(42) COMMENT 'factory address', -- log.address
   pool                 FixedString(42) COMMENT 'pool address',
   token0               FixedString(42) COMMENT 'token0 address',
   token1               FixedString(42) COMMENT 'token1 address',
   fee                  UInt32 COMMENT 'pool fee (e.g., 3000 represents 0.30%)',
   protocol             LowCardinality(String) COMMENT 'protocol name', -- 'uniswap_v2' or 'uniswap_v3'

   -- indexes --
   INDEX idx_tx_hash              (tx_hash)           TYPE bloom_filter GRANULARITY 4,
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
   tx_hash,
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
   tx_hash,
   address AS factory,
   pool,
   token0,
   token1,
   fee,
   'uniswap_v3' AS protocol
FROM uniswap_v3_pools_created;

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


-- OHLC prices including Uniswap V2 & V3 with faster quantile computation --
CREATE TABLE IF NOT EXISTS ohlc_prices (
   timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

   -- pool --
   pool                 LowCardinality(FixedString(42)) COMMENT 'pool address',

   -- swaps --
   open0                AggregateFunction(argMin, Float64, UInt64),
   quantile0            AggregateFunction(quantileDeterministic, Float64, UInt64),
   close0               AggregateFunction(argMax, Float64, UInt64),

   -- volume --
   gross_volume0        SimpleAggregateFunction(sum, UInt256) COMMENT 'gross volume of token0 in the window',
   gross_volume1        SimpleAggregateFunction(sum, UInt256) COMMENT 'gross volume of token1 in the window',
   net_flow0            SimpleAggregateFunction(sum, Int256) COMMENT 'net flow of token0 in the window',
   net_flow1            SimpleAggregateFunction(sum, Int256) COMMENT 'net flow of token1 in the window',

   -- universal --
   uaw                  AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses in the window',
   transactions         SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window'
)
ENGINE = AggregatingMergeTree
PRIMARY KEY (pool, timestamp)
ORDER BY (pool, timestamp);

-- Swaps --
CREATE MATERIALIZED VIEW IF NOT EXISTS ohlc_prices_mv
TO ohlc_prices
AS
SELECT
   toStartOfHour(timestamp) AS timestamp,

   -- pool --
   pool,

   -- swaps --
   argMinState(price, global_sequence) AS open0,
   quantileDeterministicState(price, global_sequence) AS quantile0,
   argMaxState(price, global_sequence) AS close0,

   -- volume --
   sum(toUInt256(abs(amount0))) AS gross_volume0,
   sum(toUInt256(abs(amount1))) AS gross_volume1,
   sum(toInt256(amount0))     AS net_flow0,
   sum(toInt256(amount1))     AS net_flow1,

   -- universal --
   uniqState(sender) AS uaw,
   sum(1) AS transactions
FROM swaps AS s
GROUP BY pool, timestamp;

-- OHLC prices by token contract --
CREATE TABLE IF NOT EXISTS ohlc_prices_by_contract (
   timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

   -- token --
   token                LowCardinality(FixedString(42)) COMMENT 'token address',

   -- pool --
   pool                 LowCardinality(FixedString(42)) COMMENT 'pool address',

   -- swaps --
   open                Float64,
   high                Float64,
   low                 Float64,
   close               Float64,

   -- volume --
   volume              UInt256,

   -- universal --
   uaw                  UInt64,
   transactions         UInt64
)
ENGINE = AggregatingMergeTree
PRIMARY KEY (token, pool, timestamp)
ORDER BY (token, pool, timestamp);

-- Swaps --
CREATE MATERIALIZED VIEW IF NOT EXISTS ohlc_prices_by_contract_mv
TO ohlc_prices_by_contract
AS
-- Get pools for token contract
WITH tokens AS (
    SELECT
        token,
        pool,
        p.token0 == t.token AS is_first_token
    FROM (
        SELECT DISTINCT token0 AS token FROM pools
        UNION DISTINCT
        SELECT DISTINCT token1 AS token FROM pools
    ) AS t
    JOIN pools AS p ON p.token0 = t.token OR p.token1 = t.token
),
-- Rank pools for token contract based on activity (UAW and transactions count)
ranked_pools AS (
   SELECT
        timestamp,
        token,
        pool,
        -- Handle both pair directions, normalize to token as first pair
        if(is_first_token, argMinMerge(o.open0), 1/argMinMerge(o.open0)) AS open,
        if(is_first_token, quantileDeterministicMerge(0.95)(o.quantile0), 1/quantileDeterministicMerge(0.05)(o.quantile0)) AS high,
        if(is_first_token, quantileDeterministicMerge(0.05)(o.quantile0), 1/quantileDeterministicMerge(0.95)(o.quantile0)) AS low,
        if(is_first_token, argMaxMerge(o.close0), 1/argMaxMerge(o.close0)) AS close,
        if(is_first_token, sum(o.gross_volume1), sum(o.gross_volume0)) AS volume,
        uniqMerge(o.uaw) AS uaw,
        sum(o.transactions) AS transactions,
        row_number() OVER (PARTITION BY token, timestamp ORDER BY uniqMerge(o.uaw) + sum(o.transactions) DESC) AS rank
    FROM ohlc_prices_mv AS o
    JOIN tokens ON o.pool = tokens.pool
    GROUP BY token, is_first_token, pool, timestamp
)
SELECT
    timestamp,
    token,
    pool,
    open,
    high,
    low,
    close,
    volume,
    uaw,
    transactions
FROM ranked_pools
WHERE rank <= 20 -- Only keep top 20 pools for each token
ORDER BY token, pool, rank DESC;


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

