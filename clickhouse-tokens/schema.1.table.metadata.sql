-- ERC-20 Metadata Initialize --
CREATE TABLE IF NOT EXISTS metadata_initialize AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 Metadata Initialize';

ALTER TABLE metadata_initialize
    ADD COLUMN IF NOT EXISTS decimals             UInt8 COMMENT 'token decimals',
    ADD COLUMN IF NOT EXISTS name                 String COMMENT 'token name',
    ADD COLUMN IF NOT EXISTS symbol               String COMMENT 'token symbol';

-- ERC-20 Metadata Changes --
CREATE TABLE IF NOT EXISTS metadata_changes AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 Metadata Changes';

ALTER TABLE metadata_changes
    ADD COLUMN IF NOT EXISTS name                 String COMMENT 'token name',
    ADD COLUMN IF NOT EXISTS symbol               String COMMENT 'token symbol';