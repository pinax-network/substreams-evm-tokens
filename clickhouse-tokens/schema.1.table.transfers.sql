-- ERC-20 transfers --
CREATE TABLE IF NOT EXISTS transfers AS TEMPLATE_LOGS
COMMENT 'ERC-20 & Native transfer events';

ALTER TABLE transfers
    ADD COLUMN IF NOT EXISTS `from`               FixedString(42) COMMENT 'sender address',
    ADD COLUMN IF NOT EXISTS `to`                 FixedString(42) COMMENT 'recipient address',
    ADD COLUMN IF NOT EXISTS value                UInt256 COMMENT 'transfer value';
