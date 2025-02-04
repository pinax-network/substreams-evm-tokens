-------------------------------------------------
-- Meta tables to store Substreams information --
-------------------------------------------------

CREATE TABLE IF NOT EXISTS cursors
(
    id        String,
    cursor    String,
    block_num Int64,
    block_id  String
)
    ENGINE = ReplacingMergeTree()
        PRIMARY KEY (id)
        ORDER BY (id);

-------------------------------------------------
-- -- Table for all balance changes event --
-------------------------------------------------

CREATE TABLE IF NOT EXISTS balance_changes  (
    -- block --
    timestamp           DateTime(0, 'UTC'),
    block_num           UInt32,
    date                Date,

    -- transaction --
    transaction_id      FixedString(64),
    call_index          UInt32,
    `index`             UInt32,
    version             UInt64,

    -- balance change --
    contract            FixedString(40),
    owner               FixedString(40),
    amount              UInt256,
    old_balance         UInt256,
    new_balance         UInt256
)
ENGINE = ReplacingMergeTree PRIMARY KEY (transaction_id, version)
ORDER BY (transaction_id, version);

-- ------------------------------------------------------------------------------
-- -- -- MV for historical balance changes event order by contract address   --
-- ------------------------------------------------------------------------------
-- CREATE MATERIALIZED VIEW balance_changes_contract_historical_mv
-- ENGINE = ReplacingMergeTree()
-- ORDER BY (contract, owner,block_num)
-- POPULATE
-- AS SELECT * FROM balance_changes;

-- ------------------------------------------------------------------------------
-- -- -- MV for historical balance changes event order by account address   --
-- ------------------------------------------------------------------------------
-- CREATE MATERIALIZED VIEW balance_changes_account_historical_mv
-- ENGINE = ReplacingMergeTree()
-- ORDER BY (owner, contract,block_num)
-- POPULATE
-- AS SELECT * FROM balance_changes;

-- -------------------------------------------
-- -- -- MV for latest token_holders   --
-- -------------------------------------------
-- CREATE TABLE IF NOT EXISTS token_holders
-- (
--     account              FixedString(40),
--     contract             String,
--     amount               UInt256,
--     block_num            UInt32,
--     timestamp            DateTime(0, 'UTC'),
--     tx_id                FixedString(64)
-- )
--     ENGINE = ReplacingMergeTree(block_num)
--         PRIMARY KEY (contract, account)
--         ORDER BY (contract, account);

-- CREATE MATERIALIZED VIEW token_holders_mv
--     TO token_holders
-- AS
-- SELECT owner as account,
--        contract,
--        new_balance as amount,
--        block_num,
--        timestamp,
--        transaction_id as tx_id
-- FROM balance_changes;

-- -------------------------------------------
-- --  MV for account balances   --
-- -------------------------------------------
-- CREATE TABLE IF NOT EXISTS account_balances
-- (
--     account              FixedString(40),
--     contract             String,
--     amount               UInt256,
--     block_num            UInt32,
--     timestamp            DateTime(0, 'UTC'),
--     tx_id                FixedString(64)
-- )
--     ENGINE = ReplacingMergeTree(block_num)
--         PRIMARY KEY (account,contract)
--         ORDER BY (account,contract);

-- CREATE MATERIALIZED VIEW account_balances_mv
--     TO account_balances
-- AS
-- SELECT owner as account,
--        contract,
--        amount,
--        block_num,
--        timestamp,
--        transaction_id as tx_id
-- FROM balance_changes;

-- -- Target table for daily EOD balances
-- CREATE TABLE IF NOT EXISTS daily_balances
-- (
--     date         Date,
--     contract     FixedString(40),
--     owner        FixedString(40),
--     balance      UInt256,
--     version      UInt32
-- )
-- ENGINE = ReplacingMergeTree(version)
-- ORDER BY (owner, contract, date);

CREATE TABLE IF NOT EXISTS latest_balances
(
    contract                    FixedString(40),
    owner                       FixedString(40),
    balance                     UInt256,

    last_transaction_id         FixedString(64),
    last_block_num              UInt32,
    last_call_index             UInt32,
    last_timestamp              DateTime,
    last_date                   Date,
    version                     UInt64
)
ENGINE = ReplacingMergeTree(version)
ORDER BY (contract, owner);

