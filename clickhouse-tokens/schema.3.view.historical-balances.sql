-- Historical ERC-20 balances by address/contract --
CREATE TABLE IF NOT EXISTS historical_balances (
    -- block --
    block_num            SimpleAggregateFunction(min, UInt32),
    timestamp            DateTime(0, 'UTC') COMMENT 'the start of the aggregate window',

    -- balance change --
    contract             FixedString(42) COMMENT 'contract address',
    address              FixedString(42) COMMENT 'wallet address',

    -- erc20 metadata --
    decimals            SimpleAggregateFunction(any, UInt8),
    symbol              SimpleAggregateFunction(anyLast, Nullable(String)),
    name                SimpleAggregateFunction(anyLast, Nullable(String)),

    -- ohlc --
    open                 AggregateFunction(argMin, Float64, UInt32),
    high                 SimpleAggregateFunction(max, Float64),
    low                  SimpleAggregateFunction(min, Float64),
    close                AggregateFunction(argMax, Float64, UInt32),
    uaw                  AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses that changed balance in the window',
    transactions         SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window',
)
ENGINE = AggregatingMergeTree
ORDER BY (address, contract, timestamp);

-- ERC-20 balances --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_historical_erc20_balances
TO historical_balances
AS
WITH
    b.balance / pow(10, m.decimals) AS balance
SELECT
    -- block --
    toStartOfHour(timestamp) AS timestamp,
    min(block_num) AS block_num,

    -- balance change --
    address,
    contract,

    -- erc20 metadata --
    any(m.decimals) AS decimals,
    anyLast(m.symbol) AS symbol,
    anyLast(m.name) AS name,

    -- ohlc --
    argMinState(balance, b.block_num) AS open,
    max(balance) AS high,
    min(balance) AS low,
    argMaxState(balance, b.block_num) AS close,
    uniqState(address) AS uaw,
    count() AS transactions
FROM erc20_balance_changes AS b
JOIN erc20_metadata AS m ON m.address = b.contract
GROUP BY address, contract, timestamp;

-- Native balances --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_historical_native_balances
TO historical_balances
AS
WITH
    b.balance / pow(10, 18) AS balance
SELECT
    -- block --
    min(block_num) AS block_num,
    toStartOfHour(timestamp) AS timestamp,

    -- balance change --
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
    address,

    -- erc20 metadata --
    18 AS decimals,
    'Native' AS symbol,
    'Native' AS name,

    -- balance --
    argMinState(balance, b.block_num) AS open,
    max(balance) AS high,
    min(balance) AS low,
    argMaxState(balance, b.block_num) AS close,
    uniqState(address) AS uaw,
    count() AS transactions
FROM native_balance_changes AS b
GROUP BY address, timestamp;

CREATE MATERIALIZED VIEW mv_historical_native_balances_fees TO historical_balances
(
    `block_num` UInt32,
    `timestamp` DateTime('UTC'),
    `contract` String,
    `address` FixedString(42),
    `decimals` UInt8,
    `symbol` String,
    `name` String,
    `open` AggregateFunction(argMin, Float64, UInt32),
    `high` Float64,
    `low` Float64,
    `close` AggregateFunction(argMax, Float64, UInt32),
    `uaw` AggregateFunction(uniq, FixedString(42)),
    `transactions` UInt64
)
AS (WITH b.balance / pow(10, 18) AS balance
SELECT
    min(block_num) AS block_num,
    toStartOfHour(timestamp) AS timestamp,
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
    address,
    18 AS decimals,
    'Native' AS symbol,
    'Native' AS name,
    argMinState(balance, b.block_num) AS open,
    max(balance) AS high,
    min(balance) AS low,
    argMaxState(balance, b.block_num) AS close,
    uniqState(address) AS uaw,
    count() AS transactions
FROM native_balance_changes_from_gas AS b -- Key update is here
GROUP BY
    address,
    timestamp);

-- Historical balances by contract/address --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_balances_by_contract
ENGINE = AggregatingMergeTree
ORDER BY (contract, address, timestamp)
AS
SELECT * FROM historical_balances;
