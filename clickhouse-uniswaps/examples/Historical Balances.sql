-- Historical ERC-20 Balances by Address--
SELECT
      contract,
      timestamp,
      floor(argMinMerge(open), 4)  AS open,
      floor(max(high), 4)     AS high,
      floor(min(low), 4)      AS low,
      floor(argMaxMerge(close), 4) AS close
FROM historical_balances
WHERE
      address = lower('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045') -- Vitalik Buterin
GROUP BY address,contract,timestamp
ORDER BY timestamp DESC;

-- Unique Active Wallets & Transactions by ERC-20 Contracts --
SELECT
      timestamp,
      uniqMerge(uaw) AS uaw,
      sumMerge(transactions) AS transactions
FROM historical_balances_by_contract
WHERE contract = lower('0xdac17f958d2ee523a2206206994597c13d831ec7') -- USDT (ETH Mainnet)
GROUP by contract,timestamp
ORDER BY timestamp DESC
LIMIT 24; -- last 24 hours

-- Unique Active Wallets & Transactions by Native asset (ex: ETH,BNB) --
SELECT
      timestamp,
      uniqMerge(uaw) AS uaw,
      sumMerge(transactions) AS transactions
FROM historical_balances_by_contract
WHERE contract = '' -- Native ETH asset
GROUP by timestamp
ORDER BY timestamp DESC
LIMIT 24; -- last 24 hours
