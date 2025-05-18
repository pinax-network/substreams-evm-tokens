-- Uniswap::V3::Pool:Swap --
CREATE TABLE IF NOT EXISTS uniswap_v3_swap (
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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
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
   INDEX idx_address           (address)           TYPE set(64) GRANULARITY 4,

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
CREATE TABLE IF NOT EXISTS uniswap_v3_initialize (
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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   sqrt_price_x96       UInt256 COMMENT 'UniswapV3Pool sqrt price x96',
   tick                 Int32 COMMENT 'UniswapV3Pool tick',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sqrt_price_x96    (sqrt_price_x96)    TYPE minmax          GRANULARITY 4,
   INDEX idx_tick              (tick)              TYPE minmax          GRANULARITY 4
)
ENGINE = ReplacingMergeTree(global_sequence_reverse) -- first event only --
ORDER BY (address);

-- Uniswap::V3::Factory:PoolCreated --
CREATE TABLE IF NOT EXISTS uniswap_v3_pool_created (
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
   INDEX idx_fee               (fee)               TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (address, pool);

-- Uniswap::V3::Pool:Mint --
CREATE TABLE IF NOT EXISTS uniswap_v3_mint (
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
CREATE TABLE IF NOT EXISTS uniswap_v3_collect (
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
CREATE TABLE IF NOT EXISTS uniswap_v3_burn (
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
CREATE TABLE IF NOT EXISTS uniswap_v3_flash (
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
CREATE TABLE IF NOT EXISTS uniswap_v3_increase_observation_cardinality_next (
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
   observation_cardinality_next_old  UInt16 COMMENT 'The previous value of the next observation cardinality',
   observation_cardinality_next_new  UInt16 COMMENT 'The updated value of the next observation cardinality',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_observation_cardinality_next_old  (observation_cardinality_next_old)  TYPE minmax       GRANULARITY 4,
   INDEX idx_observation_cardinality_next_new  (observation_cardinality_next_new)  TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:SetFeeProtocol --
CREATE TABLE IF NOT EXISTS uniswap_v3_set_fee_protocol (
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
   fee_protocol0_old     UInt8 COMMENT 'The previous fee protocol for token0',
   fee_protocol1_old     UInt8 COMMENT 'The previous fee protocol for token1',
   fee_protocol0_new     UInt8 COMMENT 'The updated fee protocol for token0',
   fee_protocol1_new     UInt8 COMMENT 'The updated fee protocol for token1',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_fee_protocol0_old  (fee_protocol0_old) TYPE minmax       GRANULARITY 4,
   INDEX idx_fee_protocol1_old  (fee_protocol1_old) TYPE minmax       GRANULARITY 4,
   INDEX idx_fee_protocol0_new  (fee_protocol0_new) TYPE minmax       GRANULARITY 4,
   INDEX idx_fee_protocol1_new  (fee_protocol1_new) TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:CollectProtocol --
CREATE TABLE IF NOT EXISTS uniswap_v3_collect_protocol (
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
   sender               FixedString(42) COMMENT 'The address that initiated the collect protocol',
   recipient            FixedString(42) COMMENT 'The address that received the collected protocol fees',
   amount0              UInt128 COMMENT 'The amount of token0 collected from the protocol fees',
   amount1              UInt128 COMMENT 'The amount of token1 collected from the protocol fees',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   old_owner            FixedString(42) COMMENT 'The owner before the owner was changed',
   new_owner            FixedString(42) COMMENT 'The owner after the owner was changed',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

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
   caller               FixedString(42), -- call.caller

   -- log --
   address              FixedString(42), -- log.address
   ordinal              UInt64, -- log.ordinal

   -- event --
   fee                  UInt32 COMMENT 'The fee amount that was enabled for pool creation',
   tick_spacing         Int32 COMMENT 'The tick spacing that was enabled for pool creation',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_fee               (fee)               TYPE minmax       GRANULARITY 4,
   INDEX idx_tick_spacing      (tick_spacing)      TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);
