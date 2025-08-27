-- OHLCV prices (Open/High/Low/Close/Volume) --
CREATE TABLE IF NOT EXISTS ohlc_prices (
    timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

    -- pool --
    pool                 String COMMENT 'pool address',
    protocol             Enum( 'uniswap_v2' = 1, 'uniswap_v3' = 2, 'uniswap_v4' = 3 ),
    factory              FixedString(42),

    -- token0 erc20 metadata --
    token0               FixedString(42),
    decimals0            UInt8,

    -- token1 erc20 metadata --
    token1               FixedString(42),
    decimals1            UInt8,

    -- swaps --
    open0                AggregateFunction(argMin, Float64, UInt64),
    quantile0            AggregateFunction(quantileDeterministic, Float64, UInt64),
    close0               AggregateFunction(argMax, Float64, UInt64),

    -- volume --
    gross_volume0        SimpleAggregateFunction(sum, Int256) COMMENT 'gross volume of token0 in the window',
    gross_volume1        SimpleAggregateFunction(sum, Int256) COMMENT 'gross volume of token1 in the window',
    net_flow0            SimpleAggregateFunction(sum, Int256) COMMENT 'net flow of token0 in the window',
    net_flow1            SimpleAggregateFunction(sum, Int256) COMMENT 'net flow of token1 in the window',

    -- universal --
    uaw                  AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses in the window',
    transactions         SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window',

    -- indexes --
    INDEX idx_protocol          (protocol)                  TYPE set(4)           GRANULARITY 1,
    INDEX idx_factory           (factory)                   TYPE set(256)         GRANULARITY 1,
    INDEX idx_pool              (pool)                      TYPE set(512)         GRANULARITY 1,
    INDEX idx_token0            (token0)                    TYPE set(1024)        GRANULARITY 1,
    INDEX idx_token1            (token1)                    TYPE set(1024)        GRANULARITY 1,

    -- indexes (volume) --
    INDEX idx_gross_volume0     (gross_volume0)             TYPE minmax         GRANULARITY 1,
    INDEX idx_gross_volume1     (gross_volume1)             TYPE minmax         GRANULARITY 1,
    INDEX idx_net_flow0         (net_flow0)                 TYPE minmax         GRANULARITY 1,
    INDEX idx_net_flow1         (net_flow1)                 TYPE minmax         GRANULARITY 1,
    INDEX idx_transactions      (transactions)              TYPE minmax         GRANULARITY 1,

    -- projections --
    -- PROJECTION prj_timestamp ( SELECT timestamp, _part_offset ORDER BY (timestamp) )
)
ENGINE = AggregatingMergeTree
ORDER BY (protocol, factory, pool, token0, token1, decimals0, decimals1, timestamp);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices
REFRESH EVERY 1 MINUTE APPEND
TO ohlc_prices
AS
WITH
    (input_token <= output_token) AS dir,
    if (dir, input_token, output_token) AS token0,
    if (dir, output_token, input_token) AS token1,
    if (dir, input_amount, output_amount) AS amount0,
    if (dir, output_amount, input_amount) AS amount1,
    if (dir, input_decimals, output_decimals) AS decimals0,
    if (dir, output_decimals, input_decimals) AS decimals1,
    if (dir, price, 1 / price) AS price,

    -- gross volume: +in, +out
    abs(amount0) AS gv0,
    abs(amount1) AS gv1,

    -- net flow of token0: +in, -out
    if (dir, input_amount, -output_amount) AS nf0,
    -- net flow of token1: +in, -out (signs flipped vs. your original)
    if (dir, -output_amount, input_amount) AS nf1

SELECT
    toStartOfHour(timestamp)    AS timestamp,
    protocol, factory, pool, token0, token1, decimals0, decimals1,

    /* OHLC */
    argMinState(price, toUInt64(timestamp))                 AS open0,
    quantileDeterministicState(price, toUInt64(timestamp))  AS quantile0,
    argMaxState(price, toUInt64(timestamp))                 AS close0,

    /* volumes & flows (all in canonical orientation) */
    sum(gv0)                AS gross_volume0,
    sum(gv1)                AS gross_volume1,
    sum(nf0)                AS net_flow0,
    sum(nf1)                AS net_flow1,

    /* universal */
    uniqState(tx_from)      AS uaw,
    count()                 AS transactions
FROM swaps AS s
GROUP BY protocol, factory, pool, token0, token1, decimals0, decimals1, timestamp;

-- OHLCV by token --
CREATE TABLE ohlc_prices_by_contract
(
    `timestamp` DateTime('UTC') COMMENT 'beginning of the bar',
    `token` LowCardinality(FixedString(42)) COMMENT 'token address',
    `pool` String COMMENT 'pool address',
    `open` Float64,
    `high` Float64,
    `low` Float64,
    `close` Float64,
    `volume` UInt256,
    `uaw` UInt64,
    `transactions` UInt64
)
ENGINE = AggregatingMergeTree
PRIMARY KEY (token, pool, timestamp)
ORDER BY (token, pool, timestamp)
SETTINGS index_granularity = 8192;

-- MV takes the top 20 active pools for each token and store price data --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices_by_contract
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
    greatest(high, open, close) AS high, -- OHLC candle consistency
    least(low, open, close) AS low, -- OHLC candle consistency
    close,
    volume,
    uaw,
    transactions
FROM ranked_pools
WHERE rank <= 20 -- Top 20 pools by activity by token for accurate price without costly aggregates
ORDER BY token, pool, rank DESC;
