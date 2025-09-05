-- Native transfers --
CREATE TABLE IF NOT EXISTS native_transfers AS TEMPLATE_TRANSACTIONS
TTL timestamp + INTERVAL 10 MINUTE DELETE
COMMENT 'Native Transfers';

ALTER TABLE native_transfers
    ADD COLUMN IF NOT EXISTS contract             String MATERIALIZED '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' COMMENT 'token contract address',
    ADD COLUMN IF NOT EXISTS `from`               FixedString(42) COMMENT 'sender address',
    ADD COLUMN IF NOT EXISTS `to`                 FixedString(42) COMMENT 'recipient address',
    ADD COLUMN IF NOT EXISTS value                UInt256 COMMENT 'transfer value';
