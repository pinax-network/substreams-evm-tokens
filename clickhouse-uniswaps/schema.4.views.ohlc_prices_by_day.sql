-- Swap Prices by 24h --
CREATE TABLE IF NOT EXISTS ohlc_prices_by_day (
    timestamp            DateTime(0, 'UTC') COMMENT 'beginning of window',

    -- pool --
    pool                 String COMMENT 'pool address',
    protocol             LowCardinality(String),

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

    -- swaps --
    open0                Float64 COMMENT 'price of token0 at the beginning of the window',
    high0                Float64 COMMENT 'price of token0 at the highest point in the window',
    low0                 Float64 COMMENT 'price of token0 at the lowest point in the window',
    close0               Float64 COMMENT 'price of token0 at the end of the window',

    -- volume --
    gross_volume0        Float64 COMMENT 'gross volume of token0 in window',
    gross_volume1        Float64 COMMENT 'gross volume of token1 in window',
    net_flow0            Float64 COMMENT 'net flow of token0 in window',
    net_flow1            Float64 COMMENT 'net flow of token1 in window',

    -- universal --
    uaw                  UInt64 COMMENT 'unique wallet addresses in window',
    transactions         UInt64 COMMENT 'number of transactions in window',

    -- indexes --
    INDEX idx_protocol          (protocol)          TYPE set(4)         GRANULARITY 4,
    INDEX idx_token0            (token0)            TYPE set(64)        GRANULARITY 4,
    INDEX idx_token1            (token1)            TYPE set(64)        GRANULARITY 4,

    -- indexes (swaps) --
    INDEX idx_open0             (open0)             TYPE minmax         GRANULARITY 4,
    INDEX idx_high0             (high0)             TYPE minmax         GRANULARITY 4,
    INDEX idx_low0              (low0)              TYPE minmax         GRANULARITY 4,
    INDEX idx_close0            (close0)            TYPE minmax         GRANULARITY 4,

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
ORDER BY (pool, timestamp);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices_by_day
TO ohlc_prices_by_day
AS
SELECT
    toStartOfDay(timestamp) AS timestamp,

    -- pool --
    pool,
    any(protocol) as protocol,

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

    -- token0 swaps --
    argMinMerge(open0) AS open0,
    quantileDeterministicMerge(0.95)(quantile0) AS high0,
    quantileDeterministicMerge(0.05)(quantile0) AS low0,
    argMaxMerge(close0) AS close0,

    -- volume --
    sum(gross_volume0) AS gross_volume0,
    sum(gross_volume1) AS gross_volume1,
    sum(net_flow0) AS net_flow0,
    sum(net_flow1) AS net_flow1,

    -- universal --
    uniqMerge(uaw) AS uaw,
    sum(transactions) AS transactions
FROM ohlc_prices
GROUP BY pool, timestamp;
