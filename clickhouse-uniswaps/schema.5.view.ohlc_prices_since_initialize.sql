CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices_since_initialize
REFRESH EVERY 1 HOUR OFFSET 10 MINUTE APPEND
TO ohlc_prices_since_initialize
AS
SELECT
    min(timestamp) AS timestamp,

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
GROUP BY pool;
