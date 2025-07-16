-- latest balances by owner/contract --
CREATE TABLE IF NOT EXISTS balances  (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- event --
    contract             FixedString(42),
    address              FixedString(42),
    balance              Float64,
    balance_raw          UInt256,

    -- erc20 metadata --
    decimals             UInt8,
    symbol               Nullable(String),
    name                 Nullable(String),

    -- indexes --
    INDEX idx_block_num          (block_num)           TYPE minmax GRANULARITY 4,
    INDEX idx_timestamp          (timestamp)           TYPE minmax GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)            TYPE set(64) GRANULARITY 4,
    INDEX idx_address            (address)             TYPE bloom_filter GRANULARITY 4,
    INDEX idx_balance            (balance)             TYPE minmax GRANULARITY 4,

    -- indexes (erc20 metadata) --
    INDEX idx_decimals           (decimals)            TYPE set(32) GRANULARITY 4,
    INDEX idx_symbol             (symbol)              TYPE set(64) GRANULARITY 4,
    INDEX idx_name               (name)                TYPE set(64) GRANULARITY 4
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address, contract);

-- insert ERC20 balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_balances
TO balances AS
SELECT
    -- block --
    b.block_num AS block_num,
    b.block_hash AS block_hash,
    b.timestamp AS timestamp,

    -- event --
    b.contract AS contract,
    b.address AS address,
    b.balance / pow(10, m.decimals) AS balance,
    b.balance AS balance_raw,

    -- erc20 metadata --
    m.decimals AS decimals,
    m.symbol AS symbol,
    m.name AS name

FROM erc20_balance_changes AS b
JOIN erc20_metadata AS m ON m.address = b.contract;

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