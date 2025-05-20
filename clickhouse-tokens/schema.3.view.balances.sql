-- latest balances by owner/contract --
CREATE TABLE IF NOT EXISTS balances AS erc20_balance_changes
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address, contract);

-- insert ERC20 balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_balances
TO balances AS
SELECT * FROM erc20_balance_changes;

-- insert Native balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_balances
TO balances AS
SELECT * FROM native_balance_changes;

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS balances_by_contract AS balances
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract, address);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_balances_by_contract
TO balances_by_contract AS
SELECT * FROM balances;
