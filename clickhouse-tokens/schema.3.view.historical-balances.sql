-- Historical ERC-20 balances by address/contract --
CREATE TABLE IF NOT EXISTS historical_balances (
   -- block --
   block_num            SimpleAggregateFunction(min, UInt32),
   timestamp            DateTime(0, 'UTC') COMMENT 'the start of the aggregate window',

   -- balance change --
   contract             FixedString(42) COMMENT 'contract address',
   address              FixedString(42) COMMENT 'wallet address',

   -- balance --
   open                 AggregateFunction(argMin, UInt256, UInt64),
   high                 SimpleAggregateFunction(max, UInt256),
   low                  SimpleAggregateFunction(min, UInt256),
   close                AggregateFunction(argMax, UInt256, UInt64),
   uaw                  AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses that changed balance in the window',
   transactions         AggregateFunction(sum, UInt8) COMMENT 'number of transactions that changed balance in the window'
)
ENGINE = AggregatingMergeTree
PRIMARY KEY (address, contract, timestamp)
ORDER BY (address, contract, timestamp);

-- ERC-20 balances --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_erc20_balances_mv
TO historical_balances
AS
SELECT
   toStartOfHour(timestamp) AS timestamp,
   min(block_num) AS block_num,
   address,
   contract,
   argMinState(new_balance, global_sequence) AS open, -- normalized to wei (18 decimals)
   max(new_balance) AS high, -- normalized to wei (18 decimals)
   min(new_balance) AS low, -- normalized to wei (18 decimals)
   argMaxState(new_balance, global_sequence) AS close, -- normalized to wei (18 decimals)
   uniqState(address) AS uaw,
   sumState(1) AS transactions
FROM erc20_balance_changes
GROUP BY address, contract, timestamp;

-- Native balances --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_native_balances_mv
TO historical_balances
AS
SELECT
   -- block --
   min(block_num) AS block_num,
   toStartOfHour(timestamp) AS timestamp,

   -- balance change --
   '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
   address,

   -- balance --
   argMinState(new_balance, global_sequence) AS open,
   max(new_balance) AS high,
   min(new_balance) AS low,
   argMaxState(new_balance, global_sequence) AS close,
   uniqState(address) AS uaw,
   sumState(1) AS transactions
FROM native_balance_changes
GROUP BY address, timestamp;

-- Historical balances by contract/address --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_balances_by_contract
ENGINE = AggregatingMergeTree
PRIMARY KEY (contract, address, timestamp)
ORDER BY (contract, address, timestamp)
AS
SELECT * FROM historical_balances;
