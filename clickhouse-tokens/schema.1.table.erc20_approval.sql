-- ERC-20 approvals --
CREATE TABLE IF NOT EXISTS erc20_approvals AS TEMPLATE_LOGS
COMMENT 'ERC-20 Approvals events';
ALTER TABLE erc20_approvals
    ADD COLUMN IF NOT EXISTS owner               FixedString(42) COMMENT 'owner address',
    ADD COLUMN IF NOT EXISTS spender             FixedString(42) COMMENT 'spender address',
    ADD COLUMN IF NOT EXISTS value               UInt256 COMMENT 'approval value',

    -- indexes (event) --
    ADD INDEX IF NOT EXISTS idx_owner              (owner)              TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_spender            (spender)            TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_value              (value)              TYPE minmax GRANULARITY 1;
