-- Pool activity (Transactions) --
CREATE TABLE IF NOT EXISTS pool_activity_summary (
    -- pool --
    protocol             LowCardinality(String),
    factory              FixedString(42),
    pool                 String,
    token0               FixedString(42),
    token1               FixedString(42),

    -- summing --
    transactions         UInt64,

    -- indexes --
    INDEX idx_protocol          (protocol)                  TYPE set(4)             GRANULARITY 1,
    INDEX idx_factory           (factory)                   TYPE set(256)           GRANULARITY 1,
    INDEX idx_pool              (pool)                      TYPE set(1024)          GRANULARITY 1,
    INDEX idx_token0            (token0)                    TYPE set(1024)          GRANULARITY 1,
    INDEX idx_token1            (token1)                    TYPE set(1024)          GRANULARITY 1,
    INDEX idx_transactions      (transactions)              TYPE minmax             GRANULARITY 1
)
ENGINE = SummingMergeTree
ORDER BY (protocol, factory, pool, token0, token1);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_pool_activity_summary
TO pool_activity_summary
AS
SELECT
    token0, token1, protocol, factory, pool,

    -- summing --
    sum(transactions) as transactions
FROM ohlc_prices
GROUP BY protocol, factory, pool, token0, token1;
