-- This file is generated. Do not edit.

CREATE TABLE IF NOT EXISTS verified_tokens  (
    network              LowCardinality(String),
    contract             FixedString(42),
    description          String,
    type                 Enum8('USD' = 1, 'ETH' = 2, 'BTC' = 3, 'BNB' = 4, 'POL' = 5, 'AVAX' = 6, 'ARB' = 7, 'TRX' = 8)
)
ENGINE = ReplacingMergeTree
ORDER BY (contract, network);

-- Insert initial Stable Tokens (1:1 USD) verified tokens
INSERT INTO verified_tokens (network, contract, description, type) VALUES
    ('mainnet', lower('0xdac17f958d2ee523a2206206994597c13d831ec7'), 'USDT (Tether USD)', 'USD'),
    ('mainnet', lower('0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'), 'USDC (Circle: USDC Token)', 'USD'),
    ('mainnet', lower('0x6b175474e89094c44da98b954eedeac495271d0f'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('mainnet', lower('0xc5f0f7b66764f6ec8c8dff7ba683102295e16409'), 'FDUSD (First Digital USD)', 'USD'),
    ('mainnet', lower('0x0000000000085d4780b73119b644ae5ecd22b376'), 'TUSD (TrueUSD)', 'USD'),
    ('mainnet', lower('0x8e870d67f660d95d5be530380d0ec0bd388289e1'), 'USDP (Pax Dollar)', 'USD'),
    ('bsc', lower('0x55d398326f99059ff775485246999027b3197955'), 'USDT (Binance-Peg Tether USD)', 'USD'),
    ('bsc', lower('0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d'), 'USDC (Binance-Peg USDC Token)', 'USD'),
    ('bsc', lower('0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3'), 'DAI (Binance-Peg Dai Stablecoin)', 'USD'),
    ('bsc', lower('0xe9e7cea3dedca5984780bafc599bd69add087d56'), 'BUSD (Binance-Peg BUSD Token)', 'USD'),
    ('base', lower('0x833589fcd6edb6e08f4c7c32d4f71b54bda02913'), 'USDC (Circle: USDC Token)', 'USD'),
    ('base', lower('0x820c137fa70c8691f0e44dc420a5e53c168921dc'), 'USDS (Sky: Dai Stablecoin)', 'USD'),
    ('base', lower('0x50c5725949a6f0c72e6c4a641f24049a917db0cb'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('arbone', lower('0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9'), 'USDT (Tether USD)', 'USD'),
    ('arbone', lower('0xaf88d065e77c8cc2239327c5edb3a432268e5831'), 'USDC (Circle: USDC Token)', 'USD'),
    ('arbone', lower('0xff970a61a04b1ca14834a43f5de4533ebddb5cc8'), 'USDC.e (Bridged from Ethereum)', 'USD'),
    ('arbone', lower('0x6491c05a82219b8d1479057361ff1654749b876b'), 'USDS (Sky: Dai Stablecoin)', 'USD'),
    ('arbone', lower('0xda10009cbd5d07dd0cecc66161fc93d7c9000da1'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('optimism', lower('0x94b008aa00579c1307b0ef2c499ad98a8ce58e58'), 'USDT (Tether USD)', 'USD'),
    ('optimism', lower('0x0b2c639c533813f4aa9d7837caf62653d097ff85'), 'UDSC (Bridged via Circle CCTP)', 'USD'),
    ('optimism', lower('0x7f5c764cbc14f9669b88837ca1490cca17c31607'), 'USDC.e (Bridged from Ethereum)', 'USD'),
    ('optimism', lower('0xda10009cbd5d07dd0cecc66161fc93d7c9000da1'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('polygon', lower('0xc2132d05d31c914a87c6611c10748aeb04b58e8f'), 'USDT (Bridged via Polygon POS)', 'USD'),
    ('polygon', lower('0x3c499c542cef5e3811e1192ce70d8cc03d5c3359'), 'USDC (Circle: USDC Token)', 'USD'),
    ('polygon', lower('0x2791bca1f2de4661ed88a30c99a7a9449aa84174'), 'USDC (Bridged via Polygon POS)', 'USD'),
    ('polygon', lower('0x9c9e5fd8bbc25984b178fdce6117defa39d2db39'), 'BUSD (Binance-Peg BUSD Token)', 'USD'),
    ('polygon', lower('0x8f3cf7ad23cd3cadbd9735aff958023239c6a063'), 'DAI', 'USD'),
    ('unichain', lower('0x078d782b760474a361dda0af3839290b0ef57ad6'), 'USDC', 'USD'),
    ('unichain', lower('0x9151434b16b9763660705744891fA906F660EcC5'), 'USDT0 Tether USD', 'USD')
    ('avalanche', lower('0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7'), 'USDT (Tether USD)', 'USD'),
    ('avalanche', lower('0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E'), 'USDC (Circle: USDC Token)', 'USD');

-- Insert initial Wrapped/Native Tokens (1:1 Native) verified tokens
INSERT INTO verified_tokens (network, contract, description, type) VALUES
    ('mainnet', lower('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'), 'WETH (Wrapped Ether)', 'ETH'),
    ('mainnet', lower('0xB8c77482e45F1F44dE1745F52C74426C631bDD52'), 'BNB (Wrapped BNB)', 'BNB'),
    ('mainnet', lower('0x2260fac5e5542a773aa44fbcfedf7c193bc2c599'), 'WBTC (Wrapped BTC)', 'BTC'),
    ('mainnet', lower('0xcbb7c0000ab88b473b1f5afd9ef808440eed33bf'), 'cbBTC (Coinbase Wrapped BTC)', 'BTC'),
    ('mainnet', lower('0x455e53CBB86018Ac2B8092FdCd39d8444aFFC3F6'), 'Polygon Ecosystem Token', 'POL'),
    ('mainnet', lower('0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1'), 'Arbitrum', 'ARB'),
    ('arbone', lower('0x82af49447d8a07e3bd95bd0d56f35241523fbab1'), 'WETH (Wrapped Ether)', 'ETH'),
    ('arbone', lower('0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f'), 'WBTC (Wrapped BTC)', 'BTC'),
    ('arbone', lower('0xcbb7c0000ab88b473b1f5afd9ef808440eed33bf'), 'cbBTC (Coinbase Wrapped BTC)', 'BTC'),
    ('arbone', lower('0x912ce59144191c1204e64559fe8253a0e49e6548'), 'Arbitrum', 'ARB'),
    ('bsc', lower('0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c'), 'WBNB (Wrapped BNB)', 'BNB'),
    ('bsc', lower('0x2170ed0880ac9a755fd29b2688956bd959f933f8'), 'WETH (Wrapped ETH)', 'ETH'),
    ('bsc', lower('0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c'), 'Binance-Peg BTCB Token', 'BTC'),
    ('bsc', lower('0x0555E30da8f98308EdB960aa94C0Db47230d2B9c'), 'WBTC (Wrapped BTC)', 'BTC'),
    ('bsc', lower('0xce7de646e7208a4ef112cb6ed5038fa6cc6b12e3'), 'Tron', 'TRX'),
    ('polygon', lower('0x7ceb23fd6bc0add59e62ac25578270cff1b9f619'), 'WETH (Wrapped Ether)', 'ETH'),
    ('polygon', lower('0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270'), 'WPOL (Wrapped Polygon)', 'POL'),
    ('polygon', lower('0x0000000000000000000000000000000000001010'), 'POL', 'POL'),
    ('polygon', lower('0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6'), 'WBTC (Wrapped BTC)', 'POL'),
    ('base', lower('0x4200000000000000000000000000000000000006'), 'WETH (Wrapped Ether)', 'ETH'),
    ('optimism', lower('0x4200000000000000000000000000000000000006'), 'WETH (Wrapped Ether)', 'ETH'),
    ('unichain', lower('0x4200000000000000000000000000000000000006'), 'WETH (Wrapped Ether)', 'ETH'),
    ('avalanche', lower('0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7'), 'WAVAX (Wrapped AVAX)', 'AVAX')
    ('avalanche', lower('0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB'), 'WETH.e (Avalanche Bridge)', 'ETH')
    ('avalanche', lower('0x152b9d0FdC40C096757F570A51E494bd4b943E50'), 'BTC.b (Avalanche Bridge)', 'BTC');


-- ERC-20 Metadata Initialize --
CREATE TABLE IF NOT EXISTS erc20_metadata_initialize (
    -- block --
    block_num            UInt32,
    timestamp            DateTime(0, 'UTC'),

    -- event --
    address              FixedString(42),
    decimals             UInt8,
    name                 Nullable(String),
    symbol               Nullable(String)
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address);

-- ERC-20 Metadata Changes --
CREATE TABLE IF NOT EXISTS erc20_metadata_changes (
    -- block --
    block_num            UInt32,
    timestamp            DateTime(0, 'UTC'),

    -- event --
    address              FixedString(42),
    name                 Nullable(String),
    symbol               Nullable(String)
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address);



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
   INDEX idx_tx_hash          (tx_hash)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller           (caller)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address          (address)            TYPE set(64) GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_sender           (sender)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_to               (`to`)               TYPE bloom_filter GRANULARITY 4,
   INDEX idx_amount0_in       (amount0_in)         TYPE minmax       GRANULARITY 4,
   INDEX idx_amount0_out      (amount0_out)        TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1_in       (amount1_in)         TYPE minmax       GRANULARITY 4,
   INDEX idx_amount1_out      (amount1_out)        TYPE minmax       GRANULARITY 4
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
   INDEX idx_tx_hash            (tx_hash)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller             (caller)              TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address            (address)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_reserve0_minmax    (reserve0)            TYPE minmax       GRANULARITY 4,
   INDEX idx_reserve1_minmax    (reserve1)            TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree
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
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address           (address)           TYPE set(64) GRANULARITY 4,

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
   salt                 FixedString(66) COMMENT 'The extra data to make positions unique'
)
ENGINE = ReplacingMergeTree
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
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter    GRANULARITY 4,

   -- indexes (event) --
   INDEX idx_protocol_fee_controller (protocol_fee_controller) TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree
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
   INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_caller            (caller)            TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_address           (address)           TYPE bloom_filter    GRANULARITY 4,
   -- indexes (event) --
   INDEX idx_id                (id)                TYPE bloom_filter    GRANULARITY 4,
   INDEX idx_protocol_fee      (protocol_fee)      TYPE minmax          GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);


-- latest ERC-20 Metadata --
CREATE TABLE IF NOT EXISTS erc20_metadata  (
   -- block --
   block_num            SimpleAggregateFunction(max, UInt32) COMMENT 'block number',
   timestamp            SimpleAggregateFunction(max, DateTime(0, 'UTC')),

   -- contract --
   address              FixedString(42) COMMENT 'ERC-20 contract address',
   decimals             SimpleAggregateFunction(anyLast, UInt8) COMMENT 'ERC-20 contract decimals (typically 18)',
   name                 SimpleAggregateFunction(anyLast, Nullable(String)) COMMENT 'ERC-20 contract name (typically 3-8 characters)',
   symbol               SimpleAggregateFunction(anyLast, Nullable(String)) COMMENT 'ERC-20 contract symbol (typically 3-4 characters)'
)
ENGINE = AggregatingMergeTree
ORDER BY address;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_metadata_initialize
TO erc20_metadata AS
SELECT
    -- block --
    block_num,
    timestamp,

    -- event--
    address,
    decimals,

    -- replace empty strings with NULLs --
    IF (name = '', Null, name) AS name,
    IF (symbol = '', Null, symbol) AS symbol
FROM erc20_metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_metadata_changes
TO erc20_metadata AS
SELECT
    -- block --
    c.block_num as block_num,
    c.timestamp as timestamp,

    -- event--
    c.address AS address,

    -- replace empty strings with NULLs --
    IF (c.name = '', Null, c.name) AS name,
    IF (c.symbol = '', Null, c.symbol) AS symbol
FROM erc20_metadata_changes AS c
JOIN erc20_metadata_initialize USING (address); -- address must already be initialized

-- one time INSERT to populate Native contract --
INSERT INTO erc20_metadata (
    -- block --
    block_num,
    timestamp,
    -- event --
    address,
    name,
    symbol,
    decimals
)
VALUES (
    0,
    toDateTime(0, 'UTC'),
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
   INDEX idx_pool          (pool)            TYPE set(64) GRANULARITY 4,
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

-- OHLC prices including Uniswaps with faster quantile computation --
CREATE TABLE IF NOT EXISTS ohlc_prices (
    timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

    -- pool --
    pool                 String COMMENT 'pool address',
    protocol             SimpleAggregateFunction(any, LowCardinality(String)),
    factory              SimpleAggregateFunction(any, FixedString(42)),
    fee                  SimpleAggregateFunction(anyLast, UInt32),

    -- token0 erc20 metadata --
    token0               SimpleAggregateFunction(any, FixedString(42)),
    decimals0            SimpleAggregateFunction(any, UInt8),
    symbol0              SimpleAggregateFunction(anyLast, Nullable(String)),
    name0                SimpleAggregateFunction(anyLast, Nullable(String)),

    -- token1 erc20 metadata --
    token1               SimpleAggregateFunction(any, FixedString(42)),
    decimals1            SimpleAggregateFunction(any, UInt8),
    symbol1              SimpleAggregateFunction(anyLast, Nullable(String)),
    name1                SimpleAggregateFunction(anyLast, Nullable(String)),

    -- canonical pair (token0, token1) lexicographic order --
    canonical0           SimpleAggregateFunction(any, FixedString(42)),
    canonical1           SimpleAggregateFunction(any, FixedString(42)),

    -- swaps --
    open0                AggregateFunction(argMin, Float64, UInt64),
    quantile0            AggregateFunction(quantileDeterministic, Float64, UInt64),
    close0               AggregateFunction(argMax, Float64, UInt64),

    -- volume --
    gross_volume0        SimpleAggregateFunction(sum, Float64) COMMENT 'gross volume of token0 in the window',
    gross_volume1        SimpleAggregateFunction(sum, Float64) COMMENT 'gross volume of token1 in the window',
    net_flow0            SimpleAggregateFunction(sum, Float64) COMMENT 'net flow of token0 in the window',
    net_flow1            SimpleAggregateFunction(sum, Float64) COMMENT 'net flow of token1 in the window',

    -- universal --
    uaw                  AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses in the window',
    transactions         SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window',

    -- indexes --
    INDEX idx_protocol          (protocol)                  TYPE set(4)         GRANULARITY 4,
    INDEX idx_factory           (factory)                   TYPE set(64)        GRANULARITY 4,
    INDEX idx_fee               (fee)                       TYPE minmax         GRANULARITY 4,
    INDEX idx_token0            (token0)                    TYPE set(64)        GRANULARITY 4,
    INDEX idx_token1            (token1)                    TYPE set(64)        GRANULARITY 4,

    -- indexes (volume) --
    INDEX idx_gross_volume0     (gross_volume0)             TYPE minmax         GRANULARITY 4,
    INDEX idx_gross_volume1     (gross_volume1)             TYPE minmax         GRANULARITY 4,
    INDEX idx_net_flow0         (net_flow0)                 TYPE minmax         GRANULARITY 4,
    INDEX idx_net_flow1         (net_flow1)                 TYPE minmax         GRANULARITY 4,
    INDEX idx_transactions      (transactions)              TYPE minmax         GRANULARITY 4,

    -- indexes (canonical pair) --
    INDEX idx_canonical_pair    (canonical0, canonical1)    TYPE set(64)        GRANULARITY 4,
    INDEX idx_canonical_pair0   (canonical0)                TYPE set(64)        GRANULARITY 4,
    INDEX idx_canonical_pair1   (canonical1)                TYPE set(64)        GRANULARITY 4
)
ENGINE = AggregatingMergeTree
ORDER BY (pool, timestamp);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices
-- REFRESH EVERY 1 HOUR OFFSET 5 MINUTE APPEND
TO ohlc_prices
AS
WITH
    any(p.token0) AS t0,
    any(p.token1) AS t1,
    pow(10, m0.decimals) AS scale0,
    pow(10, m1.decimals) AS scale1
SELECT
    toStartOfHour(s.timestamp)  AS timestamp,
    s.pool                      AS pool,
    any(s.protocol)             AS protocol,
    any(p.factory)              AS factory,
    anyLast(p.fee)              AS fee,

    -- token0 erc20 metadata --
    t0                      AS token0,
    any(m0.decimals)        AS decimals0,
    anyLast(m0.symbol)      AS symbol0,
    anyLast(m0.name)        AS name0,

    -- token1 erc20 metadata --
    t1                      AS token1,
    any(m1.decimals)        AS decimals1,
    anyLast(m1.symbol)      AS symbol1,
    anyLast(m1.name)        AS name1,

    -- canonical pair --
    if(t0 < t1, t0, t1) AS canonical0,
    if(t0 < t1, t1, t0) AS canonical1,

    -- swaps --
    argMinState(s.price * scale0 / scale1, s.global_sequence)                AS open0,
    quantileDeterministicState(s.price * scale0 / scale1, s.global_sequence) AS quantile0,
    argMaxState(s.price * scale0 / scale1, s.global_sequence)                AS close0,

    -- volume --
    sum(abs(s.amount0) / scale0)        AS gross_volume0,
    sum(abs(s.amount1) / scale1)        AS gross_volume1,
    sum(s.amount0 / scale0)             AS net_flow0,
    sum(s.amount1 / scale1)             AS net_flow1,

    -- universal --
    uniqState(s.tx_from)                AS uaw,
    count()                             AS transactions
FROM swaps AS s
LEFT JOIN pools AS p USING (pool)
LEFT JOIN erc20_metadata AS m0 ON m0.address = p.token0
LEFT JOIN erc20_metadata AS m1 ON m1.address = p.token1
GROUP BY pool, timestamp;


-- Pool activity summary table (Volume, UAW, Transactions) for each pool --
CREATE TABLE IF NOT EXISTS pool_activity_summary (
    timestamp            DateTime(0, 'UTC') COMMENT 'beginning of window',

    -- pool --
    pool                 String COMMENT 'pool address',
    protocol             LowCardinality(String),
    factory              FixedString(42) COMMENT 'factory address', -- log.address
    fee                  UInt32 COMMENT 'pool fee (e.g., 3000 represents 0.30%)',

    -- token0 erc20 metadata --
    token0               FixedString(42),
    decimals0            UInt8,
    symbol0              Nullable(String),
    name0                Nullable(String),

    -- token1 erc20 metadata --
    token1               FixedString(42),
    decimals1            UInt8,
    symbol1              Nullable(String),
    name1                Nullable(String),

    -- canonical pair (token0, token1) lexicographic order --
    canonical0           FixedString(42),
    canonical1           FixedString(42),

    -- volume --
    gross_volume0        Float64 COMMENT 'gross volume of token0 in window',
    gross_volume1        Float64 COMMENT 'gross volume of token1 in window',
    net_flow0            Float64 COMMENT 'net flow of token0 in window',
    net_flow1            Float64 COMMENT 'net flow of token1 in window',

    -- universal --
    uaw                  UInt64 COMMENT 'unique wallet addresses in window',
    transactions         UInt64 COMMENT 'number of transactions in window',

    -- indexes --
    INDEX idx_timestamp         (timestamp)         TYPE minmax         GRANULARITY 4,
    INDEX idx_protocol          (protocol)          TYPE set(4)         GRANULARITY 4,
    INDEX idx_token0            (token0)            TYPE set(64)        GRANULARITY 4,
    INDEX idx_token1            (token1)            TYPE set(64)        GRANULARITY 4,
    INDEX idx_factory           (factory)           TYPE set(64)        GRANULARITY 4,
    INDEX idx_fee               (fee)               TYPE minmax         GRANULARITY 4,

    -- indexes (volume) --
    INDEX idx_gross_volume0     (gross_volume0)     TYPE minmax         GRANULARITY 4,
    INDEX idx_gross_volume1     (gross_volume1)     TYPE minmax         GRANULARITY 4,
    INDEX idx_net_flow0         (net_flow0)         TYPE minmax         GRANULARITY 4,
    INDEX idx_net_flow1         (net_flow1)         TYPE minmax         GRANULARITY 4,

    -- indexes (universal) --
    INDEX idx_uaw               (uaw)               TYPE minmax         GRANULARITY 4,
    INDEX idx_transactions      (transactions)      TYPE minmax         GRANULARITY 4,

    -- indexes (canonical pair) --
    INDEX idx_canonical_pair    (canonical0, canonical1)    TYPE set(64)        GRANULARITY 4,
    INDEX idx_canonical_pair0   (canonical0)                TYPE set(64)        GRANULARITY 4,
    INDEX idx_canonical_pair1   (canonical1)                TYPE set(64)        GRANULARITY 4
)
ENGINE = ReplacingMergeTree
ORDER BY (pool);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_pool_activity_summary
-- REFRESH EVERY 1 HOUR OFFSET 10 MINUTE APPEND
TO pool_activity_summary
AS
SELECT
    min(timestamp) AS timestamp,

    -- pool --
    pool,
    any(protocol) as protocol,
    any(factory) as factory,
    any(fee) as fee,

    -- tokens0 erc20 metadata --
    any(token0) as token0,
    any(decimals0) as decimals0,
    any(symbol0) as symbol0,
    any(name0) as name0,

    -- tokens1 erc20 metadata --
    any(token1) as token1,
    any(decimals1) as decimals1,
    any(symbol1) as symbol1,
    any(name1) as name1,

    -- canonical pair (token0, token1) lexicographic order --
    any(canonical0) as canonical0,
    any(canonical1) as canonical1,

    -- volume --
    sum(gross_volume0) AS gross_volume0,
    sum(gross_volume1) AS gross_volume1,
    sum(net_flow0) AS net_flow0,
    sum(net_flow1) AS net_flow1,

    -- universal --
    uniqMerge(uaw) AS uaw,
    sum(transactions) AS transactions
FROM ohlc_prices
GROUP BY pool;


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

