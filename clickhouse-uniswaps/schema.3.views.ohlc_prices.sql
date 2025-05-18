-- OHLC prices including Uniswaps with faster quantile computation --
CREATE TABLE IF NOT EXISTS ohlc_prices (
    timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

    -- pool --
    pool                 String COMMENT 'pool address',
    protocol             SimpleAggregateFunction(anyLast, LowCardinality(String)),

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
    pool AS pool,
    any(protocol) AS protocol,

    -- swaps --
    argMinState(price, global_sequence)                AS open0,
    quantileDeterministicState(price, global_sequence) AS quantile0,
    argMaxState(price, global_sequence)                AS close0,

    -- volume --
    sum(toUInt256(abs(amount0)))     AS gross_volume0,
    sum(toUInt256(abs(amount1)))     AS gross_volume1,
    sum(toInt256(amount0))           AS net_flow0,
    sum(toInt256(amount1))           AS net_flow1,

    -- universal --
    uniqState(tx_from) AS uaw,
    sum(1) AS transactions
FROM swaps
GROUP BY pool, timestamp;
