-- ERC-20 transfers --
CREATE TABLE IF NOT EXISTS transfers AS TEMPLATE_LOGS
COMMENT 'ERC-20 & Native transfer events';

ALTER TABLE transfers
    ADD COLUMN IF NOT EXISTS `from`               FixedString(42) COMMENT 'sender address',
    ADD COLUMN IF NOT EXISTS `to`                 FixedString(42) COMMENT 'recipient address',
    ADD COLUMN IF NOT EXISTS value                UInt256 COMMENT 'transfer value';

-- ERC-20 approvals --
CREATE TABLE IF NOT EXISTS approvals AS TEMPLATE_LOGS
COMMENT 'ERC-20 Approvals events';

ALTER TABLE approvals
    ADD COLUMN IF NOT EXISTS owner               FixedString(42) COMMENT 'owner address',
    ADD COLUMN IF NOT EXISTS spender             FixedString(42) COMMENT 'spender address',
    ADD COLUMN IF NOT EXISTS value               UInt256 COMMENT 'approval value',
    -- indexes (event) --
    ADD INDEX IF NOT EXISTS idx_owner              (owner)              TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_spender            (spender)            TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_value              (value)              TYPE minmax GRANULARITY 1;
