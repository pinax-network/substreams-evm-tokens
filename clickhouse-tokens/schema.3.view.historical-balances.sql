-- Finalized read view over the AggregatingMergeTree "state" table
CREATE VIEW IF NOT EXISTS historical_balances AS
SELECT
    -- block/window
    timestamp,
    min(block_num)                         AS block_num,       -- SimpleAggregateFunction(min)

    -- keys
    contract,
    address,

    -- OHLC finalized
    argMinMerge(open)                      AS open,            -- from AggregateFunction(argMin, UInt256, UInt32)
    max(high)                              AS high,            -- SimpleAggregateFunction(max)
    min(low)                               AS low,             -- SimpleAggregateFunction(min)
    argMaxMerge(close)                     AS close,           -- from AggregateFunction(argMax, UInt256, UInt32)

    -- activity finalized
    uniqMerge(uaw)                         AS uaw,             -- from AggregateFunction(uniq, String)
    sum(transactions)                      AS transactions     -- SimpleAggregateFunction(sum)
FROM historical_balances_state
GROUP BY
    address, contract, timestamp;

CREATE VIEW IF NOT EXISTS historical_balances_by_contract AS
SELECT
    -- block/window
    timestamp,
    min(block_num)                         AS block_num,       -- SimpleAggregateFunction(min)

    -- keys
    contract,
    address,

    -- OHLC finalized
    argMinMerge(open)                      AS open,            -- from AggregateFunction(argMin, UInt256, UInt32)
    max(high)                              AS high,            -- SimpleAggregateFunction(max)
    min(low)                               AS low,             -- SimpleAggregateFunction(min)
    argMaxMerge(close)                     AS close,           -- from AggregateFunction(argMax, UInt256, UInt32)

    -- activity finalized
    uniqMerge(uaw)                         AS uaw,             -- from AggregateFunction(uniq, String)
    sum(transactions)                      AS transactions     -- SimpleAggregateFunction(sum)
FROM historical_balances_state_by_contract
GROUP BY
    contract, address, timestamp;
