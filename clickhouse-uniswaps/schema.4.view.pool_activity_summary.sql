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
