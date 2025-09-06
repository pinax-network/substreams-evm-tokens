-- ERC-20 & Native balances --
-- There can only be a single ERC-20 balance change per block for a given address / contract pair --
CREATE TABLE IF NOT EXISTS balances AS TEMPLATE_RPC
COMMENT 'ERC-20 & Native balance changes per block for a given address / contract pair';

ALTER TABLE balances
    ADD COLUMN IF NOT EXISTS address        String COMMENT 'token holder address',
    ADD COLUMN IF NOT EXISTS balance        UInt256 COMMENT 'token balance',
    MODIFY PRIMARY KEY (address, contract),
    MODIFY ORDER BY (address, contract);

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS balances_by_contract AS balances
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract, address);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_balances_by_contract
TO balances_by_contract AS
SELECT * FROM balances;
