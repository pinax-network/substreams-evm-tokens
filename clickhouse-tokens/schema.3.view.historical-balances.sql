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
    open                 AggregateFunction(argMin, UInt256, UInt32),
    high                 SimpleAggregateFunction(max, UInt256),
    low                  SimpleAggregateFunction(min, UInt256),
    close                AggregateFunction(argMax, UInt256, UInt32),
    uaw                  AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses that changed balance in the window',
    transactions         SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window',
)
ENGINE = AggregatingMergeTree
ORDER BY (address, contract, timestamp);

-- ERC-20 balances --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_historical_erc20_balances
TO historical_balances
AS
WITH (
    pow(10, m.decimals) AS scale
)
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
    sumState(1) AS transactions
FROM native_balance_changes AS b
GROUP BY address, timestamp;

-- Historical balances by contract/address --
CREATE MATERIALIZED VIEW IF NOT EXISTS historical_balances_by_contract
ENGINE = AggregatingMergeTree
ORDER BY (contract, address, timestamp)
AS
SELECT * FROM historical_balances;
