-- Native balance by account --
-- There can only be a single Native balance change per block for a given address  --
CREATE TABLE IF NOT EXISTS native_balance_changes AS TEMPLATE_RPC_CALLS
TTL timestamp + INTERVAL 10 MINUTE DELETE
COMMENT 'Native Balance Changes';

ALTER TABLE native_balance_changes
    ADD COLUMN IF NOT EXISTS address              String COMMENT 'token holder address',
    ADD COLUMN IF NOT EXISTS balance              UInt256 COMMENT 'token balance';

