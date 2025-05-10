INSERT INTO seaport_orders SELECT * FROM seaport_orders;
OPTIMIZE TABLE seaport_orders FINAL;

-- OHLC Trades for Seaport orders --
WITH (
    4 AS precision
)
SELECT
    toStartOfDay(timestamp)                                 AS timestamp,
    floor(argMinMerge(open), precision)                     AS open,
    floor(quantileDeterministicMerge(0.01)(quantile), precision)       AS low,
    floor(quantileDeterministicMerge(0.99)(quantile), precision)       AS high,
    floor(argMaxMerge(close), precision)                    AS close,
    sum(offer_volume)                                       AS sales,
    CONCAT(floor(sum(consideration_volume) / 10e18, precision), ' ETH')     AS volume,
    uniqMerge(uaw)                                          AS uaw
FROM seaport_orders_ohlc
WHERE offer_token = '0x524cab2ec69124574082676e6f654a18df49a048' -- LilPudgys
  AND consideration_token IN (
    '0x0000000000000000000000000000000000000000',
    '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
  ) -- ETH and WETH
GROUP BY timestamp
ORDER BY timestamp DESC;
