-- This file is generated. Do not edit.

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

-- ERC-20 balance changes --
CREATE TABLE IF NOT EXISTS erc20_balance_changes  (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   ordinal              UInt64, -- storage_change.ordinal or balance_change.ordinal
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   tx_hash       FixedString(66),

   -- call --
   caller               FixedString(42) COMMENT 'ERC-20 caller address', -- call.caller

   -- balance change --
   contract             FixedString(42) COMMENT 'ERC-20 contract address',
   address              FixedString(42) COMMENT 'ERC-20 wallet address',
   old_balance          UInt256 COMMENT 'ERC-20 old balance',
   new_balance          UInt256 COMMENT 'ERC-20 new balance',

   -- debug --
   algorithm            LowCardinality(String),
   trx_type             LowCardinality(String),
   call_type            LowCardinality(String),
   reason               LowCardinality(String) COMMENT 'only available in native_balance_changes',

   -- indexes --
   INDEX idx_tx_hash            (tx_hash)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_contract           (contract)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address            (address)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller             (caller)              TYPE bloom_filter GRANULARITY 4,
   INDEX idx_old_balance        (old_balance)         TYPE minmax GRANULARITY 4,
   INDEX idx_new_balance        (new_balance)         TYPE minmax GRANULARITY 4,
   INDEX idx_algorithm          (algorithm)           TYPE set(32) GRANULARITY 4,
   INDEX idx_trx_type           (trx_type)            TYPE set(32) GRANULARITY 4,
   INDEX idx_call_type          (call_type)           TYPE set(32) GRANULARITY 4,
   INDEX idx_reason             (reason)              TYPE set(32) GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- ERC-20 transfers --
CREATE TABLE IF NOT EXISTS erc20_transfers  (
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
   caller               FixedString(42) COMMENT 'ERC-20 contract caller address', -- call.caller

   -- transfer --
   contract             FixedString(42) COMMENT 'ERC-20 contract address', -- log.address
   `from`               FixedString(42) COMMENT 'ERC-20 transfer sender address', -- log.topics[1]
   `to`                 FixedString(42) COMMENT 'ERC-20 transfer recipient address', -- log.topics[2]
   value                UInt256 COMMENT 'ERC-20 transfer value', -- log.data

   -- debug --
   algorithm            LowCardinality(String),
   trx_type             LowCardinality(String),
   call_type            LowCardinality(String),

   -- indexes --
   INDEX idx_tx_hash            (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_contract           (contract)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_from               (`from`)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_to                 (`to`)               TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller             (caller)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_value              (value)              TYPE minmax GRANULARITY 4,
   INDEX idx_algorithm          (algorithm)          TYPE set(32) GRANULARITY 4,
   INDEX idx_trx_type           (trx_type)           TYPE set(32) GRANULARITY 4,
   INDEX idx_call_type          (call_type)          TYPE set(32) GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);


-- ERC-20 contracts metadata events --
CREATE TABLE IF NOT EXISTS contract_changes  (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   ordinal              UInt64, -- log.ordinal
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   tx_hash       FixedString(66),

   -- call --
   caller               FixedString(42) COMMENT 'contract creator/modifier address',

   -- contract --
   address              FixedString(42) COMMENT 'ERC-20 contract address',
   name                 String COMMENT '(Optional) ERC-20 contract name (typically 3-8 characters)',
   symbol               String COMMENT '(Optional) ERC-20 contract symbol (typically 3-4 characters)',
   decimals             String COMMENT '(Optional UInt8) ERC-20 contract decimals (18 by default)',

   -- indexes --
   INDEX idx_tx_hash             (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller              (caller)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address             (address)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_name                (name)               TYPE bloom_filter GRANULARITY 4,
   INDEX idx_symbol              (symbol)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_decimals            (decimals)           TYPE minmax GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);


-- Native balance changes --
CREATE TABLE IF NOT EXISTS native_balance_changes AS erc20_balance_changes
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- Native transfers --
CREATE TABLE IF NOT EXISTS native_transfers AS erc20_transfers
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);


-- contract creations events --
CREATE TABLE IF NOT EXISTS contract_creations  (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   ordinal              UInt64, -- storage_change.ordinal or balance_change.ordinal
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   tx_hash       FixedString(66),
   `from`               FixedString(42),
   `to`                 FixedString(42),

   -- call --
   caller               FixedString(42) COMMENT 'contract creator',

   -- contract --
   address              FixedString(42) COMMENT 'contract address',
   hash                 FixedString(66) COMMENT 'unique contract hash',

   -- indexes --
   INDEX idx_block_num          (block_num)           TYPE minmax GRANULARITY 4,
   INDEX idx_timestamp          (timestamp)           TYPE minmax GRANULARITY 4,
   INDEX idx_tx_hash            (tx_hash)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_from               (`from`)              TYPE bloom_filter GRANULARITY 4,
   INDEX idx_to                 (`to`)                TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller             (caller)              TYPE bloom_filter GRANULARITY 4,
   INDEX idx_hash               (hash)                TYPE bloom_filter GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (address)
ORDER BY (address);


-- Uniswap::V2::Factory:PairCreated --
CREATE TABLE IF NOT EXISTS uniswap_v2_pairs_created (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),

   -- ordering --
   ordinal              UInt64, -- log.ordinal
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   tx_hash       FixedString(66),

   -- call --
   caller               FixedString(42) COMMENT 'factory creator', -- call.caller

   -- log --
   address              FixedString(42) COMMENT 'UniswapV2Pair factory address', -- log.address

   -- pair created --
   token0               FixedString(42) COMMENT 'UniswapV2Pair token0 address',
   token1               FixedString(42) COMMENT 'UniswapV2Pair token1 address',
   pair                 FixedString(42) COMMENT 'UniswapV2Pair pair address',

   -- indexes --
   INDEX idx_block_num        (block_num)          TYPE minmax GRANULARITY 4,
   INDEX idx_timestamp        (timestamp)          TYPE minmax GRANULARITY 4,
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token0           (token0)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token1           (token1)             TYPE bloom_filter GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (address, pair)
ORDER BY (address, pair);

-- Uniswap::V2::Pair:Sync --
CREATE TABLE IF NOT EXISTS uniswap_v2_syncs  (
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

   -- log --
   address              FixedString(42) COMMENT 'UniswapV2Pair pair address', -- log.address

   -- sync --
   reserve0             UInt256 COMMENT 'UniswapV2Pair token0 reserve',
   reserve1             UInt256 COMMENT 'UniswapV2Pair token1 reserve',

   -- indexes --
   INDEX idx_tx_hash            (tx_hash)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller             (caller)              TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address            (address)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_reserve0_minmax    (reserve0)            TYPE minmax       GRANULARITY 4,
   INDEX idx_reserve1_minmax    (reserve1)            TYPE minmax       GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V2::Pair:Swap --
CREATE TABLE IF NOT EXISTS uniswap_v2_swaps (
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
   address              FixedString(42) COMMENT 'UniswapV2Pair pair address', -- log.address
   amount0_in           UInt256 COMMENT 'UniswapV2Pair token0 amount in',
   amount0_out          UInt256 COMMENT 'UniswapV2Pair token0 amount out',
   amount1_in           UInt256 COMMENT 'UniswapV2Pair token1 amount in',
   amount1_out          UInt256 COMMENT 'UniswapV2Pair token1 amount out',
   sender               FixedString(42) COMMENT 'UniswapV2Pair sender address',
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
   INDEX idx_amount1_out      (amount1_out)        TYPE minmax       GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);



-- Uniswap::V3::Pool:Swap --
CREATE TABLE IF NOT EXISTS uniswap_v3_swaps (
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
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
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
   INDEX idx_sender            (sender)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_recipient         (recipient)         TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0           (amount0)           TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1           (amount1)           TYPE minmax       GRANULARITY 4,
   INDEX idx_sqrt_price_x96    (sqrt_price_x96)    TYPE minmax       GRANULARITY 4,
   INDEX idx_tick              (tick)              TYPE minmax       GRANULARITY 4,
   INDEX idx_liquidity         (liquidity)         TYPE minmax       GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- Uniswap::V3::Pool:Initialize --
CREATE TABLE IF NOT EXISTS uniswap_v3_initializes (
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

   -- initializes --
   address              FixedString(42) COMMENT 'UniswapV3Pool pool address', -- log.address
   sqrt_price_x96       UInt256 COMMENT 'UniswapV3Pool sqrt price x96',
   tick                 Int32 COMMENT 'UniswapV3Pool tick',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_sqrt_price_x96    (sqrt_price_x96)    TYPE minmax          GRANULARITY 4,
   INDEX idx_tick              (tick)              TYPE minmax          GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (address)
ORDER BY (address);

-- Uniswap::V3::Factory:PoolCreated --
CREATE TABLE IF NOT EXISTS uniswap_v3_pools_created (
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

   -- initializes --
   address              FixedString(42) COMMENT 'UniswapV3Pool factory address', -- log.address
   token0               FixedString(42) COMMENT 'UniswapV3Pool token0 address',
   token1               FixedString(42) COMMENT 'UniswapV3Pool token1 address',
   pool                 FixedString(42) COMMENT 'UniswapV3Pool pool address',
   tick_spacing         Int32 COMMENT 'UniswapV3Pool tick spacing (e.g., 60)',
   fee                  UInt32 COMMENT 'UniswapV3Pool fee (e.g., 3000 represents 0.30%)',

   -- indexes --
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_token0            (token0)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_token1            (token1)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_tick_spacing      (tick_spacing)      TYPE minmax       GRANULARITY 4,
   INDEX idx_fee               (fee)               TYPE minmax       GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (address, pool)
ORDER BY (address, pool);


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
CREATE MATERIALIZED VIEW IF NOT EXISTS balances_by_contract
ENGINE = ReplacingMergeTree(global_sequence)
PRIMARY KEY (contract, address)
ORDER BY (contract, address)
AS
SELECT * FROM balances;

-- Historical ERC-20 balances by address/contract --
CREATE TABLE IF NOT EXISTS historical_balances (
   -- block --
   block_num            SimpleAggregateFunction(min, UInt32),
   timestamp            DateTime(0, 'UTC') COMMENT 'the start of the aggregate window',

   -- balance change --
   contract             FixedString(42) COMMENT 'contract address',
   address              FixedString(42) COMMENT 'wallet address',

   -- balance --
   open                 AggregateFunction(argMin, UInt256, UInt64),
   high                 SimpleAggregateFunction(max, UInt256),
   low                  SimpleAggregateFunction(min, UInt256),
   close                AggregateFunction(argMax, UInt256, UInt64),
   uaw                  AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses that changed balance in the window',
   transactions         AggregateFunction(sum, UInt8) COMMENT 'number of transactions that changed balance in the window'
)
ENGINE = AggregatingMergeTree
PRIMARY KEY (address, contract, timestamp)
ORDER BY (address, contract, timestamp);

-- ERC-20 balances --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_erc20_balances_mv
TO historical_balances
AS
SELECT
   toStartOfHour(timestamp) AS timestamp,
   min(block_num) AS block_num,
   address,
   contract,
   argMinState(new_balance, global_sequence) AS open, -- normalized to wei (18 decimals)
   max(new_balance) AS high, -- normalized to wei (18 decimals)
   min(new_balance) AS low, -- normalized to wei (18 decimals)
   argMaxState(new_balance, global_sequence) AS close, -- normalized to wei (18 decimals)
   uniqState(address) AS uaw,
   sumState(1) AS transactions
FROM erc20_balance_changes
GROUP BY address, contract, timestamp;

-- Native balances --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_native_balances_mv
TO historical_balances
AS
SELECT
   -- block --
   min(block_num) AS block_num,
   toStartOfHour(timestamp) AS timestamp,

   -- balance change --
   '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
   address,

   -- balance --
   argMinState(new_balance, global_sequence) AS open,
   max(new_balance) AS high,
   min(new_balance) AS low,
   argMaxState(new_balance, global_sequence) AS close,
   uniqState(address) AS uaw,
   sumState(1) AS transactions
FROM native_balance_changes
GROUP BY address, timestamp;

-- Historical balances by contract/address --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_balances_by_contract
ENGINE = AggregatingMergeTree
PRIMARY KEY (contract, address, timestamp)
ORDER BY (contract, address, timestamp)
AS
SELECT * FROM historical_balances;


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


