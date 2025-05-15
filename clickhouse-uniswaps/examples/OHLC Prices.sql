-- OHLC Prices by Pool (Uniswap V3 WETH/USDT) --
WITH (
      18 AS decimals0, -- JOIN contracts
      6 AS decimals1, -- JOIN contracts
      2 AS precision -- user defined
) SELECT
      timestamp,
      'WETH/USDT' AS ticker,

      -- OHLC --
      floor(argMinMerge(open0) * pow(10, decimals0 - decimals1), precision)                        AS open,
      floor(quantileDeterministicMerge(0.99)(high0) * pow(10, decimals0 - decimals1), precision)   AS high,
      floor(quantileDeterministicMerge(0.01)(low0) * pow(10, decimals0 - decimals1), precision)    AS low,
      floor(argMaxMerge(close0) * pow(10, decimals0 - decimals1), precision)                       AS close,

      -- volume --
      floor(sum(gross_volume0) / pow(10, decimals0), precision)         AS "gross volume (ETH)",
      floor(sum(gross_volume1) / pow(10, decimals1), precision)         AS "gross volume (USD)",
      floor(sum(net_flow0) / pow(10, decimals0), precision)             AS "net flow (ETH)",
      floor(sum(net_flow1) / pow(10, decimals1), precision)             AS "net flow (USD)",

      -- universal --
      uniqMerge(uaw)          AS uaw,
      sum(transactions)       AS transactions
FROM ohlc_prices
WHERE pool = lower('0xc7bbec68d12a0d1830360f8ec58fa599ba1b0e9b') -- Uniswap V3 WETH/USDT
GROUP BY pool, timestamp
ORDER BY timestamp DESC
LIMIT 10;

-- 24h Volume & Fees by Pool --
WITH (
      100 AS fee, -- JOIN pools
      18 AS decimals0, -- JOIN contracts
      6 AS decimals1, -- JOIN contracts
      2 AS precision -- user defined
) SELECT
      toDate(timestamp) as date,
      'WETH/USDT' AS ticker,

      -- Volume --
      floor(sum(gross_volume0) / pow(10, decimals0), precision)        AS "volume (WETH)",
      floor(sum(gross_volume1) / pow(10, decimals1), precision)        AS "volume (USDT)",
      floor("volume (USDT)" * fee / pow(10, decimals1), precision)     AS "fees (USDT)", -- Uniswap V3 fee 0.01% (1=basis point)

      -- universal --
      uniqMerge(uaw) AS uaw,
      sum(transactions) AS transactions
FROM ohlc_prices
WHERE pool = lower('0xc7bbec68d12a0d1830360f8ec58fa599ba1b0e9b') -- Uniswap V3 WETH/USDT
GROUP BY pool, date
ORDER BY date DESC
LIMIT 7;

-- OHLC Prices by Pool (Uniswap V3 DAI/USDC) --
WITH (
      18 AS decimals0, -- JOIN contracts
      6 AS decimals1, -- JOIN contracts
      6 AS precision -- user defined
) SELECT
      timestamp,
      'DAI/USDC' AS ticker,

      -- OHLC --
      floor(argMinMerge(open0) * pow(10, decimals0 - decimals1), precision)                        AS open,
      floor(quantileDeterministicMerge(0.99)(high0) * pow(10, decimals0 - decimals1), precision)   AS high,
      floor(quantileDeterministicMerge(0.01)(low0) * pow(10, decimals0 - decimals1), precision)    AS low,
      floor(argMaxMerge(close0) * pow(10, decimals0 - decimals1), precision)                       AS close,

      -- volume --
      floor(sum(gross_volume0 / pow(10, decimals0)), precision)      AS "volume (DAI)"
FROM ohlc_prices
WHERE pool = lower('0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168') -- Uniswap V3 DAI/USDC
GROUP BY pool, timestamp
ORDER BY timestamp DESC;

-- OHLC Prices by Pool (Uniswap V3 WBTC/USDC) --
WITH (
      8 AS decimals0, -- JOIN contracts
      6 AS decimals1, -- JOIN contracts
      3 AS precision -- user defined
) SELECT
      timestamp,
      'WBTC/USDC' AS ticker,

      -- OHLC --
      floor(argMinMerge(open0) * pow(10, decimals0 - decimals1), precision)                        AS open,
      floor(quantileDeterministicMerge(0.99)(high0) * pow(10, decimals0 - decimals1), precision)   AS high,
      floor(quantileDeterministicMerge(0.01)(low0) * pow(10, decimals0 - decimals1), precision)    AS low,
      floor(argMaxMerge(close0) * pow(10, decimals0 - decimals1), precision)                       AS close,

      -- volume --
      floor(sum(gross_volume0 / pow(10, decimals0)), precision)         AS "volume (WBTC)",
      floor(sum(gross_volume1 / pow(10, decimals1)), precision)         AS "volume (USDC)"
FROM ohlc_prices
WHERE pool = lower('0x99ac8cA7087fA4A2A1FB6357269965A2014ABc35') -- Uniswap V3 WBTC/USDC
GROUP BY pool, timestamp
ORDER BY timestamp DESC
LIMIT 20;
