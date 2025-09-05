-- Native transfers --
CREATE TABLE IF NOT EXISTS native_transfers AS TEMPLATE_TRANSACTIONS
TTL timestamp + INTERVAL 10 MINUTE DELETE
COMMENT 'Native Transfers';

ALTER TABLE native_transfers
    ADD COLUMN IF NOT EXISTS `from`               FixedString(42) COMMENT 'sender address',
    ADD COLUMN IF NOT EXISTS `to`                 FixedString(42) COMMENT 'recipient address',
    ADD COLUMN IF NOT EXISTS value                UInt256 COMMENT 'transfer value'
    -- indexes (event) --
    ADD INDEX IF NOT EXISTS idx_from               (`from`)             TYPE bloom_filter GRANULARITY 4,
    ADD INDEX IF NOT EXISTS idx_to                 (`to`)               TYPE bloom_filter GRANULARITY 4,
    ADD INDEX IF NOT EXISTS idx_value              (value)              TYPE minmax GRANULARITY 4;
