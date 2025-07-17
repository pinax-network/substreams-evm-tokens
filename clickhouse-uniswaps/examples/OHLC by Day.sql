SYSTEM REFRESH VIEW mv_ohlc_prices;
SYSTEM WAIT VIEW mv_ohlc_prices;   -- block until it finishes

-- top 10 pools by uaw and transactions --
SELECT
    pool,
    token0,
    symbol0,
    token1,
    symbol1
FROM ohlc_prices
ORDER BY uaw + transactions DESC
LIMIT 10

-- Open prices by pool --
SELECT
    pool,
    timestamp,
    symbol0,
    symbol1,
    open0,
    1 / open0 AS open1
FROM ohlc_prices_by_day
WHERE pool = '0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc'
LIMIT 10