-- latest balances by owner/contract --
CREATE TABLE IF NOT EXISTS balances_state_latest  (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- event --
    contract             FixedString(42),
    address              FixedString(42),
    balance              UInt256
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address, contract);

-- insert ERC20 balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_balances
TO balances AS
SELECT
    -- block --
    block_num,
    block_hash,
    timestamp,

    -- event --
    contract,
    address,
    balance
FROM erc20_balance_changes;

-- insert Native balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_balances
TO balances AS
SELECT
    -- block --
    block_num,
    block_hash,
    timestamp,

    -- event --
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
    address,
    b.balance / pow(10, 18) AS balance,
    b.balance AS balance_raw,

    -- erc20 metadata --
    18 AS decimals,
    'Native' AS symbol,
    'Native' AS name

FROM native_balance_changes as b;

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS balances_by_contract AS balances
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract, address);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_balances_by_contract
TO balances_by_contract AS
SELECT * FROM balances;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_balances_fees
TO balances AS
SELECT
    -- block --
    block_num,
    block_hash,
    timestamp,

    -- event --
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract,
    address,
    b.balance / pow(10, 18) AS balance,
    b.balance AS balance_raw,

    -- erc20 metadata --
    18 AS decimals,
    'Native' AS symbol,
    'Native' AS name

FROM native_balance_changes_from_gas as b;