-- ERC-20 & Native balances --
-- There can only be a single ERC-20 balance change per block for a given address / contract pair --
CREATE TABLE IF NOT EXISTS balances (
    -- block --
    block_num            UInt32,
    block_hash           String,
    timestamp            DateTime(0, 'UTC'),

    -- rpc call --
    contract            String COMMENT 'token contract address',
    address             String COMMENT 'token holder address',
    balance             UInt256 COMMENT 'token balance',

    -- indexes --
    INDEX idx_block_num          (block_num)          TYPE minmax               GRANULARITY 1,
    INDEX idx_block_hash         (block_hash)         TYPE bloom_filter(0.005)  GRANULARITY 1,
    INDEX idx_timestamp          (timestamp)          TYPE minmax               GRANULARITY 1
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address, contract)
COMMENT 'ERC-20 & Native balance changes per block for a given address / contract pair';

-- latest balances by contract/address --
CREATE TABLE IF NOT EXISTS balances_by_contract AS balances
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract, address);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_balances_by_contract
TO balances_by_contract AS
SELECT * FROM balances;
