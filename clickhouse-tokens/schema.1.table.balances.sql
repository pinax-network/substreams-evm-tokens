-- ERC-20 & Native balances --
-- There can only be a single ERC-20 balance change per block for a given address / contract pair --
CREATE TABLE IF NOT EXISTS balances AS TEMPLATE_RPC
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address, contract)
COMMENT 'ERC-20 & Native balance changes per block for a given address / contract pair';

ALTER TABLE balances
    ADD COLUMN IF NOT EXISTS contract       String COMMENT 'token contract address',
    ADD COLUMN IF NOT EXISTS address        String COMMENT 'token holder address',
    ADD COLUMN IF NOT EXISTS balance        UInt256 COMMENT 'token balance';

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS balances_by_contract AS balances
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract, address);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_balances_by_contract
TO balances_by_contract AS
SELECT * FROM balances;
