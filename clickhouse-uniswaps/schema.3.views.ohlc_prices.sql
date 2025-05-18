-- OHLC prices including Uniswaps with faster quantile computation --
CREATE TABLE IF NOT EXISTS ohlc_prices (
    timestamp            DateTime(0, 'UTC') COMMENT 'beginning of the bar',

    -- pool --
    pool                 String COMMENT 'pool address',
    protocol             SimpleAggregateFunction(any, LowCardinality(String)),

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
    toStartOfHour(s.timestamp) AS timestamp,

    -- pool --
    s.pool AS pool,
    any(s.protocol) AS protocol,

    -- token0 erc20 metadata --
    any(p.token0)           AS token0,
    any(m0.decimals)        AS decimals0,
    anyLast(m0.name)        AS name0,
    anyLast(m0.symbol)      AS symbol0,

    -- token1 erc20 metadata --
    any(p.token1)           AS token1,
    any(m1.decimals)        AS decimals1,
    anyLast(m1.name)        AS name1,
    anyLast(m1.symbol)      AS symbol1,

    -- swaps --
    argMinState(s.price, s.global_sequence)                AS open0,
    quantileDeterministicState(s.price, s.global_sequence) AS quantile0,
    argMaxState(s.price, s.global_sequence)                AS close0,

    -- volume --
    sum(toUInt256(abs(s.amount0)))     AS gross_volume0,
    sum(toUInt256(abs(s.amount1)))     AS gross_volume1,
    sum(toInt256(s.amount0))           AS net_flow0,
    sum(toInt256(s.amount1))           AS net_flow1,

    -- universal --
    uniqState(s.tx_from) AS uaw,
    sum(1) AS transactions
FROM swaps AS s
JOIN pools AS p USING (pool)
JOIN erc20_metadata AS m0 ON m0.address = p.token0
JOIN erc20_metadata AS m1 ON m1.address = p.token1
GROUP BY pool, timestamp;
