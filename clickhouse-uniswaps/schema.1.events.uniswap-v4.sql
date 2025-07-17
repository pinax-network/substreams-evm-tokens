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
   tx_from              FixedString(42),
   tx_to                FixedString(42),

   -- call --
   caller               FixedString(42), -- call.caller

   -- log --
   ordinal              UInt64, -- log.ordinal
   address              FixedString(42), -- log.address

   -- events --
   id                   FixedString(66) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   sender               FixedString(42) COMMENT 'The address that initiated the swap call, and that received the callback',
   amount0              Int256 COMMENT 'The delta of the currency0 balance of the pool',
   amount1              Int256 COMMENT 'The delta of the currency1 balance of the pool',
   sqrt_price_x96       UInt256 COMMENT 'The sqrt(price) of the pool after the swap, as a Q64.96',
   liquidity            UInt128 COMMENT 'The liquidity of the pool after the swap',
   tick                 Int32 COMMENT 'The log base 1.0001 of the price of the pool after the swap',
   fee                  Int256 COMMENT 'The swap fee in hundredths of a bip',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V4::IPoolManager:Initialize --
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
   id                   FixedString(66) COMMENT 'The abi encoded hash of the pool key struct for the new pool',
   currency0            FixedString(42) COMMENT 'The first currency of the pool by address sort order',
   currency1            FixedString(42) COMMENT 'The second currency of the pool by address sort order',
   fee                  UInt64 COMMENT 'The fee collected upon every swap in the pool, denominated in hundredths of a bip',
   tick_spacing         Int32 COMMENT 'The minimum number of ticks between initialized ticks',
   sqrt_price_x96       UInt256 COMMENT 'The price of the pool on initialization',
   tick                 Int32 COMMENT 'The initial tick of the pool corresponding to the initialized price',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);


-- Uniswap::V4::IPoolManager:ModifyLiquidity --
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
   id                   FixedString(66) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   sender               FixedString(42) COMMENT 'The address that modified the pool',
   tick_lower           Int32 COMMENT 'The lower tick of the position',
   tick_upper           Int32 COMMENT 'The upper tick of the position',
   liquidity_delta      Int128 COMMENT 'The amount of liquidity that was added or removed',
   salt                 FixedString(66) COMMENT 'The extra data to make positions unique',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V4::IPoolManager:Donate --
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
   id                   FixedString(66) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   sender               FixedString(42) COMMENT 'The address that modified the pool',
   amount0              UInt256 COMMENT 'The amount of currency0 that was donated',
   amount1              UInt256 COMMENT 'The amount of currency1 that was donated',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V4::IPoolManager:ProtocolFeeControllerUpdated --
-- Emitted when the protocol fee controller address is updated in setProtocolFeeController. --
CREATE TABLE IF NOT EXISTS uniswap_v4_protocol_fee_controller_updated (
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
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V4::IPoolManager:ProtocolFeeUpdated --
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
   id                   FixedString(66) COMMENT 'The abi encoded hash of the pool key struct for the pool that was modified',
   protocol_fee         UInt32 COMMENT 'The protocol fee in hundredths of a bip',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 1
)
ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);