CREATE MATERIALIZED VIEW IF NOT EXISTS latest_balances_mv
TO latest_balances
AS SELECT
    contract,
    owner,
    argMax(new_balance, version) AS balance
    max(block_num) AS last_block_num,
    max(timestamp) AS last_timestamp,
    max(date) AS last_date,
    max(version) AS last_version,

    -- The newest balance: pick from row with highest 'version'
    argMax(transaction_id, version) AS last_transaction_id,

FROM balance_changes
GROUP BY contract, owner;

-- -- Materialized View to populate daily_balances
-- -- In ClickHouse, an aggregate function like argMax can only take one expression as the “ordering” argument.
-- -- So we typically combine (block_num, call_index) into a single monotonic integer.
-- -- For example, if each of block_num and call_index fits in 32 bits, we can do:
-- -- max(toUInt64(block_num) * 2^32 + call_index) AS version
-- CREATE MATERIALIZED VIEW daily_balances_mv
-- TO daily_balances
-- POPULATE
-- AS SELECT
--     toDate(timestamp) AS day,
--     contract,
--     owner,
--     argMax(new_balance, timestamp) AS balance,
--     max(toUInt32(timestamp)) AS version
-- FROM balance_changes
-- GROUP BY owner, contract, day;

-- -------------------------------------------------
-- --  Table for all token information --
-- -------------------------------------------------
-- CREATE TABLE IF NOT EXISTS contracts  (
--     contract FixedString(40),
--     name        String,
--     symbol      String,
--     decimals    UInt64,
--     block_num   UInt32,
--     timestamp   DateTime(0, 'UTC'),
-- )
-- ENGINE = ReplacingMergeTree PRIMARY KEY ("contract")
-- ORDER BY (contract);

-- -------------------------------------------------
-- --  Table for  token supply  --
-- -------------------------------------------------
-- CREATE TABLE IF NOT EXISTS supply  (
--     contract FixedString(40),
--     supply       UInt256,
--     block_num    UInt32,
--     timestamp    DateTime(0, 'UTC'),
-- )
-- ENGINE = ReplacingMergeTree()
-- ORDER BY (contract,supply);

-- -------------------------------------------------
-- --  MV for  token supply order by contract address  --
-- -------------------------------------------------
-- CREATE MATERIALIZED VIEW mv_supply_contract
-- ENGINE = ReplacingMergeTree()
-- ORDER BY (contract,block_num)
-- POPULATE
-- AS SELECT * FROM supply;

-- -------------------------------------------------
-- --  table for all transfers events  --
-- -------------------------------------------------
-- CREATE TABLE IF NOT EXISTS transfers (
--     id String,
--     contract FixedString(40),
--     `from` String,
--     `to` String,
--     value String,
--     tx_id String,
--     action_index UInt32,
--     block_num UInt32,
--     timestamp DateTime(0, 'UTC')
-- )
-- ENGINE = ReplacingMergeTree
-- PRIMARY KEY (id)
-- ORDER BY (id, tx_id, block_num, timestamp);

-- -------------------------------------------------
-- --  MV for historical transfers events by contract address --
-- -------------------------------------------------
-- CREATE MATERIALIZED VIEW transfers_contract_historical_mv
-- ENGINE = ReplacingMergeTree()
-- ORDER BY (contract, `from`,`to`,block_num)
-- POPULATE
-- AS SELECT * FROM transfers;

-- -------------------------------------------------
-- --  MV for historical transfers events by from address --
-- -------------------------------------------------
-- CREATE MATERIALIZED VIEW transfers_from_historical_mv
-- ENGINE = ReplacingMergeTree()
-- ORDER BY (`from`, contract,block_num)
-- POPULATE
-- AS SELECT * FROM transfers;

-- -------------------------------------------------
-- --  MV for historical transfers events by to address --
-- -------------------------------------------------
-- CREATE MATERIALIZED VIEW transfers_to_historical_mv
-- ENGINE = ReplacingMergeTree()
-- ORDER BY (`to`, contract,block_num)
-- POPULATE
-- AS SELECT * FROM transfers;

