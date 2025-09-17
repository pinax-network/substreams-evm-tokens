-- ERC-20 Total Supply changes --
-- There can only be a single ERC-20 supply change per block per contract  --
CREATE TABLE IF NOT EXISTS total_supply AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 Supply Changes';

ALTER TABLE total_supply
    ADD COLUMN IF NOT EXISTS total_supply         UInt256 COMMENT 'token total supply',
    -- indexes (event) --
    ADD INDEX IF NOT EXISTS idx_total_supply      (total_supply)              TYPE minmax GRANULARITY 1;
