-- OHLC prices including Uniswap V2 & V3 with faster quantile computation --
CREATE TABLE IF NOT EXISTS ohlc_prices (
   timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

   -- pool --
   pool                 LowCardinality(String) COMMENT 'pool address',

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
ORDER BY (pool, timestamp);

-- Swaps --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices
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
   uniqState(sender) + uniqState(tx_from) AS uaw,
   sum(1) AS transactions
FROM swaps AS s
GROUP BY pool, timestamp;

-- OHLC prices by token contract --
CREATE TABLE IF NOT EXISTS ohlc_prices_by_contract (
   timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

   -- token --
   token                LowCardinality(FixedString(42)) COMMENT 'token address',

   -- pool --
   pool                 LowCardinality(String) COMMENT 'pool address',

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
ORDER BY (token, pool, timestamp);

-- Swaps --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices_by_contract
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
    FROM mv_ohlc_prices AS o
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
