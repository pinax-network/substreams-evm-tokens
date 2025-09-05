-- ERC-20 balance by account --
-- There can only be a single ERC-20 balance change per block for a given address / contract pair --
CREATE TABLE IF NOT EXISTS erc20_balance_changes AS TEMPLATE_RPC_CALLS
TTL timestamp + INTERVAL 10 MINUTE DELETE
COMMENT 'ERC-20 Balance Changes';

ALTER TABLE erc20_balance_changes
    ADD COLUMN IF NOT EXISTS contract             String COMMENT 'token contract address',
    ADD COLUMN IF NOT EXISTS address              String COMMENT 'token holder address',
    ADD COLUMN IF NOT EXISTS balance              UInt256 COMMENT 'token balance';
