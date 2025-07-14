-- OHLC prices by token contract including Uniswap V2 & V3 with faster quantile computation --
CREATE TABLE IF NOT EXISTS ohlc_prices_by_contract (
   timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

   -- token --
   token                LowCardinality(FixedString(42)) COMMENT 'token address',

   -- pool --
   pool                 String COMMENT 'pool address',

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
REFRESH EVERY 10 MINUTE APPEND
TO ohlc_prices_by_contract
AS
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
ranked_pools AS (
   SELECT
        timestamp,
        token,
        pool,
        if(is_first_token, argMinMerge(o.open0), 1/argMinMerge(o.open0)) AS open,
        if(is_first_token, quantileDeterministicMerge(0.95)(o.quantile0), 1/quantileDeterministicMerge(0.05)(o.quantile0)) AS high,
        if(is_first_token, quantileDeterministicMerge(0.05)(o.quantile0), 1/quantileDeterministicMerge(0.95)(o.quantile0)) AS low,
        if(is_first_token, argMaxMerge(o.close0), 1/argMaxMerge(o.close0)) AS close,
        if(is_first_token, sum(o.gross_volume1), sum(o.gross_volume0)) AS volume,
        uniqMerge(o.uaw) AS uaw,
        sum(o.transactions) AS transactions,
        row_number() OVER (PARTITION BY token, timestamp ORDER BY uniqMerge(o.uaw) + sum(o.transactions) DESC) AS rank
    FROM ohlc_prices AS o
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
WHERE rank <= 20
ORDER BY token, pool, rank DESC;