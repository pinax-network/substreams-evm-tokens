
-- Store all of the pairs prices computed from the swap events
CREATE TABLE IF NOT EXISTS pair_prices
(
    datetime            DateTime('UTC'),
    global_sequence     UInt64,
    token0              String,
    symbol0             String,
    token1              String,
    symbol1             String,
    price               Float64,
    volume              Float64
)
ENGINE = MergeTree
ORDER BY (token0, token1, datetime);

-- Continuously populate prices from new swaps
CREATE MATERIALIZED VIEW IF NOT EXISTS pair_prices_mv TO pair_prices
AS
WITH
    -- Gets the token addresses, decimals and symbols for pair prices
    PairInfo AS
    (
        SELECT
            pc.pair AS address,
            pc.token0,
            pc.token1,
            t0.decimals AS decimals0,
            t0.symbol AS symbol0,
            t1.decimals AS decimals1,
            t1.symbol AS symbol1
        FROM pairs_created AS pc
        JOIN contracts AS t0 ON pc.token0 = t0.address
        JOIN contracts AS t1 ON pc.token1 = t1.address
    )
SELECT
    s.timestamp AS datetime,
    s.global_sequence,
    if(pi.token0 < pi.token1, pi.token0, pi.token1) AS token0,
    if(pi.token0 < pi.token1, pi.symbol0, pi.symbol1) AS symbol0,
    if(pi.token1 > pi.token0, pi.token1, pi.token0) AS token1,
    if(pi.token1 > pi.token0, pi.symbol1, pi.symbol0) AS symbol1,
    -- Two cases depending on swap direction
    CASE
        WHEN amount0_in > 0 AND amount1_out > 0 THEN (toFloat64(amount0_in) / toFloat64(amount1_out)) * pow(10, pi.decimals1 - pi.decimals0)
        WHEN amount0_out > 0 AND amount1_in > 0 THEN (toFloat64(amount0_out) / toFloat64(amount1_in)) * pow(10, pi.decimals1 - pi.decimals0)
        ELSE 0
    END AS price,
    -- Always express volume in token0 currency
    CASE
        WHEN amount0_in > 0 THEN toFloat64(amount0_in) / pow(10, pi.decimals0)
        WHEN amount0_out > 0 THEN toFloat64(amount0_out) / pow(10, pi.decimals0)
        ELSE 0
    END AS volume
FROM swaps AS s
INNER JOIN PairInfo AS pi ON s.address = pi.address
-- Filter out problematic swaps
WHERE (amount0_in > 0 AND amount1_out > 0) OR (amount0_out > 0 AND amount1_in > 0);

-- Store OHLC for token pairs
CREATE TABLE IF NOT EXISTS ohlc_from_swaps
(
    token0          String,
    token1          String,
    -- Not unique, only cosmetic, use token0 and token1 addresses for uniqueness
    ticker          String,
    datetime        DateTime('UTC'),
    -- open/close value determinated not based on timestamp but global sequence since multiple swaps can occur in same block
    -- open will take the earliest (minimum sequence) and close the latest (highest sequence)
    open            AggregateFunction(argMin, Float64, UInt64),
    high            SimpleAggregateFunction(max, Float64),
    low             SimpleAggregateFunction(min, Float64),
    close           AggregateFunction(argMax, Float64, UInt64),
    volume          SimpleAggregateFunction(sum, Float64)
)
ENGINE = AggregatingMergeTree
ORDER BY (token0, token1, datetime);

CREATE MATERIALIZED VIEW IF NOT EXISTS ohlc_from_swaps_MV TO ohlc_from_swaps
AS
SELECT
    token0,
    token1,
    -- Create ticker from token symbols
    concat(symbol1, symbol0) AS ticker,
    -- Makes the OHLC one hour by default, other time periods can be computed on top
    toStartOfHour(datetime) AS datetime,
    argMinState(price, global_sequence) AS open,
    quantileExactWeighted(0.95)(price, toUInt64(p.volume)) AS high,
    quantileExactWeighted(0.05)(price, toUInt64(p.volume)) AS low,
    -- Global sequence as discriminator
    argMaxState(price, global_sequence) AS close,
    sum(volume) AS volume
FROM pair_prices AS p
-- All needed as they aren't in a aggregate function
GROUP BY token0, token1, ticker, datetime;

INSERT INTO pair_prices
WITH
    -- Gets the token addresses, decimals and symbols for pair prices
    PairInfo AS
    (
        SELECT
            pc.pair AS address,
            pc.token0,
            pc.token1,
            t0.decimals AS decimals0,
            t0.symbol AS symbol0,
            t1.decimals AS decimals1,
            t1.symbol AS symbol1
        FROM pairs_created AS pc
        JOIN contracts AS t0 ON pc.token0 = t0.address
        JOIN contracts AS t1 ON pc.token1 = t1.address
    )
SELECT
    s.timestamp AS datetime,
    s.global_sequence,
    if(pi.token0 < pi.token1, pi.token0, pi.token1) AS token0,
    if(pi.token0 < pi.token1, pi.symbol0, pi.symbol1) AS symbol0,
    if(pi.token1 > pi.token0, pi.token1, pi.token0) AS token1,
    if(pi.token1 > pi.token0, pi.symbol1, pi.symbol0) AS symbol1,
    -- Two cases depending on swap direction
    CASE
        WHEN amount0_in > 0 AND amount1_out > 0 THEN (toFloat64(amount0_in) / toFloat64(amount1_out)) * pow(10, pi.decimals1 - pi.decimals0)
        WHEN amount0_out > 0 AND amount1_in > 0 THEN (toFloat64(amount0_out) / toFloat64(amount1_in)) * pow(10, pi.decimals1 - pi.decimals0)
        ELSE 0
    END AS price,
    -- Always express volume in token0 currency
    CASE
        WHEN amount0_in > 0 THEN toFloat64(amount0_in) / pow(10, pi.decimals0)
        WHEN amount0_out > 0 THEN toFloat64(amount0_out) / pow(10, pi.decimals0)
        ELSE 0
    END AS volume
FROM swaps AS s
INNER JOIN PairInfo AS pi ON s.address = pi.address
-- Filter out problematic swaps
WHERE (amount0_in > 0 AND amount1_out > 0) OR (amount0_out > 0 AND amount1_in > 0);