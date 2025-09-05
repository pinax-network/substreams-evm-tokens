-- ERC-20 & Native balance changes --
-- There can only be a single ERC-20 balance change per block for a given address / contract pair --
CREATE TABLE IF NOT EXISTS balance_changes AS TEMPLATE_RPC
ORDER BY (contract, address)
COMMENT 'ERC-20 & Native balance changes per block for a given address / contract pair';

ALTER TABLE balance_changes
    ADD COLUMN IF NOT EXISTS contract       String COMMENT 'token contract address',
    ADD COLUMN IF NOT EXISTS address        String COMMENT 'token holder address',
    ADD COLUMN IF NOT EXISTS balance        UInt256 COMMENT 'token balance';
