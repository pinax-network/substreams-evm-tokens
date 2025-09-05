-- latest transfers --
CREATE TABLE IF NOT EXISTS transfers as erc20_transfers
COMMENT 'ERC20 + Native transfers (unified)';
ALTER TABLE transfers
    REMOVE TTL
    ADD INDEX IF NOT EXISTS idx_from               (`from`)             TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_to                 (`to`)               TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_value              (value)              TYPE minmax GRANULARITY 1;

-- insert ERC20 transfers --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc20_transfers
TO transfers AS
SELECT *
FROM erc20_transfers;

-- insert Native transfers --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfers
TO transfers AS
SELECT
    *,
    '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' AS contract
FROM native_transfers AS t;