-- latest balances by owner/contract --
CREATE TABLE IF NOT EXISTS balances AS erc20_balance_changes
ENGINE = ReplacingMergeTree(global_sequence)
PRIMARY KEY (address, contract)
ORDER BY (address, contract);

-- insert ERC20 balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS erc20_balances_mv
TO balances AS
SELECT * FROM erc20_balance_changes
WHERE algorithm != 'ALGORITHM_BALANCE_NOT_MATCH_TRANSFER'; -- not implemented yet

-- insert Native balance changes --
CREATE MATERIALIZED VIEW IF NOT EXISTS native_balances_mv
TO balances AS
SELECT * FROM native_balance_changes;

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS balances_by_contract AS balances
ENGINE = ReplacingMergeTree(global_sequence)
PRIMARY KEY (contract, address)
ORDER BY (contract, address);

CREATE MATERIALIZED VIEW IF NOT EXISTS balances_by_contract_mv
TO balances_by_contract AS
SELECT * FROM balances;
