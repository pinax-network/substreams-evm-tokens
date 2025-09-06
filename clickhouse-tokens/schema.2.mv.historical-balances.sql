-- Historical ERC-20 & Native balances by address/contract --
CREATE TABLE IF NOT EXISTS historical_balances_state (
    -- block --
    timestamp            DateTime(0, 'UTC') COMMENT 'the start of the aggregate window',
    block_num            SimpleAggregateFunction(min, UInt32) COMMENT 'the minimum block number in the aggregate window',

    -- balance change --
    contract             String COMMENT 'contract address',
    address              String COMMENT 'wallet address',

    -- ohlc --
    open                 AggregateFunction(argMin, UInt256, UInt32),
    high                 SimpleAggregateFunction(max, UInt256),
    low                  SimpleAggregateFunction(min, UInt256),
    close                AggregateFunction(argMax, UInt256, UInt32),
    uaw                  AggregateFunction(uniq, String) COMMENT 'unique wallet addresses that changed balance in the window',
    transactions         SimpleAggregateFunction(sum, UInt64) COMMENT 'total number of transactions in the window',
)
ENGINE = AggregatingMergeTree
ORDER BY (address, contract, timestamp);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_historical_balances
TO historical_balances_state
AS
SELECT
    -- block --
    toStartOfHour(timestamp) AS timestamp,
    min(block_num) AS block_num,

    -- balance change --
    address,
    contract,

    -- ohlc --
    argMinState(balance, b.block_num) AS open,
    max(balance) AS high,
    min(balance) AS low,
    argMaxState(balance, b.block_num) AS close,
    uniqState(address) AS uaw,
    count() AS transactions
FROM balances AS b
GROUP BY address, contract, timestamp;

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS historical_balances_state_by_contract AS historical_balances_state
ENGINE = AggregatingMergeTree
ORDER BY (contract, address, timestamp);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_historical_balances_state_by_contract
TO historical_balances_state_by_contract AS
SELECT * FROM historical_balances_state;
