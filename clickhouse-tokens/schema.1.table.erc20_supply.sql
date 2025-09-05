-- ERC-20 Total Supply changes --
-- There can only be a single ERC-20 supply change per block per contract  --
CREATE TABLE IF NOT EXISTS erc20_total_supply_changes AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 Supply Changes';
ALTER TABLE erc20_total_supply_changes
    ADD COLUMN IF NOT EXISTS contract             String COMMENT 'token contract address',
    ADD COLUMN IF NOT EXISTS total_supply         UInt256 COMMENT 'token total supply';
